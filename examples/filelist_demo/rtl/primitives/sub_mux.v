`include "defs.vh"

// One-bit-per-output mux, vector-width parametrized via the WIDTH macro.
module sub_mux (
  input  wire              sel,
  input  wire [`WIDTH-1:0] a,
  input  wire [`WIDTH-1:0] b,
  output wire [`WIDTH-1:0] y
);
  assign y = sel ? b : a;
endmodule
