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
    {"kind": "repeat", "count": {...}, "value": {...}}
    {"kind": "bitselect", "target": {...}, "index": {...}}
    {"kind": "partselect", "target": {...}, "msb": {...}, "lsb": {...}}
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

from prism_v2sc.ir.model import ModuleIR, ParameterIR, PortIR, SignalIR


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


@dataclass(frozen=True)
class ModuleContext:
    """Names + widths used while rendering a module's expressions to C++."""

    signal_names: frozenset[str]
    parameter_names: frozenset[str]
    signal_widths: dict[str, int]
    parameter_values: dict[str, int]
    loop_vars: frozenset[str] = field(default_factory=frozenset)
    local_names: frozenset[str] = field(default_factory=frozenset)

    def with_loop_var(self, name: str) -> "ModuleContext":
        return ModuleContext(
            signal_names=self.signal_names,
            parameter_names=self.parameter_names,
            signal_widths=self.signal_widths,
            parameter_values=self.parameter_values,
            loop_vars=frozenset(self.loop_vars | {name}),
            local_names=self.local_names,
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
            parameter_values=self.parameter_values,
            loop_vars=self.loop_vars,
            local_names=frozenset(self.local_names | names),
        )


def build_module_context(module: ModuleIR) -> ModuleContext:
    """Build a width-aware identifier context for one module."""
    signal_names: set[str] = set()
    signal_widths: dict[str, int] = {}
    parameter_names: set[str] = set()
    parameter_values: dict[str, int] = {}

    for parameter in module.parameters:
        parameter_names.add(parameter.name)
        const = _parse_const_literal(parameter.value)
        if const is not None:
            parameter_values[parameter.name] = const

    for port in module.ports:
        signal_names.add(port.name)
        signal_widths[port.name] = _port_width(port, parameter_values)
    for signal in module.signals:
        signal_names.add(signal.name)
        signal_widths[signal.name] = _signal_width(signal, parameter_values)

    return ModuleContext(
        signal_names=frozenset(signal_names),
        parameter_names=frozenset(parameter_names),
        signal_widths=signal_widths,
        parameter_values=parameter_values,
    )


def render_rvalue(expr: dict[str, Any] | None, ctx: ModuleContext) -> str:
    """Render a structured RHS expression as a C++ rvalue."""
    if not isinstance(expr, dict):
        return "0"

    kind = expr.get("kind")
    if kind == "identifier":
        return _render_identifier_rvalue(str(expr.get("name", "")), ctx)
    if kind == "intconst":
        return _format_intconst(expr)
    if kind == "binop":
        op = str(expr.get("op", ""))
        left = render_rvalue(expr.get("left"), ctx)
        right = render_rvalue(expr.get("right"), ctx)
        cpp_op = _CPP_BINARY_OP_MAP.get(op, op)
        result = f"({left} {cpp_op} {right})"
        if op == "^~":
            result = f"(~{result})"
        return result
    if kind == "unop":
        op = str(expr.get("op", ""))
        operand = expr.get("operand")
        return _render_unop(op, operand, ctx)
    if kind == "cond":
        cond = render_rvalue(expr.get("cond"), ctx)
        true_branch = render_rvalue(expr.get("true"), ctx)
        false_branch = render_rvalue(expr.get("false"), ctx)
        return f"({cond} ? {true_branch} : {false_branch})"
    if kind == "concat":
        return _render_concat(expr.get("parts", []), ctx)
    if kind == "repeat":
        return _render_repeat(expr.get("count"), expr.get("value"), ctx)
    if kind == "bitselect":
        target_str = _render_aggregate_rvalue(expr.get("target"), ctx)
        index_str = render_rvalue(expr.get("index"), ctx)
        return f"{target_str}[{index_str}]"
    if kind == "partselect":
        target_str = _render_aggregate_rvalue(expr.get("target"), ctx)
        msb = render_rvalue(expr.get("msb"), ctx)
        lsb = render_rvalue(expr.get("lsb"), ctx)
        return f"{target_str}.range({msb}, {lsb})"
    if kind == "syscall":
        return _render_syscall(expr, ctx)
    if kind == "funcall":
        name = sanitize_identifier(str(expr.get("name", "")))
        args = [render_rvalue(arg, ctx) for arg in expr.get("args", []) if isinstance(arg, dict)]
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
        for key in ("parts", "args"):
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
        return max(1, ctx.signal_widths.get(name, 1))
    if kind == "bitselect":
        return 1
    if kind == "partselect":
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
    return None


def sanitize_identifier(name: str) -> str:
    cleaned = re.sub(r"\W", "_", name or "")
    if not cleaned:
        return "unnamed"
    if cleaned[0].isdigit():
        return f"_{cleaned}"
    return cleaned


