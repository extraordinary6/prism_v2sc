 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
`ifdef DDR3_CONTROLLER
`include "global.v"
`timescale 1ps/1ps
module e603_ddr3_wrapper#(
    parameter ID_W = 3,
    parameter AW   = 32,
    parameter DW   = 64,
    parameter USR_W = 1,
    parameter MW   = 8
)(
      input              axi_ro_arvalid                ,
  output             axi_ro_arready                ,
  input  [  31:   0] axi_ro_araddr                 ,
  input  [   7:   0] axi_ro_arlen                  ,
  input  [   2:   0] axi_ro_arsize                 ,
  input  [   1:   0] axi_ro_arburst                ,
  input              axi_ro_arlock                 ,
  input  [   3:   0] axi_ro_arcache                ,
  input  [   2:   0] axi_ro_arprot                 ,
  input              axi_ro_rready                 ,
  output             axi_ro_rvalid                 ,
  output [  63:   0] axi_ro_rdata                  ,
  output [   1:   0] axi_ro_rresp                  ,
  output             axi_ro_rlast                  ,
      input              axi_wo_awvalid                ,
  output             axi_wo_awready                ,
  input  [  31:   0] axi_wo_awaddr                 ,
  input  [   7:   0] axi_wo_awlen                  ,
  input  [   2:   0] axi_wo_awsize                 ,
  input  [   1:   0] axi_wo_awburst                ,
  input              axi_wo_awlock                 ,
  input  [   3:   0] axi_wo_awcache                ,
  input  [   2:   0] axi_wo_awprot                 ,
  input              axi_wo_bready                 ,
  output             axi_wo_bvalid                 ,
  output [   1:   0] axi_wo_bresp                  ,
  output             axi_wo_wready                 ,
  input              axi_wo_wvalid                 ,
  input  [  63:   0] axi_wo_wdata                  ,
  input  [   7:   0] axi_wo_wstrb                  ,
  input              axi_wo_wlast                  ,
  input  [   2:   0] axi_ro_arid                   ,
  output [   2:   0] axi_ro_rid                    ,
  input  [   3:   0] axi_ro_arqos                  ,
  input  [   2:   0] axi_wo_awid                   ,
  input  [   2:   0] axi_wo_wid                    ,
  output [   2:   0] axi_wo_bid                    ,
  input  [   3:   0] axi_wo_awqos                  ,
  inout  [  31:   0] ddr3_dq                       ,
  inout  [   3:   0] ddr3_dqs_n                    ,
  inout  [   3:   0] ddr3_dqs_p                    ,
  output [  13:   0] ddr3_addr                     ,
  output [   2:   0] ddr3_ba                       ,
  output             ddr3_ras_n                    ,
  output             ddr3_cas_n                    ,
  output             ddr3_we_n                     ,
  output             ddr3_reset_n                  ,
  output             ddr3_ck_p                     ,
  output             ddr3_ck_n                     ,
  output             ddr3_cke                      ,
  output             ddr3_cs_n                     ,
  output [   3:   0] ddr3_dm                       ,
  output             ddr3_odt                      ,
  output             init_calib_complete           ,
  input              ddr3_sys_clk_i                ,
  input              ddr3_sys_rst_i                ,
  input              sys_clk                       ,
  input              sys_rst_n                     
);
`ifndef DDR_CONTROLLER
  wire                            os_axi_arready;
  wire                            os_axi_arvalid;
  wire [ID_W-1:0]                os_axi_arid ;
  wire [AW-1:0]                  os_axi_araddr;
  wire [7:0]                      os_axi_arlen;
  wire [2:0]                      os_axi_arsize;
  wire [1:0]                      os_axi_arburst;
  wire [1:0]                      os_axi_arlock;
  wire [3:0]                      os_axi_arcache;
  wire [2:0]                      os_axi_arprot;
  wire [3:0]                      os_axi_arqos ;
  wire [3:0]                      os_axi_arregion ;
  wire [USR_W-1:0]               os_axi_aruser ;
  wire                            os_axi_awready;
  wire                            os_axi_awvalid;
  wire [ID_W-1:0]                os_axi_awid ;
  wire [AW-1:0]                  os_axi_awaddr;
  wire [7:0]                      os_axi_awlen;
  wire [2:0]                      os_axi_awsize;
  wire [1:0]                      os_axi_awburst;
  wire [1:0]                      os_axi_awlock;
  wire [3:0]                      os_axi_awcache;
  wire [2:0]                      os_axi_awprot;
  wire [3:0]                      os_axi_awqos;
  wire [3:0]                      os_axi_awregion;
  wire [USR_W-1:0]               os_axi_awuser ; 
  wire                            os_axi_wready;
  wire                            os_axi_wvalid;
  wire [ID_W-1:0]                os_axi_wid ;
  wire [DW-1:0]                  os_axi_wdata;
  wire [MW-1:0]                  os_axi_wstrb;
  wire                            os_axi_wlast;
  wire                            os_axi_rready;
  wire                            os_axi_rvalid;
  wire  [ID_W-1:0]               os_axi_rid;
  wire  [DW-1:0]                 os_axi_rdata;
  wire  [1:0]                     os_axi_rresp;
  wire                            os_axi_rlast;
  wire                            os_axi_bready;
  wire                            os_axi_bvalid;
  wire  [ID_W-1:0]               os_axi_bid;
  wire  [1:0]                     os_axi_bresp;
