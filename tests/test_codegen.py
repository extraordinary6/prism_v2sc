from __future__ import annotations

from pathlib import Path

import pytest

from prism_v2sc.codegen.systemc import generate_systemc_header
from prism_v2sc.ir.model import WidthIR

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


def test_template_defaults_do_not_reference_parent_localparams(tmp_path: Path) -> None:
    rtl = tmp_path / "param_scope.v"
    rtl.write_text(
        """
module child #(parameter WIDTH = 4) (
  input wire [WIDTH-1:0] a,
  output wire [WIDTH-1:0] y
);
  assign y = a;
endmodule

module top #(parameter BASE = 5) (
  input wire [7:0] a,
  output wire [7:0] y
);
  localparam CHILD_W = BASE + 3;
  child #(.WIDTH(CHILD_W)) u_child(.a(a), .y(y));
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "top")

    header = generate_systemc_header(design)

    assert "child<8> u_child;" in header
    assert "WIDTH = CHILD_W" not in header


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


def test_nonblocking_chain_reads_pre_edge_values(tmp_path: Path) -> None:
    rtl = tmp_path / "nba_chain.v"
    rtl.write_text(
        """
module nba_chain(input wire clk, input wire [7:0] d, output reg [7:0] a, output reg [7:0] b);
  always @(posedge clk) begin
    a <= d;
    b <= a;
  end
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "nba_chain")

    header = generate_systemc_header(design)

    assert "__next_a = d.read();" in header
    assert "__next_b = a.read();" in header
    assert "__next_b = __next_a;" not in header


def test_blocking_temp_in_ff_feeds_later_nonblocking_rhs(tmp_path: Path) -> None:
    rtl = tmp_path / "ff_temp.v"
    rtl.write_text(
        """
module ff_temp(input wire clk, input wire [7:0] a, input wire [7:0] b, output reg [7:0] result);
  reg [8:0] sum;
  always @(posedge clk) begin
    sum = {1'b0, a} + {1'b0, b};
    result <= sum[8] ? 8'hff : sum[7:0];
  end
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "ff_temp")

    header = generate_systemc_header(design)

    assert "__next_sum =" in header
    assert "__next_result = (__next_sum[8] ? 0xff : __next_sum.range(7, 0));" in header
    assert "sum.read()[8]" not in header


def test_generate_systemc_header_for_typedef_enum(tmp_path: Path) -> None:
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
    assert module.type_aliases[0].width == WidthIR(msb="1", lsb="0")

    header = generate_systemc_header(design)
    assert "state_t" not in header
    assert "IDLE" not in header
    assert "BUSY" not in header
    assert "DONE" not in header
    assert "state.write(__next_state);" in header
    assert "done.write((state.read() == 0b10));" in header or "done.write((state.read() == 2));" in header


def test_generate_systemc_header_for_packed_struct_and_union(tmp_path: Path) -> None:
    rtl = tmp_path / "packed_aggregate_demo.sv"
    rtl.write_text(
        """
module packed_aggregate_demo(
  input  logic [3:0] a,
  input  logic [3:0] b,
  input  logic       flag,
  output logic [3:0] hi,
  output logic [3:0] lo,
    output logic [7:0] mirror
);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;
  typedef union packed { logic [7:0] wide; pair_t pair; } overlay_t;
  pair_t state;
  overlay_t overlay;
  always @(*) begin
    state.hi = a;
    state.lo = b;
    overlay.wide = flag ? {a, b} : {b, a};
  end
  assign hi = state.hi;
  assign lo = overlay.pair.lo;
  assign mirror = overlay.wide;
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "packed_aggregate_demo")
    module = next(module for module in design.modules if module.name == "packed_aggregate_demo")
    aliases = {alias.name: alias for alias in module.type_aliases}

    assert aliases["pair_t"].kind == "packed_struct"
    assert [(field.name, field.offset) for field in aliases["pair_t"].packed_fields] == [("hi", 4), ("lo", 0)]
    assert aliases["overlay_t"].kind == "packed_union"
    assert [(field.name, field.offset) for field in aliases["overlay_t"].packed_fields] == [
        ("wide", 0),
        ("pair", 0),
    ]
    assert module.signals[0].width == WidthIR(msb="7", lsb="0")

    header = generate_systemc_header(design)
    assert "pair_t" not in header
    assert "overlay_t" not in header
    assert "sc_signal<sc_uint<8>> state;" in header
    assert "sc_signal<sc_uint<8>> overlay;" in header
    assert "__next_state.range(7, 4) = a.read();" in header
    assert "__next_state.range(3, 0) = b.read();" in header
    assert "hi.write(state.read().range(7, 4));" in header
    assert "lo.write(overlay.read().range(3, 0));" in header
    assert "mirror.write(overlay.read().range(7, 0));" in header
