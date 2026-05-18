from __future__ import annotations

from pathlib import Path

from pyverilog.vparser import ast as vast

from prism_v2sc.frontend.lower import _function_statement_diagnostics, lower_design
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


def test_lower_design_reports_multiple_procedural_drivers(tmp_path: Path) -> None:
    rtl = tmp_path / "multi_driver.v"
    rtl.write_text(
        """
module multi_driver(
  input wire clk_a,
  input wire clk_b,
  input wire d,
  output reg q
);
  always @(posedge clk_a) begin
    q <= d;
  end

  always @(posedge clk_b) begin
    q <= ~d;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design(parse_verilog([rtl]), "multi_driver")
    codes = {diagnostic.code for diagnostic in design.diagnostics}
    assert "multiple_procedural_drivers" in codes
    assert "multiple_always_ff_drivers" in codes


def test_lower_design_reports_mixed_assignment_styles(tmp_path: Path) -> None:
    rtl = tmp_path / "mixed_style.v"
    rtl.write_text(
        """
module mixed_style(input wire clk, input wire d, output reg q);
  always @(posedge clk) begin
    if (d) begin
      q <= 1'b1;
    end else begin
      q = 1'b0;
    end
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design(parse_verilog([rtl]), "mixed_style")
    code_to_severity = {diagnostic.code: diagnostic.severity for diagnostic in design.diagnostics}
    assert code_to_severity["mixed_assignment_styles"] == "error"
    assert code_to_severity["blocking_in_always_ff"] == "warning"


def test_lower_design_keeps_only_top_reachable_modules(tmp_path: Path) -> None:
    rtl = tmp_path / "hier.v"
    rtl.write_text(
        """
module leaf(input wire a, output wire y);
  assign y = a;
endmodule

module mid(input wire a, output wire y);
  leaf u_leaf(.a(a), .y(y));
endmodule

module top(input wire a, output wire y);
  mid u_mid(.a(a), .y(y));
endmodule

module unused(input wire a, output wire y);
  assign y = ~a;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design(parse_verilog([rtl]), "top")
    assert {module.name for module in design.modules} == {"top", "mid", "leaf"}


def test_lower_design_reports_unresolved_instance_module(tmp_path: Path) -> None:
    rtl = tmp_path / "broken.v"
    rtl.write_text(
        """
module top(input wire a, output wire y);
  missing_mod u_missing(.a(a), .y(y));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design(parse_verilog([rtl]), "top")
    unresolved = [diagnostic for diagnostic in design.diagnostics if diagnostic.code == "unresolved_instance_module"]
    assert len(unresolved) == 1
    assert unresolved[0].module == "top"


def test_lower_design_reports_nonblocking_in_function(tmp_path: Path) -> None:
    rtl = tmp_path / "bad_function_nb.v"
    rtl.write_text(
        """
module top(input wire a, output wire y);
  function bad;
    input x;
    begin
      bad <= x;
    end
  endfunction
  assign y = bad(a);
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design(parse_verilog([rtl]), "top")
    codes = {diagnostic.code for diagnostic in design.diagnostics}
    assert "unsupported_function_nonblocking" in codes


def test_function_statement_diagnostics_reports_task_call() -> None:
    task_call = vast.TaskCall(vast.Identifier("helper"), [vast.Identifier("x")])
    diagnostics = _function_statement_diagnostics("top", "bad", [task_call])
    assert any(diagnostic.code == "unsupported_task_call_in_function" for diagnostic in diagnostics)
