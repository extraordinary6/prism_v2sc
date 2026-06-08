// Counter with enable - demonstrates counter activity pattern
module counter_with_enable(
  input wire clk,
  input wire rst_n,
  input wire enable,
  output reg [15:0] count
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      count <= 16'd0;
    else if (enable)
      count <= count + 16'd1;  // Counter pattern: reg <= reg + const
  end
endmodule
