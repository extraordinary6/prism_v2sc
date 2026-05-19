"""RTL vs prism_v2sc-generated SystemC equivalence harness.

This script is intended to run in CI (Linux) where Icarus Verilog
(`iverilog`/`vvp`) and SystemC (libsystemc-dev) are installed alongside
Python + pyslang. For each fixture it:

  1. Runs prism-v2sc to lower the RTL into a SystemC header.
  2. Generates a deterministic stimulus file.
  3. Generates a matching Verilog testbench and a SystemC testbench that
     both consume the same stimulus file.
  4. Builds and runs the RTL testbench with iverilog/vvp.
  5. Builds and runs the SystemC testbench with $CXX + -lsystemc.
  6. Diffs the per-cycle output traces.

The comparison is line-by-line (one trace line per stimulus cycle), with
an optional uniform shift tolerance for "near cycle accurate" alignment.
"""

from __future__ import annotations

import argparse
import json
import os
import random
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

THIS_FILE = Path(__file__).resolve()
PROJECT_ROOT = THIS_FILE.parents[2]
FIXTURE_DIR = THIS_FILE.parent / "fixtures"


@dataclass(frozen=True)
class Port:
    name: str
    width: int

    @property
    def is_bool(self) -> bool:
        return self.width == 1

    @property
    def sc_type(self) -> str:
        return "bool" if self.is_bool else f"sc_uint<{self.width}>"


@dataclass(frozen=True)
class Fixture:
    name: str
    sources: tuple[str, ...]
    top: str
    inputs: tuple[Port, ...]
    outputs: tuple[Port, ...]
    sequential: bool
    clock: str | None = None
    reset: str | None = None
    reset_active_low: bool = True
    cycles: int = 256
    reset_cycles: int = 3
    seed: int = 0xCAFEBABE
    sc_template_args: tuple[str, ...] = ()
    filelist: str | None = None


