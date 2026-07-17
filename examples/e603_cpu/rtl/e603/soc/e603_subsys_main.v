 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
module e603_subsys_main
#(
    parameter DDR_BG_WIDTH   = 1
)
(
  `ifdef DDR3_CONTROLLER
  inout  [31:0] ddr3_dq,
  inout  [3:0]  ddr3_dqs_n,
  inout  [3:0]  ddr3_dqs_p,
  output [13:0] ddr3_addr,
  output [2:0]  ddr3_ba,
  output        ddr3_ras_n,
  output        ddr3_cas_n,
  output        ddr3_we_n,
  output        ddr3_reset_n,
  output [0:0]  ddr3_ck_p,
  output [0:0]  ddr3_ck_n,
  output [0:0]  ddr3_cke,
  output [0:0]  ddr3_cs_n,
  output [3:0]  ddr3_dm,
  output [0:0]  ddr3_odt,
  output        init_calib_complete,
  input         ddr3_sys_clk_i,
  input         ddr3_sys_rst_i,
  `endif
  `ifdef DDR4_CONTROLLER
  inout  [7:0]  c0_ddr4_dm_dbi_n,
  inout  [63:0] c0_ddr4_dq,
  inout  [7:0]  c0_ddr4_dqs_c,
  inout  [7:0]  c0_ddr4_dqs_t,
  output        c0_ddr4_act_n,
  output [16:0] c0_ddr4_adr,
  output [1:0]  c0_ddr4_ba,
  output [DDR_BG_WIDTH-1:0]  c0_ddr4_bg,
  output [0:0]  c0_ddr4_cke,
  output [0:0]  c0_ddr4_odt,
  output [0:0]  c0_ddr4_cs_n,
  output [0:0]  c0_ddr4_ck_t,
  output [0:0]  c0_ddr4_ck_c,
  output        c0_ddr4_reset_n,
  output        init_calib_complete,
  input         ddr4_sys_clk_i,
  input         ddr4_sys_rst_i,
  `endif
  input        nex_clk,
  input        nex_rst_n,
  output       nex_o_clk,
  output [3:0] nex_o_data,
  input  [40-1:0] reset_vector,
  input  mtime_toggle_a,
  input  dbg_toggle_a,
  input  por_rst_n,
  input  sys_rst_n,
  input  sys_clk,
`ifndef FPGA_SOURCE
  input  sys_clk_fast,
`endif
  input  evt_i,
  input  nmi_i,
  output core_wfi_mode,
  output core_sleep_value,
  input stop_on_reset,
  input  jtag_tck,
  input  jtag_tms,
  input  jtag_tdi,
  output jtag_tdo,
  output jtag_tdo_drv,
  output jtag_TMS_out,
  output jtag_DRV_TMS,
  output jtag_BK_TMS,
  output sysrstreq,
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
  input  test_mode 
);
  wire              ethernet_irq;
  wire  [  11:   0] eth_cfg_apb_paddr                ;
  wire              eth_cfg_apb_pwrite               ;
  wire              eth_cfg_apb_psel                 ;
  wire  [   2:   0] eth_cfg_apb_pprot                ;
  wire  [   3:   0] eth_cfg_apb_pstrobe              ;
  wire              eth_cfg_apb_penable              ;
  wire  [  31:   0] eth_cfg_apb_pwdata               ;
  wire [  31:   0]  eth_cfg_apb_prdata                ;
  wire              eth_cfg_apb_pready                ;
  wire              eth_cfg_apb_pslverr               ;
  wire              eth_axi_arready           ;
  wire              eth_axi_rvalid            ;
  wire  [  63:   0] eth_axi_rdata             ;
  wire  [   1:   0] eth_axi_rresp             ;
  wire              eth_axi_rlast             ;
  wire              eth_axi_awready           ;
  wire              eth_axi_bvalid            ;
  wire  [   1:   0] eth_axi_bresp             ;
  wire              eth_axi_wready            ;
  wire              eth_axi_arvalid            ;
  wire [32-1:   0]  eth_axi_araddr             ;
  wire [   7:   0]  eth_axi_arlen              ;
  wire [   2:   0]  eth_axi_arsize             ;
  wire [   1:   0]  eth_axi_arburst            ;
  wire              eth_axi_arlock             ;
  wire [   3:   0]  eth_axi_arcache            ;
  wire [   2:   0]  eth_axi_arprot             ;
  wire              eth_axi_rready             ;
  wire              eth_axi_awvalid            ;
  wire [32-1:   0]  eth_axi_awaddr             ;
  wire [   7:   0]  eth_axi_awlen              ;
  wire [   2:   0]  eth_axi_awsize             ;
  wire [   1:   0]  eth_axi_awburst            ;
  wire              eth_axi_awlock             ;
  wire [   3:   0]  eth_axi_awcache            ;
  wire [   2:   0]  eth_axi_awprot             ;
  wire              eth_axi_bready             ;
  wire              eth_axi_wvalid             ;
  wire [  63:   0]  eth_axi_wdata              ;
  wire [   7:   0]  eth_axi_wstrb              ;
  wire              eth_axi_wlast              ;
  wire misc_nmi;
  wire misc_evt;
  wire misc_dbg_secure_enable;
  wire misc_dbg_isolate;
  wire misc_dbg_override_dm_sleep;
  wire misc_dbg_i_dbg_stop;
  wire            udma_w_icb_cmd_valid               ;
  wire            udma_w_icb_cmd_ready               ;
  wire            udma_w_icb_cmd_sel                 ;
  wire            udma_w_icb_cmd_read                ;
  wire[  63:   0] udma_w_icb_cmd_addr                ;
  wire[  63:   0] udma_w_icb_cmd_wdata               ;
  wire[   7:   0] udma_w_icb_cmd_wmask               ;
  wire[   2:   0] udma_w_icb_cmd_size                ;
  wire            udma_w_icb_cmd_lock                ;
  wire            udma_w_icb_cmd_excl                ;
  wire[   7:   0] udma_w_icb_cmd_xlen                ;
  wire[   1:   0] udma_w_icb_cmd_xburst              ;
  wire[   1:   0] udma_w_icb_cmd_modes               ;
  wire            udma_w_icb_cmd_dmode               ;
  wire[   2:   0] udma_w_icb_cmd_attri               ;
  wire[   1:   0] udma_w_icb_cmd_beat                ;
  wire            udma_w_icb_rsp_ready               ;
  wire            udma_w_icb_rsp_valid               ;
  wire            udma_w_icb_rsp_err                 ;
  wire            udma_w_icb_rsp_excl_ok             ;
  wire[  63:   0] udma_w_icb_rsp_rdata               ;
  wire            udma_r_icb_cmd_valid               ;
  wire            udma_r_icb_cmd_ready               ;
  wire            udma_r_icb_cmd_sel                 ;
  wire            udma_r_icb_cmd_read                ;
  wire[  63:   0] udma_r_icb_cmd_addr                ;
  wire[  63:   0] udma_r_icb_cmd_wdata               ;
  wire[   7:   0] udma_r_icb_cmd_wmask               ;
  wire[   2:   0] udma_r_icb_cmd_size                ;
  wire            udma_r_icb_cmd_lock                ;
  wire            udma_r_icb_cmd_excl                ;
  wire[   7:   0] udma_r_icb_cmd_xlen                ;
  wire[   1:   0] udma_r_icb_cmd_xburst              ;
  wire[   1:   0] udma_r_icb_cmd_modes               ;
  wire            udma_r_icb_cmd_dmode               ;
  wire[   2:   0] udma_r_icb_cmd_attri               ;
  wire[   1:   0] udma_r_icb_cmd_beat                ;
  wire            udma_r_icb_rsp_ready               ;
  wire            udma_r_icb_rsp_valid               ;
  wire            udma_r_icb_rsp_err                 ;
  wire            udma_r_icb_rsp_excl_ok             ;
  wire[  63:   0] udma_r_icb_rsp_rdata               ;
  wire  nmi_i_agg = nmi_i | misc_nmi
                  ;
  wire  evt_i_agg = evt_i | misc_evt;
  wire  ppi_clk_en = 1'b1;
  wire  cppi_clk_en = 1'b1;
  wire  ppi_clk_en_din = 1'b1;
  wire  cppi_clk_en_din = 1'b1;
  wire clk_bus = sys_clk;
  wire bus_clk_en = 1'b1;
  wire bus_clk_en_din = 1'b1;
   wire  qspi0_irq; 
   wire  qspi1_irq;
   wire  qspi2_irq;
   wire  uart0_irq;                
   wire  udma_irq;
   wire  sdio_irq;
  wire  misc_irq0;
  wire  misc_irq1;
   wire [64-1:0] irq_i;
  wire [9:0]         hart_id = 10'd0;
  wire               icache_disable_init = 1'b0;
  wire               dcache_disable_init = 1'b0;
  wire               mmu_tlb_disable_init = 1'b0;
   e603_subsys_irq_alloc #(
    .N600_EXTER_IRQ_NUM (64)   
   )u_subsys_irq_alloc(
    .irq_out                (irq_i),
    .qspi0_irq              (qspi0_irq  ), 
    .qspi1_irq              (qspi1_irq  ),
    .qspi2_irq              (qspi2_irq  ),
    .uart0_irq              (uart0_irq  ),                
    .udma_irq               (udma_irq),
    .sdio_irq               (sdio_irq),
    .misc_irq0           (misc_irq0),
    .misc_irq1           (misc_irq1),
    .ethernet_irq           (ethernet_irq),
    .clk                    (clk_bus  ),
    .rst_n                  (sys_rst_n) 
  );
  wire biu2iram_icb_cmd_valid;
  wire biu2iram_icb_cmd_ready;
  wire [16-1:0] biu2iram_icb_cmd_addr; 
  wire biu2iram_icb_cmd_read; 
  wire [64-1:0] biu2iram_icb_cmd_wdata;
  wire [8-1:0] biu2iram_icb_cmd_wmask;
  wire biu2iram_icb_rsp_valid;
  wire biu2iram_icb_rsp_ready;
  wire biu2iram_icb_rsp_err;
  wire [64-1:0] biu2iram_icb_rsp_rdata;
  wire biu2dram_icb_cmd_valid;
  wire biu2dram_icb_cmd_ready;
  wire [16-1:0] biu2dram_icb_cmd_addr; 
  wire biu2dram_icb_cmd_read; 
  wire [64-1:0] biu2dram_icb_cmd_wdata;
  wire [8-1:0] biu2dram_icb_cmd_wmask;
  wire biu2dram_icb_rsp_valid;
  wire biu2dram_icb_rsp_ready;
  wire biu2dram_icb_rsp_err;
  wire [64-1:0] biu2dram_icb_rsp_rdata;
  wire                          qspi0_ro_icb_cmd_valid;
  wire                          qspi0_ro_icb_cmd_ready;
  wire [32-1:0]      qspi0_ro_icb_cmd_addr; 
  wire                          qspi0_ro_icb_cmd_read; 
  wire [32-1:0]                 qspi0_ro_icb_cmd_wdata;
  wire                          qspi0_ro_icb_rsp_valid;
  wire                          qspi0_ro_icb_rsp_ready;
  wire                          qspi0_ro_icb_rsp_err = 1'b0;
  wire [32-1:0]                 qspi0_ro_icb_rsp_rdata;
  wire                     biu2ppi_icb_cmd_valid; 
  wire                     biu2ppi_icb_cmd_ready; 
  wire                     biu2ppi_icb_cmd_read; 
  wire [32-1:0] biu2ppi_icb_cmd_addr; 
  wire [32-1:0]    biu2ppi_icb_cmd_wdata; 
  wire [4-1:0] biu2ppi_icb_cmd_wmask;
  wire                     biu2ppi_icb_rsp_valid; 
  wire                     biu2ppi_icb_rsp_ready; 
  wire                     biu2ppi_icb_rsp_err;
  wire [32-1:0]    biu2ppi_icb_rsp_rdata;
  wire  [3-1:0]     dummy_axi_rid;
  wire  [3-1:0]     dummy_axi_bid;
  wire [3-1:0]      dummy_axi_arid = 3'h0;
  wire [3-1:0]      dummy_axi_awid = 3'h0;
  wire                          dummy_axi_arready;
  wire                          dummy_axi_arvalid = 1'b0;
  wire [32-1:0] dummy_axi_araddr  = 32'b0;
  wire [7:0]                    dummy_axi_arlen   = 8'b0;
  wire [2:0]                    dummy_axi_arsize  = 3'b0;
  wire [1:0]                    dummy_axi_arburst = 2'b0;
  wire                          dummy_axi_arlock  = 1'b0;
  wire [3:0]                    dummy_axi_arcache = 4'b0;
  wire [2:0]                    dummy_axi_arprot  = 3'b0;
  wire                          dummy_axi_awready;
  wire                          dummy_axi_awvalid = 1'b0;
  wire [32-1:0] dummy_axi_awaddr  = 32'b0;
  wire [7:0]                    dummy_axi_awlen   = 8'b0;
  wire [2:0]                    dummy_axi_awsize  = 3'b0;
  wire [1:0]                    dummy_axi_awburst = 2'b0;
  wire                          dummy_axi_awlock  = 1'b0;
  wire [3:0]                    dummy_axi_awcache = 4'b0;
  wire [2:0]                    dummy_axi_awprot  = 3'b0;
  wire                          dummy_axi_wready;
  wire                          dummy_axi_wvalid  = 1'b0;
  wire [64-1:0]                 dummy_axi_wdata   = 64'b0;
  wire [8 -1:0]                 dummy_axi_wstrb   = 8'b0;
  wire                          dummy_axi_wlast   = 1'b0;
  wire                          dummy_axi_rready  = 1'b0;
  wire                          dummy_axi_rvalid;
  wire  [64-1:0]                dummy_axi_rdata;
  wire  [1:0]                   dummy_axi_rresp;
  wire                          dummy_axi_rlast;
  wire                          dummy_axi_bready = 1'b0;
  wire                          dummy_axi_bvalid;
  wire  [1:0]                   dummy_axi_bresp;
  wire                          dummy_icb_cmd_sel   = 1'b0; 
  wire                          dummy_icb_cmd_valid = 1'b0; 
  wire                          dummy_icb_cmd_ready; 
  wire                          dummy_icb_cmd_read  = 1'b0; 
  wire [32-1:0] dummy_icb_cmd_addr  = 32'b0; 
  wire [3-1:0]                  dummy_icb_cmd_size  = 3'b0; 
  wire [64-1:0]                 dummy_icb_cmd_wdata = 64'b0; 
  wire [8 -1:0]                 dummy_icb_cmd_wmask = 8'b0;
  wire                          dummy_icb_cmd_lock  = 1'b0; 
  wire                          dummy_icb_cmd_excl  = 1'b0; 
  wire [7:0]                    dummy_icb_cmd_xlen  = 8'b0;
  wire [1:0]                    dummy_icb_cmd_xburst = 2'b0;
  wire [0:0]                    dummy_icb_cmd_dmode = 1'b0;
  wire [1:0]                    dummy_icb_cmd_modes = 2'b0;
  wire [2:0]                    dummy_icb_cmd_attri = 3'b0;
  wire [1:0]                    dummy_icb_cmd_beat  = 2'b0;
  wire                          dummy_icb_rsp_valid; 
  wire                          dummy_icb_rsp_ready = 1'b0; 
  wire                          dummy_icb_rsp_err;
  wire                          dummy_icb_rsp_excl_ok;
  wire [64-1:0]                 dummy_icb_rsp_rdata;
  wire [1:0]                     dummy_ahbl_htrans = 2'b0;   
  wire                           dummy_ahbl_hmastlock = 1'b0;
  wire                           dummy_ahbl_hwrite = 1'b0;   
  wire [32 -1:0] dummy_ahbl_haddr  = 32'b0;    
  wire [2:0]                     dummy_ahbl_hsize  = 3'b0;    
  wire [3:0]                     dummy_ahbl_hprot  = 2'b0; 
  wire [2:0]                     dummy_ahbl_hburst = 3'b0;   
  wire [64    -1:0]              dummy_ahbl_hwdata = 64'b0;   
  wire [64    -1:0]              dummy_ahbl_hrdata;   
  wire [1:0]                     dummy_ahbl_hresp;    
  wire                           dummy_ahbl_hready;   
  wire                          dummy_slv_icb_cmd_sel  ;
  wire                          dummy_slv_icb_cmd_valid;
  wire                          dummy_slv_icb_cmd_ready; 
  wire                          dummy_slv_icb_cmd_read  ;
  wire [32-1:0] dummy_slv_icb_cmd_addr  ;
  wire [3-1:0]                  dummy_slv_icb_cmd_size  ;
  wire [64-1:0]                 dummy_slv_icb_cmd_wdata ;
  wire [8 -1:0]                 dummy_slv_icb_cmd_wmask ;
  wire                          dummy_slv_icb_cmd_lock  ;
  wire                          dummy_slv_icb_cmd_excl  ;
  wire [7:0]                    dummy_slv_icb_cmd_xlen  ;
  wire [1:0]                    dummy_slv_icb_cmd_xburst;
  wire [0:0]                    dummy_slv_icb_cmd_dmode ;
  wire [1:0]                    dummy_slv_icb_cmd_modes ;
  wire [2:0]                    dummy_slv_icb_cmd_attri ;
  wire [1:0]                    dummy_slv_icb_cmd_beat  ;
  wire                          dummy_slv_icb_rsp_valid; 
  wire                          dummy_slv_icb_rsp_ready;
  wire                          dummy_slv_icb_rsp_err = 1'b1;
  wire                          dummy_slv_icb_rsp_excl_ok = 1'b0;
  wire [64-1:0]                 dummy_slv_icb_rsp_rdata;
  nuclei_default_icb_slave # (
      .AW(32), 
      .DW(64) 
  ) u_dummy_slv_icb(
     .clk             (clk_bus  ),
     .rst_n           (sys_rst_n), 
    .icb_cmd_valid (dummy_slv_icb_cmd_valid),
    .icb_cmd_ready (dummy_slv_icb_cmd_ready),
    .icb_cmd_addr  (dummy_slv_icb_cmd_addr ), 
    .icb_cmd_read  (dummy_slv_icb_cmd_read ), 
    .icb_cmd_wdata (dummy_slv_icb_cmd_wdata),
    .icb_cmd_wmask (dummy_slv_icb_cmd_wmask),
    .icb_rsp_valid (dummy_slv_icb_rsp_valid),
    .icb_rsp_ready (dummy_slv_icb_rsp_ready),
    .icb_rsp_err   (),
    .icb_rsp_rdata (dummy_slv_icb_rsp_rdata)
  );
  wire [3-1:0] mem_r_icb_cmd_id;
  wire [3-1:0] mem_r_icb_rsp_id;
  wire                     mem_r_icb_rsp_last;
  wire [3-1:0] mem_w_icb_cmd_id;
  wire [3-1:0] mem_w_icb_rsp_id;
  wire                     mem_w_icb_rsp_last;
  wire [3-1:0]        axi_arid;
  wire [3-1:0]        axi_awid;
  wire  [3-1:0]       axi_rid;
  wire  [3-1:0]       axi_bid;
  wire                            axi_arready;
  wire                            axi_arvalid;
  wire [32-1:0]   axi_araddr;
  wire [7:0]                      axi_arlen;
  wire [2:0]                      axi_arsize;
  wire [1:0]                      axi_arburst;
  wire [1:0]                      axi_arlock;
  wire [3:0]                      axi_arcache;
  wire [2:0]                      axi_arprot;
  wire [2:0]                      axi_aruser;
  assign axi_aruser[2] = axi_arprot[0];
  assign axi_aruser[1] = 1'b0;
  assign axi_aruser[0] = 1'b0;
  wire                            axi_awready;
  wire                            axi_awvalid;
  wire [32-1:0]   axi_awaddr;
  wire [7:0]                      axi_awlen;
  wire [2:0]                      axi_awsize;
  wire [1:0]                      axi_awburst;
  wire [1:0]                      axi_awlock;
  wire [3:0]                      axi_awcache;
  wire [2:0]                      axi_awprot;
  wire [2:0]                      axi_awuser;
  assign axi_awuser[2] = axi_awprot[0];
  assign axi_awuser[1] = 1'b0;
  assign axi_awuser[0] = 1'b0;
  wire                            axi_wready;
  wire                            axi_wvalid;
  wire [64-1:0]          axi_wdata;
  wire [8-1:0]       axi_wstrb;
  wire                            axi_wlast;
  wire                            axi_rready;
  wire                            axi_rvalid;
  wire  [64-1:0]         axi_rdata;
  wire  [1:0]                     axi_rresp;
  wire                            axi_rlast;
  wire                            axi_bready;
  wire                            axi_bvalid;
  wire  [1:0]                     axi_bresp;
  assign axi_arlock[1] = 1'b0;
  assign axi_awlock[1] = 1'b0;
  wire                            o1_axi_arready;
  wire                            o1_axi_arvalid;
  wire [3-1:0]        o1_axi_arid ;
  wire [32-1:0]        o1_axi_araddr;
  wire [7:0]                      o1_axi_arlen;
  wire [2:0]                      o1_axi_arsize;
  wire [1:0]                      o1_axi_arburst;
  wire [1:0]                      o1_axi_arlock;
  wire [3:0]                      o1_axi_arcache;
  wire [2:0]                      o1_axi_arprot;
  wire [3:0]                      o1_axi_arqos;
  wire [3:0]                      o1_axi_arregion;
  wire [1-1:0]          o1_axi_aruser ;
  wire                            o1_axi_awready;
  wire                            o1_axi_awvalid;
  wire [3-1:0]        o1_axi_awid ;
  wire [32-1:0]        o1_axi_awaddr;
  wire [7:0]                      o1_axi_awlen;
  wire [2:0]                      o1_axi_awsize;
  wire [1:0]                      o1_axi_awburst;
  wire [1:0]                      o1_axi_awlock;
  wire [3:0]                      o1_axi_awcache;
  wire [2:0]                      o1_axi_awprot;
  wire [3:0]                      o1_axi_awqos;
  wire [3:0]                      o1_axi_awregion;
  wire [1-1:0]          o1_axi_awuser ; 
  wire                            o1_axi_wready;
  wire                            o1_axi_wvalid;
  wire [3-1:0]        o1_axi_wid ;
  wire [64-1:0]           o1_axi_wdata;
  wire [8-1:0]        o1_axi_wstrb;
  wire                            o1_axi_wlast;
  wire                            o1_axi_rready;
  wire                            o1_axi_rvalid;
  wire  [64-1:0]          o1_axi_rdata;
  wire  [1:0]                     o1_axi_rresp;
  wire                            o1_axi_rlast;
  wire                            o1_axi_bready;
  wire                            o1_axi_bvalid;
  wire  [1:0]                     o1_axi_bresp;
  wire                            ddr_axi_arready ;
  wire                            ddr_axi_arvalid;
  wire [3-1:0]        ddr_axi_arid ;
  wire [32-1:0]        ddr_axi_araddr;
  wire [7:0]                      ddr_axi_arlen;
  wire [2:0]                      ddr_axi_arsize;
  wire [1:0]                      ddr_axi_arburst;
  wire                            ddr_axi_arlock;
  wire [3:0]                      ddr_axi_arcache;
  wire [2:0]                      ddr_axi_arprot;
  wire [3:0]                      ddr_axi_arqos = 4'b0;
  wire [3:0]                      ddr_axi_arregion = 4'b0;
  wire [1-1:0]          ddr_axi_aruser =1'b0;
  wire                            ddr_axi_awready ;
  wire                            ddr_axi_awvalid;
  wire [3-1:0]        ddr_axi_awid ;
  wire [32-1:0]   ddr_axi_awaddr;
  wire [7:0]                      ddr_axi_awlen;
  wire [2:0]                      ddr_axi_awsize;
  wire [1:0]                      ddr_axi_awburst;
  wire                            ddr_axi_awlock;
  wire [3:0]                      ddr_axi_awcache;
  wire [2:0]                      ddr_axi_awprot;
  wire [3:0]                      ddr_axi_awqos = 4'b0;
  wire [3:0]                      ddr_axi_awregion = 4'b0;
  wire [1-1:0]          ddr_axi_awuser = 1'b0; 
  wire                            ddr_axi_wready ;
  wire                            ddr_axi_wvalid;
  wire [3-1:0]        ddr_axi_wid  =3'b0;
  wire [64-1:0]   ddr_axi_wdata;
  wire [(64/8)-1:0]ddr_axi_wstrb;
  wire                            ddr_axi_wlast;
  wire                            ddr_axi_rready;
  wire                            ddr_axi_rvalid ;
  wire  [64-1:0]                  ddr_axi_rdata ;
  wire  [1:0]                     ddr_axi_rresp ;
  wire                            ddr_axi_rlast ;
  wire  [3-1:0]       ddr_axi_rid;
  wire                            ddr_axi_bready;
  wire                            ddr_axi_bvalid ;
  wire  [1:0]                     ddr_axi_bresp ;
  wire  [3-1:0]       ddr_axi_bid;
  wire ui_clk           ;
  wire ui_clk_sync_rst_n;
   wire[3:0]                   iocp_arcache;
   wire[3:0]                   iocp_awcache;
   wire[27:0] iocp_ar_hi_addr;
   wire[27:0] iocp_aw_hi_addr;
    wire addr0_icb_cmd_valid;
    wire addr0_icb_cmd_ready;
