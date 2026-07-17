 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_subsys_misc(
  input                      icb_cmd_valid, 
  output                     icb_cmd_ready, 
  input  [12-1:0] icb_cmd_addr, 
  input                      icb_cmd_read, 
  input  [32-1:0]    icb_cmd_wdata, 
  output                     icb_rsp_valid, 
  input                      icb_rsp_ready, 
  output [32-1:0]    icb_rsp_rdata,
  output  misc_irq0,
  output  misc_irq1,
   output misc_nmi,
   output misc_evt,
   output[3:0] iocp_arcache,
   output[3:0] iocp_awcache,
   output[27:0] iocp_ar_hi_addr,
   output[27:0] iocp_aw_hi_addr,
 output misc_dbg_secure_enable,
 output misc_dbg_isolate,
 output misc_dbg_override_dm_sleep,
 output misc_dbg_stop_at_boot,
 output misc_dbg_i_dbg_stop,
  output [9-1:0] mem_delay_select,
  output          misc_sdio_enable,
  input           clk,
  input           rst_n 
);
  wire icb_cmd_hsked    = icb_cmd_valid & icb_cmd_ready;
  wire icb_cmd_wr_hsked = icb_cmd_hsked & (~icb_cmd_read); 
  wire icb_cmd_rd_hsked = icb_cmd_hsked & icb_cmd_read; 
  localparam MISC0_OFST = 12'd0;
  wire icb_cmd_sel_misc0 = (icb_cmd_addr[12-1:0] == MISC0_OFST);
  localparam MISC1_OFST = 12'd4;
  wire icb_cmd_sel_misc1 = (icb_cmd_addr[12-1:0] == MISC1_OFST);
  localparam MISC_IOCP_R_OFST = 12'h20;
  localparam MISC_IOCP_W_OFST = 12'h24;
  localparam MISC_VLM_CTRL_OFST = 12'h28;
  localparam MISC_MEM_DELAY_OFST = 12'h2C;
  localparam MISC_NMI_OFST = 12'h100;
  localparam MISC_EVT_OFST = 12'h104;
  localparam MISC_DEBUG_OFST = 12'h108;
  localparam MISC_CTRL_OFST = 12'h10C;
  localparam MISC_VERSION_OFST = 12'hf00;
  wire icb_cmd_sel_version    = (icb_cmd_addr[12-1:0] == MISC_VERSION_OFST);
  wire icb_cmd_sel_nmi        = (icb_cmd_addr[12-1:0] == MISC_NMI_OFST);
  wire icb_cmd_sel_evt        = (icb_cmd_addr[12-1:0] == MISC_EVT_OFST);
  wire icb_cmd_sel_misc_debug = (icb_cmd_addr[12-1:0] == MISC_DEBUG_OFST);
  wire icb_cmd_sel_misc_ctrl  = (icb_cmd_addr[12-1:0] == MISC_CTRL_OFST);
  wire icb_cmd_sel_iocp_r     = (icb_cmd_addr[12-1:0] == MISC_IOCP_R_OFST);
  wire icb_cmd_sel_iocp_w     = (icb_cmd_addr[12-1:0] == MISC_IOCP_W_OFST);
  wire icb_cmd_sel_vlm_ctrl   = (icb_cmd_addr[12-1:0] == MISC_VLM_CTRL_OFST);
  wire icb_cmd_sel_mem_delay  = (icb_cmd_addr[12-1:0] == MISC_MEM_DELAY_OFST);
  wire [31:0] misc_version_reg = 32'h00_01_04_00;
  wire [32-1:0] misc0_cnt_r;
  wire misc0_cnt0 =  (misc0_cnt_r == 32'b0);
  wire misc0_cnt_set = icb_cmd_wr_hsked & icb_cmd_sel_misc0;
  wire misc0_cnt_dec = (~misc0_cnt0) & (~(&misc0_cnt_r));
  wire misc0_cnt_ena = misc0_cnt_set | misc0_cnt_dec;
  wire [32-1:0] misc0_cnt_nxt = 
                                   misc0_cnt_set ? icb_cmd_wdata[32-1:0] 
                                 : misc0_cnt_dec ? (misc0_cnt_r - {{32-1{1'b0}},1'b1})
                                 : misc0_cnt_r;
e603_gnrl_dfflrs #(32) misc0_cnt_dfflr                 (misc0_cnt_ena, misc0_cnt_nxt, misc0_cnt_r, clk, rst_n);// VPP_NO_REG_PARSE
   assign misc_irq0 = misc0_cnt0;
  wire [32-1:0] misc1_cnt_r;
  wire misc1_cnt0 =  (misc1_cnt_r == 32'b0);
  wire misc1_cnt_set = icb_cmd_wr_hsked & icb_cmd_sel_misc1;
  wire misc1_cnt_dec = (~misc1_cnt0) & (~(&misc1_cnt_r));
  wire misc1_cnt_ena = misc1_cnt_set | misc1_cnt_dec;
  wire [32-1:0] misc1_cnt_nxt = 
                                   misc1_cnt_set ? icb_cmd_wdata[32-1:0] 
                                 : misc1_cnt_dec ? (misc1_cnt_r - {{32-1{1'b0}},1'b1})
                                 : misc1_cnt_r;
e603_gnrl_dfflrs #(32) misc1_cnt_dfflr                 (misc1_cnt_ena, misc1_cnt_nxt, misc1_cnt_r, clk, rst_n);// VPP_NO_REG_PARSE
   assign misc_irq1 = misc1_cnt0;
  wire [32-1:0] nmi_cnt_r;
  wire nmi_cnt0 =  (nmi_cnt_r == 32'b0);
  wire nmi_cnt_set = icb_cmd_wr_hsked & icb_cmd_sel_nmi;
  wire nmi_cnt_dec = (~nmi_cnt0) & (~(&nmi_cnt_r));
  wire nmi_cnt_ena = nmi_cnt_set | nmi_cnt_dec;
  wire [32-1:0] nmi_cnt_nxt = 
                                   nmi_cnt_set ? icb_cmd_wdata[32-1:0] 
                                 : nmi_cnt_dec ? (nmi_cnt_r - {{32-1{1'b0}},1'b1})
                                 : nmi_cnt_r;
e603_gnrl_dfflrs #(32) nmi_cnt_dfflr  (nmi_cnt_ena, nmi_cnt_nxt, nmi_cnt_r, clk, rst_n);// VPP_NO_REG_PARSE
   assign misc_nmi = nmi_cnt0;
  wire [32-1:0] evt_cnt_r;
  wire evt_cnt0 =  (evt_cnt_r == 32'b0);
  wire evt_cnt_set = icb_cmd_wr_hsked & icb_cmd_sel_evt;
  wire evt_cnt_dec = (~evt_cnt0) & (~(&evt_cnt_r));
  wire evt_cnt_ena = evt_cnt_set | evt_cnt_dec;
  wire [32-1:0] evt_cnt_nxt = 
                                   evt_cnt_set ? icb_cmd_wdata[32-1:0] 
                                 : evt_cnt_dec ? (evt_cnt_r - {{32-1{1'b0}},1'b1})
                                 : evt_cnt_r;
e603_gnrl_dfflrs #(32) evt_cnt_dfflr  (evt_cnt_ena, evt_cnt_nxt, evt_cnt_r, clk, rst_n);// VPP_NO_REG_PARSE
   assign misc_evt = evt_cnt0;
  wire [32-1:0] misc_debug_r;
  wire misc_debug_ena = icb_cmd_wr_hsked & icb_cmd_sel_misc_debug;
  wire [32-1:0] misc_debug_nxt = icb_cmd_wdata[32-1:0];
e603_gnrl_dfflrs  #(1) misc_debug_secure_enable_dfflrs (misc_debug_ena, misc_debug_nxt[0], misc_debug_r[0], clk, rst_n);// VPP_NO_REG_PARSE
e603_gnrl_dfflr  #(31) misc_debug_dfflr (misc_debug_ena, misc_debug_nxt[31:1], misc_debug_r[31:1], clk, rst_n);// VPP_NO_REG_PARSE
   assign misc_dbg_secure_enable = misc_debug_r[0];
   assign misc_dbg_isolate = misc_debug_r[1];
   assign misc_dbg_override_dm_sleep = misc_debug_r[2];
   assign misc_dbg_stop_at_boot = misc_debug_r[3];
   assign misc_dbg_i_dbg_stop = misc_debug_r[4];
  wire [32-1:0] misc_ctrl_r;
  wire misc_ctrl_ena = icb_cmd_wr_hsked & icb_cmd_sel_misc_ctrl;
  wire [32-1:0] misc_ctrl_nxt = icb_cmd_wdata[32-1:0];
e603_gnrl_dfflr  #(1) misc_ctrl_dfflr (misc_ctrl_ena, misc_ctrl_nxt[0], misc_ctrl_r[0], clk, rst_n);// VPP_NO_REG_PARSE
   assign misc_sdio_enable = misc_ctrl_r[0];
   assign misc_ctrl_r[31:1] = 31'b0;
   wire [32-1:0] iocp_r_ctrl; 
   wire iocp_r_ctrl_ena = icb_cmd_wr_hsked & icb_cmd_sel_iocp_r;
   wire [32-1:0] iocp_r_ctrl_nxt = icb_cmd_wdata[32-1:0];
e603_gnrl_dfflr #(32) iocp_r_ctrl_dfflr (iocp_r_ctrl_ena, iocp_r_ctrl_nxt, iocp_r_ctrl, clk, rst_n);// VPP_NO_REG_PARSE
   assign iocp_arcache = iocp_r_ctrl[3:0];
   assign iocp_ar_hi_addr = iocp_r_ctrl[31:4];
   wire [32-1:0] iocp_w_ctrl; 
   wire iocp_w_ctrl_ena = icb_cmd_wr_hsked & icb_cmd_sel_iocp_w;
   wire [32-1:0] iocp_w_ctrl_nxt = icb_cmd_wdata[32-1:0];
e603_gnrl_dfflr #(32) iocp_w_ctrl_dfflr (iocp_w_ctrl_ena, iocp_w_ctrl_nxt, iocp_w_ctrl, clk, rst_n);// VPP_NO_REG_PARSE
   assign iocp_awcache = iocp_w_ctrl[3:0];
   assign iocp_aw_hi_addr = iocp_w_ctrl[31:4];
   wire [32-1:0] mem_delay; 
   wire mem_delay_ena = icb_cmd_wr_hsked & icb_cmd_sel_mem_delay;
   wire [32-1:0] mem_delay_nxt;
   assign mem_delay_nxt[31:0] = icb_cmd_wdata[31:0];
e603_gnrl_dfflr #(32) mem_delay_dfflr (mem_delay_ena, mem_delay_nxt, mem_delay, clk, rst_n);// VPP_NO_REG_PARSE
   assign mem_delay_select = mem_delay[9-1:0];
   wire [32-1:0] rsp_rdata = 32'b0 
                           | {32{icb_cmd_sel_version}} & misc_version_reg
                           | ({32{icb_cmd_sel_misc0}} & misc0_cnt_r)
                           | ({32{icb_cmd_sel_misc1}} & misc1_cnt_r)
                           | ({32{icb_cmd_sel_nmi}} & nmi_cnt_r)
                           | ({32{icb_cmd_sel_evt}} & evt_cnt_r)
                           | ({32{icb_cmd_sel_misc_debug}} & misc_debug_r)
                           | ({32{icb_cmd_sel_iocp_r}} & iocp_r_ctrl)
                           | ({32{icb_cmd_sel_iocp_w}} & iocp_w_ctrl)
                           | ({32{icb_cmd_sel_mem_delay}} & mem_delay)
                           | ({32{icb_cmd_sel_misc_ctrl}} & misc_ctrl_r)
                          ;
  assign icb_rsp_valid = icb_cmd_valid;
  assign icb_cmd_ready = icb_rsp_ready;
  assign icb_rsp_rdata = rsp_rdata;
endmodule
