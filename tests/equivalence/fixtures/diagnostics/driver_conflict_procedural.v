// Diagnostic fixture: two always_ff blocks write the same whole signal.
// Expected codes:
//   - multiple_procedural_drivers
//   - multiple_always_ff_drivers
module dc_proc(input wire clk, input wire a, input wire b, output reg q);
  always @(posedge clk) q <= a;
  always @(posedge clk) q <= b;
endmodule