FIXTURES: tuple[Fixture, ...] = (
    Fixture(
        name="mux2",
        sources=("mux2.v",),
        top="mux2",
        inputs=(Port("sel", 1), Port("a", 4), Port("b", 4)),
        outputs=(Port("y", 4),),
        sequential=False,
        cycles=64,
    ),
    Fixture(
        name="adder",
        sources=("adder.v",),
        top="adder",
        inputs=(Port("a", 8), Port("b", 8), Port("ci", 1)),
        outputs=(Port("sum", 8), Port("co", 1)),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="byteswap",
        sources=("byteswap.v",),
        top="byteswap",
        inputs=(Port("data_in", 32),),
        outputs=(Port("data_out", 32),),
        sequential=False,
        cycles=64,
    ),
    Fixture(
        name="alu",
        sources=("alu.v",),
        top="alu",
        inputs=(Port("a", 8), Port("b", 8), Port("op", 3)),
        outputs=(Port("result", 8), Port("zero", 1), Port("carry", 1)),
        sequential=False,
        cycles=256,
    ),
    Fixture(
        name="function_alu",
        sources=("function_alu.v",),
        top="function_alu",
        inputs=(Port("a", 8), Port("b", 8), Port("op", 3)),
        outputs=(Port("result", 8),),
        sequential=False,
        cycles=256,
    ),
    Fixture(
        name="counter",
        sources=("counter.v",),
        top="counter",
        inputs=(Port("en", 1),),
        outputs=(Port("count", 8),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="shift_register",
        sources=("shift_register.v",),
        top="shift_register",
        inputs=(
            Port("load", 1),
            Port("shift_en", 1),
            Port("parallel_in", 8),
            Port("serial_in", 1),
        ),
        outputs=(Port("data_out", 8), Port("serial_out", 1)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="fsm_handshake",
        sources=("fsm_handshake.v",),
        top="fsm_handshake",
        inputs=(Port("start", 1), Port("data_valid", 1)),
        outputs=(Port("ready", 1), Port("done", 1)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="pipeline8",
        sources=("pipeline8.v",),
        top="pipeline8",
        inputs=(Port("valid_i", 1), Port("data_i", 8)),
        outputs=(Port("valid_o", 1), Port("data_o", 8)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=256,
    ),
    Fixture(
        name="multi_file",
        sources=(),
        filelist="multi_file/sources.f",
        top="top_datapath",
        inputs=(Port("en", 1), Port("sel", 1), Port("a", 8), Port("b", 8)),
        outputs=(Port("y", 8),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="gen_demo",
        sources=("gen_demo.v",),
        top="gen_demo",
        inputs=(Port("a", 4),),
        outputs=(Port("y", 4),),
        sequential=False,
        cycles=64,
    ),
    Fixture(
        name="slice_writers",
        sources=("slice_writers.v",),
        top="slice_writers",
        inputs=(Port("a", 1), Port("b", 1)),
        outputs=(Port("q", 2),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=64,
    ),
    Fixture(
        name="sv_always_comb",
        sources=("sv_always_comb.v",),
        top="sv_always_comb",
        inputs=(Port("a", 8), Port("b", 8), Port("sel", 1)),
        outputs=(Port("y", 8),),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="sv_always_ff",
        sources=("sv_always_ff.v",),
        top="sv_always_ff",
        inputs=(Port("d", 8),),
        outputs=(Port("q", 8),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="sv_always_latch",
        sources=("sv_always_latch.v",),
        top="sv_always_latch",
        inputs=(Port("en", 1), Port("d", 8)),
        outputs=(Port("q", 8),),
        sequential=False,
        cycles=128,
    ),
)


@dataclass(frozen=True)
class DiagnosticFixture:
    """A fixture asserting that ``prism-v2sc`` emits specific diagnostic codes.

    Used for rejection-class behavior that can't be trace-equivalence tested
    (driver conflicts, unknown modules, duplicate definitions, X/Z literal
    approximation, etc.). Each entry runs prism-v2sc on the given RTL,
    reads the resulting ``ir.json``, and asserts every code in
    ``expected_codes`` appears in either the design-level or any module-level
    ``diagnostics`` list.
    """

    name: str
    sources: tuple[str, ...]
    top: str
    expected_codes: tuple[str, ...]


DIAGNOSTIC_FIXTURES: tuple[DiagnosticFixture, ...] = (
    DiagnosticFixture(
        name="driver_conflict_procedural",
        sources=("diagnostics/driver_conflict_procedural.v",),
        top="dc_proc",
        # Two always_ff blocks writing the same whole signal trigger both
        # the generic procedural-driver check and the always_ff-specific one.
        expected_codes=("multiple_procedural_drivers", "multiple_always_ff_drivers"),
    ),
    DiagnosticFixture(
        name="mixed_assignment_styles",
        sources=("diagnostics/mixed_assignment_styles.v",),
        top="mixed_assign",
        expected_codes=("mixed_assignment_styles",),
    ),
    DiagnosticFixture(
        name="blocking_in_always_ff",
        sources=("diagnostics/blocking_in_always_ff.v",),
        top="blk_in_ff",
        expected_codes=("blocking_in_always_ff",),
    ),
    DiagnosticFixture(
        name="xz_literal_approximated",
        sources=("diagnostics/xz_literal.v",),
        top="xz_lit",
        expected_codes=("x_z_literal_approximated",),
    ),
    DiagnosticFixture(
        name="slang_unknown_module",
        sources=("diagnostics/slang_unknown_module.v",),
        top="su_top",
        expected_codes=("slang_UnknownModule",),
    ),
    DiagnosticFixture(
        name="slang_duplicate_definition",
        sources=("diagnostics/slang_duplicate_definition.v",),
        top="dup",
        expected_codes=("slang_DuplicateDefinition",),
    ),
)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--fixtures",
        nargs="*",
        default=None,
        help="Fixture names to run (default: all).",
    )
    parser.add_argument(
        "--work",
        type=Path,
        default=PROJECT_ROOT / "build" / "equivalence",
        help="Working/build directory.",
    )
    parser.add_argument(
        "--shift-tolerance",
        type=int,
        default=0,
        help="Allow the SystemC trace to lag the RTL trace by N cycles (drop first N SC entries before diffing).",
    )
    parser.add_argument(
        "--keep-going",
        action="store_true",
        help="Don't stop after the first failing fixture.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Generate SystemC, stimulus, and testbenches but skip iverilog/SystemC build and diff.",
    )
    args = parser.parse_args(argv)
    args.work.mkdir(parents=True, exist_ok=True)

    selected: list[Fixture] = [
        fixture for fixture in FIXTURES if args.fixtures is None or fixture.name in args.fixtures
    ]
    selected_diag: list[DiagnosticFixture] = [
        fixture
        for fixture in DIAGNOSTIC_FIXTURES
        if args.fixtures is None or fixture.name in args.fixtures
    ]
    if not selected and not selected_diag:
        print("error: no fixtures match the selection", file=sys.stderr)
        return 2

    if selected and not args.dry_run:
        require_tool("iverilog")
        require_tool("vvp")
        require_tool(os.environ.get("CXX", "g++"))

    summary: list[tuple[str, str]] = []
    overall = 0
    for fixture in selected:
        print(f"\n=== fixture: {fixture.name} ===")
        rc = run_fixture(
            fixture,
            args.work / fixture.name,
            shift_tolerance=args.shift_tolerance,
            dry_run=args.dry_run,
        )
        summary.append((fixture.name, "PASS" if rc == 0 else "FAIL"))
        if rc != 0:
            overall = rc
            if not args.keep_going:
                break

    if overall == 0 or args.keep_going:
        for fixture in selected_diag:
            print(f"\n=== diagnostic fixture: {fixture.name} ===")
            rc = run_diagnostic_fixture(fixture, args.work / fixture.name)
            summary.append((fixture.name, "PASS" if rc == 0 else "FAIL"))
            if rc != 0:
                overall = rc
                if not args.keep_going:
                    break

    print("\n=== summary ===")
    for name, status in summary:
        print(f"  {name}: {status}")
    return overall


def require_tool(name: str) -> None:
    if shutil.which(name) is None:
        print(f"error: required tool '{name}' not found on PATH", file=sys.stderr)
        sys.exit(2)


def run_diagnostic_fixture(fixture: DiagnosticFixture, work: Path) -> int:
    """Run ``prism-v2sc`` on a fixture and assert every expected diagnostic
    code appears in the resulting ``ir.json``. Returns 0 on PASS, 1 on FAIL.
    """
    work.mkdir(parents=True, exist_ok=True)
    sources = [FIXTURE_DIR / source for source in fixture.sources]
    for source in sources:
        if not source.is_file():
            print(f"  ERROR: missing fixture source {source}")
            return 2

    out_dir = work / "systemc"
    out_dir.mkdir(parents=True, exist_ok=True)
    log_path = work / "prism.log"
    cmd = [
        sys.executable,
        "-m",
        "prism_v2sc",
        "--top",
        fixture.top,
        "--out",
        str(out_dir),
        *(str(source) for source in sources),
    ]
    env = os.environ.copy()
    new_path = str(PROJECT_ROOT / "src")
    existing = env.get("PYTHONPATH", "")
    env["PYTHONPATH"] = new_path + (os.pathsep + existing if existing else "")
    print(f"  $ {' '.join(cmd)}")
    with log_path.open("w", encoding="utf-8") as log:
        # prism-v2sc may exit non-zero for some diagnostic cases (e.g. when
        # slang refuses to elaborate); we still want to inspect ir.json if
        # it was produced. So we don't fail on a non-zero return code here.
        subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, env=env)

    ir_path = out_dir / "ir.json"
    if not ir_path.is_file():
        print(f"  ERROR: ir.json was not produced (see {log_path})")
        return 1
    try:
        payload = json.loads(ir_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"  ERROR: ir.json is malformed: {exc} (see {log_path})")
        return 1

    seen_codes: set[str] = set()
    for diagnostic in payload.get("diagnostics", ()):
        if isinstance(diagnostic, dict):
            seen_codes.add(str(diagnostic.get("code", "")))
    for module in payload.get("modules", ()):
        if not isinstance(module, dict):
            continue
        for diagnostic in module.get("diagnostics", ()):
            if isinstance(diagnostic, dict):
                seen_codes.add(str(diagnostic.get("code", "")))

    missing = [code for code in fixture.expected_codes if code not in seen_codes]
    if missing:
        print(f"  MISSING: expected diagnostic codes not found: {', '.join(missing)}")
        print(f"    seen codes: {sorted(seen_codes) or '<none>'}")
        print(f"    log: {log_path}")
        return 1
    print(f"  PASS: all {len(fixture.expected_codes)} expected diagnostic(s) present")
    return 0


def run_fixture(fixture: Fixture, work: Path, *, shift_tolerance: int, dry_run: bool = False) -> int:
    work.mkdir(parents=True, exist_ok=True)
    sources = [FIXTURE_DIR / source for source in fixture.sources]
    for source in sources:
        if not source.is_file():
            print(f"  ERROR: missing fixture source {source}")
            return 2

    filelist_path: Path | None = None
    extra_includes: list[Path] = []
    extra_defines: list[str] = []
    if fixture.filelist is not None:
        filelist_path = FIXTURE_DIR / fixture.filelist
        if not filelist_path.is_file():
            print(f"  ERROR: missing filelist {filelist_path}")
            return 2
        # Reuse the prism preprocess parser so iverilog gets the same -I / -D set.
        sys.path.insert(0, str(PROJECT_ROOT / "src"))
        try:
            from prism_v2sc.frontend.preprocess import collect_sources
        finally:
            sys.path.pop(0)
        resolved = collect_sources([], [filelist_path])
        sources.extend(resolved.sources)
        extra_includes = list(resolved.include_dirs)
        extra_defines = list(resolved.defines)
        # Resolved sources from the filelist are absolute; dedupe deterministically.
        seen: set[str] = set()
        unique: list[Path] = []
        for source in sources:
            key = str(source.resolve()).casefold() if os.name == "nt" else str(source.resolve())
            if key in seen:
                continue
            seen.add(key)
            unique.append(source)
        sources = unique

    sc_out_dir = work / "systemc"
    if not convert_with_prism(
        sources if filelist_path is None else [],
        fixture.top,
        sc_out_dir,
        log_path=work / "prism.log",
        filelist=filelist_path,
    ):
        return 1

    top_header_path = _locate_top_header(sc_out_dir, fixture.top)
    if top_header_path is None:
        print(f"  ERROR: top hpp for '{fixture.top}' not found under {sc_out_dir}")
        return 1

    stim_path = work / "stim.txt"
    write_stimulus(fixture, stim_path)

    rtl_trace = work / "rtl_trace.txt"
    sc_trace = work / "sc_trace.txt"
    vtb_path = work / f"tb_{fixture.name}.v"
    sctb_path = work / f"tb_{fixture.name}.cpp"
    vtb_path.write_text(render_verilog_tb(fixture, stim_path, rtl_trace), encoding="utf-8")
    sctb_path.write_text(
        render_systemc_tb(fixture, stim_path, sc_trace, top_header_path, sc_out_dir),
        encoding="utf-8",
    )

    if dry_run:
        print("  dry-run: generated SystemC header, stimulus, Verilog TB, SystemC TB")
        return 0

    vvp_path = work / "rtl.vvp"
    iverilog_cmd = [
        "iverilog",
        "-g2012",
        *[f"-I{include_dir}" for include_dir in extra_includes],
        *[f"-D{define}" for define in extra_defines],
        "-o",
        str(vvp_path),
        str(vtb_path),
        *[str(source) for source in sources],
    ]
    if run_logged(iverilog_cmd, work / "iverilog.log") != 0:
        print(f"  iverilog build failed (see {work / 'iverilog.log'})")
        return 1
    if run_logged(["vvp", str(vvp_path)], work / "vvp.log", cwd=work) != 0:
        print(f"  vvp run failed (see {work / 'vvp.log'})")
        return 1

    sctb_exe = work / "tb_sc"
    cxx = os.environ.get("CXX", "g++")
    cxx_flags = [flag for flag in os.environ.get("SC_CXXFLAGS", "").split() if flag]
    ld_flags = [flag for flag in os.environ.get("SC_LDFLAGS", "").split() if flag]
    libs = os.environ.get("SC_LIBS", "-lsystemc -lpthread").split()
    sc_include = sc_out_dir.resolve()
    cxx_cmd = [
        cxx,
        "-std=c++17",
        "-O0",
        "-g",
        f"-I{sc_include}",
        *cxx_flags,
        str(sctb_path),
        "-o",
        str(sctb_exe),
        *ld_flags,
        *libs,
    ]
    if run_logged(cxx_cmd, work / "g++.log") != 0:
        print(f"  SystemC compile failed (see {work / 'g++.log'})")
        return 1
    if run_logged([str(sctb_exe)], work / "sc_run.log", cwd=work) != 0:
        print(f"  SystemC run failed (see {work / 'sc_run.log'})")
        return 1

    return diff_traces(
        rtl_trace.read_text(encoding="utf-8").splitlines(),
        sc_trace.read_text(encoding="utf-8").splitlines(),
        work,
        shift_tolerance,
    )


def convert_with_prism(
    sources: list[Path],
    top: str,
    out_dir: Path,
    *,
    log_path: Path,
    filelist: Path | None = None,
) -> bool:
    out_dir.mkdir(parents=True, exist_ok=True)
    cmd = [
        sys.executable,
        "-m",
        "prism_v2sc",
        "--top",
        top,
        "--out",
        str(out_dir),
    ]
    if filelist is not None:
        cmd.extend(["--filelist", str(filelist)])
    cmd.extend(str(source) for source in sources)
    env = os.environ.copy()
    new_path = str(PROJECT_ROOT / "src")
    existing = env.get("PYTHONPATH", "")
    env["PYTHONPATH"] = new_path + (os.pathsep + existing if existing else "")
    print(f"  $ {' '.join(cmd)}")
    with log_path.open("w", encoding="utf-8") as log:
        result = subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, env=env)
    if result.returncode != 0:
        print(f"  prism-v2sc conversion failed (see {log_path})")
        return False
    return True


def write_stimulus(fixture: Fixture, path: Path) -> None:
    rng = random.Random(fixture.seed)
    masks = [(1 << port.width) - 1 for port in fixture.inputs]
    lines: list[str] = []
    for _ in range(fixture.cycles):
        values = [rng.randint(0, mask) for mask in masks]
        lines.append(" ".join(str(value) for value in values))
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def render_verilog_tb(fixture: Fixture, stim_path: Path, out_path: Path) -> str:
    inputs = fixture.inputs
    outputs = fixture.outputs

    lines: list[str] = []
    lines.append("`timescale 1ns/1ps")
    lines.append("module tb;")

    if fixture.sequential:
        lines.append("  reg clk;")
        lines.append(f"  reg {fixture.reset};")
    for port in inputs:
        if port.width == 1:
            lines.append(f"  reg {port.name};")
        else:
            lines.append(f"  reg [{port.width - 1}:0] {port.name};")
    for port in outputs:
        if port.width == 1:
            lines.append(f"  wire {port.name};")
        else:
            lines.append(f"  wire [{port.width - 1}:0] {port.name};")
    for i, _port in enumerate(inputs):
        lines.append(f"  reg [31:0] _stim_{i};")
    lines.append("  integer stim_fd;")
    lines.append("  integer out_fd;")
    lines.append("  integer _r;")
    lines.append("")

    bindings: list[str] = []
    if fixture.sequential:
        bindings.append(f".{fixture.clock}(clk)")
        bindings.append(f".{fixture.reset}({fixture.reset})")
    for port in inputs:
        bindings.append(f".{port.name}({port.name})")
    for port in outputs:
        bindings.append(f".{port.name}({port.name})")
    lines.append(f"  {fixture.top} dut (")
    for i, binding in enumerate(bindings):
        suffix = "," if i < len(bindings) - 1 else ""
        lines.append(f"    {binding}{suffix}")
    lines.append("  );")
    lines.append("")

    if fixture.sequential:
        lines.append("  initial begin")
        lines.append("    clk = 1'b0;")
        lines.append("    forever #5 clk = ~clk;")
        lines.append("  end")
        lines.append("")

    lines.append("  initial begin")
    lines.append(f"    stim_fd = $fopen(\"{stim_path.name}\", \"r\");")
    lines.append(f"    out_fd = $fopen(\"{out_path.name}\", \"w\");")
    lines.append("    if (stim_fd == 0) begin")
    lines.append("      $display(\"failed to open stimulus file\");")
    lines.append("      $finish(1);")
    lines.append("    end")
    lines.append("    if (out_fd == 0) begin")
    lines.append("      $display(\"failed to open output file\");")
    lines.append("      $finish(1);")
    lines.append("    end")

    if fixture.sequential:
        reset_value = "1'b0" if fixture.reset_active_low else "1'b1"
        lines.append(f"    {fixture.reset} = {reset_value};")
    for port in inputs:
        if port.width == 1:
            lines.append(f"    {port.name} = 1'b0;")
        else:
            lines.append(f"    {port.name} = {port.width}'h0;")

    if fixture.sequential:
        for _ in range(fixture.reset_cycles):
            lines.append("    @(posedge clk);")
        deasserted = "1'b1" if fixture.reset_active_low else "1'b0"
        lines.append(f"    {fixture.reset} = {deasserted};")

    scan_fmt = " ".join("%d" for _ in inputs)
    scan_args = ", ".join(f"_stim_{i}" for i in range(len(inputs)))

    lines.append("    begin: stim_loop")
    lines.append("      while (1) begin")
    lines.append(f"        _r = $fscanf(stim_fd, \"{scan_fmt}\\n\", {scan_args});")
    lines.append(f"        if (_r != {len(inputs)}) disable stim_loop;")
    if fixture.sequential:
        lines.append("        @(negedge clk);")
    for i, port in enumerate(inputs):
        if port.width == 1:
            lines.append(f"        {port.name} = _stim_{i}[0];")
        else:
            lines.append(f"        {port.name} = _stim_{i}[{port.width - 1}:0];")
    if fixture.sequential:
        lines.append("        @(posedge clk);")
        lines.append("        #1;")
    else:
        lines.append("        #1;")
    out_fmt = " ".join("%0d" for _ in outputs)
    out_args = ", ".join(port.name for port in outputs)
    lines.append(f"        $fwrite(out_fd, \"{out_fmt}\\n\", {out_args});")
    lines.append("      end")
    lines.append("    end")
    lines.append("    $fclose(stim_fd);")
    lines.append("    $fclose(out_fd);")
    lines.append("    $finish(0);")
    lines.append("  end")
    lines.append("endmodule")
    return "\n".join(lines) + "\n"


def render_systemc_tb(
    fixture: Fixture,
    stim_path: Path,
    out_path: Path,
    header_path: Path,
    include_root: Path,
) -> str:
    inputs = fixture.inputs
    outputs = fixture.outputs

    try:
        include_rel = header_path.resolve().relative_to(include_root.resolve())
        include_directive = str(include_rel).replace(os.sep, "/")
    except ValueError:
        include_directive = header_path.name

    lines: list[str] = []
    lines.append("#include <fstream>")
    lines.append("#include <iostream>")
    lines.append("#include <string>")
    lines.append(f'#include "{include_directive}"')
    lines.append("")
    lines.append("int sc_main(int argc, char* argv[]) {")
    lines.append("  (void)argc; (void)argv;")

    if fixture.sequential:
        lines.append("  sc_clock clk(\"clk\", 10, SC_NS, 0.5, 0, SC_NS, false);")
        lines.append(f"  sc_signal<bool> {fixture.reset};")
    for port in inputs:
        lines.append(f"  sc_signal<{port.sc_type}> {port.name};")
    for port in outputs:
        lines.append(f"  sc_signal<{port.sc_type}> {port.name};")
    lines.append("")

    sc_top = fixture.top
    if fixture.sc_template_args:
        sc_top = f"{sc_top}<{', '.join(fixture.sc_template_args)}>"
    elif _header_top_is_templated(header_path, fixture.top):
        sc_top = f"{sc_top}<>"
    lines.append(f"  {sc_top} dut(\"dut\");")
    if fixture.sequential:
        lines.append(f"  dut.{fixture.clock}(clk);")
        lines.append(f"  dut.{fixture.reset}({fixture.reset});")
    for port in inputs:
        lines.append(f"  dut.{port.name}({port.name});")
    for port in outputs:
        lines.append(f"  dut.{port.name}({port.name});")
    lines.append("")

    lines.append(f"  std::ifstream stim(\"{stim_path.name}\");")
    lines.append(f"  std::ofstream out(\"{out_path.name}\");")
    lines.append("  if (!stim) { std::cerr << \"failed to open stimulus\\n\"; return 1; }")
    lines.append("  if (!out)  { std::cerr << \"failed to open output\\n\";   return 1; }")
    lines.append("")

    if fixture.sequential:
        reset_value = "false" if fixture.reset_active_low else "true"
        lines.append(f"  {fixture.reset}.write({reset_value});")
    for port in inputs:
        if port.is_bool:
            lines.append(f"  {port.name}.write(false);")
        else:
            lines.append(f"  {port.name}.write({port.sc_type}(0));")
    lines.append("")

    if fixture.sequential:
        lines.append(f"  sc_start({10 * fixture.reset_cycles}, SC_NS);")
        deasserted = "true" if fixture.reset_active_low else "false"
        lines.append(f"  {fixture.reset}.write({deasserted});")
    else:
        lines.append("  sc_start(1, SC_NS);")
    lines.append("")

    var_names = [f"v{i}" for i in range(len(inputs))]
    lines.append("  long " + ", ".join(var_names) + ";")
    extract = "".join(f" >> {name}" for name in var_names)
    lines.append(f"  while (stim{extract}) {{")
    for i, port in enumerate(inputs):
        if port.is_bool:
            lines.append(f"    {port.name}.write({var_names[i]} != 0);")
        else:
            lines.append(f"    {port.name}.write({port.sc_type}({var_names[i]}));")
    if fixture.sequential:
        lines.append("    sc_start(10, SC_NS);")
    else:
        lines.append("    sc_start(1, SC_NS);")

    out_parts: list[str] = []
    for port in outputs:
        if port.is_bool:
            out_parts.append(f"(int){port.name}.read()")
        else:
            out_parts.append(f"{port.name}.read().to_uint64()")
    if len(out_parts) == 1:
        out_expr = out_parts[0]
    else:
        out_expr = (" << ' ' << ").join(out_parts)
    lines.append(f"    out << {out_expr} << '\\n';")
    lines.append("  }")
    lines.append("")
    lines.append("  sc_stop();")
    lines.append("  return 0;")
    lines.append("}")
    return "\n".join(lines) + "\n"


def diff_traces(rtl: list[str], sc: list[str], work: Path, shift: int) -> int:
    rtl_stripped = [line.strip() for line in rtl if line.strip() != ""]
    sc_stripped = [line.strip() for line in sc if line.strip() != ""]
    if shift > 0:
        sc_stripped = sc_stripped[shift:]
    n = min(len(rtl_stripped), len(sc_stripped))
    mismatches: list[tuple[int, str, str]] = []
    for i in range(n):
        if rtl_stripped[i] != sc_stripped[i]:
            mismatches.append((i, rtl_stripped[i], sc_stripped[i]))
    if len(rtl_stripped) != len(sc_stripped):
        print(f"  NOTE: trace length differs (rtl={len(rtl_stripped)} sc={len(sc_stripped)})")
    if mismatches:
        log_path = work / "diff.log"
        with log_path.open("w", encoding="utf-8") as log:
            for idx, r, s in mismatches:
                log.write(f"cycle {idx}: rtl={r!r} sc={s!r}\n")
        print(f"  MISMATCH: {len(mismatches)} of {n} cycle(s) differ (see {log_path})")
        for idx, r, s in mismatches[:5]:
            print(f"    cycle {idx}: rtl={r!r} sc={s!r}")
        return 1
    if n == 0:
        print("  ERROR: no cycles to compare")
        return 1
    print(f"  PASS: {n} cycle(s) match")
    return 0


def run_logged(cmd: list[str], log_path: Path, *, cwd: Path | None = None) -> int:
    print(f"  $ {' '.join(cmd)}")
    with log_path.open("w", encoding="utf-8") as log:
        result = subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, cwd=cwd)
    return result.returncode


def _locate_top_header(sc_out_dir: Path, top: str) -> Path | None:
    """Find the per-module hpp for ``top`` somewhere under ``sc_out_dir``."""
    candidate = sc_out_dir / f"{top}.hpp"
    if candidate.is_file():
        return candidate
    matches = sorted(sc_out_dir.rglob(f"{top}.hpp"))
    return matches[0] if matches else None


def _header_top_is_templated(header_path: Path, top: str) -> bool:
    """Return True when the generated SystemC header declares ``top`` as a template."""
    if not header_path.is_file():
        return False
    text = header_path.read_text(encoding="utf-8", errors="ignore")
    pattern = re.compile(
        rf"template\s*<[^>]*>\s*\n\s*SC_MODULE\(\s*{re.escape(top)}\s*\)",
        re.MULTILINE,
    )
    return bool(pattern.search(text))


if __name__ == "__main__":
    sys.exit(main())
