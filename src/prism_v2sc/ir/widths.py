"""Width extraction helpers."""

from __future__ import annotations

from .expressions import render_expr
from .model import WidthIR


def scalar_width() -> int:
    """Return the width of a scalar Verilog signal."""
    return 1


def extract_width(width_node: object | None) -> WidthIR | None:
    """Convert a Pyverilog width node into Phase 1 IR."""
    if width_node is None:
        return None
    return WidthIR(msb=render_expr(width_node.msb), lsb=render_expr(width_node.lsb))
