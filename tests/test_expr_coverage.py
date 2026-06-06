"""Tests for expanded Verilog expression coverage (post-tree-IR refactor)."""

from __future__ import annotations

from pathlib import Path

import pytest

from prism_v2sc.codegen.systemc import generate_systemc_header

from _pyslang_helper import lower_via_pyslang


def _design(tmp_path: Path, source: str, top: str):
    rtl = tmp_path / f"{top}.v"
    rtl.write_text(source, encoding="utf-8")
    return lower_via_pyslang([rtl], top)


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


def test_sized_integer_literal_value_is_parsed_not_zero(tmp_path: Path) -> None:
    """Regression: case-item values like ``3'b001`` were emitted as IR value=0
    because ``int(str(SVInt))`` raises on slang's formatted output. The IR
    ``value`` field must reflect the actual integer the literal represents."""
    design = _design(
        tmp_path,
        """
module case_demo(input wire [2:0] op, output reg [7:0] out);
  always @(*) begin
    case (op)
      3'b001: out = 8'h11;
      3'b010: out = 8'h22;
      3'b111: out = 8'hFF;
      default: out = 8'h00;
    endcase
  end
endmodule
""",
        "case_demo",
    )
    module = design.modules[0]
    case_items = module.processes[0].structured_statements[0]["items"]
    seen_values = []
    for item in case_items:
        for cond in item.get("cond_exprs", ()):
            if cond.get("kind") == "intconst":
                seen_values.append((cond["raw"], cond["value"]))
    assert ("3'b001", 1) in seen_values
    assert ("3'b010", 2) in seen_values
    assert ("3'b111", 7) in seen_values

    # Also covers RHS hex literals (8'h11 = 17, 8'hFF = 255).
    rhs_values = {}
    for item in case_items:
        for stmt in item.get("statements", ()):
            rhs = stmt.get("right_expr", {})
            if rhs.get("kind") == "intconst":
                rhs_values[rhs["raw"]] = rhs["value"]
    assert rhs_values["8'h11"] == 0x11
    assert rhs_values["8'h22"] == 0x22
    assert rhs_values["8'hFF"] == 0xFF


def test_unary_bitwise_not_on_one_bit_signal_uses_logical_not(tmp_path: Path) -> None:
    """Regression: ``~`` on a ``sc_in<bool>`` widens to int in C++ and inverts
    every bit of the int, so ``~true`` (== -2) and ``~false`` (== -1) both
    round-trip back to ``true``. Verilog ``~`` on a 1-bit signal is logical
    inversion, so codegen must emit ``!`` instead when the operand is 1-bit.
    The bug stayed hidden under pyverilog because generate-for left bit-level
    inverters wrapped in vector contexts; once slang unrolled them into
    scalar-port subcells the equivalence harness caught it."""
    design = _design(
        tmp_path,
        """
module inv1(input wire a, output wire y);
  assign y = ~a;
endmodule
""",
        "inv1",
    )
    header = generate_systemc_header(design)
    assert "y.write((!a.read()));" in header
    assert "~a.read()" not in header


def test_unary_bitwise_not_on_multi_bit_signal_still_uses_tilde(tmp_path: Path) -> None:
    """Counterpart: on multi-bit ``sc_uint<N>`` operands ``~`` is the correct
    bitwise inverter, so we must not over-correct and replace it with ``!``."""
    design = _design(
        tmp_path,
        """
module inv8(input wire [7:0] a, output wire [7:0] y);
  assign y = ~a;
endmodule
""",
        "inv8",
    )
    header = generate_systemc_header(design)
    assert "y.write((~a.read()));" in header


def test_unary_bitwise_not_on_unknown_width_keeps_tilde(tmp_path: Path) -> None:
    """Regression for over-correction: the previous fix gated ``~`` → ``!``
    on ``infer_width == 1``, but ``infer_width`` falls back to 1 for unknown
    identifiers (notably function-local params), which silently turned every
    ``~x`` inside a synthesizable Verilog ``function`` into a logical ``!``.
    Unknown widths must stay as ``~`` — only *provably* 1-bit operands get
    rewritten."""
    design = _design(
        tmp_path,
        """
module fn_inv(input wire [7:0] a, output reg [7:0] y);
  function [7:0] inv8;
    input [7:0] x;
    begin
      inv8 = ~x;
    end
  endfunction
  always @(*) begin
    y = inv8(a);
  end
endmodule
""",
        "fn_inv",
    )
    header = generate_systemc_header(design)
    # Inside the function, ``x`` is a parameter — its width is not visible
    # to ``ctx.signal_widths``. We must NOT rewrite to ``!`` here.
    assert "inv8 = (~x);" in header
    assert "inv8 = (!x);" not in header


