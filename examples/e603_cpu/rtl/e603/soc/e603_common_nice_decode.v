 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
module e603_exu_nice_decode(
  input  [32-1:0] i_instr,
  output  dec_nice_rs1_en,
  output  dec_nice_rs1_fpu,
  output  dec_nice_rs1_pair,
  output  dec_nice_rs2_en,
  output  dec_nice_rs2_fpu,
  output  dec_nice_rs2_pair,
  output  dec_nice_rd_mac,
  output  dec_nice_rd_en,
  output  dec_nice_rd_fpu,
  output  dec_nice_rd_pair,
  output dec_nice_ilgl,
  output nice_need_fpu
);
  wire [6:0]  rv32_func7  = i_instr[31:25];
  wire nice_64_op = 1'b0;
  assign nice_need_fpu = 1'b0;
  assign dec_nice_rs1_en = i_instr[13];
  assign dec_nice_rs2_en = i_instr[12];
  assign dec_nice_rd_mac = rv32_func7[6];
  assign dec_nice_rd_en  = i_instr[14];
  assign dec_nice_rs1_fpu = nice_need_fpu;
  assign dec_nice_rs2_fpu = nice_need_fpu;
  assign dec_nice_rd_fpu  = nice_need_fpu;
  assign dec_nice_rs1_pair = nice_64_op;
  assign dec_nice_rs2_pair = nice_64_op;
  assign dec_nice_rd_pair  = nice_64_op;
  assign dec_nice_ilgl     = 1'b0;
endmodule
