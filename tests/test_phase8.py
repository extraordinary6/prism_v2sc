from __future__ import annotations

from pathlib import Path

import pytest

from prism_v2sc.codegen.systemc import generate_systemc_header

from _pyslang_helper import lower_via_pyslang


def test_case_statement_emits_switch(tmp_path: Path) -> None:
    rtl = tmp_path / "decode.v"
    rtl.write_text(
        """
module decode(input wire [1:0] sel, output reg [3:0] y);
  always @(*) begin
    case (sel)
      2'b00: y = 4'b0001;
      2'b01, 2'b10: y = 4'b0010;
      default: y = 4'b1000;
    endcase
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "decode")
    header = generate_systemc_header(design)

    assert design.diagnostics == ()
    assert "switch (sel.read()) {" in header
    assert "case 0b00:" in header
    assert "case 0b01:" in header
    assert "case 0b10:" in header
    assert "default:" in header
    assert "__next_y = 0b1000;" in header
    assert "y.write(__next_y);" in header


def test_bit_select_driver_conflict_is_slice_aware(tmp_path: Path) -> None:
    rtl = tmp_path / "slices.v"
    rtl.write_text(
        """
module slices(input wire clk_a, input wire clk_b, input wire a, input wire b, output reg [1:0] q);
  always @(posedge clk_a) begin
    q[0] <= a;
  end
  always @(posedge clk_b) begin
    q[1] <= b;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "slices")

    assert not any(diagnostic.code == "multiple_procedural_drivers" for diagnostic in design.diagnostics)


def test_generate_bit_select_binding_uses_scalar_bridges(tmp_path: Path) -> None:
    """slang elaborates the generate-for into ``WIDTH`` flattened instances
    with disambiguated names (``g_0_u`` ... ``g_3_u``). Each per-iteration
    instance gets its own pair of scalar bridge signals and its own bridge
    SC_METHODs, and the genvar ``i`` in ``a[i]``/``y[i]`` resolves to the
    iteration's concrete index.
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
    header = generate_systemc_header(design)

    assert "TODO: bind bit-select" not in header
    # Each unrolled iteration owns disambiguated instance + bridge signals.
    for idx in range(4):
        assert f"bitcell g_{idx}_u;" in header
        assert f"sc_signal<bool> __bridge_g_{idx}_u_a;" in header
        assert f"sc_signal<bool> __bridge_g_{idx}_u_y;" in header
        assert f"g_{idx}_u.a(__bridge_g_{idx}_u_a);" in header
        assert f"g_{idx}_u.y(__bridge_g_{idx}_u_y);" in header
        # genvar `i` resolves to the iteration's concrete index in bridge methods.
        assert f"__bridge_g_{idx}_u_a.write(a.read()[{idx}]);" in header
        assert f"__tmp[{idx}] = __bridge_g_{idx}_u_y.read();" in header
    # Genvar must not leak through to the generated C++.
    assert "[i]" not in header


def test_bit_select_outputs_to_same_parent_share_one_writer(tmp_path: Path) -> None:
    """Regression: when slang unrolls a generate-for, each iteration becomes a
    regular instance and ``_direct_bit_bridges`` produces N output bridges all
    targeting the same parent signal. Emitting one ``SC_METHOD`` per bridge
    would mean N writers on a single ``sc_signal``, which SystemC aborts at
    runtime with ``SC_ID_MORE_THAN_ONE_SIGNAL_DRIVER_``. All N bridges sharing
    a parent must collapse to a single assembler process."""
    rtl = tmp_path / "gen_assemble.v"
    rtl.write_text(
        """
module subcell(input wire a, output wire y);
  assign y = ~a;
endmodule

module gen_assemble (
  input  wire [3:0] a,
  output wire [3:0] y
);
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : g
      subcell u(.a(a[i]), .y(y[i]));
    end
  endgenerate
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "gen_assemble")
    header = generate_systemc_header(design)

    # Exactly one assembler method drives `y`; the per-bridge methods that
    # used to do read-modify-write on `y` must not exist.
    assert header.count("__bridge_assemble_y") >= 2  # method body + SC_METHOD line
    assert "y.write(__tmp);" in header
    assert header.count("y.write(__tmp);") == 1, "y must have exactly one writer"
    for idx in range(4):
        assert f"__bridge_method_g_{idx}_u_y" not in header, (
            f"per-bridge output method __bridge_method_g_{idx}_u_y must not exist; "
            "would cause SC_ID_MORE_THAN_ONE_SIGNAL_DRIVER_ at runtime"
        )
        # All bit assignments still land in the one assembler.
        assert f"__tmp[{idx}] = __bridge_g_{idx}_u_y.read();" in header
    # Sensitivity is the union of every contributing bridge.
    assert (
        "sensitive << __bridge_g_0_u_y << __bridge_g_1_u_y "
        "<< __bridge_g_2_u_y << __bridge_g_3_u_y;" in header
    )


