"""Unit tests for procedural for loop lowering."""
from pathlib import Path
from textwrap import dedent

from prism_v2sc.codegen.systemc import generate_systemc_header

from _pyslang_helper import lower_via_pyslang


def test_procedural_for_loop_unrolls_constant_bounds(tmp_path: Path) -> None:
    """Procedural for loops with constant bounds unroll into sequential statements."""
    rtl = tmp_path / "for_loop.v"
    rtl.write_text(
        dedent(
            """\
            module for_loop (
              input  wire       clk,
              input  wire       rst_n,
              input  wire [3:0] din,
              output reg  [3:0] reversed
            );
              integer i;
              always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                  reversed <= 4'b0;
                end else begin
                  for (i = 0; i < 4; i = i + 1) begin
                    reversed[i] <= din[3 - i];
                  end
                end
              end
            endmodule
            """
        )
    )

    design = lower_via_pyslang([rtl], "for_loop")
    assert len(design.diagnostics) == 0, f"Unexpected diagnostics: {design.diagnostics}"

    mod = design.modules[0]
    assert len(mod.processes) == 1

    proc = mod.processes[0]
    assert len(proc.structured_statements) == 1

    # The top-level statement is the if/else for reset
    stmt = proc.structured_statements[0]
    assert stmt["type"] == "if"
    assert len(stmt["false"]) == 1

    # The else branch should contain the unrolled for loop (4 iterations)
    unrolled = stmt["false"][0]
    assert unrolled["type"] == "block"
    assert len(unrolled["statements"]) == 4, "Expected 4 unrolled iterations for i=0..3"

    # Each iteration should be a nonblocking assignment
    for iteration in unrolled["statements"]:
        assert iteration["type"] == "nonblocking_assign"


def test_procedural_for_loop_with_parameter_bound(tmp_path: Path) -> None:
    """For loops with parameter-based bounds are unrolled at elaboration time."""
    rtl = tmp_path / "param_for.v"
    rtl.write_text(
        dedent(
            """\
            module param_for #(
              parameter WIDTH = 8
            ) (
              input  wire              clk,
              input  wire              rst_n,
              output reg  [WIDTH-1:0]  cleared
            );
              integer i;
              always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                  cleared <= {WIDTH{1'b0}};
                end else begin
                  for (i = 0; i < WIDTH; i = i + 1) begin
                    cleared[i] <= 1'b0;
                  end
                end
              end
            endmodule
            """
        )
    )

    design = lower_via_pyslang([rtl], "param_for")
    assert len(design.diagnostics) == 0

    mod = design.modules[0]
    proc = mod.processes[0]
    stmt = proc.structured_statements[0]

    # The else branch contains the unrolled loop
    unrolled = stmt["false"][0]
    assert unrolled["type"] == "block"
    assert len(unrolled["statements"]) == 8, "Expected 8 iterations for WIDTH=8"


def test_procedural_for_loop_accepts_local_int_postincrement(tmp_path: Path) -> None:
    """Loop-local declarations and i++ steps are common synthesizable SV."""
    rtl = tmp_path / "local_postincrement_for.sv"
    rtl.write_text(
        dedent(
            """\
            module local_postincrement_for (
              input  logic       clk,
              input  logic [7:0] din,
              output logic [7:0] out
            );
              always_ff @(posedge clk) begin
                for (int i = 0; i < 8; i++) begin
                  out[i] <= din[i];
                end
              end
            endmodule
            """
        )
    )

    design = lower_via_pyslang([rtl], "local_postincrement_for")
    assert len(design.diagnostics) == 0

    proc = design.modules[0].processes[0]
    block = proc.structured_statements[0]
    assert block["type"] == "block"
    assert block["statements"][0]["type"] == "noop"
    unrolled = block["statements"][1]
    assert unrolled["type"] == "block"
    assert len(unrolled["statements"]) == 8

    header = generate_systemc_header(design)
    assert "Unsupported statement: ForLoop" not in header
    assert "__next_out[0]" in header
    assert "__next_out[7]" in header


def test_decrement_for_loop_unrolls_and_keeps_block_sensitivity(tmp_path: Path) -> None:
    """Decrementing loops unroll, and RHS signals inside the unrolled block
    contribute to always-comb sensitivity.
    """
    rtl = tmp_path / "decrement_for.v"
    rtl.write_text(
        dedent(
            """\
            module decrement_for (
              input  wire [3:0] din,
              input  wire [3:0] mask,
              output reg  [3:0] out
            );
              integer i;
              always @(*) begin
                for (i = 3; i > 0; i = i - 1) begin
                  out[i] = din[i] ^ mask[i];
                end
                out[0] = mask[0];
              end
            endmodule
            """
        )
    )

    design = lower_via_pyslang([rtl], "decrement_for")
    assert len(design.diagnostics) == 0

    proc = design.modules[0].processes[0]
    unrolled = proc.structured_statements[0]
    assert unrolled["type"] == "block"
    assert len(unrolled["statements"]) == 3

    header = generate_systemc_header(design)
    assert "__next_out[3]" in header
    assert "__next_out[1]" in header
    assert "sensitive << din << mask;" in header


def test_procedural_for_loop_nested_in_case(tmp_path: Path) -> None:
    """For loops can appear inside case branches."""
    rtl = tmp_path / "case_for.v"
    rtl.write_text(
        dedent(
            """\
            module case_for (
              input  wire       clk,
              input  wire       rst_n,
              input  wire [1:0] mode,
              output reg  [3:0] out
            );
              integer i;
              always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                  out <= 4'b0;
                end else begin
                  case (mode)
                    2'b00: begin
                      for (i = 0; i < 4; i = i + 1) begin
                        out[i] <= 1'b1;
                      end
                    end
                    default: out <= 4'b0;
                  endcase
                end
              end
            endmodule
            """
        )
    )

    design = lower_via_pyslang([rtl], "case_for")
    assert len(design.diagnostics) == 0

    mod = design.modules[0]
    proc = mod.processes[0]
    stmt = proc.structured_statements[0]

    # Navigate: if -> else -> case -> first item -> statements -> block
    case_stmt = stmt["false"][0]
    assert case_stmt["type"] == "case"
    first_case_item = case_stmt["items"][0]
    unrolled = first_case_item["statements"][0]
    assert unrolled["type"] == "block"
    assert len(unrolled["statements"]) == 4
