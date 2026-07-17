 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
`include "global.v"
module e603_subsys_perips(
 output misc_nmi,
 output misc_evt,
 output misc_dbg_secure_enable,
 output misc_dbg_isolate,
 output misc_dbg_override_dm_sleep,
 output misc_dbg_stop_at_boot,
 output misc_dbg_i_dbg_stop,
   output[3:0] iocp_arcache,
   output[3:0] iocp_awcache,
   output[27:0] iocp_ar_hi_addr,
   output[27:0] iocp_aw_hi_addr,
  output [9-1:0]  mem_delay_select,
  input                          biu2ppi_icb_cmd_valid,
  output                         biu2ppi_icb_cmd_ready,
  input  [32-1:0]   biu2ppi_icb_cmd_addr, 
  input                          biu2ppi_icb_cmd_read, 
  input  [32-1:0]        biu2ppi_icb_cmd_wdata,
  input  [32/8-1:0]      biu2ppi_icb_cmd_wmask,
  output                         biu2ppi_icb_rsp_valid,
  input                          biu2ppi_icb_rsp_ready,
  output                         biu2ppi_icb_rsp_err  ,
  output [32-1:0]        biu2ppi_icb_rsp_rdata,
  input                      qspi0_ro_icb_cmd_valid,
  output                     qspi0_ro_icb_cmd_ready,
  input  [32-1:0]            qspi0_ro_icb_cmd_addr, 
  input                      qspi0_ro_icb_cmd_read, 
  input  [32-1:0]            qspi0_ro_icb_cmd_wdata,
  output                     qspi0_ro_icb_rsp_valid,
  input                      qspi0_ro_icb_rsp_ready,
  output [32-1:0]            qspi0_ro_icb_rsp_rdata,
  output             udma_w_icb_cmd_valid               ,
  input              udma_w_icb_cmd_ready               ,
  output             udma_w_icb_cmd_sel                 ,
  output             udma_w_icb_cmd_read                ,
  output [  63:   0] udma_w_icb_cmd_addr                ,
  output [  63:   0] udma_w_icb_cmd_wdata               ,
  output [   7:   0] udma_w_icb_cmd_wmask               ,
  output [   2:   0] udma_w_icb_cmd_size                ,
  output             udma_w_icb_cmd_lock                ,
  output             udma_w_icb_cmd_excl                ,
  output [   7:   0] udma_w_icb_cmd_xlen                ,
  output [   1:   0] udma_w_icb_cmd_xburst              ,
  output [   1:   0] udma_w_icb_cmd_modes               ,
  output             udma_w_icb_cmd_dmode               ,
  output [   2:   0] udma_w_icb_cmd_attri               ,
  output [   1:   0] udma_w_icb_cmd_beat                ,
  output             udma_w_icb_rsp_ready               ,
  input              udma_w_icb_rsp_valid               ,
  input              udma_w_icb_rsp_err                 ,
  input              udma_w_icb_rsp_excl_ok             ,
  input  [  63:   0] udma_w_icb_rsp_rdata               ,
  output             udma_r_icb_cmd_valid               ,
  input              udma_r_icb_cmd_ready               ,
  output             udma_r_icb_cmd_sel                 ,
  output             udma_r_icb_cmd_read                ,
  output [  63:   0] udma_r_icb_cmd_addr                ,
  output [  63:   0] udma_r_icb_cmd_wdata               ,
  output [   7:   0] udma_r_icb_cmd_wmask               ,
  output [   2:   0] udma_r_icb_cmd_size                ,
  output             udma_r_icb_cmd_lock                ,
  output             udma_r_icb_cmd_excl                ,
  output [   7:   0] udma_r_icb_cmd_xlen                ,
  output [   1:   0] udma_r_icb_cmd_xburst              ,
  output [   1:   0] udma_r_icb_cmd_modes               ,
  output             udma_r_icb_cmd_dmode               ,
  output [   2:   0] udma_r_icb_cmd_attri               ,
  output [   1:   0] udma_r_icb_cmd_beat                ,
  output             udma_r_icb_rsp_ready               ,
  input              udma_r_icb_rsp_valid               ,
  input              udma_r_icb_rsp_err                 ,
  input              udma_r_icb_rsp_excl_ok             ,
  input  [  63:   0] udma_r_icb_rsp_rdata               ,
  input  [  11:   0] eth_cfg_apb_paddr      ,
  input              eth_cfg_apb_pwrite     ,
  input              eth_cfg_apb_psel       ,
  input  [   2:   0] eth_cfg_apb_pprot      ,
  input  [   3:   0] eth_cfg_apb_pstrobe    ,
  input              eth_cfg_apb_penable    ,
  input  [  31:   0] eth_cfg_apb_pwdata     ,
  output[  31:   0]  eth_cfg_apb_prdata     ,
  output             eth_cfg_apb_pready     ,
  output             eth_cfg_apb_pslverr    ,
  input              eth_axi_arready ,
  output             eth_axi_arvalid ,
  output[  31:   0]  eth_axi_araddr  ,
  output[   7:   0]  eth_axi_arlen   ,
  output[   2:   0]  eth_axi_arsize  ,
  output[   1:   0]  eth_axi_arburst ,
  output             eth_axi_arlock  ,
  output[   3:   0]  eth_axi_arcache ,
  output[   2:   0]  eth_axi_arprot  ,
  input              eth_axi_rvalid  ,
  output             eth_axi_rready  ,
  input [  63:   0]  eth_axi_rdata   ,
  input [   1:   0]  eth_axi_rresp   ,
  input              eth_axi_rlast   ,
  output            eth_axi_awvalid ,
  input             eth_axi_awready ,
  output[  31:   0] eth_axi_awaddr  ,
  output[   7:   0] eth_axi_awlen   ,
  output[   2:   0] eth_axi_awsize  ,
  output[   1:   0] eth_axi_awburst ,
  output            eth_axi_awlock  ,
  output[   3:   0] eth_axi_awcache ,
  output[   2:   0] eth_axi_awprot  ,
  output            eth_axi_wvalid  ,
  input             eth_axi_wready  ,
  output[  63:   0] eth_axi_wdata   ,
  output[   7:   0] eth_axi_wstrb   ,
  output            eth_axi_wlast   ,
  input             eth_axi_bvalid  ,
  output            eth_axi_bready  ,
  input  [   1:  0] eth_axi_bresp  ,
  output            ethernet_irq,
  input              xec_sys_clk                   ,
  input              xmii_txc_i_ival               ,
  output             xmii_txc_o_oval               ,
  output             xmii_txc_o_oe                 ,
  input              gmii_rxc_i_ival               ,
  input              gmii_rxd_bit0_i_ival          ,
  output             gmii_txd_bit0_o_oval          ,
  input              gmii_rxd_bit1_i_ival          ,
  output             gmii_txd_bit1_o_oval          ,
  input              gmii_rxd_bit2_i_ival          ,
  output             gmii_txd_bit2_o_oval          ,
  input              gmii_rxd_bit3_i_ival          ,
  output             gmii_txd_bit3_o_oval          ,
  input              gmii_crs_i_ival               ,
  input              gmii_col_i_ival               ,
  input              gmii_rxdv_i_ival              ,
  input              gmii_rxer_i_ival              ,
  output             gmii_txen_o_oval              ,
  output             gmii_txer_o_oval              ,
  input              mdio_i_ival                   ,
  output             mdio_o_oval                   ,
  output             mdio_o_oe                     ,
  output             mdc_o_oval                    ,
  input   io_pads_qspi0_sck_i_ival,
  output  io_pads_qspi0_sck_o_oval,
  output  io_pads_qspi0_sck_o_oe,
  output  io_pads_qspi0_sck_o_ie,
  output  io_pads_qspi0_sck_o_pue,
  output  io_pads_qspi0_sck_o_ds,
  input   io_pads_qspi0_dq_0_i_ival,
  output  io_pads_qspi0_dq_0_o_oval,
  output  io_pads_qspi0_dq_0_o_oe,
  output  io_pads_qspi0_dq_0_o_ie,
  output  io_pads_qspi0_dq_0_o_pue,
  output  io_pads_qspi0_dq_0_o_ds,
  input   io_pads_qspi0_dq_1_i_ival,
  output  io_pads_qspi0_dq_1_o_oval,
  output  io_pads_qspi0_dq_1_o_oe,
  output  io_pads_qspi0_dq_1_o_ie,
  output  io_pads_qspi0_dq_1_o_pue,
  output  io_pads_qspi0_dq_1_o_ds,
  input   io_pads_qspi0_dq_2_i_ival,
  output  io_pads_qspi0_dq_2_o_oval,
  output  io_pads_qspi0_dq_2_o_oe,
  output  io_pads_qspi0_dq_2_o_ie,
  output  io_pads_qspi0_dq_2_o_pue,
  output  io_pads_qspi0_dq_2_o_ds,
  input   io_pads_qspi0_dq_3_i_ival,
  output  io_pads_qspi0_dq_3_o_oval,
  output  io_pads_qspi0_dq_3_o_oe,
  output  io_pads_qspi0_dq_3_o_ie,
  output  io_pads_qspi0_dq_3_o_pue,
  output  io_pads_qspi0_dq_3_o_ds,
  input   io_pads_qspi0_cs_0_i_ival,
  output  io_pads_qspi0_cs_0_o_oval,
  output  io_pads_qspi0_cs_0_o_oe,
  output  io_pads_qspi0_cs_0_o_ie,
  output  io_pads_qspi0_cs_0_o_pue,
  output  io_pads_qspi0_cs_0_o_ds,
  input   io_pads_qspi1_sck_i_ival,
  output  io_pads_qspi1_sck_o_oval,
  output  io_pads_qspi1_sck_o_oe,
  output  io_pads_qspi1_sck_o_ie,
  output  io_pads_qspi1_sck_o_pue,
  output  io_pads_qspi1_sck_o_ds,
  input   io_pads_qspi1_dq_0_i_ival,
  output  io_pads_qspi1_dq_0_o_oval,
  output  io_pads_qspi1_dq_0_o_oe,
  output  io_pads_qspi1_dq_0_o_ie,
  output  io_pads_qspi1_dq_0_o_pue,
  output  io_pads_qspi1_dq_0_o_ds,
  input   io_pads_qspi1_dq_1_i_ival,
  output  io_pads_qspi1_dq_1_o_oval,
  output  io_pads_qspi1_dq_1_o_oe,
  output  io_pads_qspi1_dq_1_o_ie,
  output  io_pads_qspi1_dq_1_o_pue,
  output  io_pads_qspi1_dq_1_o_ds,
  input   io_pads_qspi1_dq_2_i_ival,
  output  io_pads_qspi1_dq_2_o_oval,
  output  io_pads_qspi1_dq_2_o_oe,
  output  io_pads_qspi1_dq_2_o_ie,
  output  io_pads_qspi1_dq_2_o_pue,
  output  io_pads_qspi1_dq_2_o_ds,
  input   io_pads_qspi1_dq_3_i_ival,
  output  io_pads_qspi1_dq_3_o_oval,
  output  io_pads_qspi1_dq_3_o_oe,
  output  io_pads_qspi1_dq_3_o_ie,
  output  io_pads_qspi1_dq_3_o_pue,
  output  io_pads_qspi1_dq_3_o_ds,
  input   io_pads_qspi1_cs_0_i_ival,
  output  io_pads_qspi1_cs_0_o_oval,
  output  io_pads_qspi1_cs_0_o_oe,
  output  io_pads_qspi1_cs_0_o_ie,
  output  io_pads_qspi1_cs_0_o_pue,
  output  io_pads_qspi1_cs_0_o_ds,
  input   io_pads_qspi1_cs_1_i_ival,
  output  io_pads_qspi1_cs_1_o_oval,
  output  io_pads_qspi1_cs_1_o_oe,
  output  io_pads_qspi1_cs_1_o_ie,
  output  io_pads_qspi1_cs_1_o_pue,
  output  io_pads_qspi1_cs_1_o_ds,
  input   io_pads_qspi1_cs_2_i_ival,
  output  io_pads_qspi1_cs_2_o_oval,
  output  io_pads_qspi1_cs_2_o_oe,
  output  io_pads_qspi1_cs_2_o_ie,
  output  io_pads_qspi1_cs_2_o_pue,
  output  io_pads_qspi1_cs_2_o_ds,
  input   io_pads_qspi1_cs_3_i_ival,
  output  io_pads_qspi1_cs_3_o_oval,
  output  io_pads_qspi1_cs_3_o_oe,
  output  io_pads_qspi1_cs_3_o_ie,
  output  io_pads_qspi1_cs_3_o_pue,
  output  io_pads_qspi1_cs_3_o_ds,
  input   io_pads_qspi2_sck_i_ival,
  output  io_pads_qspi2_sck_o_oval,
  output  io_pads_qspi2_sck_o_oe,
  output  io_pads_qspi2_sck_o_ie,
  output  io_pads_qspi2_sck_o_pue,
  output  io_pads_qspi2_sck_o_ds,
  input   io_pads_qspi2_dq_0_i_ival,
  output  io_pads_qspi2_dq_0_o_oval,
  output  io_pads_qspi2_dq_0_o_oe,
  output  io_pads_qspi2_dq_0_o_ie,
  output  io_pads_qspi2_dq_0_o_pue,
  output  io_pads_qspi2_dq_0_o_ds,
  input   io_pads_qspi2_dq_1_i_ival,
  output  io_pads_qspi2_dq_1_o_oval,
  output  io_pads_qspi2_dq_1_o_oe,
  output  io_pads_qspi2_dq_1_o_ie,
  output  io_pads_qspi2_dq_1_o_pue,
  output  io_pads_qspi2_dq_1_o_ds,
  input   io_pads_qspi2_dq_2_i_ival,
  output  io_pads_qspi2_dq_2_o_oval,
  output  io_pads_qspi2_dq_2_o_oe,
  output  io_pads_qspi2_dq_2_o_ie,
  output  io_pads_qspi2_dq_2_o_pue,
  output  io_pads_qspi2_dq_2_o_ds,
  input   io_pads_qspi2_dq_3_i_ival,
  output  io_pads_qspi2_dq_3_o_oval,
  output  io_pads_qspi2_dq_3_o_oe,
  output  io_pads_qspi2_dq_3_o_ie,
  output  io_pads_qspi2_dq_3_o_pue,
  output  io_pads_qspi2_dq_3_o_ds,
  input   io_pads_qspi2_cs_0_i_ival,
  output  io_pads_qspi2_cs_0_o_oval,
  output  io_pads_qspi2_cs_0_o_oe,
  output  io_pads_qspi2_cs_0_o_ie,
  output  io_pads_qspi2_cs_0_o_pue,
  output  io_pads_qspi2_cs_0_o_ds,
  input   io_pads_uart0_rxd_i_ival,
  output  io_pads_uart0_rxd_o_oval,
  output  io_pads_uart0_rxd_o_oe,
  output  io_pads_uart0_rxd_o_ie,
  output  io_pads_uart0_rxd_o_pue,
  output  io_pads_uart0_rxd_o_ds,
  input   io_pads_uart0_txd_i_ival,
  output  io_pads_uart0_txd_o_oval,
  output  io_pads_uart0_txd_o_oe,
  output  io_pads_uart0_txd_o_ie,
  output  io_pads_uart0_txd_o_pue,
  output  io_pads_uart0_txd_o_ds,
  output qspi0_irq, 
  output qspi1_irq,
  output qspi2_irq,
  output uart0_irq,                
  output udma_irq,
  output sdio_irq,
  output  misc_irq0,
  output  misc_irq1,
  input  clk,
  input  bus_rst_n,
  input  rst_n
);
  wire qspi0_sck;
  wire qspi0_dq_0_i;
  wire qspi0_dq_0_o;
  wire qspi0_dq_0_oe;
  wire qspi0_dq_1_i;
  wire qspi0_dq_1_o;
  wire qspi0_dq_1_oe;
  wire qspi0_dq_2_i;
  wire qspi0_dq_2_o;
  wire qspi0_dq_2_oe;
  wire qspi0_dq_3_i;
  wire qspi0_dq_3_o;
  wire qspi0_dq_3_oe;
  wire qspi0_cs_0;
  wire sdio_enable;
  wire sdclk_i_ival;
  wire sdclk_o_oval;
  wire sdclk_o_oe;
  wire sdclk_o_pue;
  wire sdcmd_i_ival;
  wire sdcmd_o_oval;
  wire sdcmd_o_oe;
  wire sdcmd_o_pue;
  wire sddata0_i_ival;
  wire sddata0_o_oval;
  wire sddata0_o_oe;
  wire sddata0_o_pue;
  wire sddata1_i_ival;
  wire sddata1_o_oval;
  wire sddata1_o_oe;
  wire sddata1_o_pue;
  wire sddata2_i_ival;
  wire sddata2_o_oval;
  wire sddata2_o_oe;
  wire sddata2_o_pue;
  wire sddata3_i_ival;
  wire sddata3_o_oval;
  wire sddata3_o_oe;
  wire sddata3_o_pue;
  wire sddata4_i_ival = 1'b0;
  wire sddata4_o_oval;
  wire sddata4_o_oe;
  wire sddata4_o_pue;
  wire sddata5_i_ival = 1'b0;
  wire sddata5_o_oval;
  wire sddata5_o_oe;
  wire sddata5_o_pue;
  wire sddata6_i_ival = 1'b0;
  wire sddata6_o_oval;
  wire sddata6_o_oe;
  wire sddata6_o_pue;
  wire sddata7_i_ival = 1'b0;
  wire sddata7_o_oval;
  wire sddata7_o_oe;
  wire sddata7_o_pue;
  wire sddata8_i_ival = 1'b0;
  wire sddata8_o_oval;
  wire sddata8_o_oe;
  wire sddata8_o_pue;
  wire qspi1_sck = 1'b0;
  wire qspi1_dq_0_i;
  wire qspi1_dq_0_o = 1'b0;
  wire qspi1_dq_0_oe = 1'b0;
  wire qspi1_dq_1_i;
  wire qspi1_dq_1_o = 1'b0;
  wire qspi1_dq_1_oe = 1'b0;
  wire qspi1_dq_2_i;
  wire qspi1_dq_2_o = 1'b0;
  wire qspi1_dq_2_oe = 1'b0;
  wire qspi1_dq_3_i;
  wire qspi1_dq_3_o = 1'b0;
  wire qspi1_dq_3_oe = 1'b0;
  wire qspi1_cs_0 = 1'b0;
  wire qspi1_cs_1 = 1'b0;
  wire qspi1_cs_2 = 1'b0;
  wire qspi1_cs_3 = 1'b0;
  wire qspi2_sck;
  wire qspi2_dq_0_i;
  wire qspi2_dq_0_o;
  wire qspi2_dq_0_oe;
  wire qspi2_dq_1_i;
  wire qspi2_dq_1_o;
  wire qspi2_dq_1_oe;
  wire qspi2_dq_2_i;
  wire qspi2_dq_2_o;
  wire qspi2_dq_2_oe;
  wire qspi2_dq_3_i;
  wire qspi2_dq_3_o;
  wire qspi2_dq_3_oe;
  wire qspi2_cs_0;
  wire  uart0_txd;
  wire  uart0_rxd;
  assign io_pads_qspi0_sck_o_oval = qspi0_sck;
  assign io_pads_qspi0_sck_o_oe   = 1'b1;
  assign io_pads_qspi0_sck_o_ie   = 1'b0;
  assign io_pads_qspi0_sck_o_pue  = 1'b0;
  assign io_pads_qspi0_sck_o_ds   = 1'b0;
  assign qspi0_dq_0_i = io_pads_qspi0_dq_0_i_ival;
  assign io_pads_qspi0_dq_0_o_oval= qspi0_dq_0_o;
  assign io_pads_qspi0_dq_0_o_oe  = qspi0_dq_0_oe;
  assign io_pads_qspi0_dq_0_o_ie  = ~qspi0_dq_0_oe;
  assign io_pads_qspi0_dq_0_o_pue = 1'b1;
  assign io_pads_qspi0_dq_0_o_ds  = 1'b1;
  assign qspi0_dq_1_i = io_pads_qspi0_dq_1_i_ival;
  assign io_pads_qspi0_dq_1_o_oval= qspi0_dq_1_o;
  assign io_pads_qspi0_dq_1_o_oe  = qspi0_dq_1_oe;
  assign io_pads_qspi0_dq_1_o_ie  = ~qspi0_dq_1_oe;
  assign io_pads_qspi0_dq_1_o_pue = 1'b1;
  assign io_pads_qspi0_dq_1_o_ds  = 1'b1;
  assign qspi0_dq_2_i = io_pads_qspi0_dq_2_i_ival;
  assign io_pads_qspi0_dq_2_o_oval= qspi0_dq_2_o;
  assign io_pads_qspi0_dq_2_o_oe  = qspi0_dq_2_oe;
  assign io_pads_qspi0_dq_2_o_ie  = ~qspi0_dq_2_oe;
  assign io_pads_qspi0_dq_2_o_pue = 1'b1;
  assign io_pads_qspi0_dq_2_o_ds  = 1'b1;
  assign qspi0_dq_3_i = io_pads_qspi0_dq_3_i_ival;
  assign io_pads_qspi0_dq_3_o_oval= qspi0_dq_3_o;
  assign io_pads_qspi0_dq_3_o_oe  = qspi0_dq_3_oe;
  assign io_pads_qspi0_dq_3_o_ie  = ~qspi0_dq_3_oe;
  assign io_pads_qspi0_dq_3_o_pue = 1'b1;
  assign io_pads_qspi0_dq_3_o_ds  = 1'b1;
  assign io_pads_qspi0_cs_0_o_oval= qspi0_cs_0;
  assign io_pads_qspi0_cs_0_o_oe  = 1'b1;
  assign io_pads_qspi0_cs_0_o_ie  = 1'b0;
  assign io_pads_qspi0_cs_0_o_pue = 1'b0;
  assign io_pads_qspi0_cs_0_o_ds  = 1'b0;
  assign io_pads_qspi1_sck_o_oval = qspi1_sck;
  assign io_pads_qspi1_sck_o_oe   = 1'b1;
  assign io_pads_qspi1_sck_o_ie   = 1'b0;
  assign io_pads_qspi1_sck_o_pue  = 1'b0;
  assign io_pads_qspi1_sck_o_ds   = 1'b0;
  assign qspi1_dq_0_i = io_pads_qspi1_dq_0_i_ival;
  assign io_pads_qspi1_dq_0_o_oval= qspi1_dq_0_o;
  assign io_pads_qspi1_dq_0_o_oe  = qspi1_dq_0_oe;
  assign io_pads_qspi1_dq_0_o_ie  = ~qspi1_dq_0_oe;
  assign io_pads_qspi1_dq_0_o_pue = 1'b1;
  assign io_pads_qspi1_dq_0_o_ds  = 1'b1;
  assign qspi1_dq_1_i = io_pads_qspi1_dq_1_i_ival;
  assign io_pads_qspi1_dq_1_o_oval= qspi1_dq_1_o;
  assign io_pads_qspi1_dq_1_o_oe  = qspi1_dq_1_oe;
  assign io_pads_qspi1_dq_1_o_ie  = ~qspi1_dq_1_oe;
  assign io_pads_qspi1_dq_1_o_pue = 1'b1;
  assign io_pads_qspi1_dq_1_o_ds  = 1'b1;
  assign qspi1_dq_2_i = io_pads_qspi1_dq_2_i_ival;
  assign io_pads_qspi1_dq_2_o_oval= qspi1_dq_2_o;
  assign io_pads_qspi1_dq_2_o_oe  = qspi1_dq_2_oe;
  assign io_pads_qspi1_dq_2_o_ie  = ~qspi1_dq_2_oe;
  assign io_pads_qspi1_dq_2_o_pue = 1'b1;
  assign io_pads_qspi1_dq_2_o_ds  = 1'b1;
  assign qspi1_dq_3_i = io_pads_qspi1_dq_3_i_ival;
  assign io_pads_qspi1_dq_3_o_oval= qspi1_dq_3_o;
  assign io_pads_qspi1_dq_3_o_oe  = qspi1_dq_3_oe;
  assign io_pads_qspi1_dq_3_o_ie  = ~qspi1_dq_3_oe;
  assign io_pads_qspi1_dq_3_o_pue = 1'b1;
  assign io_pads_qspi1_dq_3_o_ds  = 1'b1;
  assign io_pads_qspi1_cs_0_o_oval= qspi1_cs_0;
  assign io_pads_qspi1_cs_0_o_oe  = 1'b1;
  assign io_pads_qspi1_cs_0_o_ie  = 1'b0;
  assign io_pads_qspi1_cs_0_o_pue = 1'b0;
  assign io_pads_qspi1_cs_0_o_ds  = 1'b0;
  assign io_pads_qspi1_cs_1_o_oval= qspi1_cs_1;
  assign io_pads_qspi1_cs_1_o_oe  = 1'b1;
  assign io_pads_qspi1_cs_1_o_ie  = 1'b0;
  assign io_pads_qspi1_cs_1_o_pue = 1'b0;
  assign io_pads_qspi1_cs_1_o_ds  = 1'b0;
  assign io_pads_qspi1_cs_2_o_oval= qspi1_cs_2;
  assign io_pads_qspi1_cs_2_o_oe  = 1'b1;
  assign io_pads_qspi1_cs_2_o_ie  = 1'b0;
  assign io_pads_qspi1_cs_2_o_pue = 1'b0;
  assign io_pads_qspi1_cs_2_o_ds  = 1'b0;
  assign io_pads_qspi1_cs_3_o_oval= qspi1_cs_3;
  assign io_pads_qspi1_cs_3_o_oe  = 1'b1;
  assign io_pads_qspi1_cs_3_o_ie  = 1'b0;
  assign io_pads_qspi1_cs_3_o_pue = 1'b0;
  assign io_pads_qspi1_cs_3_o_ds  = 1'b0;
  assign sdclk_i_ival = io_pads_qspi2_sck_i_ival;
  assign io_pads_qspi2_sck_o_oval = sdio_enable ? sdclk_o_oval : qspi2_sck;
  assign io_pads_qspi2_sck_o_oe   = sdio_enable ? sdclk_o_oe : 1'b1;
  assign io_pads_qspi2_sck_o_ie   = 1'b0;
  assign io_pads_qspi2_sck_o_pue  = sdio_enable ? sdclk_o_pue : 1'b0;
  assign io_pads_qspi2_sck_o_ds   = 1'b0;
  assign sddata3_i_ival = io_pads_qspi2_cs_0_i_ival;
  assign io_pads_qspi2_cs_0_o_oval= sdio_enable ? sddata3_o_oval : qspi2_cs_0;
  assign io_pads_qspi2_cs_0_o_oe  = sdio_enable ? sddata3_o_oe : 1'b1;
  assign io_pads_qspi2_cs_0_o_ie  = sdio_enable ? ~sddata3_o_oe: 1'b0;
  assign io_pads_qspi2_cs_0_o_pue = sdio_enable ? sddata3_o_pue : 1'b0;
  assign io_pads_qspi2_cs_0_o_ds  = 1'b0;
  assign sdcmd_i_ival = io_pads_qspi2_dq_0_i_ival;
  assign qspi2_dq_0_i = io_pads_qspi2_dq_0_i_ival;
  assign io_pads_qspi2_dq_0_o_oval= sdio_enable ? sdcmd_o_oval : qspi2_dq_0_o;
  assign io_pads_qspi2_dq_0_o_oe  = sdio_enable ? sdcmd_o_oe : qspi2_dq_0_oe;
  assign io_pads_qspi2_dq_0_o_ie  = sdio_enable ? ~sdcmd_o_oe : ~qspi2_dq_0_oe;
  assign io_pads_qspi2_dq_0_o_pue = sdio_enable ? sdcmd_o_pue : 1'b0;
  assign io_pads_qspi2_dq_0_o_ds  = 1'b0;
  assign sddata0_i_ival = io_pads_qspi2_dq_1_i_ival;
  assign qspi2_dq_1_i = io_pads_qspi2_dq_1_i_ival;
  assign io_pads_qspi2_dq_1_o_oval= sdio_enable ? sddata0_o_oval : qspi2_dq_1_o;
  assign io_pads_qspi2_dq_1_o_oe  = sdio_enable ? sddata0_o_oe :   qspi2_dq_1_oe;
  assign io_pads_qspi2_dq_1_o_ie  = sdio_enable ? ~sddata0_o_oe : ~qspi2_dq_1_oe;
  assign io_pads_qspi2_dq_1_o_pue = sdio_enable ? sddata0_o_pue : 1'b0;
  assign io_pads_qspi2_dq_1_o_ds  = 1'b0;
  assign sddata1_i_ival = io_pads_qspi2_dq_2_i_ival;
  assign qspi2_dq_2_i = io_pads_qspi2_dq_2_i_ival;
  assign io_pads_qspi2_dq_2_o_oval= sdio_enable ? sddata1_o_oval : qspi2_dq_2_o;
  assign io_pads_qspi2_dq_2_o_oe  = sdio_enable ? sddata1_o_oe :   qspi2_dq_2_oe;
  assign io_pads_qspi2_dq_2_o_ie  = sdio_enable ? ~sddata1_o_oe : ~qspi2_dq_2_oe;
  assign io_pads_qspi2_dq_2_o_pue = sdio_enable ? sddata1_o_pue : 1'b0;
  assign io_pads_qspi2_dq_2_o_ds  = 1'b0;
  assign sddata2_i_ival = io_pads_qspi2_dq_3_i_ival;
  assign qspi2_dq_3_i = io_pads_qspi2_dq_3_i_ival;
  assign io_pads_qspi2_dq_3_o_oval= sdio_enable ? sddata2_o_oval : qspi2_dq_3_o;
  assign io_pads_qspi2_dq_3_o_oe  = sdio_enable ? sddata2_o_oe :   qspi2_dq_3_oe;
  assign io_pads_qspi2_dq_3_o_ie  = sdio_enable ? ~sddata2_o_oe : ~qspi2_dq_3_oe;
  assign io_pads_qspi2_dq_3_o_pue = sdio_enable ? sddata2_o_pue : 1'b0;
  assign io_pads_qspi2_dq_3_o_ds  = 1'b0;
  assign uart0_rxd = io_pads_uart0_rxd_i_ival;
  assign io_pads_uart0_rxd_o_oval = 1'h0;
  assign io_pads_uart0_rxd_o_oe = 1'h0;
  assign io_pads_uart0_rxd_o_ie = 1'h1;
  assign io_pads_uart0_rxd_o_pue = 1'h0;
  assign io_pads_uart0_rxd_o_ds = 1'h0;
  assign io_pads_uart0_txd_o_oval = uart0_txd;
  assign io_pads_uart0_txd_o_oe = 1'h1;
  assign io_pads_uart0_txd_o_ie = 1'h0;
  assign io_pads_uart0_txd_o_pue = 1'h0;
  assign io_pads_uart0_txd_o_ds = 1'h0;
  wire                     uart0_icb_cmd_valid;
  wire                     uart0_icb_cmd_ready;
  wire [32-1:0]            uart0_icb_cmd_addr; 
  wire                     uart0_icb_cmd_read; 
  wire [32-1:0]            uart0_icb_cmd_wdata;
  wire                     uart0_icb_rsp_valid;
  wire                     uart0_icb_rsp_ready;
  wire [32-1:0]            uart0_icb_rsp_rdata;
  wire                     misc_icb_cmd_valid;
  wire                     misc_icb_cmd_ready;
  wire [32-1:0]            misc_icb_cmd_addr; 
  wire                     misc_icb_cmd_read; 
  wire [32-1:0]            misc_icb_cmd_wdata;
  wire                     misc_icb_rsp_valid;
  wire                     misc_icb_rsp_ready;
  wire [32-1:0]            misc_icb_rsp_rdata;
  wire                     qspi0_icb_cmd_valid;
  wire                     qspi0_icb_cmd_ready;
  wire [32-1:0]            qspi0_icb_cmd_addr; 
  wire                     qspi0_icb_cmd_read; 
  wire [32-1:0]            qspi0_icb_cmd_wdata;
  wire                     qspi0_icb_rsp_valid;
  wire                     qspi0_icb_rsp_ready;
  wire [32-1:0]            qspi0_icb_rsp_rdata;
  wire                     qspi2_icb_cmd_valid;
  wire                     qspi2_icb_cmd_ready;
  wire [32-1:0]            qspi2_icb_cmd_addr; 
  wire                     qspi2_icb_cmd_read; 
  wire [32-1:0]            qspi2_icb_cmd_wdata;
  wire                     qspi2_icb_rsp_valid;
  wire                     qspi2_icb_rsp_ready;
  wire [32-1:0]            qspi2_icb_rsp_rdata;
  wire            udma_reg_icb_cmd_valid             ;
  wire            udma_reg_icb_cmd_ready             ;
  wire            udma_reg_icb_cmd_read              ;
  wire[  32-1:   0] udma_reg_icb_cmd_addr;
  wire[  31:   0] udma_reg_icb_cmd_wdata             ;
  wire[   3:   0] udma_reg_icb_cmd_wmask             ;
  wire[   2:   0] udma_reg_icb_cmd_size              ;
  wire            udma_reg_icb_cmd_lock              ;
  wire            udma_reg_icb_cmd_excl              ;
  wire[   7:   0] udma_reg_icb_cmd_xlen              ;
  wire[   1:   0] udma_reg_icb_cmd_xburst            ;
  wire[   1:   0] udma_reg_icb_cmd_modes             ;
  wire            udma_reg_icb_cmd_dmode             ;
  wire[   2:   0] udma_reg_icb_cmd_attri             ;
  wire[   1:   0] udma_reg_icb_cmd_beat              ;
  wire            udma_reg_icb_rsp_ready             ;
  wire            udma_reg_icb_rsp_valid             ;
  wire            udma_reg_icb_rsp_err               ;
  wire            udma_reg_icb_rsp_excl_ok           ;
  wire[  31:   0] udma_reg_icb_rsp_rdata             ;
  wire            sdio_icb_cmd_valid             ;
  wire            sdio_icb_cmd_ready             ;
  wire            sdio_icb_cmd_read              ;
  wire[  32-1:   0] sdio_icb_cmd_addr;
  wire[  31:   0] sdio_icb_cmd_wdata             ;
  wire[   3:   0] sdio_icb_cmd_wmask             ;
  wire[   2:   0] sdio_icb_cmd_size              ;
  wire            sdio_icb_cmd_lock              ;
  wire            sdio_icb_cmd_excl              ;
  wire[   7:   0] sdio_icb_cmd_xlen              ;
  wire[   1:   0] sdio_icb_cmd_xburst            ;
  wire[   1:   0] sdio_icb_cmd_modes             ;
  wire            sdio_icb_cmd_dmode             ;
  wire[   2:   0] sdio_icb_cmd_attri             ;
  wire[   1:   0] sdio_icb_cmd_beat              ;
  wire            sdio_icb_rsp_ready             ;
  wire            sdio_icb_rsp_valid             ;
  wire            sdio_icb_rsp_err               ;
  wire            sdio_icb_rsp_excl_ok           ;
  wire[  31:   0] sdio_icb_rsp_rdata             ;
  wire default_icb_cmd_valid;
  wire default_icb_cmd_ready;
  wire            default_icb_cmd_read              ;
  wire[  32-1:   0] default_icb_cmd_addr;
  wire[  31:   0] default_icb_cmd_wdata             ;
  wire[   3:   0] default_icb_cmd_wmask             ;
  wire[   2:   0] default_icb_cmd_size              ;
  wire            default_icb_cmd_lock              ;
  wire            default_icb_cmd_excl              ;
  wire[   7:   0] default_icb_cmd_xlen              ;
  wire[   1:   0] default_icb_cmd_xburst            ;
  wire[   1:   0] default_icb_cmd_modes             ;
  wire            default_icb_cmd_dmode             ;
  wire[   2:   0] default_icb_cmd_attri             ;
  wire[   1:   0] default_icb_cmd_beat              ;
  wire            default_icb_rsp_valid             ;
  wire            default_icb_rsp_ready             ;
  wire            default_icb_rsp_err               ;
  wire            default_icb_rsp_excl_ok    = 1'b0 ;
  wire[  31:   0] default_icb_rsp_rdata             ;
  e603_subsys_perips_ficb1ton_bus # (
      .ALLOW_0CYCL_RSP    (1),
  .ICB_FIFO_CMD_DP        (2),
  .ICB_FIFO_RSP_DP        (2),
  .ICB_FIFO_CMD_CUT_READY (0),
  .ICB_FIFO_RSP_CUT_READY (0),
  .SPLT_FIFO_OUTS_NUM   (16),
  .SPLT_FIFO_CUT_READY  (1),
  .O0_BASE_ADDR       ({32'h10000000 + 20'h0}),       
  .O0_BASE_REGION_LSB (12),
  .O1_BASE_ADDR       ({32'h10000000 + 20'h8000}),       
  .O1_BASE_REGION_LSB (12),
  .O2_BASE_ADDR       ({32'h10000000 + 20'h1_0000}),       
  .O2_BASE_REGION_LSB (12),
  .O3_BASE_ADDR       ({32'h10000000 + 20'h1_2000}),       
  .O3_BASE_REGION_LSB (12),
  .O4_BASE_ADDR       ({32'h10000000 + 20'h1_3000}),       
  .O4_BASE_REGION_LSB (12),
  .O5_BASE_ADDR       ({32'h10000000 + 20'h1_4000}),       
  .O5_BASE_REGION_LSB (12),
  .O6_BASE_ADDR       ({32'h10000000 + 20'h1_5000}),       
  .O6_BASE_REGION_LSB (12),
  .O7_BASE_ADDR       ({32'h10000000 + 20'h1_6000}),       
  .O7_BASE_REGION_LSB (12),
  .O8_BASE_ADDR       ({32'h10000000 + 20'h2_4000}),       
  .O8_BASE_REGION_LSB (12),
  .O9_BASE_ADDR       ({32'h10000000 + 20'h2_5000}),       
  .O9_BASE_REGION_LSB (12),
  .O10_BASE_ADDR       ({32'h10000000 + 20'h3_4000}),       
  .O10_BASE_REGION_LSB (12),
  .O11_BASE_ADDR       ({32'h10000000 + 20'h3_5000}),       
  .O11_BASE_REGION_LSB (12),
  .O12_BASE_ADDR       ({32'h10000000 + 20'h3_6000}),       
  .O12_BASE_REGION_LSB (13),
  .O13_BASE_ADDR       ({32'h10000000 + 20'h1_4000}),
  .O13_BASE_REGION_LSB (12),
  .O14_BASE_ADDR       ({32'h10000000 + 20'h4_2000}),
  .O14_BASE_REGION_LSB (3)
  )u_ppi_fab(
      .i_clk_en(1'b1),
      .o_clk_en(1'b1),
      .icb1ton_active(),
    .i_icb_cmd_usr(1'b0),
    .o0_icb_rsp_usr(1'b0),
    .o1_icb_rsp_usr(1'b0),
    .o2_icb_rsp_usr(1'b0),
    .o3_icb_rsp_usr(1'b0),
    .o4_icb_rsp_usr(1'b0),
    .o5_icb_rsp_usr(1'b0),
    .o6_icb_rsp_usr(1'b0),
    .o7_icb_rsp_usr(1'b0),
    .o8_icb_rsp_usr(1'b0),
    .o9_icb_rsp_usr(1'b0),
    .o10_icb_rsp_usr(1'b0),
    .o11_icb_rsp_usr(1'b0),
    .o12_icb_rsp_usr(1'b0),
    .o13_icb_rsp_usr(1'b0),
    .o14_icb_rsp_usr(1'b0),
    .o15_icb_rsp_usr(1'b0),
    .i_icb_rsp_usr (),
    .o0_icb_cmd_sel(),
    .o0_icb_cmd_usr(),
    .o1_icb_cmd_sel(),
    .o1_icb_cmd_usr(),
    .o2_icb_cmd_sel(),
    .o2_icb_cmd_usr(),
    .o3_icb_cmd_sel(),
    .o3_icb_cmd_usr(),
    .o4_icb_cmd_sel(),
    .o4_icb_cmd_usr(),
    .o5_icb_cmd_sel(),
    .o5_icb_cmd_usr(),
    .o6_icb_cmd_sel(),
    .o6_icb_cmd_usr(),
    .o7_icb_cmd_sel(),
    .o7_icb_cmd_usr(),
    .o8_icb_cmd_sel(),
    .o8_icb_cmd_usr(),
    .o9_icb_cmd_sel(),
    .o9_icb_cmd_usr(),
    .o10_icb_cmd_sel(),
    .o10_icb_cmd_usr(),
    .o11_icb_cmd_sel(),
    .o11_icb_cmd_usr(),
    .o12_icb_cmd_sel(),
    .o12_icb_cmd_usr(),
    .o13_icb_cmd_sel(),
    .o13_icb_cmd_usr(),
    .o14_icb_cmd_sel(),
    .o14_icb_cmd_usr(),
    .o15_icb_cmd_sel(),
    .o15_icb_cmd_usr(),
    .i_icb_cmd_sel    (biu2ppi_icb_cmd_valid),
    .i_icb_cmd_valid  (biu2ppi_icb_cmd_valid),
    .i_icb_cmd_ready  (biu2ppi_icb_cmd_ready),
    .i_icb_cmd_addr   (biu2ppi_icb_cmd_addr ),
    .i_icb_cmd_read   (biu2ppi_icb_cmd_read ),
    .i_icb_cmd_wdata  (biu2ppi_icb_cmd_wdata),
    .i_icb_cmd_wmask  (biu2ppi_icb_cmd_wmask),
    .i_icb_cmd_lock   (1'b0),
    .i_icb_cmd_excl   (1'b0 ),
    .i_icb_cmd_size   (3'b0 ),
    .i_icb_cmd_xburst  (2'b0 ),
    .i_icb_cmd_xlen  (8'b0 ),
    .i_icb_cmd_dmode (1'b0 ),
    .i_icb_cmd_modes  (2'b0 ),
    .i_icb_cmd_attri  (3'b0 ),
    .i_icb_cmd_beat   (2'b0 ),
    .i_icb_rsp_valid  (biu2ppi_icb_rsp_valid),
    .i_icb_rsp_ready  (biu2ppi_icb_rsp_ready),
    .i_icb_rsp_err    (biu2ppi_icb_rsp_err  ),
    .i_icb_rsp_excl_ok(),
    .i_icb_rsp_rdata  (biu2ppi_icb_rsp_rdata),
    .o0_icb_enable     (1'b0),
    .o0_icb_cmd_valid  (),
    .o0_icb_cmd_ready  (1'b0),
    .o0_icb_cmd_addr   (),
    .o0_icb_cmd_read   (),
    .o0_icb_cmd_wdata  (),
    .o0_icb_cmd_wmask  (),
    .o0_icb_cmd_lock   (),
    .o0_icb_cmd_excl   (),
    .o0_icb_cmd_size   (),
    .o0_icb_cmd_xburst (),
    .o0_icb_cmd_xlen   (),
    .o0_icb_cmd_dmode  (),
    .o0_icb_cmd_modes  (),
    .o0_icb_cmd_attri  (),
    .o0_icb_cmd_beat   (),
    .o0_icb_rsp_valid  (1'b0),
    .o0_icb_rsp_ready  (),
    .o0_icb_rsp_err    (1'b0  ),
    .o0_icb_rsp_excl_ok(1'b0  ),
    .o0_icb_rsp_rdata  (32'b0),
    .o1_icb_enable     (1'b0),
    .o1_icb_cmd_valid  (),
    .o1_icb_cmd_ready  (1'b0),
    .o1_icb_cmd_addr   (),
    .o1_icb_cmd_read   (),
    .o1_icb_cmd_wdata  (),
    .o1_icb_cmd_wmask  (),
    .o1_icb_cmd_lock   (),
    .o1_icb_cmd_excl   (),
    .o1_icb_cmd_size   (),
    .o1_icb_cmd_xburst (),
    .o1_icb_cmd_xlen   (),
    .o1_icb_cmd_dmode  (),
    .o1_icb_cmd_modes  (),
    .o1_icb_cmd_attri  (),
    .o1_icb_cmd_beat   (),
    .o1_icb_rsp_valid  (1'b0),
    .o1_icb_rsp_ready  (),
    .o1_icb_rsp_err    (1'b0  ),
    .o1_icb_rsp_excl_ok(1'b0  ),
    .o1_icb_rsp_rdata  (32'b0),
    .o2_icb_enable     (1'b0),
    .o2_icb_cmd_valid  (),
    .o2_icb_cmd_ready  (1'b0),
    .o2_icb_cmd_addr   (),
    .o2_icb_cmd_read   (),
    .o2_icb_cmd_wdata  (),
    .o2_icb_cmd_wmask  (),
    .o2_icb_cmd_lock   (),
    .o2_icb_cmd_excl   (),
    .o2_icb_cmd_size   (),
    .o2_icb_cmd_xburst (),
    .o2_icb_cmd_xlen   (),
    .o2_icb_cmd_dmode  (),
    .o2_icb_cmd_modes  (),
    .o2_icb_cmd_attri  (),
    .o2_icb_cmd_beat   (),
    .o2_icb_rsp_valid  (1'b0),
    .o2_icb_rsp_ready  (),
    .o2_icb_rsp_err    (1'b0),
    .o2_icb_rsp_excl_ok(1'b0),
    .o2_icb_rsp_rdata  (32'b0),
    .o3_icb_enable     (1'b1),
    .o3_icb_cmd_valid  (misc_icb_cmd_valid),
    .o3_icb_cmd_ready  (misc_icb_cmd_ready),
    .o3_icb_cmd_addr   (misc_icb_cmd_addr ),
    .o3_icb_cmd_read   (misc_icb_cmd_read ),
    .o3_icb_cmd_wdata  (misc_icb_cmd_wdata),
    .o3_icb_cmd_wmask  (),
    .o3_icb_cmd_lock   (),
    .o3_icb_cmd_excl   (),
    .o3_icb_cmd_size   (),
    .o3_icb_cmd_xburst (),
    .o3_icb_cmd_xlen   (),
    .o3_icb_cmd_dmode  (),
    .o3_icb_cmd_modes  (),
    .o3_icb_cmd_attri  (),
    .o3_icb_cmd_beat   (),
    .o3_icb_rsp_valid  (misc_icb_rsp_valid),
    .o3_icb_rsp_ready  (misc_icb_rsp_ready),
    .o3_icb_rsp_err    (1'b0  ),
    .o3_icb_rsp_excl_ok(1'b0  ),
    .o3_icb_rsp_rdata  (misc_icb_rsp_rdata),
    .o4_icb_enable     (1'b1),
    .o4_icb_cmd_valid  (uart0_icb_cmd_valid),
    .o4_icb_cmd_ready  (uart0_icb_cmd_ready),
    .o4_icb_cmd_addr   (uart0_icb_cmd_addr ),
    .o4_icb_cmd_read   (uart0_icb_cmd_read ),
    .o4_icb_cmd_wdata  (uart0_icb_cmd_wdata),
    .o4_icb_cmd_wmask  (),
    .o4_icb_cmd_lock   (),
    .o4_icb_cmd_excl   (),
    .o4_icb_cmd_size   (),
    .o4_icb_cmd_xburst (),
    .o4_icb_cmd_xlen   (),
    .o4_icb_cmd_dmode  (),
    .o4_icb_cmd_modes  (),
    .o4_icb_cmd_attri  (),
    .o4_icb_cmd_beat   (),
    .o4_icb_rsp_valid  (uart0_icb_rsp_valid),
    .o4_icb_rsp_ready  (uart0_icb_rsp_ready),
    .o4_icb_rsp_err    (1'b0  ),
    .o4_icb_rsp_excl_ok(1'b0  ),
    .o4_icb_rsp_rdata  (uart0_icb_rsp_rdata),
    .o5_icb_enable     (1'b1),
    .o5_icb_cmd_valid  (qspi0_icb_cmd_valid),
    .o5_icb_cmd_ready  (qspi0_icb_cmd_ready),
    .o5_icb_cmd_addr   (qspi0_icb_cmd_addr ),
    .o5_icb_cmd_read   (qspi0_icb_cmd_read ),
    .o5_icb_cmd_wdata  (qspi0_icb_cmd_wdata),
    .o5_icb_cmd_wmask  (),
    .o5_icb_cmd_lock   (),
    .o5_icb_cmd_excl   (),
    .o5_icb_cmd_size   (),
    .o5_icb_cmd_xburst (),
    .o5_icb_cmd_xlen   (),
    .o5_icb_cmd_dmode  (),
    .o5_icb_cmd_modes  (),
    .o5_icb_cmd_attri  (),
    .o5_icb_cmd_beat   (),
    .o5_icb_rsp_valid  (qspi0_icb_rsp_valid),
    .o5_icb_rsp_ready  (qspi0_icb_rsp_ready),
    .o5_icb_rsp_err    (1'b0  ),
    .o5_icb_rsp_excl_ok(1'b0  ),
    .o5_icb_rsp_rdata  (qspi0_icb_rsp_rdata),
    .o6_icb_enable     (1'b1),
    .o6_icb_cmd_valid  (udma_reg_icb_cmd_valid),
    .o6_icb_cmd_ready  (udma_reg_icb_cmd_ready),
    .o6_icb_cmd_addr   (udma_reg_icb_cmd_addr),
    .o6_icb_cmd_read   (udma_reg_icb_cmd_read),
    .o6_icb_cmd_wdata  (udma_reg_icb_cmd_wdata),
    .o6_icb_cmd_wmask  (udma_reg_icb_cmd_wmask),
    .o6_icb_cmd_lock   (udma_reg_icb_cmd_lock),
    .o6_icb_cmd_excl   (udma_reg_icb_cmd_excl),
    .o6_icb_cmd_size   (udma_reg_icb_cmd_size),
    .o6_icb_cmd_xburst (udma_reg_icb_cmd_xburst),
    .o6_icb_cmd_xlen   (udma_reg_icb_cmd_xlen),
    .o6_icb_cmd_dmode  (udma_reg_icb_cmd_dmode),
    .o6_icb_cmd_modes  (udma_reg_icb_cmd_modes),
    .o6_icb_cmd_attri  (udma_reg_icb_cmd_attri),
    .o6_icb_cmd_beat   (udma_reg_icb_cmd_beat),
    .o6_icb_rsp_valid  (udma_reg_icb_rsp_valid),
    .o6_icb_rsp_ready  (udma_reg_icb_rsp_ready),
    .o6_icb_rsp_err    (udma_reg_icb_rsp_err  ),
    .o6_icb_rsp_excl_ok(udma_reg_icb_rsp_excl_ok),
    .o6_icb_rsp_rdata  (udma_reg_icb_rsp_rdata),
    .o7_icb_enable     (1'b1),
    .o7_icb_cmd_valid  (sdio_icb_cmd_valid),
    .o7_icb_cmd_ready  (sdio_icb_cmd_ready),
    .o7_icb_cmd_addr   (sdio_icb_cmd_addr),
    .o7_icb_cmd_read   (sdio_icb_cmd_read),
    .o7_icb_cmd_wdata  (sdio_icb_cmd_wdata),
    .o7_icb_cmd_wmask  (sdio_icb_cmd_wmask),
    .o7_icb_cmd_lock   (sdio_icb_cmd_lock),
    .o7_icb_cmd_excl   (sdio_icb_cmd_excl),
    .o7_icb_cmd_size   (sdio_icb_cmd_size),
    .o7_icb_cmd_xburst (sdio_icb_cmd_xburst),
    .o7_icb_cmd_xlen   (sdio_icb_cmd_xlen),
    .o7_icb_cmd_dmode  (sdio_icb_cmd_dmode),
    .o7_icb_cmd_modes  (sdio_icb_cmd_modes),
    .o7_icb_cmd_attri  (sdio_icb_cmd_attri),
    .o7_icb_cmd_beat   (sdio_icb_cmd_beat),
    .o7_icb_rsp_valid  (sdio_icb_rsp_valid),
    .o7_icb_rsp_ready  (sdio_icb_rsp_ready),
    .o7_icb_rsp_err    (sdio_icb_rsp_err),
    .o7_icb_rsp_excl_ok(sdio_icb_rsp_excl_ok),
    .o7_icb_rsp_rdata  (sdio_icb_rsp_rdata),
    .o8_icb_enable     (1'b0),
    .o8_icb_cmd_valid  (),
    .o8_icb_cmd_ready  (1'b0),
    .o8_icb_cmd_addr   (),
    .o8_icb_cmd_read   (),
    .o8_icb_cmd_wdata  (),
    .o8_icb_cmd_wmask  (),
    .o8_icb_cmd_lock   (),
    .o8_icb_cmd_excl   (),
    .o8_icb_cmd_size   (),
    .o8_icb_cmd_xburst (),
    .o8_icb_cmd_xlen   (),
    .o8_icb_cmd_dmode  (),
    .o8_icb_cmd_modes  (),
    .o8_icb_cmd_attri  (),
    .o8_icb_cmd_beat   (),
    .o8_icb_rsp_valid  (1'b0),
    .o8_icb_rsp_ready  (),
    .o8_icb_rsp_err    (1'b0  ),
    .o8_icb_rsp_excl_ok(1'b0  ),
    .o8_icb_rsp_rdata  (32'b0),
    .o9_icb_enable     (1'b0),
    .o9_icb_cmd_valid  (),
    .o9_icb_cmd_ready  (1'b1),
    .o9_icb_cmd_addr   (),
    .o9_icb_cmd_read   (),
    .o9_icb_cmd_wdata  (),
    .o9_icb_cmd_wmask  (),
    .o9_icb_cmd_lock   (),
    .o9_icb_cmd_excl   (),
    .o9_icb_cmd_size   (),
    .o9_icb_cmd_xburst (),
    .o9_icb_cmd_xlen   (),
    .o9_icb_cmd_dmode  (),
    .o9_icb_cmd_modes  (),
    .o9_icb_cmd_attri  (),
    .o9_icb_cmd_beat   (),
    .o9_icb_rsp_valid  (1'b0),
    .o9_icb_rsp_ready  (),
    .o9_icb_rsp_err    (1'b0  ),
    .o9_icb_rsp_excl_ok(1'b0  ),
    .o9_icb_rsp_rdata  (32'b0),
    .o10_icb_enable     (1'b1),
    .o10_icb_cmd_valid  (qspi2_icb_cmd_valid),
    .o10_icb_cmd_ready  (qspi2_icb_cmd_ready),
    .o10_icb_cmd_addr   (qspi2_icb_cmd_addr ),
    .o10_icb_cmd_read   (qspi2_icb_cmd_read ),
    .o10_icb_cmd_wdata  (qspi2_icb_cmd_wdata),
    .o10_icb_cmd_wmask  (),
    .o10_icb_cmd_lock   (),
    .o10_icb_cmd_excl   (),
    .o10_icb_cmd_size   (),
    .o10_icb_cmd_xburst (),
    .o10_icb_cmd_xlen   (),
    .o10_icb_cmd_dmode  (),
    .o10_icb_cmd_modes  (),
    .o10_icb_cmd_attri  (),
    .o10_icb_cmd_beat   (),
    .o10_icb_rsp_valid  (qspi2_icb_rsp_valid),
    .o10_icb_rsp_ready  (qspi2_icb_rsp_ready),
    .o10_icb_rsp_err    (1'b0  ),
    .o10_icb_rsp_excl_ok(1'b0  ),
    .o10_icb_rsp_rdata  (qspi2_icb_rsp_rdata),
    .o11_icb_enable     (1'b0),
    .o11_icb_cmd_valid  (),
    .o11_icb_cmd_ready  (1'b0),
    .o11_icb_cmd_addr   (),
    .o11_icb_cmd_read   (),
    .o11_icb_cmd_wdata  (),
    .o11_icb_cmd_wmask  (),
    .o11_icb_cmd_lock   (),
    .o11_icb_cmd_excl   (),
    .o11_icb_cmd_size   (),
    .o11_icb_cmd_xburst (),
    .o11_icb_cmd_xlen   (),
    .o11_icb_cmd_dmode  (),
    .o11_icb_cmd_modes  (),
    .o11_icb_cmd_attri  (),
    .o11_icb_cmd_beat   (),
    .o11_icb_rsp_valid  (1'b0),
    .o11_icb_rsp_ready  (),
    .o11_icb_rsp_err    (1'b0  ),
    .o11_icb_rsp_excl_ok(1'b0  ),
    .o11_icb_rsp_rdata  (32'b0),
    .o12_icb_enable     (1'b0),
    .o12_icb_cmd_valid  (),
    .o12_icb_cmd_ready  (1'b0),
    .o12_icb_cmd_addr   ( ),
    .o12_icb_cmd_read   ( ),
    .o12_icb_cmd_wdata  (),
    .o12_icb_cmd_wmask  (),
    .o12_icb_cmd_lock   (),
    .o12_icb_cmd_excl   (),
    .o12_icb_cmd_size   (),
    .o12_icb_cmd_xburst (),
    .o12_icb_cmd_xlen   (),
    .o12_icb_cmd_dmode  (),
    .o12_icb_cmd_modes  (),
    .o12_icb_cmd_attri  (),
    .o12_icb_cmd_beat   (),
    .o12_icb_rsp_valid  (1'b0),
    .o12_icb_rsp_ready  (),
    .o12_icb_rsp_err    (1'b0  ),
    .o12_icb_rsp_excl_ok(1'b0  ),
    .o12_icb_rsp_rdata  (32'b0),
    .o13_icb_enable     (1'b0),
    .o13_icb_cmd_valid  (),
    .o13_icb_cmd_ready  (1'b0),
    .o13_icb_cmd_addr   (),
    .o13_icb_cmd_read   (),
    .o13_icb_cmd_wdata  (),
    .o13_icb_cmd_wmask  (),
    .o13_icb_cmd_lock   (),
    .o13_icb_cmd_excl   (),
    .o13_icb_cmd_size   (),
    .o13_icb_cmd_xburst (),
    .o13_icb_cmd_xlen   (),
    .o13_icb_cmd_dmode  (),
    .o13_icb_cmd_modes  (),
    .o13_icb_cmd_attri  (),
    .o13_icb_cmd_beat   (),
    .o13_icb_rsp_valid  (1'b0),
    .o13_icb_rsp_ready  (),
    .o13_icb_rsp_err    (1'b0),
    .o13_icb_rsp_excl_ok(1'b0  ),
    .o13_icb_rsp_rdata  (32'b0),
    .o14_icb_enable     (1'b0),
    .o14_icb_cmd_valid  (),
    .o14_icb_cmd_ready  (1'b1),
    .o14_icb_cmd_addr   ( ),
    .o14_icb_cmd_read   ( ),
    .o14_icb_cmd_wdata  (),
    .o14_icb_cmd_wmask  (),
    .o14_icb_cmd_lock   (),
    .o14_icb_cmd_excl   (),
    .o14_icb_cmd_size   (),
    .o14_icb_cmd_xburst (),
    .o14_icb_cmd_xlen   (),
    .o14_icb_cmd_dmode  (),
    .o14_icb_cmd_modes  (),
    .o14_icb_cmd_attri  (),
    .o14_icb_cmd_beat   (),
    .o14_icb_rsp_valid  (1'b0),
    .o14_icb_rsp_ready  (),
    .o14_icb_rsp_err    (1'b0),
    .o14_icb_rsp_excl_ok(1'b0  ),
    .o14_icb_rsp_rdata  (32'b0),
    .o15_icb_cmd_valid  (default_icb_cmd_valid),
    .o15_icb_cmd_ready  (default_icb_cmd_ready),
    .o15_icb_cmd_addr   (default_icb_cmd_addr),
    .o15_icb_cmd_read   (default_icb_cmd_read),
    .o15_icb_cmd_wdata  (default_icb_cmd_wdata),
    .o15_icb_cmd_wmask  (default_icb_cmd_wmask),
    .o15_icb_cmd_lock   (default_icb_cmd_lock),
    .o15_icb_cmd_excl   (default_icb_cmd_excl),
    .o15_icb_cmd_size   (default_icb_cmd_size),
    .o15_icb_cmd_xburst (default_icb_cmd_xburst),
    .o15_icb_cmd_xlen   (default_icb_cmd_xlen),
    .o15_icb_cmd_dmode  (default_icb_cmd_dmode),
    .o15_icb_cmd_modes  (default_icb_cmd_modes),
    .o15_icb_cmd_attri  (default_icb_cmd_attri),
    .o15_icb_cmd_beat   (default_icb_cmd_beat),
    .o15_icb_rsp_valid  (default_icb_rsp_valid),
    .o15_icb_rsp_ready  (default_icb_rsp_ready),
    .o15_icb_rsp_err    (default_icb_rsp_err),
    .o15_icb_rsp_excl_ok(default_icb_rsp_excl_ok),
    .o15_icb_rsp_rdata  (default_icb_rsp_rdata),
    .clk           (clk  ),
    .rst_n         (bus_rst_n) 
  );
e603_uart_top u_uart0_top (
    .clk           (clk  ),
    .rst_n         (rst_n),
    .i_icb_cmd_valid (uart0_icb_cmd_valid),
    .i_icb_cmd_ready (uart0_icb_cmd_ready),
    .i_icb_cmd_addr  (uart0_icb_cmd_addr[31:0] ),
    .i_icb_cmd_read  (uart0_icb_cmd_read ),
    .i_icb_cmd_wdata (uart0_icb_cmd_wdata),
    .i_icb_rsp_valid (uart0_icb_rsp_valid),
    .i_icb_rsp_ready (uart0_icb_rsp_ready),
    .i_icb_rsp_rdata (uart0_icb_rsp_rdata),
    .io_interrupts_0_0 (uart0_irq),                
    .io_port_txd       (uart0_txd),
    .io_port_rxd       (uart0_rxd)
);
  nuclei_default_icb_slave u_default_icb_slave (
    .clk           (clk  ),
    .rst_n         (rst_n),
    .icb_cmd_valid (default_icb_cmd_valid),
    .icb_cmd_ready (default_icb_cmd_ready),
    .icb_cmd_addr  (default_icb_cmd_addr[31:0] ),
    .icb_cmd_read  (default_icb_cmd_read ),
    .icb_cmd_wdata (default_icb_cmd_wdata),
    .icb_cmd_wmask (default_icb_cmd_wmask),
    .icb_rsp_valid (default_icb_rsp_valid),
    .icb_rsp_ready (default_icb_rsp_ready),
    .icb_rsp_err   (default_icb_rsp_err),
    .icb_rsp_rdata (default_icb_rsp_rdata)
  );
e603_subsys_misc u_subsys_misc(
    .icb_cmd_valid (misc_icb_cmd_valid),
    .icb_cmd_ready (misc_icb_cmd_ready),
    .icb_cmd_addr  (misc_icb_cmd_addr[12-1:0] ),
    .icb_cmd_read  (misc_icb_cmd_read ),
    .icb_cmd_wdata (misc_icb_cmd_wdata),
    .icb_rsp_valid (misc_icb_rsp_valid),
    .icb_rsp_ready (misc_icb_rsp_ready),
    .icb_rsp_rdata (misc_icb_rsp_rdata),
  .misc_irq0(misc_irq0),
  .misc_irq1(misc_irq1),
     .misc_nmi(misc_nmi),
     .misc_evt(misc_evt),
     .iocp_arcache (iocp_arcache),
     .iocp_awcache (iocp_awcache),
     .iocp_ar_hi_addr (iocp_ar_hi_addr),
     .iocp_aw_hi_addr (iocp_aw_hi_addr),
     .mem_delay_select (mem_delay_select),
     .misc_dbg_secure_enable     (misc_dbg_secure_enable      ),
     .misc_dbg_isolate           (misc_dbg_isolate            ),
     .misc_dbg_override_dm_sleep (misc_dbg_override_dm_sleep  ),
     .misc_dbg_stop_at_boot      (misc_dbg_stop_at_boot       ),
     .misc_dbg_i_dbg_stop        (misc_dbg_i_dbg_stop         ),
     .misc_sdio_enable   (sdio_enable),
    .clk           (clk  ),
    .rst_n         (rst_n) 
);
    assign udma_w_icb_cmd_addr[63:32] = 32'b0;
    assign udma_r_icb_cmd_addr[63:32] = 32'b0;
nuclei_udma_top u_udma (
  .w_icb_cmd_valid                (udma_w_icb_cmd_valid                    ),
  .w_icb_cmd_ready                (udma_w_icb_cmd_ready                    ),
  .w_icb_cmd_sel                  (udma_w_icb_cmd_sel                      ),
  .w_icb_cmd_read                 (udma_w_icb_cmd_read                     ),
  .w_icb_cmd_addr                 (udma_w_icb_cmd_addr          [  31:   0]),
  .w_icb_cmd_wdata                (udma_w_icb_cmd_wdata         [  63:   0]),
  .w_icb_cmd_wmask                (udma_w_icb_cmd_wmask         [   7:   0]),
  .w_icb_cmd_size                 (udma_w_icb_cmd_size          [   2:   0]),
  .w_icb_cmd_lock                 (udma_w_icb_cmd_lock                     ),
  .w_icb_cmd_excl                 (udma_w_icb_cmd_excl                     ),
  .w_icb_cmd_xlen                 (udma_w_icb_cmd_xlen          [   7:   0]),
  .w_icb_cmd_xburst               (udma_w_icb_cmd_xburst        [   1:   0]),
  .w_icb_cmd_modes                (udma_w_icb_cmd_modes         [   1:   0]),
  .w_icb_cmd_dmode                (udma_w_icb_cmd_dmode                    ),
  .w_icb_cmd_attri                (udma_w_icb_cmd_attri         [   2:   0]),
  .w_icb_cmd_beat                 (udma_w_icb_cmd_beat          [   1:   0]),
  .w_icb_cmd_usr                  (                      ),
  .w_icb_rsp_ready                (udma_w_icb_rsp_ready                    ),
  .w_icb_rsp_valid                (udma_w_icb_rsp_valid                    ),
  .w_icb_rsp_err                  (udma_w_icb_rsp_err                      ),
  .w_icb_rsp_excl_ok              (udma_w_icb_rsp_excl_ok                  ),
  .w_icb_rsp_rdata                (udma_w_icb_rsp_rdata         [  63:   0]),
  .w_icb_rsp_usr                  (1'b0),
  .r_icb_cmd_valid                (udma_r_icb_cmd_valid                    ),
  .r_icb_cmd_ready                (udma_r_icb_cmd_ready                    ),
  .r_icb_cmd_sel                  (udma_r_icb_cmd_sel                      ),
  .r_icb_cmd_read                 (udma_r_icb_cmd_read                     ),
  .r_icb_cmd_addr                 (udma_r_icb_cmd_addr          [  31:   0]),
  .r_icb_cmd_wdata                (udma_r_icb_cmd_wdata         [  63:   0]),
  .r_icb_cmd_wmask                (udma_r_icb_cmd_wmask         [   7:   0]),
  .r_icb_cmd_size                 (udma_r_icb_cmd_size          [   2:   0]),
  .r_icb_cmd_lock                 (udma_r_icb_cmd_lock                     ),
  .r_icb_cmd_excl                 (udma_r_icb_cmd_excl                     ),
  .r_icb_cmd_xlen                 (udma_r_icb_cmd_xlen          [   7:   0]),
  .r_icb_cmd_xburst               (udma_r_icb_cmd_xburst        [   1:   0]),
  .r_icb_cmd_modes                (udma_r_icb_cmd_modes         [   1:   0]),
  .r_icb_cmd_dmode                (udma_r_icb_cmd_dmode                    ),
  .r_icb_cmd_attri                (udma_r_icb_cmd_attri         [   2:   0]),
  .r_icb_cmd_beat                 (udma_r_icb_cmd_beat          [   1:   0]),
  .r_icb_cmd_usr                  (                      ),
  .r_icb_rsp_ready                (udma_r_icb_rsp_ready                    ),
  .r_icb_rsp_valid                (udma_r_icb_rsp_valid                    ),
  .r_icb_rsp_err                  (udma_r_icb_rsp_err                      ),
  .r_icb_rsp_excl_ok              (udma_r_icb_rsp_excl_ok                  ),
  .r_icb_rsp_rdata                (udma_r_icb_rsp_rdata         [  63:   0]),
  .r_icb_rsp_usr                  (1'b0),
  .udma_irq                       (udma_irq                           ),
  .udma_dbg0_o_oval               (                   ),
  .udma_dbg1_o_oval               (                   ),
  .clk                            (clk                 ),
  .rst_n                          (rst_n            ),
  .reg_icb_cmd_valid              (udma_reg_icb_cmd_valid                  ),
  .reg_icb_cmd_ready              (udma_reg_icb_cmd_ready                  ),
  .reg_icb_cmd_sel                (udma_reg_icb_cmd_valid                  ),
  .reg_icb_cmd_read               (udma_reg_icb_cmd_read                   ),
  .reg_icb_cmd_addr               (udma_reg_icb_cmd_addr        [  11:   0]),
  .reg_icb_cmd_wdata              (udma_reg_icb_cmd_wdata       [  31:   0]),
  .reg_icb_cmd_wmask              (udma_reg_icb_cmd_wmask       [   3:   0]),
  .reg_icb_cmd_size               (udma_reg_icb_cmd_size        [   2:   0]),
  .reg_icb_cmd_lock               (udma_reg_icb_cmd_lock                   ),
  .reg_icb_cmd_excl               (udma_reg_icb_cmd_excl                   ),
  .reg_icb_cmd_xlen               (udma_reg_icb_cmd_xlen        [   7:   0]),
  .reg_icb_cmd_xburst             (udma_reg_icb_cmd_xburst      [   1:   0]),
  .reg_icb_cmd_modes              (udma_reg_icb_cmd_modes       [   1:   0]),
  .reg_icb_cmd_dmode              (udma_reg_icb_cmd_dmode                  ),
  .reg_icb_cmd_attri              (udma_reg_icb_cmd_attri       [   2:   0]),
  .reg_icb_cmd_beat               (udma_reg_icb_cmd_beat        [   1:   0]),
  .reg_icb_cmd_usr                (1'b0                    ),
  .reg_icb_rsp_ready              (udma_reg_icb_rsp_ready                  ),
  .reg_icb_rsp_valid              (udma_reg_icb_rsp_valid                  ),
  .reg_icb_rsp_err                (udma_reg_icb_rsp_err                    ),
  .reg_icb_rsp_excl_ok            (udma_reg_icb_rsp_excl_ok                ),
  .reg_icb_rsp_rdata              (udma_reg_icb_rsp_rdata       [  31:   0]),
  .reg_icb_rsp_usr                (                    )
    );
e603_flash_qspi_top u_qspi0_top(
    .clk           (clk  ),
    .rst_n         (rst_n),
    .i_icb_cmd_valid (qspi0_icb_cmd_valid),
    .i_icb_cmd_ready (qspi0_icb_cmd_ready),
    .i_icb_cmd_addr  (qspi0_icb_cmd_addr[31:0] ),
    .i_icb_cmd_read  (qspi0_icb_cmd_read ),
    .i_icb_cmd_wdata (qspi0_icb_cmd_wdata),
    .i_icb_rsp_valid (qspi0_icb_rsp_valid),
    .i_icb_rsp_ready (qspi0_icb_rsp_ready),
    .i_icb_rsp_rdata (qspi0_icb_rsp_rdata), 
    .f_icb_cmd_valid (qspi0_ro_icb_cmd_valid),
    .f_icb_cmd_ready (qspi0_ro_icb_cmd_ready),
    .f_icb_cmd_addr  (qspi0_ro_icb_cmd_addr[31:0] ),
    .f_icb_cmd_read  (qspi0_ro_icb_cmd_read ),
    .f_icb_cmd_wdata (qspi0_ro_icb_cmd_wdata),
    .f_icb_rsp_valid (qspi0_ro_icb_rsp_valid),
    .f_icb_rsp_ready (qspi0_ro_icb_rsp_ready),
    .f_icb_rsp_rdata (qspi0_ro_icb_rsp_rdata), 
    .io_port_sck     (qspi0_sck    ), 
    .io_port_dq_0_i  (qspi0_dq_0_i ),
    .io_port_dq_0_o  (qspi0_dq_0_o ),
    .io_port_dq_0_oe (qspi0_dq_0_oe),
    .io_port_dq_1_i  (qspi0_dq_1_i ),
    .io_port_dq_1_o  (qspi0_dq_1_o ),
    .io_port_dq_1_oe (qspi0_dq_1_oe),
    .io_port_dq_2_i  (qspi0_dq_2_i ),
    .io_port_dq_2_o  (qspi0_dq_2_o ),
    .io_port_dq_2_oe (qspi0_dq_2_oe),
    .io_port_dq_3_i  (qspi0_dq_3_i ),
    .io_port_dq_3_o  (qspi0_dq_3_o ),
    .io_port_dq_3_oe (qspi0_dq_3_oe),
    .io_port_cs_0    (qspi0_cs_0   ),
    .io_tl_i_0_0     (qspi0_irq    ) 
);
nuclei_sdio_top u_sdio_top(
    .sdio_icb_cmd_valid  (sdio_icb_cmd_valid),
    .sdio_icb_cmd_ready  (sdio_icb_cmd_ready),
    .sdio_icb_cmd_sel    (sdio_icb_cmd_valid),
    .sdio_icb_cmd_read   (sdio_icb_cmd_read),
    .sdio_icb_cmd_addr   (sdio_icb_cmd_addr[11:0]),
    .sdio_icb_cmd_wdata  (sdio_icb_cmd_wdata),
    .sdio_icb_cmd_wmask  (sdio_icb_cmd_wmask),
    .sdio_icb_cmd_size   (sdio_icb_cmd_size),
    .sdio_icb_cmd_lock   (sdio_icb_cmd_lock),
    .sdio_icb_cmd_excl   (sdio_icb_cmd_excl),
    .sdio_icb_cmd_xlen   (sdio_icb_cmd_xlen),
    .sdio_icb_cmd_xburst (sdio_icb_cmd_xburst),
    .sdio_icb_cmd_modes  (sdio_icb_cmd_modes),
    .sdio_icb_cmd_dmode  (sdio_icb_cmd_dmode),
    .sdio_icb_cmd_attri  (sdio_icb_cmd_attri),
    .sdio_icb_cmd_beat   (sdio_icb_cmd_beat),
    .sdio_icb_rsp_ready  (sdio_icb_rsp_ready),
    .sdio_icb_rsp_valid  (sdio_icb_rsp_valid),
    .sdio_icb_rsp_excl_ok(sdio_icb_rsp_excl_ok),
    .sdio_icb_rsp_err    (sdio_icb_rsp_err),
    .sdio_icb_rsp_rdata  (sdio_icb_rsp_rdata),
    .sdclk_i_ival     (sdclk_i_ival),
    .sdclk_o_oval     (sdclk_o_oval),
    .sdclk_o_oe       (sdclk_o_oe),
    .sdclk_o_pue      (sdclk_o_pue),
    .sdcmd_i_ival     (sdcmd_i_ival),
    .sdcmd_o_oval     (sdcmd_o_oval),
    .sdcmd_o_oe       (sdcmd_o_oe),
    .sdcmd_o_pue      (sdcmd_o_pue),
    .sddata0_i_ival (sddata0_i_ival),
    .sddata0_o_oval (sddata0_o_oval),
    .sddata0_o_oe   (sddata0_o_oe),
    .sddata0_o_pue  (sddata0_o_pue),
    .sddata1_i_ival (sddata1_i_ival),
    .sddata1_o_oval (sddata1_o_oval),
    .sddata1_o_oe   (sddata1_o_oe),
    .sddata1_o_pue  (sddata1_o_pue),
    .sddata2_i_ival (sddata2_i_ival),
    .sddata2_o_oval (sddata2_o_oval),
    .sddata2_o_oe   (sddata2_o_oe),
    .sddata2_o_pue  (sddata2_o_pue),
    .sddata3_i_ival (sddata3_i_ival),
    .sddata3_o_oval (sddata3_o_oval),
    .sddata3_o_oe   (sddata3_o_oe),
    .sddata3_o_pue  (sddata3_o_pue),
    .sddata4_i_ival (sddata4_i_ival),
    .sddata4_o_oval (sddata4_o_oval),
    .sddata4_o_oe   (sddata4_o_oe),
    .sddata4_o_pue  (sddata4_o_pue),
    .sddata5_i_ival (sddata5_i_ival),
    .sddata5_o_oval (sddata5_o_oval),
    .sddata5_o_oe   (sddata5_o_oe),
    .sddata5_o_pue  (sddata5_o_pue),
    .sddata6_i_ival (sddata6_i_ival),
    .sddata6_o_oval (sddata6_o_oval),
    .sddata6_o_oe   (sddata6_o_oe),
    .sddata6_o_pue  (sddata6_o_pue),
    .sddata7_i_ival (sddata7_i_ival),
    .sddata7_o_oval (sddata7_o_oval),
    .sddata7_o_oe   (sddata7_o_oe),
    .sddata7_o_pue  (sddata7_o_pue),
    .clk (clk),
    .rst_n (rst_n),
    .sdio_clk(clk),
    .reset_bypass(1'b0),
    .sdio_irq (sdio_irq)
);
    assign qspi1_irq = 1'b0;
e603_qspi_1cs_top u_qspi2_top(
    .clk           (clk  ),
    .rst_n         (rst_n),
    .i_icb_cmd_valid (qspi2_icb_cmd_valid),
    .i_icb_cmd_ready (qspi2_icb_cmd_ready),
    .i_icb_cmd_addr  (qspi2_icb_cmd_addr [31:0]),
    .i_icb_cmd_read  (qspi2_icb_cmd_read ),
    .i_icb_cmd_wdata (qspi2_icb_cmd_wdata),
    .i_icb_rsp_valid (qspi2_icb_rsp_valid),
    .i_icb_rsp_ready (qspi2_icb_rsp_ready),
    .i_icb_rsp_rdata (qspi2_icb_rsp_rdata), 
    .io_port_sck     (qspi2_sck    ), 
    .io_port_dq_0_i  (qspi2_dq_0_i ), 
    .io_port_dq_0_o  (qspi2_dq_0_o ),
    .io_port_dq_0_oe (qspi2_dq_0_oe),
    .io_port_dq_1_i  (qspi2_dq_1_i ), 
    .io_port_dq_1_o  (qspi2_dq_1_o ),
    .io_port_dq_1_oe (qspi2_dq_1_oe),
    .io_port_dq_2_i  (qspi2_dq_2_i ),
    .io_port_dq_2_o  (qspi2_dq_2_o ),
    .io_port_dq_2_oe (qspi2_dq_2_oe),
    .io_port_dq_3_i  (qspi2_dq_3_i ),
    .io_port_dq_3_o  (qspi2_dq_3_o ),
    .io_port_dq_3_oe (qspi2_dq_3_oe),
    .io_port_cs_0    (qspi2_cs_0   ),
    .io_tl_i_0_0     (qspi2_irq    ) 
);
`ifdef FPGA_SOURCE
`ifdef BOARD_KU060
`define HAS_XEC_GEN2                             
`endif
`ifdef BOARD_VCU118
`define HAS_XEC_GEN2                             
`endif
`endif
`ifdef HAS_XEC_GEN2
xec_gen2_top_with_sram u_xec_gen2_top_with_sram (
  .cfg_apb_paddr                 (eth_cfg_apb_paddr                 ),
  .cfg_apb_pwrite                (eth_cfg_apb_pwrite                ),
  .cfg_apb_psel                  (eth_cfg_apb_psel                  ),
  .cfg_apb_pprot                 (eth_cfg_apb_pprot                 ),
  .cfg_apb_pstrobe               (eth_cfg_apb_pstrobe               ),
  .cfg_apb_penable               (eth_cfg_apb_penable               ),
  .cfg_apb_pwdata                (eth_cfg_apb_pwdata                ),
  .cfg_apb_prdata                (eth_cfg_apb_prdata                ),
  .cfg_apb_pready                (eth_cfg_apb_pready                ),
  .cfg_apb_pslverr               (eth_cfg_apb_pslverr               ),
  .strm_r_axi_arvalid            (eth_axi_arvalid            ),
  .strm_r_axi_arready            (eth_axi_arready            ),
  .strm_r_axi_araddr             (eth_axi_araddr             ),
  .strm_r_axi_arlen              (eth_axi_arlen              ),
  .strm_r_axi_arsize             (eth_axi_arsize             ),
  .strm_r_axi_arburst            (eth_axi_arburst            ),
  .strm_r_axi_arlock             (eth_axi_arlock             ),
  .strm_r_axi_arcache            (eth_axi_arcache            ),
  .strm_r_axi_arprot             (eth_axi_arprot             ),
  .strm_r_axi_rready             (eth_axi_rready             ),
  .strm_r_axi_rvalid             (eth_axi_rvalid             ),
  .strm_r_axi_rdata              (eth_axi_rdata              ),
  .strm_r_axi_rresp              (eth_axi_rresp              ),
  .strm_r_axi_rlast              (eth_axi_rlast              ),
  .strm_w_axi_awvalid            (eth_axi_awvalid            ),
  .strm_w_axi_awready            (eth_axi_awready            ),
  .strm_w_axi_awaddr             (eth_axi_awaddr             ),
  .strm_w_axi_awlen              (eth_axi_awlen              ),
  .strm_w_axi_awsize             (eth_axi_awsize             ),
  .strm_w_axi_awburst            (eth_axi_awburst            ),
  .strm_w_axi_awlock             (eth_axi_awlock             ),
  .strm_w_axi_awcache            (eth_axi_awcache            ),
  .strm_w_axi_awprot             (eth_axi_awprot             ),
  .strm_w_axi_bready             (eth_axi_bready             ),
  .strm_w_axi_bvalid             (eth_axi_bvalid             ),
  .strm_w_axi_bresp              (eth_axi_bresp              ),
  .strm_w_axi_wready             (eth_axi_wready             ),
  .strm_w_axi_wvalid             (eth_axi_wvalid             ),
  .strm_w_axi_wdata              (eth_axi_wdata              ),
  .strm_w_axi_wstrb              (eth_axi_wstrb              ),
  .strm_w_axi_wlast              (eth_axi_wlast              ),
  .xmii_txc_i_ival               (xmii_txc_i_ival               ),
  .xmii_txc_o_oval               (xmii_txc_o_oval               ),
  .xmii_txc_o_oe                 (xmii_txc_o_oe                 ),
  .gmii_rxc_i_ival               (gmii_rxc_i_ival               ),
  .gmii_rxd_bit0_i_ival          (gmii_rxd_bit0_i_ival          ),
  .gmii_txd_bit0_o_oval          (gmii_txd_bit0_o_oval          ),
  .gmii_rxd_bit1_i_ival          (gmii_rxd_bit1_i_ival          ),
  .gmii_txd_bit1_o_oval          (gmii_txd_bit1_o_oval          ),
  .gmii_rxd_bit2_i_ival          (gmii_rxd_bit2_i_ival          ),
  .gmii_txd_bit2_o_oval          (gmii_txd_bit2_o_oval          ),
  .gmii_rxd_bit3_i_ival          (gmii_rxd_bit3_i_ival          ),
  .gmii_txd_bit3_o_oval          (gmii_txd_bit3_o_oval          ),
  .gmii_crs_i_ival               (gmii_crs_i_ival               ),
  .gmii_col_i_ival               (gmii_col_i_ival               ),
  .gmii_rxdv_i_ival              (gmii_rxdv_i_ival              ),
  .gmii_rxer_i_ival              (gmii_rxer_i_ival              ),
  .gmii_txen_o_oval              (gmii_txen_o_oval              ),
  .gmii_txer_o_oval              (gmii_txer_o_oval              ),
  .mdio_i_ival                   (mdio_i_ival                   ),
  .mdio_o_oval                   (mdio_o_oval                   ),
  .mdio_o_oe                     (mdio_o_oe                     ),
  .mdc_o_oval                    (mdc_o_oval                    ),
  .pps_out_o_oval                (),
  .sys_clk                       (xec_sys_clk),
  .rst_n                         (rst_n),
  .cfg_apb_clk                   (clk),
  .rmii_clk_ref                  (1'b0),
  .top_intr                      (ethernet_irq),
  .scan_mode                     (1'b0),
  .ptp_ref_clk                   (1'b0),
  .rtc_smp_value                 (),
  .rtc_smp_req                   (1'b0),
  .rtc_smp_ack                   (),
  .clkgate_bypass                (1'b0)
 );
`else
  assign             eth_cfg_apb_prdata                = 32'b0;
  assign             eth_cfg_apb_pready                = 1'b1;
  assign             eth_cfg_apb_pslverr               = 1'b0;
  assign             eth_axi_arvalid            = 1'b0;
  assign             eth_axi_araddr             = 32'b0;
  assign             eth_axi_arlen              = 8'd0;
  assign             eth_axi_arsize             = 3'd0;
  assign             eth_axi_arburst            = 2'd0;
  assign             eth_axi_arlock             = 1'b0;
  assign             eth_axi_arcache            = 4'b0;
  assign             eth_axi_arprot             = 3'b0;
  assign             eth_axi_rready             = 1'b0;
  assign             eth_axi_awvalid            = 1'b0;
  assign             eth_axi_awaddr             = 32'b0;
  assign             eth_axi_awlen              = 8'b0;
  assign             eth_axi_awsize             = 3'b0;
  assign             eth_axi_awburst            = 2'b0;
  assign             eth_axi_awlock             = 1'b0;
  assign             eth_axi_awcache            = 4'b0;
  assign             eth_axi_awprot             = 3'b0;
  assign             eth_axi_bready             = 1'b0;
  assign             eth_axi_wvalid             = 1'b0;
  assign             eth_axi_wdata              = 64'b0;
  assign             eth_axi_wstrb              = 8'b0;
  assign             eth_axi_wlast              = 1'b0;
  assign             xmii_txc_o_oval               = 1'b0;
  assign             xmii_txc_o_oe                 = 1'b0;
  assign             gmii_txd_bit0_o_oval          = 1'b0;
  assign             gmii_txd_bit1_o_oval          = 1'b0;
  assign             gmii_txd_bit2_o_oval          = 1'b0;
  assign             gmii_txd_bit3_o_oval          = 1'b0;
  assign             gmii_txen_o_oval              = 1'b0;
  assign             gmii_txer_o_oval              = 1'b0;
  assign             mdio_o_oval                   = 1'b0;
  assign             mdio_o_oe                     = 1'b0;
  assign             mdc_o_oval                    = 1'b0;
  assign             ethernet_irq                  = 1'b0;
`endif
endmodule
