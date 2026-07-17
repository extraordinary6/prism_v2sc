 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_subsys_axi2axi_async # (
  parameter SYNC_DP = 1,
  parameter AW = 32,
  parameter DW = 32,
  parameter ID_W = 4,
  parameter USR_W = 4,
  parameter MW = 4
) (
  output                           i_axi_arready,
  input                            i_axi_arvalid,
  input [ID_W-1:0]                 i_axi_arid,
  input [AW-1:0]                   i_axi_araddr,
  input [7:0]                      i_axi_arlen,
  input [2:0]                      i_axi_arsize,
  input [1:0]                      i_axi_arburst,
  input                            i_axi_arlock,
  input [3:0]                      i_axi_arcache,
  input [2:0]                      i_axi_arprot,
  input [3:0]                      i_axi_arqos,
  input [3:0]                      i_axi_arregion,
  input [USR_W-1:0]                i_axi_aruser,
  output                           i_axi_awready,
  input                            i_axi_awvalid,
  input [ID_W-1:0]                 i_axi_awid,
  input [AW-1:0]                   i_axi_awaddr,
  input [7:0]                      i_axi_awlen,
  input [2:0]                      i_axi_awsize,
  input [1:0]                      i_axi_awburst,
  input                            i_axi_awlock,
  input [3:0]                      i_axi_awcache,
  input [2:0]                      i_axi_awprot,
  input [3:0]                      i_axi_awqos,
  input [3:0]                      i_axi_awregion,
  input [USR_W-1:0]                i_axi_awuser, 
  output                           i_axi_wready,
  input                            i_axi_wvalid,
  input [ID_W-1:0]                 i_axi_wid,
  input [DW-1:0]                   i_axi_wdata,
  input [MW-1:0]                   i_axi_wstrb,
  input                            i_axi_wlast,
  input                            i_axi_rready,
  output                           i_axi_rvalid,
  output [ID_W-1:0]                i_axi_rid,
  output [DW-1:0]                  i_axi_rdata,
  output [1:0]                     i_axi_rresp,
  output                           i_axi_rlast,
  input                            i_axi_bready,
  output                           i_axi_bvalid,
  output [ID_W-1:0]                i_axi_bid,
  output [1:0]                     i_axi_bresp,
  input                            o_axi_arready,
  output                           o_axi_arvalid,
  output [ID_W-1:0]                o_axi_arid,
  output [AW-1:0]                  o_axi_araddr,
  output [7:0]                     o_axi_arlen,
  output [2:0]                     o_axi_arsize,
  output [1:0]                     o_axi_arburst,
  output                           o_axi_arlock,
  output [3:0]                     o_axi_arcache,
  output [2:0]                     o_axi_arprot,
  output [3:0]                     o_axi_arqos,
  output [3:0]                     o_axi_arregion,
  output [USR_W-1:0]               o_axi_aruser,
  input                            o_axi_awready,
  output                           o_axi_awvalid,
  output [ID_W-1:0]                o_axi_awid,
  output [AW-1:0]                  o_axi_awaddr,
  output [7:0]                     o_axi_awlen,
  output [2:0]                     o_axi_awsize,
  output [1:0]                     o_axi_awburst,
  output                           o_axi_awlock,
  output [3:0]                     o_axi_awcache,
  output [2:0]                     o_axi_awprot,
  output [3:0]                     o_axi_awqos,
  output [3:0]                     o_axi_awregion,
  output [USR_W-1:0]               o_axi_awuser, 
  input                            o_axi_wready,
  output                           o_axi_wvalid,
  output [ID_W-1:0]                o_axi_wid,
  output [DW-1:0]                  o_axi_wdata,
  output [MW-1:0]                  o_axi_wstrb,
  output                           o_axi_wlast,
  output                           o_axi_rready,
  input                            o_axi_rvalid,
  input [ID_W-1:0]                 o_axi_rid,
  input [DW-1:0]                   o_axi_rdata,
  input [1:0]                      o_axi_rresp,
  input                            o_axi_rlast,
  output                           o_axi_bready,
  input                            o_axi_bvalid,
  input [ID_W-1:0]                 o_axi_bid,
  input [1:0]                      o_axi_bresp,
  input                            i_clk,
  input                            o_clk,
  input                            i_rst_n,
  input                            o_rst_n 
  );
  localparam CMD_AR_PACK_W = (ID_W+AW+8+3+2+1+4+3+4+4+USR_W);
  wire [CMD_AR_PACK_W-1:0] cmd_ar_i_dat = {
                                 i_axi_arid,
                                 i_axi_araddr,
                                 i_axi_arlen,
                                 i_axi_arsize,
                                 i_axi_arburst,
                                 i_axi_arlock,
                                 i_axi_arcache,
                                 i_axi_arprot,
                                 i_axi_arqos,
                                 i_axi_arregion,
                                 i_axi_aruser
                                 };
  wire [CMD_AR_PACK_W-1:0] cmd_ar_o_dat;
  assign {
                                 o_axi_arid,
                                 o_axi_araddr,
                                 o_axi_arlen,
                                 o_axi_arsize,
                                 o_axi_arburst,
                                 o_axi_arlock,
                                 o_axi_arcache,
                                 o_axi_arprot,
                                 o_axi_arqos,
                                 o_axi_arregion,
                                 o_axi_aruser
                                 } = cmd_ar_o_dat;
  e603_gnrl_cdc_tx_rx # ( .DW(CMD_AR_PACK_W), .SYNC_DP(SYNC_DP) ) u_cmd_ar_cdc_tx_rx (
    .i_clk   (i_clk),
    .i_rst_n (i_rst_n),
    .i_valid (i_axi_arvalid),
    .i_ready (i_axi_arready),
    .i_data  (cmd_ar_i_dat),
    .o_clk   (o_clk),
    .o_rst_n (o_rst_n),
    .o_valid (o_axi_arvalid),
    .o_ready (o_axi_arready),
    .o_data  (cmd_ar_o_dat)
  );
  localparam CMD_AW_PACK_W = (ID_W+AW+8+3+2+1+4+3+4+4+USR_W);
  wire [CMD_AW_PACK_W-1:0] cmd_aw_i_dat = {
                                 i_axi_awid,
                                 i_axi_awaddr,
                                 i_axi_awlen,
                                 i_axi_awsize,
                                 i_axi_awburst,
                                 i_axi_awlock,
                                 i_axi_awcache,
                                 i_axi_awprot,
                                 i_axi_awqos,
                                 i_axi_awregion,
                                 i_axi_awuser
                                 };
  wire [CMD_AW_PACK_W-1:0] cmd_aw_o_dat;
  assign {
                                 o_axi_awid,
                                 o_axi_awaddr,
                                 o_axi_awlen,
                                 o_axi_awsize,
                                 o_axi_awburst,
                                 o_axi_awlock,
                                 o_axi_awcache,
                                 o_axi_awprot,
                                 o_axi_awqos,
                                 o_axi_awregion,
                                 o_axi_awuser
                                 } = cmd_aw_o_dat;
  e603_gnrl_cdc_tx_rx # ( .DW(CMD_AW_PACK_W), .SYNC_DP(SYNC_DP) ) u_cmd_aw_cdc_tx_rx (
    .i_clk   (i_clk),
    .i_rst_n (i_rst_n),
    .i_valid (i_axi_awvalid),
    .i_ready (i_axi_awready),
    .i_data  (cmd_aw_i_dat),
    .o_clk   (o_clk),
    .o_rst_n (o_rst_n),
    .o_valid (o_axi_awvalid),
    .o_ready (o_axi_awready),
    .o_data  (cmd_aw_o_dat)
  );
  localparam CMD_W_PACK_W = (ID_W+DW+MW+1);
  wire [CMD_W_PACK_W-1:0] cmd_w_i_dat = {
                                 i_axi_wid,
                                 i_axi_wdata,
                                 i_axi_wstrb,
                                 i_axi_wlast
                                 };
  wire [CMD_W_PACK_W-1:0] cmd_w_o_dat;
  assign {
                                 o_axi_wid,
                                 o_axi_wdata,
                                 o_axi_wstrb,
                                 o_axi_wlast
                                 } = cmd_w_o_dat;
  e603_gnrl_cdc_tx_rx # ( .DW(CMD_W_PACK_W), .SYNC_DP(SYNC_DP) ) u_cmd_w_cdc_tx_rx (
    .i_clk   (i_clk),
    .i_rst_n (i_rst_n),
    .i_valid (i_axi_wvalid),
    .i_ready (i_axi_wready),
    .i_data  (cmd_w_i_dat),
    .o_clk   (o_clk),
    .o_rst_n (o_rst_n),
    .o_valid (o_axi_wvalid),
    .o_ready (o_axi_wready),
    .o_data  (cmd_w_o_dat)
  );
  localparam CMD_R_PACK_W = (ID_W+DW+2+1);
  wire [CMD_R_PACK_W-1:0] rsp_r_i_dat = {
                                 o_axi_rid,
                                 o_axi_rdata,
                                 o_axi_rresp,
                                 o_axi_rlast
                                 };
  wire [CMD_R_PACK_W-1:0] rsp_r_o_dat;
  assign {
                                 i_axi_rid,
                                 i_axi_rdata,
                                 i_axi_rresp,
                                 i_axi_rlast
                                 } = rsp_r_o_dat;
  e603_gnrl_cdc_tx_rx # ( .DW(CMD_R_PACK_W), .SYNC_DP(SYNC_DP) ) u_rsp_r_cdc_tx_rx (
    .i_clk   (o_clk),
    .i_rst_n (o_rst_n),
    .i_valid (o_axi_rvalid),
    .i_ready (o_axi_rready),
    .i_data  (rsp_r_i_dat),
    .o_clk   (i_clk),
    .o_rst_n (i_rst_n),
    .o_valid (i_axi_rvalid),
    .o_ready (i_axi_rready),
    .o_data  (rsp_r_o_dat)
  );
  localparam CMD_B_PACK_W = (ID_W+2);
  wire [CMD_B_PACK_W-1:0] rsp_b_i_dat = {
                                 o_axi_bid,
                                 o_axi_bresp
                                 };
  wire [CMD_B_PACK_W-1:0] rsp_b_o_dat;
  assign {
                                 i_axi_bid,
                                 i_axi_bresp
                                 } = rsp_b_o_dat;
  e603_gnrl_cdc_tx_rx # ( .DW(CMD_B_PACK_W), .SYNC_DP(SYNC_DP) ) u_rsp_b_cdc_tx_rx (
    .i_clk   (o_clk),
    .i_rst_n (o_rst_n),
    .i_valid (o_axi_bvalid),
    .i_ready (o_axi_bready),
    .i_data  (rsp_b_i_dat),
    .o_clk   (i_clk),
    .o_rst_n (i_rst_n),
    .o_valid (i_axi_bvalid),
    .o_ready (i_axi_bready),
    .o_data  (rsp_b_o_dat)
  );
