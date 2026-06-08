"""SystemC instrumentation for power profiling.

This module defines the instrumentation configuration and generates
power profiling code for SystemC modules.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Any

from prism_v2sc.analysis.probe_planning import PowerProbePlan, ProbeSpec


@dataclass(frozen=True)
class InstrumentationConfig:
    """Configuration for SystemC power instrumentation."""

    # Enable/disable instrumentation
    enabled: bool = False

    # Probe plan to use
    probe_plan: PowerProbePlan | None = None

    # Counter options
    track_toggles: bool = True          # Track bit toggles
    track_value_changes: bool = True    # Track value changes
    track_samples: bool = True          # Track sample count

    # Advanced options (for future phases)
    track_high_cycles: bool = False     # Track T1/T0 for SAIF-like analysis
    per_bit_counters: bool = False      # Per-bit toggle counters (Phase P8)


@dataclass(frozen=True)
class ProbeInstrumentation:
    """Instrumentation code for a single probe."""

    probe: ProbeSpec

    # Member variable declarations
    prev_value_decl: str        # Previous sampled value
    sample_count_decl: str      # Sample count
    change_count_decl: str      # Value change count
    toggle_count_decl: str      # Bit toggle count

    # Sampling method body
    sampling_code: str          # Code to execute on each sample


@dataclass(frozen=True)
class SamplingProcessSpec:
    """A generated SystemC sampling process."""

    method_name: str
    clock_domain: str | None
    clock_edge: str | None
    body: str


def generate_instrumentation_declarations(config: InstrumentationConfig) -> list[str]:
    """Generate C++ member variable declarations for instrumentation.

    Returns a list of C++ declaration strings to be added to the class.
    """
    if not config.enabled or config.probe_plan is None:
        return []

    declarations = []

    # Add a comment header
    declarations.append("// Power profiling instrumentation")
    declarations.append("")

    for probe in config.probe_plan.probes:
        signal = _counter_suffix(probe)
        width = probe.width

        # Choose appropriate C++ type based on width
        cpp_type = _cpp_value_type(width)

        # Previous value for change detection
        if config.track_value_changes or config.track_toggles:
            declarations.append(f"{cpp_type} __power_prev_{signal};")

        # Counters
        if config.track_samples:
            declarations.append(f"uint64_t __power_sample_count_{signal};")

        if config.track_value_changes:
            declarations.append(f"uint64_t __power_change_count_{signal};")

        if config.track_toggles:
            declarations.append(f"uint64_t __power_toggle_count_{signal};")

        if config.track_high_cycles:
            declarations.append(f"uint64_t __power_high_cycle_count_{signal};")

        if config.per_bit_counters:
            declarations.append(f"uint64_t __power_bit_toggle_count_{signal}[{max(width, 1)}];")

        declarations.append("")

    return declarations


def generate_instrumentation_init(config: InstrumentationConfig) -> list[str]:
    """Generate initialization code for instrumentation counters.

    Returns C++ code to initialize counters (for constructor).
    """
    if not config.enabled or config.probe_plan is None:
        return []

    init_code = []
    init_code.append("// Initialize power profiling counters")

    for probe in config.probe_plan.probes:
        signal = _counter_suffix(probe)
        width = max(probe.width, 1)

        # Initialize previous value to 0
        if config.track_value_changes or config.track_toggles:
            init_code.append(f"__power_prev_{signal} = 0;")

        # Initialize counters to 0
        if config.track_samples:
            init_code.append(f"__power_sample_count_{signal} = 0;")

        if config.track_value_changes:
            init_code.append(f"__power_change_count_{signal} = 0;")

        if config.track_toggles:
            init_code.append(f"__power_toggle_count_{signal} = 0;")

        if config.track_high_cycles:
            init_code.append(f"__power_high_cycle_count_{signal} = 0;")

        if config.per_bit_counters:
            init_code.append(f"for (int __power_i = 0; __power_i < {width}; ++__power_i) {{")
            init_code.append(f"    __power_bit_toggle_count_{signal}[__power_i] = 0;")
            init_code.append("}")

    return init_code


def generate_sampling_method(config: InstrumentationConfig, probe: ProbeSpec) -> str:
    """Generate sampling method for a probe.

    Returns C++ code for the sampling method body.
    """
    signal = _counter_suffix(probe)
    width = max(probe.width, 1)

    lines = []

    # Read current value
    lines.append(f"// Sample {probe.rtl_signal_name}")
    value_expr = _probe_current_value_expr(probe)

    lines.append(f"auto current_value = {value_expr};")

    # Increment sample count
    if config.track_samples:
        lines.append(f"__power_sample_count_{signal}++;")

    if config.track_high_cycles:
        if width == 1:
            lines.append(f"if (current_value) {{ __power_high_cycle_count_{signal}++; }}")
        elif width <= 64:
            lines.append(f"__power_high_cycle_count_{signal} += __builtin_popcountll(current_value);")
        else:
            lines.append("uint64_t __power_high_bits = 0;")
            lines.append(f"for (int __power_i = 0; __power_i < {width}; ++__power_i) {{")
            lines.append("    if (current_value[__power_i]) { __power_high_bits++; }")
            lines.append("}")
            lines.append(f"__power_high_cycle_count_{signal} += __power_high_bits;")

    # Check for value change
    if config.track_value_changes or config.track_toggles:
        lines.append(f"if (current_value != __power_prev_{signal}) {{")

        if config.track_value_changes:
            lines.append(f"    __power_change_count_{signal}++;")

        if config.track_toggles:
            if width == 1:
                lines.append(f"    __power_toggle_count_{signal}++;")
                if config.per_bit_counters:
                    lines.append(f"    __power_bit_toggle_count_{signal}[0]++;")
            elif width <= 64:
                lines.append(f"    auto toggled_bits = current_value ^ __power_prev_{signal};")
                lines.append(f"    __power_toggle_count_{signal} += __builtin_popcountll(toggled_bits);")
                if config.per_bit_counters:
                    lines.append(f"    for (int __power_i = 0; __power_i < {width}; ++__power_i) {{")
                    lines.append("        if ((toggled_bits >> __power_i) & 1ULL) {")
                    lines.append(f"            __power_bit_toggle_count_{signal}[__power_i]++;")
                    lines.append("        }")
                    lines.append("    }")
            else:
                lines.append("    uint64_t __power_toggled_bits = 0;")
                lines.append(f"    for (int __power_i = 0; __power_i < {width}; ++__power_i) {{")
                lines.append(f"        if (current_value[__power_i] != __power_prev_{signal}[__power_i]) {{")
                lines.append("            __power_toggled_bits++;")
                if config.per_bit_counters:
                    lines.append(f"            __power_bit_toggle_count_{signal}[__power_i]++;")
                lines.append("        }")
                lines.append("    }")
                lines.append(f"    __power_toggle_count_{signal} += __power_toggled_bits;")

        lines.append(f"    __power_prev_{signal} = current_value;")
        lines.append("}")

    return "\n".join(lines)


def generate_all_sampling_methods(config: InstrumentationConfig) -> dict[str, str]:
    """Generate all sampling methods grouped by clock domain.

    Returns a dict mapping clock domain to SC_METHOD body code.
    """
    if not config.enabled or config.probe_plan is None:
        return {}

    # Group probes by clock domain and edge.
    by_domain: dict[tuple[str, str | None], list[ProbeSpec]] = {}

    for probe in config.probe_plan.probes:
        domain = probe.clock_domain or "comb"
        key = (domain, probe.clock_edge)
        if key not in by_domain:
            by_domain[key] = []
        by_domain[key].append(probe)

    # Generate method for each domain
    methods = {}

    for (domain, _edge), probes in by_domain.items():
        lines = []
        lines.append(f"// Power sampling for clock domain: {domain}")

        for probe in probes:
            probe_code = generate_sampling_method(config, probe)
            lines.append(probe_code)
            lines.append("")

        methods[domain] = "\n".join(lines)

    return methods


def generate_sampling_processes(config: InstrumentationConfig) -> list[SamplingProcessSpec]:
    """Generate sampling processes with method names and sensitivity metadata."""
    if not config.enabled or config.probe_plan is None:
        return []

    grouped: dict[tuple[str | None, str | None], list[ProbeSpec]] = {}
    for probe in config.probe_plan.probes:
        key = (probe.clock_domain, probe.clock_edge)
        grouped.setdefault(key, []).append(probe)

    processes: list[SamplingProcessSpec] = []
    for index, ((clock_domain, clock_edge), probes) in enumerate(grouped.items()):
        label = _sanitize_identifier(clock_domain or "sample_strobe")
        method_name = f"__power_sample_{label}_{index}"
        lines = [
            f"// Power sampling for {'clock domain ' + clock_domain if clock_domain else 'sample strobe'}"
        ]
        for probe in probes:
            lines.append(generate_sampling_method(config, probe))
            lines.append("")
        processes.append(
            SamplingProcessSpec(
                method_name=method_name,
                clock_domain=clock_domain,
                clock_edge=clock_edge,
                body="\n".join(lines),
            )
        )
    return processes


def generate_dump_api(config: InstrumentationConfig) -> str:
    """Generate power profile dump API.

    Returns C++ code for the dump method.
    """
    if not config.enabled or config.probe_plan is None:
        return ""

    lines = []
    lines.append("void prism_power_dump(std::ostream& os) const {")
    lines.append('    os << "# Power Profile Data\\n";')
    lines.append(
        '    os << "signal,sample_count,change_count,toggle_count,'
        'module,width,signal_class,high_cycle_count,bit_toggle_counts\\n";'
    )

    for probe in config.probe_plan.probes:
        signal = _counter_suffix(probe)

        sample_count = f"__power_sample_count_{signal}" if config.track_samples else "0"
        change_count = f"__power_change_count_{signal}" if config.track_value_changes else "0"
        toggle_count = f"__power_toggle_count_{signal}" if config.track_toggles else "0"
        high_count = f"__power_high_cycle_count_{signal}" if config.track_high_cycles else "0"

        lines.append(f'    os << "{signal}," ')
        lines.append(f'       << {sample_count} << "," ')
        lines.append(f'       << {change_count} << "," ')
        lines.append(f'       << {toggle_count} << "," ')
        lines.append(f'       << "{probe.module_name}," ')
        lines.append(f'       << "{probe.width}," ')
        lines.append(f'       << "{probe.signal_class}," ')
        lines.append(f'       << {high_count} << ",";')
        if config.per_bit_counters:
            lines.append(f"    for (int __power_i = 0; __power_i < {max(probe.width, 1)}; ++__power_i) {{")
            lines.append('        if (__power_i != 0) { os << ";"; }')
            lines.append(f"        os << __power_bit_toggle_count_{signal}[__power_i];")
            lines.append("    }")
        lines.append('    os << "\\n";')

    lines.append("}")

    return "\n".join(lines)


def generate_manifest_json(config: InstrumentationConfig) -> dict[str, Any]:
    """Generate instrumentation manifest as JSON.

    This maps dump output columns back to probe metadata.
    """
    if not config.enabled or config.probe_plan is None:
        return {}

    manifest = {
        "instrumentation_version": "1.0",
        "probes": [],
    }

    for probe in config.probe_plan.probes:
        probe_info = {
            "signal": probe.rtl_signal_name,
            "module": probe.module_name,
            "width": probe.width,
            "signal_class": probe.signal_class,
            "clock_domain": probe.clock_domain,
            "columns": {
                "sample_count": config.track_samples,
                "change_count": config.track_value_changes,
                "toggle_count": config.track_toggles,
                "high_cycle_count": config.track_high_cycles,
                "bit_toggle_counts": config.per_bit_counters,
            }
        }

        if probe.source_loc:
            probe_info["source_loc"] = {
                "file": probe.source_loc.file,
                "line": probe.source_loc.line,
                "column": probe.source_loc.column,
            }

        manifest["probes"].append(probe_info)

    return manifest


def _cpp_value_type(width: int) -> str:
    width = max(width, 1)
    if width == 1:
        return "bool"
    if width <= 8:
        return "uint8_t"
    if width <= 16:
        return "uint16_t"
    if width <= 32:
        return "uint32_t"
    if width <= 64:
        return "uint64_t"
    return f"sc_bv<{width}>"


def _counter_suffix(probe: ProbeSpec) -> str:
    return _sanitize_identifier(probe.rtl_signal_name)


def _probe_read_expr(probe: ProbeSpec) -> str:
    return _sanitize_member_expr(probe.systemc_member_name)


def _probe_current_value_expr(probe: ProbeSpec) -> str:
    width = max(probe.width, 1)
    read_expr = f"{_probe_read_expr(probe)}.read()"
    if width == 1:
        return read_expr
    if width <= 8:
        return f"static_cast<uint8_t>({read_expr})"
    if width <= 16:
        return f"static_cast<uint16_t>({read_expr})"
    if width <= 32:
        return f"static_cast<uint32_t>({read_expr})"
    if width <= 64:
        return f"static_cast<uint64_t>({read_expr})"
    return read_expr


def _sanitize_member_expr(expr: str) -> str:
    match = re.fullmatch(r"(?P<base>[A-Za-z_][A-Za-z0-9_$]*)(?P<indexes>(\[\d+\])+)", expr)
    if match:
        return f"{_sanitize_identifier(match.group('base'))}{match.group('indexes')}"
    return _sanitize_identifier(expr)


def _sanitize_identifier(name: str) -> str:
    cleaned = re.sub(r"\W", "_", name)
    if not cleaned:
        return "unnamed"
    if cleaned[0].isdigit():
        return f"_{cleaned}"
    return cleaned
