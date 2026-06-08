"""Power analysis command-line interface."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

from prism_v2sc.frontend.flow import lower_design_top_down
from prism_v2sc.analysis.power_static import analyze_static_power, PowerThresholds
from prism_v2sc.analysis.probe_planning import create_probe_plan, ProbePlanPolicy
from prism_v2sc.codegen.instrumentation import InstrumentationConfig, generate_manifest_json
from prism_v2sc.codegen.systemc import emit_systemc_files
from prism_v2sc.frontend.flow import compute_source_root
from prism_v2sc.power.schemas import export_power_static_json


def run_power_static(
    sources: list[Path],
    top: str,
    output_path: Path | None = None,
    thresholds: PowerThresholds | None = None,
    *,
    include_dirs: list[Path] | tuple[Path, ...] = (),
    defines: list[str] | tuple[str, ...] = (),
) -> dict[str, Any]:
    """Run static power analysis and generate power_static.json.

    Args:
        sources: List of RTL source files
        top: Top module name
        output_path: Output file path (default: power_static.json)
        thresholds: Optional custom thresholds

    Returns:
        Dictionary with analysis results
    """
    if output_path is None:
        output_path = Path("power_static.json")

    # Convert design to IR
    print(f"Converting design (top={top})...", file=sys.stderr)
    artifacts = lower_design_top_down(
        sources=sources,
        top=top,
        include_dirs=include_dirs,
        defines=defines,
    )
    design = artifacts.design

    # Run static analysis on all modules
    all_suspects = []
    for module in design.modules:
        print(f"Analyzing module: {module.name}", file=sys.stderr)
        suspects = analyze_static_power(module, thresholds)
        all_suspects.extend(suspects)

    print(f"Found {len(all_suspects)} potential power issues", file=sys.stderr)

    # Export to JSON
    result = export_power_static_json(all_suspects, design.top)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2)

    print(f"Static analysis written to: {output_path}", file=sys.stderr)

    return result


def run_power_instrument(
    sources: list[Path],
    top: str,
    manifest_path: Path,
    output_dir: Path,
    policy: ProbePlanPolicy | None = None,
    *,
    include_dirs: list[Path] | tuple[Path, ...] = (),
    defines: list[str] | tuple[str, ...] = (),
    deep_profile: bool = False,
) -> dict[str, Any]:
    """Generate instrumented SystemC with probe manifest.

    Args:
        sources: List of RTL source files
        top: Top module name
        manifest_path: Path to save probe manifest
        output_dir: Output directory for SystemC
        policy: Probe selection policy
    """
    if policy is None:
        policy = ProbePlanPolicy()

    # Convert design to IR
    print(f"Converting design (top={top})...", file=sys.stderr)
    artifacts = lower_design_top_down(
        sources=sources,
        top=top,
        include_dirs=include_dirs,
        defines=defines,
    )
    design = artifacts.design

    # Create probe plan
    print("Creating probe plan...", file=sys.stderr)
    probe_plan = create_probe_plan(design, policy)

    print(f"Probe plan: {probe_plan.probe_count} signals ({probe_plan.state_probe_count} state, {probe_plan.comb_probe_count} comb)", file=sys.stderr)

    instrumentation_config = InstrumentationConfig(
        enabled=True,
        probe_plan=probe_plan,
        track_high_cycles=deep_profile,
        per_bit_counters=deep_profile,
    )

    # Export probe plan manifest
    from prism_v2sc.analysis.probe_planning import export_probe_plan_json

    manifest = export_probe_plan_json(probe_plan)
    manifest["instrumentation"] = generate_manifest_json(instrumentation_config)
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2)

    print(f"Probe manifest written to: {manifest_path}", file=sys.stderr)

    output_dir.mkdir(parents=True, exist_ok=True)
    source_root = compute_source_root(sources)
    written = emit_systemc_files(
        design,
        output_dir,
        source_root,
        signatures=artifacts.signatures,
        instrumentation_config=instrumentation_config,
    )

    print(f"Instrumented SystemC written to: {output_dir}", file=sys.stderr)
    for path in written:
        print(f"  {path}", file=sys.stderr)

    return {
        "manifest": manifest,
        "written_files": [str(path) for path in written],
        "probe_count": probe_plan.probe_count,
        "warnings": list(probe_plan.warnings),
    }


def run_power_report(
    profile_path: Path,
    static_path: Path | None = None,
    output_path: Path | None = None,
    top_k: int = 50,
) -> dict[str, Any]:
    """Generate power report from profile data.

    Args:
        profile_path: Path to power_profile.json
        static_path: Optional path to power_static.json
        output_path: Output file path (default: power_report.json)
        top_k: Number of top hotspots to include

    Returns:
        Dictionary with report data
    """
    if output_path is None:
        output_path = Path("power_report.json")

    # Use P7 scoring module
    from prism_v2sc.power.scoring import generate_power_report

    print(f"Loading profile data from: {profile_path}", file=sys.stderr)

    if static_path and static_path.exists():
        print(f"Loading static analysis from: {static_path}", file=sys.stderr)

    report = generate_power_report(static_path, profile_path, output_path, top_k)

    print(f"Power report written to: {output_path}", file=sys.stderr)
    print(f"Top {len(report['hotspots'])} hotspots identified", file=sys.stderr)

    return report


def add_power_arguments(parser: Any) -> None:
    """Add power analysis arguments to argument parser.

    Args:
        parser: argparse.ArgumentParser instance
    """
    power_group = parser.add_argument_group('power analysis')

    power_group.add_argument(
        '--power-static',
        action='store_true',
        help='Run static power analysis and output power_static.json'
    )

    power_group.add_argument(
        '--power-static-output',
        type=Path,
        default=Path('power_static.json'),
        metavar='FILE',
        help='Output path for static analysis (default: power_static.json)'
    )

    power_group.add_argument(
        '--power-instrument',
        type=Path,
        metavar='MANIFEST',
        help='Generate instrumented SystemC with probe manifest at MANIFEST'
    )

    power_group.add_argument(
        '--power-report',
        type=Path,
        metavar='PROFILE',
        help='Generate power report from profile data at PROFILE'
    )

    power_group.add_argument(
        '--power-report-output',
        type=Path,
        default=Path('power_report.json'),
        metavar='FILE',
        help='Output path for power report (default: power_report.json)'
    )

    power_group.add_argument(
        '--power-report-static',
        type=Path,
        metavar='FILE',
        help='Static analysis JSON to join into --power-report'
    )

    power_group.add_argument(
        '--power-all-signals',
        action='store_true',
        help='Probe all eligible signals instead of only state plus comb suspects'
    )

    power_group.add_argument(
        '--power-probe-ports',
        action='store_true',
        help='Include module ports in probe plans'
    )

    power_group.add_argument(
        '--power-memory-cells',
        action='store_true',
        help='Include capped per-cell probes for unpacked-array memories'
    )

    power_group.add_argument(
        '--power-deep-profile',
        action='store_true',
        help='Enable per-bit and T1-style counters for instrumented probes'
    )


def handle_power_commands(
    args: Any,
    sources: list[Path],
    top: str,
    *,
    include_dirs: list[Path] | tuple[Path, ...] = (),
    defines: list[str] | tuple[str, ...] = (),
    out_dir: Path | None = None,
) -> bool:
    """Handle power analysis commands from parsed arguments.

    Args:
        args: Parsed command-line arguments
        sources: List of source files
        top: Top module name

    Returns:
        True if a power command was handled, False otherwise
    """
    handled = False

    if args.power_static:
        run_power_static(
            sources,
            top,
            args.power_static_output,
            include_dirs=include_dirs,
            defines=defines,
        )
        handled = True

    if args.power_instrument:
        output_dir = out_dir if out_dir is not None else Path('build') / 'systemc_instrumented'
        policy = ProbePlanPolicy(
            probe_comb_suspects_only=not args.power_all_signals,
            probe_ports=args.power_probe_ports,
            probe_memory_cells=args.power_memory_cells,
        )
        run_power_instrument(
            sources,
            top,
            args.power_instrument,
            output_dir,
            policy,
            include_dirs=include_dirs,
            defines=defines,
            deep_profile=args.power_deep_profile,
        )
        handled = True

    if args.power_report:
        static_path = args.power_report_static
        if static_path is None:
            static_path = Path('power_static.json') if Path('power_static.json').exists() else None
        run_power_report(args.power_report, static_path, args.power_report_output)
        handled = True

    return handled
