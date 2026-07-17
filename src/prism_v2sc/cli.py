"""Command-line interface for prism_v2sc."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Sequence

from .frontend.flow import compute_source_root
from .frontend.preprocess import collect_sources
from .models.manifest import ModelManifest, load_model_manifest
from . import __version__
from .power.cli import (
    add_power_arguments,
    handle_power_commands,
    run_power_profile_from_dump,
    run_power_report,
)
from .verify.harness import convert_with_metrics, write_report
from .verify.conversion_audit import build_conversion_audit
from .verify.diagnostic_policy import (
    DiagnosticPolicy,
    failing_diagnostics,
    load_diagnostic_policy,
)


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
        "--no-ir",
        action="store_true",
        help="Do not serialize ir.json (useful for very large designs).",
    )
    parser.add_argument(
        "--incremental-codegen",
        action="store_true",
        help="Reuse unchanged per-module SystemC files using a content fingerprint cache.",
    )
    parser.add_argument(
        "--compile-friendly",
        action="store_true",
        help="Emit a shared SystemC prelude and outline non-template module methods into .cpp files.",
    )
    parser.add_argument(
        "--reuse-generated-module",
        action="append",
        default=[],
        metavar="MODULE",
        help="Trust and reuse an existing generated module without rendering it (repeatable).",
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
        "--diagnostic-policy",
        type=Path,
        help="Version 1 JSON policy controlling allowed and fatal diagnostic codes.",
    )
    parser.add_argument(
        "--conversion-audit",
        type=Path,
        help="Write a machine-readable conversion coverage and diagnostics audit report.",
    )
    parser.add_argument(
        "--model-manifest",
        type=Path,
        help="JSON/TOML external-model manifest for source filtering and provider replacement.",
    )
    parser.add_argument(
        "--model-audit",
        action="store_true",
        help="Classify input sources and write model_report.json even without replacement rules.",
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
        and not args.power_profile_dump
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

    profile_dump_only = (
        args.power_profile_dump
        and not args.power_report
        and not args.power_static
        and args.power_instrument is None
        and not args.sources
        and not args.filelist
    )
    if profile_dump_only:
        try:
            run_power_profile_from_dump(
                args.power_profile_dump,
                args.power_profile_output,
                workload_name=args.power_workload_name,
                cycle_count=args.power_workload_cycles,
                top_module=args.power_profile_top or args.top or "unknown",
                sources=tuple(args.power_profile_source),
                vector_file=args.power_vector_file,
                seed=args.power_seed,
                reset_cycles=args.power_reset_cycles,
            )
        except FileNotFoundError as exc:
            parser.error(str(exc))
        return 0

    if not args.sources and not args.filelist:
        parser.error("at least one Verilog source file or --filelist is required")

    if args.top is None:
        parser.error("--top is required")

    try:
        source_set = collect_sources(args.sources, args.filelist)
    except (FileNotFoundError, ValueError) as exc:
        parser.error(str(exc))

    model_manifest: ModelManifest | None = None
    if args.model_manifest is not None:
        try:
            model_manifest = load_model_manifest(args.model_manifest)
        except (FileNotFoundError, ValueError, json.JSONDecodeError) as exc:
            parser.error(str(exc))
    elif args.model_audit:
        model_manifest = ModelManifest()

    diagnostic_policy = DiagnosticPolicy()
    if args.diagnostic_policy is not None:
        try:
            diagnostic_policy = load_diagnostic_policy(args.diagnostic_policy)
        except (FileNotFoundError, ValueError, json.JSONDecodeError) as exc:
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
        model_manifest=model_manifest,
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
        model_manifest=model_manifest,
        track_memory=args.metrics or args.compare_verilator,
        incremental_codegen=args.incremental_codegen or bool(args.reuse_generated_module),
        reuse_existing_modules=tuple(args.reuse_generated_module),
        compile_friendly=args.compile_friendly,
    )
    design = artifacts.design
    if args.dump_ir:
        payload = json.dumps(design.to_dict(), indent=2, sort_keys=True)
        print(payload)
        return 0

    if not args.no_ir:
        payload = json.dumps(design.to_dict(), indent=2, sort_keys=True)
        ir_path = args.out / "ir.json"
        ir_path.write_text(payload + "\n", encoding="utf-8")
        print(f"wrote Phase 1 IR: {ir_path}")
    for emitted in artifacts.emitted_files:
        print(f"wrote SystemC module: {emitted}")
    if args.incremental_codegen or args.reuse_generated_module:
        print(
            "codegen cache: "
            f"rendered={artifacts.report.codegen_rendered_count}, "
            f"reused={artifacts.report.codegen_reused_count}, "
            f"bootstrapped={artifacts.report.codegen_bootstrapped_count}"
        )

    if artifacts.model_report is not None:
        model_report_path = args.out / "model_report.json"
        model_report_path.write_text(
            json.dumps(artifacts.model_report.to_dict(), indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        print(f"wrote model resolution report: {model_report_path}")

    policy_failures = failing_diagnostics(design.diagnostics, diagnostic_policy)
    if args.conversion_audit is not None:
        audit = build_conversion_audit(
            design,
            source_set.sources,
            emitted_files=artifacts.emitted_files,
            model_report=artifacts.model_report,
            policy_path=diagnostic_policy.path,
            policy_failures=policy_failures,
        )
        args.conversion_audit.parent.mkdir(parents=True, exist_ok=True)
        args.conversion_audit.write_text(
            json.dumps(audit.to_dict(), indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        print(f"wrote conversion audit: {args.conversion_audit}")

    if args.metrics or args.compare_verilator:
        metrics_path = args.out / "metrics.json"
        write_report(artifacts.report, metrics_path)
        print(f"wrote Phase 5 metrics: {metrics_path}")

    if design.diagnostics:
        error_count = sum(1 for diagnostic in design.diagnostics if diagnostic.severity == "error")
        warning_count = len(design.diagnostics) - error_count
        print(f"diagnostics: {error_count} error(s), {warning_count} warning(s)")
        if args.diagnostic_policy is not None and policy_failures:
            return 2
        if args.fail_on_diagnostics and error_count:
            return 2
    return 0
