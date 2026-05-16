from __future__ import annotations

from pathlib import Path

from prism_v2sc.frontend.lower import lower_design
from prism_v2sc.frontend.pyverilog_parser import parse_verilog
from prism_v2sc.verify import harness
from prism_v2sc.verify.harness import convert_with_metrics


def test_phase5_realistic_rtl_subset_metrics(tmp_path: Path) -> None:
    rtl = tmp_path / "pipeline.v"
    rtl.write_text(
        """
module stage #(parameter WIDTH = 8) (
  input wire clk,
  input wire rst_n,
  input wire valid_i,
  input wire [WIDTH-1:0] data_i,
  output reg valid_o,
  output reg [WIDTH-1:0] data_o
);
  wire [WIDTH-1:0] mixed;
  assign mixed = data_i ^ {WIDTH{valid_i}};

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_o <= 1'b0;
      data_o <= {WIDTH{1'b0}};
    end else begin
      valid_o <= valid_i;
      data_o <= mixed;
    end
  end
endmodule

module pipeline_top #(parameter WIDTH = 8) (
  input wire clk,
  input wire rst_n,
  input wire valid_i,
  input wire [WIDTH-1:0] data_i,
  output wire valid_o,
  output wire [WIDTH-1:0] data_o
);
  wire mid_valid;
  wire [WIDTH-1:0] mid_data;

  stage #(.WIDTH(WIDTH)) u0(
    .clk(clk), .rst_n(rst_n), .valid_i(valid_i), .data_i(data_i),
    .valid_o(mid_valid), .data_o(mid_data)
  );
  stage #(.WIDTH(WIDTH)) u1(
    .clk(clk), .rst_n(rst_n), .valid_i(mid_valid), .data_i(mid_data),
    .valid_o(valid_o), .data_o(data_o)
  );
endmodule
""",
        encoding="utf-8",
    )

    artifacts = convert_with_metrics([rtl], "pipeline_top")

    assert artifacts.report.module_count == 2
    assert artifacts.report.instance_count == 2
    assert artifacts.report.process_count == 1
    assert artifacts.report.diagnostic_count == 0
    assert artifacts.report.parse_lower.elapsed_seconds >= 0
    assert artifacts.report.codegen.peak_python_bytes > 0
    assert "stage<WIDTH> u0;" in artifacts.header
    assert "stage<WIDTH> u1;" in artifacts.header


def test_unsupported_case_is_reported_in_ir(tmp_path: Path) -> None:
    rtl = tmp_path / "decode.v"
    rtl.write_text(
        """
module decode(input wire [1:0] sel, output reg [3:0] y);
  always @(*) begin
    case (sel)
      2'b00: y = 4'b0001;
      2'b01: y = 4'b0010;
      default: y = 4'b1000;
    endcase
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_design(parse_verilog([rtl]), "decode")

    assert len(design.diagnostics) == 1
    diagnostic = design.diagnostics[0]
    assert diagnostic.severity == "error"
    assert diagnostic.module == "decode"
    assert diagnostic.code == "unsupported_case"
    assert diagnostic.node == "CaseStatement"


def test_windows_verilator_wrapper_discovery(monkeypatch, tmp_path: Path) -> None:
    bin_dir = tmp_path / "mingw64" / "bin"
    usr_bin_dir = tmp_path / "mingw64" / "usr" / "bin"
    real_bin_dir = tmp_path / "mingw64" / "share" / "verilator" / "bin"
    bin_dir.mkdir(parents=True)
    usr_bin_dir.mkdir(parents=True)
    real_bin_dir.mkdir(parents=True)
    (bin_dir / "verilator").write_text("#!/usr/bin/perl\n", encoding="utf-8")
    perl = usr_bin_dir / "perl.exe"
    perl.write_text("", encoding="utf-8")
    wrapper = real_bin_dir / "verilator"
    wrapper.write_text("#!/usr/bin/env perl\n", encoding="utf-8")
    real_binary = real_bin_dir / "verilator_bin.exe"
    real_binary.write_text("", encoding="utf-8")

    monkeypatch.setattr(harness.shutil, "which", lambda _name: None)
    monkeypatch.setattr(harness.sys, "platform", "win32")
    monkeypatch.setenv("PATH", str(bin_dir))

    assert harness._find_verilator_command() == (str(perl), str(wrapper))


def test_verilator_root_is_inferred_from_share_binary(tmp_path: Path) -> None:
    root = tmp_path / "share" / "verilator"
    bin_dir = root / "bin"
    include_dir = root / "include"
    bin_dir.mkdir(parents=True)
    include_dir.mkdir()
    binary = bin_dir / "verilator_bin.exe"
    binary.write_text("", encoding="utf-8")
    (include_dir / "verilated_std.sv").write_text("", encoding="utf-8")

    assert harness._infer_verilator_root((str(binary),)) == root
