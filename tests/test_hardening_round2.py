from __future__ import annotations

from pathlib import Path

from prism_v2sc.codegen.systemc import generate_systemc_header
from prism_v2sc.verify.static_checks import check_generated_systemc

from _pyslang_helper import lower_via_pyslang


def test_multiple_procedural_blocks_emit_scheduler_warning(tmp_path: Path) -> None:
    rtl = tmp_path / "sched.v"
    rtl.write_text(
        """
module sched(input wire clk, input wire a, output reg q, output reg r);
  always @(posedge clk) begin
    q <= a;
  end
  always @(*) begin
    r = q;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "sched")
    diagnostics = [diagnostic for diagnostic in design.diagnostics if diagnostic.code == "event_scheduler_approximated"]

    assert len(diagnostics) == 1
    assert diagnostics[0].severity == "warning"


def test_direct_instance_bit_select_binding_uses_scalar_bridge(tmp_path: Path) -> None:
    rtl = tmp_path / "direct_bridge.v"
    rtl.write_text(
        """
module bitcell(input wire a, output wire y);
  assign y = a;
endmodule

module top(input wire [1:0] a, output wire [1:0] y);
  bitcell u0(.a(a[0]), .y(y[0]));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "top")
    header = generate_systemc_header(design)

    assert "sc_signal<bool> __bridge_u0_a;" in header
    assert "sc_signal<bool> __bridge_u0_y;" in header
    assert "u0.a(__bridge_u0_a);" in header
    assert "u0.y(__bridge_u0_y);" in header
    assert "__bridge_u0_a.write(a.read()[0]);" in header
    assert "__tmp[0] = __bridge_u0_y.read();" in header
    assert "y.write(__tmp);" in header


def test_input_expression_binding_uses_bridge_and_empty_output_uses_dummy(tmp_path: Path) -> None:
    rtl = tmp_path / "expr_bridge.sv"
    rtl.write_text(
        """
module child(input wire [31:0] acc_done, output wire [7:0] unused, output wire seen);
  assign unused = acc_done[7:0];
  assign seen = acc_done[0];
endmodule

module top(input wire done, output wire seen);
  child u(.acc_done({31'b0, done}), .unused(), .seen(seen));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "top")
    header = generate_systemc_header(design)

    assert "sc_signal<sc_uint<32>> __bridge_u_acc_done;" in header
    assert "sc_signal<sc_uint<8>> __unused_u_unused;" in header
    assert "u.acc_done(__bridge_u_acc_done);" in header
    assert "u.unused(__unused_u_unused);" in header
    assert "__bridge_u_acc_done.write(" in header
    assert "done.read()" in header
    assert "SC_METHOD(__bridge_method_u_acc_done);" in header
    assert "sensitive << done;" in header


def test_array_element_port_bridge_casts_between_parent_and_child_types(tmp_path: Path) -> None:
    rtl = tmp_path / "array_expr_bridge.sv"
    rtl.write_text(
        """
module child(input wire signed [7:0] a, output wire signed [15:0] y);
  assign y = a;
endmodule

module top(input wire [7:0] din, output wire [15:0] dout);
  wire [7:0] grid [0:0][0:0];
  wire [15:0] result [0:0][0:0];
  assign grid[0][0] = din;
  assign dout = result[0][0];
  child u(.a(grid[0][0]), .y(result[0][0]));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "top")
    header = generate_systemc_header(design)

    assert "sc_signal<sc_int<8>> __bridge_u_a;" in header
    assert "sc_signal<sc_int<16>> __bridge_u_y;" in header
    assert "__bridge_u_a.write(sc_int<8>(grid[0][0].read()));" in header
    assert "result[0][0].write(sc_uint<16>(__bridge_u_y.read()));" in header


