"""Tree-based SystemC expression rendering.

Consumes the structured-expression dicts produced by the frontend
(``frontend.lower._lower_expression`` for the slang path) and emits C++
SystemC source.

The dict tree uses a stable schema so it can round-trip through the IR
JSON dump:

.. code-block:: python

    {"kind": "identifier", "name": "data_i"}
    {"kind": "intconst", "raw": "8'hAA", "value": 170, "width": 8, "base": 16}
    {"kind": "binop", "op": "+", "left": {...}, "right": {...}}
    {"kind": "unop", "op": "!", "operand": {...}}
    {"kind": "cond", "cond": {...}, "true": {...}, "false": {...}}
    {"kind": "concat", "parts": [{...}, ...]}
    {"kind": "assignment_pattern", "elements": [{...}, ...]}
    {"kind": "repeat", "count": {...}, "value": {...}}
    {"kind": "bitselect", "target": {...}, "index": {...}}
    {"kind": "partselect", "target": {...}, "msb": {...}, "lsb": {...}}
    # Packed struct/union member access lowers to bitselect / partselect.
    {"kind": "cast", "signed": True, "width": 8, "operand": {...}}
    {"kind": "syscall", "name": "signed", "args": [{...}]}
    {"kind": "funcall", "name": "add_one", "args": [{...}]}
    {"kind": "raw", "text": "..."}     # safety fallback

When a sub-expression cannot be classified, a ``raw`` node is emitted with
the original Verilog text so codegen can still produce *some* output and
the diagnostic path stays useful.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Any

from prism_v2sc.ir.model import ModuleIR, ParameterIR, PortIR, SignalIR, SubroutineIR, TypeAliasIR


_BINARY_REDUCTION_OPS = {"&", "|", "^", "~&", "~|", "^~", "~^"}

_CPP_BINARY_OP_MAP = {
    "+": "+",
    "-": "-",
    "*": "*",
    "/": "/",
    "%": "%",
    "==": "==",
    "!=": "!=",
    "===": "==",
    "!==": "!=",
    "<": "<",
    ">": ">",
    "<=": "<=",
    ">=": ">=",
    "&&": "&&",
    "||": "||",
    "&": "&",
    "|": "|",
    "^": "^",
    "^~": "^",     # treat ^~ as XNOR; we wrap in ~ below
    "<<": "<<",
    ">>": ">>",
    "<<<": "<<",   # signed shift — approximated
    ">>>": ">>",
    "**": "*",     # rare; approximate
}

_SAFE_CONST_EXPR_RE = re.compile(r"^[\s\d\(\)\+\-\*\/A-Za-z_?:<>=!&|]+$")
_IDENTIFIER_RE = re.compile(r"\b[A-Za-z_][A-Za-z0-9_]*\b")


@dataclass(frozen=True)
class ModuleContext:
    """Names + widths used while rendering a module's expressions to C++."""

    signal_names: frozenset[str]
    parameter_names: frozenset[str]
    signal_widths: dict[str, int]
    parameter_values: dict[str, int]
    signal_signedness: dict[str, bool] = field(default_factory=dict)
    enum_values: dict[str, int] = field(default_factory=dict)
    enum_widths: dict[str, int] = field(default_factory=dict)
    loop_vars: frozenset[str] = field(default_factory=frozenset)
    local_names: frozenset[str] = field(default_factory=frozenset)
    packed_vector_names: frozenset[str] = field(default_factory=frozenset)
    # Signals declared with one or more unpacked dimensions (e.g. memories
    # like ``reg [7:0] mem [0:15]``). Such signals are emitted as a C
    # array of ``sc_signal`` cells, so ``sig[i]`` reads/writes route to
    # ``sig[i].read()`` / ``sig[i].write(...)`` rather than the
    # ``sig.read()[i]`` bit-select form.
    array_signal_names: frozenset[str] = field(default_factory=frozenset)
    array_dimensions: dict[str, tuple[int, ...]] = field(default_factory=dict)
    array_bounds: dict[str, tuple[tuple[int, int], ...]] = field(default_factory=dict)
    # Names emitted as SystemC resolved vectors (top-level ``inout`` ports
    # and internal nets connected to child ``inout`` ports). Reads from
    # these values are converted back to the converter's existing two-state
    # expression domain.
    resolved_names: frozenset[str] = field(default_factory=frozenset)
    compile_friendly: bool = False

    def with_loop_var(self, name: str) -> "ModuleContext":
        return ModuleContext(
            signal_names=self.signal_names,
            parameter_names=self.parameter_names,
            signal_widths=self.signal_widths,
            signal_signedness=self.signal_signedness,
            parameter_values=self.parameter_values,
            enum_values=self.enum_values,
            enum_widths=self.enum_widths,
            loop_vars=frozenset(self.loop_vars | {name}),
            local_names=self.local_names,
            packed_vector_names=self.packed_vector_names,
            array_signal_names=self.array_signal_names,
            array_dimensions=self.array_dimensions,
            array_bounds=self.array_bounds,
            resolved_names=self.resolved_names,
            compile_friendly=self.compile_friendly,
        )

    def with_locals(self, names: frozenset[str]) -> "ModuleContext":
        """Return a context where ``names`` resolve as plain C++ locals.

        Used when rendering function/task bodies: the parameter names and the
        implicit return-value variable (named after the subroutine) are local
        to the emitted method, so they must NOT be rendered as
        ``.read()`` / ``.write()`` on sc_signals.
        """
        return ModuleContext(
            signal_names=self.signal_names,
            parameter_names=self.parameter_names,
            signal_widths=self.signal_widths,
            signal_signedness=self.signal_signedness,
            parameter_values=self.parameter_values,
            enum_values=self.enum_values,
            enum_widths=self.enum_widths,
            loop_vars=self.loop_vars,
            local_names=frozenset(self.local_names | names),
            packed_vector_names=self.packed_vector_names,
            array_signal_names=self.array_signal_names,
            array_dimensions=self.array_dimensions,
            array_bounds=self.array_bounds,
            resolved_names=self.resolved_names,
            compile_friendly=self.compile_friendly,
        )

    def with_subroutine(self, subroutine: SubroutineIR) -> "ModuleContext":
        """Return a context containing function parameters and local variables."""
        local_names = set(self.local_names)
        signal_widths = dict(self.signal_widths)
        signal_signedness = dict(self.signal_signedness)
        array_signal_names = set(self.array_signal_names)
        array_dimensions = dict(self.array_dimensions)
        array_bounds = dict(self.array_bounds)

        def add(name: str, width, signed: bool, unpacked_dims=()) -> None:
            local_names.add(name)
            signal_widths[name] = (
                1
                if width is None
                else _width_from_pair(width.msb, width.lsb, self.parameter_values)
            )
            signal_signedness[name] = signed
            if unpacked_dims:
                array_signal_names.add(name)
                array_dimensions[name] = _array_dim_sizes(unpacked_dims)
                array_bounds[name] = unpacked_dims

        add(subroutine.name, subroutine.return_width, subroutine.return_signed)
        for param in subroutine.params:
            add(param.name, param.width, param.signed)
        for local in subroutine.local_signals:
            add(local.name, local.width, local.signed, local.unpacked_dims)

        return ModuleContext(
            signal_names=self.signal_names,
            parameter_names=self.parameter_names,
            signal_widths=signal_widths,
            signal_signedness=signal_signedness,
            parameter_values=self.parameter_values,
            enum_values=self.enum_values,
            enum_widths=self.enum_widths,
            loop_vars=self.loop_vars,
            local_names=frozenset(local_names),
            packed_vector_names=self.packed_vector_names,
            array_signal_names=frozenset(array_signal_names),
            array_dimensions=array_dimensions,
            array_bounds=array_bounds,
            resolved_names=self.resolved_names,
            compile_friendly=self.compile_friendly,
        )


