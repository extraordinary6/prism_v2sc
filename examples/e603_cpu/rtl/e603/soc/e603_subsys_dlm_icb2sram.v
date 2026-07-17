 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
module e603_dlm_icb2sram_slave # (
   parameter WQ_ALWAYS_DRAIN  = 0
)(
  input              ram_icb_stall                 ,
  input              ram_icb_cmd_valid             ,
  output             ram_icb_cmd_ready             ,
  input              ram_icb_cmd_sel               ,
  input              ram_icb_cmd_read              ,
  input  [  15:   0] ram_icb_cmd_addr              ,
  input  [  63:   0] ram_icb_cmd_wdata             ,
  input  [   7:   0] ram_icb_cmd_wmask             ,
  input  [   2:   0] ram_icb_cmd_size              ,
  input              ram_icb_cmd_lock              ,
  input              ram_icb_cmd_excl              ,
  input  [   7:   0] ram_icb_cmd_xlen              ,
  input  [   1:   0] ram_icb_cmd_xburst            ,
  input  [   1:   0] ram_icb_cmd_modes             ,
  input              ram_icb_cmd_dmode             ,
  input  [   2:   0] ram_icb_cmd_attri             ,
  input  [   1:   0] ram_icb_cmd_beat              ,
  input              ram_icb_rsp_ready             ,
  output             ram_icb_rsp_valid             ,
  output             ram_icb_rsp_err               ,
  output             ram_icb_rsp_excl_ok           ,
  output [  63:   0] ram_icb_rsp_rdata             ,
  output               ram_icb_rsp_itag_valid,  
  output               ram_icb_rsp_valid2agu,  
  output               ram_icb_rsp_flush2agu,  
  output                   ram0_dmode  ,
  output                   ram0_cs  ,
  output [13-1:0]     ram0_addr, 
  output                   ram0_we  ,
  output [4-1:0]     ram0_wem,
  output [32-1:0]     ram0_din,          
  input  [32-1:0]     ram0_dout,
  output                   ram0_clk,
  output                   ram1_dmode  ,
  output                   ram1_cs  ,
  output [13-1:0]     ram1_addr, 
  output                   ram1_we  ,
  output [4-1:0]     ram1_wem,
  output [32-1:0]     ram1_din,          
  input  [32-1:0]     ram1_dout,
  output                   ram1_clk,
  input              clkgate_bypass                ,
  input              clk                           ,
  input              rst_n                         
  );
  assign ram_icb_rsp_excl_ok = 1'b0;
  e603_dlm_icb2sram_noecc u_icb2ram_noecc_ctrl(
     .stall_uop_cmd (ram_icb_stall),
     .icb_cmd_valid (ram_icb_cmd_valid),
     .icb_cmd_ready (ram_icb_cmd_ready),
     .icb_cmd_read  (ram_icb_cmd_read ),
     .icb_cmd_addr  (ram_icb_cmd_addr ), 
     .icb_cmd_size  (ram_icb_cmd_size [1:0]), 
     .icb_cmd_wdata (ram_icb_cmd_wdata), 
     .icb_cmd_wmask (ram_icb_cmd_wmask), 
     .icb_cmd_dmode (ram_icb_cmd_dmode), 
     .icb_rsp_valid (ram_icb_rsp_valid),
     .icb_rsp_ready (ram_icb_rsp_ready),
     .icb_rsp_rdata (ram_icb_rsp_rdata),
     .icb_rsp_err   (ram_icb_rsp_err  ),
     .icb_rsp_itag_valid(ram_icb_rsp_itag_valid),
     .icb_rsp_flush2agu(ram_icb_rsp_flush2agu),
     .icb_rsp_valid2agu(ram_icb_rsp_valid2agu),
     .ram0_dmode  (ram0_dmode  ),  
     .ram0_cs  (ram0_cs  ),  
     .ram0_addr(ram0_addr), 
     .ram0_we  (ram0_we  ),
     .ram0_wem (ram0_wem ),
     .ram0_din (ram0_din ),          
     .ram0_dout(ram0_dout),
     .ram0_clk (ram0_clk ),
     .ram1_dmode  (ram1_dmode  ),  
     .ram1_cs  (ram1_cs  ),  
     .ram1_addr(ram1_addr), 
     .ram1_we  (ram1_we  ),
     .ram1_wem (ram1_wem ),
     .ram1_din (ram1_din ),          
     .ram1_dout(ram1_dout),
     .ram1_clk (ram1_clk ),
     .clkgate_bypass(clkgate_bypass  ),
     .clk  (clk  ),
     .rst_n(rst_n)  
    );
