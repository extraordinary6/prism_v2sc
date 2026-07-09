// Diagnostic fixture: two processes write overlapping slices of the same
// vector, which the multi-writer shadow aggregation must reject.
module overlap_slice_writers (
  input  wire       clk,
  input  wire [3:0] a,
  input  wire [3:0] b,
  output reg  [7:0] q
);
  always @(posedge clk) begin
    q[3:0] <= a;
  end

  always @(posedge clk) begin
    q[5:2] <= b;
  end
endmodule
