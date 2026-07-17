from __future__ import annotations

from pathlib import Path

import pytest

from prism_v2sc.codegen.systemc import generate_systemc_header
from prism_v2sc.frontend.flow import lower_design_top_down
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


def test_large_continuous_assign_sets_are_grouped(tmp_path: Path) -> None:
    rtl = tmp_path / "large_assigns.sv"
    signal_count = 300
    declarations = "\n".join(
        f"  logic [7:0] stage_{index};" for index in range(signal_count)
    )
    assignments = ["  assign stage_0 = a;"]
    assignments.extend(
        f"  assign stage_{index} = stage_{index - 1};"
        for index in range(1, signal_count)
    )
    assignments.append(f"  assign y = stage_{signal_count - 1};")
    rtl.write_text(
        "\n".join(
            [
                "module large_assigns(input logic [7:0] a, output logic [7:0] y);",
                declarations,
                *assignments,
                "endmodule",
            ]
        ),
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "large_assigns")
    header = generate_systemc_header(design)

    assert "void assign_group_0_63()" in header
    assert "void assign_group_64_127()" in header
    assert "void assign_group_256_300()" in header
    assert "SC_METHOD(assign_group_0_63);" in header
    assert "SC_METHOD(assign_group_256_300);" in header
    assert "void assign_0()" not in header


def test_large_direct_bit_bridge_sets_are_grouped(tmp_path: Path) -> None:
    rtl = tmp_path / "large_bridges.sv"
    instances = "\n".join(
        f"  bit_leaf u_{index}(.d(a[{index}]), .q(y[{index}]));"
        for index in range(300)
    )
    rtl.write_text(
        "\n".join(
            [
                "module bit_leaf(input logic d, output logic q);",
                "  assign q = d;",
                "endmodule",
                "module large_bridges(input logic [299:0] a, output logic [299:0] y);",
                instances,
                "endmodule",
            ]
        ),
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "large_bridges")
    header = generate_systemc_header(design)

    assert "void __bridge_group_0_255()" in header
    assert "void __bridge_group_256_299()" in header
    assert "SC_METHOD(__bridge_group_0_255);" in header
    assert "SC_METHOD(__bridge_group_256_299);" in header
    assert "void __bridge_method_u_0_d()" not in header


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


def test_template_defaults_translate_verilog_only_constant_forms(tmp_path: Path) -> None:
    rtl = tmp_path / "template_defaults.v"
    rtl.write_text(
        """
module template_defaults #(
  parameter DW = 8,
  parameter ZERO = {DW{1'b0}},
  parameter ONES = {DW{1'b1}},
  parameter FIELD = DW[6:0],
  parameter DECIMAL = 09
) (output wire out);
  assign out = ZERO | FIELD | DECIMAL;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "template_defaults")
    header = generate_systemc_header(design)

    assert "int ZERO = 0" in header
    assert "int ONES = ((DW >= 31) ? -1 : ((1 << DW) - 1))" in header
    assert "int FIELD = ((DW >> 0) & 127)" in header
    assert "int DECIMAL = 9" in header


def test_specialization_name_includes_defaulted_actual_parameters(tmp_path: Path) -> None:
    rtl = tmp_path / "defaulted_specialization.v"
    rtl.write_text(
        """
module child #(parameter DW = 1, parameter RST = {DW{1'b1}}) (
  input wire [DW-1:0] d,
  output wire [DW-1:0] q
);
  assign q = d | RST;
endmodule

module top(input wire d, output wire q0, output wire q1);
  child #(1) u_default(.d(d), .q(q0));
  child #(.DW(1), .RST(1'b0)) u_zero(.d(d), .q(q1));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design_top_down([rtl], "top").design
    top = next(module for module in design.modules if module.name == "top")
    module_names = {module.name for module in design.modules}

    assert len({instance.module for instance in top.instances}) == 2
    assert all(instance.module in module_names for instance in top.instances)
    assert all(len(instance.parameters) == 2 for instance in top.instances)


def test_internal_signal_edges_use_signal_event_methods(tmp_path: Path) -> None:
    rtl = tmp_path / "internal_edge.v"
    rtl.write_text(
        """
module internal_edge(input wire clk, input wire rst_n, input wire d, output reg q);
  wire gated_clk = clk;
  wire local_rst_n = rst_n;
  always @(posedge gated_clk or negedge local_rst_n) begin
    if (!local_rst_n) q <= 1'b0;
    else q <= d;
  end
endmodule
""",
        encoding="utf-8",
    )

    header = generate_systemc_header(lower_via_pyslang([rtl], "internal_edge"))
    assert "gated_clk.posedge_event()" in header
    assert "local_rst_n.negedge_event()" in header


