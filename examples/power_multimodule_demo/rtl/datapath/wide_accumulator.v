`include "power_defs.vh"

module wide_accumulator (
  input  wire                 clk,
  input  wire                 rst_n,
  input  wire [`PMD_DATA_W-1:0] data_in,
  output reg  [`PMD_DATA_W-1:0] accum
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      accum <= `PMD_DATA_W'd0;
    else
      accum <= accum + data_in;
  end
endmodule

