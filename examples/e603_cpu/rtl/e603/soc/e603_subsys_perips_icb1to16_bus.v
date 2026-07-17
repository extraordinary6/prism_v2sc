 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_subsys_perips_ficb1ton_bus #(
  parameter I_SUPPORT_RATIO = 0, 
  parameter O_SUPPORT_RATIO = 0,
  parameter ALLOW_DIFF =0,
  parameter ALLOW_0CYCL_RSP =0,
  parameter ICB_FIFO_CMD_BYPBUF = 0,
  parameter ICB_FIFO_CMD_DP = 0, 
  parameter ICB_FIFO_RSP_DP = 0, 
  parameter ICB_FIFO_CMD_CUT_READY = 1, 
  parameter ICB_FIFO_RSP_CUT_READY = 1, 
  parameter O0_BASE_ADDR       = 32'h0,       
  parameter O0_BASE_REGION_LSB = 12,
  parameter O1_BASE_ADDR       = 32'h0,       
  parameter O1_BASE_REGION_LSB = 12,
  parameter O2_BASE_ADDR       = 32'h0,       
  parameter O2_BASE_REGION_LSB = 12,
  parameter O3_BASE_ADDR       = 32'h0,       
  parameter O3_BASE_REGION_LSB = 12,
  parameter O4_BASE_ADDR       = 32'h0,       
  parameter O4_BASE_REGION_LSB = 12,
  parameter O5_BASE_ADDR       = 32'h0,       
  parameter O5_BASE_REGION_LSB = 12,
  parameter O6_BASE_ADDR       = 32'h0,       
  parameter O6_BASE_REGION_LSB = 12,
  parameter O7_BASE_ADDR       = 32'h0,       
  parameter O7_BASE_REGION_LSB = 12,
  parameter O8_BASE_ADDR       = 32'h0,       
  parameter O8_BASE_REGION_LSB = 12,
  parameter O9_BASE_ADDR       = 32'h0,       
  parameter O9_BASE_REGION_LSB = 12,
  parameter O10_BASE_ADDR       = 32'h0,       
  parameter O10_BASE_REGION_LSB = 12,
  parameter O11_BASE_ADDR       = 32'h0,       
  parameter O11_BASE_REGION_LSB = 12,
  parameter O12_BASE_ADDR       = 32'h0,       
  parameter O12_BASE_REGION_LSB = 12,
  parameter O13_BASE_ADDR       = 32'h0,       
  parameter O13_BASE_REGION_LSB = 12,
  parameter O14_BASE_ADDR       = 32'h0,       
  parameter O14_BASE_REGION_LSB = 12,
  parameter O15_BASE_ADDR       = 32'h0,       
  parameter O15_BASE_REGION_LSB = 12,
  parameter PAYLOAD_NORST    = 0,
  parameter SPLT_FIFO_OUTS_NUM    = 1,
  parameter SPLT_FIFO_OUTS_CNT_W  = 1,
  parameter SPLT_FIFO_CUT_READY   = 1 
)(
  input i_clk_en,
  input o_clk_en,
  output  icb1ton_active,
    input              i_icb_cmd_valid               ,
  output             i_icb_cmd_ready               ,
  input              i_icb_cmd_sel                 ,
  input              i_icb_cmd_read                ,
  input  [  31:   0] i_icb_cmd_addr                ,
  input  [  31:   0] i_icb_cmd_wdata               ,
  input  [   3:   0] i_icb_cmd_wmask               ,
  input  [   2:   0] i_icb_cmd_size                ,
  input              i_icb_cmd_lock                ,
  input              i_icb_cmd_excl                ,
  input  [   7:   0] i_icb_cmd_xlen                ,
  input  [   1:   0] i_icb_cmd_xburst              ,
  input  [   1:   0] i_icb_cmd_modes               ,
  input              i_icb_cmd_dmode               ,
  input  [   2:   0] i_icb_cmd_attri               ,
  input  [   1:   0] i_icb_cmd_beat                ,
  input              i_icb_cmd_usr                 ,
  input              i_icb_rsp_ready               ,
  output             i_icb_rsp_valid               ,
  output             i_icb_rsp_err                 ,
  output             i_icb_rsp_excl_ok             ,
  output [  31:   0] i_icb_rsp_rdata               ,
  output             i_icb_rsp_usr                 ,
  input                          o0_icb_enable,
    output             o0_icb_cmd_valid              ,
  input              o0_icb_cmd_ready              ,
  output             o0_icb_cmd_sel                ,
  output             o0_icb_cmd_read               ,
  output [  31:   0] o0_icb_cmd_addr               ,
  output [  31:   0] o0_icb_cmd_wdata              ,
  output [   3:   0] o0_icb_cmd_wmask              ,
  output [   2:   0] o0_icb_cmd_size               ,
  output             o0_icb_cmd_lock               ,
  output             o0_icb_cmd_excl               ,
  output [   7:   0] o0_icb_cmd_xlen               ,
  output [   1:   0] o0_icb_cmd_xburst             ,
  output [   1:   0] o0_icb_cmd_modes              ,
  output             o0_icb_cmd_dmode              ,
  output [   2:   0] o0_icb_cmd_attri              ,
  output [   1:   0] o0_icb_cmd_beat               ,
  output             o0_icb_cmd_usr                ,
  output             o0_icb_rsp_ready              ,
  input              o0_icb_rsp_valid              ,
  input              o0_icb_rsp_err                ,
  input              o0_icb_rsp_excl_ok            ,
  input  [  31:   0] o0_icb_rsp_rdata              ,
  input              o0_icb_rsp_usr                ,
  input                          o1_icb_enable,
    output             o1_icb_cmd_valid              ,
  input              o1_icb_cmd_ready              ,
  output             o1_icb_cmd_sel                ,
  output             o1_icb_cmd_read               ,
  output [  31:   0] o1_icb_cmd_addr               ,
  output [  31:   0] o1_icb_cmd_wdata              ,
  output [   3:   0] o1_icb_cmd_wmask              ,
  output [   2:   0] o1_icb_cmd_size               ,
  output             o1_icb_cmd_lock               ,
  output             o1_icb_cmd_excl               ,
  output [   7:   0] o1_icb_cmd_xlen               ,
  output [   1:   0] o1_icb_cmd_xburst             ,
  output [   1:   0] o1_icb_cmd_modes              ,
  output             o1_icb_cmd_dmode              ,
  output [   2:   0] o1_icb_cmd_attri              ,
  output [   1:   0] o1_icb_cmd_beat               ,
  output             o1_icb_cmd_usr                ,
  output             o1_icb_rsp_ready              ,
  input              o1_icb_rsp_valid              ,
  input              o1_icb_rsp_err                ,
  input              o1_icb_rsp_excl_ok            ,
  input  [  31:   0] o1_icb_rsp_rdata              ,
  input              o1_icb_rsp_usr                ,
  input                          o2_icb_enable,
    output             o2_icb_cmd_valid              ,
  input              o2_icb_cmd_ready              ,
  output             o2_icb_cmd_sel                ,
  output             o2_icb_cmd_read               ,
  output [  31:   0] o2_icb_cmd_addr               ,
  output [  31:   0] o2_icb_cmd_wdata              ,
  output [   3:   0] o2_icb_cmd_wmask              ,
  output [   2:   0] o2_icb_cmd_size               ,
  output             o2_icb_cmd_lock               ,
  output             o2_icb_cmd_excl               ,
  output [   7:   0] o2_icb_cmd_xlen               ,
  output [   1:   0] o2_icb_cmd_xburst             ,
  output [   1:   0] o2_icb_cmd_modes              ,
  output             o2_icb_cmd_dmode              ,
  output [   2:   0] o2_icb_cmd_attri              ,
  output [   1:   0] o2_icb_cmd_beat               ,
  output             o2_icb_cmd_usr                ,
  output             o2_icb_rsp_ready              ,
  input              o2_icb_rsp_valid              ,
  input              o2_icb_rsp_err                ,
  input              o2_icb_rsp_excl_ok            ,
  input  [  31:   0] o2_icb_rsp_rdata              ,
  input              o2_icb_rsp_usr                ,
  input                          o3_icb_enable,
    output             o3_icb_cmd_valid              ,
  input              o3_icb_cmd_ready              ,
  output             o3_icb_cmd_sel                ,
  output             o3_icb_cmd_read               ,
  output [  31:   0] o3_icb_cmd_addr               ,
  output [  31:   0] o3_icb_cmd_wdata              ,
  output [   3:   0] o3_icb_cmd_wmask              ,
  output [   2:   0] o3_icb_cmd_size               ,
  output             o3_icb_cmd_lock               ,
  output             o3_icb_cmd_excl               ,
  output [   7:   0] o3_icb_cmd_xlen               ,
  output [   1:   0] o3_icb_cmd_xburst             ,
  output [   1:   0] o3_icb_cmd_modes              ,
  output             o3_icb_cmd_dmode              ,
  output [   2:   0] o3_icb_cmd_attri              ,
  output [   1:   0] o3_icb_cmd_beat               ,
  output             o3_icb_cmd_usr                ,
  output             o3_icb_rsp_ready              ,
  input              o3_icb_rsp_valid              ,
  input              o3_icb_rsp_err                ,
  input              o3_icb_rsp_excl_ok            ,
  input  [  31:   0] o3_icb_rsp_rdata              ,
  input              o3_icb_rsp_usr                ,
  input                          o4_icb_enable,
    output             o4_icb_cmd_valid              ,
  input              o4_icb_cmd_ready              ,
  output             o4_icb_cmd_sel                ,
  output             o4_icb_cmd_read               ,
  output [  31:   0] o4_icb_cmd_addr               ,
  output [  31:   0] o4_icb_cmd_wdata              ,
  output [   3:   0] o4_icb_cmd_wmask              ,
  output [   2:   0] o4_icb_cmd_size               ,
  output             o4_icb_cmd_lock               ,
  output             o4_icb_cmd_excl               ,
  output [   7:   0] o4_icb_cmd_xlen               ,
  output [   1:   0] o4_icb_cmd_xburst             ,
  output [   1:   0] o4_icb_cmd_modes              ,
  output             o4_icb_cmd_dmode              ,
  output [   2:   0] o4_icb_cmd_attri              ,
  output [   1:   0] o4_icb_cmd_beat               ,
  output             o4_icb_cmd_usr                ,
  output             o4_icb_rsp_ready              ,
  input              o4_icb_rsp_valid              ,
  input              o4_icb_rsp_err                ,
  input              o4_icb_rsp_excl_ok            ,
  input  [  31:   0] o4_icb_rsp_rdata              ,
  input              o4_icb_rsp_usr                ,
  input                          o5_icb_enable,
    output             o5_icb_cmd_valid              ,
  input              o5_icb_cmd_ready              ,
  output             o5_icb_cmd_sel                ,
  output             o5_icb_cmd_read               ,
  output [  31:   0] o5_icb_cmd_addr               ,
  output [  31:   0] o5_icb_cmd_wdata              ,
  output [   3:   0] o5_icb_cmd_wmask              ,
  output [   2:   0] o5_icb_cmd_size               ,
  output             o5_icb_cmd_lock               ,
  output             o5_icb_cmd_excl               ,
  output [   7:   0] o5_icb_cmd_xlen               ,
  output [   1:   0] o5_icb_cmd_xburst             ,
  output [   1:   0] o5_icb_cmd_modes              ,
  output             o5_icb_cmd_dmode              ,
  output [   2:   0] o5_icb_cmd_attri              ,
  output [   1:   0] o5_icb_cmd_beat               ,
  output             o5_icb_cmd_usr                ,
  output             o5_icb_rsp_ready              ,
  input              o5_icb_rsp_valid              ,
  input              o5_icb_rsp_err                ,
  input              o5_icb_rsp_excl_ok            ,
  input  [  31:   0] o5_icb_rsp_rdata              ,
  input              o5_icb_rsp_usr                ,
  input                          o6_icb_enable,
    output             o6_icb_cmd_valid              ,
  input              o6_icb_cmd_ready              ,
  output             o6_icb_cmd_sel                ,
  output             o6_icb_cmd_read               ,
  output [  31:   0] o6_icb_cmd_addr               ,
  output [  31:   0] o6_icb_cmd_wdata              ,
  output [   3:   0] o6_icb_cmd_wmask              ,
  output [   2:   0] o6_icb_cmd_size               ,
  output             o6_icb_cmd_lock               ,
  output             o6_icb_cmd_excl               ,
  output [   7:   0] o6_icb_cmd_xlen               ,
  output [   1:   0] o6_icb_cmd_xburst             ,
  output [   1:   0] o6_icb_cmd_modes              ,
  output             o6_icb_cmd_dmode              ,
  output [   2:   0] o6_icb_cmd_attri              ,
  output [   1:   0] o6_icb_cmd_beat               ,
  output             o6_icb_cmd_usr                ,
  output             o6_icb_rsp_ready              ,
  input              o6_icb_rsp_valid              ,
  input              o6_icb_rsp_err                ,
  input              o6_icb_rsp_excl_ok            ,
  input  [  31:   0] o6_icb_rsp_rdata              ,
  input              o6_icb_rsp_usr                ,
  input                          o7_icb_enable,
    output             o7_icb_cmd_valid              ,
  input              o7_icb_cmd_ready              ,
  output             o7_icb_cmd_sel                ,
  output             o7_icb_cmd_read               ,
  output [  31:   0] o7_icb_cmd_addr               ,
  output [  31:   0] o7_icb_cmd_wdata              ,
  output [   3:   0] o7_icb_cmd_wmask              ,
  output [   2:   0] o7_icb_cmd_size               ,
  output             o7_icb_cmd_lock               ,
  output             o7_icb_cmd_excl               ,
  output [   7:   0] o7_icb_cmd_xlen               ,
  output [   1:   0] o7_icb_cmd_xburst             ,
  output [   1:   0] o7_icb_cmd_modes              ,
  output             o7_icb_cmd_dmode              ,
  output [   2:   0] o7_icb_cmd_attri              ,
  output [   1:   0] o7_icb_cmd_beat               ,
  output             o7_icb_cmd_usr                ,
  output             o7_icb_rsp_ready              ,
  input              o7_icb_rsp_valid              ,
  input              o7_icb_rsp_err                ,
  input              o7_icb_rsp_excl_ok            ,
  input  [  31:   0] o7_icb_rsp_rdata              ,
  input              o7_icb_rsp_usr                ,
  input                          o8_icb_enable,
    output             o8_icb_cmd_valid              ,
  input              o8_icb_cmd_ready              ,
  output             o8_icb_cmd_sel                ,
  output             o8_icb_cmd_read               ,
  output [  31:   0] o8_icb_cmd_addr               ,
  output [  31:   0] o8_icb_cmd_wdata              ,
  output [   3:   0] o8_icb_cmd_wmask              ,
  output [   2:   0] o8_icb_cmd_size               ,
  output             o8_icb_cmd_lock               ,
  output             o8_icb_cmd_excl               ,
  output [   7:   0] o8_icb_cmd_xlen               ,
  output [   1:   0] o8_icb_cmd_xburst             ,
  output [   1:   0] o8_icb_cmd_modes              ,
  output             o8_icb_cmd_dmode              ,
  output [   2:   0] o8_icb_cmd_attri              ,
  output [   1:   0] o8_icb_cmd_beat               ,
  output             o8_icb_cmd_usr                ,
  output             o8_icb_rsp_ready              ,
  input              o8_icb_rsp_valid              ,
  input              o8_icb_rsp_err                ,
  input              o8_icb_rsp_excl_ok            ,
  input  [  31:   0] o8_icb_rsp_rdata              ,
  input              o8_icb_rsp_usr                ,
  input                          o9_icb_enable,
    output             o9_icb_cmd_valid              ,
  input              o9_icb_cmd_ready              ,
  output             o9_icb_cmd_sel                ,
  output             o9_icb_cmd_read               ,
  output [  31:   0] o9_icb_cmd_addr               ,
  output [  31:   0] o9_icb_cmd_wdata              ,
  output [   3:   0] o9_icb_cmd_wmask              ,
  output [   2:   0] o9_icb_cmd_size               ,
  output             o9_icb_cmd_lock               ,
  output             o9_icb_cmd_excl               ,
  output [   7:   0] o9_icb_cmd_xlen               ,
  output [   1:   0] o9_icb_cmd_xburst             ,
  output [   1:   0] o9_icb_cmd_modes              ,
  output             o9_icb_cmd_dmode              ,
  output [   2:   0] o9_icb_cmd_attri              ,
  output [   1:   0] o9_icb_cmd_beat               ,
  output             o9_icb_cmd_usr                ,
  output             o9_icb_rsp_ready              ,
  input              o9_icb_rsp_valid              ,
  input              o9_icb_rsp_err                ,
  input              o9_icb_rsp_excl_ok            ,
  input  [  31:   0] o9_icb_rsp_rdata              ,
  input              o9_icb_rsp_usr                ,
  input                          o10_icb_enable,
    output             o10_icb_cmd_valid             ,
  input              o10_icb_cmd_ready             ,
  output             o10_icb_cmd_sel               ,
  output             o10_icb_cmd_read              ,
  output [  31:   0] o10_icb_cmd_addr              ,
  output [  31:   0] o10_icb_cmd_wdata             ,
  output [   3:   0] o10_icb_cmd_wmask             ,
  output [   2:   0] o10_icb_cmd_size              ,
  output             o10_icb_cmd_lock              ,
  output             o10_icb_cmd_excl              ,
  output [   7:   0] o10_icb_cmd_xlen              ,
  output [   1:   0] o10_icb_cmd_xburst            ,
  output [   1:   0] o10_icb_cmd_modes             ,
  output             o10_icb_cmd_dmode             ,
  output [   2:   0] o10_icb_cmd_attri             ,
  output [   1:   0] o10_icb_cmd_beat              ,
  output             o10_icb_cmd_usr               ,
  output             o10_icb_rsp_ready             ,
  input              o10_icb_rsp_valid             ,
  input              o10_icb_rsp_err               ,
  input              o10_icb_rsp_excl_ok           ,
  input  [  31:   0] o10_icb_rsp_rdata             ,
  input              o10_icb_rsp_usr               ,
  input                          o11_icb_enable,
    output             o11_icb_cmd_valid             ,
  input              o11_icb_cmd_ready             ,
  output             o11_icb_cmd_sel               ,
  output             o11_icb_cmd_read              ,
  output [  31:   0] o11_icb_cmd_addr              ,
  output [  31:   0] o11_icb_cmd_wdata             ,
  output [   3:   0] o11_icb_cmd_wmask             ,
  output [   2:   0] o11_icb_cmd_size              ,
  output             o11_icb_cmd_lock              ,
  output             o11_icb_cmd_excl              ,
  output [   7:   0] o11_icb_cmd_xlen              ,
  output [   1:   0] o11_icb_cmd_xburst            ,
  output [   1:   0] o11_icb_cmd_modes             ,
  output             o11_icb_cmd_dmode             ,
  output [   2:   0] o11_icb_cmd_attri             ,
  output [   1:   0] o11_icb_cmd_beat              ,
  output             o11_icb_cmd_usr               ,
  output             o11_icb_rsp_ready             ,
  input              o11_icb_rsp_valid             ,
  input              o11_icb_rsp_err               ,
  input              o11_icb_rsp_excl_ok           ,
  input  [  31:   0] o11_icb_rsp_rdata             ,
  input              o11_icb_rsp_usr               ,
  input                          o12_icb_enable,
    output             o12_icb_cmd_valid             ,
  input              o12_icb_cmd_ready             ,
  output             o12_icb_cmd_sel               ,
  output             o12_icb_cmd_read              ,
  output [  31:   0] o12_icb_cmd_addr              ,
  output [  31:   0] o12_icb_cmd_wdata             ,
  output [   3:   0] o12_icb_cmd_wmask             ,
  output [   2:   0] o12_icb_cmd_size              ,
  output             o12_icb_cmd_lock              ,
  output             o12_icb_cmd_excl              ,
  output [   7:   0] o12_icb_cmd_xlen              ,
  output [   1:   0] o12_icb_cmd_xburst            ,
  output [   1:   0] o12_icb_cmd_modes             ,
  output             o12_icb_cmd_dmode             ,
  output [   2:   0] o12_icb_cmd_attri             ,
  output [   1:   0] o12_icb_cmd_beat              ,
  output             o12_icb_cmd_usr               ,
  output             o12_icb_rsp_ready             ,
  input              o12_icb_rsp_valid             ,
  input              o12_icb_rsp_err               ,
  input              o12_icb_rsp_excl_ok           ,
  input  [  31:   0] o12_icb_rsp_rdata             ,
  input              o12_icb_rsp_usr               ,
  input                          o13_icb_enable,
    output             o13_icb_cmd_valid             ,
  input              o13_icb_cmd_ready             ,
  output             o13_icb_cmd_sel               ,
  output             o13_icb_cmd_read              ,
  output [  31:   0] o13_icb_cmd_addr              ,
  output [  31:   0] o13_icb_cmd_wdata             ,
  output [   3:   0] o13_icb_cmd_wmask             ,
  output [   2:   0] o13_icb_cmd_size              ,
  output             o13_icb_cmd_lock              ,
  output             o13_icb_cmd_excl              ,
  output [   7:   0] o13_icb_cmd_xlen              ,
  output [   1:   0] o13_icb_cmd_xburst            ,
  output [   1:   0] o13_icb_cmd_modes             ,
  output             o13_icb_cmd_dmode             ,
  output [   2:   0] o13_icb_cmd_attri             ,
  output [   1:   0] o13_icb_cmd_beat              ,
  output             o13_icb_cmd_usr               ,
  output             o13_icb_rsp_ready             ,
  input              o13_icb_rsp_valid             ,
  input              o13_icb_rsp_err               ,
  input              o13_icb_rsp_excl_ok           ,
  input  [  31:   0] o13_icb_rsp_rdata             ,
  input              o13_icb_rsp_usr               ,
  input                          o14_icb_enable,
    output             o14_icb_cmd_valid             ,
  input              o14_icb_cmd_ready             ,
  output             o14_icb_cmd_sel               ,
  output             o14_icb_cmd_read              ,
  output [  31:   0] o14_icb_cmd_addr              ,
  output [  31:   0] o14_icb_cmd_wdata             ,
  output [   3:   0] o14_icb_cmd_wmask             ,
  output [   2:   0] o14_icb_cmd_size              ,
  output             o14_icb_cmd_lock              ,
  output             o14_icb_cmd_excl              ,
  output [   7:   0] o14_icb_cmd_xlen              ,
  output [   1:   0] o14_icb_cmd_xburst            ,
  output [   1:   0] o14_icb_cmd_modes             ,
  output             o14_icb_cmd_dmode             ,
  output [   2:   0] o14_icb_cmd_attri             ,
  output [   1:   0] o14_icb_cmd_beat              ,
  output             o14_icb_cmd_usr               ,
  output             o14_icb_rsp_ready             ,
  input              o14_icb_rsp_valid             ,
  input              o14_icb_rsp_err               ,
  input              o14_icb_rsp_excl_ok           ,
  input  [  31:   0] o14_icb_rsp_rdata             ,
  input              o14_icb_rsp_usr               ,
    output             o15_icb_cmd_valid             ,
  input              o15_icb_cmd_ready             ,
  output             o15_icb_cmd_sel               ,
  output             o15_icb_cmd_read              ,
  output [  31:   0] o15_icb_cmd_addr              ,
  output [  31:   0] o15_icb_cmd_wdata             ,
  output [   3:   0] o15_icb_cmd_wmask             ,
  output [   2:   0] o15_icb_cmd_size              ,
  output             o15_icb_cmd_lock              ,
  output             o15_icb_cmd_excl              ,
  output [   7:   0] o15_icb_cmd_xlen              ,
  output [   1:   0] o15_icb_cmd_xburst            ,
  output [   1:   0] o15_icb_cmd_modes             ,
  output             o15_icb_cmd_dmode             ,
  output [   2:   0] o15_icb_cmd_attri             ,
  output [   1:   0] o15_icb_cmd_beat              ,
  output             o15_icb_cmd_usr               ,
  output             o15_icb_rsp_ready             ,
  input              o15_icb_rsp_valid             ,
  input              o15_icb_rsp_err               ,
  input              o15_icb_rsp_excl_ok           ,
  input  [  31:   0] o15_icb_rsp_rdata             ,
  input              o15_icb_rsp_usr               ,
  input  clk,
  input  rst_n
  );
    wire                buf_icb_cmd_valid             ;
  wire                buf_icb_cmd_ready             ;
  wire                buf_icb_cmd_sel               ;
  wire                buf_icb_cmd_read              ;
  wire    [  31:   0] buf_icb_cmd_addr              ;
  wire    [  31:   0] buf_icb_cmd_wdata             ;
  wire    [   3:   0] buf_icb_cmd_wmask             ;
  wire    [   2:   0] buf_icb_cmd_size              ;
  wire                buf_icb_cmd_lock              ;
  wire                buf_icb_cmd_excl              ;
  wire    [   7:   0] buf_icb_cmd_xlen              ;
  wire    [   1:   0] buf_icb_cmd_xburst            ;
  wire    [   1:   0] buf_icb_cmd_modes             ;
  wire                buf_icb_cmd_dmode             ;
  wire    [   2:   0] buf_icb_cmd_attri             ;
  wire    [   1:   0] buf_icb_cmd_beat              ;
  wire                buf_icb_cmd_usr               ;
  wire                buf_icb_rsp_ready             ;
  wire                buf_icb_rsp_valid             ;
  wire                buf_icb_rsp_err               ;
  wire                buf_icb_rsp_excl_ok           ;
  wire    [  31:   0] buf_icb_rsp_rdata             ;
  wire                buf_icb_rsp_usr               ;
  wire buffer_active;
  wire splt_active;
  assign icb1ton_active = buffer_active | splt_active;
  e603_gnrl_ficb_buffer # (
    .I_SUPPORT_RATIO(I_SUPPORT_RATIO),
    .O_SUPPORT_RATIO(O_SUPPORT_RATIO),
    .OUTS_CNT_W     (SPLT_FIFO_OUTS_CNT_W),
    .AW    (32),
    .DW    (32), 
    .RSP_DP(ICB_FIFO_RSP_DP),
    .CMD_DP(ICB_FIFO_CMD_DP),
    .CMD_CUT_READY (ICB_FIFO_CMD_CUT_READY),
    .RSP_CUT_READY (ICB_FIFO_RSP_CUT_READY),
    .CMD_UW (1),
    .RSP_UW (1)
  )u_e603_icb_buffer(
    .i_clk_en   (i_clk_en),
    .o_clk_en   (o_clk_en),
    .icb_buffer_active (buffer_active),
      .i_icb_cmd_valid                (i_icb_cmd_valid                          ),
  .i_icb_cmd_ready                (i_icb_cmd_ready                          ),
  .i_icb_cmd_sel                  (i_icb_cmd_sel                            ),
  .i_icb_cmd_read                 (i_icb_cmd_read                           ),
  .i_icb_cmd_addr                 (i_icb_cmd_addr                [  31:   0]),
  .i_icb_cmd_wdata                (i_icb_cmd_wdata               [  31:   0]),
  .i_icb_cmd_wmask                (i_icb_cmd_wmask               [   3:   0]),
  .i_icb_cmd_size                 (i_icb_cmd_size                [   2:   0]),
  .i_icb_cmd_lock                 (i_icb_cmd_lock                           ),
  .i_icb_cmd_excl                 (i_icb_cmd_excl                           ),
  .i_icb_cmd_xlen                 (i_icb_cmd_xlen                [   7:   0]),
  .i_icb_cmd_xburst               (i_icb_cmd_xburst              [   1:   0]),
  .i_icb_cmd_modes                (i_icb_cmd_modes               [   1:   0]),
  .i_icb_cmd_dmode                (i_icb_cmd_dmode                          ),
  .i_icb_cmd_attri                (i_icb_cmd_attri               [   2:   0]),
  .i_icb_cmd_beat                 (i_icb_cmd_beat                [   1:   0]),
  .i_icb_cmd_usr                  (i_icb_cmd_usr                            ),
  .i_icb_rsp_ready                (i_icb_rsp_ready                          ),
  .i_icb_rsp_valid                (i_icb_rsp_valid                          ),
  .i_icb_rsp_err                  (i_icb_rsp_err                            ),
  .i_icb_rsp_excl_ok              (i_icb_rsp_excl_ok                        ),
  .i_icb_rsp_rdata                (i_icb_rsp_rdata               [  31:   0]),
  .i_icb_rsp_usr                  (i_icb_rsp_usr                            ),
      .o_icb_cmd_valid                (buf_icb_cmd_valid                        ),
  .o_icb_cmd_ready                (buf_icb_cmd_ready                        ),
  .o_icb_cmd_sel                  (buf_icb_cmd_sel                          ),
  .o_icb_cmd_read                 (buf_icb_cmd_read                         ),
  .o_icb_cmd_addr                 (buf_icb_cmd_addr              [  31:   0]),
  .o_icb_cmd_wdata                (buf_icb_cmd_wdata             [  31:   0]),
  .o_icb_cmd_wmask                (buf_icb_cmd_wmask             [   3:   0]),
  .o_icb_cmd_size                 (buf_icb_cmd_size              [   2:   0]),
  .o_icb_cmd_lock                 (buf_icb_cmd_lock                         ),
  .o_icb_cmd_excl                 (buf_icb_cmd_excl                         ),
  .o_icb_cmd_xlen                 (buf_icb_cmd_xlen              [   7:   0]),
  .o_icb_cmd_xburst               (buf_icb_cmd_xburst            [   1:   0]),
  .o_icb_cmd_modes                (buf_icb_cmd_modes             [   1:   0]),
  .o_icb_cmd_dmode                (buf_icb_cmd_dmode                        ),
  .o_icb_cmd_attri                (buf_icb_cmd_attri             [   2:   0]),
  .o_icb_cmd_beat                 (buf_icb_cmd_beat              [   1:   0]),
  .o_icb_cmd_usr                  (buf_icb_cmd_usr                          ),
  .o_icb_rsp_ready                (buf_icb_rsp_ready                        ),
  .o_icb_rsp_valid                (buf_icb_rsp_valid                        ),
  .o_icb_rsp_err                  (buf_icb_rsp_err                          ),
  .o_icb_rsp_excl_ok              (buf_icb_rsp_excl_ok                      ),
  .o_icb_rsp_rdata                (buf_icb_rsp_rdata             [  31:   0]),
  .o_icb_rsp_usr                  (buf_icb_rsp_usr                          ),
    .clk                    (clk  ),
    .rst_n                  (rst_n)
  );
    wire    [  15:   0] splt_bus_icb_cmd_valid        ;
  wire    [  15:   0] splt_bus_icb_cmd_ready        ;
  wire    [  15:   0] splt_bus_icb_cmd_sel          ;
  wire    [  15:   0] splt_bus_icb_cmd_read         ;
  wire    [ 511:   0] splt_bus_icb_cmd_addr         ;
  wire    [ 511:   0] splt_bus_icb_cmd_wdata        ;
  wire    [  63:   0] splt_bus_icb_cmd_wmask        ;
  wire    [  47:   0] splt_bus_icb_cmd_size         ;
  wire    [  15:   0] splt_bus_icb_cmd_lock         ;
  wire    [  15:   0] splt_bus_icb_cmd_excl         ;
  wire    [ 127:   0] splt_bus_icb_cmd_xlen         ;
  wire    [  31:   0] splt_bus_icb_cmd_xburst       ;
  wire    [  31:   0] splt_bus_icb_cmd_modes        ;
  wire    [  15:   0] splt_bus_icb_cmd_dmode        ;
  wire    [  47:   0] splt_bus_icb_cmd_attri        ;
  wire    [  31:   0] splt_bus_icb_cmd_beat         ;
  wire    [  15:   0] splt_bus_icb_cmd_usr          ;
  wire    [  15:   0] splt_bus_icb_rsp_ready        ;
  wire    [  15:   0] splt_bus_icb_rsp_valid        ;
  wire    [  15:   0] splt_bus_icb_rsp_err          ;
  wire    [  15:   0] splt_bus_icb_rsp_excl_ok      ;
  wire    [ 511:   0] splt_bus_icb_rsp_rdata        ;
  wire    [  15:   0] splt_bus_icb_rsp_usr          ;
      assign                 { o15_icb_cmd_sel
                           , o14_icb_cmd_sel
                           , o13_icb_cmd_sel
                           , o12_icb_cmd_sel
                           , o11_icb_cmd_sel
                           , o10_icb_cmd_sel
                           , o9_icb_cmd_sel
                           , o8_icb_cmd_sel
                           , o7_icb_cmd_sel
                           , o6_icb_cmd_sel
                           , o5_icb_cmd_sel
                           , o4_icb_cmd_sel
                           , o3_icb_cmd_sel
                           , o2_icb_cmd_sel
                           , o1_icb_cmd_sel
                           , o0_icb_cmd_sel
                           } = splt_bus_icb_cmd_sel;
      assign                 { o15_icb_cmd_valid
                           , o14_icb_cmd_valid
                           , o13_icb_cmd_valid
                           , o12_icb_cmd_valid
                           , o11_icb_cmd_valid
                           , o10_icb_cmd_valid
                           , o9_icb_cmd_valid
                           , o8_icb_cmd_valid
                           , o7_icb_cmd_valid
                           , o6_icb_cmd_valid
                           , o5_icb_cmd_valid
                           , o4_icb_cmd_valid
                           , o3_icb_cmd_valid
                           , o2_icb_cmd_valid
                           , o1_icb_cmd_valid
                           , o0_icb_cmd_valid
                           } = splt_bus_icb_cmd_valid;
      assign                 { o15_icb_cmd_read
                           , o14_icb_cmd_read
                           , o13_icb_cmd_read
                           , o12_icb_cmd_read
                           , o11_icb_cmd_read
                           , o10_icb_cmd_read
                           , o9_icb_cmd_read
                           , o8_icb_cmd_read
                           , o7_icb_cmd_read
                           , o6_icb_cmd_read
                           , o5_icb_cmd_read
                           , o4_icb_cmd_read
                           , o3_icb_cmd_read
                           , o2_icb_cmd_read
                           , o1_icb_cmd_read
                           , o0_icb_cmd_read
                           } = splt_bus_icb_cmd_read;
      assign                 { o15_icb_cmd_addr
                           , o14_icb_cmd_addr
                           , o13_icb_cmd_addr
                           , o12_icb_cmd_addr
                           , o11_icb_cmd_addr
                           , o10_icb_cmd_addr
                           , o9_icb_cmd_addr
                           , o8_icb_cmd_addr
                           , o7_icb_cmd_addr
                           , o6_icb_cmd_addr
                           , o5_icb_cmd_addr
                           , o4_icb_cmd_addr
                           , o3_icb_cmd_addr
                           , o2_icb_cmd_addr
                           , o1_icb_cmd_addr
                           , o0_icb_cmd_addr
                           } = splt_bus_icb_cmd_addr;
      assign                 { o15_icb_cmd_wdata
                           , o14_icb_cmd_wdata
                           , o13_icb_cmd_wdata
                           , o12_icb_cmd_wdata
                           , o11_icb_cmd_wdata
                           , o10_icb_cmd_wdata
                           , o9_icb_cmd_wdata
                           , o8_icb_cmd_wdata
                           , o7_icb_cmd_wdata
                           , o6_icb_cmd_wdata
                           , o5_icb_cmd_wdata
                           , o4_icb_cmd_wdata
                           , o3_icb_cmd_wdata
                           , o2_icb_cmd_wdata
                           , o1_icb_cmd_wdata
                           , o0_icb_cmd_wdata
                           } = splt_bus_icb_cmd_wdata;
      assign                 { o15_icb_cmd_wmask
                           , o14_icb_cmd_wmask
                           , o13_icb_cmd_wmask
                           , o12_icb_cmd_wmask
                           , o11_icb_cmd_wmask
                           , o10_icb_cmd_wmask
                           , o9_icb_cmd_wmask
                           , o8_icb_cmd_wmask
                           , o7_icb_cmd_wmask
                           , o6_icb_cmd_wmask
                           , o5_icb_cmd_wmask
                           , o4_icb_cmd_wmask
                           , o3_icb_cmd_wmask
                           , o2_icb_cmd_wmask
                           , o1_icb_cmd_wmask
                           , o0_icb_cmd_wmask
                           } = splt_bus_icb_cmd_wmask;
      assign                 { o15_icb_cmd_size
                           , o14_icb_cmd_size
                           , o13_icb_cmd_size
                           , o12_icb_cmd_size
                           , o11_icb_cmd_size
                           , o10_icb_cmd_size
                           , o9_icb_cmd_size
                           , o8_icb_cmd_size
                           , o7_icb_cmd_size
                           , o6_icb_cmd_size
                           , o5_icb_cmd_size
                           , o4_icb_cmd_size
                           , o3_icb_cmd_size
                           , o2_icb_cmd_size
                           , o1_icb_cmd_size
                           , o0_icb_cmd_size
                           } = splt_bus_icb_cmd_size;
      assign                 { o15_icb_cmd_lock
                           , o14_icb_cmd_lock
                           , o13_icb_cmd_lock
                           , o12_icb_cmd_lock
                           , o11_icb_cmd_lock
                           , o10_icb_cmd_lock
                           , o9_icb_cmd_lock
                           , o8_icb_cmd_lock
                           , o7_icb_cmd_lock
                           , o6_icb_cmd_lock
                           , o5_icb_cmd_lock
                           , o4_icb_cmd_lock
                           , o3_icb_cmd_lock
                           , o2_icb_cmd_lock
                           , o1_icb_cmd_lock
                           , o0_icb_cmd_lock
                           } = splt_bus_icb_cmd_lock;
      assign                 { o15_icb_cmd_excl
                           , o14_icb_cmd_excl
                           , o13_icb_cmd_excl
                           , o12_icb_cmd_excl
                           , o11_icb_cmd_excl
                           , o10_icb_cmd_excl
                           , o9_icb_cmd_excl
                           , o8_icb_cmd_excl
                           , o7_icb_cmd_excl
                           , o6_icb_cmd_excl
                           , o5_icb_cmd_excl
                           , o4_icb_cmd_excl
                           , o3_icb_cmd_excl
                           , o2_icb_cmd_excl
                           , o1_icb_cmd_excl
                           , o0_icb_cmd_excl
                           } = splt_bus_icb_cmd_excl;
      assign                 { o15_icb_cmd_xlen
                           , o14_icb_cmd_xlen
                           , o13_icb_cmd_xlen
                           , o12_icb_cmd_xlen
                           , o11_icb_cmd_xlen
                           , o10_icb_cmd_xlen
                           , o9_icb_cmd_xlen
                           , o8_icb_cmd_xlen
                           , o7_icb_cmd_xlen
                           , o6_icb_cmd_xlen
                           , o5_icb_cmd_xlen
                           , o4_icb_cmd_xlen
                           , o3_icb_cmd_xlen
                           , o2_icb_cmd_xlen
                           , o1_icb_cmd_xlen
                           , o0_icb_cmd_xlen
                           } = splt_bus_icb_cmd_xlen;
      assign                 { o15_icb_cmd_xburst
                           , o14_icb_cmd_xburst
                           , o13_icb_cmd_xburst
                           , o12_icb_cmd_xburst
                           , o11_icb_cmd_xburst
                           , o10_icb_cmd_xburst
                           , o9_icb_cmd_xburst
                           , o8_icb_cmd_xburst
                           , o7_icb_cmd_xburst
                           , o6_icb_cmd_xburst
                           , o5_icb_cmd_xburst
                           , o4_icb_cmd_xburst
                           , o3_icb_cmd_xburst
                           , o2_icb_cmd_xburst
                           , o1_icb_cmd_xburst
                           , o0_icb_cmd_xburst
                           } = splt_bus_icb_cmd_xburst;
      assign                 { o15_icb_cmd_modes
                           , o14_icb_cmd_modes
                           , o13_icb_cmd_modes
                           , o12_icb_cmd_modes
                           , o11_icb_cmd_modes
                           , o10_icb_cmd_modes
                           , o9_icb_cmd_modes
                           , o8_icb_cmd_modes
                           , o7_icb_cmd_modes
                           , o6_icb_cmd_modes
                           , o5_icb_cmd_modes
                           , o4_icb_cmd_modes
                           , o3_icb_cmd_modes
                           , o2_icb_cmd_modes
                           , o1_icb_cmd_modes
                           , o0_icb_cmd_modes
                           } = splt_bus_icb_cmd_modes;
      assign                 { o15_icb_cmd_dmode
                           , o14_icb_cmd_dmode
                           , o13_icb_cmd_dmode
                           , o12_icb_cmd_dmode
                           , o11_icb_cmd_dmode
                           , o10_icb_cmd_dmode
                           , o9_icb_cmd_dmode
                           , o8_icb_cmd_dmode
                           , o7_icb_cmd_dmode
                           , o6_icb_cmd_dmode
                           , o5_icb_cmd_dmode
                           , o4_icb_cmd_dmode
                           , o3_icb_cmd_dmode
                           , o2_icb_cmd_dmode
                           , o1_icb_cmd_dmode
                           , o0_icb_cmd_dmode
                           } = splt_bus_icb_cmd_dmode;
      assign                 { o15_icb_cmd_attri
                           , o14_icb_cmd_attri
                           , o13_icb_cmd_attri
                           , o12_icb_cmd_attri
                           , o11_icb_cmd_attri
                           , o10_icb_cmd_attri
                           , o9_icb_cmd_attri
                           , o8_icb_cmd_attri
                           , o7_icb_cmd_attri
                           , o6_icb_cmd_attri
                           , o5_icb_cmd_attri
                           , o4_icb_cmd_attri
                           , o3_icb_cmd_attri
                           , o2_icb_cmd_attri
                           , o1_icb_cmd_attri
                           , o0_icb_cmd_attri
                           } = splt_bus_icb_cmd_attri;
      assign                 { o15_icb_cmd_beat
                           , o14_icb_cmd_beat
                           , o13_icb_cmd_beat
                           , o12_icb_cmd_beat
                           , o11_icb_cmd_beat
                           , o10_icb_cmd_beat
                           , o9_icb_cmd_beat
                           , o8_icb_cmd_beat
                           , o7_icb_cmd_beat
                           , o6_icb_cmd_beat
                           , o5_icb_cmd_beat
                           , o4_icb_cmd_beat
                           , o3_icb_cmd_beat
                           , o2_icb_cmd_beat
                           , o1_icb_cmd_beat
                           , o0_icb_cmd_beat
                           } = splt_bus_icb_cmd_beat;
      assign                 { o15_icb_cmd_usr
                           , o14_icb_cmd_usr
                           , o13_icb_cmd_usr
                           , o12_icb_cmd_usr
                           , o11_icb_cmd_usr
                           , o10_icb_cmd_usr
                           , o9_icb_cmd_usr
                           , o8_icb_cmd_usr
                           , o7_icb_cmd_usr
                           , o6_icb_cmd_usr
                           , o5_icb_cmd_usr
                           , o4_icb_cmd_usr
                           , o3_icb_cmd_usr
                           , o2_icb_cmd_usr
                           , o1_icb_cmd_usr
                           , o0_icb_cmd_usr
                           } = splt_bus_icb_cmd_usr;
    assign splt_bus_icb_cmd_ready =
                           { o15_icb_cmd_ready
                           , o14_icb_cmd_ready
                           , o13_icb_cmd_ready
                           , o12_icb_cmd_ready
                           , o11_icb_cmd_ready
                           , o10_icb_cmd_ready
                           , o9_icb_cmd_ready
                           , o8_icb_cmd_ready
                           , o7_icb_cmd_ready
                           , o6_icb_cmd_ready
                           , o5_icb_cmd_ready
                           , o4_icb_cmd_ready
                           , o3_icb_cmd_ready
                           , o2_icb_cmd_ready
                           , o1_icb_cmd_ready
                           , o0_icb_cmd_ready
                           };
    assign splt_bus_icb_rsp_valid =
                           { o15_icb_rsp_valid
                           , o14_icb_rsp_valid
                           , o13_icb_rsp_valid
                           , o12_icb_rsp_valid
                           , o11_icb_rsp_valid
                           , o10_icb_rsp_valid
                           , o9_icb_rsp_valid
                           , o8_icb_rsp_valid
                           , o7_icb_rsp_valid
                           , o6_icb_rsp_valid
                           , o5_icb_rsp_valid
                           , o4_icb_rsp_valid
                           , o3_icb_rsp_valid
                           , o2_icb_rsp_valid
                           , o1_icb_rsp_valid
                           , o0_icb_rsp_valid
                           };
    assign splt_bus_icb_rsp_err =
                           { o15_icb_rsp_err
                           , o14_icb_rsp_err
                           , o13_icb_rsp_err
                           , o12_icb_rsp_err
                           , o11_icb_rsp_err
                           , o10_icb_rsp_err
                           , o9_icb_rsp_err
                           , o8_icb_rsp_err
                           , o7_icb_rsp_err
                           , o6_icb_rsp_err
                           , o5_icb_rsp_err
                           , o4_icb_rsp_err
                           , o3_icb_rsp_err
                           , o2_icb_rsp_err
                           , o1_icb_rsp_err
                           , o0_icb_rsp_err
                           };
    assign splt_bus_icb_rsp_excl_ok =
                           { o15_icb_rsp_excl_ok
                           , o14_icb_rsp_excl_ok
                           , o13_icb_rsp_excl_ok
                           , o12_icb_rsp_excl_ok
                           , o11_icb_rsp_excl_ok
                           , o10_icb_rsp_excl_ok
                           , o9_icb_rsp_excl_ok
                           , o8_icb_rsp_excl_ok
                           , o7_icb_rsp_excl_ok
                           , o6_icb_rsp_excl_ok
                           , o5_icb_rsp_excl_ok
                           , o4_icb_rsp_excl_ok
                           , o3_icb_rsp_excl_ok
                           , o2_icb_rsp_excl_ok
                           , o1_icb_rsp_excl_ok
                           , o0_icb_rsp_excl_ok
                           };
    assign splt_bus_icb_rsp_rdata =
                           { o15_icb_rsp_rdata
                           , o14_icb_rsp_rdata
                           , o13_icb_rsp_rdata
                           , o12_icb_rsp_rdata
                           , o11_icb_rsp_rdata
                           , o10_icb_rsp_rdata
                           , o9_icb_rsp_rdata
                           , o8_icb_rsp_rdata
                           , o7_icb_rsp_rdata
                           , o6_icb_rsp_rdata
                           , o5_icb_rsp_rdata
                           , o4_icb_rsp_rdata
                           , o3_icb_rsp_rdata
                           , o2_icb_rsp_rdata
                           , o1_icb_rsp_rdata
                           , o0_icb_rsp_rdata
                           };
    assign splt_bus_icb_rsp_usr =
                           { o15_icb_rsp_usr
                           , o14_icb_rsp_usr
                           , o13_icb_rsp_usr
                           , o12_icb_rsp_usr
                           , o11_icb_rsp_usr
                           , o10_icb_rsp_usr
                           , o9_icb_rsp_usr
                           , o8_icb_rsp_usr
                           , o7_icb_rsp_usr
                           , o6_icb_rsp_usr
                           , o5_icb_rsp_usr
                           , o4_icb_rsp_usr
                           , o3_icb_rsp_usr
                           , o2_icb_rsp_usr
                           , o1_icb_rsp_usr
                           , o0_icb_rsp_usr
                           };
      assign                 { o15_icb_rsp_ready
                           , o14_icb_rsp_ready
                           , o13_icb_rsp_ready
                           , o12_icb_rsp_ready
                           , o11_icb_rsp_ready
                           , o10_icb_rsp_ready
                           , o9_icb_rsp_ready
                           , o8_icb_rsp_ready
                           , o7_icb_rsp_ready
                           , o6_icb_rsp_ready
                           , o5_icb_rsp_ready
                           , o4_icb_rsp_ready
                           , o3_icb_rsp_ready
                           , o2_icb_rsp_ready
                           , o1_icb_rsp_ready
                           , o0_icb_rsp_ready
                           } = splt_bus_icb_rsp_ready;
      wire icb_cmd_o0 = (buf_icb_cmd_addr     [31:O0_BASE_REGION_LSB]
                         ==  O0_BASE_ADDR [31:O0_BASE_REGION_LSB] 
                        ) & o0_icb_enable 
                        ; 
      wire icb_cmd_o1 = (buf_icb_cmd_addr     [31:O1_BASE_REGION_LSB]
                         ==  O1_BASE_ADDR [31:O1_BASE_REGION_LSB] 
                        ) & o1_icb_enable 
                          & (~icb_cmd_o0)
                        ; 
      wire icb_cmd_o2 = (buf_icb_cmd_addr     [31:O2_BASE_REGION_LSB]
                         ==  O2_BASE_ADDR [31:O2_BASE_REGION_LSB] 
                        ) & o2_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                        ; 
      wire icb_cmd_o3 = (buf_icb_cmd_addr     [31:O3_BASE_REGION_LSB]
                         ==  O3_BASE_ADDR [31:O3_BASE_REGION_LSB] 
                        ) & o3_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                        ; 
      wire icb_cmd_o4 = (buf_icb_cmd_addr     [31:O4_BASE_REGION_LSB]
                         ==  O4_BASE_ADDR [31:O4_BASE_REGION_LSB] 
                        ) & o4_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                        ; 
      wire icb_cmd_o5 = (buf_icb_cmd_addr     [31:O5_BASE_REGION_LSB]
                         ==  O5_BASE_ADDR [31:O5_BASE_REGION_LSB] 
                        ) & o5_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                        ; 
      wire icb_cmd_o6 = (buf_icb_cmd_addr     [31:O6_BASE_REGION_LSB]
                         ==  O6_BASE_ADDR [31:O6_BASE_REGION_LSB] 
                        ) & o6_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                        ; 
      wire icb_cmd_o7 = (buf_icb_cmd_addr     [31:O7_BASE_REGION_LSB]
                         ==  O7_BASE_ADDR [31:O7_BASE_REGION_LSB] 
                        ) & o7_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                          & (~icb_cmd_o6)
                        ; 
      wire icb_cmd_o8 = (buf_icb_cmd_addr     [31:O8_BASE_REGION_LSB]
                         ==  O8_BASE_ADDR [31:O8_BASE_REGION_LSB] 
                        ) & o8_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                          & (~icb_cmd_o6)
                          & (~icb_cmd_o7)
                        ; 
      wire icb_cmd_o9 = (buf_icb_cmd_addr     [31:O9_BASE_REGION_LSB]
                         ==  O9_BASE_ADDR [31:O9_BASE_REGION_LSB] 
                        ) & o9_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                          & (~icb_cmd_o6)
                          & (~icb_cmd_o7)
                          & (~icb_cmd_o8)
                        ; 
      wire icb_cmd_o10 = (buf_icb_cmd_addr     [31:O10_BASE_REGION_LSB]
                         ==  O10_BASE_ADDR [31:O10_BASE_REGION_LSB] 
                        ) & o10_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                          & (~icb_cmd_o6)
                          & (~icb_cmd_o7)
                          & (~icb_cmd_o8)
                          & (~icb_cmd_o9)
                        ; 
      wire icb_cmd_o11 = (buf_icb_cmd_addr     [31:O11_BASE_REGION_LSB]
                         ==  O11_BASE_ADDR [31:O11_BASE_REGION_LSB] 
                        ) & o11_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                          & (~icb_cmd_o6)
                          & (~icb_cmd_o7)
                          & (~icb_cmd_o8)
                          & (~icb_cmd_o9)
                          & (~icb_cmd_o10)
                        ; 
      wire icb_cmd_o12 = (buf_icb_cmd_addr     [31:O12_BASE_REGION_LSB]
                         ==  O12_BASE_ADDR [31:O12_BASE_REGION_LSB] 
                        ) & o12_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                          & (~icb_cmd_o6)
                          & (~icb_cmd_o7)
                          & (~icb_cmd_o8)
                          & (~icb_cmd_o9)
                          & (~icb_cmd_o10)
                          & (~icb_cmd_o11)
                        ; 
      wire icb_cmd_o13 = (buf_icb_cmd_addr     [31:O13_BASE_REGION_LSB]
                         ==  O13_BASE_ADDR [31:O13_BASE_REGION_LSB] 
                        ) & o13_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                          & (~icb_cmd_o6)
                          & (~icb_cmd_o7)
                          & (~icb_cmd_o8)
                          & (~icb_cmd_o9)
                          & (~icb_cmd_o10)
                          & (~icb_cmd_o11)
                          & (~icb_cmd_o12)
                        ; 
      wire icb_cmd_o14 = (buf_icb_cmd_addr     [31:O14_BASE_REGION_LSB]
                         ==  O14_BASE_ADDR [31:O14_BASE_REGION_LSB] 
                        ) & o14_icb_enable 
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                          & (~icb_cmd_o6)
                          & (~icb_cmd_o7)
                          & (~icb_cmd_o8)
                          & (~icb_cmd_o9)
                          & (~icb_cmd_o10)
                          & (~icb_cmd_o11)
                          & (~icb_cmd_o12)
                          & (~icb_cmd_o13)
                        ; 
      wire icb_cmd_o15 = 1'b1
                          & (~icb_cmd_o0)
                          & (~icb_cmd_o1)
                          & (~icb_cmd_o2)
                          & (~icb_cmd_o3)
                          & (~icb_cmd_o4)
                          & (~icb_cmd_o5)
                          & (~icb_cmd_o6)
                          & (~icb_cmd_o7)
                          & (~icb_cmd_o8)
                          & (~icb_cmd_o9)
                          & (~icb_cmd_o10)
                          & (~icb_cmd_o11)
                          & (~icb_cmd_o12)
                          & (~icb_cmd_o13)
                          & (~icb_cmd_o14)
                        ; 
  wire [16-1:0] buf_icb_splt_indic = 
      {
                      icb_cmd_o15
                    , icb_cmd_o14
                    , icb_cmd_o13
                    , icb_cmd_o12
                    , icb_cmd_o11
                    , icb_cmd_o10
                    , icb_cmd_o9
                    , icb_cmd_o8
                    , icb_cmd_o7
                    , icb_cmd_o6
                    , icb_cmd_o5
                    , icb_cmd_o4
                    , icb_cmd_o3
                    , icb_cmd_o2
                    , icb_cmd_o1
                    , icb_cmd_o0
      };
  e603_gnrl_ficb_splt # (
  .ALLOW_DIFF (ALLOW_DIFF),
  .ALLOW_0CYCL_RSP (ALLOW_0CYCL_RSP),
  .FIFO_OUTS_NUM   (SPLT_FIFO_OUTS_NUM ),
  .FIFO_CUT_READY  (SPLT_FIFO_CUT_READY),
  .SPLT_NUM   (16),
  .SPLT_PTR_W (16),
  .SPLT_PTR_1HOT (1),
  .CMD_UW (1),
  .RSP_UW (1),
  .AW         (32),
  .DW         (32) 
  ) u_buf_icb_splt(
      .clk_en(o_clk_en),
  .i_icb_splt_indic       (buf_icb_splt_indic),        
  .splt_active            (splt_active),
      .i_icb_cmd_valid                (buf_icb_cmd_valid                        ),
  .i_icb_cmd_ready                (buf_icb_cmd_ready                        ),
  .i_icb_cmd_sel                  (buf_icb_cmd_sel                          ),
  .i_icb_cmd_read                 (buf_icb_cmd_read                         ),
  .i_icb_cmd_addr                 (buf_icb_cmd_addr              [  31:   0]),
  .i_icb_cmd_wdata                (buf_icb_cmd_wdata             [  31:   0]),
  .i_icb_cmd_wmask                (buf_icb_cmd_wmask             [   3:   0]),
  .i_icb_cmd_size                 (buf_icb_cmd_size              [   2:   0]),
  .i_icb_cmd_lock                 (buf_icb_cmd_lock                         ),
  .i_icb_cmd_excl                 (buf_icb_cmd_excl                         ),
  .i_icb_cmd_xlen                 (buf_icb_cmd_xlen              [   7:   0]),
  .i_icb_cmd_xburst               (buf_icb_cmd_xburst            [   1:   0]),
  .i_icb_cmd_modes                (buf_icb_cmd_modes             [   1:   0]),
  .i_icb_cmd_dmode                (buf_icb_cmd_dmode                        ),
  .i_icb_cmd_attri                (buf_icb_cmd_attri             [   2:   0]),
  .i_icb_cmd_beat                 (buf_icb_cmd_beat              [   1:   0]),
  .i_icb_cmd_usr                  (buf_icb_cmd_usr                          ),
  .i_icb_rsp_ready                (buf_icb_rsp_ready                        ),
  .i_icb_rsp_valid                (buf_icb_rsp_valid                        ),
  .i_icb_rsp_err                  (buf_icb_rsp_err                          ),
  .i_icb_rsp_excl_ok              (buf_icb_rsp_excl_ok                      ),
  .i_icb_rsp_rdata                (buf_icb_rsp_rdata             [  31:   0]),
  .i_icb_rsp_usr                  (buf_icb_rsp_usr                          ),
      .o_bus_icb_cmd_valid            (splt_bus_icb_cmd_valid        [  15:   0]),
  .o_bus_icb_cmd_ready            (splt_bus_icb_cmd_ready        [  15:   0]),
  .o_bus_icb_cmd_sel              (splt_bus_icb_cmd_sel          [  15:   0]),
  .o_bus_icb_cmd_read             (splt_bus_icb_cmd_read         [  15:   0]),
  .o_bus_icb_cmd_addr             (splt_bus_icb_cmd_addr         [ 511:   0]),
  .o_bus_icb_cmd_wdata            (splt_bus_icb_cmd_wdata        [ 511:   0]),
  .o_bus_icb_cmd_wmask            (splt_bus_icb_cmd_wmask        [  63:   0]),
  .o_bus_icb_cmd_size             (splt_bus_icb_cmd_size         [  47:   0]),
  .o_bus_icb_cmd_lock             (splt_bus_icb_cmd_lock         [  15:   0]),
  .o_bus_icb_cmd_excl             (splt_bus_icb_cmd_excl         [  15:   0]),
  .o_bus_icb_cmd_xlen             (splt_bus_icb_cmd_xlen         [ 127:   0]),
  .o_bus_icb_cmd_xburst           (splt_bus_icb_cmd_xburst       [  31:   0]),
  .o_bus_icb_cmd_modes            (splt_bus_icb_cmd_modes        [  31:   0]),
  .o_bus_icb_cmd_dmode            (splt_bus_icb_cmd_dmode        [  15:   0]),
  .o_bus_icb_cmd_attri            (splt_bus_icb_cmd_attri        [  47:   0]),
  .o_bus_icb_cmd_beat             (splt_bus_icb_cmd_beat         [  31:   0]),
  .o_bus_icb_cmd_usr              (splt_bus_icb_cmd_usr          [  15:   0]),
  .o_bus_icb_rsp_ready            (splt_bus_icb_rsp_ready        [  15:   0]),
  .o_bus_icb_rsp_valid            (splt_bus_icb_rsp_valid        [  15:   0]),
  .o_bus_icb_rsp_err              (splt_bus_icb_rsp_err          [  15:   0]),
  .o_bus_icb_rsp_excl_ok          (splt_bus_icb_rsp_excl_ok      [  15:   0]),
  .o_bus_icb_rsp_rdata            (splt_bus_icb_rsp_rdata        [ 511:   0]),
  .o_bus_icb_rsp_usr              (splt_bus_icb_rsp_usr          [  15:   0]),
  .clk                    (clk  )                     ,
  .rst_n                  (rst_n)
  );
endmodule