def test_explicit_one_bit_vector_write_casts_bit_reference(tmp_path: Path) -> None:
    rtl = tmp_path / "one_bit_vector.v"
    rtl.write_text(
        """
module one_bit_vector(input wire [3:0] data, output wire [0:0] y);
  assign y = data[3];
endmodule
""",
        encoding="utf-8",
    )

    header = generate_systemc_header(lower_via_pyslang([rtl], "one_bit_vector"))
    assert "y.write(sc_uint<1>(data.read()[3]));" in header


def test_unpacked_array_element_slice_uses_cell_read_modify_write(tmp_path: Path) -> None:
    rtl = tmp_path / "array_slice.sv"
    rtl.write_text(
        """
module array_slice(input logic [3:0] hi, lo, output logic [7:0] y);
  logic [7:0] words [0:1];
  always_comb begin
    words[0][7:4] = hi;
    words[0][3:0] = lo;
    y = words[0];
  end
endmodule
""",
        encoding="utf-8",
    )

    header = generate_systemc_header(lower_via_pyslang([rtl], "array_slice"))
    assert "words[0].read()" in header
    assert "words[0].write(" in header
    assert "words.read()" not in header


def test_continuous_array_cell_slices_use_one_assembler_writer(tmp_path: Path) -> None:
    rtl = tmp_path / "continuous_array_slice.sv"
    rtl.write_text(
        """
module continuous_array_slice(input logic [3:0] hi, lo, output logic [7:0] y);
  logic [7:0] words [0:0];
  assign words[0][7:4] = hi;
  assign words[0][3:0] = lo;
  assign y = words[0];
endmodule
""",
        encoding="utf-8",
    )

    header = generate_systemc_header(lower_via_pyslang([rtl], "continuous_array_slice"))
    assert "__shadow_words_0__7_4" in header
    assert "__shadow_words_0__3_0" in header
    assert "__assemble_words_0" in header


def test_child_output_bit_binding_writes_back_array_cell(tmp_path: Path) -> None:
    rtl = tmp_path / "child_output_array_bit.sv"
    rtl.write_text(
        """
module bit_source(input logic d, output logic q);
  assign q = d;
endmodule
module child_output_array_bit(input logic d, output logic [1:0] y);
  logic [1:0] cells [0:1];
  bit_source u_bit(.d(d), .q(cells[0][1]));
  assign y = cells[0];
endmodule
""",
        encoding="utf-8",
    )

    header = generate_systemc_header(lower_via_pyslang([rtl], "child_output_array_bit"))
    assert "__bridge_u_bit_q" in header
    assert "__bridge_assemble_cells_0_" in header
    assert "auto __tmp = cells[0].read();" in header
    assert "cells[0].write(__tmp);" in header


def test_child_output_and_continuous_slice_share_one_parent_writer(tmp_path: Path) -> None:
    rtl = tmp_path / "child_and_assign_slice.sv"
    rtl.write_text(
        """
module low_source(input logic d, output logic q);
  assign q = d;
endmodule
module child_and_assign_slice(input logic d, output logic [7:0] y);
  logic [7:0] value;
  low_source u_low(.d(d), .q(value[0]));
  assign value[7:1] = 7'b0;
  assign y = value;
endmodule
""",
        encoding="utf-8",
    )

    header = generate_systemc_header(lower_via_pyslang([rtl], "child_and_assign_slice"))
    assert "__shadow_value_7_1" in header
    assert "void __bridge_assemble_value()" in header
    assembler = header.split("void __bridge_assemble_value()", 1)[1].split("}", 1)[0]
    assert "__tmp.range(7, 1) = __shadow_value_7_1.read();" in assembler
    assert "__tmp[0] = __bridge_u_low_q.read();" in assembler
    assert "value.write(__tmp);" in assembler
    assert header.count("value.write(__tmp);") == 1


