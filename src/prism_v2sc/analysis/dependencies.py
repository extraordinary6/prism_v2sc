"""Dependency analysis for signals and expressions in lowered IR."""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from typing import Any

from prism_v2sc.ir.model import ContinuousAssignIR, ModuleIR, ProcessIR


@dataclass(frozen=True)
class DependencyGraph:
    """Dependency graph for a module."""

    # Signal name -> set of signals it depends on (fanin)
    dependencies: dict[str, set[str]]
    # Signal name -> set of signals that depend on it (fanout)
    dependents: dict[str, set[str]]
    # Signal name -> fanin count
    fanin_count: dict[str, int]
    # Signal name -> fanout count
    fanout_count: dict[str, int]


def analyze_dependencies(module: ModuleIR) -> DependencyGraph:
    """Analyze signal dependencies in a module.

    Returns a dependency graph with fanin/fanout information.
    """
    dependencies: dict[str, set[str]] = defaultdict(set)
    dependents: dict[str, set[str]] = defaultdict(set)

    # Analyze continuous assigns
    for assign in module.continuous_assigns:
        targets = _extract_targets(assign.left, assign.left_expr)
        if targets:
            sources = _collect_identifiers(assign.right_expr)
            for target in targets:
                dependencies[target].update(sources)
                for source in sources:
                    dependents[source].add(target)

    # Analyze processes
    for process in module.processes:
        for statement in process.structured_statements:
            _analyze_statement(statement, dependencies, dependents)

    # Compute fanin/fanout counts
    fanin_count = {sig: len(deps) for sig, deps in dependencies.items()}
    fanout_count = {sig: len(deps) for sig, deps in dependents.items()}

    return DependencyGraph(
        dependencies=dict(dependencies),
        dependents=dict(dependents),
        fanin_count=fanin_count,
        fanout_count=fanout_count,
    )


def _extract_targets(left_text: str, left_expr: dict[str, Any] | None) -> set[str]:
    """Extract base signal names from an assignment target."""
    if isinstance(left_expr, dict):
        targets = _extract_lvalue_bases(left_expr)
        if targets:
            return targets

    # Fallback to text parsing for legacy or unsupported lvalue shapes.
    import re
    match = re.match(r"^\s*(?P<name>[A-Za-z_][A-Za-z0-9_$]*)", left_text)
    if match:
        return {match.group("name")}
    return set()


def _extract_target(left_text: str, left_expr: dict[str, Any] | None) -> str:
    """Backward-compatible single-target helper."""
    targets = _extract_targets(left_text, left_expr)
    return next(iter(targets), "")


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


def _collect_identifiers(expr: dict[str, Any] | None) -> set[str]:
    """Recursively collect all identifier names from an expression."""
    if not expr or not isinstance(expr, dict):
        return set()

    identifiers: set[str] = set()
    kind = expr.get("kind")

    if kind == "identifier":
        name = expr.get("name")
        if name:
            identifiers.add(str(name))
    elif kind in ("binop", "unop"):
        # Binary or unary operation
        left = expr.get("left")
        right = expr.get("right")
        operand = expr.get("operand")
        if left:
            identifiers.update(_collect_identifiers(left))
        if right:
            identifiers.update(_collect_identifiers(right))
        if operand:
            identifiers.update(_collect_identifiers(operand))
    elif kind == "cond":
        # Ternary conditional
        identifiers.update(_collect_identifiers(expr.get("cond")))
        identifiers.update(_collect_identifiers(expr.get("true")))
        identifiers.update(_collect_identifiers(expr.get("false")))
    elif kind == "concat":
        # Concatenation
        elements = expr.get("parts") or expr.get("elements")
        if isinstance(elements, list):
            for elem in elements:
                identifiers.update(_collect_identifiers(elem))
    elif kind in ("bitselect", "partselect"):
        # Bit or part select
        signal = expr.get("target") or expr.get("signal")
        identifiers.update(_collect_identifiers(signal))
        # Also collect from index expressions
        identifiers.update(_collect_identifiers(expr.get("index")))
        identifiers.update(_collect_identifiers(expr.get("msb")))
        identifiers.update(_collect_identifiers(expr.get("lsb")))
    elif kind == "call":
        # Function call
        args = expr.get("args")
        if isinstance(args, list):
            for arg in args:
                identifiers.update(_collect_identifiers(arg))
    elif kind == "cast":
        # Type cast
        identifiers.update(_collect_identifiers(expr.get("operand")))
    elif kind in ("replicate", "repeat"):
        # Replication
        identifiers.update(_collect_identifiers(expr.get("count")))
        identifiers.update(_collect_identifiers(expr.get("value")))
        identifiers.update(_collect_identifiers(expr.get("concat")))

    return identifiers


