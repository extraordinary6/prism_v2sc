`include "edge_defs.vh"

module filelist_edges_top (
  input  wire                   clk,
  input  wire                   rst_n,
  input  wire                   en,
  input  wire                   sel,
  input  wire [`EDGE_WIDTH-1:0] a,
  input  wire [`EDGE_WIDTH-1:0] b,
  output reg  [`EDGE_WIDTH-1:0] y,
  output wire [`EDGE_WIDTH-1:0] comb
);
  wire [`EDGE_WIDTH-1:0] pre;

  edge_pre u_pre (
    .sel(sel),
    .a(a),
    .b(b),
    .y(pre)
  );

  assign comb = pre;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      y <= `EDGE_WIDTH'h0;
    end else if (en) begin
      y <= pre;
    end else begin
      y <= y ^ `EDGE_WIDTH'h1;
    end
  end
endmodule
