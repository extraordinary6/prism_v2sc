// Diagnostic fixture: blocking '=' inside an always_ff block.
// Expected code: blocking_in_always_ff
module blk_in_ff(input wire clk, input wire a, output reg q);
  always @(posedge clk) q = a;
endmodule
