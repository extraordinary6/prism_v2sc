 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
module e603_1cyc_sram_ctrl #(
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
