// Equivalence fixture: inferred combinational sensitivity through function
// call arguments, selects, concat and replication.
module sensitivity_edges (
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire [1:0] idx,
  input  wire       sel,
  output reg  [7:0] y,
  output reg        picked
);
  function [7:0] blend;
    input [7:0] x;
    input [7:0] z;
    input [1:0] sh;
    begin
      blend = {x[3:0], z[7:4]} ^ (x >> sh);
    end
  endfunction

  always @(*) begin
    picked = sel ? a[idx] : b[idx];
    y = blend(a, b, idx) ^ ({8{picked}} & {a[0], b[6:0]});
  end
endmodule
