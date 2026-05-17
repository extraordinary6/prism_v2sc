`include "defs.vh"

// Top: a 2:1 mux feeding an enable register. The whole block can be
// short-circuited (mux output directly to y) by leaving USE_REG undefined.
module top_datapath (
  input  wire              clk,
  input  wire              rst_n,
  input  wire              en,
  input  wire              sel,
  input  wire [`WIDTH-1:0] a,
  input  wire [`WIDTH-1:0] b,
  output wire [`WIDTH-1:0] y
);
`ifdef USE_REG
  wire [`WIDTH-1:0] mux_out;
  sub_mux u_mux (
    .sel(sel), .a(a), .b(b), .y(mux_out)
  );
  sub_register u_reg (
    .clk(clk), .rst_n(rst_n), .en(en),
    .data_in(mux_out), .data_out(y)
  );
`else
  sub_mux u_mux (
    .sel(sel), .a(a), .b(b), .y(y)
  );
`endif
endmodule
