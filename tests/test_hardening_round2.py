from __future__ import annotations

from pathlib import Path

from prism_v2sc.codegen.systemc import generate_systemc_header
from prism_v2sc.frontend.lower import lower_design
from prism_v2sc.frontend.pyverilog_parser import parse_verilog
from prism_v2sc.verify.static_checks import check_generated_systemc


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

    design = lower_design(parse_verilog([rtl]), "sched")
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

    design = lower_design(parse_verilog([rtl]), "top")
    header = generate_systemc_header(design)

    assert "sc_signal<bool> __bridge_u0_a;" in header
    assert "sc_signal<bool> __bridge_u0_y;" in header
    assert "u0.a(__bridge_u0_a);" in header
    assert "u0.y(__bridge_u0_y);" in header
    assert "__bridge_u0_a.write(a.read()[0]);" in header
    assert "__tmp[0] = __bridge_u0_y.read();" in header
    assert "y.write(__tmp);" in header


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

    design = lower_design(parse_verilog([rtl]), "top")
    header = generate_systemc_header(design)

    assert check_generated_systemc(header) == ()