def _analyze_statement(
    statement: dict[str, Any],
    dependencies: dict[str, set[str]],
    dependents: dict[str, set[str]],
) -> None:
    """Analyze dependencies in a structured statement."""
    kind = statement.get("type")

    if kind in ("blocking_assign", "nonblocking_assign"):
        # Assignment
        targets = _extract_targets(
            str(statement.get("left", "")),
            statement.get("left_expr")
        )
        if targets:
            sources = _collect_identifiers(statement.get("right_expr"))
            for target in targets:
                dependencies[target].update(sources)
                for source in sources:
                    dependents[source].add(target)
    elif kind == "if":
        # If statement - condition signals affect all targets in branches
        cond_sources = _collect_identifiers(statement.get("cond_expr"))

        # Collect targets from branches
        branch_targets: set[str] = set()

        true_branch = statement.get("true")
        if isinstance(true_branch, list):
            for child in true_branch:
                if isinstance(child, dict):
                    # Collect targets from this branch
                    child_targets = _collect_targets_from_statement(child)
                    branch_targets.update(child_targets)
                    # Recursively analyze
                    _analyze_statement(child, dependencies, dependents)

        false_branch = statement.get("false")
        if isinstance(false_branch, list):
            for child in false_branch:
                if isinstance(child, dict):
                    # Collect targets from this branch
                    child_targets = _collect_targets_from_statement(child)
                    branch_targets.update(child_targets)
                    # Recursively analyze
                    _analyze_statement(child, dependencies, dependents)

        # Condition signals are dependencies of all branch targets
        for target in branch_targets:
            dependencies[target].update(cond_sources)
            for source in cond_sources:
                dependents[source].add(target)

    elif kind == "case":
        # Case statement - selector affects all targets
        selector_sources = _collect_identifiers(statement.get("expr_tree") or statement.get("expr"))

        # Collect targets from all case items
        case_targets: set[str] = set()

        items = statement.get("items")
        if isinstance(items, list):
            for item in items:
                if isinstance(item, dict):
                    stmts = item.get("statements")
                    if isinstance(stmts, list):
                        for child in stmts:
                            if isinstance(child, dict):
                                child_targets = _collect_targets_from_statement(child)
                                case_targets.update(child_targets)
                                _analyze_statement(child, dependencies, dependents)

        # Selector signals are dependencies of all case targets
        for target in case_targets:
            dependencies[target].update(selector_sources)
            for source in selector_sources:
                dependents[source].add(target)

    elif kind == "for":
        # For loop
        body = statement.get("body")
        if isinstance(body, list):
            for child in body:
                if isinstance(child, dict):
                    _analyze_statement(child, dependencies, dependents)


def _collect_targets_from_statement(statement: dict[str, Any]) -> set[str]:
    """Collect all assignment targets from a statement (recursively)."""
    targets: set[str] = set()
    kind = statement.get("type")

    if kind in ("blocking_assign", "nonblocking_assign"):
        extracted = _extract_targets(
            str(statement.get("left", "")),
            statement.get("left_expr")
        )
        targets.update(extracted)
    elif kind == "if":
        true_branch = statement.get("true")
        if isinstance(true_branch, list):
            for child in true_branch:
                if isinstance(child, dict):
                    targets.update(_collect_targets_from_statement(child))

        false_branch = statement.get("false")
        if isinstance(false_branch, list):
            for child in false_branch:
                if isinstance(child, dict):
                    targets.update(_collect_targets_from_statement(child))
    elif kind == "case":
        items = statement.get("items")
        if isinstance(items, list):
            for item in items:
                if isinstance(item, dict):
                    stmts = item.get("statements")
                    if isinstance(stmts, list):
                        for child in stmts:
                            if isinstance(child, dict):
                                targets.update(_collect_targets_from_statement(child))
    elif kind == "for":
        body = statement.get("body")
        if isinstance(body, list):
            for child in body:
                if isinstance(child, dict):
                    targets.update(_collect_targets_from_statement(child))

    return targets


def filter_synthetic_signals(signals: set[str]) -> set[str]:
    """Filter out synthetic signal names generated by the converter.

    Synthetic signals include:
    - __next_* (staging signals)
    - __shadow_* (slice aggregation)
    - Bridge signals for interface flattening
    """
    return {
        sig for sig in signals
        if not sig.startswith("__next_")
        and not sig.startswith("__shadow_")
        and not sig.startswith("__bridge_")
    }
