"""Expression rendering helpers for the Phase 1 structural IR."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class IdentifierExpr:
    """Reference to a named Verilog object."""

    name: str


_BINARY_OPERATORS = {
    "Plus": "+",
    "Minus": "-",
    "Times": "*",
    "Divide": "/",
    "Mod": "%",
    "Power": "**",
    "Eq": "==",
    "NotEq": "!=",
    "Eql": "===",
    "NotEql": "!==",
    "LessThan": "<",
    "GreaterThan": ">",
    "LessEq": "<=",
    "GreaterEq": ">=",
    "Land": "&&",
    "Lor": "||",
    "And": "&",
    "Or": "|",
    "Xor": "^",
    "Xnor": "^~",
    "Sll": "<<",
    "Srl": ">>",
    "Sla": "<<<",
    "Sra": ">>>",
}

_UNARY_OPERATORS = {
    "Uplus": "+",
    "Uminus": "-",
    "Ulnot": "!",
    "Unot": "~",
    "Uand": "&",
    "Unand": "~&",
    "Uor": "|",
    "Unor": "~|",
    "Uxor": "^",
    "Uxnor": "^~",
}


def render_expr(node: object | None) -> str:
    """Render a Pyverilog expression node into a stable source-like string."""
    if node is None:
        return ""

    cls_name = node.__class__.__name__

    if cls_name in {"Lvalue", "Rvalue"}:
        children = node.children()
        return render_expr(children[0]) if children else ""

    if cls_name in {"Identifier", "IntConst", "FloatConst", "StringConst"}:
        return str(getattr(node, "name", getattr(node, "value", "")))

    if cls_name == "Pointer":
        return f"{render_expr(node.var)}[{render_expr(node.ptr)}]"

    if cls_name == "Partselect":
        return f"{render_expr(node.var)}[{render_expr(node.msb)}:{render_expr(node.lsb)}]"

    if cls_name == "Concat":
        return "{" + ", ".join(render_expr(child) for child in node.list) + "}"

    if cls_name == "Repeat":
        return "{" + f"{render_expr(node.times)}{{{render_expr(node.value)}}}" + "}"

    if cls_name == "Cond":
        return f"({render_expr(node.cond)} ? {render_expr(node.true_value)} : {render_expr(node.false_value)})"

    if cls_name in _BINARY_OPERATORS:
        left, right = node.children()
        return f"({render_expr(left)} {_BINARY_OPERATORS[cls_name]} {render_expr(right)})"

    if cls_name in _UNARY_OPERATORS:
        children = node.children()
        value = children[0] if children else None
        return f"({_UNARY_OPERATORS[cls_name]}{render_expr(value)})"

    if cls_name == "SystemCall":
        args = ", ".join(render_expr(arg) for arg in getattr(node, "args", ()))
        return f"${node.syscall}({args})"

    children = node.children() if hasattr(node, "children") else ()
    if children:
        return f"{cls_name}(" + ", ".join(render_expr(child) for child in children) + ")"
    return cls_name
