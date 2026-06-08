`include "power_defs.vh"

module wide_crossbar (
  input  wire [1:0]             sel,
  input  wire [`PMD_DATA_W-1:0] in0,
  input  wire [`PMD_DATA_W-1:0] in1,
  input  wire [`PMD_DATA_W-1:0] in2,
  input  wire [`PMD_DATA_W-1:0] in3,
  output wire [`PMD_DATA_W-1:0] out
);
  assign out = sel[1] ? (sel[0] ? in3 : in2) : (sel[0] ? in1 : in0);
endmodule