`endif
 `ifdef DDR_CONTROLLER
  wire                            ddr_axi_arready ;
  wire                            ddr_axi_arvalid;
  wire [ID_W-1:0]                 ddr_axi_arid ;
  wire [AW-1:0]                   ddr_axi_araddr;
  wire [7:0]                      ddr_axi_arlen;
  wire [2:0]                      ddr_axi_arsize;
  wire [1:0]                      ddr_axi_arburst;
  wire [0:0]                      ddr_axi_arlock;
  wire [3:0]                      ddr_axi_arcache;
  wire [2:0]                      ddr_axi_arprot;
  wire [3:0]                      ddr_axi_arqos ;
  wire [3:0]                      ddr_axi_arregion ;
  wire [USR_W-1:0]               ddr_axi_aruser ;
  wire                            ddr_axi_awready ;
  wire                            ddr_axi_awvalid;
  wire [ID_W-1:0]                ddr_axi_awid ;
  wire [AW-1:0]                  ddr_axi_awaddr;
  wire [7:0]                      ddr_axi_awlen;
  wire [2:0]                      ddr_axi_awsize;
  wire [1:0]                      ddr_axi_awburst;
  wire [0:0]                      ddr_axi_awlock;
  wire [3:0]                      ddr_axi_awcache;
  wire [2:0]                      ddr_axi_awprot;
  wire [3:0]                      ddr_axi_awqos;
  wire [3:0]                      ddr_axi_awregion;
  wire [USR_W-1:0]               ddr_axi_awuser ; 
  wire                            ddr_axi_wready ;
  wire                            ddr_axi_wvalid;
  wire [ID_W-1:0]                ddr_axi_wid ;
  wire [DW-1:0]                  ddr_axi_wdata;
  wire [MW-1:0]                  ddr_axi_wstrb;
  wire                            ddr_axi_wlast;
  wire                            ddr_axi_rready;
  wire                            ddr_axi_rvalid ;
  wire [DW-1:0]                   ddr_axi_rdata ;
  wire [1:0]                      ddr_axi_rresp ;
  wire                            ddr_axi_rlast ;
  wire [ID_W-1:0]                 ddr_axi_rid ;
  wire                            ddr_axi_bready;
  wire                            ddr_axi_bvalid ;
  wire [1:0]                      ddr_axi_bresp ;
  wire [ID_W-1:0]                 ddr_axi_bid ;
  wire                            ddr_clk ;
  reg                             ddr_rst_n ;
  wire                            ddr_ready ;
  wire                            ui_clk;
  wire                            ui_clk_sync_rst;
  wire                            mmcm_locked;
  assign   ddr_clk = ui_clk;
  always @(posedge ui_clk) begin
      ddr_rst_n <= ~ui_clk_sync_rst;
  end
  assign   ddr_ready = mmcm_locked & init_calib_complete;
  wire   tmp_ddr_axi_arready  ;
  wire   tmp_ddr_axi_arvalid  ;
  wire   tmp_ddr_axi_awready  ;
  wire   tmp_ddr_axi_awvalid  ;
  wire   tmp_ddr_axi_rready   ;
  wire   tmp_ddr_axi_rvalid   ;
  wire   tmp_ddr_axi_wready   ;
  wire   tmp_ddr_axi_wvalid   ;
  wire   tmp_ddr_axi_bready   ;
  wire   tmp_ddr_axi_bvalid   ;
  assign  tmp_ddr_axi_arready = ddr_axi_arready & ddr_ready;
  assign  ddr_axi_arvalid = tmp_ddr_axi_arvalid & ddr_ready;
  assign  tmp_ddr_axi_awready = ddr_axi_awready & ddr_ready;
  assign  ddr_axi_awvalid = tmp_ddr_axi_awvalid & ddr_ready;
  assign  tmp_ddr_axi_wready  = ddr_axi_wready & ddr_ready;
  assign  ddr_axi_wvalid  = tmp_ddr_axi_wvalid & ddr_ready;
  assign  ddr_axi_rready  = tmp_ddr_axi_rready & ddr_ready;
  assign  tmp_ddr_axi_rvalid  = ddr_axi_rvalid & ddr_ready;
  assign  ddr_axi_bready  = tmp_ddr_axi_bready & ddr_ready;
  assign  tmp_ddr_axi_bvalid  = ddr_axi_bvalid & ddr_ready;
