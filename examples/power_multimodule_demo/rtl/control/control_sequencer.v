`include "power_defs.vh"

module control_sequencer (
  input  wire                 clk,
  input  wire                 rst_n,
  input  wire                 start,
  input  wire [3:0]           command,
  output reg                  busy,
  output reg  [1:0]           mux_sel,
  output reg                  mix_mode,
  output reg  [`PMD_COUNT_W-1:0] packet_count
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      busy <= 1'b0;
      mux_sel <= 2'd0;
      mix_mode <= 1'b0;
      packet_count <= `PMD_COUNT_W'd0;
    end else begin
      busy <= start | busy;
      mux_sel <= command[1:0];
      mix_mode <= command[2];
      if (start)
        packet_count <= packet_count + `PMD_COUNT_W'd1;
    end
  end
endmodule

