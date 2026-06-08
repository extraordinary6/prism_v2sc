"""Expression complexity metrics for power analysis."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from prism_v2sc.ir.model import ContinuousAssignIR, ModuleIR, ProcessIR


@dataclass(frozen=True)
class ExpressionMetrics:
    """Complexity metrics for an expression."""

    node_count: int  # Total number of nodes in expression tree
    depth: int  # Maximum depth of expression tree
    operator_count: int  # Number of operators
    mux_count: int  # Number of mux/conditional operations
    concat_count: int  # Number of concatenations
    arithmetic_count: int  # Number of arithmetic operations


@dataclass(frozen=True)
class SignalMetrics:
    """Metrics for a signal's associated expressions."""

    signal_name: str
    max_expr_depth: int
    total_node_count: int
    operator_count: int
    mux_count: int
    has_arithmetic: bool


def analyze_expression_metrics(module: ModuleIR) -> dict[str, SignalMetrics]:
    """Analyze expression complexity for all signals in a module.

    Returns a mapping from signal name to its metrics.
    """
    signal_metrics: dict[str, list[ExpressionMetrics]] = {}

    # Analyze continuous assigns
    for assign in module.continuous_assigns:
        targets = _extract_target_names(assign.left, assign.left_expr)
        if targets and assign.right_expr:
            metrics = compute_expression_metrics(assign.right_expr)
            for target in targets:
                if target not in signal_metrics:
                    signal_metrics[target] = []
                signal_metrics[target].append(metrics)

    # Analyze processes
    for process in module.processes:
        _collect_process_metrics(process, signal_metrics)

    # Aggregate metrics per signal
    result: dict[str, SignalMetrics] = {}
    for signal, expr_list in signal_metrics.items():
        result[signal] = SignalMetrics(
            signal_name=signal,
            max_expr_depth=max((m.depth for m in expr_list), default=0),
            total_node_count=sum(m.node_count for m in expr_list),
            operator_count=sum(m.operator_count for m in expr_list),
            mux_count=sum(m.mux_count for m in expr_list),
            has_arithmetic=any(m.arithmetic_count > 0 for m in expr_list),
        )

    return result