e603_subsys_bus_fab u_bus_fab(
    .eth_axi_arready     (eth_axi_arready    ),
    .eth_axi_arvalid     (eth_axi_arvalid    ),
    .eth_axi_araddr      (eth_axi_araddr[32-1:0]),
    .eth_axi_arlen       (eth_axi_arlen      ),
    .eth_axi_arsize      (eth_axi_arsize     ),
    .eth_axi_arburst     (eth_axi_arburst    ),
    .eth_axi_arlock      (eth_axi_arlock     ),
    .eth_axi_arcache     (eth_axi_arcache    ),
    .eth_axi_arprot      (eth_axi_arprot     ),
    .eth_axi_awready     (eth_axi_awready    ),
    .eth_axi_awvalid     (eth_axi_awvalid    ),
    .eth_axi_awaddr      (eth_axi_awaddr[32-1:0]),
    .eth_axi_awlen       (eth_axi_awlen      ),
    .eth_axi_awsize      (eth_axi_awsize     ),
    .eth_axi_awburst     (eth_axi_awburst    ),
    .eth_axi_awlock      (eth_axi_awlock     ),
    .eth_axi_awcache     (eth_axi_awcache    ),
    .eth_axi_awprot      (eth_axi_awprot     ),
    .eth_axi_wready      (eth_axi_wready     ),
    .eth_axi_wvalid      (eth_axi_wvalid     ),
    .eth_axi_wdata       (eth_axi_wdata      ),
    .eth_axi_wstrb       (eth_axi_wstrb      ),
    .eth_axi_wlast       (eth_axi_wlast      ),
    .eth_axi_rready      (eth_axi_rready     ),
    .eth_axi_rvalid      (eth_axi_rvalid     ),
    .eth_axi_rdata       (eth_axi_rdata      ),
    .eth_axi_rresp       (eth_axi_rresp      ),
    .eth_axi_rlast       (eth_axi_rlast      ),
    .eth_axi_bready      (eth_axi_bready     ),
    .eth_axi_bvalid      (eth_axi_bvalid     ),
    .eth_axi_bresp       (eth_axi_bresp      ),
    .eth_axi_clk             (xec_sys_clk),
    .eth_axi_rst_n           (sys_rst_n),
    .dummy_axi_rid         (dummy_axi_rid        ),
    .dummy_axi_bid         (dummy_axi_bid        ),
    .dummy_axi_arid        (dummy_axi_arid       ),
    .dummy_axi_awid        (dummy_axi_awid       ),
    .dummy_axi_arready     (dummy_axi_arready    ),
    .dummy_axi_arvalid     (dummy_axi_arvalid    ),
    .dummy_axi_araddr      (dummy_axi_araddr     ),
    .dummy_axi_arlen       (dummy_axi_arlen      ),
    .dummy_axi_arsize      (dummy_axi_arsize     ),
    .dummy_axi_arburst     (dummy_axi_arburst    ),
    .dummy_axi_arlock      (dummy_axi_arlock     ),
    .dummy_axi_arcache     (dummy_axi_arcache    ),
    .dummy_axi_arprot      (dummy_axi_arprot     ),
    .dummy_axi_awready     (dummy_axi_awready    ),
    .dummy_axi_awvalid     (dummy_axi_awvalid    ),
    .dummy_axi_awaddr      (dummy_axi_awaddr     ),
    .dummy_axi_awlen       (dummy_axi_awlen      ),
    .dummy_axi_awsize      (dummy_axi_awsize     ),
    .dummy_axi_awburst     (dummy_axi_awburst    ),
    .dummy_axi_awlock      (dummy_axi_awlock     ),
    .dummy_axi_awcache     (dummy_axi_awcache    ),
    .dummy_axi_awprot      (dummy_axi_awprot     ),
    .dummy_axi_wready      (dummy_axi_wready     ),
    .dummy_axi_wvalid      (dummy_axi_wvalid     ),
    .dummy_axi_wdata       (dummy_axi_wdata      ),
    .dummy_axi_wstrb       (dummy_axi_wstrb      ),
    .dummy_axi_wlast       (dummy_axi_wlast      ),
    .dummy_axi_rready      (dummy_axi_rready     ),
    .dummy_axi_rvalid      (dummy_axi_rvalid     ),
    .dummy_axi_rdata       (dummy_axi_rdata      ),
    .dummy_axi_rresp       (dummy_axi_rresp      ),
    .dummy_axi_rlast       (dummy_axi_rlast      ),
    .dummy_axi_bready      (dummy_axi_bready     ),
    .dummy_axi_bvalid      (dummy_axi_bvalid     ),
    .dummy_axi_bresp       (dummy_axi_bresp      ),
    .dummy_icb_cmd_sel     (dummy_icb_cmd_sel    ),
    .dummy_icb_cmd_valid   (dummy_icb_cmd_valid  ),
    .dummy_icb_cmd_ready   (dummy_icb_cmd_ready  ),
    .dummy_icb_cmd_read    (dummy_icb_cmd_read   ),
    .dummy_icb_cmd_addr    (dummy_icb_cmd_addr   ),
    .dummy_icb_cmd_size    (dummy_icb_cmd_size   ),
    .dummy_icb_cmd_wdata   (dummy_icb_cmd_wdata  ),
    .dummy_icb_cmd_wmask   (dummy_icb_cmd_wmask  ),
    .dummy_icb_cmd_lock    (dummy_icb_cmd_lock   ),
    .dummy_icb_cmd_excl    (dummy_icb_cmd_excl   ),
    .dummy_icb_cmd_xlen    (dummy_icb_cmd_xlen   ),
    .dummy_icb_cmd_xburst  (dummy_icb_cmd_xburst ),
    .dummy_icb_cmd_dmode   (dummy_icb_cmd_dmode  ),
    .dummy_icb_cmd_modes   (dummy_icb_cmd_modes  ),
    .dummy_icb_cmd_attri   (dummy_icb_cmd_attri  ),
    .dummy_icb_cmd_beat    (dummy_icb_cmd_beat   ),
    .dummy_icb_rsp_valid   (dummy_icb_rsp_valid  ),
    .dummy_icb_rsp_ready   (dummy_icb_rsp_ready  ),
    .dummy_icb_rsp_err     (dummy_icb_rsp_err    ),
    .dummy_icb_rsp_excl_ok (dummy_icb_rsp_excl_ok),
    .dummy_icb_rsp_rdata   (dummy_icb_rsp_rdata  ),
    .dummy_ahbl_htrans     (dummy_ahbl_htrans),
    .dummy_ahbl_hmastlock  (dummy_ahbl_hmastlock),
    .dummy_ahbl_hwrite     (dummy_ahbl_hwrite),
    .dummy_ahbl_haddr      (dummy_ahbl_haddr ),
    .dummy_ahbl_hsize      (dummy_ahbl_hsize ),
    .dummy_ahbl_hprot      (dummy_ahbl_hprot ),
    .dummy_ahbl_hburst     (dummy_ahbl_hburst),
    .dummy_ahbl_hwdata     (dummy_ahbl_hwdata),
    .dummy_ahbl_hrdata     (dummy_ahbl_hrdata),
    .dummy_ahbl_hresp      (dummy_ahbl_hresp ),
    .dummy_ahbl_hready     (dummy_ahbl_hready),
    .dummy_slv_icb_cmd_sel     (dummy_slv_icb_cmd_sel    ),
    .dummy_slv_icb_cmd_valid   (dummy_slv_icb_cmd_valid  ),
    .dummy_slv_icb_cmd_ready   (dummy_slv_icb_cmd_ready  ),
    .dummy_slv_icb_cmd_read    (dummy_slv_icb_cmd_read   ),
    .dummy_slv_icb_cmd_addr    (dummy_slv_icb_cmd_addr   ),
    .dummy_slv_icb_cmd_size    (dummy_slv_icb_cmd_size   ),
    .dummy_slv_icb_cmd_wdata   (dummy_slv_icb_cmd_wdata  ),
    .dummy_slv_icb_cmd_wmask   (dummy_slv_icb_cmd_wmask  ),
    .dummy_slv_icb_cmd_lock    (dummy_slv_icb_cmd_lock   ),
    .dummy_slv_icb_cmd_excl    (dummy_slv_icb_cmd_excl   ),
    .dummy_slv_icb_cmd_xlen    (dummy_slv_icb_cmd_xlen   ),
    .dummy_slv_icb_cmd_xburst  (dummy_slv_icb_cmd_xburst ),
    .dummy_slv_icb_cmd_dmode   (dummy_slv_icb_cmd_dmode  ),
    .dummy_slv_icb_cmd_modes   (dummy_slv_icb_cmd_modes  ),
    .dummy_slv_icb_cmd_attri   (dummy_slv_icb_cmd_attri  ),
    .dummy_slv_icb_cmd_beat    (dummy_slv_icb_cmd_beat   ),
    .dummy_slv_icb_rsp_valid   (dummy_slv_icb_rsp_valid  ),
    .dummy_slv_icb_rsp_ready   (dummy_slv_icb_rsp_ready  ),
    .dummy_slv_icb_rsp_err     (dummy_slv_icb_rsp_err    ),
    .dummy_slv_icb_rsp_excl_ok (dummy_slv_icb_rsp_excl_ok),
    .dummy_slv_icb_rsp_rdata   (dummy_slv_icb_rsp_rdata  ),
    .addr0_icb_cmd_sel     (),
    .addr0_icb_cmd_valid   (addr0_icb_cmd_valid),
    .addr0_icb_cmd_ready   (addr0_icb_cmd_ready),
    .addr0_icb_cmd_read    (),
    .addr0_icb_cmd_addr    (),
    .addr0_icb_cmd_size    (),
    .addr0_icb_cmd_wdata   (),
    .addr0_icb_cmd_wmask   (),
    .addr0_icb_cmd_lock    (),
    .addr0_icb_cmd_excl    (),
    .addr0_icb_cmd_xlen    (),
    .addr0_icb_cmd_xburst  (),
    .addr0_icb_cmd_dmode   (),
    .addr0_icb_cmd_modes   (),
    .addr0_icb_cmd_attri   (),
    .addr0_icb_cmd_beat    (),
    .addr0_icb_rsp_valid   (addr0_icb_cmd_valid),
    .addr0_icb_rsp_ready   (addr0_icb_cmd_ready),
    .addr0_icb_rsp_err     (1'b0),
    .addr0_icb_rsp_excl_ok (1'b0),
    .addr0_icb_rsp_rdata   (32'b0),
  .eth_cfg_apb_paddr        (eth_cfg_apb_paddr  ),
  .eth_cfg_apb_pwrite       (eth_cfg_apb_pwrite ),
  .eth_cfg_apb_psel         (eth_cfg_apb_psel   ),
  .eth_cfg_apb_penable      (eth_cfg_apb_penable),
  .eth_cfg_apb_pwdata       (eth_cfg_apb_pwdata ),
  .eth_cfg_apb_prdata       (eth_cfg_apb_prdata ),
  .eth_cfg_apb_pready       (eth_cfg_apb_pready ),
  .eth_cfg_apb_pslverr      (eth_cfg_apb_pslverr),
  .eth_cfg_apb_pprot        (eth_cfg_apb_pprot  ),
  .eth_cfg_apb_pstrobe      (eth_cfg_apb_pstrobe),
    .i_axi_arid         (axi_arid),
    .i_axi_awid         (axi_awid),
    .i_axi_rid          (axi_rid ),
    .i_axi_bid          (axi_bid ),
    .i_axi_arready      (axi_arready),
    .i_axi_arvalid      (axi_arvalid),
    .i_axi_araddr       (axi_araddr),
    .i_axi_arlen        (axi_arlen),
    .i_axi_arsize       (axi_arsize),
    .i_axi_arburst      (axi_arburst),
    .i_axi_arlock       (axi_arlock[0]),
    .i_axi_arcache      (axi_arcache),
    .i_axi_arprot       (axi_arprot),
    .i_axi_aruser       (axi_aruser),
    .i_axi_awready      (axi_awready),
    .i_axi_awvalid      (axi_awvalid),
    .i_axi_awaddr       (axi_awaddr),
    .i_axi_awlen        (axi_awlen),
    .i_axi_awsize       (axi_awsize),
    .i_axi_awburst      (axi_awburst),
    .i_axi_awlock       (axi_awlock[0]),
    .i_axi_awcache      (axi_awcache),
    .i_axi_awprot       (axi_awprot),
    .i_axi_awuser       (axi_awuser),
    .i_axi_wready       (axi_wready),
    .i_axi_wvalid       (axi_wvalid),
    .i_axi_wdata        (axi_wdata),
    .i_axi_wstrb        (axi_wstrb),
    .i_axi_wlast        (axi_wlast),
    .i_axi_rready       (axi_rready),
    .i_axi_rvalid       (axi_rvalid),
    .i_axi_rdata        (axi_rdata),
    .i_axi_ruser        (),
    .i_axi_rresp        (axi_rresp),
    .i_axi_rlast        (axi_rlast),
    .i_axi_bready       (axi_bready),
    .i_axi_bvalid       (axi_bvalid),
    .i_axi_bresp        (axi_bresp),
    .i_axi_buser        (),
  .udma_w_icb_cmd_valid                (udma_w_icb_cmd_valid                    ),
  .udma_w_icb_cmd_ready                (udma_w_icb_cmd_ready                    ),
  .udma_w_icb_cmd_sel                  (udma_w_icb_cmd_sel                      ),
  .udma_w_icb_cmd_read                 (udma_w_icb_cmd_read                     ),
  .udma_w_icb_cmd_addr                 (udma_w_icb_cmd_addr[32-1:0]          ),
  .udma_w_icb_cmd_wdata                (udma_w_icb_cmd_wdata         [  63:   0]),
  .udma_w_icb_cmd_wmask                (udma_w_icb_cmd_wmask         [   7:   0]),
  .udma_w_icb_cmd_size                 (udma_w_icb_cmd_size          [   2:   0]),
  .udma_w_icb_cmd_lock                 (udma_w_icb_cmd_lock                     ),
  .udma_w_icb_cmd_excl                 (udma_w_icb_cmd_excl                     ),
  .udma_w_icb_cmd_xlen                 (udma_w_icb_cmd_xlen          [   7:   0]),
  .udma_w_icb_cmd_xburst               (udma_w_icb_cmd_xburst        [   1:   0]),
  .udma_w_icb_cmd_modes                (udma_w_icb_cmd_modes         [   1:   0]),
  .udma_w_icb_cmd_dmode                (udma_w_icb_cmd_dmode                    ),
  .udma_w_icb_cmd_attri                (udma_w_icb_cmd_attri         [   2:   0]),
  .udma_w_icb_cmd_beat                 (udma_w_icb_cmd_beat          [   1:   0]),
  .udma_w_icb_rsp_ready                (udma_w_icb_rsp_ready                    ),
  .udma_w_icb_rsp_valid                (udma_w_icb_rsp_valid                    ),
  .udma_w_icb_rsp_err                  (udma_w_icb_rsp_err                      ),
  .udma_w_icb_rsp_excl_ok              (udma_w_icb_rsp_excl_ok                  ),
  .udma_w_icb_rsp_rdata                (udma_w_icb_rsp_rdata         [  63:   0]),
  .udma_r_icb_cmd_valid                (udma_r_icb_cmd_valid                    ),
  .udma_r_icb_cmd_ready                (udma_r_icb_cmd_ready                    ),
  .udma_r_icb_cmd_sel                  (udma_r_icb_cmd_sel                      ),
  .udma_r_icb_cmd_read                 (udma_r_icb_cmd_read                     ),
  .udma_r_icb_cmd_addr                 (udma_r_icb_cmd_addr[32-1:0]),
  .udma_r_icb_cmd_wdata                (udma_r_icb_cmd_wdata         [  63:   0]),
  .udma_r_icb_cmd_wmask                (udma_r_icb_cmd_wmask         [   7:   0]),
  .udma_r_icb_cmd_size                 (udma_r_icb_cmd_size          [   2:   0]),
  .udma_r_icb_cmd_lock                 (udma_r_icb_cmd_lock                     ),
  .udma_r_icb_cmd_excl                 (udma_r_icb_cmd_excl                     ),
  .udma_r_icb_cmd_xlen                 (udma_r_icb_cmd_xlen          [   7:   0]),
  .udma_r_icb_cmd_xburst               (udma_r_icb_cmd_xburst        [   1:   0]),
  .udma_r_icb_cmd_modes                (udma_r_icb_cmd_modes         [   1:   0]),
  .udma_r_icb_cmd_dmode                (udma_r_icb_cmd_dmode                    ),
  .udma_r_icb_cmd_attri                (udma_r_icb_cmd_attri         [   2:   0]),
  .udma_r_icb_cmd_beat                 (udma_r_icb_cmd_beat          [   1:   0]),
  .udma_r_icb_rsp_ready                (udma_r_icb_rsp_ready                    ),
  .udma_r_icb_rsp_valid                (udma_r_icb_rsp_valid                    ),
  .udma_r_icb_rsp_err                  (udma_r_icb_rsp_err                      ),
  .udma_r_icb_rsp_excl_ok              (udma_r_icb_rsp_excl_ok                  ),
  .udma_r_icb_rsp_rdata                (udma_r_icb_rsp_rdata         [  63:   0]),
    .biu2ppi_icb_cmd_valid     (biu2ppi_icb_cmd_valid),
    .biu2ppi_icb_cmd_ready     (biu2ppi_icb_cmd_ready),
    .biu2ppi_icb_cmd_addr      (biu2ppi_icb_cmd_addr ),
    .biu2ppi_icb_cmd_read      (biu2ppi_icb_cmd_read ),
    .biu2ppi_icb_cmd_wdata     (biu2ppi_icb_cmd_wdata),
    .biu2ppi_icb_cmd_wmask     (biu2ppi_icb_cmd_wmask),
    .biu2ppi_icb_cmd_sel       (),
    .biu2ppi_icb_cmd_modes (),
    .biu2ppi_icb_cmd_dmode (),
    .biu2ppi_icb_cmd_size  (),
    .biu2ppi_icb_cmd_lock  (),
    .biu2ppi_icb_cmd_excl  (),
    .biu2ppi_icb_cmd_xlen  (),
    .biu2ppi_icb_cmd_xburst (),
    .biu2ppi_icb_cmd_beat   (),
    .biu2ppi_icb_cmd_attri  (),
    .biu2ppi_icb_rsp_excl_ok  (1'b1),
    .biu2ppi_icb_rsp_valid     (biu2ppi_icb_rsp_valid),
    .biu2ppi_icb_rsp_ready     (biu2ppi_icb_rsp_ready),
    .biu2ppi_icb_rsp_err       (biu2ppi_icb_rsp_err  ),
    .biu2ppi_icb_rsp_rdata     (biu2ppi_icb_rsp_rdata),
    .qspi0_ro_icb_cmd_valid  (qspi0_ro_icb_cmd_valid), 
    .qspi0_ro_icb_cmd_ready  (qspi0_ro_icb_cmd_ready),
    .qspi0_ro_icb_cmd_addr   (qspi0_ro_icb_cmd_addr ),
    .qspi0_ro_icb_cmd_read   (qspi0_ro_icb_cmd_read ),
    .qspi0_ro_icb_cmd_wdata  (qspi0_ro_icb_cmd_wdata),
    .qspi0_ro_icb_cmd_wmask     (),
    .qspi0_ro_icb_cmd_modes     (),
    .qspi0_ro_icb_cmd_dmode     (),
    .qspi0_ro_icb_cmd_sel   (),
    .qspi0_ro_icb_cmd_size  (),
    .qspi0_ro_icb_cmd_lock  (),
    .qspi0_ro_icb_cmd_excl  (),
    .qspi0_ro_icb_cmd_xlen  (),
    .qspi0_ro_icb_cmd_xburst (),
    .qspi0_ro_icb_cmd_beat   (),
    .qspi0_ro_icb_cmd_attri  (),
    .qspi0_ro_icb_rsp_excl_ok  (1'b1),
    .qspi0_ro_icb_rsp_valid  (qspi0_ro_icb_rsp_valid),
    .qspi0_ro_icb_rsp_ready  (qspi0_ro_icb_rsp_ready),
    .qspi0_ro_icb_rsp_err    (qspi0_ro_icb_rsp_err  ),
    .qspi0_ro_icb_rsp_rdata  (qspi0_ro_icb_rsp_rdata),
    .biu2iram_icb_clk_en      (1'b1),
    .biu2iram_icb_clk         (sys_clk),
    .biu2iram_icb_rst_n       (sys_rst_n),
    .biu2iram_icb_cmd_valid   (biu2iram_icb_cmd_valid),
    .biu2iram_icb_cmd_ready   (biu2iram_icb_cmd_ready),
    .biu2iram_icb_cmd_addr    (biu2iram_icb_cmd_addr ), 
    .biu2iram_icb_cmd_read    (biu2iram_icb_cmd_read ), 
    .biu2iram_icb_cmd_wdata   (biu2iram_icb_cmd_wdata),
    .biu2iram_icb_cmd_wmask   (biu2iram_icb_cmd_wmask),
    .biu2iram_icb_cmd_modes   (),
    .biu2iram_icb_cmd_dmode   (),
    .biu2iram_icb_cmd_sel     (),
    .biu2iram_icb_cmd_size    (),
    .biu2iram_icb_cmd_lock    (),
    .biu2iram_icb_cmd_excl    (),
    .biu2iram_icb_cmd_xlen    (),
    .biu2iram_icb_cmd_xburst  (),
    .biu2iram_icb_cmd_beat    (),
    .biu2iram_icb_cmd_attri   (),
    .biu2iram_icb_rsp_excl_ok (1'b0),
    .biu2iram_icb_rsp_valid   (biu2iram_icb_rsp_valid),
    .biu2iram_icb_rsp_ready   (biu2iram_icb_rsp_ready),
    .biu2iram_icb_rsp_err     (biu2iram_icb_rsp_err  ),
    .biu2iram_icb_rsp_rdata   (biu2iram_icb_rsp_rdata),
    .biu2dram_icb_clk_en      (1'b1),
    .biu2dram_icb_clk         (sys_clk),
    .biu2dram_icb_rst_n       (sys_rst_n),
    .biu2dram_icb_cmd_valid   (biu2dram_icb_cmd_valid),
    .biu2dram_icb_cmd_ready   (biu2dram_icb_cmd_ready),
    .biu2dram_icb_cmd_addr    (biu2dram_icb_cmd_addr ), 
    .biu2dram_icb_cmd_read    (biu2dram_icb_cmd_read ), 
    .biu2dram_icb_cmd_wdata   (biu2dram_icb_cmd_wdata),
    .biu2dram_icb_cmd_wmask   (biu2dram_icb_cmd_wmask),
    .biu2dram_icb_cmd_modes   (),
    .biu2dram_icb_cmd_dmode   (),
    .biu2dram_icb_cmd_sel     (),
    .biu2dram_icb_cmd_size    (),
    .biu2dram_icb_cmd_lock    (),
    .biu2dram_icb_cmd_excl    (),
    .biu2dram_icb_cmd_xlen    (),
    .biu2dram_icb_cmd_xburst  (),
    .biu2dram_icb_cmd_beat    (),
    .biu2dram_icb_cmd_attri   (),
    .biu2dram_icb_rsp_excl_ok (1'b1),
    .biu2dram_icb_rsp_valid   (biu2dram_icb_rsp_valid),
    .biu2dram_icb_rsp_ready   (biu2dram_icb_rsp_ready),
    .biu2dram_icb_rsp_err     (biu2dram_icb_rsp_err  ),
    .biu2dram_icb_rsp_rdata   (biu2dram_icb_rsp_rdata),
    .o0_axi_arready   (ddr_axi_arready),
    .o0_axi_arvalid   (ddr_axi_arvalid),
    .o0_axi_arid      (ddr_axi_arid  ),
    .o0_axi_araddr    (ddr_axi_araddr),
    .o0_axi_arlen     (ddr_axi_arlen),
    .o0_axi_arsize    (ddr_axi_arsize),
    .o0_axi_arburst   (ddr_axi_arburst),
    .o0_axi_arlock    (ddr_axi_arlock),
    .o0_axi_arcache   (ddr_axi_arcache),
    .o0_axi_arprot    (ddr_axi_arprot),
    .o0_axi_awready   (ddr_axi_awready),
    .o0_axi_awvalid   (ddr_axi_awvalid),
    .o0_axi_awid      (ddr_axi_awid  ),
    .o0_axi_awaddr    (ddr_axi_awaddr),
    .o0_axi_awlen     (ddr_axi_awlen),
    .o0_axi_awsize    (ddr_axi_awsize),
    .o0_axi_awburst   (ddr_axi_awburst),
    .o0_axi_awlock    (ddr_axi_awlock),
    .o0_axi_awcache   (ddr_axi_awcache),
    .o0_axi_awprot    (ddr_axi_awprot),
    .o0_axi_wready    (ddr_axi_wready),
    .o0_axi_wvalid    (ddr_axi_wvalid),
    .o0_axi_wdata     (ddr_axi_wdata),
    .o0_axi_wstrb     (ddr_axi_wstrb),
    .o0_axi_wlast     (ddr_axi_wlast),
    .o0_axi_rready    (ddr_axi_rready),
    .o0_axi_rvalid    (ddr_axi_rvalid),
    .o0_axi_rdata     (ddr_axi_rdata),
    .o0_axi_rresp     (ddr_axi_rresp),
    .o0_axi_rlast     (ddr_axi_rlast),
    .o0_axi_rid       (ddr_axi_rid),
    .o0_axi_bready    (ddr_axi_bready),
    .o0_axi_bvalid    (ddr_axi_bvalid),
    .o0_axi_bresp     (ddr_axi_bresp),
    .o0_axi_bid       (ddr_axi_bid),
    `ifdef DDR4_CONTROLLER
     .o0_axi_clk      (ui_clk),
     .o0_axi_rst_n    (ui_clk_sync_rst_n), 
    `else
     .o0_axi_clk      (clk_bus),
     .o0_axi_rst_n    (sys_rst_n), 
    `endif
     .clkgate_bypass  (test_mode),
     .clk             (clk_bus  ),
     .rst_n           (sys_rst_n) 
);
  wire                        nice_clk         ;
  wire                        nice_active	     ;
  wire                        nice_mem_holdup  ;
  wire                        nice_req_valid    ;
  wire                        nice_req_ready    ;
  wire [32-1:0]       nice_req_instr    ;
  wire [64-1:0]       nice_req_rs1      ;
  wire [64-1:0]       nice_req_rs2      ;
  wire                        nice_req_mmode    ;
  wire                        nice_req_smode    ;
  wire                        nice_rsp_1cyc_type    ;
  wire [64-1:0]       nice_rsp_1cyc_dat    ;	
  wire                        nice_rsp_1cyc_err     ;
  wire                        nice_rsp_multicyc_valid    ;
  wire                        nice_rsp_multicyc_ready    ;
  wire [64-1:0]       nice_rsp_multicyc_dat     ;
  wire                        nice_rsp_multicyc_err      ;
  wire                        nice_icb_cmd_valid;
  wire                        nice_icb_cmd_ready;
  wire [32-1:0]  nice_icb_cmd_addr ;
  wire                        nice_icb_cmd_read ;
  wire [64-1:0]   nice_icb_cmd_wdata;
  wire [8-1:0]   nice_icb_cmd_wmask;
  wire [2:0]                  nice_icb_cmd_size ;
  wire                        nice_icb_cmd_mmode;
  wire                        nice_icb_cmd_smode;
  wire                        nice_icb_rsp_valid;
  wire                        nice_icb_rsp_ready;
  wire [64-1:0]   nice_icb_rsp_rdata;
  wire                        nice_icb_rsp_err  ;
  wire i0_trace_ivalid;
  wire i0_trace_iexception;
  wire i0_trace_interrupt;
  wire [64-1:0] i0_trace_cause;
  wire [64-1:0] i0_trace_tval;
  wire [64-1:0] i0_trace_iaddr;
  wire [32-1:0] i0_trace_instr;
  wire [1:0] i0_trace_priv;
  wire i0_trace_bjp_taken;
  wire i0_trace_dmode;
  wire i0_trace_cmt_ena;
  wire core_clk_aon;
  wire [31:0] random_clken = 32'b0;
  wire evt_i_real ;
  wire nmi_i_real;
  wire irq_i_real;
  wire aon_wake_up_detct =  (
                                  evt_i_real
                                | nmi_i_real
	   `ifndef FPGA_SOURCE
                                | irq_i_real
	   `endif
                              );
  wire core_clk_aon_en =
                        random_clken[0] | 
                        ((core_wfi_mode & core_sleep_value) ?
                                  aon_wake_up_detct
                              : 1'b1);
  reg evt_i_r;
  reg nmi_i_r;
  reg irq_i_r;
  reg irq_i_r_r;
  wire deep_sleep = (core_wfi_mode & core_sleep_value);
  always@(posedge sys_clk or negedge sys_rst_n)
  begin
      if(~sys_rst_n) begin
        evt_i_r  <= 1'b0;
        nmi_i_r <= 1'b0;
        irq_i_r  <= 1'b0;
        irq_i_r_r <= 1'b0;
      end
      else begin
        evt_i_r   <= deep_sleep & evt_i_agg;
        nmi_i_r   <= deep_sleep & nmi_i_agg;
        irq_i_r   <= deep_sleep & (|irq_i);
        irq_i_r_r <= irq_i_r;
      end
  end
  assign evt_i_real  = evt_i_agg | evt_i_r;
  assign nmi_i_real  = nmi_i_agg | nmi_i_r;
  assign irq_i_real  = (|irq_i) | irq_i_r | irq_i_r_r;
    wire core_clk_aon_pre;
  e603_clkgate u_core_aon_clkgate(
    .clk_in   (sys_clk      ),
    .clkgate_bypass(test_mode  ),
    .clock_en (core_clk_aon_en),
    .clk_out  (core_clk_aon_pre)
  );
`ifndef FPGA_SOURCE
    assign core_clk_aon = core_clk_aon_pre;
`else
    assign core_clk_aon = core_clk_aon_pre;
`endif
  wire nice_active_real = nice_active ;
  e603_clkgate u_nice_clkgate(
    .clk_in   (sys_clk      ),
    .clkgate_bypass(test_mode  ),
    .clock_en (nice_active_real),
    .clk_out  (nice_clk)
  );
  wire                                          mmu_disable_init = 1'b0;
 wire dbg_stoptime;
  e603_core_rams u_core_rams(
    .hart_halted     (           ), 
     .jtag_TCK    (jtag_tck),
     .jtag_TMS_in (jtag_tms),
     .jtag_TDI    (jtag_tdi),
     .jtag_TDO    (jtag_tdo),
     .jtag_DRV_TDO(jtag_tdo_drv),
     .jtag_TMS_out   (jtag_TMS_out),
     .jtag_DRV_TMS   (jtag_DRV_TMS),
     .jtag_BK_TMS    (jtag_BK_TMS ),
     .jtag_dwen      (),
     .jtag_dwbypass  (1'b0), 
     .i_dbg_stop  (misc_dbg_i_dbg_stop),
     .override_dm_sleep  (misc_dbg_override_dm_sleep),
    .dbg_stoptime    (dbg_stoptime), 
    .sysrstreq       (sysrstreq       ),
    .i0_trace_ivalid    (i0_trace_ivalid    ),
    .i0_trace_iexception(i0_trace_iexception),
    .i0_trace_cause     (i0_trace_cause     ),
    .i0_trace_tval      (i0_trace_tval      ),
    .i0_trace_interrupt (i0_trace_interrupt ),
    .i0_trace_iaddr     (i0_trace_iaddr     ),
    .i0_trace_instr     (i0_trace_instr     ),
    .i0_trace_priv      (i0_trace_priv      ),
    .i0_trace_bjp_taken (i0_trace_bjp_taken ),
    .i0_trace_dmode     (i0_trace_dmode     ),
    .i0_trace_cmt_ena   (i0_trace_cmt_ena   ),
    .mtime_toggle_a     (mtime_toggle_a  ),
    .dbg_toggle_a     (dbg_toggle_a),
    .nmi            (nmi_i_agg),
    .irq_i      (irq_i),
    .reset_vector             (reset_vector),
    .core_wfi_mode            (core_wfi_mode),
    .core_sleep_value         (core_sleep_value),
    .hart_id          (hart_id), 
    .icache_disable_init  (icache_disable_init),
    .dcache_disable_init      (dcache_disable_init),
    .mmu_tlb_disable_init (mmu_disable_init    ),
    .nice_mem_holdup         (nice_mem_holdup),
    .nice_req_valid          (nice_req_valid ),
    .nice_req_ready          (nice_req_ready ),
    .nice_req_instr          (nice_req_instr ),
    .nice_req_rs1            (nice_req_rs1   ), 
    .nice_req_rs2            (nice_req_rs2   ), 
    .nice_req_mmode          (nice_req_mmode     ), 
    .nice_req_smode          (nice_req_smode     ), 
    .nice_rsp_1cyc_type      (nice_rsp_1cyc_type     ), 
    .nice_rsp_1cyc_dat       (nice_rsp_1cyc_dat     ), 
    .nice_rsp_multicyc_valid (nice_rsp_multicyc_valid     ), 
    .nice_rsp_multicyc_ready (nice_rsp_multicyc_ready     ), 
    .nice_rsp_multicyc_dat   (nice_rsp_multicyc_dat      ), 
    .nice_rsp_multicyc_err   (nice_rsp_multicyc_err       ),
    .nice_icb_cmd_valid      (nice_icb_cmd_valid ), 
    .nice_icb_cmd_ready      (nice_icb_cmd_ready ), 
    .nice_icb_cmd_addr       (nice_icb_cmd_addr  ), 
    .nice_icb_cmd_read       (nice_icb_cmd_read  ), 
    .nice_icb_cmd_wdata      (nice_icb_cmd_wdata ), 
    .nice_icb_cmd_wmask      (nice_icb_cmd_wmask ), 
    .nice_icb_cmd_size       (nice_icb_cmd_size  ), 
    .nice_icb_cmd_mmode      (nice_icb_cmd_mmode ), 
    .nice_icb_cmd_smode      (nice_icb_cmd_smode ), 
    .nice_icb_rsp_valid      (nice_icb_rsp_valid ), 
    .nice_icb_rsp_ready      (nice_icb_rsp_ready ), 
    .nice_icb_rsp_rdata      (nice_icb_rsp_rdata ), 
    .nice_icb_rsp_err        (nice_icb_rsp_err   ), 
     .mem_arid(axi_arid),
     .mem_awid(axi_awid),
     .mem_rid (axi_rid ),
     .mem_bid (axi_bid ),
     .mem_arready    (axi_arready),
     .mem_arvalid    (axi_arvalid),
     .mem_araddr     (axi_araddr),
     .mem_arlen      (axi_arlen),
     .mem_arsize     (axi_arsize),
     .mem_arburst    (axi_arburst),
     .mem_arlock     (axi_arlock[0]),
     .mem_arcache    (axi_arcache),
     .mem_arprot     (axi_arprot),
     .mem_awready    (axi_awready),
     .mem_awvalid    (axi_awvalid),
     .mem_awaddr     (axi_awaddr),
     .mem_awlen      (axi_awlen),
     .mem_awsize     (axi_awsize),
     .mem_awburst    (axi_awburst),
     .mem_awlock     (axi_awlock[0]),
     .mem_awcache    (axi_awcache),
     .mem_awprot     (axi_awprot),
     .mem_wready     (axi_wready),
     .mem_wvalid     (axi_wvalid),
     .mem_wdata      (axi_wdata),
     .mem_wstrb      (axi_wstrb),
     .mem_wlast      (axi_wlast),
     .mem_rready     (axi_rready),
     .mem_rvalid     (axi_rvalid),
     .mem_rdata      (axi_rdata),
     .mem_rresp      (axi_rresp),
     .mem_rlast      (axi_rlast),
     .mem_bready     (axi_bready),
     .mem_bvalid     (axi_bvalid),
     .mem_bresp      (axi_bresp),
     .mem_clk_en     (bus_clk_en),
     .tx_evt  (),
     .rx_evt  (evt_i_agg),
     .stop_on_reset    (stop_on_reset),
     .clkgate_bypass   (test_mode), 
     .reset_bypass     (test_mode), 
     .core_clk_aon     (core_clk_aon),
     .core_reset_n     (sys_rst_n),
     .por_reset_n      (por_rst_n)
);
`ifndef SYNTHESIS
    reg[31:0] hang_counter_max = 32'h20_0000;
    reg[31:0] core_hang_counter = 32'b0;
    always@(posedge sys_clk)
        if (i0_trace_ivalid | core_wfi_mode)
            core_hang_counter <= 32'b0;
        else
            core_hang_counter <= core_hang_counter + 1'b1;
    wire core_hang = core_hang_counter > hang_counter_max;
`endif
    assign nex_o_clk = 1'b0;
    assign nex_o_data = 4'b0;
  wire [9-1:0] mem_delay_select; 
 e603_subsys_ram u_subsys_ram(
    .biu2iram_icb_cmd_valid (biu2iram_icb_cmd_valid),
    .biu2iram_icb_cmd_ready (biu2iram_icb_cmd_ready),
    .biu2iram_icb_cmd_addr  (biu2iram_icb_cmd_addr ), 
    .biu2iram_icb_cmd_read  (biu2iram_icb_cmd_read ), 
    .biu2iram_icb_cmd_wdata (biu2iram_icb_cmd_wdata),
    .biu2iram_icb_cmd_wmask (biu2iram_icb_cmd_wmask),
    .biu2iram_icb_rsp_valid (biu2iram_icb_rsp_valid),
    .biu2iram_icb_rsp_ready (biu2iram_icb_rsp_ready),
    .biu2iram_icb_rsp_err   (biu2iram_icb_rsp_err  ),
    .biu2iram_icb_rsp_rdata (biu2iram_icb_rsp_rdata),
    .biu2dram_icb_cmd_valid (biu2dram_icb_cmd_valid),
    .biu2dram_icb_cmd_ready (biu2dram_icb_cmd_ready),
    .biu2dram_icb_cmd_addr  (biu2dram_icb_cmd_addr ), 
    .biu2dram_icb_cmd_read  (biu2dram_icb_cmd_read ), 
    .biu2dram_icb_cmd_wdata (biu2dram_icb_cmd_wdata),
    .biu2dram_icb_cmd_wmask (biu2dram_icb_cmd_wmask),
    .biu2dram_icb_rsp_valid (biu2dram_icb_rsp_valid),
    .biu2dram_icb_rsp_ready (biu2dram_icb_rsp_ready),
    .biu2dram_icb_rsp_err   (biu2dram_icb_rsp_err  ),
    .biu2dram_icb_rsp_rdata (biu2dram_icb_rsp_rdata),
    .test_mode     (test_mode),
    .clk           (clk_bus  ),
    .aon_clk       (sys_clk     ),
    .rst_n         (sys_rst_n) 
  );
  e603_subsys_perips u_subsys_perips (
    .mem_delay_select           (mem_delay_select),
    .misc_nmi(misc_nmi),
    .misc_evt(misc_evt),
    .misc_dbg_secure_enable     (misc_dbg_secure_enable      ),
    .misc_dbg_isolate           (misc_dbg_isolate            ),
    .misc_dbg_override_dm_sleep (misc_dbg_override_dm_sleep  ),
    .misc_dbg_stop_at_boot      (       ),
    .misc_dbg_i_dbg_stop        (misc_dbg_i_dbg_stop         ),
    .iocp_arcache  (iocp_arcache),
    .iocp_awcache  (iocp_awcache),
    .iocp_ar_hi_addr (iocp_ar_hi_addr),
    .iocp_aw_hi_addr (iocp_aw_hi_addr),
    .biu2ppi_icb_cmd_valid     (biu2ppi_icb_cmd_valid),
    .biu2ppi_icb_cmd_ready     (biu2ppi_icb_cmd_ready),
    .biu2ppi_icb_cmd_addr      (biu2ppi_icb_cmd_addr ),
    .biu2ppi_icb_cmd_read      (biu2ppi_icb_cmd_read ),
    .biu2ppi_icb_cmd_wdata     (biu2ppi_icb_cmd_wdata),
    .biu2ppi_icb_cmd_wmask     (biu2ppi_icb_cmd_wmask),
    .biu2ppi_icb_rsp_valid     (biu2ppi_icb_rsp_valid),
    .biu2ppi_icb_rsp_ready     (biu2ppi_icb_rsp_ready),
    .biu2ppi_icb_rsp_err       (biu2ppi_icb_rsp_err  ),
    .biu2ppi_icb_rsp_rdata     (biu2ppi_icb_rsp_rdata),
  .udma_w_icb_cmd_valid                (udma_w_icb_cmd_valid                    ),
  .udma_w_icb_cmd_ready                (udma_w_icb_cmd_ready                    ),
  .udma_w_icb_cmd_sel                  (udma_w_icb_cmd_sel                      ),
  .udma_w_icb_cmd_read                 (udma_w_icb_cmd_read                     ),
  .udma_w_icb_cmd_addr                 (udma_w_icb_cmd_addr),
  .udma_w_icb_cmd_wdata                (udma_w_icb_cmd_wdata         [  63:   0]),
  .udma_w_icb_cmd_wmask                (udma_w_icb_cmd_wmask         [   7:   0]),
  .udma_w_icb_cmd_size                 (udma_w_icb_cmd_size          [   2:   0]),
  .udma_w_icb_cmd_lock                 (udma_w_icb_cmd_lock                     ),
  .udma_w_icb_cmd_excl                 (udma_w_icb_cmd_excl                     ),
  .udma_w_icb_cmd_xlen                 (udma_w_icb_cmd_xlen          [   7:   0]),
  .udma_w_icb_cmd_xburst               (udma_w_icb_cmd_xburst        [   1:   0]),
  .udma_w_icb_cmd_modes                (udma_w_icb_cmd_modes         [   1:   0]),
  .udma_w_icb_cmd_dmode                (udma_w_icb_cmd_dmode                    ),
  .udma_w_icb_cmd_attri                (udma_w_icb_cmd_attri         [   2:   0]),
  .udma_w_icb_cmd_beat                 (udma_w_icb_cmd_beat          [   1:   0]),
  .udma_w_icb_rsp_ready                (udma_w_icb_rsp_ready                    ),
  .udma_w_icb_rsp_valid                (udma_w_icb_rsp_valid                    ),
  .udma_w_icb_rsp_err                  (udma_w_icb_rsp_err                      ),
  .udma_w_icb_rsp_excl_ok              (udma_w_icb_rsp_excl_ok                  ),
  .udma_w_icb_rsp_rdata                (udma_w_icb_rsp_rdata         [  63:   0]),
  .udma_r_icb_cmd_valid                (udma_r_icb_cmd_valid                    ),
  .udma_r_icb_cmd_ready                (udma_r_icb_cmd_ready                    ),
  .udma_r_icb_cmd_sel                  (udma_r_icb_cmd_sel                      ),
  .udma_r_icb_cmd_read                 (udma_r_icb_cmd_read                     ),
  .udma_r_icb_cmd_addr                 (udma_r_icb_cmd_addr),
  .udma_r_icb_cmd_wdata                (udma_r_icb_cmd_wdata         [  63:   0]),
  .udma_r_icb_cmd_wmask                (udma_r_icb_cmd_wmask         [   7:   0]),
  .udma_r_icb_cmd_size                 (udma_r_icb_cmd_size          [   2:   0]),
  .udma_r_icb_cmd_lock                 (udma_r_icb_cmd_lock                     ),
  .udma_r_icb_cmd_excl                 (udma_r_icb_cmd_excl                     ),
  .udma_r_icb_cmd_xlen                 (udma_r_icb_cmd_xlen          [   7:   0]),
  .udma_r_icb_cmd_xburst               (udma_r_icb_cmd_xburst        [   1:   0]),
  .udma_r_icb_cmd_modes                (udma_r_icb_cmd_modes         [   1:   0]),
  .udma_r_icb_cmd_dmode                (udma_r_icb_cmd_dmode                    ),
  .udma_r_icb_cmd_attri                (udma_r_icb_cmd_attri         [   2:   0]),
  .udma_r_icb_cmd_beat                 (udma_r_icb_cmd_beat          [   1:   0]),
  .udma_r_icb_rsp_ready                (udma_r_icb_rsp_ready                    ),
  .udma_r_icb_rsp_valid                (udma_r_icb_rsp_valid                    ),
  .udma_r_icb_rsp_err                  (udma_r_icb_rsp_err                      ),
  .udma_r_icb_rsp_excl_ok              (udma_r_icb_rsp_excl_ok                  ),
  .udma_r_icb_rsp_rdata                (udma_r_icb_rsp_rdata         [  63:   0]),
  .eth_cfg_apb_paddr             (eth_cfg_apb_paddr                 ),
  .eth_cfg_apb_pwrite            (eth_cfg_apb_pwrite                ),
  .eth_cfg_apb_psel              (eth_cfg_apb_psel                  ),
  .eth_cfg_apb_pprot             (eth_cfg_apb_pprot                 ),
  .eth_cfg_apb_pstrobe           (eth_cfg_apb_pstrobe               ),
  .eth_cfg_apb_penable           (eth_cfg_apb_penable               ),
  .eth_cfg_apb_pwdata            (eth_cfg_apb_pwdata                ),
  .eth_cfg_apb_prdata            (eth_cfg_apb_prdata                ),
  .eth_cfg_apb_pready            (eth_cfg_apb_pready                ),
  .eth_cfg_apb_pslverr           (eth_cfg_apb_pslverr               ),
  .eth_axi_arvalid            (eth_axi_arvalid            ),
  .eth_axi_arready            (eth_axi_arready            ),
  .eth_axi_araddr             (eth_axi_araddr[31:0]       ),
  .eth_axi_arlen              (eth_axi_arlen              ),
  .eth_axi_arsize             (eth_axi_arsize             ),
  .eth_axi_arburst            (eth_axi_arburst            ),
  .eth_axi_arlock             (eth_axi_arlock             ),
  .eth_axi_arcache            (eth_axi_arcache            ),
  .eth_axi_arprot             (eth_axi_arprot             ),
  .eth_axi_rready             (eth_axi_rready             ),
  .eth_axi_rvalid             (eth_axi_rvalid             ),
  .eth_axi_rdata              (eth_axi_rdata              ),
  .eth_axi_rresp              (eth_axi_rresp              ),
  .eth_axi_rlast              (eth_axi_rlast              ),
  .eth_axi_awvalid            (eth_axi_awvalid            ),
  .eth_axi_awready            (eth_axi_awready            ),
  .eth_axi_awaddr             (eth_axi_awaddr[31:0]       ),
  .eth_axi_awlen              (eth_axi_awlen              ),
  .eth_axi_awsize             (eth_axi_awsize             ),
  .eth_axi_awburst            (eth_axi_awburst            ),
  .eth_axi_awlock             (eth_axi_awlock             ),
  .eth_axi_awcache            (eth_axi_awcache            ),
  .eth_axi_awprot             (eth_axi_awprot             ),
  .eth_axi_bready             (eth_axi_bready             ),
  .eth_axi_bvalid             (eth_axi_bvalid             ),
  .eth_axi_bresp              (eth_axi_bresp              ),
  .eth_axi_wready             (eth_axi_wready             ),
  .eth_axi_wvalid             (eth_axi_wvalid             ),
  .eth_axi_wdata              (eth_axi_wdata              ),
  .eth_axi_wstrb              (eth_axi_wstrb              ),
  .eth_axi_wlast              (eth_axi_wlast              ),
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
  .xec_sys_clk                   (xec_sys_clk                   ),
  .ethernet_irq                  (ethernet_irq                  ),
    .qspi0_ro_icb_cmd_valid  (qspi0_ro_icb_cmd_valid), 
    .qspi0_ro_icb_cmd_ready  (qspi0_ro_icb_cmd_ready),
    .qspi0_ro_icb_cmd_addr   (qspi0_ro_icb_cmd_addr ),
    .qspi0_ro_icb_cmd_read   (qspi0_ro_icb_cmd_read ),
    .qspi0_ro_icb_cmd_wdata  (qspi0_ro_icb_cmd_wdata),
    .qspi0_ro_icb_rsp_valid  (qspi0_ro_icb_rsp_valid),
    .qspi0_ro_icb_rsp_ready  (qspi0_ro_icb_rsp_ready),
    .qspi0_ro_icb_rsp_rdata  (qspi0_ro_icb_rsp_rdata),
    .io_pads_qspi0_sck_i_ival (io_pads_qspi0_sck_i_ival    ),
    .io_pads_qspi0_sck_o_oval (io_pads_qspi0_sck_o_oval    ),
    .io_pads_qspi0_sck_o_oe   (io_pads_qspi0_sck_o_oe      ),
    .io_pads_qspi0_sck_o_ie   (io_pads_qspi0_sck_o_ie      ),
    .io_pads_qspi0_sck_o_pue  (io_pads_qspi0_sck_o_pue     ),
    .io_pads_qspi0_sck_o_ds   (io_pads_qspi0_sck_o_ds      ),
    .io_pads_qspi0_dq_0_i_ival(io_pads_qspi0_dq_0_i_ival   ),
    .io_pads_qspi0_dq_0_o_oval(io_pads_qspi0_dq_0_o_oval   ),
    .io_pads_qspi0_dq_0_o_oe  (io_pads_qspi0_dq_0_o_oe     ),
    .io_pads_qspi0_dq_0_o_ie  (io_pads_qspi0_dq_0_o_ie     ),
    .io_pads_qspi0_dq_0_o_pue (io_pads_qspi0_dq_0_o_pue    ),
    .io_pads_qspi0_dq_0_o_ds  (io_pads_qspi0_dq_0_o_ds     ),
    .io_pads_qspi0_dq_1_i_ival(io_pads_qspi0_dq_1_i_ival   ),
    .io_pads_qspi0_dq_1_o_oval(io_pads_qspi0_dq_1_o_oval   ),
    .io_pads_qspi0_dq_1_o_oe  (io_pads_qspi0_dq_1_o_oe     ),
    .io_pads_qspi0_dq_1_o_ie  (io_pads_qspi0_dq_1_o_ie     ),
    .io_pads_qspi0_dq_1_o_pue (io_pads_qspi0_dq_1_o_pue    ),
    .io_pads_qspi0_dq_1_o_ds  (io_pads_qspi0_dq_1_o_ds     ),
    .io_pads_qspi0_dq_2_i_ival(io_pads_qspi0_dq_2_i_ival   ),
    .io_pads_qspi0_dq_2_o_oval(io_pads_qspi0_dq_2_o_oval   ),
    .io_pads_qspi0_dq_2_o_oe  (io_pads_qspi0_dq_2_o_oe     ),
    .io_pads_qspi0_dq_2_o_ie  (io_pads_qspi0_dq_2_o_ie     ),
    .io_pads_qspi0_dq_2_o_pue (io_pads_qspi0_dq_2_o_pue    ),
    .io_pads_qspi0_dq_2_o_ds  (io_pads_qspi0_dq_2_o_ds     ),
    .io_pads_qspi0_dq_3_i_ival(io_pads_qspi0_dq_3_i_ival   ),
    .io_pads_qspi0_dq_3_o_oval(io_pads_qspi0_dq_3_o_oval   ),
    .io_pads_qspi0_dq_3_o_oe  (io_pads_qspi0_dq_3_o_oe     ),
    .io_pads_qspi0_dq_3_o_ie  (io_pads_qspi0_dq_3_o_ie     ),
    .io_pads_qspi0_dq_3_o_pue (io_pads_qspi0_dq_3_o_pue    ),
    .io_pads_qspi0_dq_3_o_ds  (io_pads_qspi0_dq_3_o_ds     ),
    .io_pads_qspi0_cs_0_i_ival(io_pads_qspi0_cs_0_i_ival   ),
    .io_pads_qspi0_cs_0_o_oval(io_pads_qspi0_cs_0_o_oval   ),
    .io_pads_qspi0_cs_0_o_oe  (io_pads_qspi0_cs_0_o_oe     ),
    .io_pads_qspi0_cs_0_o_ie  (io_pads_qspi0_cs_0_o_ie     ),
    .io_pads_qspi0_cs_0_o_pue (io_pads_qspi0_cs_0_o_pue    ),
    .io_pads_qspi0_cs_0_o_ds  (io_pads_qspi0_cs_0_o_ds     ),
    .io_pads_qspi1_sck_i_ival (io_pads_qspi1_sck_i_ival    ),
    .io_pads_qspi1_sck_o_oval (io_pads_qspi1_sck_o_oval    ),
    .io_pads_qspi1_sck_o_oe   (io_pads_qspi1_sck_o_oe      ),
    .io_pads_qspi1_sck_o_ie   (io_pads_qspi1_sck_o_ie      ),
    .io_pads_qspi1_sck_o_pue  (io_pads_qspi1_sck_o_pue     ),
    .io_pads_qspi1_sck_o_ds   (io_pads_qspi1_sck_o_ds      ),
    .io_pads_qspi1_dq_0_i_ival(io_pads_qspi1_dq_0_i_ival   ),
    .io_pads_qspi1_dq_0_o_oval(io_pads_qspi1_dq_0_o_oval   ),
    .io_pads_qspi1_dq_0_o_oe  (io_pads_qspi1_dq_0_o_oe     ),
    .io_pads_qspi1_dq_0_o_ie  (io_pads_qspi1_dq_0_o_ie     ),
    .io_pads_qspi1_dq_0_o_pue (io_pads_qspi1_dq_0_o_pue    ),
    .io_pads_qspi1_dq_0_o_ds  (io_pads_qspi1_dq_0_o_ds     ),
    .io_pads_qspi1_dq_1_i_ival(io_pads_qspi1_dq_1_i_ival   ),
    .io_pads_qspi1_dq_1_o_oval(io_pads_qspi1_dq_1_o_oval   ),
    .io_pads_qspi1_dq_1_o_oe  (io_pads_qspi1_dq_1_o_oe     ),
    .io_pads_qspi1_dq_1_o_ie  (io_pads_qspi1_dq_1_o_ie     ),
    .io_pads_qspi1_dq_1_o_pue (io_pads_qspi1_dq_1_o_pue    ),
    .io_pads_qspi1_dq_1_o_ds  (io_pads_qspi1_dq_1_o_ds     ),
    .io_pads_qspi1_dq_2_i_ival(io_pads_qspi1_dq_2_i_ival   ),
    .io_pads_qspi1_dq_2_o_oval(io_pads_qspi1_dq_2_o_oval   ),
    .io_pads_qspi1_dq_2_o_oe  (io_pads_qspi1_dq_2_o_oe     ),
    .io_pads_qspi1_dq_2_o_ie  (io_pads_qspi1_dq_2_o_ie     ),
    .io_pads_qspi1_dq_2_o_pue (io_pads_qspi1_dq_2_o_pue    ),
    .io_pads_qspi1_dq_2_o_ds  (io_pads_qspi1_dq_2_o_ds     ),
    .io_pads_qspi1_dq_3_i_ival(io_pads_qspi1_dq_3_i_ival   ),
    .io_pads_qspi1_dq_3_o_oval(io_pads_qspi1_dq_3_o_oval   ),
    .io_pads_qspi1_dq_3_o_oe  (io_pads_qspi1_dq_3_o_oe     ),
    .io_pads_qspi1_dq_3_o_ie  (io_pads_qspi1_dq_3_o_ie     ),
    .io_pads_qspi1_dq_3_o_pue (io_pads_qspi1_dq_3_o_pue    ),
    .io_pads_qspi1_dq_3_o_ds  (io_pads_qspi1_dq_3_o_ds     ),
    .io_pads_qspi1_cs_0_i_ival(io_pads_qspi1_cs_0_i_ival   ),
    .io_pads_qspi1_cs_0_o_oval(io_pads_qspi1_cs_0_o_oval   ),
    .io_pads_qspi1_cs_0_o_oe  (io_pads_qspi1_cs_0_o_oe     ),
    .io_pads_qspi1_cs_0_o_ie  (io_pads_qspi1_cs_0_o_ie     ),
    .io_pads_qspi1_cs_0_o_pue (io_pads_qspi1_cs_0_o_pue    ),
    .io_pads_qspi1_cs_0_o_ds  (io_pads_qspi1_cs_0_o_ds     ),
    .io_pads_qspi1_cs_1_i_ival(io_pads_qspi1_cs_1_i_ival   ),
    .io_pads_qspi1_cs_1_o_oval(io_pads_qspi1_cs_1_o_oval   ),
    .io_pads_qspi1_cs_1_o_oe  (io_pads_qspi1_cs_1_o_oe     ),
    .io_pads_qspi1_cs_1_o_ie  (io_pads_qspi1_cs_1_o_ie     ),
    .io_pads_qspi1_cs_1_o_pue (io_pads_qspi1_cs_1_o_pue    ),
    .io_pads_qspi1_cs_1_o_ds  (io_pads_qspi1_cs_1_o_ds     ),
    .io_pads_qspi1_cs_2_i_ival(io_pads_qspi1_cs_2_i_ival   ),
    .io_pads_qspi1_cs_2_o_oval(io_pads_qspi1_cs_2_o_oval   ),
    .io_pads_qspi1_cs_2_o_oe  (io_pads_qspi1_cs_2_o_oe     ),
    .io_pads_qspi1_cs_2_o_ie  (io_pads_qspi1_cs_2_o_ie     ),
    .io_pads_qspi1_cs_2_o_pue (io_pads_qspi1_cs_2_o_pue    ),
    .io_pads_qspi1_cs_2_o_ds  (io_pads_qspi1_cs_2_o_ds     ),
    .io_pads_qspi1_cs_3_i_ival(io_pads_qspi1_cs_3_i_ival   ),
    .io_pads_qspi1_cs_3_o_oval(io_pads_qspi1_cs_3_o_oval   ),
    .io_pads_qspi1_cs_3_o_oe  (io_pads_qspi1_cs_3_o_oe     ),
    .io_pads_qspi1_cs_3_o_ie  (io_pads_qspi1_cs_3_o_ie     ),
    .io_pads_qspi1_cs_3_o_pue (io_pads_qspi1_cs_3_o_pue    ),
    .io_pads_qspi1_cs_3_o_ds  (io_pads_qspi1_cs_3_o_ds     ),
    .io_pads_qspi2_sck_i_ival (io_pads_qspi2_sck_i_ival    ),
    .io_pads_qspi2_sck_o_oval (io_pads_qspi2_sck_o_oval    ),
    .io_pads_qspi2_sck_o_oe   (io_pads_qspi2_sck_o_oe      ),
    .io_pads_qspi2_sck_o_ie   (io_pads_qspi2_sck_o_ie      ),
    .io_pads_qspi2_sck_o_pue  (io_pads_qspi2_sck_o_pue     ),
    .io_pads_qspi2_sck_o_ds   (io_pads_qspi2_sck_o_ds      ),
    .io_pads_qspi2_dq_0_i_ival(io_pads_qspi2_dq_0_i_ival   ),
    .io_pads_qspi2_dq_0_o_oval(io_pads_qspi2_dq_0_o_oval   ),
    .io_pads_qspi2_dq_0_o_oe  (io_pads_qspi2_dq_0_o_oe     ),
    .io_pads_qspi2_dq_0_o_ie  (io_pads_qspi2_dq_0_o_ie     ),
    .io_pads_qspi2_dq_0_o_pue (io_pads_qspi2_dq_0_o_pue    ),
    .io_pads_qspi2_dq_0_o_ds  (io_pads_qspi2_dq_0_o_ds     ),
    .io_pads_qspi2_dq_1_i_ival(io_pads_qspi2_dq_1_i_ival   ),
    .io_pads_qspi2_dq_1_o_oval(io_pads_qspi2_dq_1_o_oval   ),
    .io_pads_qspi2_dq_1_o_oe  (io_pads_qspi2_dq_1_o_oe     ),
    .io_pads_qspi2_dq_1_o_ie  (io_pads_qspi2_dq_1_o_ie     ),
    .io_pads_qspi2_dq_1_o_pue (io_pads_qspi2_dq_1_o_pue    ),
    .io_pads_qspi2_dq_1_o_ds  (io_pads_qspi2_dq_1_o_ds     ),
    .io_pads_qspi2_dq_2_i_ival(io_pads_qspi2_dq_2_i_ival   ),
    .io_pads_qspi2_dq_2_o_oval(io_pads_qspi2_dq_2_o_oval   ),
    .io_pads_qspi2_dq_2_o_oe  (io_pads_qspi2_dq_2_o_oe     ),
    .io_pads_qspi2_dq_2_o_ie  (io_pads_qspi2_dq_2_o_ie     ),
    .io_pads_qspi2_dq_2_o_pue (io_pads_qspi2_dq_2_o_pue    ),
    .io_pads_qspi2_dq_2_o_ds  (io_pads_qspi2_dq_2_o_ds     ),
    .io_pads_qspi2_dq_3_i_ival(io_pads_qspi2_dq_3_i_ival   ),
    .io_pads_qspi2_dq_3_o_oval(io_pads_qspi2_dq_3_o_oval   ),
    .io_pads_qspi2_dq_3_o_oe  (io_pads_qspi2_dq_3_o_oe     ),
    .io_pads_qspi2_dq_3_o_ie  (io_pads_qspi2_dq_3_o_ie     ),
    .io_pads_qspi2_dq_3_o_pue (io_pads_qspi2_dq_3_o_pue    ),
    .io_pads_qspi2_dq_3_o_ds  (io_pads_qspi2_dq_3_o_ds     ),
    .io_pads_qspi2_cs_0_i_ival(io_pads_qspi2_cs_0_i_ival   ),
    .io_pads_qspi2_cs_0_o_oval(io_pads_qspi2_cs_0_o_oval   ),
    .io_pads_qspi2_cs_0_o_oe  (io_pads_qspi2_cs_0_o_oe     ),
    .io_pads_qspi2_cs_0_o_ie  (io_pads_qspi2_cs_0_o_ie     ),
    .io_pads_qspi2_cs_0_o_pue (io_pads_qspi2_cs_0_o_pue    ),
    .io_pads_qspi2_cs_0_o_ds  (io_pads_qspi2_cs_0_o_ds     ),
    .io_pads_uart0_rxd_i_ival (io_pads_uart0_rxd_i_ival),
    .io_pads_uart0_rxd_o_oval (io_pads_uart0_rxd_o_oval),
    .io_pads_uart0_rxd_o_oe   (io_pads_uart0_rxd_o_oe),
    .io_pads_uart0_rxd_o_ie   (io_pads_uart0_rxd_o_ie),
    .io_pads_uart0_rxd_o_pue  (io_pads_uart0_rxd_o_pue),
    .io_pads_uart0_rxd_o_ds   (io_pads_uart0_rxd_o_ds),
    .io_pads_uart0_txd_i_ival (io_pads_uart0_txd_i_ival),
    .io_pads_uart0_txd_o_oval (io_pads_uart0_txd_o_oval),
    .io_pads_uart0_txd_o_oe   (io_pads_uart0_txd_o_oe),
    .io_pads_uart0_txd_o_ie   (io_pads_uart0_txd_o_ie),
    .io_pads_uart0_txd_o_pue  (io_pads_uart0_txd_o_pue),
    .io_pads_uart0_txd_o_ds   (io_pads_uart0_txd_o_ds),
    .qspi0_irq            (qspi0_irq  ),
    .qspi1_irq            (qspi1_irq  ),
    .qspi2_irq            (qspi2_irq  ),
    .uart0_irq            (uart0_irq  ),
    .misc_irq0           (misc_irq0),
    .misc_irq1           (misc_irq1),
    .udma_irq             (udma_irq),
    .sdio_irq             (sdio_irq),
    .clk                    (clk_bus  ),
    .bus_rst_n              (sys_rst_n), 
    .rst_n                  (sys_rst_n) 
  );
e603_subsys_nice_core  u_subsys_nice_core(
    .nice_rst_n           (sys_rst_n          ),
    .nice_clk             (nice_clk            ),
    .nice_mem_holdup      (nice_mem_holdup     ),
    .nice_active          (nice_active         ),
    .nice_req_valid       (nice_req_valid      ),
    .nice_req_ready       (nice_req_ready      ),
    .nice_req_instr       (nice_req_instr      ),
    .nice_req_rs1         (nice_req_rs1        ),
    .nice_req_rs2         (nice_req_rs2        ),
    .nice_req_mmode       (nice_req_mmode      ),
    .nice_req_smode       (nice_req_smode      ),
    .nice_rsp_1cyc_type       (nice_rsp_1cyc_type      ),
    .nice_rsp_1cyc_dat       (nice_rsp_1cyc_dat      ),	
    .nice_rsp_multicyc_valid       (nice_rsp_multicyc_valid      ),
    .nice_rsp_multicyc_ready       (nice_rsp_multicyc_ready      ),
    .nice_rsp_multicyc_dat        (nice_rsp_multicyc_dat       ),
    .nice_rsp_multicyc_err         (nice_rsp_multicyc_err        ),
    .nice_icb_cmd_valid   (nice_icb_cmd_valid  ),
    .nice_icb_cmd_ready   (nice_icb_cmd_ready  ),
    .nice_icb_cmd_addr    (nice_icb_cmd_addr   ),
    .nice_icb_cmd_read    (nice_icb_cmd_read   ),
    .nice_icb_cmd_wdata   (nice_icb_cmd_wdata  ),
    .nice_icb_cmd_wmask   (nice_icb_cmd_wmask  ),
    .nice_icb_cmd_size    (nice_icb_cmd_size   ),
    .nice_icb_cmd_mmode   (nice_icb_cmd_mmode  ),
    .nice_icb_cmd_smode   (nice_icb_cmd_smode  ),
    .nice_icb_rsp_valid   (nice_icb_rsp_valid  ),
    .nice_icb_rsp_ready   (nice_icb_rsp_ready  ),
    .nice_icb_rsp_rdata   (nice_icb_rsp_rdata  ),
    .nice_icb_rsp_err	  (nice_icb_rsp_err	   )
);
  `ifndef DDR_CONTROLLER
 e603_subsys_axi2sram # (
    .AW                   ( 32 ),
    .DW                   ( 64 ),
    .ID_W                 ( 3 ),
    .USR_W                ( 1   ),
    .DELAY_WIDTH          (9),
    .MW                   ( 64/8 )
) 
 u_subsys_axi2sram
   (
     .axi_arready      (ddr_axi_arready),
     .axi_arvalid      (ddr_axi_arvalid),
     .axi_arid         (ddr_axi_arid),
     .axi_araddr       (ddr_axi_araddr),
     .axi_arlen        (ddr_axi_arlen),
     .axi_arsize       (ddr_axi_arsize),
     .axi_arburst      (ddr_axi_arburst),
     .axi_arlock       (ddr_axi_arlock),
     .axi_arcache      (ddr_axi_arcache),
     .axi_arprot       (ddr_axi_arprot),
     .axi_arqos        (ddr_axi_arqos),
     .axi_arregion     (ddr_axi_arregion),
     .axi_aruser       (ddr_axi_aruser),
     .axi_awready      (ddr_axi_awready),
     .axi_awvalid      (ddr_axi_awvalid),
     .axi_awid         (ddr_axi_awid),
     .axi_awaddr       (ddr_axi_awaddr),
     .axi_awlen        (ddr_axi_awlen),
     .axi_awsize       (ddr_axi_awsize),
     .axi_awburst      (ddr_axi_awburst),
     .axi_awlock       (ddr_axi_awlock),
     .axi_awcache      (ddr_axi_awcache),
     .axi_awprot       (ddr_axi_awprot),
     .axi_awqos        (ddr_axi_awqos),
     .axi_awregion     (ddr_axi_awregion),
     .axi_awuser       (ddr_axi_awuser),  
     .axi_wready       (ddr_axi_wready),
     .axi_wvalid       (ddr_axi_wvalid),
     .axi_wid          (ddr_axi_wid),
     .axi_wdata        (ddr_axi_wdata),
     .axi_wstrb        (ddr_axi_wstrb),
     .axi_wlast        (ddr_axi_wlast),
     .axi_rready       (ddr_axi_rready),
     .axi_rvalid       (ddr_axi_rvalid),
     .axi_rid          (ddr_axi_rid),
     .axi_rdata        (ddr_axi_rdata),
     .axi_rresp        (ddr_axi_rresp),
     .axi_rlast        (ddr_axi_rlast),
     .axi_bready       (ddr_axi_bready),
     .axi_bvalid       (ddr_axi_bvalid),
     .axi_bid          (ddr_axi_bid),
     .axi_bresp        (ddr_axi_bresp),
     .delay_select     (mem_delay_select),
     .clk              (sys_clk),
     .rst_n            (sys_rst_n)
  );
 `endif
  `ifdef DDR3_CONTROLLER
    e603_ddr3_wrapper  u_ddr3_wrapper(
       .ddr3_addr                      (ddr3_addr),
       .ddr3_ba                        (ddr3_ba),
       .ddr3_cas_n                     (ddr3_cas_n),
       .ddr3_ck_n                      (ddr3_ck_n),
       .ddr3_ck_p                      (ddr3_ck_p),
       .ddr3_cke                       (ddr3_cke),
       .ddr3_ras_n                     (ddr3_ras_n),
       .ddr3_we_n                      (ddr3_we_n),
       .ddr3_dq                        (ddr3_dq),
       .ddr3_dqs_n                     (ddr3_dqs_n),
       .ddr3_dqs_p                     (ddr3_dqs_p),
       .ddr3_reset_n                   (ddr3_reset_n),
       .init_calib_complete            (init_calib_complete),
       .ddr3_cs_n                      (ddr3_cs_n),
       .ddr3_dm                        (ddr3_dm),
       .ddr3_odt                       (ddr3_odt),
       .axi_wo_awid                     (ddr_axi_awid),
       .axi_wo_awaddr                   (ddr_axi_awaddr),
       .axi_wo_awlen                    (ddr_axi_awlen),
       .axi_wo_awsize                   (ddr_axi_awsize),
       .axi_wo_awburst                  (ddr_axi_awburst),
       .axi_wo_awlock                   (ddr_axi_awlock),
       .axi_wo_awcache                  (ddr_axi_awcache),
       .axi_wo_awprot                   (ddr_axi_awprot),
       .axi_wo_awvalid                  (ddr_axi_awvalid),
       .axi_wo_awready                  (ddr_axi_awready),
       .axi_wo_wdata                    (ddr_axi_wdata),
       .axi_wo_wstrb                    (ddr_axi_wstrb),
       .axi_wo_wlast                    (ddr_axi_wlast),
       .axi_wo_wvalid                   (ddr_axi_wvalid),
       .axi_wo_wready                   (ddr_axi_wready),
       .axi_wo_bid                      (ddr_axi_bid),
       .axi_wo_bresp                    (ddr_axi_bresp),
       .axi_wo_bvalid                   (ddr_axi_bvalid),
       .axi_wo_bready                   (ddr_axi_bready),
       .axi_ro_arid                     (ddr_axi_arid),
       .axi_ro_araddr                   (ddr_axi_araddr),
       .axi_ro_arlen                    (ddr_axi_arlen),
       .axi_ro_arsize                   (ddr_axi_arsize),
       .axi_ro_arburst                  (ddr_axi_arburst),
       .axi_ro_arlock                   (ddr_axi_arlock),
       .axi_ro_arcache                  (ddr_axi_arcache),
       .axi_ro_arprot                   (ddr_axi_arprot),
       .axi_ro_arvalid                  (ddr_axi_arvalid),
       .axi_ro_arready                  (ddr_axi_arready),
       .axi_ro_rid                      (ddr_axi_rid),
       .axi_ro_rdata                    (ddr_axi_rdata),
       .axi_ro_rresp                    (ddr_axi_rresp),
       .axi_ro_rlast                    (ddr_axi_rlast),
       .axi_ro_rvalid                   (ddr_axi_rvalid),
       .axi_ro_rready                   (ddr_axi_rready),
       .axi_ro_arqos                    (4'h0), 
       .axi_wo_awqos                    (4'h0),        
       .ddr3_sys_clk_i                  (ddr3_sys_clk_i),
       .ddr3_sys_rst_i                  (ddr3_sys_rst_i),
       .sys_clk                         (sys_clk),
       .sys_rst_n                       (sys_rst_n)
       );
    `endif
    `ifdef DDR4_CONTROLLER
    `ifdef BOARD_VCU118
    e603_vcu118_ddr4_wrapper #(.AXI_ASYNC_FIFO(0)) u_ddr4_wrapper(
    `elsif BOARD_VU440_S2C
    e603_vu440_s2c_ddr4_wrapper #(.AXI_ASYNC_FIFO(0)) u_ddr4_wrapper(
    `else
    e603_ku060_ddr4_wrapper #(.AXI_ASYNC_FIFO(0))  u_ddr4_wrapper(
    `endif
       .ddr4_sys_clk_i              (ddr4_sys_clk_i),
       .ddr4_sys_rst_i              (ddr4_sys_rst_i),
       .ddr4_act_n                  (c0_ddr4_act_n),
       .ddr4_adr                    (c0_ddr4_adr),
       .ddr4_ba                     (c0_ddr4_ba),
       .ddr4_bg                     (c0_ddr4_bg),
       .ddr4_cke                    (c0_ddr4_cke),
       .ddr4_odt                    (c0_ddr4_odt),
       .ddr4_cs_n                   (c0_ddr4_cs_n),
       .ddr4_ck_t                   (c0_ddr4_ck_t),
       .ddr4_ck_c                   (c0_ddr4_ck_c),
       .ddr4_dm_dbi_n               (c0_ddr4_dm_dbi_n),
       .ddr4_dq                     (c0_ddr4_dq),
       .ddr4_dqs_c                  (c0_ddr4_dqs_c),
       .ddr4_dqs_t                  (c0_ddr4_dqs_t),
       .ddr4_reset_n                (c0_ddr4_reset_n),
       .init_calib_complete         (init_calib_complete),
       .sys_clk                     (sys_clk),
       .sys_rst_n                   (sys_rst_n),
       .ui_clk                      (ui_clk           ),
       .ui_clk_sync_rst_n           (ui_clk_sync_rst_n),
       .axi_wo_awid                 (ddr_axi_awid),
       .axi_wo_awaddr               (ddr_axi_awaddr),
       .axi_wo_awlen                (ddr_axi_awlen),
       .axi_wo_awsize               (ddr_axi_awsize),
       .axi_wo_awburst              (ddr_axi_awburst),
       .axi_wo_awlock               (ddr_axi_awlock),
       .axi_wo_awcache              (ddr_axi_awcache),
       .axi_wo_awprot               (ddr_axi_awprot),
       .axi_wo_awqos                (ddr_axi_awqos),
       .axi_wo_awvalid              (ddr_axi_awvalid),
       .axi_wo_awready              (ddr_axi_awready),
       .axi_wo_wdata                (ddr_axi_wdata),
       .axi_wo_wstrb                (ddr_axi_wstrb),
       .axi_wo_wlast                (ddr_axi_wlast),
       .axi_wo_wvalid               (ddr_axi_wvalid),
       .axi_wo_wready               (ddr_axi_wready),
       .axi_wo_wid                  (ddr_axi_wid),
       .axi_wo_bid                  (ddr_axi_bid),
       .axi_wo_bresp                (ddr_axi_bresp),
       .axi_wo_bvalid               (ddr_axi_bvalid),
       .axi_wo_bready               (ddr_axi_bready),
       .axi_ro_arid                 (ddr_axi_arid),
       .axi_ro_araddr               (ddr_axi_araddr),
       .axi_ro_arlen                (ddr_axi_arlen),
       .axi_ro_arsize               (ddr_axi_arsize),
       .axi_ro_arburst              (ddr_axi_arburst),
       .axi_ro_arlock               (ddr_axi_arlock),
       .axi_ro_arcache              (ddr_axi_arcache),
       .axi_ro_arprot               (ddr_axi_arprot),
       .axi_ro_arqos                (ddr_axi_arqos),
       .axi_ro_arvalid              (ddr_axi_arvalid),
       .axi_ro_arready              (ddr_axi_arready),
       .axi_ro_rid                  (ddr_axi_rid),
       .axi_ro_rdata                (ddr_axi_rdata),
       .axi_ro_rresp                (ddr_axi_rresp),
       .axi_ro_rlast                (ddr_axi_rlast),
       .axi_ro_rvalid               (ddr_axi_rvalid),
       .axi_ro_rready               (ddr_axi_rready)
       );
    `endif
endmodule
