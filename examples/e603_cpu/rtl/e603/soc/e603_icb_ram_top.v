 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_icb_ram_top #(
    parameter DELAY_WIDTH=9,
    parameter AW = 12,
    parameter DW = 32
)(
  input  [DELAY_WIDTH-1:0] delay_select,
  input                          icb_cmd_valid,
  output                         icb_cmd_ready,
  input                          icb_cmd_read, 
  input [AW-1:0]                 icb_cmd_addr, 
  input [DW-1:0]                 icb_cmd_wdata,
  input [DW/8-1:0]               icb_cmd_wmask,
  output                         icb_rsp_valid,
  input                          icb_rsp_ready,
  output [DW-1:0]                icb_rsp_rdata,
  output                         icb_rsp_err,
  input                          clk,
  input                          rst_n
  );
parameter AW_LSB      = $clog2(DW)-3;
parameter MW          = DW/8;
parameter DP          = (1<<(AW-AW_LSB));
wire                   ram_cs;
wire [AW-AW_LSB-1:0]   ram_addr;
wire [MW-1:0]          ram_wem;
wire [DW-1:0]          ram_din;
wire [DW-1:0]          ram_dout;
wire                   clk_ram;
wire                   ram_we;
 e603_sram_icb_ctrl #(
      .DW     (DW    ),
      .AW     (AW    ),
      .MW     (MW    ),
      .AW_LSB (AW_LSB),
      .DELAY_WIDTH(DELAY_WIDTH),
      .USR_W  (1     ) 
  ) u_sram_icb_ctrl (
     .delay_select    (delay_select),
     .sram_ctrl_active(             ),
     .tcm_cgstop      (1'b0         ),
     .stall_uop_cmd   (1'b0         ),
     .i_icb_cmd_valid (icb_cmd_valid),
     .i_icb_cmd_ready (icb_cmd_ready),
     .i_icb_cmd_read  (icb_cmd_read ),
     .i_icb_cmd_addr  (icb_cmd_addr ), 
     .i_icb_cmd_wdata (icb_cmd_wdata), 
     .i_icb_cmd_wmask (icb_cmd_wmask), 
     .i_icb_cmd_usr   (1'b0         ),
     .i_icb_rsp_valid (icb_rsp_valid),
     .i_icb_rsp_ready (icb_rsp_ready),
     .i_icb_rsp_rdata (icb_rsp_rdata),
     .i_icb_rsp_usr   (             ),
     .i_icb_rsp_err   (             ),
     .ram_cs          (ram_cs       ),  
     .ram_addr        (ram_addr     ), 
     .ram_we          (ram_we       ),  
     .ram_wem         (ram_wem      ),
     .ram_din         (ram_din      ),          
     .ram_dout        (ram_dout     ),
     .clk_ram         (clk_ram      ),
     .clkgate_bypass  (1'b0         ),
     .clk             (clk          ),
     .rst_n           (rst_n        )  
    );
assign icb_rsp_err = 1'b0;
 e603_gnrl_sim_ram #(
    .FORCE_X2ZERO(1), 
    .DP(DP),
    .DW(DW),
    .MW(MW),
    .AW(AW-AW_LSB) 
  ) u_gnrl_ram(
  .sd  (1'b0  ),
  .ds  (1'b0  ),
  .ls  (1'b0  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n   ),
  .clk   (clk_ram ),
  .cs    (ram_cs  ),
  .addr  (ram_addr),
  .din   (ram_din ),
  .wem   (ram_wem ),
  .we    (ram_we  ),
  .dout  (ram_dout)
  );
endmodule
