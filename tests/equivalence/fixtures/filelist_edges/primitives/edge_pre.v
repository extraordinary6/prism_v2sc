`include "edge_defs.vh"

module edge_pre (
  input  wire                  sel,
  input  wire [`EDGE_WIDTH-1:0] a,
  input  wire [`EDGE_WIDTH-1:0] b,
  output wire [`EDGE_WIDTH-1:0] y
);
`ifdef USE_EDGE_XOR
  assign y = sel ? (a ^ `EDGE_MASK) : (b + `EDGE_BIAS);
`else
  assign y = sel ? a : b;
`endif
endmodule