def test_procedural_bit_writes_to_same_parent_share_one_writer(tmp_path: Path) -> None:
    """Regression: when two procedural blocks each write a different bit of
    the same parent signal, the previous codegen produced two SC_METHODs
    that both ended with ``parent.write(__next_parent)`` — SystemC aborts
    at runtime with ``SC_ID_MORE_THAN_ONE_SIGNAL_DRIVER_``. The codegen
    aggregation pass must redirect each per-process write to a private
    ``__shadow_<parent>_<idx>`` signal and emit a single ``__assemble_<parent>``
    method as the only writer to ``parent``. Test pins the shape of the
    rewrite for an always_ff parent; trace-level correctness is verified
    by the ``slice_writers`` equivalence fixture."""
    rtl = tmp_path / "slices.v"
    rtl.write_text(
        """
module slices(input wire clk, input wire rst_n, input wire a, input wire b, output reg [1:0] q);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) q[0] <= 1'b0;
    else        q[0] <= a;
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) q[1] <= 1'b0;
    else        q[1] <= b;
  end
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "slices")
    header = generate_systemc_header(design)

    # Shadow signals declared and each per-process method writes its own.
    assert "sc_signal<bool> __shadow_q_0;" in header
    assert "sc_signal<bool> __shadow_q_1;" in header
    # Exactly one writer to q (the assembler).
    assert header.count("q.write(__tmp);") == 1
    # Per-process methods write the shadow, not q.
    assert "__shadow_q_0.write(__next___shadow_q_0);" in header
    assert "__shadow_q_1.write(__next___shadow_q_1);" in header
    # No process writes ``q`` directly anymore.
    assert "q.write(__next_q);" not in header
    # Assembler sensitivity unions both shadows.
    assert "sensitive << __shadow_q_0 << __shadow_q_1;" in header


def test_casez_lowers_to_mask_match_if_chain(tmp_path: Path) -> None:
    """casez/casex must lower to a mask+match if/elif chain rather than a
    plain ``switch``. A naive switch silently drops wildcard semantics,
    which is the silent-miscompile path docs/syntax_coverage's section D
    used to flag. Verifies the codegen for casez (casex is identical for
    our zero-X model)."""
    rtl = tmp_path / "casez_demo.v"
    rtl.write_text(
        """
module casez_demo(input wire [3:0] op, output reg [1:0] y);
  always @(*) casez (op)
    4'b1???: y = 2'd0;
    4'b01??: y = 2'd1;
    4'b001?: y = 2'd2;
    default: y = 2'd3;
  endcase
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "casez_demo")
    header = generate_systemc_header(design)

    # Mask/match form for each pattern.
    assert "(__sel & 0x8) == 0x8" in header   # 4'b1???
    assert "(__sel & 0xc) == 0x4" in header   # 4'b01??
    assert "(__sel & 0xe) == 0x2" in header   # 4'b001?
    # Selector cached once, not re-read per branch.
    assert "auto __sel = op.read();" in header
    # No plain switch on the wildcard case — that would lose wildcards.
    assert "switch (op.read())" not in header


def test_casex_lowers_to_mask_match_if_chain(tmp_path: Path) -> None:
    """casex shares the same lowering path as casez. Under our zero-X
    model, X is treated identically to Z, but the keyword must still be
    recognized."""
    rtl = tmp_path / "casex_demo.v"
    rtl.write_text(
        """
module casex_demo(input wire [3:0] op, output reg q);
  always @(*) casex (op)
    4'b1xxx: q = 1'b1;
    default: q = 1'b0;
  endcase
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "casex_demo")
    header = generate_systemc_header(design)

    assert "(__sel & 0x8) == 0x8" in header
    assert "switch (op.read())" not in header
