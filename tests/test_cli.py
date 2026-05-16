from __future__ import annotations

import json
from pathlib import Path

from prism_v2sc.cli import main


def test_cli_writes_ir_and_systemc_header(tmp_path: Path, capsys) -> None:
    rtl = tmp_path / "top.v"
    rtl.write_text("module top(input a, output y); assign y = a; endmodule\n", encoding="utf-8")
    out_dir = tmp_path / "systemc"

    assert main(["--top", "top", "--out", str(out_dir), str(rtl)]) == 0

    captured = capsys.readouterr()
    assert "wrote Phase 1 IR" in captured.out
    assert "wrote SystemC header" in captured.out

    ir_path = out_dir / "ir.json"
    assert ir_path.is_file()
    payload = json.loads(ir_path.read_text(encoding="utf-8"))
    assert payload["top"] == "top"
    assert payload["modules"][0]["name"] == "top"
    assert payload["modules"][0]["continuous_assigns"] == [{"left": "y", "right": "a"}]

    header = (out_dir / "prism_v2sc.hpp").read_text(encoding="utf-8")
    assert "SC_MODULE(top)" in header
    assert "sc_in<bool> a;" in header
    assert "sc_out<bool> y;" in header
    assert "void assign_0()" in header
    assert "y.write(a.read());" in header
    assert "SC_METHOD(assign_0);" in header


def test_cli_dump_ir_captures_structure(tmp_path: Path, capsys) -> None:
    rtl = tmp_path / "design.v"
    rtl.write_text(
        """
module child #(parameter WIDTH = 8) (
  input wire clk,
  input wire [WIDTH-1:0] a,
  output reg [WIDTH-1:0] y
);
  always @(posedge clk) begin
    y <= a;
  end
endmodule

module top (
  input wire clk,
  input wire [7:0] a,
  output wire [7:0] y
);
  wire [7:0] tmp;
  assign tmp = a;
  child #(.WIDTH(8)) u_child(.clk(clk), .a(tmp), .y(y));
endmodule
""",
        encoding="utf-8",
    )

    assert main(["--top", "top", "--dump-ir", str(rtl)]) == 0

    payload = json.loads(capsys.readouterr().out)
    modules = {module["name"]: module for module in payload["modules"]}
    assert payload["top"] == "top"
    assert modules["child"]["parameters"] == [{"kind": "parameter", "name": "WIDTH", "value": "8"}]
    assert modules["child"]["processes"][0]["kind"] == "always_ff"
    assert modules["child"]["processes"][0]["statements"] == ["y <= a"]
    assert modules["child"]["processes"][0]["structured_statements"][0] == {
        "left": "y",
        "right": "a",
        "type": "nonblocking_assign",
    }
    assert modules["top"]["signals"][0]["name"] == "tmp"
    assert modules["top"]["signals"][0]["width"] == {"msb": "7", "lsb": "0"}
    assert modules["top"]["instances"][0]["module"] == "child"
    assert modules["top"]["instances"][0]["name"] == "u_child"


def test_cli_writes_phase5_metrics(tmp_path: Path, capsys) -> None:
    rtl = tmp_path / "top.v"
    rtl.write_text("module top(input a, output y); assign y = a; endmodule\n", encoding="utf-8")
    out_dir = tmp_path / "systemc"

    assert main(["--top", "top", "--metrics", "--out", str(out_dir), str(rtl)]) == 0

    captured = capsys.readouterr()
    assert "wrote Phase 5 metrics" in captured.out

    metrics = json.loads((out_dir / "metrics.json").read_text(encoding="utf-8"))
    assert metrics["top"] == "top"
    assert metrics["module_count"] == 1
    assert metrics["port_count"] == 2
    assert metrics["peak_python_bytes"] >= 0
    assert metrics["parse_lower"]["elapsed_seconds"] >= 0
    assert metrics["verilator_lint"]["tool"] == "verilator"


def test_cli_can_fail_on_error_diagnostics(tmp_path: Path, capsys) -> None:
    rtl = tmp_path / "case_top.v"
    rtl.write_text(
        """
module case_top(input wire [1:0] sel, output reg y);
  always @(*) begin
    case (sel)
      2'b00: y = 1'b0;
      default: y = 1'b1;
    endcase
  end
endmodule
""",
        encoding="utf-8",
    )
    out_dir = tmp_path / "systemc"

    assert main(["--top", "case_top", "--fail-on-diagnostics", "--out", str(out_dir), str(rtl)]) == 2
    assert "diagnostics: 1 error(s)" in capsys.readouterr().out


def test_cli_can_fail_on_phase3_driver_conflicts(tmp_path: Path, capsys) -> None:
    rtl = tmp_path / "driver_conflict.v"
    rtl.write_text(
        """
module driver_conflict(
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
    out_dir = tmp_path / "systemc"

    assert main(["--top", "driver_conflict", "--fail-on-diagnostics", "--out", str(out_dir), str(rtl)]) == 2
    output = capsys.readouterr().out
    assert "diagnostics: 2 error(s)" in output
