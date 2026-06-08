`include "power_defs.vh"

module reg_bank (
  input  wire                 clk,
  input  wire                 rst_n,
  input  wire                 load0,
  input  wire                 load1,
  input  wire                 load2,
  input  wire                 load3,
  input  wire [`PMD_DATA_W-1:0] d0,
  input  wire [`PMD_DATA_W-1:0] d1,
  input  wire [`PMD_DATA_W-1:0] d2,
  input  wire [`PMD_DATA_W-1:0] d3,
  output reg  [`PMD_DATA_W-1:0] q0,
  output reg  [`PMD_DATA_W-1:0] q1,
  output reg  [`PMD_DATA_W-1:0] q2,
  output reg  [`PMD_DATA_W-1:0] q3
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q0 <= `PMD_DATA_W'd0;
      q1 <= `PMD_DATA_W'd0;
      q2 <= `PMD_DATA_W'd0;
      q3 <= `PMD_DATA_W'd0;
    end else begin
      q0 <= d0;
      if (load1)
        q1 <= d1;
      if (load2)
        q2 <= d2;
      if (load3)
        q3 <= d3;
    end
  end
endmodule

