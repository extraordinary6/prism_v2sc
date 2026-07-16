#!/usr/bin/env python3
"""Deterministic generated RTL/SystemC differential regression."""

from __future__ import annotations

import argparse
import json
import random
import sys
from dataclasses import asdict, dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))

from tests.equivalence import run_equivalence as eq  # noqa: E402


@dataclass(frozen=True)
class GeneratedCase:
    name: str
    width: int
    expression: str
    seed: int


EXPRESSIONS = (
    "(a ^ b) + {{(W-1){1'b0}}, sel}",
    "sel ? (a + b) : (a - b)",
    "(a << sh) | (b >> sh)",
    "{a[W/2-1:0], b[W-1:W/2]}",
    "(~a) ^ (b + {{(W-1){1'b0}}, sel})",
)


def generate_cases(seed: int, count: int) -> tuple[GeneratedCase, ...]:
    rng = random.Random(seed)
    widths = (4, 8, 16, 32)
    return tuple(
        GeneratedCase(
            name=f"generated_semantics_{index:02d}",
            width=rng.choice(widths),
            expression=rng.choice(EXPRESSIONS),
            seed=rng.getrandbits(32),
        )
        for index in range(count)
    )


def render_case(case: GeneratedCase) -> str:
    return f"""module {case.name} #(parameter W = {case.width}) (
  input wire clk,
  input wire rst_n,
  input wire en,
  input wire sel,
  input wire [4:0] sh,
  input wire [W-1:0] a,
  input wire [W-1:0] b,
  output wire [W-1:0] comb,
  output reg [W-1:0] q
);
  assign comb = {case.expression};
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      q <= {{W{{1'b0}}}};
    else if (en)
      q <= comb;
  end
endmodule
"""


def run(seed: int, count: int, work: Path, rtl_sim: str, dry_run: bool) -> int:
    source_dir = work / "generated_sources"
    source_dir.mkdir(parents=True, exist_ok=True)
    cases = generate_cases(seed, count)
    (work / "cases.json").write_text(
        json.dumps([asdict(case) for case in cases], indent=2) + "\n", encoding="utf-8"
    )
    fixtures: list[eq.Fixture] = []
    for case in cases:
        (source_dir / f"{case.name}.v").write_text(render_case(case), encoding="utf-8")
        fixtures.append(
            eq.Fixture(
                name=case.name,
                sources=(f"{case.name}.v",),
                top=case.name,
                inputs=(
                    eq.Port("en", 1), eq.Port("sel", 1), eq.Port("sh", 5),
                    eq.Port("a", case.width), eq.Port("b", case.width),
                ),
                outputs=(eq.Port("comb", case.width), eq.Port("q", case.width)),
                sequential=True,
                clock="clk",
                reset="rst_n",
                cycles=192,
                seed=case.seed,
            )
        )

    original_fixture_dir = eq.FIXTURE_DIR
    eq.FIXTURE_DIR = source_dir
    try:
        selected_sim = rtl_sim if dry_run else eq.select_rtl_simulator(rtl_sim)
        overall = 0
        for fixture in fixtures:
            print(f"\n=== generated fixture: {fixture.name} ===")
            rc = eq.run_fixture(
                fixture,
                work / fixture.name,
                shift_tolerance=0,
                rtl_sim=selected_sim,
                dry_run=dry_run,
            )
            if rc:
                overall = rc
                print(f"Generated semantic consistency failed; retained case: {source_dir / (fixture.name + '.v')}")
                break
        if overall == 0:
            print(f"Generated semantic consistency passed: {len(fixtures)} cases, seed={seed}")
        return overall
    finally:
        eq.FIXTURE_DIR = original_fixture_dir


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed", type=lambda value: int(value, 0), default=0x2035C0DE)
    parser.add_argument("--count", type=int, default=12)
    parser.add_argument("--work", type=Path, default=ROOT / "build/generated_semantic_consistency")
    parser.add_argument("--rtl-sim", choices=("auto", "iverilog", "vcs"), default="auto")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    if args.count <= 0:
        parser.error("--count must be positive")
    return run(args.seed, args.count, args.work.resolve(), args.rtl_sim, args.dry_run)


if __name__ == "__main__":
    raise SystemExit(main())
