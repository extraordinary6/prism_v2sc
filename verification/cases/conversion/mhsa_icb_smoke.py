#!/usr/bin/env python3
"""Real-design conversion smoke for the external ICB MHSA accelerator.

This script intentionally references the RTL in-place under ``--mhsa-root``.
It does not copy or modify the external design.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


DEFAULT_MHSA_ROOT = Path("/home/MicroE/MHSA")
DEFAULT_OUT = Path("/tmp/prism_mhsa_icb_smoke")
DEFAULT_SYSTEMC_INCLUDE = Path("/usr/local/systemc-2.3.4/include")


def _sources(root: Path) -> list[Path]:
    return [
        root / "icb_mhsa" / "icb_mhsa.sv",
        root / "icb_mhsa" / "imu.sv",
        *sorted((root / "rtl_design").glob("*.sv")),
    ]


def _run(cmd: list[str], *, cwd: Path) -> None:
    print("+ " + " ".join(cmd), flush=True)
    subprocess.run(cmd, cwd=cwd, check=True)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mhsa-root", type=Path, default=DEFAULT_MHSA_ROOT)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--systemc-include", type=Path, default=DEFAULT_SYSTEMC_INCLUDE)
    parser.add_argument("--cxx", default="g++")
    parser.add_argument("--keep-out", action="store_true")
    args = parser.parse_args(argv)

    repo_root = Path(__file__).resolve().parents[3]
    mhsa_root = args.mhsa_root.expanduser().resolve()
    out_dir = args.out.expanduser().resolve()
    sources = _sources(mhsa_root)
    missing = [path for path in sources if not path.exists()]
    if missing:
        for path in missing:
            print(f"missing source: {path}", file=sys.stderr)
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
        "icb_mhsa",
        "--out",
        str(out_dir),
        "--metrics",
        "--fail-on-diagnostics",
        *[str(path) for path in sources],
    ]
    _run(convert_cmd, cwd=repo_root)

    top_header = out_dir / "icb_mhsa" / "icb_mhsa.hpp"
    compile_cmd = [
        args.cxx,
        "-std=c++14",
        f"-I{args.systemc_include}",
        f"-I{out_dir / 'icb_mhsa'}",
        f"-I{out_dir / 'rtl_design'}",
        "-x",
        "c++",
        "-c",
        str(top_header),
        "-o",
        str(out_dir / "icb_mhsa.o"),
    ]
    _run(compile_cmd, cwd=repo_root)

    print(f"MHSA ICB smoke passed: {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
