// Diagnostic fixture: X literal in a continuous assign default.
// prism approximates X/Z as 0 and surfaces a warning so callers know
// the simulation will diverge from a four-state RTL simulator.
// Expected code: x_z_literal_approximated
module xz_lit(input wire a, output wire q);
  assign q = a ? 1'b1 : 1'bx;
endmodule
