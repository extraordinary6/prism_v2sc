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
    assert "wrote SystemC module" in captured.out

    ir_path = out_dir / "ir.json"
    assert ir_path.is_file()
    payload = json.loads(ir_path.read_text(encoding="utf-8"))
    assert payload["top"] == "top"
    assert payload["modules"][0]["name"] == "top"
    assigns = payload["modules"][0]["continuous_assigns"]
    assert len(assigns) == 1
    assert assigns[0]["left"] == "y"
    assert assigns[0]["right"] == "a"

    # No umbrella anymore — the per-module file is the entry point.
    assert not (out_dir / "prism_v2sc.hpp").exists()
    header = (out_dir / "top.hpp").read_text(encoding="utf-8")
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
    nba = modules["child"]["processes"][0]["structured_statements"][0]
    assert nba["type"] == "nonblocking_assign"
    assert nba["left"] == "y"
    assert nba["right"] == "a"
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
    rtl = tmp_path / "for_top.v"
    rtl.write_text(
        """
module for_top(input wire [1:0] a, output reg [1:0] y);
  integer i;
  always @(*) begin
    for (i = 0; i < 2; i = i + 1) begin
      y[i] = a[i];
    end
  end
endmodule
""",
        encoding="utf-8",
    )
    out_dir = tmp_path / "systemc"

    assert main(["--top", "for_top", "--fail-on-diagnostics", "--out", str(out_dir), str(rtl)]) == 2
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


def test_cli_accepts_filelist_input(tmp_path: Path, capsys) -> None:
    leaf = tmp_path / "leaf.v"
    top = tmp_path / "top.v"
    filelist = tmp_path / "sources.f"
    out_dir = tmp_path / "systemc"

    leaf.write_text(
        """
module leaf(input wire a, output wire y);
  assign y = a;
endmodule
""",
        encoding="utf-8",
    )
    top.write_text(
        """
module top(input wire a, output wire y);
  leaf u_leaf(.a(a), .y(y));
endmodule
""",
        encoding="utf-8",
    )
    filelist.write_text(
        """
# comment line
// comment line
leaf.v
top.v
""",
        encoding="utf-8",
    )

    assert main(["--top", "top", "--filelist", str(filelist), "--out", str(out_dir)]) == 0
    payload = json.loads((out_dir / "ir.json").read_text(encoding="utf-8"))
    assert {module["name"] for module in payload["modules"]} == {"top", "leaf"}
    assert "wrote Phase 1 IR" in capsys.readouterr().out


def test_cli_combines_positional_sources_and_filelist_with_dedup(tmp_path: Path) -> None:
    leaf = tmp_path / "leaf.v"
    top = tmp_path / "top.v"
    extra = tmp_path / "extra_unused.v"
    filelist = tmp_path / "sources.f"

    leaf.write_text(
        "module leaf(input wire a, output wire y); assign y = a; endmodule\n",
        encoding="utf-8",
    )
    top.write_text(
        "module top(input wire a, output wire y); leaf u_leaf(.a(a), .y(y)); endmodule\n",
        encoding="utf-8",
    )
    extra.write_text(
        "module extra_unused(input wire a, output wire y); assign y = ~a; endmodule\n",
        encoding="utf-8",
    )
    filelist.write_text(
        """
leaf.v
top.v
""",
        encoding="utf-8",
    )

    out_dir = tmp_path / "systemc"
    assert (
        main(
            [
                "--top",
                "top",
                "--filelist",
                str(filelist),
                "--out",
                str(out_dir),
                str(leaf),
                str(extra),
            ]
        )
        == 0
    )
    payload = json.loads((out_dir / "ir.json").read_text(encoding="utf-8"))
    # Reachability filter should keep top + leaf only, and dedupe leaf source.
    assert {module["name"] for module in payload["modules"]} == {"top", "leaf"}


def test_cli_passes_filelist_include_dirs_and_defines_to_parser(tmp_path: Path) -> None:
    include_dir = tmp_path / "inc"
    include_dir.mkdir()
    defs = include_dir / "defs.vh"
    top = tmp_path / "top.v"
    filelist = tmp_path / "sources.f"
    out_dir = tmp_path / "systemc"

    defs.write_text("`define WIDTH 8\n", encoding="utf-8")
    top.write_text(
        """
`include "defs.vh"
module top(
  input wire [`WIDTH-1:0] a,
`ifdef USE_INVERT
  output wire [`WIDTH-1:0] y
);
  assign y = ~a;
`else
  output wire [`WIDTH-1:0] y
);
  assign y = a;
`endif
endmodule
""",
        encoding="utf-8",
    )
    filelist.write_text(
        """
+incdir+inc
-DUSE_INVERT
top.v
""",
        encoding="utf-8",
    )

    assert main(["--top", "top", "--filelist", str(filelist), "--out", str(out_dir)]) == 0

    payload = json.loads((out_dir / "ir.json").read_text(encoding="utf-8"))
    top_module = payload["modules"][0]
    # slang resolves ``[WIDTH-1:0]`` to ``[7:0]`` during elaboration; the
    # pyverilog path leaves the textual ``(8 - 1)`` form intact. Accept
    # either — what matters for this test is that include-dir + define
    # both flowed through to the parser at all.
    assert top_module["ports"][0]["width"] in (
        {"msb": "(8 - 1)", "lsb": "0"},
        {"msb": "7", "lsb": "0"},
    )
    assigns = top_module["continuous_assigns"]
    assert len(assigns) == 1
    assert assigns[0]["left"] == "y"
    assert assigns[0]["right"] == "(~a)"
