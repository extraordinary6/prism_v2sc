// Equivalence fixture: latch hold and partial assignment behavior within one
// always_latch process.
module latch_edges (
  input  wire       load,
  input  wire       hold_hi,
  input  wire [7:0] din,
  input  wire [3:0] hi,
  output reg  [7:0] q,
  output reg  [7:0] mirror
);
  always_latch begin
    if (load) begin
      q = din;
    end
    if (hold_hi) begin
      q[7:4] = hi;
    end
    if (load | hold_hi) begin
      mirror = q ^ 8'h3C;
    end
  end
endmodule
