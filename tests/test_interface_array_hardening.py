"""Regression coverage for real-design interface and array lowering."""

from pathlib import Path
from textwrap import dedent

from prism_v2sc.codegen.systemc import generate_systemc_header

from _pyslang_helper import lower_via_pyslang


def _lower(tmp_path: Path, source: str, top: str = "top"):
    rtl = tmp_path / "top.sv"
    rtl.write_text(dedent(source), encoding="utf-8")
    return lower_via_pyslang([rtl], top)


def test_interface_instance_hierarchical_values_flatten(tmp_path: Path) -> None:
    design = _lower(
        tmp_path,
        """
        interface bus_if;
          logic [7:0] req;
          logic [7:0] rsp;
          modport slave(input req, output rsp);
        endinterface

        module leaf(bus_if.slave bus);
          assign bus.rsp = bus.req ^ 8'h5a;
        endmodule

        module top(
          input  logic [7:0] req,
          output logic [7:0] rsp
        );
          bus_if bus();
          assign bus.req = req;
          assign rsp = bus.rsp;
          leaf u_leaf(.bus(bus.slave));
        endmodule
        """,
    )

    header = generate_systemc_header(design)
    assert "bus__req.write(req.read());" in header
    assert "rsp.write(bus__rsp.read());" in header
    assert "raw: bus." not in header


def test_interface_constructor_ports_drive_flattened_signals(tmp_path: Path) -> None:
    design = _lower(
        tmp_path,
        """
        interface bus_if(input logic clk, input logic rst_n);
          logic value;
          modport sink(input clk, rst_n, value);
        endinterface

        module leaf(bus_if.sink bus, output logic sampled);
          always_ff @(posedge bus.clk or negedge bus.rst_n)
            if (!bus.rst_n) sampled <= 0;
            else sampled <= bus.value;
        endmodule

        module top(input logic clk, rst_n, value, output logic sampled);
          bus_if bus(clk, rst_n);
          assign bus.value = value;
          leaf u_leaf(.bus(bus.sink), .sampled(sampled));
        endmodule
        """,
    )

    header = generate_systemc_header(design)
    assert "bus__clk.write(clk.read());" in header
    assert "bus__rst_n.write(rst_n.read());" in header
    assert "u_leaf.bus__clk(bus__clk);" in header


def test_interface_values_survive_procedural_for_unrolling(tmp_path: Path) -> None:
    design = _lower(
        tmp_path,
        """
        interface bus_if;
          logic [7:0] data;
          logic [1:0] mask;
          modport sink(input data, mask);
        endinterface

        module leaf(bus_if.sink bus, output logic [7:0] out);
          always_comb begin
            for (int i = 0; i < 2; i++) begin
              out[i*4 +: 4] = bus.data[i*4 +: 4] & {4{~bus.mask[i]}};
            end
          end
        endmodule

        module top(
          input  logic [7:0] data,
          input  logic [1:0] mask,
          output logic [7:0] out
        );
          bus_if bus();
          assign bus.data = data;
          assign bus.mask = mask;
          leaf u_leaf(.bus(bus.sink), .out(out));
        endmodule
        """,
    )

    header = generate_systemc_header(design)
    assert "bus__data.read()" in header
    assert "bus__mask.read()" in header
    assert "/* raw:  */ 0" not in header


def test_unpacked_array_assignment_pattern_emits_per_cell_writes(tmp_path: Path) -> None:
    design = _lower(
        tmp_path,
        """
        module top(
          input  logic       row,
          input  logic [1:0] col,
          output logic [3:0] value
        );
          logic [3:0] lut [0:1][0:2];
          assign lut = '{
            {4'd1, 4'd2, 4'd3},
            {4'd4, 4'd5, 4'd6}
          };
          assign value = lut[row][col];
        endmodule
        """,
    )

    assert not design.diagnostics
    header = generate_systemc_header(design)
    assert "lut[0][0].write(1);" in header
    assert "lut[0][2].write(3);" in header
    assert "lut[1][0].write(4);" in header
    assert "lut[1][2].write(6);" in header
    assert "lut.write(" not in header
    assert "raw:" not in header


def test_direct_statement_list_in_function_is_lowered(tmp_path: Path) -> None:
    design = _lower(
        tmp_path,
        """
        module top(input logic [7:0] a, output logic [7:0] y);
          function logic [7:0] mix(input logic [7:0] value);
            logic [7:0] temp;
            temp = value + 1;
            temp = temp ^ 8'h3c;
            return temp;
          endfunction
          assign y = mix(a);
        endmodule
        """,
    )

    assert not any(diagnostic.code == "unsupported_list" for diagnostic in design.diagnostics)
    header = generate_systemc_header(design)
    assert "Unsupported statement: List" not in header
    assert "temp = (value + 1);" in header
    assert "return temp;" in header


def test_invalid_continuous_assignment_reports_diagnostic_instead_of_crashing(tmp_path: Path) -> None:
    design = _lower(
        tmp_path,
        """
        interface bus_if;
          logic value;
        endinterface

        module top(bus_if bus, output logic value);
          assign value = bus.value;
        endmodule
        """,
    )

    assert any(diagnostic.code == "invalid_continuous_assignment" for diagnostic in design.diagnostics)


def test_ascending_packed_ranges_map_to_systemc_bit_order(tmp_path: Path) -> None:
    design = _lower(
        tmp_path,
        """
        module top(
          input  logic [0:7] data,
          output logic       first,
          output logic [0:3] high,
          output logic [0:3] low
        );
          assign first = data[0];
          assign high = data[0:3];
          assign low = data[4 +: 4];
        endmodule
        """,
    )

    header = generate_systemc_header(design)
    assert "first.write(data.read()[(7 - 0)]);" in header
    assert "high.write(sc_uint<4>(data.read().range((7 - 0), (7 - 3))));" in header
    assert "low.write(sc_uint<4>(data.read().range((7 - 4), (7 - ((4 + 4) - 1)))));" in header


def test_verification_only_assertions_are_ignored(tmp_path: Path) -> None:
    design = _lower(
        tmp_path,
        """
        module top(input logic clk, input logic a, output logic y);
          property output_tracks_input;
            @(posedge clk) a |-> y;
          endproperty
          assert property (output_tracks_input);
          always_comb begin
            assert (a == a);
            y = a;
          end
          always_comb begin
            assert (a == a);
          end
        endmodule
        """,
    )

    assert not design.diagnostics
    header = generate_systemc_header(design)
    assert "y.write(" in header
    assert "a.read()" in header
    assert "assert" not in header


def test_generate_local_signals_receive_unique_flattened_names(tmp_path: Path) -> None:
    design = _lower(
        tmp_path,
        """
        module leaf(input logic signed [7:0] value, output logic signed [7:0] same);
          assign same = value;
        endmodule

        module top(input logic [15:0] data, output logic [15:0] result);
          for (genvar i = 0; i < 2; i++) begin : g_lane
            logic signed [7:0] lane;
            assign lane = $signed(data[i*8 +: 8]);
            leaf u_leaf(.value(lane), .same(result[i*8 +: 8]));
          end
        endmodule
        """,
    )

    header = generate_systemc_header(design)
    assert "sc_signal<sc_int<8>> g_lane_0_lane;" in header
    assert "sc_signal<sc_int<8>> g_lane_1_lane;" in header
    assert "g_lane_0_u_leaf.value(g_lane_0_lane);" in header
    assert "g_lane_1_u_leaf.value(g_lane_1_lane);" in header
    assert header.count("sc_signal<sc_int<8>> lane;") == 0
