`include "power_defs.vh"

module vector_alu (
  input  wire [`PMD_DATA_W-1:0] a,
  input  wire [`PMD_DATA_W-1:0] b,
  input  wire [`PMD_DATA_W-1:0] c,
  input  wire [`PMD_DATA_W-1:0] mask,
  input  wire                   mode,
  output wire [`PMD_DATA_W-1:0] result
);
  wire [`PMD_DATA_W-1:0] mix0;
  wire [`PMD_DATA_W-1:0] mix1;
  wire [`PMD_DATA_W-1:0] mix2;

  assign mix0 = (a ^ b) + (c & mask);
  assign mix1 = ((mix0 + a) ^ (b - mask)) | (c & mix0);
  assign mix2 = ((mix1 & (a + b)) | ((c ^ mask) + (mix0 - b)));
  assign result = mode ? (mix2 ^ (mix1 + mask)) : ((mix0 | mix1) + (mix2 & c));
endmodule

