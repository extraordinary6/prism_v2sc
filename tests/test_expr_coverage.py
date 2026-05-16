"""Tests for expanded Verilog expression coverage (post-tree-IR refactor)."""

from __future__ import annotations

from pathlib import Path

from prism_v2sc.codegen.systemc import generate_systemc_header
from prism_v2sc.frontend.lower import lower_design
from prism_v2sc.frontend.pyverilog_parser import parse_verilog


def _design(tmp_path: Path, source: str, top: str):
    rtl = tmp_path / f"{top}.v"
    rtl.write_text(source, encoding="utf-8")
    return lower_design(parse_verilog([rtl]), top)


def test_concat_in_continuous_assign(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module concat_top(
  input wire [3:0] a,
  input wire [3:0] b,
  output wire [7:0] y
);
  assign y = {a, b};
endmodule
""",
        "concat_top",
    )
    header = generate_systemc_header(design)
    # Concat must compile as bit-shifted OR of sc_uint-cast operands.
    assert "sc_uint<8>(a.read()) << 4" in header
    assert "| sc_uint<8>(b.read())" in header
    # Sensitivity must list both signals, no phantom names.
    assert "sensitive << a << b;" in header


def test_replicate_in_continuous_assign(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module repeat_top(
  input wire sel,
  input wire [7:0] data,
  output wire [7:0] y
);
  assign y = data ^ {8{sel}};
endmodule
""",
        "repeat_top",
    )
    header = generate_systemc_header(design)
    # 8-way replicate emits eight OR'd casts of sel.
    assert header.count("sc_uint<8>(sel.read())") >= 8
    # Sensitivity must list data + sel only — no 'b0', 'h00' or other literal residue.
    assert "sensitive << data << sel;" in header
    assert " b0" not in header.split("SC_CTOR")[1]
    assert " h" not in " ".join(line for line in header.splitlines() if "sensitive" in line)


def test_part_select_and_bit_select_read(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module probe(
  input  wire [15:0] data,
  output wire [7:0]  lo,
  output wire [7:0]  hi,
  output wire        bit3
);
  assign lo   = data[7:0];
  assign hi   = data[15:8];
  assign bit3 = data[3];
endmodule
""",
        "probe",
    )
    header = generate_systemc_header(design)
    assert "data.read().range(7, 0)" in header
    assert "data.read().range(15, 8)" in header
    assert "data.read()[3]" in header


def test_generate_if_picks_true_branch(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module config_top #(parameter MODE = 1) (
  input  wire [7:0] a,
  input  wire [7:0] b,
  output wire [7:0] y
);
  generate
    if (MODE == 1) begin : g_xor
      assign y = a ^ b;
    end else begin : g_and
      assign y = a & b;
    end
  endgenerate
endmodule
""",
        "config_top",
    )
    header = generate_systemc_header(design)
    assert "(a.read() ^ b.read())" in header
    assert "(a.read() & b.read())" not in header
    # No diagnostic about the if since MODE evaluates statically.
    assert design.diagnostics == ()


def test_generate_if_picks_false_branch(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module config_top #(parameter MODE = 0) (
  input  wire [7:0] a,
  input  wire [7:0] b,
  output wire [7:0] y
);
  generate
    if (MODE == 1) begin : g_xor
      assign y = a ^ b;
    end else begin : g_and
      assign y = a & b;
    end
  endgenerate
endmodule
""",
        "config_top",
    )
    header = generate_systemc_header(design)
    assert "(a.read() & b.read())" in header
    assert "(a.read() ^ b.read())" not in header


def test_phantom_sensitivity_filtered_from_sized_literal(tmp_path: Path) -> None:
    """Sized literals must not leak their base prefix into the sensitivity list."""
    design = _design(
        tmp_path,
        """
module masker(
  input  wire [7:0] data_in,
  output wire [7:0] data_out
);
  assign data_out = data_in ^ 8'hAA;
endmodule
""",
        "masker",
    )
    header = generate_systemc_header(design)
    sensitive_line = next(line for line in header.splitlines() if "sensitive" in line and "<<" in line)
    assert "hAA" not in sensitive_line
    assert "data_in" in sensitive_line


def test_bit_select_lhs_in_always_ff_uses_staged_target(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module reg_bit(
  input wire clk,
  input wire rst_n,
  input wire a,
  input wire b,
  output reg [1:0] q
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 2'b00;
    end else begin
      q[0] <= a;
      q[1] <= b;
    end
  end
endmodule
""",
        "reg_bit",
    )
    header = generate_systemc_header(design)
    assert "auto __next_q = q.read();" in header
    assert "__next_q[0] = a.read();" in header
    assert "__next_q[1] = b.read();" in header
    assert "q.write(__next_q);" in header


def test_part_select_lhs_in_always_ff(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module reg_part(
  input wire clk,
  input wire rst_n,
  input wire [3:0] din,
  output reg [7:0] q
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 8'h00;
    end else begin
      q[3:0] <= din;
    end
  end
endmodule
""",
        "reg_part",
    )
    header = generate_systemc_header(design)
    assert "auto __next_q = q.read();" in header
    assert "__next_q.range(3, 0) = din.read();" in header
    assert "q.write(__next_q);" in header


def test_reduction_operators(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module reducer(
  input  wire [7:0] data,
  output wire and_all,
  output wire or_all,
  output wire xor_all
);
  assign and_all = &data;
  assign or_all  = |data;
  assign xor_all = ^data;
endmodule
""",
        "reducer",
    )
    header = generate_systemc_header(design)
    assert "data.read().and_reduce()" in header
    assert "data.read().or_reduce()" in header
    assert "data.read().xor_reduce()" in header
