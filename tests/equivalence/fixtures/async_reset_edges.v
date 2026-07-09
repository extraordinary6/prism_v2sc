// Equivalence fixture: active-high async reset with reset deasserted on the
// clock boundary by the generated testbench.
module async_reset_edges (
  input  wire       clk,
  input  wire       rst,
  input  wire       en,
  input  wire [7:0] din,
  output reg  [7:0] q,
  output reg        flag
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      q    <= 8'hA5;
      flag <= 1'b0;
    end else begin
      if (en) begin
        q <= din;
      end else begin
        q <= {q[6:0], flag};
      end
      flag <= ^q;
    end
  end
endmodule
