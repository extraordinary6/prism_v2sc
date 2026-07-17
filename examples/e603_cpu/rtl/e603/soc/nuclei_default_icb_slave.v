 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module nuclei_default_icb_slave # (
    parameter AW = 32, 
    parameter DW = 32 
)(
  input   clk,
  input   rst_n,
  input                      icb_cmd_valid,
  output                     icb_cmd_ready,
  input  [AW-1:0]            icb_cmd_addr, 
  input                      icb_cmd_read, 
  input  [DW-1:0]            icb_cmd_wdata,
  input  [DW/8-1:0]          icb_cmd_wmask,
  output                     icb_rsp_valid,
  input                      icb_rsp_ready,
  output                     icb_rsp_err,
  output [DW-1:0]            icb_rsp_rdata
);
      e603_gnrl_pipe_stage # (
        .CUT_READY (0),
        .DP  (1),
        .DW  (DW)
      ) u_gnrl_pipe_stage (
        .i_vld(icb_cmd_valid),
        .i_rdy(icb_cmd_ready),
        .i_dat(icb_cmd_wdata),
        .o_vld(icb_rsp_valid),
        .o_rdy(icb_rsp_ready),  
        .o_dat(icb_rsp_rdata),  
        .clk  (clk),
        .rst_n(rst_n)
      );
    assign icb_rsp_err = 1'b0;
endmodule