`endif
 `ifndef DDR_CONTROLLER
 e603_ddr3_axi2sram # (
    .AW                   ( AW ),
    .DW                   ( DW    ),
    .ID_W                 ( ID_W ),
    .USR_W                ( USR_W   ),
    .MW                   ( MW )
) 
 u_axi2sram
   (
     .axi_arready      (os_axi_arready),
     .axi_arvalid      (os_axi_arvalid),
     .axi_arid         (os_axi_arid),
     .axi_araddr       (os_axi_araddr),
     .axi_arlen        (os_axi_arlen),
     .axi_arsize       (os_axi_arsize),
     .axi_arburst      (os_axi_arburst),
     .axi_arlock       (os_axi_arlock[0]),
     .axi_arcache      (os_axi_arcache),
     .axi_arprot       (os_axi_arprot),
     .axi_arqos        (os_axi_arqos),
     .axi_arregion     (os_axi_arregion),
     .axi_aruser       (os_axi_aruser),
     .axi_awready      (os_axi_awready),
     .axi_awvalid      (os_axi_awvalid),
     .axi_awid         (os_axi_awid),
     .axi_awaddr       (os_axi_awaddr),
     .axi_awlen        (os_axi_awlen),
     .axi_awsize       (os_axi_awsize),
     .axi_awburst      (os_axi_awburst),
     .axi_awlock       (os_axi_awlock[0]),
     .axi_awcache      (os_axi_awcache),
     .axi_awprot       (os_axi_awprot),
     .axi_awqos        (os_axi_awqos),
     .axi_awregion     (os_axi_awregion),
     .axi_awuser       (os_axi_awuser),  
     .axi_wready       (os_axi_wready),
     .axi_wvalid       (os_axi_wvalid),
     .axi_wid          (os_axi_wid),
     .axi_wdata        (os_axi_wdata),
     .axi_wstrb        (os_axi_wstrb),
     .axi_wlast        (os_axi_wlast),
     .axi_rready       (os_axi_rready),
     .axi_rvalid       (os_axi_rvalid),
     .axi_rid          (os_axi_rid),
     .axi_rdata        (os_axi_rdata),
     .axi_rresp        (os_axi_rresp),
     .axi_rlast        (os_axi_rlast),
     .axi_bready       (os_axi_bready),
     .axi_bvalid       (os_axi_bvalid),
     .axi_bid          (os_axi_bid),
     .axi_bresp        (os_axi_bresp),
     .clk              (sys_clk),
     .rst_n            (sys_rst_n)
  );
    assign ddr3_dq     = 32'b0;
    assign ddr3_dqs_n  = 4'b0;
    assign ddr3_dqs_p  = 4'b0;
    assign ddr3_addr   = 14'b0;
    assign ddr3_ba     = 3'b0;
    assign ddr3_ras_n    = 1'b0; 
    assign ddr3_cas_n    = 1'b0; 
    assign ddr3_we_n     = 1'b0;  
    assign ddr3_reset_n  = 1'b0;   
    assign ddr3_ck_p     = 1'b0;   
    assign ddr3_ck_n     = 1'b0;  
    assign ddr3_cke      = 1'b0; 
    assign ddr3_cs_n     = 1'b0;   
    assign ddr3_dm       = 4'b0;
    assign ddr3_odt      = 1'b0; 
    assign init_calib_complete = 1'b1;   
 `endif
  e603_ddr3_axi2axi_async # (
    .SYNC_DP              (1) ,
    .AW                   ( AW ),
    .DW                   ( DW    ),
    .ID_W                 ( ID_W ),
    .USR_W                ( USR_W   ),
    .MW                   ( MW )
  )
  u_axi2axi_async
  (
     .i_axi_arready   (axi_ro_arready),
     .i_axi_arvalid   (axi_ro_arvalid),
     .i_axi_arid      (axi_ro_arid),
     .i_axi_araddr    (axi_ro_araddr),
     .i_axi_arlen     (axi_ro_arlen),
     .i_axi_arsize    (axi_ro_arsize),
     .i_axi_arburst   (axi_ro_arburst),
     .i_axi_arlock    (axi_ro_arlock),
     .i_axi_arcache   (axi_ro_arcache),
     .i_axi_arprot    (axi_ro_arprot),
     .i_axi_arqos     (axi_ro_arqos),
     .i_axi_arregion  (4'b0),
     .i_axi_aruser    ({USR_W{1'b0}}),
     .i_axi_awready   (axi_wo_awready),
     .i_axi_awvalid   (axi_wo_awvalid),
     .i_axi_awid      (axi_wo_awid),
     .i_axi_awaddr    (axi_wo_awaddr),
     .i_axi_awlen     (axi_wo_awlen),
     .i_axi_awsize    (axi_wo_awsize),
     .i_axi_awburst   (axi_wo_awburst),
     .i_axi_awlock    (axi_wo_awlock),
     .i_axi_awcache   (axi_wo_awcache),
     .i_axi_awprot    (axi_wo_awprot),
     .i_axi_awqos     (axi_wo_awqos),
     .i_axi_awregion  (4'b0),
     .i_axi_awuser    ({USR_W{1'b0}}), 
     .i_axi_wready    (axi_wo_wready),
     .i_axi_wvalid    (axi_wo_wvalid),
     .i_axi_wid       (axi_wo_wid),
     .i_axi_wdata     (axi_wo_wdata),
     .i_axi_wstrb     (axi_wo_wstrb),
     .i_axi_wlast     (axi_wo_wlast),
     .i_axi_rready    (axi_ro_rready),
     .i_axi_rvalid    (axi_ro_rvalid),
     .i_axi_rid       (axi_ro_rid),
     .i_axi_rdata     (axi_ro_rdata),
     .i_axi_rresp     (axi_ro_rresp),
     .i_axi_rlast     (axi_ro_rlast),
     .i_axi_bready    (axi_wo_bready),
     .i_axi_bvalid    (axi_wo_bvalid),
     .i_axi_bid       (axi_wo_bid),
     .i_axi_bresp     (axi_wo_bresp),
  `ifdef DDR_CONTROLLER
     .o_axi_arready   (tmp_ddr_axi_arready),
     .o_axi_arvalid   (tmp_ddr_axi_arvalid),
     .o_axi_arid      (ddr_axi_arid),
     .o_axi_araddr    (ddr_axi_araddr),
     .o_axi_arlen     (ddr_axi_arlen),
     .o_axi_arsize    (ddr_axi_arsize),
     .o_axi_arburst   (ddr_axi_arburst),
     .o_axi_arlock    (ddr_axi_arlock),
     .o_axi_arcache   (ddr_axi_arcache),
     .o_axi_arprot    (ddr_axi_arprot),
     .o_axi_arqos     (ddr_axi_arqos),
     .o_axi_arregion  (ddr_axi_arregion),
     .o_axi_aruser    (ddr_axi_aruser),
     .o_axi_awready   (tmp_ddr_axi_awready),
     .o_axi_awvalid   (tmp_ddr_axi_awvalid),
     .o_axi_awid      (ddr_axi_awid),
     .o_axi_awaddr    (ddr_axi_awaddr),
     .o_axi_awlen     (ddr_axi_awlen),
     .o_axi_awsize    (ddr_axi_awsize),
     .o_axi_awburst   (ddr_axi_awburst),
     .o_axi_awlock    (ddr_axi_awlock),
     .o_axi_awcache   (ddr_axi_awcache),
     .o_axi_awprot    (ddr_axi_awprot),
     .o_axi_awqos     (ddr_axi_awqos),
     .o_axi_awregion  (ddr_axi_awregion),
     .o_axi_awuser    (ddr_axi_awuser), 
     .o_axi_wready    (tmp_ddr_axi_wready),
     .o_axi_wvalid    (tmp_ddr_axi_wvalid),
     .o_axi_wid       (ddr_axi_wid),
     .o_axi_wdata     (ddr_axi_wdata),
     .o_axi_wstrb     (ddr_axi_wstrb),
     .o_axi_wlast     (ddr_axi_wlast),
     .o_axi_rready    (tmp_ddr_axi_rready),
     .o_axi_rvalid    (tmp_ddr_axi_rvalid),
     .o_axi_rid       (ddr_axi_rid),
     .o_axi_rdata     (ddr_axi_rdata),
     .o_axi_rresp     (ddr_axi_rresp),
     .o_axi_rlast     (ddr_axi_rlast),
     .o_axi_bready    (tmp_ddr_axi_bready),
     .o_axi_bvalid    (tmp_ddr_axi_bvalid),
     .o_axi_bid       (ddr_axi_bid),
     .o_axi_bresp     (ddr_axi_bresp),
     .i_clk           (sys_clk),
     .o_clk           (ddr_clk),
     .i_rst_n         (sys_rst_n),
     .o_rst_n         (ddr_rst_n)
   `else
     .o_axi_arready   (os_axi_arready),
     .o_axi_arvalid   (os_axi_arvalid),
     .o_axi_arid      (os_axi_arid),
     .o_axi_araddr    (os_axi_araddr),
     .o_axi_arlen     (os_axi_arlen),
     .o_axi_arsize    (os_axi_arsize),
     .o_axi_arburst   (os_axi_arburst),
     .o_axi_arlock    (os_axi_arlock[0]),
     .o_axi_arcache   (os_axi_arcache),
     .o_axi_arprot    (os_axi_arprot),
     .o_axi_arqos     (os_axi_arqos),
     .o_axi_arregion  (os_axi_arregion),
     .o_axi_aruser    (os_axi_aruser),
     .o_axi_awready   (os_axi_awready),
     .o_axi_awvalid   (os_axi_awvalid),
     .o_axi_awid      (os_axi_awid),
     .o_axi_awaddr    (os_axi_awaddr),
     .o_axi_awlen     (os_axi_awlen),
     .o_axi_awsize    (os_axi_awsize),
     .o_axi_awburst   (os_axi_awburst),
     .o_axi_awlock    (os_axi_awlock[0]),
     .o_axi_awcache   (os_axi_awcache),
     .o_axi_awprot    (os_axi_awprot),
     .o_axi_awqos     (os_axi_awqos),
     .o_axi_awregion  (os_axi_awregion),
     .o_axi_awuser    (os_axi_awuser), 
     .o_axi_wready    (os_axi_wready),
     .o_axi_wvalid    (os_axi_wvalid),
     .o_axi_wid       (os_axi_wid),
     .o_axi_wdata     (os_axi_wdata),
     .o_axi_wstrb     (os_axi_wstrb),
     .o_axi_wlast     (os_axi_wlast),
     .o_axi_rready    (os_axi_rready),
     .o_axi_rvalid    (os_axi_rvalid),
     .o_axi_rid       (os_axi_rid),
     .o_axi_rdata     (os_axi_rdata),
     .o_axi_rresp     (os_axi_rresp),
     .o_axi_rlast     (os_axi_rlast),
     .o_axi_bready    (os_axi_bready),
     .o_axi_bvalid    (os_axi_bvalid),
     .o_axi_bid       (os_axi_bid),
     .o_axi_bresp     (os_axi_bresp),
     .i_clk           (sys_clk),
     .o_clk           (sys_clk),
     .i_rst_n         (sys_rst_n),
     .o_rst_n         (sys_rst_n)
   `endif
  );
