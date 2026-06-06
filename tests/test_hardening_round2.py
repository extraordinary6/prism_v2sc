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
    assert "bus__rsp.write((bus__valid.read() ? (bus__req.read() + bias.read()) : (bias.read() ^ 0x55)));" in header


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
