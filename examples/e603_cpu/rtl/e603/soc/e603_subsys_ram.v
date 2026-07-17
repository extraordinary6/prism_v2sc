 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
module e603_subsys_ram(
  input  biu2iram_icb_cmd_valid,
  output biu2iram_icb_cmd_ready,
  input  [16-1:0] biu2iram_icb_cmd_addr, 
  input  biu2iram_icb_cmd_read, 
  input  [64-1:0] biu2iram_icb_cmd_wdata,
  input  [8-1:0] biu2iram_icb_cmd_wmask,
  output biu2iram_icb_rsp_valid,
  input  biu2iram_icb_rsp_ready,
  output biu2iram_icb_rsp_err,
  output [64-1:0] biu2iram_icb_rsp_rdata,
  input  biu2dram_icb_cmd_valid,
  output biu2dram_icb_cmd_ready,
  input  [16-1:0] biu2dram_icb_cmd_addr, 
  input  biu2dram_icb_cmd_read, 
  input  [64-1:0] biu2dram_icb_cmd_wdata,
  input  [8-1:0] biu2dram_icb_cmd_wmask,
  output biu2dram_icb_rsp_valid,
  input  biu2dram_icb_rsp_ready,
  output biu2dram_icb_rsp_err,
  output [64-1:0] biu2dram_icb_rsp_rdata,
  input  test_mode,
  input  clk,
  input  aon_clk,
  input  rst_n
  );
  wire iram_icb_cmd_valid; 
  wire iram_icb_cmd_ready; 
  wire iram_icb_cmd_read; 
  wire [16-1:0] iram_icb_cmd_addr;
  wire [64-1:0] iram_icb_cmd_wdata; 
  wire [8-1:0] iram_icb_cmd_wmask;
  wire iram_icb_rsp_valid; 
  wire iram_icb_rsp_ready; 
  wire iram_icb_rsp_err;
  wire [64-1:0] iram_icb_rsp_rdata;
  e603_subsys_iram_ficbnto1_bus # (
    .ARBT_FIFO_OUTS_NUM    (4),
    .ARBT_FIFO_OUTS_CNT_W  (3),
    .ARBT_FIFO_CUT_READY   (1),
    .ARBT_SCHEME           (0),
    .ARBT_ALLOW_0CYCL_RSP  (0),
    .ICB_FIFO_CMD_DP       (0),
    .ICB_FIFO_RSP_DP       (0),
    .ICB_FIFO_CMD_CUT_READY(0),
    .ICB_FIFO_RSP_CUT_READY(0) 
  ) u_iram_icb2to1_bus(
    .icbnto1_active    (),
    .i_clk_en          (1'b1),
    .o_clk_en          (1'b1),
    .o_icb_cmd_sel     (),
    .o_icb_cmd_usr     (),
    .o_icb_rsp_usr     (1'b0),
    .i0_icb_cmd_usr    (1'b0),
    .i1_icb_cmd_usr    (1'b0),
    .i0_icb_rsp_usr    (),
    .i1_icb_rsp_usr    (),
    .o_icb_cmd_valid   (iram_icb_cmd_valid),
    .o_icb_cmd_ready   (iram_icb_cmd_ready),
    .o_icb_cmd_addr    (iram_icb_cmd_addr),
    .o_icb_cmd_read    (iram_icb_cmd_read ),
    .o_icb_cmd_wdata   (iram_icb_cmd_wdata),
    .o_icb_cmd_wmask   (iram_icb_cmd_wmask),
    .o_icb_cmd_lock    (),
    .o_icb_cmd_excl    (),
    .o_icb_cmd_size    (),
    .o_icb_cmd_xlen    (),
    .o_icb_cmd_xburst  (),
    .o_icb_cmd_modes   (),
    .o_icb_cmd_dmode   (),
    .o_icb_cmd_attri   (),
    .o_icb_cmd_beat    (),
    .o_icb_rsp_valid   (iram_icb_rsp_valid),
    .o_icb_rsp_ready   (iram_icb_rsp_ready),
    .o_icb_rsp_err     (iram_icb_rsp_err  ),
    .o_icb_rsp_excl_ok (1'b0),
    .o_icb_rsp_rdata   (iram_icb_rsp_rdata),
    .i0_icb_cmd_sel    (biu2iram_icb_cmd_valid),
    .i0_icb_cmd_valid  (biu2iram_icb_cmd_valid),
    .i0_icb_cmd_ready  (biu2iram_icb_cmd_ready),
    .i0_icb_cmd_addr   (biu2iram_icb_cmd_addr ),
    .i0_icb_cmd_read   (biu2iram_icb_cmd_read ),
    .i0_icb_cmd_wdata  (biu2iram_icb_cmd_wdata),
    .i0_icb_cmd_wmask  (biu2iram_icb_cmd_wmask),
    .i0_icb_cmd_lock   (1'b0),
    .i0_icb_cmd_excl   (1'b0),
    .i0_icb_cmd_size   (3'b0),
    .i0_icb_cmd_xlen   (8'b0),
    .i0_icb_cmd_xburst (2'b0),
    .i0_icb_cmd_modes  (2'b0),
    .i0_icb_cmd_dmode  (1'b0),
    .i0_icb_cmd_attri  (3'b0),
    .i0_icb_cmd_beat   (2'b0),
    .i0_icb_rsp_valid  (biu2iram_icb_rsp_valid),
    .i0_icb_rsp_ready  (biu2iram_icb_rsp_ready),
    .i0_icb_rsp_err    (biu2iram_icb_rsp_err  ),
    .i0_icb_rsp_excl_ok(),
    .i0_icb_rsp_rdata  (biu2iram_icb_rsp_rdata),
    .i1_icb_cmd_sel    (1'b0),
    .i1_icb_cmd_valid  (1'b0),
    .i1_icb_cmd_ready  (),
    .i1_icb_cmd_addr   (16'b0),
    .i1_icb_cmd_read   (1'b0 ),
    .i1_icb_cmd_wdata  (64'b0),
    .i1_icb_cmd_wmask  (8'b0),
    .i1_icb_cmd_lock   (1'b0),
    .i1_icb_cmd_excl   (1'b0),
    .i1_icb_cmd_size   (3'b0),
    .i1_icb_cmd_xlen   (8'b0),
    .i1_icb_cmd_xburst (2'b0),
    .i1_icb_cmd_modes  (2'b0),
    .i1_icb_cmd_dmode  (1'b0),
    .i1_icb_cmd_attri  (3'b0),
    .i1_icb_cmd_beat   (2'b0),
    .i1_icb_rsp_valid  (),
    .i1_icb_rsp_ready  (1'b0),
    .i1_icb_rsp_err    (),
    .i1_icb_rsp_excl_ok(),
    .i1_icb_rsp_rdata  (),
    .clk               (aon_clk),
    .rst_n             (rst_n  ) 
  );
  wire iram_cs;  
  wire iram_we;  
  wire [13-1:0] iram_addr; 
  wire [8-1:0] iram_wem;
  wire [64-1:0] iram_din;          
  wire [64-1:0] iram_dout;
 e603_sram_icb_ctrl #(
      .ECC    (0),
      .RAM_DW (64),
      .RAM_MW (8),
      .DW     (64),
      .MW     (8),
      .CS_W   (1),
      .AW     (16),
      .AW_LSB (3),
      .USR_W  (1) 
  ) u_iram_icb_ctrl (
     .delay_select (9'd0),
     .sram_ctrl_active(),
     .tcm_cgstop      (1'b0),
     .stall_uop_cmd   (1'b0),
     .i_icb_cmd_valid (iram_icb_cmd_valid),
     .i_icb_cmd_ready (iram_icb_cmd_ready),
     .i_icb_cmd_read  (iram_icb_cmd_read ),
     .i_icb_cmd_addr  (iram_icb_cmd_addr ), 
     .i_icb_cmd_wdata (iram_icb_cmd_wdata), 
     .i_icb_cmd_wmask (iram_icb_cmd_wmask), 
     .i_icb_cmd_usr   (1'b0),
     .i_icb_rsp_valid (iram_icb_rsp_valid),
     .i_icb_rsp_ready (iram_icb_rsp_ready),
     .i_icb_rsp_rdata (iram_icb_rsp_rdata),
     .i_icb_rsp_usr   (),
     .i_icb_rsp_err   (iram_icb_rsp_err  ),
     .ram_cs          (iram_cs  ),  
     .ram_addr        (iram_addr), 
     .ram_we          (iram_we  ),  
     .ram_wem         (iram_wem ),
     .ram_din         (iram_din ),          
     .ram_dout        (iram_dout),
     .clk_ram         (),
     .clkgate_bypass  (test_mode),
     .clk             (aon_clk  ),
     .rst_n           (rst_n    )  
    );
  wire iram_clk;
  e603_clkgate u_clk_iram_clkgate(
    .clk_in        (aon_clk ),
    .clkgate_bypass(1'b0    ),
    .clock_en      (iram_cs ),
    .clk_out       (iram_clk)
  );
  e603_subsys_iram_ram u_iram (
    .sd   (1'b0),
    .ds   (1'b0),
    .ls   (1'b0),
    .cs   (iram_cs   ),
    .addr (iram_addr ),
    .we   (iram_we   ),
    .wem  (iram_wem  ),
    .din  (iram_din  ),
    .dout (iram_dout ),
    .rst_n(1'b1      ),
    .clk  (iram_clk  )
    );
  wire dram_icb_cmd_valid; 
  wire dram_icb_cmd_ready; 
  wire dram_icb_cmd_read; 
  wire [16-1:0] dram_icb_cmd_addr;
  wire [64-1:0] dram_icb_cmd_wdata; 
  wire [8-1:0] dram_icb_cmd_wmask;
  wire dram_icb_rsp_valid; 
  wire dram_icb_rsp_ready; 
  wire dram_icb_rsp_err;
  wire [64-1:0] dram_icb_rsp_rdata;
  e603_subsys_dram_ficbnto1_bus # (
    .ARBT_FIFO_OUTS_NUM    (4),
    .ARBT_FIFO_OUTS_CNT_W  (3),
    .ARBT_FIFO_CUT_READY   (1),
    .ARBT_SCHEME           (0),
    .ARBT_ALLOW_0CYCL_RSP  (0),
    .ICB_FIFO_CMD_DP       (0),
    .ICB_FIFO_RSP_DP       (0),
    .ICB_FIFO_CMD_CUT_READY(0),
    .ICB_FIFO_RSP_CUT_READY(0) 
  ) u_dram_icb2to1_bus(
    .icbnto1_active    (),
    .i_clk_en          (1'b1),
    .o_clk_en          (1'b1),
    .o_icb_cmd_sel     (),
    .o_icb_cmd_usr     (),
    .o_icb_rsp_usr     (1'b0),
    .i0_icb_cmd_usr    (1'b0),
    .i1_icb_cmd_usr    (1'b0),
    .i0_icb_rsp_usr    (),
    .i1_icb_rsp_usr    (),
    .o_icb_cmd_valid   (dram_icb_cmd_valid),
    .o_icb_cmd_ready   (dram_icb_cmd_ready),
    .o_icb_cmd_addr    (dram_icb_cmd_addr),
    .o_icb_cmd_read    (dram_icb_cmd_read ),
    .o_icb_cmd_wdata   (dram_icb_cmd_wdata),
    .o_icb_cmd_wmask   (dram_icb_cmd_wmask),
    .o_icb_cmd_lock    (),
    .o_icb_cmd_excl    (),
    .o_icb_cmd_size    (),
    .o_icb_cmd_xlen    (),
    .o_icb_cmd_xburst  (),
    .o_icb_cmd_modes   (),
    .o_icb_cmd_dmode   (),
    .o_icb_cmd_attri   (),
    .o_icb_cmd_beat    (),
    .o_icb_rsp_valid   (dram_icb_rsp_valid),
    .o_icb_rsp_ready   (dram_icb_rsp_ready),
    .o_icb_rsp_err     (dram_icb_rsp_err  ),
    .o_icb_rsp_excl_ok (1'b0),
    .o_icb_rsp_rdata   (dram_icb_rsp_rdata),
    .i0_icb_cmd_sel    (biu2dram_icb_cmd_valid),
    .i0_icb_cmd_valid  (biu2dram_icb_cmd_valid),
    .i0_icb_cmd_ready  (biu2dram_icb_cmd_ready),
    .i0_icb_cmd_addr   (biu2dram_icb_cmd_addr ),
    .i0_icb_cmd_read   (biu2dram_icb_cmd_read ),
    .i0_icb_cmd_wdata  (biu2dram_icb_cmd_wdata),
    .i0_icb_cmd_wmask  (biu2dram_icb_cmd_wmask),
    .i0_icb_cmd_lock   (1'b0),
    .i0_icb_cmd_excl   (1'b0),
    .i0_icb_cmd_size   (3'b0),
    .i0_icb_cmd_xlen   (8'b0),
    .i0_icb_cmd_xburst (2'b0),
    .i0_icb_cmd_modes  (2'b0),
    .i0_icb_cmd_dmode  (1'b0),
    .i0_icb_cmd_attri  (3'b0),
    .i0_icb_cmd_beat   (2'b0),
    .i0_icb_rsp_valid  (biu2dram_icb_rsp_valid),
    .i0_icb_rsp_ready  (biu2dram_icb_rsp_ready),
    .i0_icb_rsp_err    (biu2dram_icb_rsp_err  ),
    .i0_icb_rsp_excl_ok(),
    .i0_icb_rsp_rdata  (biu2dram_icb_rsp_rdata),
    .i1_icb_cmd_sel    (1'b0),
    .i1_icb_cmd_valid  (1'b0),
    .i1_icb_cmd_ready  (),
    .i1_icb_cmd_addr   (16'b0),
    .i1_icb_cmd_read   (1'b0 ),
    .i1_icb_cmd_wdata  (64'b0),
    .i1_icb_cmd_wmask  (8'b0),
    .i1_icb_cmd_lock   (1'b0),
    .i1_icb_cmd_excl   (1'b0),
    .i1_icb_cmd_size   (3'b0),
    .i1_icb_cmd_xlen   (8'b0),
    .i1_icb_cmd_xburst (2'b0),
    .i1_icb_cmd_modes  (2'b0),
    .i1_icb_cmd_dmode  (1'b0),
    .i1_icb_cmd_attri  (3'b0),
    .i1_icb_cmd_beat   (2'b0),
    .i1_icb_rsp_valid  (),
    .i1_icb_rsp_ready  (1'b0),
    .i1_icb_rsp_err    (),
    .i1_icb_rsp_excl_ok(),
    .i1_icb_rsp_rdata  (),
    .clk               (aon_clk),
    .rst_n             (rst_n  ) 
  );
  wire dram_cs;  
  wire dram_we;  
  wire [13-1:0] dram_addr; 
  wire [8-1:0] dram_wem;
  wire [64-1:0] dram_din;          
  wire [64-1:0] dram_dout;
 e603_sram_icb_ctrl #(
      .ECC    (0),
      .RAM_DW (64),
      .RAM_MW (8),
      .DW     (64),
      .MW     (8),
      .CS_W   (1),
      .AW     (16),
      .AW_LSB (3),
      .USR_W  (1) 
  ) u_dram_icb_ctrl (
     .delay_select (9'd0),
     .sram_ctrl_active(),
     .tcm_cgstop      (1'b0),
     .stall_uop_cmd   (1'b0),
     .i_icb_cmd_valid (dram_icb_cmd_valid),
     .i_icb_cmd_ready (dram_icb_cmd_ready),
     .i_icb_cmd_read  (dram_icb_cmd_read ),
     .i_icb_cmd_addr  (dram_icb_cmd_addr ), 
     .i_icb_cmd_wdata (dram_icb_cmd_wdata), 
     .i_icb_cmd_wmask (dram_icb_cmd_wmask), 
     .i_icb_cmd_usr   (1'b0),
     .i_icb_rsp_valid (dram_icb_rsp_valid),
     .i_icb_rsp_ready (dram_icb_rsp_ready),
     .i_icb_rsp_rdata (dram_icb_rsp_rdata),
     .i_icb_rsp_usr   (),
     .i_icb_rsp_err   (dram_icb_rsp_err  ),
     .ram_cs          (dram_cs  ),  
     .ram_addr        (dram_addr), 
     .ram_we          (dram_we  ),  
     .ram_wem         (dram_wem ),
     .ram_din         (dram_din ),          
     .ram_dout        (dram_dout),
     .clk_ram         (),
     .clkgate_bypass  (test_mode),
     .clk             (aon_clk  ),
     .rst_n           (rst_n    )  
    );
  wire dram_clk;
  e603_clkgate u_clk_dram_clkgate(
    .clk_in        (aon_clk ),
    .clkgate_bypass(1'b0    ),
    .clock_en      (dram_cs ),
    .clk_out       (dram_clk)
  );
  e603_subsys_dram_ram u_dram (
    .sd   (1'b0),
    .ds   (1'b0),
    .ls   (1'b0),
    .cs   (dram_cs   ),
    .addr (dram_addr ),
    .we   (dram_we   ),
    .wem  (dram_wem  ),
    .din  (dram_din  ),
    .dout (dram_dout ),
    .rst_n(1'b1      ),
    .clk  (dram_clk  )
    );
endmodule
