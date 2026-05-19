// Regression fixture for generate-for unrolling + generate-if branch selection.
//
// Drives both constructs through prism_v2sc to lock in:
//   * generate-if dead-branch suppression (only the live branch's logic emits)
//   * generate-for instance disambiguation + genvar substitution in bit-selects
//   * per-iteration submodule bindings stay correct after elaboration.
//
// Each output bit is bit-inverted via a per-iteration ``subcell`` instance, so
// the SystemC build must emit four distinct instances with the right bit
// indices for the trace diff to pass.

module subcell(input wire a, output wire y);
  assign y = ~a;
endmodule

module gen_demo (
  input  wire [3:0] a,
  output wire [3:0] y
);
  parameter MODE = 1;

  generate
    if (MODE == 1) begin : g_invert
      genvar i;
      for (i = 0; i < 4; i = i + 1) begin : g
        subcell u(.a(a[i]), .y(y[i]));
      end
    end else begin : g_passthrough
      assign y = a;
    end
  endgenerate
endmodule
