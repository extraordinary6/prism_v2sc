"""Command-line interface for prism_v2sc."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Sequence

from .frontend.flow import compute_source_root
from .frontend.preprocess import collect_sources
from . import __version__
from .power.cli import add_power_arguments, handle_power_commands, run_power_report
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
        "--filelist",
        action="append",
        default=[],
        type=Path,
        help="Path to .f-style filelist (can be specified multiple times).",
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
    add_power_arguments(parser)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    report_only = (
        args.power_report
        and not args.power_static
        and args.power_instrument is None
        and not args.sources
        and not args.filelist
    )
    if report_only:
        static_path = args.power_report_static
        if static_path is None:
            default_static = Path("power_static.json")
            static_path = default_static if default_static.exists() else None
        run_power_report(args.power_report, static_path, args.power_report_output)
        return 0

    if not args.sources and not args.filelist:
        parser.error("at least one Verilog source file or --filelist is required")

    if args.top is None:
        parser.error("--top is required")

    try:
        source_set = collect_sources(args.sources, args.filelist)
    except (FileNotFoundError, ValueError) as exc:
        parser.error(str(exc))

    if not source_set.sources:
        parser.error("no Verilog source files resolved from positional inputs and filelists")

    if handle_power_commands(
        args,
        list(source_set.sources),
        args.top,
        include_dirs=source_set.include_dirs,
        defines=source_set.defines,
        out_dir=args.out,
    ):
        return 0

    args.out.mkdir(parents=True, exist_ok=True)

    source_root = compute_source_root(source_set.sources)
    artifacts = convert_with_metrics(
        source_set.sources,
        args.top,
        include_dirs=source_set.include_dirs,
        defines=source_set.defines,
        compare_verilator=args.compare_verilator,
        out_dir=args.out,
        source_root=source_root,
    )
    design = artifacts.design
    payload = json.dumps(design.to_dict(), indent=2, sort_keys=True)

    if args.dump_ir:
        print(payload)
        return 0

    ir_path = args.out / "ir.json"
    ir_path.write_text(payload + "\n", encoding="utf-8")
    print(f"wrote Phase 1 IR: {ir_path}")
    for emitted in artifacts.emitted_files:
        print(f"wrote SystemC module: {emitted}")

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
