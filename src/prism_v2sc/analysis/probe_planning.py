"""Probe planning for power instrumentation.

This module determines which signals should be instrumented for dynamic power
analysis, without modifying the SystemC codegen yet.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from prism_v2sc.ir.model import DesignIR, ModuleIR, SignalIR, SourceLocIR
from prism_v2sc.analysis.sensitivity import analyze_sensitivity
from prism_v2sc.analysis.power_static import analyze_static_power, PowerSuspect


@dataclass(frozen=True)
class ProbeSpec:
    """Specification for a single signal probe.

    This describes what to instrument and how to sample it.
    """

    # Identity
    instance_path: str          # Hierarchical path (e.g., "top.cpu.alu")
    module_name: str            # Module type name
    rtl_signal_name: str        # Original RTL signal name
    systemc_member_name: str    # Generated SystemC member name

    # Signal properties
    width: int                  # Bit width
    signal_class: str           # "state", "comb", "port", "memory_cell"

    # Sampling strategy
    clock_domain: str | None    # Clock signal name for sampling (None for comb)
    clock_edge: str | None      # "posedge" or "negedge"

    # Context
    source_loc: SourceLocIR | None      # Source location
    static_reason_codes: tuple[str, ...] # Reason codes from static analysis


@dataclass(frozen=True)
class PowerProbePlan:
    """Complete probe plan for a design.

    This is the manifest that bridges static analysis and SystemC instrumentation.
    """

    probes: tuple[ProbeSpec, ...]

    # Metadata
    design_name: str
    top_module: str
    probe_count: int
    state_probe_count: int
    comb_probe_count: int
    memory_probe_count: int

    # Policy used
    policy: str  # "default", "all_signals", "suspects_only"
    warnings: tuple[str, ...] = ()
    estimated_counter_count: int = 0
    estimated_storage_bytes: int = 0


@dataclass(frozen=True)
class ProbePlanPolicy:
    """Configuration for probe selection policy."""

    # What to probe
    probe_all_state_registers: bool = True     # Always probe state registers
    probe_comb_suspects_only: bool = True      # Only probe comb signals with issues
    probe_ports: bool = False                  # Probe module ports
    probe_memory_cells: bool = False           # Probe unpacked-array cells

    # Filtering
    filter_synthetic_signals: bool = True      # Skip __next_*, __shadow_*, etc.

    # Top-K selection for combinational suspects
    max_comb_suspects: int | None = 20         # Limit number of comb probes
    max_memory_cells: int | None = 64          # Cap cell-level memory probes
    warning_probe_count: int = 1000            # Emit warning above this count
    max_total_probes: int | None = 10000       # Reject pathological plans


def create_probe_plan(
    design: DesignIR,
    policy: ProbePlanPolicy | None = None,
) -> PowerProbePlan:
    """Create a probe plan for a design.

    This determines which signals to instrument based on:
    - Signal classification (state vs comb)
    - Static power analysis results
    - Probe policy configuration

    Args:
        design: The design IR
        policy: Probe selection policy (uses default if None)

    Returns:
        PowerProbePlan with all probe specifications
    """
    if policy is None:
        policy = ProbePlanPolicy()

    probes: list[ProbeSpec] = []

    # Process each module
    for module in design.modules:
        module_probes = _plan_module_probes(module, policy)
        probes.extend(module_probes)

    # Count by signal class
    state_count = sum(1 for p in probes if p.signal_class == "state")
    comb_count = sum(1 for p in probes if p.signal_class == "comb")
    memory_count = sum(1 for p in probes if p.signal_class == "memory_cell")

    if policy.max_total_probes is not None and len(probes) > policy.max_total_probes:
        raise ValueError(
            f"probe plan has {len(probes)} probes, exceeding limit {policy.max_total_probes}"
        )

    warnings: list[str] = []
    if len(probes) > policy.warning_probe_count:
        warnings.append(
            f"probe plan has {len(probes)} probes; instrumentation may slow simulation"
        )

    estimated_counter_count = _estimate_counter_count(probes)
    estimated_storage_bytes = estimated_counter_count * 8

    # Determine policy name
    if policy.probe_all_state_registers and not policy.probe_comb_suspects_only:
        policy_name = "all_signals"
    elif not policy.probe_all_state_registers and policy.probe_comb_suspects_only:
        policy_name = "suspects_only"
    else:
        policy_name = "default"

    return PowerProbePlan(
        probes=tuple(probes),
        design_name=design.top,  # Use top module name as design name
        top_module=design.top,
        probe_count=len(probes),
        state_probe_count=state_count,
        comb_probe_count=comb_count,
        memory_probe_count=memory_count,
        policy=policy_name,
        warnings=tuple(warnings),
        estimated_counter_count=estimated_counter_count,
        estimated_storage_bytes=estimated_storage_bytes,
    )


def _plan_module_probes(
    module: ModuleIR,
    policy: ProbePlanPolicy,
) -> list[ProbeSpec]:
    """Plan probes for a single module."""
    probes: list[ProbeSpec] = []

    # Run sensitivity analysis to classify signals
    sens_analysis = analyze_sensitivity(module)

    # Run static power analysis to get suspects
    suspects = analyze_static_power(module)

    # Build suspect lookup by signal name
    suspect_map: dict[str, list[PowerSuspect]] = {}
    for suspect in suspects:
        if suspect.signal not in suspect_map:
            suspect_map[suspect.signal] = []
        suspect_map[suspect.signal].append(suspect)

    # Get clock domains
    clock_domains = sens_analysis.clock_domains
    signal_to_domains = sens_analysis.signal_to_domains

    # Process both ports and internal signals
    all_signals = []

    # Add ports (if policy allows or if they are state registers)
    for port in module.ports:
        if policy.probe_ports:
            # Probe all ports
            all_signals.append((port.name, port.kind, port.width, port.loc))
        elif port.direction == "output" and port.name in sens_analysis.state_signals:
            # Always probe output state registers
            all_signals.append((port.name, port.kind, port.width, port.loc))
        elif port.direction == "output" and not policy.probe_comb_suspects_only:
            # If probing all signals, include output ports
            all_signals.append((port.name, port.kind, port.width, port.loc))

    # Add internal signals
    for signal in module.signals:
        if signal.unpacked_dims:
            if policy.probe_memory_cells:
                probes.extend(
                    _plan_memory_cell_probes(
                        module,
                        signal,
                        policy,
                        sens_analysis,
                        suspect_map,
                    )
                )
            continue
        all_signals.append((signal.name, signal.kind, signal.width, signal.loc))

    for signal_name, signal_kind, signal_width, signal_loc in all_signals:
        # Filter synthetic signals
        if policy.filter_synthetic_signals and _is_synthetic_signal(signal_name):
            continue

        # Determine signal class
        if signal_name in sens_analysis.state_signals:
            signal_class = "state"
            should_probe = policy.probe_all_state_registers
        elif signal_name in sens_analysis.comb_signals:
            signal_class = "comb"
            # Only probe comb signals if they are suspects (when policy says so)
            should_probe = not policy.probe_comb_suspects_only or signal_name in suspect_map
        else:
            # Unknown classification, treat as comb (e.g., output ports)
            signal_class = "comb"
            # Probe if we're in all-signals mode
            should_probe = not policy.probe_comb_suspects_only

        if not should_probe:
            continue

        # Get clock domain for state signals
        clock_domain = None
        clock_edge = None
        if signal_class == "state" and signal_name in signal_to_domains:
            domains = signal_to_domains[signal_name]
            if domains:
                # Use the first domain
                domain = next(iter(domains))
                clock_domain = domain.clock_signal
                clock_edge = domain.edge

        # Get width
        width = _compute_width_from_width_ir(signal_width)

        # Get static reason codes
        reason_codes = tuple(s.reason_code for s in suspect_map.get(signal_name, []))

        # Create probe spec
        probe = ProbeSpec(
            instance_path=module.name,  # For now, flat instance path
            module_name=module.name,
            rtl_signal_name=signal_name,
            systemc_member_name=signal_name,  # TODO: Apply name mapping
            width=width,
            signal_class=signal_class,
            clock_domain=clock_domain,
            clock_edge=clock_edge,
            source_loc=signal_loc,
            static_reason_codes=reason_codes,
        )

        probes.append(probe)

    # Apply top-K selection for comb suspects if configured
    if policy.max_comb_suspects is not None:
        comb_probes = [p for p in probes if p.signal_class == "comb"]
        state_probes = [p for p in probes if p.signal_class != "comb"]

        # Sort comb probes by number of reason codes (most suspicious first)
        comb_probes_sorted = sorted(
            comb_probes,
            key=lambda p: len(p.static_reason_codes),
            reverse=True
        )

        # Keep top K
        comb_probes_selected = comb_probes_sorted[:policy.max_comb_suspects]

        probes = state_probes + comb_probes_selected

    return probes


def _plan_memory_cell_probes(
    module: ModuleIR,
    signal: SignalIR,
    policy: ProbePlanPolicy,
    sens_analysis: Any,
    suspect_map: dict[str, list[PowerSuspect]],
) -> list[ProbeSpec]:
    """Create optional probes for unpacked-array cells."""
    cell_indices = _memory_cell_indices(signal.unpacked_dims)
    if policy.max_memory_cells is not None:
        cell_indices = cell_indices[:policy.max_memory_cells]

    domains = sens_analysis.signal_to_domains.get(signal.name, set())
    clock_domain = None
    clock_edge = None
    if domains:
        domain = next(iter(domains))
        clock_domain = domain.clock_signal
        clock_edge = domain.edge

    width = _compute_width_from_width_ir(signal.width)
    reason_codes = tuple(s.reason_code for s in suspect_map.get(signal.name, []))
    probes: list[ProbeSpec] = []
    for index_tuple in cell_indices:
        index_text = "][".join(str(index) for index in index_tuple)
        cell_name = f"{signal.name}[{index_text}]"
        probes.append(
            ProbeSpec(
                instance_path=module.name,
                module_name=module.name,
                rtl_signal_name=cell_name,
                systemc_member_name=cell_name,
                width=width,
                signal_class="memory_cell",
                clock_domain=clock_domain,
                clock_edge=clock_edge,
                source_loc=signal.loc,
                static_reason_codes=reason_codes,
            )
        )
    return probes


def _memory_cell_indices(dims: tuple[tuple[int, int], ...]) -> list[tuple[int, ...]]:
    if not dims:
        return []
    ranges = [range(abs(msb - lsb) + 1) for msb, lsb in dims]
    result: list[tuple[int, ...]] = [()]
    for dim_range in ranges:
        result = [prefix + (index,) for prefix in result for index in dim_range]
    return result


def _compute_width_from_width_ir(width: Any) -> int:
    """Compute the width from WidthIR."""
    if width is None:
        return 1

    try:
        msb = int(width.msb)
        lsb = int(width.lsb)
        return abs(msb - lsb) + 1
    except (ValueError, AttributeError):
        return 1


def _is_synthetic_signal(name: str) -> bool:
    """Check if a signal is synthetic (generated by converter)."""
    return (
        name.startswith("__next_") or
        name.startswith("__shadow_") or
        name.startswith("__bridge_")
    )


def _estimate_counter_count(probes: list[ProbeSpec]) -> int:
    """Estimate coarse counter count for a probe plan."""
    # sample, value-change, and total bit-toggle counters per probe.
    return len(probes) * 3


def export_probe_plan_json(plan: PowerProbePlan) -> dict[str, Any]:
    """Export probe plan to JSON-serializable dict."""
    return {
        "design_name": plan.design_name,
        "top_module": plan.top_module,
        "probe_count": plan.probe_count,
        "state_probe_count": plan.state_probe_count,
        "comb_probe_count": plan.comb_probe_count,
        "memory_probe_count": plan.memory_probe_count,
        "policy": plan.policy,
        "warnings": list(plan.warnings),
        "estimated_counter_count": plan.estimated_counter_count,
        "estimated_storage_bytes": plan.estimated_storage_bytes,
        "probes": [
            {
                "instance_path": probe.instance_path,
                "module_name": probe.module_name,
                "rtl_signal_name": probe.rtl_signal_name,
                "systemc_member_name": probe.systemc_member_name,
                "width": probe.width,
                "signal_class": probe.signal_class,
                "clock_domain": probe.clock_domain,
                "clock_edge": probe.clock_edge,
                "source_loc": {
                    "file": probe.source_loc.file,
                    "line": probe.source_loc.line,
                    "column": probe.source_loc.column,
                } if probe.source_loc else None,
                "static_reason_codes": list(probe.static_reason_codes),
            }
            for probe in plan.probes
        ],
    }
