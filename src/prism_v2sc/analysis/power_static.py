"""Static power analysis for identifying potential power hotspots without simulation."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from prism_v2sc.ir.model import ModuleIR, SignalIR, SourceLocIR
from prism_v2sc.analysis.dependencies import analyze_dependencies
from prism_v2sc.analysis.sensitivity import analyze_sensitivity
from prism_v2sc.analysis.expression_metrics import analyze_expression_metrics
from prism_v2sc.codegen.expr import build_module_context


@dataclass(frozen=True)
class PowerThresholds:
    """Configurable thresholds for power analysis.

    All thresholds are intentionally conservative to reduce false positives.
    """

    # Width thresholds
    wide_register_bits: int = 32  # Registers wider than this are candidates for gating
    wide_mux_bits: int = 16       # Muxes wider than this are power-significant

    # Fanout thresholds
    high_fanout_count: int = 10   # Signals driving more than this many other signals

    # Expression complexity thresholds
    deep_expression_depth: int = 4      # Expression depth indicating glitch risk
    complex_expression_nodes: int = 15  # Total nodes indicating complex logic

    # Mux/case thresholds
    mux_threshold: int = 3        # Number of muxes to flag as suspicious


@dataclass(frozen=True)
class PowerSuspect:
    """A potential power hotspot identified by static analysis."""

    module: str
    signal: str
    reason_code: str
    message: str
    recommendation: str
    severity: str = "info"  # "info", "warning", "error"
    loc: SourceLocIR | None = None
    width: int | None = None
    metrics: dict[str, Any] | None = None


def analyze_static_power(module: ModuleIR, thresholds: PowerThresholds | None = None) -> tuple[PowerSuspect, ...]:
    """Perform static power analysis on a module.

    Identifies potential power hotspots without simulation:
    - Wide registers without enable guards
    - Counter patterns
    - Wide muxes
    - High fanout signals
    - Deep combinational cones (glitch risk)

    Args:
        module: The module to analyze
        thresholds: Optional custom thresholds (uses defaults if None)

    Returns:
        Tuple of PowerSuspect records, sorted by severity and width
    """
    if thresholds is None:
        thresholds = PowerThresholds()

    suspects: list[PowerSuspect] = []

    # Run dependency and sensitivity analysis
    dep_graph = analyze_dependencies(module)
    sens_analysis = analyze_sensitivity(module)
    expr_metrics = analyze_expression_metrics(module)

    # Build signal width map
    signal_widths = _build_signal_width_map(module)

    # Build signal location map
    signal_locs = _build_signal_location_map(module)

    # 1. Check for wide registers without enable guards
    suspects.extend(_check_wide_registers(
        module, sens_analysis.state_signals, signal_widths, signal_locs, thresholds
    ))

    # 2. Check for counter patterns
    suspects.extend(_check_counter_patterns(
        module, sens_analysis.state_signals, signal_locs
    ))

    # 3. Check for wide muxes
    suspects.extend(_check_wide_muxes(
        module, expr_metrics, signal_widths, signal_locs, thresholds
    ))

    # 4. Check for high fanout signals
    suspects.extend(_check_high_fanout(
        module, dep_graph.fanout_count, signal_widths, signal_locs, thresholds
    ))

    # 5. Check for deep combinational expressions (glitch risk)
    suspects.extend(_check_deep_expressions(
        module, expr_metrics, signal_locs, thresholds
    ))

    # Sort by severity and width
    sorted_suspects = sorted(
        suspects,
        key=lambda s: (
            0 if s.severity == "error" else (1 if s.severity == "warning" else 2),
            -(s.width or 0)
        )
    )

    return tuple(sorted_suspects)


def _build_signal_width_map(module: ModuleIR) -> dict[str, int]:
    """Build a map from signal name to bit width."""
    return dict(build_module_context(module).signal_widths)


def _build_signal_location_map(module: ModuleIR) -> dict[str, SourceLocIR]:
    """Build a map from signal name to source location."""
    locs: dict[str, SourceLocIR] = {}

    for port in module.ports:
        if port.loc:
            locs[port.name] = port.loc

    for signal in module.signals:
        if signal.loc:
            locs[signal.name] = signal.loc

    return locs


def _compute_width(width: Any) -> int:
    """Compute bit width from WidthIR."""
    if width is None:
        return 1

    try:
        msb = int(width.msb)
        lsb = int(width.lsb)
        return abs(msb - lsb) + 1
    except (ValueError, AttributeError):
        return 1


def _check_wide_registers(
    module: ModuleIR,
    state_signals: set[str],
    signal_widths: dict[str, int],
    signal_locs: dict[str, SourceLocIR],
    thresholds: PowerThresholds,
) -> list[PowerSuspect]:
    """Check for wide registers that might benefit from clock gating."""
    suspects: list[PowerSuspect] = []

    for signal in state_signals:
        width = signal_widths.get(signal, 1)
        if width >= thresholds.wide_register_bits:
            # Check if it has enable guard (heuristic: look for "enable" in dependencies)
            # For now, flag all wide registers as candidates
            suspects.append(PowerSuspect(
                module=module.name,
                signal=signal,
                reason_code="clock_gating_candidate",
                message=f"Wide register '{signal}' ({width} bits) may benefit from clock gating",
                recommendation=f"Consider adding an enable signal to gate updates when '{signal}' is idle",
                severity="info",
                loc=signal_locs.get(signal),
                width=width,
            ))

    return suspects


def _check_counter_patterns(
    module: ModuleIR,
    state_signals: set[str],
    signal_locs: dict[str, SourceLocIR],
) -> list[PowerSuspect]:
    """Check for counter patterns (reg <= reg +/- const)."""
    suspects: list[PowerSuspect] = []

    for process in module.processes:
        if process.kind != "always_ff":
            continue

        for statement in process.structured_statements:
            counter_info = _detect_counter_in_statement(statement, state_signals)
            if counter_info:
                signal, op = counter_info
                suspects.append(PowerSuspect(
                    module=module.name,
                    signal=signal,
                    reason_code="counter_activity_candidate",
                    message=f"Counter pattern detected: '{signal}' {op}= constant",
                    recommendation=f"Counters toggle frequently; consider gating or reducing update rate",
                    severity="info",
                    loc=signal_locs.get(signal),
                ))

    return suspects


def _detect_counter_in_statement(statement: dict[str, Any], state_signals: set[str]) -> tuple[str, str] | None:
    """Detect counter pattern in a statement."""
    kind = statement.get("type")

    if kind in ("blocking_assign", "nonblocking_assign"):
        # Check if LHS is a state signal
        left_text = str(statement.get("left", ""))
        left_expr = statement.get("left_expr")

        if left_expr and left_expr.get("kind") == "identifier":
            target = str(left_expr.get("name", ""))
            if target in state_signals:
                # Check if RHS is target +/- constant
                right_expr = statement.get("right_expr")
                if right_expr and right_expr.get("kind") == "binop":
                    op = str(right_expr.get("op", ""))
                    if op in ("+", "-"):
                        left = right_expr.get("left")
                        right = right_expr.get("right")

                        # Check if one operand is the target and the other is a literal/intconst
                        if left and left.get("kind") == "identifier" and left.get("name") == target:
                            if right and right.get("kind") in ("literal", "intconst"):
                                return (target, op)
                        if right and right.get("kind") == "identifier" and right.get("name") == target:
                            if left and left.get("kind") in ("literal", "intconst"):
                                return (target, op)

    elif kind == "if":
        # Check both branches
        true_branch = statement.get("true")
        if isinstance(true_branch, list):
            for child in true_branch:
                if isinstance(child, dict):
                    result = _detect_counter_in_statement(child, state_signals)
                    if result:
                        return result

        false_branch = statement.get("false")
        if isinstance(false_branch, list):
            for child in false_branch:
                if isinstance(child, dict):
                    result = _detect_counter_in_statement(child, state_signals)
                    if result:
                        return result

    return None


def _check_wide_muxes(
    module: ModuleIR,
    expr_metrics: dict[str, Any],
    signal_widths: dict[str, int],
    signal_locs: dict[str, SourceLocIR],
    thresholds: PowerThresholds,
) -> list[PowerSuspect]:
    """Check for wide muxes."""
    suspects: list[PowerSuspect] = []

    for signal, metrics in expr_metrics.items():
        if metrics.mux_count >= thresholds.mux_threshold:
            width = signal_widths.get(signal, 1)
            if width >= thresholds.wide_mux_bits:
                suspects.append(PowerSuspect(
                    module=module.name,
                    signal=signal,
                    reason_code="wide_mux_candidate",
                    message=f"Signal '{signal}' has {metrics.mux_count} muxes and is {width} bits wide",
                    recommendation="Consider reducing mux width or using case statements with synthesis attributes",
                    severity="info",
                    loc=signal_locs.get(signal),
                    width=width,
                    metrics={"mux_count": metrics.mux_count},
                ))

    return suspects


def _check_high_fanout(
    module: ModuleIR,
    fanout_counts: dict[str, int],
    signal_widths: dict[str, int],
    signal_locs: dict[str, SourceLocIR],
    thresholds: PowerThresholds,
) -> list[PowerSuspect]:
    """Check for high fanout signals."""
    suspects: list[PowerSuspect] = []

    for signal, fanout in fanout_counts.items():
        if fanout >= thresholds.high_fanout_count:
            width = signal_widths.get(signal, 1)
            suspects.append(PowerSuspect(
                module=module.name,
                signal=signal,
                reason_code="high_fanout_candidate",
                message=f"Signal '{signal}' has high fanout ({fanout} loads)",
                recommendation="High fanout signals dissipate more dynamic power; consider buffering or reducing fanout",
                severity="info",
                loc=signal_locs.get(signal),
                width=width,
                metrics={"fanout": fanout},
            ))

    return suspects


def _check_deep_expressions(
    module: ModuleIR,
    expr_metrics: dict[str, Any],
    signal_locs: dict[str, SourceLocIR],
    thresholds: PowerThresholds,
) -> list[PowerSuspect]:
    """Check for deep combinational expressions (glitch risk)."""
    suspects: list[PowerSuspect] = []

    for signal, metrics in expr_metrics.items():
        if metrics.max_expr_depth >= thresholds.deep_expression_depth:
            suspects.append(PowerSuspect(
                module=module.name,
                signal=signal,
                reason_code="glitch_risk_structural",
                message=f"Signal '{signal}' has deep combinational logic (depth {metrics.max_expr_depth})",
                recommendation="Deep logic can produce glitches; consider pipeline registers to reduce glitch power",
                severity="info",
                loc=signal_locs.get(signal),
                metrics={"depth": metrics.max_expr_depth, "nodes": metrics.total_node_count},
            ))

    return suspects