def build_module_context(
    module: ModuleIR,
    *,
    resolved_names: frozenset[str] | None = None,
    compile_friendly: bool = False,
) -> ModuleContext:
    """Build a width-aware identifier context for one module."""
    signal_names: set[str] = set()
    signal_widths: dict[str, int] = {}
    signal_signedness: dict[str, bool] = {}
    parameter_names: set[str] = set()
    parameter_values: dict[str, int] = {}

    for parameter in module.parameters:
        parameter_names.add(parameter.name)
        const = _eval_text(parameter.value, parameter_values)
        if const is not None:
            parameter_values[parameter.name] = const

    enum_values, enum_widths = _flatten_enum_values(module.type_aliases)

    array_signal_names: set[str] = set()
    packed_vector_names: set[str] = set()
    array_dimensions: dict[str, tuple[int, ...]] = {}
    array_bounds: dict[str, tuple[tuple[int, int], ...]] = {}
    for port in module.ports:
        signal_names.add(port.name)
        signal_widths[port.name] = _port_width(port, parameter_values)
        signal_signedness[port.name] = bool(port.signed)
        if port.width is not None:
            packed_vector_names.add(port.name)
        if getattr(port, "unpacked_dims", ()):
            array_signal_names.add(port.name)
            array_dimensions[port.name] = _array_dim_sizes(port.unpacked_dims)
            array_bounds[port.name] = port.unpacked_dims
    for signal in module.signals:
        signal_names.add(signal.name)
        signal_widths[signal.name] = _signal_width(signal, parameter_values)
        signal_signedness[signal.name] = bool(signal.signed)
        if signal.width is not None:
            packed_vector_names.add(signal.name)
        if getattr(signal, "unpacked_dims", ()):
            array_signal_names.add(signal.name)
            array_dimensions[signal.name] = _array_dim_sizes(signal.unpacked_dims)
            array_bounds[signal.name] = signal.unpacked_dims

    return ModuleContext(
        signal_names=frozenset(signal_names),
        parameter_names=frozenset(parameter_names),
        signal_widths=signal_widths,
        signal_signedness=signal_signedness,
        parameter_values=parameter_values,
        enum_values=enum_values,
        enum_widths=enum_widths,
        packed_vector_names=frozenset(packed_vector_names),
        array_signal_names=frozenset(array_signal_names),
        array_dimensions=array_dimensions,
        array_bounds=array_bounds,
        resolved_names=resolved_names or frozenset(),
        compile_friendly=compile_friendly,
    )


def _flatten_enum_values(type_aliases: tuple[TypeAliasIR, ...]) -> tuple[dict[str, int], dict[str, int]]:
    values: dict[str, int] = {}
    widths: dict[str, int] = {}
    for alias in type_aliases:
        width = _type_alias_width(alias)
        for enum_value in alias.enum_values:
            values[enum_value.name] = enum_value.value
            if width is not None:
                widths[enum_value.name] = width
    return values, widths


def _type_alias_width(alias: TypeAliasIR) -> int | None:
    if alias.width is None:
        return None
    msb = _parse_bound(alias.width.msb)
    lsb = _parse_bound(alias.width.lsb)
    if msb is None or lsb is None:
        return None
    return abs(msb - lsb) + 1


def _array_dim_sizes(dims: tuple[tuple[int, int], ...]) -> tuple[int, ...]:
    return tuple(max(msb, lsb) - min(msb, lsb) + 1 for msb, lsb in dims)


def _render_array_access(
    expr: dict[str, Any],
    ctx: ModuleContext,
    *,
    staged_names: frozenset[str] | None = None,
    as_lvalue: bool,
) -> str | None:
    base, indices = _bitselect_chain(expr)
    if not base or base not in ctx.array_dimensions:
        return None
    dim_count = len(ctx.array_dimensions[base])
    if len(indices) < dim_count:
        return None
    rendered_indices = [render_rvalue(index, ctx, staged_names=staged_names) for index in indices]
    sanitized = sanitize_identifier(base)
    element = sanitized + "".join(f"[{index}]" for index in rendered_indices[:dim_count])
    remaining = rendered_indices[dim_count:]
    if as_lvalue:
        return element + "".join(f"[{index}]" for index in remaining)
    value = f"{element}.read()"
    for index in remaining:
        value = f"{value}[{index}]"
    return value