`ifdef DDR_CONTROLLER
  wire [11:0] device_temp;
  wire app_zq_ack;
  wire app_ref_ack;
  wire app_sr_active;
  ddr3 u_ddr3 (
    .ddr3_addr                      (ddr3_addr),
    .ddr3_ba                        (ddr3_ba),
    .ddr3_cas_n                     (ddr3_cas_n),
    .ddr3_ck_n                      (ddr3_ck_n),
    .ddr3_ck_p                      (ddr3_ck_p),
    .ddr3_cke                       (ddr3_cke),
    .ddr3_ras_n                     (ddr3_ras_n),
    .ddr3_reset_n                   (ddr3_reset_n),
    .ddr3_we_n                      (ddr3_we_n),
    .ddr3_dq                        (ddr3_dq),
    .ddr3_dqs_n                     (ddr3_dqs_n),
    .ddr3_dqs_p                     (ddr3_dqs_p),
    .init_calib_complete            (init_calib_complete),
    .ddr3_cs_n                      (ddr3_cs_n),
    .ddr3_dm                        (ddr3_dm),
    .ddr3_odt                       (ddr3_odt),
    .ui_clk                         (ui_clk),
    .ui_clk_sync_rst                (ui_clk_sync_rst),
    .mmcm_locked                    (mmcm_locked),
    .aresetn                        (sys_rst_n),
    .app_sr_req                     (1'b0),
    .app_ref_req                    (1'b0),
    .app_zq_req                     (1'b0),
    .app_sr_active                  (app_sr_active),
    .app_ref_ack                    (app_ref_ack),
    .app_zq_ack                     (app_zq_ack),
    .s_axi_awid                     (ddr_axi_awid),
    .s_axi_awaddr                   (ddr_axi_awaddr),
    .s_axi_awlen                    (ddr_axi_awlen),
    .s_axi_awsize                   (ddr_axi_awsize),
    .s_axi_awburst                  (ddr_axi_awburst),
    .s_axi_awlock                   (ddr_axi_awlock),
    .s_axi_awcache                  (ddr_axi_awcache),
    .s_axi_awprot                   (ddr_axi_awprot),
    .s_axi_awqos                    (4'b0),
    .s_axi_awvalid                  (ddr_axi_awvalid),
    .s_axi_awready                  (ddr_axi_awready),
    .s_axi_wdata                    (ddr_axi_wdata),
    .s_axi_wstrb                    (ddr_axi_wstrb),
    .s_axi_wlast                    (ddr_axi_wlast),
    .s_axi_wvalid                   (ddr_axi_wvalid),
    .s_axi_wready                   (ddr_axi_wready),
    .s_axi_bid                      (ddr_axi_bid),
    .s_axi_bresp                    (ddr_axi_bresp),
    .s_axi_bvalid                   (ddr_axi_bvalid),
    .s_axi_bready                   (ddr_axi_bready),
    .s_axi_arid                     (ddr_axi_arid),
    .s_axi_araddr                   (ddr_axi_araddr),
    .s_axi_arlen                    (ddr_axi_arlen),
    .s_axi_arsize                   (ddr_axi_arsize),
    .s_axi_arburst                  (ddr_axi_arburst),
    .s_axi_arlock                   (ddr_axi_arlock),
    .s_axi_arcache                  (ddr_axi_arcache),
    .s_axi_arprot                   (ddr_axi_arprot),
    .s_axi_arqos                    (4'b0),
    .s_axi_arvalid                  (ddr_axi_arvalid),
    .s_axi_arready                  (ddr_axi_arready),
    .s_axi_rid                      (ddr_axi_rid),
    .s_axi_rdata                    (ddr_axi_rdata),
    .s_axi_rresp                    (ddr_axi_rresp),
    .s_axi_rlast                    (ddr_axi_rlast),
    .s_axi_rvalid                   (ddr_axi_rvalid),
    .s_axi_rready                   (ddr_axi_rready),
    .sys_clk_i                       (ddr3_sys_clk_i),
       .device_temp            (device_temp),
    .sys_rst                        (ddr3_sys_rst_i)
    );
`endif
endmodule
module e603_ddr3_axi2axi_async # (
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
  e603_ddr3_cdc_tx_rx # ( .DW(CMD_AR_PACK_W), .SYNC_DP(SYNC_DP) ) u_cmd_ar_cdc_tx_rx (
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
  e603_ddr3_cdc_tx_rx # ( .DW(CMD_AW_PACK_W), .SYNC_DP(SYNC_DP) ) u_cmd_aw_cdc_tx_rx (
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
  e603_ddr3_cdc_tx_rx # ( .DW(CMD_W_PACK_W), .SYNC_DP(SYNC_DP) ) u_cmd_w_cdc_tx_rx (
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
  e603_ddr3_cdc_tx_rx # ( .DW(CMD_R_PACK_W), .SYNC_DP(SYNC_DP) ) u_rsp_r_cdc_tx_rx (
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
  e603_ddr3_cdc_tx_rx # ( .DW(CMD_B_PACK_W), .SYNC_DP(SYNC_DP) ) u_rsp_b_cdc_tx_rx (
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
module e603_ddr3_cdc_tx_rx
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
module e603_ddr3_1cyc_sram_ctrl #(
    parameter CS_W = 1,
    parameter DW = 32,
    parameter MW = 4,
    parameter AW = 32,
    parameter AW_LSB = 3,
    parameter USR_W = 3 
)(
  output sram_ctrl_active,
  input  tcm_cgstop,
  input  stall_uop_cmd,
  input  uop_cmd_valid, 
  output uop_cmd_ready, 
  input  uop_cmd_read,  
  input  [AW-1:0] uop_cmd_addr, 
  input  [DW-1:0] uop_cmd_wdata, 
  input  [MW-1:0] uop_cmd_wmask, 
  input  [2-1:0]  uop_cmd_size,  
  input  [USR_W-1:0] uop_cmd_usr, 
  output uop_rsp_valid, 
  input  uop_rsp_ready, 
  output uop_rsp_err, 
  output [DW-1:0] uop_rsp_rdata, 
  output [USR_W-1:0] uop_rsp_usr, 
  output [CS_W-1:0]      ram_cs,  
  output [AW-AW_LSB-1:0] ram_addr, 
  output [MW-1:0] ram_wem,
  output          ram_we,
  output [DW-1:0] ram_din,          
  input  [DW-1:0] ram_dout,
  output          clk_ram,
  input  clkgate_bypass,
  input  clk,
  input  rst_n
  );
  wire i_uop_cmd_valid;
  wire i_uop_cmd_ready;
  assign uop_rsp_err = 1'b0; 
  assign i_uop_cmd_valid = (~stall_uop_cmd) & uop_cmd_valid;
  assign uop_cmd_ready   = (~stall_uop_cmd) & i_uop_cmd_ready;
  e603_gnrl_pipe_stage # (
   .CUT_READY(0),
   .DP(1),
   .DW(USR_W)
  ) u_e1_stage (
    .i_vld(i_uop_cmd_valid), 
    .i_rdy(i_uop_cmd_ready), 
    .i_dat(uop_cmd_usr),
    .o_vld(uop_rsp_valid), 
    .o_rdy(uop_rsp_ready), 
    .o_dat(uop_rsp_usr),
    .clk  (clk  ),
    .rst_n(rst_n)  
   );
   generate
   if (CS_W == 1) begin :gen_csw_1
   assign ram_cs = uop_cmd_valid & uop_cmd_ready;  
   end
   else begin :gen_csw_2
   assign ram_cs[0] = uop_cmd_valid && uop_cmd_ready;  
   assign ram_cs[1] = uop_cmd_valid && uop_cmd_ready;  
   end
   endgenerate
   assign ram_we = (~uop_cmd_read);  
   assign ram_addr= uop_cmd_addr [AW-1:AW_LSB];          
   assign ram_wem = {MW{ram_we}} & uop_cmd_wmask[MW-1:0];          
   assign ram_din = uop_cmd_wdata[DW-1:0];          
   wire ram_clk_en = |ram_cs | tcm_cgstop;
   e603_clkgate u_ram_clkgate(
     .clk_in   (clk        ),
     .clkgate_bypass(clkgate_bypass  ),
     .clock_en (ram_clk_en),
     .clk_out  (clk_ram)
   );
   assign uop_rsp_rdata = ram_dout;
   assign sram_ctrl_active = uop_cmd_valid | uop_rsp_valid;
