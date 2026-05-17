`include "defs.vh"

// Single-write-enable register, async active-low reset.
module sub_register (
  input  wire              clk,
  input  wire              rst_n,
  input  wire              en,
  input  wire [`WIDTH-1:0] data_in,
  output reg  [`WIDTH-1:0] data_out
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)    data_out <= 8'h00;
    else if (en)   data_out <= data_in;
  end
endmodule