def _bitselect_chain(expr: dict[str, Any]) -> tuple[str | None, list[dict[str, Any]]]:
    indices: list[dict[str, Any]] = []
    node: dict[str, Any] | None = expr
    while isinstance(node, dict) and node.get("kind") == "bitselect":
        index = node.get("index")
        if not isinstance(index, dict):
            return None, []
        indices.append(index)
        target = node.get("target")
        node = target if isinstance(target, dict) else None
    if isinstance(node, dict) and node.get("kind") == "identifier":
        return str(node.get("name", "")), list(reversed(indices))
    return None, []


def is_array_element_expr(expr: dict[str, Any] | None, ctx: ModuleContext) -> bool:
    if not isinstance(expr, dict):
        return False
    base, indices = _bitselect_chain(expr)
    if not base or base not in ctx.array_dimensions:
        return False
    return len(indices) == len(ctx.array_dimensions[base])


def render_rvalue(expr: dict[str, Any] | None, ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    """Render a structured RHS expression as a C++ rvalue.

    If ``staged_names`` is provided and an identifier is in that set,
    the rvalue reads from ``__next_<name>`` instead of ``<name>.read()``.
    This is used in FF/comb processes where signals are staged.
    """
    if not isinstance(expr, dict):
        return "0"

    kind = expr.get("kind")
    if kind == "identifier":
        return _render_identifier_rvalue(str(expr.get("name", "")), ctx, staged_names=staged_names)
    if kind == "intconst":
        return _format_intconst(expr)
    if kind == "binop":
        op = str(expr.get("op", ""))
        left_node = expr.get("left")
        right_node = expr.get("right")
        left = render_rvalue(left_node, ctx, staged_names=staged_names)
        right = render_rvalue(right_node, ctx, staged_names=staged_names)
        if op in {"==", "!=", "===", "!==", "<", ">", "<=", ">="}:
            left_signed = infer_signed(left_node, ctx)
            right_signed = infer_signed(right_node, ctx)
            if left_signed != right_signed:
                common_width = max(1, infer_width(left_node, ctx), infer_width(right_node, ctx))
                left = _render_type_cast(left_node, left, common_width, False, ctx)
                right = _render_type_cast(right_node, right, common_width, False, ctx)
        cpp_op = _CPP_BINARY_OP_MAP.get(op, op)
        if op in {"/", "%"}:
            # A network of continuous assignments can briefly expose a zero
            # denominator in an intermediate SystemC delta cycle even when
            # the settled RTL expression guards that case. Verilog produces
            # an unknown result for a genuine divide-by-zero; the converter's
            # two-state policy maps that transient/unknown value to zero.
            return f"(({right} == 0) ? 0 : ({left} {cpp_op} {right}))"
        result = f"({left} {cpp_op} {right})"
        if op == "^~":
            result = f"(~{result})"
        return result
    if kind == "unop":
        op = str(expr.get("op", ""))
        operand = expr.get("operand")
        return _render_unop(op, operand, ctx, staged_names=staged_names)
    if kind == "cond":
        cond = render_rvalue(expr.get("cond"), ctx, staged_names=staged_names)
        true_node = expr.get("true")
        false_node = expr.get("false")
        true_branch = render_rvalue(true_node, ctx, staged_names=staged_names)
        false_branch = render_rvalue(false_node, ctx, staged_names=staged_names)
        true_width = infer_width(true_node, ctx)
        false_width = infer_width(false_node, ctx)
        both_signed = infer_signed(true_node, ctx) and infer_signed(false_node, ctx)
        width = max(1, true_width, false_width)
        if width > 1:
            true_branch = _render_type_cast(true_node, true_branch, width, both_signed, ctx)
            false_branch = _render_type_cast(false_node, false_branch, width, both_signed, ctx)
        return f"({cond} ? {true_branch} : {false_branch})"
    if kind == "concat":
        return _render_concat(expr.get("parts", []), ctx, staged_names=staged_names)
    if kind == "repeat":
        return _render_repeat(expr.get("count"), expr.get("value"), ctx, staged_names=staged_names)
    if kind == "bitselect":
        array_access = _render_array_access(expr, ctx, staged_names=staged_names, as_lvalue=False)
        if array_access is not None:
            return array_access
        target = expr.get("target")
        if isinstance(target, dict) and target.get("kind") == "identifier":
            target_name = str(target.get("name", ""))
            if target_name in ctx.array_signal_names:
                # Array cell read: ``mem[i].read()`` rather than the
                # vector bit-select ``mem.read()[i]``.
                index_str = render_rvalue(expr.get("index"), ctx, staged_names=staged_names)
                return f"{sanitize_identifier(target_name)}[{index_str}].read()"
            if target_name in ctx.parameter_names:
                index_str = render_rvalue(expr.get("index"), ctx, staged_names=staged_names)
                return f"(({sanitize_identifier(target_name)} >> ({index_str})) & 1)"
        target_str = _render_aggregate_rvalue(expr.get("target"), ctx, staged_names=staged_names)
        index_str = render_rvalue(expr.get("index"), ctx, staged_names=staged_names)
        return f"{target_str}[{index_str}]"
    if kind == "partselect":
        target_node = expr.get("target")
        target_str = _render_aggregate_rvalue(target_node, ctx, staged_names=staged_names)
        if isinstance(target_node, dict) and target_node.get("kind") == "identifier":
            target_name = str(target_node.get("name", ""))
            if target_name in ctx.parameter_names:
                lsb = render_rvalue(expr.get("lsb"), ctx, staged_names=staged_names)
                width = max(1, infer_width(expr, ctx))
                return f"{systemc_int_type(width)}({sanitize_identifier(target_name)} >> ({lsb}))"
        if isinstance(target_node, dict) and target_node.get("kind") == "intconst":
            target_width = max(1, infer_width(target_node, ctx), infer_width(expr, ctx))
            target_str = f"{systemc_int_type(target_width)}({target_str})"
        msb = render_rvalue(expr.get("msb"), ctx, staged_names=staged_names)
        lsb = render_rvalue(expr.get("lsb"), ctx, staged_names=staged_names)
        width = max(1, infer_width(expr, ctx))
        return f"{systemc_int_type(width)}({target_str}.range({msb}, {lsb}))"
    if kind == "cast":
        return _render_cast(expr, ctx, staged_names=staged_names)
    if kind == "syscall":
        return _render_syscall(expr, ctx, staged_names=staged_names)
    if kind == "funcall":
        name = sanitize_identifier(str(expr.get("name", "")))
        args = [render_rvalue(arg, ctx, staged_names=staged_names) for arg in expr.get("args", []) if isinstance(arg, dict)]
        return f"{name}({', '.join(args)})"
    if kind == "raw":
        text = str(expr.get("text", ""))
        return f"/* raw: {text} */ 0"
    return f"/* unsupported expr: {kind} */ 0"


def render_lvalue(expr: dict[str, Any] | None, ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    """Render an LHS expression as a C++ assignable target.

    If ``staged_names`` is provided and the base identifier is in that set,
    the lvalue is rebased onto ``__next_<name>`` for FF/comb staging.
    """
    if not isinstance(expr, dict):
        return "/* lvalue */"

    kind = expr.get("kind")
    if kind == "identifier":
        name = str(expr.get("name", ""))
        sanitized = sanitize_identifier(name)
        if staged_names is not None and name in staged_names:
            return f"__next_{sanitized}"
        return sanitized
    if kind == "bitselect":
        array_access = _render_array_access(expr, ctx, staged_names=staged_names, as_lvalue=True)
        if array_access is not None:
            return array_access
        target = render_lvalue(expr.get("target"), ctx, staged_names=staged_names)
        idx = render_rvalue(expr.get("index"), ctx)
        return f"{target}[{idx}]"
    if kind == "partselect":
        target = render_lvalue(expr.get("target"), ctx, staged_names=staged_names)
        msb = render_rvalue(expr.get("msb"), ctx)
        lsb = render_rvalue(expr.get("lsb"), ctx)
        return f"{target}.range({msb}, {lsb})"
    return "/* unsupported lvalue */"


def lvalue_base_name(expr: dict[str, Any] | None) -> str:
    """Return the base identifier driven by an lvalue (e.g., ``q`` for ``q[3:0]``)."""
    if not isinstance(expr, dict):
        return ""
    kind = expr.get("kind")
    if kind == "identifier":
        return str(expr.get("name", ""))
    if kind in {"bitselect", "partselect"}:
        return lvalue_base_name(expr.get("target"))
    return ""


def collect_sensitivity(expr: dict[str, Any] | None, ctx: ModuleContext) -> list[str]:
    """Return de-duplicated sanitized signal names referenced by an rvalue tree.

    Identifiers that resolve to parameters or loop variables are skipped, so
    sized literals like ``8'hAA`` no longer poison the sensitivity list with
    phantom base-prefix tokens.
    """
    seen: set[str] = set()
    ordered: list[str] = []

    def walk(node: dict[str, Any] | None) -> None:
        if not isinstance(node, dict):
            return
        kind = node.get("kind")
        if kind == "identifier":
            name = str(node.get("name", ""))
            if not name:
                return
            if name in ctx.enum_values:
                return
            if name in ctx.parameter_names or name in ctx.loop_vars:
                return
            if name not in ctx.signal_names:
                return
            sanitized = sanitize_identifier(name)
            if sanitized not in seen:
                seen.add(sanitized)
                ordered.append(sanitized)
            return
        for key in ("target", "operand", "value", "cond", "true", "false", "left", "right", "msb", "lsb", "index", "count"):
            walk(node.get(key))
        for key in ("parts", "args", "elements"):
            children = node.get(key)
            if isinstance(children, list):
                for child in children:
                    walk(child)

    walk(expr)
    return ordered


def infer_width(expr: dict[str, Any] | None, ctx: ModuleContext) -> int:
    """Best-effort width inference for an expression."""
    if not isinstance(expr, dict):
        return 1
    kind = expr.get("kind")
    if kind == "intconst":
        width = expr.get("width")
        if isinstance(width, int) and width > 0:
            return width
        value = expr.get("value", 0) or 0
        if value > 0:
            return max(1, value.bit_length())
        return 1
    if kind == "identifier":
        name = str(expr.get("name", ""))
        if name in ctx.enum_widths:
            return max(1, ctx.enum_widths[name])
        if name in ctx.enum_values:
            return max(1, ctx.enum_widths.get(name, 1))
        return max(1, ctx.signal_widths.get(name, 1))
    if kind == "bitselect":
        base, indices = _bitselect_chain(expr)
        if base in ctx.array_dimensions and len(indices) == len(ctx.array_dimensions[base]):
            return max(1, ctx.signal_widths.get(base, 1))
        return 1
    if kind == "partselect":
        width = expr.get("width")
        if isinstance(width, int) and width > 0:
            return width
        msb = const_eval(expr.get("msb"), ctx)
        lsb = const_eval(expr.get("lsb"), ctx)
        if msb is not None and lsb is not None:
            return abs(msb - lsb) + 1
        return 1
    if kind == "concat":
        return max(1, sum(infer_width(part, ctx) for part in expr.get("parts", [])))
    if kind == "repeat":
        count = const_eval(expr.get("count"), ctx) or 1
        return max(1, count * infer_width(expr.get("value"), ctx))
    if kind == "cast":
        width = expr.get("width")
        if isinstance(width, int) and width > 0:
            return width
        return infer_width(expr.get("operand"), ctx)
    if kind == "binop":
        op = str(expr.get("op", ""))
        if op in {"==", "!=", "===", "!==", "<", ">", "<=", ">=", "&&", "||"}:
            return 1
        return max(infer_width(expr.get("left"), ctx), infer_width(expr.get("right"), ctx))
    if kind == "unop":
        op = str(expr.get("op", ""))
        if op in {"!"} or op in {"&", "|", "^", "~&", "~|", "^~", "~^"}:
            # logical / reduction → 1 bit
            return 1
        return infer_width(expr.get("operand"), ctx)
    if kind == "cond":
        return max(infer_width(expr.get("true"), ctx), infer_width(expr.get("false"), ctx))
    return 1


def systemc_int_type(width: int, signed: bool = False) -> str:
    """Return the SystemC integer type for a concrete packed width."""
    width = max(1, int(width))
    if width > 64:
        return f"sc_{'bigint' if signed else 'biguint'}<{width}>"
    return f"sc_{'int' if signed else 'uint'}<{width}>"


def _cond_branch_needs_unsized_cast(
    true_node: dict[str, Any] | None,
    false_node: dict[str, Any] | None,
) -> bool:
    """C++ needs help when one ternary branch is an unsized SV integer."""
    return _is_unsized_intconst(true_node) != _is_unsized_intconst(false_node)


def _is_unsized_intconst(expr: dict[str, Any] | None) -> bool:
    if not isinstance(expr, dict) or expr.get("kind") != "intconst":
        return False
    raw = str(expr.get("raw", ""))
    return "'" not in raw


def infer_signed(expr: dict[str, Any] | None, ctx: ModuleContext) -> bool:
    """Best-effort signedness inference for expression codegen.

    This intentionally stays conservative. It is used to avoid C++ conditional
    operator ambiguity in signed ternaries, not to claim complete SV type
    propagation.
    """
    if not isinstance(expr, dict):
        return False
    kind = expr.get("kind")
    if kind == "intconst":
        return bool(expr.get("signed"))
    if kind == "identifier":
        name = str(expr.get("name", ""))
        return bool(ctx.signal_signedness.get(name, False))
    if kind in {"bitselect", "partselect", "concat", "repeat"}:
        return False
    if kind == "cast":
        return bool(expr.get("signed"))
    if kind == "syscall":
        name = str(expr.get("name", ""))
        if name == "signed":
            return True
        if name == "unsigned":
            return False
        return False
    if kind == "unop":
        op = str(expr.get("op", ""))
        if op in {"!", "&", "|", "^", "~&", "~|", "^~", "~^"}:
            return False
        return infer_signed(expr.get("operand"), ctx)
    if kind == "binop":
        op = str(expr.get("op", ""))
        if op in {"==", "!=", "===", "!==", "<", ">", "<=", ">=", "&&", "||"}:
            return False
        if op in {"<<", ">>", "<<<", ">>>"}:
            return infer_signed(expr.get("left"), ctx)
        return infer_signed(expr.get("left"), ctx) and infer_signed(expr.get("right"), ctx)
    if kind == "cond":
        return infer_signed(expr.get("true"), ctx) and infer_signed(expr.get("false"), ctx)
    return False


def const_eval(expr: dict[str, Any] | None, ctx: ModuleContext) -> int | None:
    """Best-effort constant folding for widths/indices."""
    if not isinstance(expr, dict):
        return None
    kind = expr.get("kind")
    if kind == "intconst":
        value = expr.get("value")
        return int(value) if isinstance(value, int) else None
    if kind == "identifier":
        name = str(expr.get("name", ""))
        if name in ctx.enum_values:
            return ctx.enum_values[name]
        return ctx.parameter_values.get(name)
    if kind == "binop":
        left = const_eval(expr.get("left"), ctx)
        right = const_eval(expr.get("right"), ctx)
        if left is None or right is None:
            return None
        op = expr.get("op")
        try:
            if op == "+":
                return left + right
            if op == "-":
                return left - right
            if op == "*":
                return left * right
            if op == "/":
                return left // right if right else None
            if op == "%":
                return left % right if right else None
            if op == "<<":
                return left << right
            if op == ">>":
                return left >> right
            if op == "&":
                return left & right
            if op == "|":
                return left | right
            if op == "^":
                return left ^ right
            if op == "==":
                return int(left == right)
            if op == "!=":
                return int(left != right)
            if op == "<":
                return int(left < right)
            if op == ">":
                return int(left > right)
            if op == "<=":
                return int(left <= right)
            if op == ">=":
                return int(left >= right)
            if op == "&&":
                return int(bool(left) and bool(right))
            if op == "||":
                return int(bool(left) or bool(right))
        except Exception:
            return None
        return None
    if kind == "unop":
        operand = const_eval(expr.get("operand"), ctx)
        if operand is None:
            return None
        op = expr.get("op")
        if op == "-":
            return -operand
        if op == "+":
            return operand
        if op == "!":
            return int(not operand)
        if op == "~":
            return ~operand
        return None
    if kind == "cond":
        cond = const_eval(expr.get("cond"), ctx)
        if cond is None:
            return None
        return const_eval(expr.get("true" if cond else "false"), ctx)
    if kind == "concat":
        parts = expr.get("parts", [])
        if not isinstance(parts, list) or not parts:
            return None
        widths = [max(1, infer_width(part, ctx)) for part in parts]
        return _fold_concat_constant(parts, widths, ctx)
    if kind == "repeat":
        count = const_eval(expr.get("count"), ctx)
        value_node = expr.get("value")
        value = const_eval(value_node, ctx)
        if count is None or value is None:
            return None
        if count <= 0:
            count = 1
        width = max(1, infer_width(value_node, ctx))
        chunk = value & ((1 << width) - 1)
        repeated = 0
        for _ in range(count):
            repeated = (repeated << width) | chunk
        return repeated
    if kind == "cast":
        return const_eval(expr.get("operand"), ctx)
    return None


def sanitize_identifier(name: str) -> str:
    cleaned = re.sub(r"\W", "_", name or "")
    if not cleaned:
        return "unnamed"
    if cleaned[0].isdigit():
        return f"_{cleaned}"
    return cleaned


def _render_identifier_rvalue(name: str, ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    sanitized = sanitize_identifier(name)
    if name in ctx.local_names:
        return sanitized
    if name in ctx.loop_vars:
        return sanitized
    if name in ctx.enum_values:
        return str(ctx.enum_values[name])
    if name in ctx.parameter_names:
        return sanitized
    if name in ctx.signal_names:
        # If this signal is staged, read from __next_ instead of .read()
        if staged_names is not None and name in staged_names:
            return f"__next_{sanitized}"
        if name in ctx.resolved_names:
            width = max(1, ctx.signal_widths.get(name, 1))
            if width == 1:
                return f"({sanitized}.read()[0] == sc_dt::SC_LOGIC_1)"
            return f"sc_uint<{width}>({sanitized}.read().to_uint64())"
        return f"{sanitized}.read()"
    return sanitized


def _render_aggregate_rvalue(node: dict[str, Any] | None, ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    """Render an aggregate target (used as the base of bit/part-select).

    For a top-level identifier we use ``name.read()``; for nested aggregates
    we render through the regular rvalue path.
    """
    if isinstance(node, dict) and node.get("kind") == "identifier":
        return _render_identifier_rvalue(str(node.get("name", "")), ctx, staged_names=staged_names)
    return render_rvalue(node, ctx, staged_names=staged_names)


def _is_definitely_one_bit(expr: dict[str, Any] | None, ctx: ModuleContext) -> bool:
    """True only when the operand is provably 1-bit.

    Used to gate Verilog-``~`` → C++-``!`` rewriting. Unknown widths must
    return False so we keep ``~`` (the only safe fallback for multi-bit
    bitwise inversion). ``infer_width`` cannot answer this on its own
    because it conflates "unknown identifier" with "width 1".
    """
    if not isinstance(expr, dict):
        return False
    kind = expr.get("kind")
    if kind == "intconst":
        width = expr.get("width")
        return isinstance(width, int) and width == 1
    if kind == "identifier":
        name = str(expr.get("name", ""))
        width = ctx.signal_widths.get(name)
        return isinstance(width, int) and width == 1
    if kind == "bitselect":
        return True
    if kind == "partselect":
        msb = const_eval(expr.get("msb"), ctx)
        lsb = const_eval(expr.get("lsb"), ctx)
        return msb is not None and lsb is not None and msb == lsb
    if kind == "unop":
        op = str(expr.get("op", ""))
        # ``!`` and reduction operators always yield 1 bit; ``~`` and ``-``
        # preserve operand width.
        if op in {"!", "&", "|", "^", "~&", "~|", "^~", "~^"}:
            return True
        if op in {"~", "-", "+"}:
            return _is_definitely_one_bit(expr.get("operand"), ctx)
        return False
    if kind == "binop":
        op = str(expr.get("op", ""))
        if op in {"==", "!=", "===", "!==", "<", ">", "<=", ">=", "&&", "||"}:
            return True
        return _is_definitely_one_bit(expr.get("left"), ctx) and _is_definitely_one_bit(
            expr.get("right"), ctx
        )
    if kind == "cond":
        return _is_definitely_one_bit(expr.get("true"), ctx) and _is_definitely_one_bit(
            expr.get("false"), ctx
        )
    return False


def _render_unop(op: str, operand_node: dict[str, Any] | None, ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    operand_text = render_rvalue(operand_node, ctx, staged_names=staged_names)
    if op == "!":
        return f"(!{operand_text})"
    if op == "~":
        # On a bool/sc_uint<1> operand, C++'s ``~`` widens to int and inverts
        # all the int bits, so ``~true`` is -2 and ``~false`` is -1 — both
        # round-trip back to ``true``. Verilog ``~`` on a 1-bit signal is
        # logical inversion, so emit ``!`` instead, but only when we can
        # *prove* the operand is 1-bit. ``infer_width`` falls back to 1 for
        # unknown identifiers (e.g. function-local params), so a width==1
        # answer there would be ambiguous and we must keep ``~``.
        if _is_definitely_one_bit(operand_node, ctx):
            return f"(!{operand_text})"
        width = infer_width(operand_node, ctx)
        if width > 1:
            value_type = systemc_int_type(width)
            normalized = _render_type_cast(operand_node, operand_text, width, False, ctx)
            return f"{value_type}(~{normalized})"
        return f"(~{operand_text})"
    if op == "-":
        return f"(-{operand_text})"
    if op == "+":
        return f"(+{operand_text})"
    reduction_width = max(1, infer_width(operand_node, ctx))
    reduction_operand = _render_type_cast(
        operand_node,
        operand_text,
        reduction_width,
        False,
        ctx,
    )
    if op == "&":
        return f"{reduction_operand}.and_reduce()"
    if op == "|":
        return f"{reduction_operand}.or_reduce()"
    if op == "^":
        return f"{reduction_operand}.xor_reduce()"
    if op == "~&":
        return f"(!({reduction_operand}.and_reduce()))"
    if op == "~|":
        return f"(!({reduction_operand}.or_reduce()))"
    if op in {"^~", "~^"}:
        return f"(!({reduction_operand}.xor_reduce()))"
    return f"({op}{operand_text})"


def _render_concat(parts: list[dict[str, Any]], ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    if not parts:
        return "0"
    if len(parts) == 1:
        return render_rvalue(parts[0], ctx, staged_names=staged_names)
    widths = [max(1, infer_width(part, ctx)) for part in parts]
    total = sum(widths)
    if total <= 0:
        total = 1
    target_type = systemc_int_type(total)
    constant = _fold_concat_constant(parts, widths, ctx)
    if constant is not None:
        return _render_unsigned_constant(constant, total)
    pieces: list[str] = []
    bits_remaining = total
    for part, width in zip(parts, widths):
        bits_remaining -= width
        operand = render_rvalue(part, ctx, staged_names=staged_names)
        if bits_remaining > 0:
            pieces.append(f"({target_type}({operand}) << {bits_remaining})")
        else:
            pieces.append(f"{target_type}({operand})")
    return f"{target_type}((" + " | ".join(pieces) + "))"


def _render_repeat(count_node: dict[str, Any] | None, value_node: dict[str, Any] | None, ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    count = const_eval(count_node, ctx) or 0
    if count <= 0:
        count = 1
    width = max(1, infer_width(value_node, ctx))
    total = count * width
    if total <= 0:
        total = 1
    target_type = systemc_int_type(total)
    value = const_eval(value_node, ctx)
    if value is not None:
        mask = (1 << width) - 1
        repeated = 0
        chunk = value & mask
        for _ in range(count):
            repeated = (repeated << width) | chunk
        return _render_unsigned_constant(repeated, total)
    operand = render_rvalue(value_node, ctx, staged_names=staged_names)
    pieces: list[str] = []
    for i in range(count):
        shift = (count - 1 - i) * width
        if shift > 0:
            pieces.append(f"({target_type}({operand}) << {shift})")
        else:
            pieces.append(f"{target_type}({operand})")
    return f"{target_type}((" + " | ".join(pieces) + "))"


def _fold_concat_constant(
    parts: list[dict[str, Any]],
    widths: list[int],
    ctx: ModuleContext,
) -> int | None:
    value = 0
    for part, width in zip(parts, widths):
        part_value = const_eval(part, ctx)
        if part_value is None:
            return None
        value = (value << width) | (part_value & ((1 << width) - 1))
    return value


def _render_unsigned_constant(value: int, width: int) -> str:
    width = max(1, width)
    value &= (1 << width) - 1
    target_type = systemc_int_type(width)
    if width > 64:
        return f'{target_type}("0x{value:x}")'
    if value > (1 << 63) - 1:
        # Unsuffixed decimal literals above INT64_MAX are commonly typed as
        # ``__int128`` by GCC, for which sc_uint has no unambiguous ctor.
        return f"{target_type}(0x{value:X}ULL)"
    return f"{target_type}({value})"


def _render_cast(expr: dict[str, Any], ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    width = expr.get("width")
    if not isinstance(width, int) or width <= 0:
        width = infer_width(expr.get("operand"), ctx)
    signed = bool(expr.get("signed"))
    operand_node = expr.get("operand")
    operand = render_rvalue(operand_node, ctx, staged_names=staged_names)
    return _render_type_cast(operand_node, operand, width, signed, ctx)


def _render_syscall(expr: dict[str, Any], ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    name = str(expr.get("name", ""))
    args_nodes = expr.get("args", []) or []
    args = [render_rvalue(arg, ctx, staged_names=staged_names) for arg in args_nodes]
    if name in {"signed", "unsigned"} and args:
        # ``$signed`` and ``$unsigned`` change the type of an expression for
        # operations that care about sign — most importantly ``>>>``, which
        # arithmetic-shifts iff its LHS is signed. Treating them as no-ops
        # silently turns ``$signed(x) >>> n`` into a logical shift on the
        # underlying unsigned representation.
        width = infer_width(args_nodes[0], ctx) if args_nodes else 1
        return _render_type_cast(
            args_nodes[0],
            args[0],
            width,
            name == "signed",
            ctx,
        )
    return f"/* $${name}() unsupported */ 0"


def _render_type_cast(
    expr: dict[str, Any] | None,
    rendered: str,
    width: int,
    signed: bool,
    ctx: ModuleContext,
) -> str:
    """Emit one SystemC cast, omitting it only when the source type is exact."""
    width = max(1, int(width))
    if ctx.compile_friendly and _has_exact_systemc_type(expr, width, signed, ctx):
        return rendered
    return f"{systemc_int_type(width, signed=signed)}({rendered})"


def _has_exact_systemc_type(
    expr: dict[str, Any] | None,
    width: int,
    signed: bool,
    ctx: ModuleContext,
) -> bool:
    if not isinstance(expr, dict):
        return False
    kind = expr.get("kind")
    if kind == "cast":
        cast_width = expr.get("width")
        if not isinstance(cast_width, int) or cast_width <= 0:
            cast_width = infer_width(expr.get("operand"), ctx)
        return cast_width == width and bool(expr.get("signed")) == signed
    if kind == "identifier":
        name = str(expr.get("name", ""))
        if ctx.signal_widths.get(name) != width or bool(ctx.signal_signedness.get(name, False)) != signed:
            return False
        return width > 1 or name in ctx.packed_vector_names
    if kind == "bitselect" and is_array_element_expr(expr, ctx):
        base, _indices = _bitselect_chain(expr)
        if ctx.signal_widths.get(base) != width or bool(ctx.signal_signedness.get(base, False)) != signed:
            return False
        return width > 1 or base in ctx.packed_vector_names
    if kind == "partselect":
        return infer_width(expr, ctx) == width and not signed
    if kind == "syscall" and expr.get("name") in {"signed", "unsigned"}:
        return infer_width(expr, ctx) == width and (expr.get("name") == "signed") == signed
    return False


def _format_intconst(expr: dict[str, Any]) -> str:
    if expr.get("has_xz"):
        return "0"
    width = expr.get("width")
    width_int = width if isinstance(width, int) and width > 0 else None
    if width_int is not None and width_int > 64:
        return _format_wide_intconst(expr, width_int)
    if expr.get("signed"):
        signed_value = expr.get("signed_value")
        if isinstance(signed_value, int):
            return str(signed_value)
    digits = expr.get("digits")
    base = expr.get("base", 10)
    if isinstance(digits, str) and digits:
        if base == 16:
            return f"0x{digits}"
        if base == 2:
            return f"0b{digits}"
        if base == 8:
            return f"0{digits}"
        value = expr.get("value", 0)
        return str(value) if isinstance(value, int) else "0"
    value = expr.get("value", 0)
    if not isinstance(value, int):
        return "0"
    if base == 16:
        return f"0x{value:X}" if value > 0 else "0x0"
    if base == 2:
        return f"0b{value:b}" if value > 0 else "0b0"
    if base == 8:
        return f"0{value:o}" if value > 0 else "0"
    return str(value)


def _format_wide_intconst(expr: dict[str, Any], width: int) -> str:
    target_type = systemc_int_type(width, signed=bool(expr.get("signed")))
    digits = expr.get("digits")
    base = expr.get("base", 10)
    if isinstance(digits, str) and digits:
        if base == 16:
            literal = f"0x{digits}"
        elif base == 2:
            literal = f"0b{digits}"
        elif base == 8:
            literal = f"0{digits}"
        else:
            literal = digits
    else:
        value = expr.get("value", 0)
        literal = str(value if isinstance(value, int) else 0)
    escaped = literal.replace("\\", "\\\\").replace('"', '\\"')
    return f'{target_type}("{escaped}")'


def _parse_const_literal(text: str) -> int | None:
    if not text:
        return None
    cleaned = text.strip().replace("_", "")
    sized = re.match(r"^(?P<size>\d+)?\s*'\s*(?P<base>[bodhBODH])(?P<value>[0-9a-fA-F]+)$", cleaned)
    unsized = re.match(r"^'\s*(?P<base>[bodhBODH])(?P<value>[0-9a-fA-F]+)$", cleaned)
    bases = {"b": 2, "o": 8, "d": 10, "h": 16}
    if sized:
        try:
            return int(sized.group("value"), bases[sized.group("base").lower()])
        except ValueError:
            return None
    if unsized:
        try:
            return int(unsized.group("value"), bases[unsized.group("base").lower()])
        except ValueError:
            return None
    try:
        return int(cleaned)
    except ValueError:
        return None


def _parse_bound(text: str) -> int | None:
    value = _parse_const_literal(text)
    if value is not None:
        return value
    try:
        return int((text or "").strip())
    except ValueError:
        return None


def _port_width(port: PortIR, parameter_values: dict[str, int]) -> int:
    if port.width is None:
        return 1
    return _width_from_pair(port.width.msb, port.width.lsb, parameter_values)


def _signal_width(signal: SignalIR, parameter_values: dict[str, int]) -> int:
    if signal.width is None:
        return 1
    return _width_from_pair(signal.width.msb, signal.width.lsb, parameter_values)


def _width_from_pair(msb_text: str, lsb_text: str, parameter_values: dict[str, int]) -> int:
    msb = _eval_text(msb_text, parameter_values)
    lsb = _eval_text(lsb_text, parameter_values)
    if msb is None or lsb is None:
        return 1
    return abs(msb - lsb) + 1


def _eval_text(text: str, parameter_values: dict[str, int]) -> int | None:
    text = (text or "").strip()
    if not text:
        return None
    previous = None
    while previous != text:
        previous = text
        text = re.sub(r"\{\s*([^,{}]+)\s*\}", r"(\1)", text)
    try:
        return int(text)
    except ValueError:
        pass
    direct = _parse_const_literal(text)
    if direct is not None:
        return direct
    # Tiny expression evaluator for things like "(WIDTH - 1)".
    if _SAFE_CONST_EXPR_RE.fullmatch(text) is None:
        return None
    expr = _IDENTIFIER_RE.sub(
        lambda match: str(parameter_values.get(match.group(0), 0)),
        text,
    )
    expr = _translate_const_ternary(expr)
    expr = expr.replace("&&", " and ").replace("||", " or ")
    expr = re.sub(r"!(?!=)", " not ", expr)
    try:
        return int(eval(expr, {"__builtins__": {}}, {}))  # noqa: S307 - sanitized above
    except Exception:
        return None


def _translate_const_ternary(text: str) -> str:
    """Translate balanced C/Verilog ``cond ? a : b`` into Python syntax."""
    stripped = _strip_balanced_outer_parentheses(text.strip())
    question = _find_top_level_token(stripped, "?")
    if question is None:
        return stripped
    colon = _matching_ternary_colon(stripped, question)
    if colon is None:
        return stripped
    cond = _translate_const_ternary(stripped[:question])
    true_value = _translate_const_ternary(stripped[question + 1 : colon])
    false_value = _translate_const_ternary(stripped[colon + 1 :])
    return f"(({true_value}) if ({cond}) else ({false_value}))"


def _strip_balanced_outer_parentheses(text: str) -> str:
    while text.startswith("(") and text.endswith(")"):
        depth = 0
        balanced = True
        for index, char in enumerate(text):
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0 and index != len(text) - 1:
                    balanced = False
                    break
            if depth < 0:
                balanced = False
                break
        if not balanced or depth != 0:
            break
        text = text[1:-1].strip()
    return text


def _find_top_level_token(text: str, token: str) -> int | None:
    depth = 0
    for index, char in enumerate(text):
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
        elif char == token and depth == 0:
            return index
    return None


def _matching_ternary_colon(text: str, question: int) -> int | None:
    depth = 0
    nested = 0
    for index in range(question + 1, len(text)):
        char = text[index]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
        elif depth == 0 and char == "?":
            nested += 1
        elif depth == 0 and char == ":":
            if nested == 0:
                return index
            nested -= 1
    return None