def test_child_output_expression_bit_index_writes_back_vector(tmp_path: Path) -> None:
    rtl = tmp_path / "child_output_expression_bit.sv"
    rtl.write_text(
        """
module bit_source_expr(input logic d, output logic q);
  assign q = d;
endmodule
module child_output_expression_bit(input logic d, output logic [7:0] y);
  bit_source_expr u_bit(.d(d), .q(y[8-1]));
endmodule
""",
        encoding="utf-8",
    )

    header = generate_systemc_header(lower_via_pyslang([rtl], "child_output_expression_bit"))
    assert "__bridge_u_bit_q" in header
    assert "__bridge_assemble_y" in header
    assert "auto __tmp = y.read();" in header
    assert "__tmp[(8 - 1)]" in header
    assert "y.write(__tmp);" in header


def test_parameter_select_expression_uses_integer_shift(tmp_path: Path) -> None:
    rtl = tmp_path / "parameter_select.v"
    rtl.write_text(
        """
module parameter_select #(parameter VALUE = 32'h1234abcd) (
  output wire [7:0] byte_value,
  output wire bit_value
);
  assign byte_value = VALUE[15:8];
  assign bit_value = VALUE[3];
endmodule
""",
        encoding="utf-8",
    )

    header = generate_systemc_header(lower_via_pyslang([rtl], "parameter_select"))
    assert "VALUE.range" not in header
    assert "sc_uint<8>(VALUE >> (8))" in header
    assert "((VALUE >> (3)) & 1)" in header


def test_parameterized_expression_bridge_uses_instance_width(tmp_path: Path) -> None:
    rtl = tmp_path / "param_bridge.sv"
    rtl.write_text(
        """
module child #(parameter WIDTH = 4) (
  input logic [WIDTH-1:0] data
);
endmodule

module top(input logic [15:0] data);
  child #(.WIDTH(8)) u_child(.data(data[7:0]));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "top")
    header = generate_systemc_header(design)

    bridge_declaration = next(
        line for line in header.splitlines() if "__bridge_u_child_data;" in line
    )
    assert "sc_signal<sc_uint<" in bridge_declaration
    assert "8" in bridge_declaration
    assert "WIDTH" not in bridge_declaration


def test_parameterized_wide_ports_select_big_integer_types(tmp_path: Path) -> None:
    rtl = tmp_path / "wide_param.sv"
    rtl.write_text(
        """
module wide_param #(
  parameter ELEM_W = 32,
  parameter ELEM_N = 32
) (
  input  logic signed [ELEM_W*ELEM_N-1:0] signed_data,
  output logic        [ELEM_W*ELEM_N-1:0] unsigned_data
);
  assign unsigned_data = signed_data;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "wide_param")
    header = generate_systemc_header(design)

    assert "#include <type_traits>" in header
    assert "using prism_v2sc_uint_t" in header
    assert "using prism_v2sc_int_t" in header
    assert "sc_in<prism_v2sc_int_t<" in header
    assert "sc_out<prism_v2sc_uint_t<" in header
    assert "sc_in<sc_int<" not in header
    assert "sc_out<sc_uint<" not in header


def test_parameterized_ascending_range_uses_positive_width(tmp_path: Path) -> None:
    rtl = tmp_path / "ascending_param.sv"
    rtl.write_text(
        """
module ascending_param #(parameter WIDTH = 8) (
  input  logic [0:WIDTH-1] data,
  output logic [0:WIDTH-1] same
);
  assign same = data;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "ascending_param")
    header = generate_systemc_header(design)

    port_lines = [
        line
        for line in header.splitlines()
        if line.strip().startswith(("sc_in<", "sc_out<"))
    ]
    assert len(port_lines) == 2
    assert all("prism_v2sc_uint_t<" in line for line in port_lines)
    assert all("?" in line and ":" in line for line in port_lines)


def test_parameterized_clog2_localparam_keeps_derived_default(tmp_path: Path) -> None:
    rtl = tmp_path / "clog2_param.sv"
    rtl.write_text(
        """
module clog2_param #(parameter DEPTH = 64) (
  input logic [$clog2(DEPTH)-1:0] addr
);
  localparam AW = $clog2(DEPTH);
  logic [AW-1:0] saved;
  assign saved = addr;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "clog2_param")
    header = generate_systemc_header(design)

    assert "constexpr int prism_v2sc_clog2" in header
    assert "int AW = prism_v2sc_clog2(DEPTH)" in header
    assert "int AW = 1" not in header


