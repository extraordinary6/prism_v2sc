from __future__ import annotations

from pathlib import Path

from prism_v2sc.frontend.lower import lower_design
from prism_v2sc.frontend.pyverilog_parser import parse_verilog


def test_lower_design_rejects_missing_top(tmp_path: Path) -> None:
    rtl = tmp_path / "top.v"
    rtl.write_text("module top(input a, output y); assign y = a; endmodule\n", encoding="utf-8")

    ast = parse_verilog([rtl])

    try:
        lower_design(ast, "missing")
    except ValueError as exc:
        assert "top module 'missing' not found" in str(exc)
    else:
        raise AssertionError("expected missing top to raise ValueError")
