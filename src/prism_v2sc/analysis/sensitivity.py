"""Sensitivity and clock domain analysis for lowered IR."""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from typing import Any

from prism_v2sc.ir.model import ModuleIR, ProcessIR, SensitivityIR


@dataclass(frozen=True)
class ClockDomain:
    """Clock domain information."""

    clock_signal: str
    edge: str  # "posedge" or "negedge"
    reset_signal: str | None = None
    reset_edge: str | None = None  # "posedge" or "negedge"


@dataclass(frozen=True)
class SensitivityAnalysis:
    """Sensitivity and clock domain analysis results."""

    # Signal name -> set of clock domains it belongs to
    signal_to_domains: dict[str, set[ClockDomain]]
    # Clock signal name -> ClockDomain
    clock_domains: dict[str, ClockDomain]
    # Set of state signal names (registered signals)
    state_signals: set[str]
    # Set of combinational signal names
    comb_signals: set[str]


def analyze_sensitivity(module: ModuleIR) -> SensitivityAnalysis:
    """Analyze sensitivity and clock domains in a module.

    Returns:
        SensitivityAnalysis with clock domain and signal classification info.
    """
    signal_to_domains: dict[str, set[ClockDomain]] = defaultdict(set)
    clock_domains: dict[str, ClockDomain] = {}
    state_signals: set[str] = set()
    comb_signals: set[str] = set()

    # Analyze each process
    for process in module.processes:
        if process.kind == "always_ff":
            # Extract clock domain from sensitivity list
            domain = _extract_clock_domain(process.sensitivity)
            if domain:
                clock_domains[domain.clock_signal] = domain

                # Collect state signals (LHS of assignments in always_ff)
                targets = _collect_assignment_targets(process)
                state_signals.update(targets)

                # Associate state signals with this clock domain
                for target in targets:
                    signal_to_domains[target].add(domain)
        elif process.kind in ("always_comb", "always_latch"):
            # Combinational signals
            targets = _collect_assignment_targets(process)
            comb_signals.update(targets)

    return SensitivityAnalysis(
        signal_to_domains=dict(signal_to_domains),
        clock_domains=clock_domains,
        state_signals=state_signals,
        comb_signals=comb_signals,
    )


def _extract_clock_domain(sensitivity: tuple[SensitivityIR, ...]) -> ClockDomain | None:
    """Extract clock domain from a sensitivity list.

    For always_ff blocks, this looks for posedge/negedge clock signals.
    """
    clock_signal: str | None = None
    clock_edge: str | None = None
    reset_signal: str | None = None
    reset_edge: str | None = None

    for item in sensitivity:
        if item.edge in ("posedge", "negedge"):
            # First edge-sensitive signal is typically the clock
            if clock_signal is None:
                clock_signal = item.signal
                clock_edge = item.edge
            else:
                # Second edge-sensitive signal is typically reset
                reset_signal = item.signal
                reset_edge = item.edge

    if clock_signal and clock_edge:
        return ClockDomain(
            clock_signal=clock_signal,
            edge=clock_edge,
            reset_signal=reset_signal,
            reset_edge=reset_edge,
        )

    return None


def _collect_assignment_targets(process: ProcessIR) -> set[str]:
    """Collect all assignment target signal names from a process."""
    targets: set[str] = set()

    for statement in process.structured_statements:
        _collect_targets_from_statement(statement, targets)

    return targets


def _collect_targets_from_statement(statement: dict[str, Any], targets: set[str]) -> None:
    """Recursively collect assignment targets from a statement."""
    kind = statement.get("type")

    if kind in ("blocking_assign", "nonblocking_assign"):
        targets.update(_extract_base_signals(
            str(statement.get("left", "")),
            statement.get("left_expr")
        ))
    elif kind == "if":
        # Recursively process if branches
        true_branch = statement.get("true")
        if isinstance(true_branch, list):
            for child in true_branch:
                if isinstance(child, dict):
                    _collect_targets_from_statement(child, targets)

        false_branch = statement.get("false")
        if isinstance(false_branch, list):
            for child in false_branch:
                if isinstance(child, dict):
                    _collect_targets_from_statement(child, targets)
    elif kind == "case":
        # Recursively process case items
        items = statement.get("items")
        if isinstance(items, list):
            for item in items:
                if isinstance(item, dict):
                    stmts = item.get("statements")
                    if isinstance(stmts, list):
                        for child in stmts:
                            if isinstance(child, dict):
                                _collect_targets_from_statement(child, targets)
    elif kind == "for":
        # Recursively process for loop body
        body = statement.get("body")
        if isinstance(body, list):
            for child in body:
                if isinstance(child, dict):
                    _collect_targets_from_statement(child, targets)


def _extract_base_signals(left_text: str, left_expr: dict[str, Any] | None) -> set[str]:
    """Extract base signal names from an assignment target."""
    if isinstance(left_expr, dict):
        bases = _extract_lvalue_bases(left_expr)
        if bases:
            return bases

    # Fallback to text parsing for legacy or unsupported lvalue shapes.
    import re
    match = re.match(r"^\s*(?P<name>[A-Za-z_][A-Za-z0-9_$]*)", left_text)
    if match:
        return {match.group("name")}
    return set()


def _extract_base_signal(left_text: str, left_expr: dict[str, Any] | None) -> str:
    """Backward-compatible single-target helper."""
    bases = _extract_base_signals(left_text, left_expr)
    return next(iter(bases), "")


def _extract_lvalue_bases(expr: dict[str, Any] | None) -> set[str]:
    if not isinstance(expr, dict):
        return set()
    kind = expr.get("kind")
    if kind == "identifier":
        name = expr.get("name")
        return {str(name)} if name else set()
    if kind in {"bitselect", "partselect"}:
        return _extract_lvalue_bases(expr.get("target") or expr.get("signal"))
    if kind == "concat":
        bases: set[str] = set()
        parts = expr.get("parts") or expr.get("elements") or ()
        if isinstance(parts, list):
            for part in parts:
                bases.update(_extract_lvalue_bases(part))
        return bases
    return set()


def infer_empty_sensitivity() -> tuple[str, ...]:
    """Return an empty sensitivity list for placeholder flows.

    This is kept for backward compatibility with older code.
    """
    return ()
