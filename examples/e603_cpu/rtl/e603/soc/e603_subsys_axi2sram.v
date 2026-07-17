 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_subsys_axi2sram # (
  parameter AW = 32,
  parameter DW = 32,
  parameter ID_W = 4,
  parameter DELAY_WIDTH=9,
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
  input  [DELAY_WIDTH-1:0] delay_select,
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
  wire [USR_W-1:0]               icb_cmd_usr        ;
  wire                           icb_rsp_valid       ;
  wire                           icb_rsp_ready       ;
  wire                           icb_rsp_err         ;
  wire [        DW-1:0]          icb_rsp_rdata       ;
 e603_gnrl_axi2ficb # (
  .AW              ( AW ),
  .DW              ( DW ),
  .ID_W            ( ID_W  ),
  .USR_W           ( USR_W  ),
`ifndef NXX_CCT_DDR_LATENCY  
  .FIFO_OUTS_NUM   ( 4  ),
`else
  .FIFO_OUTS_NUM   ( 512 ),
`endif
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
     .icb_cmd_user        (),
     .icb_cmd_beat        (icb_cmd_beat),
     .icb_cmd_wdata       (icb_cmd_wdata),
     .icb_cmd_wmask       (icb_cmd_wmask),
     .icb_cmd_lock        (icb_cmd_lock),
     .icb_cmd_excl        (icb_cmd_excl),
     .icb_cmd_size        (icb_cmd_size),
     .icb_cmd_sel         (icb_cmd_sel),
     .icb_rsp_valid       (icb_rsp_valid),
     .icb_rsp_ready       (icb_rsp_ready),
     .icb_rsp_err         (icb_rsp_err),
     .icb_rsp_excl_ok     (1'b1),
     .icb_rsp_rdata       (icb_rsp_rdata),
     .clk                 (clk),
     .rst_n               (rst_n)
  );
    localparam RAM_AW = 29;
e603_icb_ram_top #(
    .DELAY_WIDTH(DELAY_WIDTH),
    .AW(RAM_AW),
    .DW(DW)
)
u_icb_ram_top
(
    .delay_select    (delay_select),
    .icb_cmd_valid (icb_cmd_valid),
    .icb_cmd_ready (icb_cmd_ready),
    .icb_cmd_read  (icb_cmd_read), 
    .icb_cmd_addr  (icb_cmd_addr[RAM_AW-1:0]), 
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