def _render_identifier_rvalue(name: str, ctx: ModuleContext) -> str:
    sanitized = sanitize_identifier(name)
    if name in ctx.local_names:
        return sanitized
    if name in ctx.loop_vars:
        return sanitized
    if name in ctx.parameter_names:
        return sanitized
    if name in ctx.signal_names:
        return f"{sanitized}.read()"
    return sanitized


def _render_aggregate_rvalue(node: dict[str, Any] | None, ctx: ModuleContext) -> str:
    """Render an aggregate target (used as the base of bit/part-select).

    For a top-level identifier we use ``name.read()``; for nested aggregates
    we render through the regular rvalue path.
    """
    if isinstance(node, dict) and node.get("kind") == "identifier":
        return _render_identifier_rvalue(str(node.get("name", "")), ctx)
    return render_rvalue(node, ctx)


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


def _render_unop(op: str, operand_node: dict[str, Any] | None, ctx: ModuleContext) -> str:
    operand_text = render_rvalue(operand_node, ctx)
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
        return f"(~{operand_text})"
    if op == "-":
        return f"(-{operand_text})"
    if op == "+":
        return f"(+{operand_text})"
    if op == "&":
        return f"{operand_text}.and_reduce()"
    if op == "|":
        return f"{operand_text}.or_reduce()"
    if op == "^":
        return f"{operand_text}.xor_reduce()"
    if op == "~&":
        return f"(!({operand_text}.and_reduce()))"
    if op == "~|":
        return f"(!({operand_text}.or_reduce()))"
    if op in {"^~", "~^"}:
        return f"(!({operand_text}.xor_reduce()))"
    return f"({op}{operand_text})"


def _render_concat(parts: list[dict[str, Any]], ctx: ModuleContext) -> str:
    if not parts:
        return "0"
    if len(parts) == 1:
        return render_rvalue(parts[0], ctx)
    widths = [max(1, infer_width(part, ctx)) for part in parts]
    total = sum(widths)
    if total <= 0:
        total = 1
    pieces: list[str] = []
    bits_remaining = total
    for part, width in zip(parts, widths):
        bits_remaining -= width
        operand = render_rvalue(part, ctx)
        if bits_remaining > 0:
            pieces.append(f"(sc_uint<{total}>({operand}) << {bits_remaining})")
        else:
            pieces.append(f"sc_uint<{total}>({operand})")
    return "(" + " | ".join(pieces) + ")"


def _render_repeat(count_node: dict[str, Any] | None, value_node: dict[str, Any] | None, ctx: ModuleContext) -> str:
    count = const_eval(count_node, ctx) or 0
    if count <= 0:
        count = 1
    width = max(1, infer_width(value_node, ctx))
    total = count * width
    if total <= 0:
        total = 1
    operand = render_rvalue(value_node, ctx)
    pieces: list[str] = []
    for i in range(count):
        shift = (count - 1 - i) * width
        if shift > 0:
            pieces.append(f"(sc_uint<{total}>({operand}) << {shift})")
        else:
            pieces.append(f"sc_uint<{total}>({operand})")
    return "(" + " | ".join(pieces) + ")"


def _render_syscall(expr: dict[str, Any], ctx: ModuleContext) -> str:
    name = str(expr.get("name", ""))
    args_nodes = expr.get("args", []) or []
    args = [render_rvalue(arg, ctx) for arg in args_nodes]
    if name in {"signed", "unsigned"} and args:
        # ``$signed`` and ``$unsigned`` change the type of an expression for
        # operations that care about sign — most importantly ``>>>``, which
        # arithmetic-shifts iff its LHS is signed. Treating them as no-ops
        # silently turns ``$signed(x) >>> n`` into a logical shift on the
        # underlying unsigned representation.
        width = infer_width(args_nodes[0], ctx) if args_nodes else 1
        target_type = "sc_int" if name == "signed" else "sc_uint"
        return f"{target_type}<{width}>({args[0]})"
    return f"/* $${name}() unsupported */ 0"


def _format_intconst(expr: dict[str, Any]) -> str:
    if expr.get("has_xz"):
        return "0"
    digits = expr.get("digits")
    base = expr.get("base", 10)
    if isinstance(digits, str) and digits:
        if base == 16:
            return f"0x{digits}"
        if base == 2:
            return f"0b{digits}"
        if base == 8:
            return f"0{digits}"
        return digits
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
    try:
        return int(text)
    except ValueError:
        pass
    direct = _parse_const_literal(text)
    if direct is not None:
        return direct
    # Tiny expression evaluator for things like "(WIDTH - 1)".
    safe = re.match(r"^[\s\d\(\)\+\-\*\/A-Za-z_]+$", text)
    if not safe:
        return None
    expr = text
    for name, value in parameter_values.items():
        expr = re.sub(rf"\b{re.escape(name)}\b", str(value), expr)
    expr = re.sub(r"\b[A-Za-z_][A-Za-z0-9_]*\b", "0", expr)
    try:
        return int(eval(expr, {"__builtins__": {}}, {}))  # noqa: S307 - sanitized above
    except Exception:
        return None