def compute_expression_metrics(expr: dict[str, Any] | None) -> ExpressionMetrics:
    """Compute complexity metrics for an expression tree."""
    if not expr or not isinstance(expr, dict):
        return ExpressionMetrics(
            node_count=0,
            depth=0,
            operator_count=0,
            mux_count=0,
            concat_count=0,
            arithmetic_count=0,
        )

    kind = expr.get("kind")
    node_count = 1
    depth = 1
    operator_count = 0
    mux_count = 0
    concat_count = 0
    arithmetic_count = 0

    if kind == "identifier":
        # Leaf node
        return ExpressionMetrics(
            node_count=1,
            depth=1,
            operator_count=0,
            mux_count=0,
            concat_count=0,
            arithmetic_count=0,
        )
    elif kind == "literal":
        # Leaf node
        return ExpressionMetrics(
            node_count=1,
            depth=1,
            operator_count=0,
            mux_count=0,
            concat_count=0,
            arithmetic_count=0,
        )
    elif kind == "binop":
        # Binary operation
        operator_count = 1
        op = str(expr.get("op", ""))
        if op in ("+", "-", "*", "/", "%"):
            arithmetic_count = 1

        left_metrics = compute_expression_metrics(expr.get("left"))
        right_metrics = compute_expression_metrics(expr.get("right"))

        return ExpressionMetrics(
            node_count=1 + left_metrics.node_count + right_metrics.node_count,
            depth=1 + max(left_metrics.depth, right_metrics.depth),
            operator_count=1 + left_metrics.operator_count + right_metrics.operator_count,
            mux_count=left_metrics.mux_count + right_metrics.mux_count,
            concat_count=left_metrics.concat_count + right_metrics.concat_count,
            arithmetic_count=arithmetic_count + left_metrics.arithmetic_count + right_metrics.arithmetic_count,
        )
    elif kind == "unop":
        # Unary operation
        operator_count = 1
        operand_metrics = compute_expression_metrics(expr.get("operand"))

        return ExpressionMetrics(
            node_count=1 + operand_metrics.node_count,
            depth=1 + operand_metrics.depth,
            operator_count=1 + operand_metrics.operator_count,
            mux_count=operand_metrics.mux_count,
            concat_count=operand_metrics.concat_count,
            arithmetic_count=operand_metrics.arithmetic_count,
        )
    elif kind == "cond":
        # Ternary conditional (mux)
        mux_count = 1
        cond_metrics = compute_expression_metrics(expr.get("cond"))
        true_metrics = compute_expression_metrics(expr.get("true"))
        false_metrics = compute_expression_metrics(expr.get("false"))

        return ExpressionMetrics(
            node_count=1 + cond_metrics.node_count + true_metrics.node_count + false_metrics.node_count,
            depth=1 + max(cond_metrics.depth, true_metrics.depth, false_metrics.depth),
            operator_count=cond_metrics.operator_count + true_metrics.operator_count + false_metrics.operator_count,
            mux_count=1 + cond_metrics.mux_count + true_metrics.mux_count + false_metrics.mux_count,
            concat_count=cond_metrics.concat_count + true_metrics.concat_count + false_metrics.concat_count,
            arithmetic_count=cond_metrics.arithmetic_count + true_metrics.arithmetic_count + false_metrics.arithmetic_count,
        )
    elif kind == "concat":
        # Concatenation
        concat_count = 1
        elements = expr.get("parts") or expr.get("elements")
        if isinstance(elements, list):
            child_metrics = [compute_expression_metrics(elem) for elem in elements]
            return ExpressionMetrics(
                node_count=1 + sum(m.node_count for m in child_metrics),
                depth=1 + max((m.depth for m in child_metrics), default=0),
                operator_count=sum(m.operator_count for m in child_metrics),
                mux_count=sum(m.mux_count for m in child_metrics),
                concat_count=1 + sum(m.concat_count for m in child_metrics),
                arithmetic_count=sum(m.arithmetic_count for m in child_metrics),
            )
    elif kind in ("bitselect", "partselect"):
        # Bit/part select
        signal_metrics = compute_expression_metrics(expr.get("target") or expr.get("signal"))
        index_metrics = compute_expression_metrics(expr.get("index"))
        msb_metrics = compute_expression_metrics(expr.get("msb"))
        lsb_metrics = compute_expression_metrics(expr.get("lsb"))

        return ExpressionMetrics(
            node_count=1 + signal_metrics.node_count + index_metrics.node_count + msb_metrics.node_count + lsb_metrics.node_count,
            depth=1 + max(signal_metrics.depth, index_metrics.depth, msb_metrics.depth, lsb_metrics.depth),
            operator_count=signal_metrics.operator_count + index_metrics.operator_count + msb_metrics.operator_count + lsb_metrics.operator_count,
            mux_count=signal_metrics.mux_count + index_metrics.mux_count + msb_metrics.mux_count + lsb_metrics.mux_count,
            concat_count=signal_metrics.concat_count + index_metrics.concat_count + msb_metrics.concat_count + lsb_metrics.concat_count,
            arithmetic_count=signal_metrics.arithmetic_count + index_metrics.arithmetic_count + msb_metrics.arithmetic_count + lsb_metrics.arithmetic_count,
        )
    elif kind == "call":
        # Function call
        args = expr.get("args")
        if isinstance(args, list):
            child_metrics = [compute_expression_metrics(arg) for arg in args]
            return ExpressionMetrics(
                node_count=1 + sum(m.node_count for m in child_metrics),
                depth=1 + max((m.depth for m in child_metrics), default=0),
                operator_count=sum(m.operator_count for m in child_metrics),
                mux_count=sum(m.mux_count for m in child_metrics),
                concat_count=sum(m.concat_count for m in child_metrics),
                arithmetic_count=sum(m.arithmetic_count for m in child_metrics),
            )
    elif kind == "cast":
        # Type cast
        operand_metrics = compute_expression_metrics(expr.get("operand"))
        return ExpressionMetrics(
            node_count=1 + operand_metrics.node_count,
            depth=1 + operand_metrics.depth,
            operator_count=operand_metrics.operator_count,
            mux_count=operand_metrics.mux_count,
            concat_count=operand_metrics.concat_count,
            arithmetic_count=operand_metrics.arithmetic_count,
        )
    elif kind in ("replicate", "repeat"):
        # Replication
        count_metrics = compute_expression_metrics(expr.get("count"))
        value_metrics = compute_expression_metrics(expr.get("value") or expr.get("concat"))
        return ExpressionMetrics(
            node_count=1 + count_metrics.node_count + value_metrics.node_count,
            depth=1 + max(count_metrics.depth, value_metrics.depth),
            operator_count=count_metrics.operator_count + value_metrics.operator_count,
            mux_count=count_metrics.mux_count + value_metrics.mux_count,
            concat_count=count_metrics.concat_count + value_metrics.concat_count,
            arithmetic_count=count_metrics.arithmetic_count + value_metrics.arithmetic_count,
        )

    # Default case
    return ExpressionMetrics(
        node_count=1,
        depth=1,
        operator_count=0,
        mux_count=0,
        concat_count=0,
        arithmetic_count=0,
    )