endmodule
module e603_dlm_icb2sram_noecc (
  input            stall_uop_cmd,
  input            icb_cmd_valid, 
  output           icb_cmd_ready, 
  input            icb_cmd_read,  
  input            icb_cmd_dmode, 
  input  [16-1:0] icb_cmd_addr, 
  input  [64-1:0] icb_cmd_wdata, 
  input  [8-1:0] icb_cmd_wmask, 
  input  [1:0]     icb_cmd_size,
  output           icb_rsp_itag_valid, 
  output           icb_rsp_valid2agu, 
  output           icb_rsp_flush2agu, 
  output           icb_rsp_valid, 
  input            icb_rsp_ready, 
  output [64-1:0] icb_rsp_rdata, 
  output           icb_rsp_err,
  output                   ram0_dmode  ,
  output                   ram0_cs  ,
  output [13-1:0]     ram0_addr, 
  output                   ram0_we  ,
  output [4-1:0]     ram0_wem,
  output [32-1:0]     ram0_din,          
  input  [32-1:0]     ram0_dout,
  output                   ram0_clk,
  output                   ram1_dmode  ,
  output                   ram1_cs  ,
  output [13-1:0]     ram1_addr, 
  output                   ram1_we  ,
  output [4-1:0]     ram1_wem,
  output [32-1:0]     ram1_din,          
  input  [32-1:0]     ram1_dout,
  output                   ram1_clk,
  input              clkgate_bypass                ,
  input              clk                           ,
  input              rst_n                         
  );
  wire                   ram_cs  ;
  wire                   ram_dmode  ;
  wire                   ram_we  ;
  wire [13        -1:0]     ram_addr; 
  wire [4*2-1:0]     ram_wem;
  wire [32*2-1:0]     ram_din;          
  wire [32*2-1:0]     ram_dout;
  wire                   ram_clk;
  wire           i_icb_rsp_valid;
  wire           i_icb_rsp_ready;
  wire [64-1:0] i_icb_rsp_rdata;
  wire           i_icb_rsp_err;
  wire           i_icb_rsp_excl_ok;
  wire [66-1:0] i_icb_rsp_pack;
  wire [66-1:0] icb_rsp_pack;
  wire icb_rsp_excl_ok; 
  assign i_icb_rsp_pack = {
                 i_icb_rsp_rdata,
                 i_icb_rsp_err,
                 i_icb_rsp_excl_ok 
  };
  assign {
                 icb_rsp_rdata,
                 icb_rsp_err,
                 icb_rsp_excl_ok 
  } = icb_rsp_pack;
  wire icb_cmd_valid_raw;
  wire icb_cmd_ready_raw;
  assign icb_cmd_valid_raw = (~stall_uop_cmd) & icb_cmd_valid;
  assign icb_cmd_ready     = (~stall_uop_cmd) & icb_cmd_ready_raw;
  e603_gnrl_pipe_stage # (
   .CUT_READY(0),
   .DP(1),
   .DW(1)
  ) u_e1_stage (
    .i_vld(icb_cmd_valid_raw), 
    .i_rdy(icb_cmd_ready_raw), 
    .i_dat(1'b0),
    .o_dat(),
    .o_vld(i_icb_rsp_valid), 
    .o_rdy(i_icb_rsp_ready), 
    .clk  (clk  ),
    .rst_n(rst_n)  
   );
   assign i_icb_rsp_rdata = ram_dout;
   assign i_icb_rsp_err   = 1'b0;
   assign i_icb_rsp_excl_ok   = 1'b0;
  e603_gnrl_pipe_stage # (
   .CUT_READY(0),
   .DP(0),
   .DW(66)
  ) u_e2_stage (
    .i_vld(i_icb_rsp_valid), 
    .i_rdy(i_icb_rsp_ready), 
    .i_dat(i_icb_rsp_pack),
    .o_vld(icb_rsp_valid), 
    .o_rdy(icb_rsp_ready), 
    .o_dat(icb_rsp_pack ),
    .clk  (clk  ),
    .rst_n(rst_n)  
   );
  wire i_icb_rsp_hsked = i_icb_rsp_valid & i_icb_rsp_ready;
  wire icb_rsp_hsked = icb_rsp_valid & icb_rsp_ready;
  assign icb_rsp_valid2agu = icb_rsp_itag_valid;
  assign icb_rsp_flush2agu = 1'b0;
      assign icb_rsp_itag_valid = icb_rsp_valid;
   wire   icb2sram_active = icb_cmd_valid | i_icb_rsp_valid | icb_rsp_valid;
   assign ram_we  = (~icb_cmd_read);  
   assign ram_cs  = icb_cmd_valid & icb_cmd_ready;  
   assign ram_addr= icb_cmd_addr [13+3-1:3];
   assign ram_dmode  = icb_cmd_dmode;  
   assign ram_wem = {8{ram_we}} & icb_cmd_wmask[4*2-1:0];          
   assign ram_din = icb_cmd_wdata[32*2-1:0];   
  e603_clkgate u_sram0_clkgate(
    .clk_in   (clk),
    .clkgate_bypass(clkgate_bypass  ),
    .clock_en (ram0_cs),
    .clk_out  (ram0_clk)
  );
  e603_clkgate u_sram1_clkgate(
    .clk_in   (clk),
    .clkgate_bypass(clkgate_bypass  ),
    .clock_en (ram1_cs),
    .clk_out  (ram1_clk)
  );
   assign ram0_dmode = ram_dmode;
   assign ram1_dmode = ram_dmode;
   assign ram0_cs = ram_cs & ((&icb_cmd_size) | (~icb_cmd_addr[3-1]));  
   assign ram1_cs = ram_cs & ((&icb_cmd_size) | ( icb_cmd_addr[3-1]));
   assign ram0_we = ram_we;
   assign ram1_we = ram_we;
   assign ram0_addr = ram_addr;
   assign ram1_addr = ram_addr;
   assign {ram1_wem, ram0_wem} = ram_wem;
   assign {ram1_din, ram0_din} = ram_din;
   assign ram_dout             = {ram1_dout,ram0_dout};
endmodule
