"""Expression rendering helpers for the Phase 1 structural IR.

Two parallel representations are supported:

- a Verilog-like source string via ``render_expr`` (used for diagnostics and
  IR text fields), and
- a JSON-serializable dict tree via ``lower_expr`` (used by codegen so it
  can walk the structure without re-parsing Verilog text).

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
    {"kind": "raw", "text": "..."}     # safety fallback

When a sub-expression cannot be classified, a ``raw`` node is emitted with
the original Verilog text so codegen can still produce *some* output and
the diagnostic path stays useful.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Any


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

_SIZED_LITERAL = re.compile(
    r"^(?P<size>\d+)?\s*'\s*(?P<base>[bodhBODH])(?P<value>[0-9a-fA-F_xXzZ?]+)$"
)
_UNSIZED_LITERAL = re.compile(
    r"^'\s*(?P<base>[bodhBODH])(?P<value>[0-9a-fA-F_xXzZ?]+)$"
)
_BASE_MAP = {"b": 2, "o": 8, "d": 10, "h": 16}


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


def lower_expr(node: object | None) -> dict[str, Any]:
    """Lower a Pyverilog expression node into a JSON-serializable tree."""
    if node is None:
        return {"kind": "raw", "text": ""}

    cls_name = node.__class__.__name__

    if cls_name in {"Lvalue", "Rvalue"}:
        children = node.children() if hasattr(node, "children") else ()
        return lower_expr(children[0]) if children else {"kind": "raw", "text": ""}

    if cls_name == "Identifier":
        return {"kind": "identifier", "name": str(node.name)}

    if cls_name == "IntConst":
        return _lower_int_const(str(getattr(node, "value", "")))

    if cls_name == "FloatConst":
        return {"kind": "raw", "text": str(getattr(node, "value", ""))}

    if cls_name == "StringConst":
        return {"kind": "raw", "text": str(getattr(node, "value", ""))}

    if cls_name == "Pointer":
        return {
            "kind": "bitselect",
            "target": lower_expr(node.var),
            "index": lower_expr(node.ptr),
        }

    if cls_name == "Partselect":
        return {
            "kind": "partselect",
            "target": lower_expr(node.var),
            "msb": lower_expr(node.msb),
            "lsb": lower_expr(node.lsb),
        }

    if cls_name == "Concat":
        return {
            "kind": "concat",
            "parts": [lower_expr(child) for child in getattr(node, "list", ())],
        }

    if cls_name == "Repeat":
        return {
            "kind": "repeat",
            "count": lower_expr(node.times),
            "value": lower_expr(node.value),
        }

    if cls_name == "Cond":
        return {
            "kind": "cond",
            "cond": lower_expr(node.cond),
            "true": lower_expr(node.true_value),
            "false": lower_expr(node.false_value),
        }

    if cls_name in _BINARY_OPERATORS:
        children = node.children()
        left = children[0] if len(children) > 0 else None
        right = children[1] if len(children) > 1 else None
        return {
            "kind": "binop",
            "op": _BINARY_OPERATORS[cls_name],
            "left": lower_expr(left),
            "right": lower_expr(right),
        }

    if cls_name in _UNARY_OPERATORS:
        children = node.children() if hasattr(node, "children") else ()
        operand = children[0] if children else None
        return {
            "kind": "unop",
            "op": _UNARY_OPERATORS[cls_name],
            "operand": lower_expr(operand),
        }

    if cls_name == "SystemCall":
        return {
            "kind": "syscall",
            "name": str(getattr(node, "syscall", "")),
            "args": [lower_expr(arg) for arg in getattr(node, "args", ())],
        }

    return {"kind": "raw", "text": render_expr(node)}


def _lower_int_const(raw: str) -> dict[str, Any]:
    """Parse a Verilog integer literal into an intconst node."""
    text = raw.strip()
    sized = _SIZED_LITERAL.match(text)
    unsized = _UNSIZED_LITERAL.match(text)
    if sized:
        size = int(sized.group("size")) if sized.group("size") else None
        base = sized.group("base").lower()
        value_text = sized.group("value").replace("_", "")
        value, has_xz = _parse_value(value_text, _BASE_MAP[base])
        return {
            "kind": "intconst",
            "raw": text,
            "value": value,
            "width": size,
            "base": _BASE_MAP[base],
            "has_xz": has_xz,
            "digits": value_text,
        }
    if unsized:
        base = unsized.group("base").lower()
        value_text = unsized.group("value").replace("_", "")
        value, has_xz = _parse_value(value_text, _BASE_MAP[base])
        return {
            "kind": "intconst",
            "raw": text,
            "value": value,
            "width": None,
            "base": _BASE_MAP[base],
            "has_xz": has_xz,
            "digits": value_text,
        }
    plain = text.replace("_", "")
    try:
        value = int(plain)
        return {
            "kind": "intconst",
            "raw": text,
            "value": value,
            "width": None,
            "base": 10,
            "has_xz": False,
            "digits": plain,
        }
    except ValueError:
        return {"kind": "raw", "text": text}


def _parse_value(value_text: str, base: int) -> tuple[int, bool]:
    """Parse a digit string for a given base, treating x/z/? as zero bits.

    Returns ``(integer_value, has_xz_or_question)``.
    """
    has_xz = bool(re.search(r"[xXzZ?]", value_text))
    sanitized = re.sub(r"[xXzZ?]", "0", value_text)
    if not sanitized:
        return 0, has_xz
    try:
        return int(sanitized, base), has_xz
    except ValueError:
        return 0, has_xz


def collect_identifiers(expr: dict[str, Any] | None) -> list[str]:
    """Return the ordered, de-duplicated identifier names referenced in an expression tree.

    Sized integer literals are excluded — this is the canonical replacement
    for the previous regex-based identifier scan that mistakenly picked up
    constant-base prefixes like ``hAA`` from sized literals.
    """
    seen: set[str] = set()
    ordered: list[str] = []

    def walk(node: dict[str, Any] | None) -> None:
        if not isinstance(node, dict):
            return
        kind = node.get("kind")
        if kind == "identifier":
            name = str(node.get("name", ""))
            if name and name not in seen:
                seen.add(name)
                ordered.append(name)
            return
        for key in ("target", "operand", "value", "cond", "true", "false", "left", "right", "msb", "lsb", "index", "count"):
            child = node.get(key)
            if isinstance(child, dict):
                walk(child)
        for key in ("parts", "args"):
            children = node.get(key)
            if isinstance(children, list):
                for child in children:
                    if isinstance(child, dict):
                        walk(child)

    walk(expr)
    return ordered