endmodule
module e603_gnrl_cdc_tx_rx
# (
  parameter DW = 32,
  parameter SYNC_DP = 2
) (
  input  i_clk,
  input  i_rst_n,
  input  i_valid,
  output i_ready,
  input [DW-1 : 0] i_data,
  input   o_clk,
  input   o_rst_n,
  output  o_valid,
  input   o_ready,
  output [DW-1 : 0] o_data
);
  wire tx_rx_valid ;
  wire tx_rx_ready;
  wire [DW-1:0] tx_rx_data;
  e603_gnrl_cdc_tx # ( .DW(DW), .SYNC_DP(SYNC_DP) ) u_cdc_tx(
    .i_vld   (i_valid), 
    .i_rdy   (i_ready), 
    .i_dat   (i_data ),
    .o_vld   (tx_rx_valid), 
    .o_rdy_a (tx_rx_ready), 
    .o_dat   (tx_rx_data),
    .clk     (i_clk),
    .rst_n   (i_rst_n) 
  );
  e603_gnrl_cdc_rx # ( .DW(DW), .SYNC_DP(SYNC_DP) ) u_cdc_rx(
    .i_vld_a(tx_rx_valid), 
    .i_rdy  (tx_rx_ready), 
    .i_dat  (tx_rx_data),
    .o_vld  (o_valid), 
    .o_rdy  (o_ready), 
    .o_dat  (o_data ),
    .clk    (o_clk),
    .rst_n  (o_rst_n) 
  );
endmodule 
