 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_mrom_top #(
    parameter AW = 12,
    parameter DW = 32,
    parameter DP = 1024
)(
  input  rom_icb_cmd_valid, 
  output rom_icb_cmd_ready, 
  input  [AW-1:0] rom_icb_cmd_addr, 
  input  rom_icb_cmd_read,   
  output rom_icb_rsp_valid, 
  input  rom_icb_rsp_ready, 
  output rom_icb_rsp_err,   
  output [DW-1:0] rom_icb_rsp_rdata, 
  input  clk,
  input  rst_n
  );
  wire [DW-1:0] rom_dout; 
  assign rom_icb_rsp_valid = rom_icb_cmd_valid;
  assign rom_icb_cmd_ready = rom_icb_rsp_ready;
  assign rom_icb_rsp_err = ~rom_icb_cmd_read;
  assign rom_icb_rsp_rdata = rom_dout;
   e603_mrom # (
    .AW(AW),
    .DW(DW),
    .DP(DP)
   )u_mrom (
     .rom_addr (rom_icb_cmd_addr[AW-1:2]),
     .rom_dout (rom_dout) 
   );
endmodule
