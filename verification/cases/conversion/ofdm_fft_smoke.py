#!/usr/bin/env python3
"""Real-design conversion smoke for the external OFDM FFT/IFFT RTL.

This script references the RTL in-place under ``--rtl-root``. It does not copy
or modify the external design.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from collections import Counter
from pathlib import Path

from prism_v2sc.verify.static_checks import check_generated_systemc


DEFAULT_RTL_ROOT = Path(
    "/home/MicroE/ai_proj/Simulation-and-FFT-Implementation-of-OFDM-Communication-System/hardware/src"
)
DEFAULT_OUT = Path("/tmp/prism_ofdm_fft_smoke")
DEFAULT_SYSTEMC_INCLUDE = Path("/usr/local/systemc-2.3.4/include")


def _run(cmd: list[str], *, cwd: Path) -> None:
    print("+ " + " ".join(cmd), flush=True)
    subprocess.run(cmd, cwd=cwd, check=True)


def _diagnostic_counts(ir_path: Path) -> Counter[str]:
    payload = json.loads(ir_path.read_text(encoding="utf-8"))
    return Counter(diag.get("code", "<missing>") for diag in payload.get("diagnostics", ()))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rtl-root", type=Path, default=DEFAULT_RTL_ROOT)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--systemc-include", type=Path, default=DEFAULT_SYSTEMC_INCLUDE)
    parser.add_argument("--cxx", default="g++")
    parser.add_argument("--keep-out", action="store_true")
    args = parser.parse_args(argv)

    repo_root = Path(__file__).resolve().parents[3]
    rtl_root = args.rtl_root.expanduser().resolve()
    out_dir = args.out.expanduser().resolve()
    source = rtl_root / "fft_ifft_top.v"
    if not source.exists():
        print(f"missing source: {source}", file=sys.stderr)
        return 2
    if not args.systemc_include.exists():
        print(f"missing SystemC include dir: {args.systemc_include}", file=sys.stderr)
        return 2

    if out_dir.exists() and not args.keep_out:
        shutil.rmtree(out_dir)

    convert_cmd = [
        sys.executable,
        "-m",
        "prism_v2sc",
        "--top",
        "fft_ifft_top",
        "--out",
        str(out_dir),
        "--metrics",
        "--fail-on-diagnostics",
        str(source),
    ]
    _run(convert_cmd, cwd=repo_root)

    top_header = out_dir / "fft_ifft_top.hpp"
    header_text = top_header.read_text(encoding="utf-8")
    issues = check_generated_systemc(header_text)
    if issues:
        for issue in issues:
            print(f"{issue.severity}: {issue.code}: {issue.message}", file=sys.stderr)
        return 1
    if "raw: 0." in header_text:
        print("generated header still contains raw real-literal fallback", file=sys.stderr)
        return 1

    compile_cmd = [
        args.cxx,
        "-std=c++14",
        f"-I{args.systemc_include}",
        "-x",
        "c++",
        "-c",
        str(top_header),
        "-o",
        str(out_dir / "fft_ifft_top.o"),
    ]
    _run(compile_cmd, cwd=repo_root)

    counts = _diagnostic_counts(out_dir / "ir.json")
    print("diagnostic warning breakdown:")
    for code, count in counts.most_common():
        print(f"  {count:3d} {code}")
    print(f"OFDM FFT/IFFT smoke passed: {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