endmodule
module e603_ddr3_sram_icb_ctrl #(
    parameter CS_W = 1,
    parameter DW = 32,
    parameter MW = 4,
    parameter AW = 32,
    parameter AW_LSB = 3,
    parameter USR_W = 3 
)(
  output sram_ctrl_active,
  input  tcm_cgstop,
  input  stall_uop_cmd,
  input  i_icb_cmd_valid, 
  output i_icb_cmd_ready, 
  input  i_icb_cmd_read,  
  input  [AW-1:0] i_icb_cmd_addr, 
  input  [DW-1:0] i_icb_cmd_wdata, 
  input  [MW-1:0] i_icb_cmd_wmask, 
  input  [USR_W-1:0] i_icb_cmd_usr, 
  output i_icb_rsp_valid, 
  input  i_icb_rsp_ready, 
  output [DW-1:0] i_icb_rsp_rdata, 
  output [USR_W-1:0] i_icb_rsp_usr, 
  output [CS_W-1:0]      ram_cs,  
  output [AW-AW_LSB-1:0] ram_addr, 
  output [MW-1:0] ram_wem,
  output [DW-1:0] ram_din,          
  input  [DW-1:0] ram_dout,
  output          clk_ram,
  input  clkgate_bypass,
  input  clk,
  input  rst_n
  );
  wire  byp_icb_cmd_valid;
  wire  byp_icb_cmd_ready;
  wire  byp_icb_cmd_read;
  wire  [AW-1:0] byp_icb_cmd_addr; 
  wire  [DW-1:0] byp_icb_cmd_wdata; 
  wire  [MW-1:0] byp_icb_cmd_wmask; 
  wire  [USR_W-1:0] byp_icb_cmd_usr; 
  localparam BUF_CMD_PACK_W = (AW+DW+MW+USR_W+1);
  wire [BUF_CMD_PACK_W-1:0] byp_icb_cmd_o_pack;
  wire [BUF_CMD_PACK_W-1:0] byp_icb_cmd_i_pack =  {
                      i_icb_cmd_read, 
                      i_icb_cmd_addr, 
                      i_icb_cmd_wdata, 
                      i_icb_cmd_wmask, 
                      i_icb_cmd_usr  
                    };
  assign {
                      byp_icb_cmd_read, 
                      byp_icb_cmd_addr, 
                      byp_icb_cmd_wdata, 
                      byp_icb_cmd_wmask, 
                      byp_icb_cmd_usr  
                    } = byp_icb_cmd_o_pack;
  e603_gnrl_bypbuf # (
   .DP(1),
   .DW(BUF_CMD_PACK_W)
  ) u_byp_icb_cmd_buf(
    .i_vld(i_icb_cmd_valid), 
    .i_rdy(i_icb_cmd_ready), 
    .i_dat(byp_icb_cmd_i_pack),
    .o_vld(byp_icb_cmd_valid), 
    .o_rdy(byp_icb_cmd_ready), 
    .o_dat(byp_icb_cmd_o_pack),
    .fifo_o_vld(),
    .clk  (clk  ),
    .rst_n(rst_n)  
   );
  wire sram_active;
  e603_ddr3_1cyc_sram_ctrl #(
      .CS_W   (CS_W),
      .DW     (DW),
      .AW     (AW),
      .MW     (MW),
      .AW_LSB (AW_LSB),
      .USR_W  (USR_W) 
  ) u_e603_1cyc_sram_ctrl(
     .sram_ctrl_active (sram_active),
     .tcm_cgstop       (tcm_cgstop),
     .stall_uop_cmd (stall_uop_cmd),
     .uop_cmd_valid (byp_icb_cmd_valid),
     .uop_cmd_ready (byp_icb_cmd_ready),
     .uop_cmd_read  (byp_icb_cmd_read ),
     .uop_cmd_addr  (byp_icb_cmd_addr ), 
     .uop_cmd_size  (2'b0             ), 
     .uop_cmd_wdata (byp_icb_cmd_wdata), 
     .uop_cmd_wmask (byp_icb_cmd_wmask), 
     .uop_cmd_usr   (byp_icb_cmd_usr  ),
     .uop_rsp_valid (i_icb_rsp_valid),
     .uop_rsp_ready (i_icb_rsp_ready),
     .uop_rsp_err   (               ),
     .uop_rsp_rdata (i_icb_rsp_rdata),
     .uop_rsp_usr   (i_icb_rsp_usr  ),
     .ram_cs   (ram_cs  ),  
     .ram_addr (ram_addr), 
     .ram_wem  (ram_wem ),
     .ram_we   (        ),
     .ram_din  (ram_din ),          
     .ram_dout (ram_dout),
     .clk_ram  (clk_ram ),
     .clkgate_bypass(clkgate_bypass  ),
     .clk  (clk  ),
     .rst_n(rst_n)  
    );
  assign sram_ctrl_active = 
                       i_icb_cmd_valid 
                     | byp_icb_cmd_valid 
                     | sram_active  
                     | i_icb_rsp_valid 
                     ;
endmodule
`include "global.v"
module e603_ddr3_sim_ram 
#(parameter DP = 512,
  parameter FORCE_X2ZERO = 0,
  parameter DW = 32,
  parameter MW = 4,
  parameter AW = 32 
)
(
  input             clk, 
  input  [DW-1  :0] din, 
  input  [AW-1  :0] addr,
  input             cs,
  input             we,
  input  [MW-1:0]   wem,
  output [DW-1:0]   dout
);
  localparam WBITS = ((DW-1) / MW) + 1;
    reg [MW*WBITS-1:0] mem_r [0:DP-1];
    reg [AW-1:0] addr_r;
    wire [MW-1:0] wen;
    wire ren;
    assign ren = cs & (~we);
    assign wen = ({MW{cs & we}} & wem);
    wire [MW*WBITS-1:0] i_din; 
    generate
      if(DW == (MW*WBITS)) begin:dw_eq_mw
          assign i_din = din; 
      end
      else begin: dw_ne_mw
          assign i_din = {{(MW*WBITS-DW){1'b0}},din}; 
      end
    endgenerate
    genvar i;
    always @(posedge clk)
    begin
        if (ren) begin
            addr_r <= addr;
        end
        else if((|wen)) begin
            addr_r <= ~addr;     
        end
    end
    generate
      for (i = 0; i < MW; i = i+1) begin :mem
          always @(posedge clk) begin
            if (wen[i]) begin
               mem_r[addr][WBITS*i+WBITS-1:WBITS*i] <= i_din[WBITS*i+WBITS-1:WBITS*i];
            end
          end
      end
    endgenerate
  wire [MW*WBITS-1:0] dout_pre;
  assign dout_pre = mem_r[addr_r];
  generate
   if(FORCE_X2ZERO == 1) begin: force_x_to_zero
      for (i = 0; i < DW; i = i+1) begin:force_x_gen 
          `ifndef SYNTHESIS
         assign dout[i] = (dout_pre[i] === 1'bx) ? 1'b0 : dout_pre[i];
          `else
         assign dout[i] = dout_pre[i];
          `endif
      end
   end
   else begin:no_force_x_to_zero
     assign dout = dout_pre[DW-1:0];
   end
  endgenerate
endmodule
`include "global.v"
module e603_ddr3_gnrl_ram
#(parameter DP = 32,
  parameter DW = 32,
  parameter FORCE_X2ZERO = 0,
  parameter GATE_CLK = 1,
  parameter MW = 4,
  parameter AW = 15
  ) (
  input            sd,
  input            ds,
  input            ls,
  input            rst_n,
  input            clk,
  input            clkgate_bypass,
  input            cs,
  input            we,
  input [AW-1:0]   addr,
  input [DW-1:0]   din,
  input [MW-1:0]   wem,
  output[DW-1:0]   dout
);
    wire clk_cg;
  generate
  if (GATE_CLK == 1)
  begin : gen_cg
  e603_clkgate u_clk_clkgate(
    .clk_in   (clk),
    .clkgate_bypass(clkgate_bypass  ),
    .clock_en (cs),
    .clk_out  (clk_cg )
  );
  end else begin : gen_non_cg
    assign clk_cg = clk;
  end
  endgenerate
e603_ddr3_sim_ram #(
    .FORCE_X2ZERO (FORCE_X2ZERO),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW)
)u_ram (
    .clk   (clk_cg),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);
endmodule
module e603_ddr3_icb_ram_top #(
    parameter AW = 12,
    parameter DW = 32
)(
  input                          icb_cmd_valid,
  output                         icb_cmd_ready,
  input                          icb_cmd_read, 
  input [AW-1:0]                 icb_cmd_addr, 
  input [DW-1:0]                 icb_cmd_wdata,
  input [DW/8-1:0]               icb_cmd_wmask,
  output                         icb_rsp_valid,
  input                          icb_rsp_ready,
  output [DW-1:0]                icb_rsp_rdata,
  output                         icb_rsp_err,
  input                          clk,
  input                          rst_n
  );
parameter AW_LSB      = $clog2(DW)-3;
parameter MW          = DW/8;
parameter DP          = (1<<(AW-AW_LSB));
wire                   ram_cs;
wire [AW-AW_LSB-1:0]   ram_addr;
wire [MW-1:0]          ram_wem;
wire [DW-1:0]          ram_din;
wire [DW-1:0]          ram_dout;
wire                   clk_ram;
wire                   ram_we;
 e603_ddr3_sram_icb_ctrl #(
      .DW     (DW    ),
      .AW     (AW    ),
      .MW     (MW    ),
      .AW_LSB (AW_LSB),
      .USR_W  (1     ) 
  ) u_sram_icb_ctrl (
     .sram_ctrl_active(             ),
     .tcm_cgstop      (1'b0         ),
     .stall_uop_cmd   (1'b0         ),
     .i_icb_cmd_valid (icb_cmd_valid),
     .i_icb_cmd_ready (icb_cmd_ready),
     .i_icb_cmd_read  (icb_cmd_read ),
     .i_icb_cmd_addr  (icb_cmd_addr ), 
     .i_icb_cmd_wdata (icb_cmd_wdata), 
     .i_icb_cmd_wmask (icb_cmd_wmask), 
     .i_icb_cmd_usr   (1'b0         ),
     .i_icb_rsp_valid (icb_rsp_valid),
     .i_icb_rsp_ready (icb_rsp_ready),
     .i_icb_rsp_rdata (icb_rsp_rdata),
     .i_icb_rsp_usr   (             ),
     .ram_cs          (ram_cs       ),  
     .ram_addr        (ram_addr     ), 
     .ram_wem         (ram_wem      ),
     .ram_din         (ram_din      ),          
     .ram_dout        (ram_dout     ),
     .clk_ram         (clk_ram      ),
     .clkgate_bypass  (1'b0         ),
     .clk             (clk          ),
     .rst_n           (rst_n        )  
    );
assign icb_rsp_err = 1'b0;
assign ram_we = |ram_wem;
 e603_ddr3_gnrl_ram #(
    .FORCE_X2ZERO(1), 
    .DP(DP),
    .DW(DW),
    .MW(MW),
    .AW(AW-AW_LSB) 
  ) u_gnrl_ram(
  .sd  (1'b0  ),
  .ds  (1'b0  ),
  .ls  (1'b0  ),
  .clkgate_bypass (1'b0),
  .rst_n (rst_n   ),
  .clk   (clk_ram ),
  .cs    (ram_cs  ),
  .addr  (ram_addr),
  .din   (ram_din ),
  .wem   (ram_wem ),
  .we    (ram_we  ),
  .dout  (ram_dout)
  );
endmodule
module e603_ddr3_axi2sram # (
  parameter AW = 32,
  parameter DW = 32,
  parameter ID_W = 4,
  parameter USR_W = 4,
  parameter MW = 4
) (
  output                           axi_arready,
  input                            axi_arvalid,
  input [ID_W-1:0]                 axi_arid,
  input [AW-1:0]                   axi_araddr,
  input [7:0]                      axi_arlen,
  input [2:0]                      axi_arsize,
  input [1:0]                      axi_arburst,
  input                            axi_arlock,
  input [3:0]                      axi_arcache,
  input [2:0]                      axi_arprot,
  input [3:0]                      axi_arqos,
  input [3:0]                      axi_arregion,
  input [USR_W-1:0]                axi_aruser,
  output                           axi_awready,
  input                            axi_awvalid,
  input [ID_W-1:0]                 axi_awid,
  input [AW-1:0]                   axi_awaddr,
  input [7:0]                      axi_awlen,
  input [2:0]                      axi_awsize,
  input [1:0]                      axi_awburst,
  input                            axi_awlock,
  input [3:0]                      axi_awcache,
  input [2:0]                      axi_awprot,
  input [3:0]                      axi_awqos,
  input [3:0]                      axi_awregion,
  input [USR_W-1:0]                axi_awuser, 
  output                           axi_wready,
  input                            axi_wvalid,
  input [ID_W-1:0]                 axi_wid,
  input [DW-1:0]                   axi_wdata,
  input [MW-1:0]                   axi_wstrb,
  input                            axi_wlast,
  input                            axi_rready,
  output                           axi_rvalid,
  output [ID_W-1:0]                axi_rid,
  output [DW-1:0]                  axi_rdata,
  output [1:0]                     axi_rresp,
  output                           axi_rlast,
  input                            axi_bready,
  output                           axi_bvalid,
  output [ID_W-1:0]                axi_bid,
  output [1:0]                     axi_bresp,
  input                            clk,
  input                            rst_n
  );
  wire                           icb_cmd_valid       ;
  wire                           icb_cmd_ready       ;
  wire [AW-1:0]                  icb_cmd_addr        ;  
  wire                           icb_cmd_read        ; 
  wire [2-1:0]                   icb_cmd_beat        ;
  wire [        DW-1:0]          icb_cmd_wdata       ;
  wire [        MW-1:0]          icb_cmd_wmask       ;
  wire                           icb_cmd_lock        ;
  wire                           icb_cmd_excl        ;
  wire [2:0]                     icb_cmd_size        ;
  wire                           icb_cmd_sel         ;
  wire [USR_W-1:0]               icb_cmd_user        ;
  wire                           icb_rsp_valid       ;
  wire                           icb_rsp_ready       ;
  wire                           icb_rsp_err         ;
  wire [        DW-1:0]          icb_rsp_rdata       ;
 e603_gnrl_axi2ficb # (
  .AW              ( AW ),
  .DW              ( DW ),
  .ID_W            ( ID_W  ),
  .USR_W           ( USR_W  ),
  .FIFO_OUTS_NUM   ( 4  ),
  .MW              ( MW  )
)
 u_gnrl_axi2icb
 (
     .reset_flag_r        (1'b0),
     .axi_slave_active    (),
     .axi_arready         (axi_arready),
     .axi_arvalid         (axi_arvalid),
     .axi_arid            (axi_arid),
     .axi_araddr          (axi_araddr),
     .axi_arlen           (axi_arlen),
     .axi_arsize          (axi_arsize),
     .axi_arburst         (axi_arburst),
     .axi_arlock          (axi_arlock),
     .axi_arcache         (axi_arcache),
     .axi_arprot          (axi_arprot),
     .axi_aruser          (axi_aruser),
     .axi_awready         (axi_awready),
     .axi_awvalid         (axi_awvalid),
     .axi_awid            (axi_awid),
     .axi_awaddr          (axi_awaddr),
     .axi_awlen           (axi_awlen),
     .axi_awsize          (axi_awsize),
     .axi_awburst         (axi_awburst),
     .axi_awlock          (axi_awlock), 
     .axi_awcache         (axi_awcache),
     .axi_awprot          (axi_awprot),
     .axi_awuser          (axi_awuser),  
     .axi_wready          (axi_wready),
     .axi_wvalid          (axi_wvalid),
     .axi_wdata           (axi_wdata),
     .axi_wstrb           (axi_wstrb),
     .axi_wlast           (axi_wlast),
     .axi_rready          (axi_rready),
     .axi_rvalid          (axi_rvalid),
     .axi_rid             (axi_rid),
     .axi_rdata           (axi_rdata),
     .axi_rresp           (axi_rresp),
     .axi_rlast           (axi_rlast),
     .axi_bready          (axi_bready),
     .axi_bvalid          (axi_bvalid),
     .axi_bid             (axi_bid),
     .axi_bresp           (axi_bresp),
     .axi_bus_clk_en      (1'b1),
     .icb_cmd_valid       (icb_cmd_valid),
     .icb_cmd_ready       (icb_cmd_ready),
     .icb_cmd_addr        (icb_cmd_addr),  
     .icb_cmd_read        (icb_cmd_read), 
     .icb_cmd_xburst      (),
     .icb_cmd_xlen        (),
     .icb_cmd_modes       (),
     .icb_cmd_dmode       (),
     .icb_cmd_attri       (),
     .icb_cmd_beat        (icb_cmd_beat),
     .icb_cmd_wdata       (icb_cmd_wdata),
     .icb_cmd_wmask       (icb_cmd_wmask),
     .icb_cmd_lock        (icb_cmd_lock),
     .icb_cmd_excl        (icb_cmd_excl),
     .icb_cmd_size        (icb_cmd_size),
     .icb_cmd_sel         (icb_cmd_sel),
     .icb_cmd_user        (icb_cmd_user),
     .icb_rsp_valid       (icb_rsp_valid),
     .icb_rsp_ready       (icb_rsp_ready),
     .icb_rsp_err         (icb_rsp_err),
     .icb_rsp_excl_ok     (1'b1),
     .icb_rsp_rdata       (icb_rsp_rdata),
     .clk                 (clk),
     .rst_n               (rst_n)
  );
e603_ddr3_icb_ram_top #(
    .AW(14),
    .DW(DW)
)
u_icb_ram_top
(
    .icb_cmd_valid (icb_cmd_valid),
    .icb_cmd_ready (icb_cmd_ready),
    .icb_cmd_read  (icb_cmd_read), 
    .icb_cmd_addr  (icb_cmd_addr[13:0]), 
    .icb_cmd_wdata (icb_cmd_wdata),
    .icb_cmd_wmask (icb_cmd_wmask),
    .icb_rsp_valid (icb_rsp_valid),
    .icb_rsp_ready (icb_rsp_ready),
    .icb_rsp_rdata (icb_rsp_rdata),
    .icb_rsp_err   (icb_rsp_err),
    .clk           (clk),
    .rst_n         (rst_n)
  );
endmodule
`endif
