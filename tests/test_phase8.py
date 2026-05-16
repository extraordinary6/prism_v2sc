from __future__ import annotations

from pathlib import Path

from prism_v2sc.codegen.systemc import generate_systemc_header
from prism_v2sc.frontend.lower import lower_design
from prism_v2sc.frontend.pyverilog_parser import parse_verilog


def test_case_statement_emits_switch(tmp_path: Path) -> None:
    rtl = tmp_path / "decode.v"
    rtl.write_text(
        """
module decode(input wire [1:0] sel, output reg [3:0] y);
  always @(*) begin
    case (sel)
      2'b00: y = 4'b0001;
      2'b01, 2'b10: y = 4'b0010;
      default: y = 4'b1000;
    endcase
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design(parse_verilog([rtl]), "decode")
    header = generate_systemc_header(design)

    assert design.diagnostics == ()
    assert "switch (sel.read()) {" in header
    assert "case 0b00:" in header
    assert "case 0b01:" in header
    assert "case 0b10:" in header
    assert "default:" in header
    assert "__next_y = 0b1000;" in header
    assert "y.write(__next_y);" in header


def test_bit_select_driver_conflict_is_slice_aware(tmp_path: Path) -> None:
    rtl = tmp_path / "slices.v"
    rtl.write_text(
        """
module slices(input wire clk_a, input wire clk_b, input wire a, input wire b, output reg [1:0] q);
  always @(posedge clk_a) begin
    q[0] <= a;
  end
  always @(posedge clk_b) begin
    q[1] <= b;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design(parse_verilog([rtl]), "slices")

    assert not any(diagnostic.code == "multiple_procedural_drivers" for diagnostic in design.diagnostics)


def test_generate_bit_select_binding_uses_scalar_bridges(tmp_path: Path) -> None:
    rtl = tmp_path / "generate.v"
    rtl.write_text(
        """
module bitcell(input wire a, output wire y);
  assign y = a;
endmodule

module gen_top #(parameter WIDTH = 4) (
  input wire [WIDTH-1:0] a,
  output wire [WIDTH-1:0] y
);
  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : g
      bitcell u(.a(a[i]), .y(y[i]));
    end
  endgenerate
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design(parse_verilog([rtl]), "gen_top")
    header = generate_systemc_header(design)

    assert "TODO: bind bit-select" not in header
    assert "sc_vector<sc_signal<bool>> __bridge_g_u_a;" in header
    assert "sc_vector<sc_signal<bool>> __bridge_g_u_y;" in header
    assert "g_u[i].a(__bridge_g_u_a[i]);" in header
    assert "g_u[i].y(__bridge_g_u_y[i]);" in header
    assert "__bridge_g_u_a[i].write(a.read()[i]);" in header
    assert "__tmp[i] = __bridge_g_u_y[i].read();" in header
    assert "y.write(__tmp);" in header