def test_one_dimensional_array_cell_uses_only_expression_bridge(tmp_path: Path) -> None:
    rtl = tmp_path / "array_cell_bridge.sv"
    rtl.write_text(
        """
module child(input wire [2:0] a, output wire [6:0] y);
  assign y = a;
endmodule

module top(input wire [2:0] din, output wire [6:0] dout);
  wire [2:0] inputs [0:0];
  wire [6:0] outputs [0:0];
  assign inputs[0] = din;
  assign dout = outputs[0];
  child u(.a(inputs[0]), .y(outputs[0]));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "top")
    header = generate_systemc_header(design)

    assert header.count("sc_signal<sc_uint<3>> __bridge_u_a;") == 1
    assert header.count("sc_signal<sc_uint<7>> __bridge_u_y;") == 1
    assert "sc_signal<sc_uint<1>> __bridge_u_a;" not in header
    assert "sc_signal<sc_uint<1>> __bridge_u_y;" not in header
    assert "__bridge_u_a.write(sc_uint<3>(inputs[0].read()));" in header
    assert "outputs[0].write(sc_uint<7>(__bridge_u_y.read()));" in header


def test_inout_ports_use_resolved_systemc_and_hierarchical_binding(tmp_path: Path) -> None:
    rtl = tmp_path / "inout_bus.sv"
    rtl.write_text(
        """
module inout_cell(input wire oe, input wire [3:0] din, inout wire [3:0] pad, output wire [3:0] seen);
  assign pad = oe ? din : 4'bzzzz;
  assign seen = pad;
endmodule

module inout_bus(input wire oe, input wire [3:0] din, inout wire [3:0] bus, output wire [3:0] seen, output wire [3:0] mixed);
  inout_cell u(.oe(oe), .din(din), .pad(bus), .seen(seen));
  assign mixed = bus ^ 4'hA;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "inout_bus")
    header = generate_systemc_header(design)

    assert "sc_inout_rv<4> pad;" in header
    assert "sc_inout_rv<4> bus;" in header
    assert 'pad.write((oe.read() ? sc_lv<4>(sc_uint<4>(din.read())) : sc_lv<4>("ZZZZ")));' in header
    assert "seen.write(sc_uint<4>(pad.read().to_uint64()));" in header
    assert "mixed.write((sc_uint<4>(bus.read().to_uint64()) ^ 0xA));" in header
    assert "u.pad(bus);" in header


def test_non_inout_xz_continuous_assign_stays_two_state(tmp_path: Path) -> None:
    rtl = tmp_path / "z_out.v"
    rtl.write_text("module z_out(output wire y); assign y = 1'bz; endmodule\n", encoding="utf-8")

    design = lower_via_pyslang([rtl], "z_out")
    header = generate_systemc_header(design)

    assert any(diagnostic.code == "x_z_literal_approximated" for diagnostic in design.diagnostics)
    assert "sc_out<bool> y;" in header
    assert "y.write(0);" in header
    assert 'y.write(sc_lv<1>("Z"));' not in header


def test_interface_modport_flattens_to_plain_ports_and_signals(tmp_path: Path) -> None:
    rtl = tmp_path / "interface_modport.sv"
    rtl.write_text(
        """
interface stream_if;
  logic [7:0] req;
  logic [7:0] rsp;
  logic valid;
  modport master(output req, output valid, input rsp);
  modport slave(input req, input valid, output rsp);
endinterface

module iface_source(input wire [7:0] a, input wire en, stream_if.master bus, output wire [7:0] echo);
  assign bus.req = en ? (a ^ 8'h3c) : 8'h00;
  assign bus.valid = en;
  assign echo = bus.rsp;
endmodule

module iface_sink(stream_if.slave bus, input wire [7:0] bias, output wire [7:0] y);
  assign bus.rsp = bus.valid ? (bus.req + bias) : (bias ^ 8'h55);
  assign y = bus.rsp;
endmodule

module interface_modport(input wire [7:0] a, input wire [7:0] bias, input wire en, output wire [7:0] y, output wire [7:0] echo);
  stream_if bus();
  iface_source u_src(.a(a), .en(en), .bus(bus), .echo(echo));
  iface_sink u_sink(.bus(bus), .bias(bias), .y(y));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "interface_modport")
    modules = {module.name: module for module in design.modules}
    top = modules["interface_modport"]
    source = modules["iface_source"]
    sink = modules["iface_sink"]
    header = generate_systemc_header(design)

    assert not any(diagnostic.code == "unsupported_interface_port" for diagnostic in design.diagnostics)
    assert {signal.name for signal in top.signals} == {"bus__req", "bus__rsp", "bus__valid"}
    assert {instance.module for instance in top.instances} == {"iface_source", "iface_sink"}
    assert "stream_if" not in {instance.module for instance in top.instances}
    assert [(port.name, port.direction) for port in source.ports if port.name.startswith("bus__")] == [
        ("bus__req", "output"),
        ("bus__valid", "output"),
        ("bus__rsp", "input"),
    ]
    assert [(port.name, port.direction) for port in sink.ports if port.name.startswith("bus__")] == [
        ("bus__req", "input"),
        ("bus__valid", "input"),
        ("bus__rsp", "output"),
    ]
    assert "sc_signal<sc_uint<8>> bus__req;" in header
    assert "sc_signal<sc_uint<8>> bus__rsp;" in header
    assert "sc_signal<bool> bus__valid;" in header
    assert "u_src.bus__req(bus__req);" in header
    assert "u_sink.bus__rsp(bus__rsp);" in header
    assert "bus__req.write((bus__valid.read() ? (a.read() ^ 0x3c) : 0x00));" not in header
    assert (
        "bus__rsp.write((bus__valid.read() ? "
        "sc_uint<8>((bus__req.read() + bias.read())) : "
        "sc_uint<8>((bias.read() ^ 0x55))));"
    ) in header


def test_static_generated_systemc_checks_detect_fallbacks(tmp_path: Path) -> None:
    header = """
#include <systemc>
SC_MODULE(top) {
  // Unsupported statement: ForStatement
  // TODO: manual fallback
};
"""

    issues = check_generated_systemc(header)
    codes = {issue.code for issue in issues}

    assert codes == {"generated_todo", "generated_unsupported_statement"}


def test_static_generated_systemc_checks_accept_supported_header(tmp_path: Path) -> None:
    rtl = tmp_path / "top.v"
    rtl.write_text("module top(input wire a, output wire y); assign y = a; endmodule\n", encoding="utf-8")

    design = lower_via_pyslang([rtl], "top")
    header = generate_systemc_header(design)

    assert check_generated_systemc(header) == ()