def test_dollar_signed_emits_sc_int_cast(tmp_path: Path) -> None:
    """``$signed(x)`` was previously a no-op in codegen, which silently
    turned ``$signed(x) >>> n`` into a logical right shift on the
    underlying ``sc_uint`` operand. The fix emits a real ``sc_int<W>``
    cast so the ``>>`` lands on a signed type and arithmetic-shifts."""
    design = _design(
        tmp_path,
        """
module sshift(input wire [7:0] x, input wire [2:0] n, output wire [7:0] y);
  assign y = $signed(x) >>> n;
endmodule
""",
        "sshift",
    )
    header = generate_systemc_header(design)
    assert "sc_int<8>(x.read())" in header
    # Plain ``x.read() >> n.read()`` (the old buggy form) must not appear.
    assert "y.write((x.read() >> n.read())" not in header


def test_dollar_unsigned_emits_sc_uint_cast(tmp_path: Path) -> None:
    """``$unsigned(x)`` becomes a real ``sc_uint<W>`` cast (counterpart to
    the ``$signed`` fix). On already-unsigned operands the cast is
    redundant but harmless; on signed operands it suppresses the
    arithmetic-shift behavior, matching Verilog semantics."""
    design = _design(
        tmp_path,
        """
module ushift(input wire signed [7:0] x, input wire [2:0] n, output wire [7:0] y);
  assign y = $unsigned(x) >>> n;
endmodule
""",
        "ushift",
    )
    header = generate_systemc_header(design)
    assert "sc_uint<8>(x.read())" in header


def test_signed_declared_ports_and_signals_emit_sc_int(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module signed_decl(
  input  wire signed [7:0] a,
  output reg  signed [8:0] y
);
  reg signed [8:0] acc;
  always @(*) begin
    acc = a;
    y = acc;
  end
endmodule
""",
        "signed_decl",
    )
    header = generate_systemc_header(design)
    assert "sc_in<sc_int<8>> a;" in header
    assert "sc_out<sc_int<9>> y;" in header
    assert "sc_signal<sc_int<9>> acc;" in header


def test_one_bit_signed_decl_does_not_collapse_to_bool(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module signed_one_bit(
  input  wire signed a,
  output wire signed y
);
  assign y = a;
endmodule
""",
        "signed_one_bit",
    )
    header = generate_systemc_header(design)
    assert "sc_in<sc_int<1>> a;" in header
    assert "sc_out<sc_int<1>> y;" in header
    assert "sc_in<bool> a;" not in header
    assert "sc_out<bool> y;" not in header


def test_signed_based_literal_preserves_bit_pattern_and_signed_value(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module signed_literal(output wire signed [7:0] y);
  assign y = 8'shFF;
endmodule
""",
        "signed_literal",
    )
    assign = design.modules[0].continuous_assigns[0]
    expr = assign.right_expr
    assert expr["kind"] == "intconst"
    assert expr["raw"] == "8'shFF"
    assert expr["value"] == 0xFF
    assert expr["signed"] is True
    assert expr["signed_value"] == -1

    header = generate_systemc_header(design)
    assert "y.write(-1);" in header
    assert "y.write(0);" not in header


def test_signed_based_literal_case_label_uses_bit_pattern(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module signed_literal_case(input wire [3:0] op, output reg hit);
  always @(*) begin
    case (op)
      4'shF: hit = 1'b1;
      default: hit = 1'b0;
    endcase
  end
endmodule
""",
        "signed_literal_case",
    )
    header = generate_systemc_header(design)
    assert "case 15:" in header
    assert "case -1:" not in header


def test_explicit_sv_signed_cast_is_preserved(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module sv_signed_cast(input wire [7:0] x, input wire [2:0] n, output wire [7:0] y);
  assign y = signed'(x) >>> n;
endmodule
""",
        "sv_signed_cast",
    )
    header = generate_systemc_header(design)
    assert "sc_int<8>(x.read())" in header
    assert "y.write((x.read() >> n.read())" not in header


def test_explicit_sv_unsigned_cast_is_preserved(tmp_path: Path) -> None:
    design = _design(
        tmp_path,
        """
module sv_unsigned_cast(input wire signed [7:0] x, input wire [2:0] n, output wire [7:0] y);
  assign y = unsigned'(x) >>> n;
endmodule
""",
        "sv_unsigned_cast",
    )
    header = generate_systemc_header(design)
    assert "sc_uint<8>(x.read())" in header
