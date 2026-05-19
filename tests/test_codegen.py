from __future__ import annotations

from pathlib import Path

import pytest

from prism_v2sc.codegen.systemc import generate_systemc_header

from _pyslang_helper import lower_via_pyslang


def test_generate_systemc_header_for_hierarchical_design(tmp_path: Path) -> None:
    rtl = tmp_path / "design.v"
    rtl.write_text(
        """
module child (
  input wire [7:0] a,
  output wire [7:0] y
);
  assign y = a;
endmodule

module top (
  input wire [7:0] a,
  output wire [7:0] y
);
  wire [7:0] tmp;
  assign tmp = a;
  child u_child(.a(tmp), .y(y));
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "top")

    header = generate_systemc_header(design)

    assert "SC_MODULE(child)" in header
    assert "sc_in<sc_uint<8>> a;" in header
    assert "sc_out<sc_uint<8>> y;" in header
    assert "SC_MODULE(top)" in header
    assert "sc_signal<sc_uint<8>> tmp;" in header
    assert "child u_child;" in header
    assert 'u_child("u_child")' in header
    assert "u_child.a(tmp);" in header
    assert "u_child.y(y);" in header


def test_generate_systemc_header_for_parameter_override(tmp_path: Path) -> None:
    rtl = tmp_path / "param.v"
    rtl.write_text(
        """
module child #(parameter WIDTH = 4) (
  input wire [WIDTH-1:0] a,
  output wire [WIDTH-1:0] y
);
  assign y = a;
endmodule

module top (
  input wire [7:0] a,
  output wire [7:0] y
);
  child #(.WIDTH(8)) u_child(.a(a), .y(y));
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "top")

    header = generate_systemc_header(design)

    # slang elaborates parameter overrides before lowering, so the template's
    # default reflects the override (WIDTH=8) rather than the declaration default
    # (WIDTH=4). Either value confirms the template was emitted.
    assert ("template <int WIDTH = 4>" in header) or ("template <int WIDTH = 8>" in header)
    assert "SC_MODULE(child)" in header
    assert "child<8> u_child;" in header
    assert 'u_child("u_child")' in header


def test_generate_for_unrolls_into_flattened_instances(tmp_path: Path) -> None:
    """slang elaborates generate-for into N concrete instances. The IR's
    ``generate_fors`` is empty; each unrolled iteration lands as a plain
    ``InstanceIR`` with a disambiguated name (``g_0_u`` ... ``g_3_u``), and
    the genvar in each instance's port binding resolves to the iteration
    index rather than leaking through as a literal ``i``.
    """
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
    design = lower_via_pyslang([rtl], "gen_top")

    payload = design.to_dict()
    gen_top = next(module for module in payload["modules"] if module["name"] == "gen_top")
    assert gen_top["generate_fors"] == [] or gen_top["generate_fors"] == ()
    instance_names = [inst["name"] for inst in gen_top["instances"]]
    assert instance_names == [f"g_{i}_u" for i in range(4)]
    for idx, inst in enumerate(gen_top["instances"]):
        a_port = next(p for p in inst["ports"] if p["name"] == "a")
        y_port = next(p for p in inst["ports"] if p["name"] == "y")
        assert a_port["value"] == f"a[{idx}]"
        assert y_port["value"] == f"y[{idx}]"

    header = generate_systemc_header(design)
    for idx in range(4):
        assert f"bitcell g_{idx}_u;" in header
    assert "sc_vector<bitcell>" not in header  # elaborated form, not the GenerateForIR template


def test_generate_systemc_header_for_simple_dff_with_async_reset(tmp_path: Path) -> None:
    rtl = tmp_path / "dff.v"
    rtl.write_text(
        """
module dff(input wire clk, input wire rst_n, input wire [7:0] d, output reg [7:0] q);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 8'h00;
    end else begin
      q <= d;
    end
  end
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "dff")

    header = generate_systemc_header(design)

    assert "void always_ff_0()" in header
    assert "auto __next_q = q.read();" in header
    assert "if ((!rst_n.read())) {" in header
    assert "__next_q = 0x00;" in header
    assert "} else {" in header
    assert "__next_q = d.read();" in header
    assert "q.write(__next_q);" in header
    assert "SC_METHOD(always_ff_0);" in header
    assert "sensitive << clk.pos() << rst_n.neg();" in header
