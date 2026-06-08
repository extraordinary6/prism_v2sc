"""Power analysis package.

This package provides power analysis capabilities for prism_v2sc:
- Static power analysis (zero-simulation)
- Probe planning for dynamic profiling
- SystemC instrumentation
- Profile data collection
- Power hotspot reporting
"""

from prism_v2sc.power.schemas import (
    POWER_STATIC_SCHEMA,
    POWER_PROFILE_SCHEMA,
    POWER_REPORT_SCHEMA,
    export_power_static_json,
    export_power_profile_json,
    export_power_report_json,
)

from prism_v2sc.power.cli import (
    run_power_static,
    run_power_instrument,
    run_power_report,
    add_power_arguments,
    handle_power_commands,
)

from prism_v2sc.power.runner import (
    WorkloadMetadata,
    create_systemc_runner,
    run_systemc_simulation,
    parse_power_dump,
    create_power_profile_json,
    collect_profile,
    aggregate_memory_activity,
)

from prism_v2sc.power.scoring import (
    PowerHotspot,
    calculate_activity_rate,
    calculate_toggle_density,
    score_signal,
    combine_static_and_dynamic,
    generate_recommendation,
    generate_power_report,
    calculate_probe_metrics,
    calculate_bit_utilization,
    classify_score_dimensions,
    select_deep_profile_targets,
    generate_workload_comparison_report,
    export_saif_like,
)

__all__ = [
    # Schemas
    "POWER_STATIC_SCHEMA",
    "POWER_PROFILE_SCHEMA",
    "POWER_REPORT_SCHEMA",
    "export_power_static_json",
    "export_power_profile_json",
    "export_power_report_json",
    # CLI
    "run_power_static",
    "run_power_instrument",
    "run_power_report",
    "add_power_arguments",
    "handle_power_commands",
    # Runner (P6)
    "WorkloadMetadata",
    "create_systemc_runner",
    "run_systemc_simulation",
    "parse_power_dump",
    "create_power_profile_json",
    "collect_profile",
    "aggregate_memory_activity",
    # Scoring (P7)
    "PowerHotspot",
    "calculate_activity_rate",
    "calculate_toggle_density",
    "score_signal",
    "combine_static_and_dynamic",
    "generate_recommendation",
    "generate_power_report",
    "calculate_probe_metrics",
    "calculate_bit_utilization",
    "classify_score_dimensions",
    "select_deep_profile_targets",
    "generate_workload_comparison_report",
    "export_saif_like",
]
