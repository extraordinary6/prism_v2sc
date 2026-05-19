// Diagnostic fixture: same signal driven with both blocking ('=') and
// nonblocking ('<=') assignment styles.
// Expected code: mixed_assignment_styles
module mixed_assign(input wire clk, input wire a, output reg q);
  always @(*)         q = a;
  always @(posedge clk) q <= a;
endmodule
