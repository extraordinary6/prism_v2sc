from __future__ import annotations

from pathlib import Path

from prism_v2sc.ir.model import WidthIR

from _pyslang_helper import lower_via_pyslang


def test_lower_design_rejects_missing_top(tmp_path: Path) -> None:
    rtl = tmp_path / "top.v"
    rtl.write_text("module top(input a, output y); assign y = a; endmodule\n", encoding="utf-8")

    try:
        lower_via_pyslang([rtl], "missing")
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

    design = lower_via_pyslang([rtl], "multi_driver")
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

    design = lower_via_pyslang([rtl], "mixed_style")
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

    design = lower_via_pyslang([rtl], "top")
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

    design = lower_via_pyslang([rtl], "top")
    unresolved = [
        diagnostic
        for diagnostic in design.diagnostics
        if diagnostic.code in ("unresolved_instance_module", "slang_UnknownModule")
    ]
    assert len(unresolved) == 1


def test_lower_design_flattens_typedef_enum_metadata(tmp_path: Path) -> None:
    rtl = tmp_path / "enum_demo.sv"
    rtl.write_text(
        """
module enum_demo(input logic clk, input logic rst_n, input logic go, output logic done, output logic [1:0] state_bits);
  typedef enum logic [1:0] { IDLE = 2'b00, BUSY = 2'b01, DONE = 2'b10 } state_t;
  state_t state;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else if (go) state <= BUSY;
    else state <= DONE;
  end
  assign done = (state == DONE);
  assign state_bits = state;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "enum_demo")
    module = next(module for module in design.modules if module.name == "enum_demo")
    aliases = {alias.name: alias for alias in module.type_aliases}

    assert aliases["state_t"].kind == "enum"
    assert aliases["state_t"].width == WidthIR(msb="1", lsb="0")
    assert [(value.name, value.value) for value in aliases["state_t"].enum_values] == [
        ("IDLE", 0),
        ("BUSY", 1),
        ("DONE", 2),
    ]


def test_lower_design_flattens_packed_struct_metadata_and_accesses(tmp_path: Path) -> None:
    rtl = tmp_path / "packed_struct_demo.sv"
    rtl.write_text(
        """
module packed_struct_demo(
  input  logic [3:0] a,
  input  logic [3:0] b,
  output logic [3:0] hi,
  output logic [3:0] lo,
  output logic [7:0] bits
);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;
  pair_t state;
  always @(*) begin
    state.hi = a;
    state.lo = b;
  end
  assign hi = state.hi;
  assign lo = state.lo;
  assign bits = state;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "packed_struct_demo")
    module = next(module for module in design.modules if module.name == "packed_struct_demo")
    alias = next(alias for alias in module.type_aliases if alias.name == "pair_t")

    assert alias.kind == "packed_struct"
    assert alias.width == WidthIR(msb="7", lsb="0")
    assert [(field.name, field.offset) for field in alias.packed_fields] == [("hi", 4), ("lo", 0)]

    process = module.processes[0]
    first_assign = process.structured_statements[0]
    second_assign = process.structured_statements[1]
    assert first_assign["left_expr"]["kind"] == "partselect"
    assert first_assign["left_expr"]["msb"]["value"] == 7
    assert first_assign["left_expr"]["lsb"]["value"] == 4
    assert second_assign["left_expr"]["kind"] == "partselect"
    assert second_assign["left_expr"]["msb"]["value"] == 3
    assert second_assign["left_expr"]["lsb"]["value"] == 0