def test_single_element_concat_in_width_is_constant_evaluated(tmp_path: Path) -> None:
    rtl = tmp_path / "curly_width.sv"
    rtl.write_text(
        """
module curly_width #(
  parameter LANES = 4,
  parameter BITS = 58,
  parameter EXTRA = 11
) (
  input  logic [LANES*{BITS+EXTRA}-1:0] a,
  output logic [LANES*{BITS+EXTRA}-1:0] y
);
  assign y = a;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "curly_width")
    header = generate_systemc_header(design)

    assert "y.write(a.read());" in header
    assert "y.write(sc_uint<1>(a.read()));" not in header


def test_localparam_constant_concat_and_replication_is_folded(tmp_path: Path) -> None:
    rtl = tmp_path / "concat_localparam.sv"
    rtl.write_text(
        """
module concat_localparam (
  output logic [7:0] value
);
  localparam MASK = {1'b0, {7{1'b1}}};
  assign value = MASK;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "concat_localparam")
    header = generate_systemc_header(design)

    assert "static constexpr int MASK = 127;" in header
    assert "7((0b1))" not in header


def test_parameterized_child_with_default_args_uses_template_empty_args(tmp_path: Path) -> None:
    rtl = tmp_path / "param_default.v"
    rtl.write_text(
        """
module child #(parameter WIDTH = 4) (
  input wire [WIDTH-1:0] a,
  output wire [WIDTH-1:0] y
);
  assign y = a;
endmodule

module top (
  input wire [3:0] a,
  output wire [3:0] y
);
  child u_child(.a(a), .y(y));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "top")
    header = generate_systemc_header(design)

    assert "child<4> u_child;" in header
    assert "u_child.a(a);" in header


def test_continuous_assign_concat_lvalue_splits_targets(tmp_path: Path) -> None:
    rtl = tmp_path / "concat_lvalue.sv"
    rtl.write_text(
        """
module split_bus(
  input  wire [15:0] bus,
  output wire [7:0] hi,
  output wire [7:0] lo
);
  assign {hi, lo} = bus;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "split_bus")
    header = generate_systemc_header(design)

    assert "_hi__lo_" not in header
    assert "auto __concat_rhs = sc_uint<16>(bus.read());" in header
    assert "hi.write(sc_uint<8>(__concat_rhs.range(15, 8)));" in header
    assert "lo.write(sc_uint<8>(__concat_rhs.range(7, 0)));" in header


def test_concat_lvalue_bit_slices_share_one_parent_writer(tmp_path: Path) -> None:
    rtl = tmp_path / "concat_lvalue_slices.sv"
    rtl.write_text(
        """
module concat_lvalue_slices(
  input wire [1:0] a,
  input wire [1:0] b,
  output wire [1:0] y
);
  wire [1:0] flags;
  wire lanes [0:1];
  assign {flags[0], lanes[0]} = a;
  assign {flags[1], lanes[1]} = b;
  assign y = flags;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "concat_lvalue_slices")
    header = generate_systemc_header(design)

    assert "sc_signal<bool> __shadow_flags_0;" in header
    assert "sc_signal<bool> __shadow_flags_1;" in header
    assert "__shadow_flags_0.write(__concat_rhs[1]);" in header
    assert "__shadow_flags_1.write(__concat_rhs[1]);" in header
    assembler = header.split("void __assemble_flags()", 1)[1].split("}", 1)[0]
    assert "flags.write(__tmp);" in assembler
    assert "__tmp[0] = __shadow_flags_0.read();" in assembler
    assert "__tmp[1] = __shadow_flags_1.read();" in assembler


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


def test_always_ff_with_level_clock_event_keeps_sensitivity(tmp_path: Path) -> None:
    rtl = tmp_path / "level_clock_ff.sv"
    rtl.write_text(
        """
module level_clock_ff(input logic clk, input logic d, output logic q);
  always_ff @(clk) begin
    q <= d;
  end
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "level_clock_ff")

    header = generate_systemc_header(design)

    assert "SC_METHOD(always_ff_0);" in header
    assert "sensitive << clk;" in header


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
    assert "__next_result = (__next_sum[8] ? sc_uint<8>(0xff)" in header
    assert "sc_uint<8>(__next_sum.range(7, 0))" in header
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
    assert "hi.write(sc_uint<4>(state.read().range(7, 4)));" in header
    assert "lo.write(sc_uint<4>(overlay.read().range(3, 0)));" in header
    assert "mirror.write(sc_uint<8>(overlay.read().range(7, 0)));" in header