def _collect_process_metrics(process: ProcessIR, signal_metrics: dict[str, list[ExpressionMetrics]]) -> None:
    """Collect expression metrics from a process."""
    for statement in process.structured_statements:
        _collect_statement_metrics(statement, signal_metrics)


def _collect_statement_metrics(statement: dict[str, Any], signal_metrics: dict[str, list[ExpressionMetrics]]) -> None:
    """Recursively collect metrics from a statement."""
    kind = statement.get("type")

    if kind in ("blocking_assign", "nonblocking_assign"):
        targets = _extract_target_names(
            str(statement.get("left", "")),
            statement.get("left_expr")
        )
        if targets:
            right_expr = statement.get("right_expr")
            if right_expr:
                metrics = compute_expression_metrics(right_expr)
                for target in targets:
                    if target not in signal_metrics:
                        signal_metrics[target] = []
                    signal_metrics[target].append(metrics)
    elif kind == "if":
        # Process both branches
        true_branch = statement.get("true")
        if isinstance(true_branch, list):
            for child in true_branch:
                if isinstance(child, dict):
                    _collect_statement_metrics(child, signal_metrics)

        false_branch = statement.get("false")
        if isinstance(false_branch, list):
            for child in false_branch:
                if isinstance(child, dict):
                    _collect_statement_metrics(child, signal_metrics)
    elif kind == "case":
        # Process all case items
        items = statement.get("items")
        if isinstance(items, list):
            for item in items:
                if isinstance(item, dict):
                    stmts = item.get("statements")
                    if isinstance(stmts, list):
                        for child in stmts:
                            if isinstance(child, dict):
                                _collect_statement_metrics(child, signal_metrics)
    elif kind == "for":
        # Process for loop body
        body = statement.get("body")
        if isinstance(body, list):
            for child in body:
                if isinstance(child, dict):
                    _collect_statement_metrics(child, signal_metrics)


def _extract_target_name(left_text: str, left_expr: dict[str, Any] | None) -> str:
    """Backward-compatible single-target helper."""
    targets = _extract_target_names(left_text, left_expr)
    return next(iter(targets), "")


def _extract_target_names(left_text: str, left_expr: dict[str, Any] | None) -> set[str]:
    """Extract base signal names from an assignment target."""
    if isinstance(left_expr, dict):
        targets = _extract_lvalue_bases(left_expr)
        if targets:
            return targets

    # Fallback to text parsing
    import re
    match = re.match(r"^\s*(?P<name>[A-Za-z_][A-Za-z0-9_$]*)", left_text)
    if match:
        return {match.group("name")}
    return set()


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
