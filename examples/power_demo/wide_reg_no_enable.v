// Wide register without enable - clock gating candidate
module wide_reg_no_enable(
  input wire clk,
  input wire rst_n,
  input wire [63:0] data_in,
  output reg [63:0] data_out
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      data_out <= 64'd0;
    else
      data_out <= data_in;  // Always updates, even when not needed
  end
endmodule
