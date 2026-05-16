"""Command-line interface for prism_v2sc."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Sequence

from . import __version__
from .verify.harness import convert_with_metrics, write_report


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="prism-v2sc",
        description="Convert hierarchical Verilog designs into approximate SystemC models.",
    )
    parser.add_argument(
        "sources",
        nargs="*",
        type=Path,
        help="Input Verilog source files.",
    )
    parser.add_argument(
        "--top",
        help="Top-level Verilog module name.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=Path("build/systemc"),
        help="Output directory for generated artifacts.",
    )
    parser.add_argument(
        "--dump-ir",
        action="store_true",
        help="Print the Phase 1 JSON IR to stdout instead of writing ir.json.",
    )
    parser.add_argument(
        "--metrics",
        action="store_true",
        help="Write Phase 5 conversion metrics to metrics.json.",
    )
    parser.add_argument(
        "--compare-verilator",
        action="store_true",
        help="Run best-effort Verilator --lint-only timing for the same sources.",
    )
    parser.add_argument(
        "--fail-on-diagnostics",
        action="store_true",
        help="Exit non-zero when error-level unsupported construct diagnostics are found.",
    )
    parser.add_argument(
        "--version",
        action="version",
        version=f"%(prog)s {__version__}",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if not args.sources:
        parser.error("at least one Verilog source file is required")

    missing_sources = [source for source in args.sources if not source.is_file()]
    if missing_sources:
        formatted = ", ".join(str(source) for source in missing_sources)
        parser.error(f"source file(s) not found: {formatted}")

    if args.top is None:
        parser.error("--top is required")

    args.out.mkdir(parents=True, exist_ok=True)

    artifacts = convert_with_metrics(
        args.sources,
        args.top,
        compare_verilator=args.compare_verilator,
    )
    design = artifacts.design
    payload = json.dumps(design.to_dict(), indent=2, sort_keys=True)

    if args.dump_ir:
        print(payload)
        return 0

    ir_path = args.out / "ir.json"
    ir_path.write_text(payload + "\n", encoding="utf-8")
    header_path = args.out / "prism_v2sc.hpp"
    header_path.write_text(artifacts.header, encoding="utf-8")
    print(f"wrote Phase 1 IR: {ir_path}")
    print(f"wrote SystemC header: {header_path}")

    if args.metrics or args.compare_verilator:
        metrics_path = args.out / "metrics.json"
        write_report(artifacts.report, metrics_path)
        print(f"wrote Phase 5 metrics: {metrics_path}")

    if design.diagnostics:
        error_count = sum(1 for diagnostic in design.diagnostics if diagnostic.severity == "error")
        warning_count = len(design.diagnostics) - error_count
        print(f"diagnostics: {error_count} error(s), {warning_count} warning(s)")
        if args.fail_on_diagnostics and error_count:
            return 2
    return 0
