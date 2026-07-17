 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module nuclei_sdio_top (
    input              sdio_icb_cmd_valid            ,
  output             sdio_icb_cmd_ready            ,
  input              sdio_icb_cmd_sel              ,
  input              sdio_icb_cmd_read             ,
  input  [  11:   0] sdio_icb_cmd_addr             ,
  input  [  31:   0] sdio_icb_cmd_wdata            ,
  input  [   3:   0] sdio_icb_cmd_wmask            ,
  input  [   2:   0] sdio_icb_cmd_size             ,
  input              sdio_icb_cmd_lock             ,
  input              sdio_icb_cmd_excl             ,
  input  [   7:   0] sdio_icb_cmd_xlen             ,
  input  [   1:   0] sdio_icb_cmd_xburst           ,
  input  [   1:   0] sdio_icb_cmd_modes            ,
  input              sdio_icb_cmd_dmode            ,
  input  [   2:   0] sdio_icb_cmd_attri            ,
  input  [   1:   0] sdio_icb_cmd_beat             ,
  input              sdio_icb_rsp_ready            ,
  output             sdio_icb_rsp_valid            ,
  output             sdio_icb_rsp_err              ,
  output             sdio_icb_rsp_excl_ok          ,
  output [  31:   0] sdio_icb_rsp_rdata            ,
  input              sdclk_i_ival                  ,
  output             sdclk_o_oval                  ,
  output             sdclk_o_oe                    ,
  output             sdclk_o_pue                   ,
  input              sdcmd_i_ival                  ,
  output             sdcmd_o_oval                  ,
  output             sdcmd_o_oe                    ,
  output             sdcmd_o_pue                   ,
  input              sddata0_i_ival                ,
  output             sddata0_o_oval                ,
  output             sddata0_o_oe                  ,
  output             sddata0_o_pue                 ,
  input              sddata1_i_ival                ,
  output             sddata1_o_oval                ,
  output             sddata1_o_oe                  ,
  output             sddata1_o_pue                 ,
  input              sddata2_i_ival                ,
  output             sddata2_o_oval                ,
  output             sddata2_o_oe                  ,
  output             sddata2_o_pue                 ,
  input              sddata3_i_ival                ,
  output             sddata3_o_oval                ,
  output             sddata3_o_oe                  ,
  output             sddata3_o_pue                 ,
  input              sddata4_i_ival                ,
  output             sddata4_o_oval                ,
  output             sddata4_o_oe                  ,
  output             sddata4_o_pue                 ,
  input              sddata5_i_ival                ,
  output             sddata5_o_oval                ,
  output             sddata5_o_oe                  ,
  output             sddata5_o_pue                 ,
  input              sddata6_i_ival                ,
  output             sddata6_o_oval                ,
  output             sddata6_o_oe                  ,
  output             sddata6_o_pue                 ,
  input              sddata7_i_ival                ,
  output             sddata7_o_oval                ,
  output             sddata7_o_oe                  ,
  output             sddata7_o_pue                 ,
  input              clk                           ,
  input              rst_n                         ,
  input              sdio_clk                      ,
  input              reset_bypass                  ,
  output             sdio_irq                      
);
ioxpnqbc7aqwqrifv wm88zepqx4xt(
  .ri2ziyy(clk),
  .r46kf(rst_n),
  .x9t4ls4jmm(sdio_clk),
  .nhmow92ziyrfc2(reset_bypass),
    .mxwg8lfgv4pge1                  (sdio_icb_cmd_valid                       ),
  .qi_euczbjhgo1za                  (sdio_icb_cmd_ready                       ),
  .mqxw6of2d4b4nr7b                    (sdio_icb_cmd_sel                         ),
  .cuu3goyrnwc9hf                   (sdio_icb_cmd_read                        ),
  .t3lk20ui52aqc6                   (sdio_icb_cmd_addr             [  11:   0]),
  .rs8qfdkpko8pq                  (sdio_icb_cmd_wdata            [  31:   0]),
  .swwpvt6gm3cz8                  (sdio_icb_cmd_wmask            [   3:   0]),
  .pccr2d0febxqx                   (sdio_icb_cmd_size             [   2:   0]),
  .vah0tsdviw4b                   (sdio_icb_cmd_lock                        ),
  .u7u7t6iaofiovjc                   (sdio_icb_cmd_excl                        ),
  .xwpttmbn8xqi2b0qg                   (sdio_icb_cmd_xlen             [   7:   0]),
  .j7onlxu8c84rohjl3                 (sdio_icb_cmd_xburst           [   1:   0]),
  .abuhy0_a307fr_734f                  (sdio_icb_cmd_modes            [   1:   0]),
  .xi4mxnyfh8q6pd2                  (sdio_icb_cmd_dmode                       ),
  .le80uwswd0y0q8                  (sdio_icb_cmd_attri            [   2:   0]),
  .p5nleje0lb8ux                   (sdio_icb_cmd_beat             [   1:   0]),
  .ptdklfwbs2d13                  (sdio_icb_rsp_ready                       ),
  .l_geblczxuwi5x4e                  (sdio_icb_rsp_valid                       ),
  .r1ukfidrb_5kvibw                    (sdio_icb_rsp_err                         ),
  .nhup3xqrnngwbqsg_e                (sdio_icb_rsp_excl_ok                     ),
  .nuvz1doibyin1uaa                  (sdio_icb_rsp_rdata            [  31:   0]),
  .faqpcbe4751rx                   (sdclk_i_ival                             ),
  .es2eisdm0qu3                   (sdclk_o_oval                             ),
  .wkwscugp5re                     (sdclk_o_oe                               ),
  .ce4q39qw2gn0                    (sdclk_o_pue                              ),
  .j0ymi3se1vtv                   (sdcmd_i_ival                             ),
  .ula1fsl673girmu                   (sdcmd_o_oval                             ),
  .jy8f6iovbm                     (sdcmd_o_oe                               ),
  .aoofou61a0iq                    (sdcmd_o_pue                              ),
  .s35jhrn02ch4omla86m                 (sddata0_i_ival                           ),
  .agxndvfnxt1lq3nz                 (sddata0_o_oval                           ),
  .f649ftjq8dd47v7s                   (sddata0_o_oe                             ),
  .pc2xuy_fyjus3                  (sddata0_o_pue                            ),
  .ipatp60owfx8c9                 (sddata1_i_ival                           ),
  .kiypykzrw_fdhxb                 (sddata1_o_oval                           ),
  .hvblb8fnvykeisty                   (sddata1_o_oe                             ),
  .loao5ar4y59i7dy                  (sddata1_o_pue                            ),
  .axf_lvtru_gky2vx                 (sddata2_i_ival                           ),
  .y0ifgrg4j8xe1z_e                 (sddata2_o_oval                           ),
  .y_utkzr29tc_rjqx9                   (sddata2_o_oe                             ),
  .utnb83_6j8sa_k                  (sddata2_o_pue                            ),
  .dkndzqtx29xy_gey8p                 (sddata3_i_ival                           ),
  .mj4c7hhslgsjy9bt                 (sddata3_o_oval                           ),
  .i6573hvtpcm16                   (sddata3_o_oe                             ),
  .zxmk7fbbwufsu2wy8                  (sddata3_o_pue                            ),
  .esqkfu_ee6jfpik74y                 (sddata4_i_ival                           ),
  .drlefxcf3_j2lppdm_                 (sddata4_o_oval                           ),
  .va0j6og_ll80oj                   (sddata4_o_oe                             ),
  .dy2liyrkkic1u                  (sddata4_o_pue                            ),
  .s3x0920mp6a8e_k7xox                 (sddata5_i_ival                           ),
  .pm30xgj2vj2smr71b1u                 (sddata5_o_oval                           ),
  .j8qu4ksipdiygyj2r                   (sddata5_o_oe                             ),
  .tyd569koo37unwhw                  (sddata5_o_pue                            ),
  .hkmux_qq6fgq58j                 (sddata6_i_ival                           ),
  .gfb43rrs4k_3sx1jaka                 (sddata6_o_oval                           ),
  .crxkbbsftdo8e                   (sddata6_o_oe                             ),
  .cbb6qt91iz4rzait2                  (sddata6_o_pue                            ),
  .biaikjakr36558d                 (sddata7_i_ival                           ),
  .m0kao6qjv0umm2ulcgd                 (sddata7_o_oval                           ),
  .a56yiaqw9t1t0                   (sddata7_o_oe                             ),
  .x5o1z7p1fq7zycs                  (sddata7_o_pue                            ),
  .c_6y8qe_ucl(sdio_irq)
);
endmodule
module sdio_gnrl_0dfflr # (
  parameter DW = 32
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
assign qout = dnxt;
endmodule
module sdio_gnrl_0dffl # (
  parameter DW = 32
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk
);
assign qout = dnxt;
endmodule
module sdio_gnrl_dfflrs # (
  parameter DW   = 32
, parameter [DW-1:0]  RST  = {DW{1'b1}}
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= RST;
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
endmodule
module sdio_gnrl_cdc_dfflrs # (
  parameter DW   = 32
, parameter [DW-1:0]  RST  = {DW{1'b1}}
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block Ac_unsync01
// SMD: Checks unsynchronized crossings for scalar signals
// spyglass disable_block Ac_unsync02
// SMD: Checks unsynchronized crossings for vector signals
// spyglass disable_block Ar_asyncdeassert01
// SMD: Reports if reset signal is asynchronously deasserted
// spyglass disable_block Ar_unsync01
// SMD: Reports unsynchronized reset signals in the design
// spyglass disable_block Reset_sync02
// SMD: Reports asynchronous reset signals which are generated in asynchronous clock domain
// spyglass disable_block Ac_glitch04
// SMD: Reports clock domain crossings subject to glitches
// spyglass disable_block Clock_sync05a
// SMD: Reports primary inputs sampled by multiple clock domains
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets synchronized more than once in the same clock domain
// spyglass disable_block Ac_cdc01a
// SMD: Checks data loss for multi-flop or sync cell or qualifier synchronized clock domain
// SJ:  CDC register does not need to check for CDC rules
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= RST;
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ac_unsync02
// spyglass enable_block Ar_asyncdeassert01
// spyglass enable_block Ar_unsync01
// spyglass enable_block Reset_sync02
// spyglass enable_block Ac_glitch04
// spyglass enable_block Clock_sync05a
// spyglass enable_block Reset_sync04
// spyglass enable_block Ac_cdc01a
endmodule
module sdio_gnrl_prot_dfflrs # (
  parameter DW   = 32
, parameter [DW-1:0]  RST  = {DW{1'b1}}
) (
  output              error,
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
localparam [0:0]    PAR_RESET   = (^RST) & 1;
reg [DW:0] mu8spjb6;
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {PAR_RESET, RST};
  else if (lden == 1'b1)
    mu8spjb6 <= {^dnxt, dnxt};
end
assign qout = mu8spjb6[DW-1:0];
assign error = mu8spjb6[DW] != (^qout);
// spyglass enable_block UnrecSynthDir-ML
endmodule
module sdio_gnrl_prot_cdc_dfflrs # (
  parameter DW   = 32
, parameter [DW-1:0]  RST  = {DW{1'b1}}
) (
  output              error,
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
localparam [0:0]    PAR_RESET   = (^RST) & 1;
reg [DW:0] mu8spjb6;
// spyglass disable_block Ac_unsync01
// SMD: Checks unsynchronized crossings for scalar signals
// spyglass disable_block Ac_unsync02
// SMD: Checks unsynchronized crossings for vector signals
// spyglass disable_block Ar_asyncdeassert01
// SMD: Reports if reset signal is asynchronously deasserted
// spyglass disable_block Ar_unsync01
// SMD: Reports unsynchronized reset signals in the design
// spyglass disable_block Reset_sync02
// SMD: Reports asynchronous reset signals which are generated in asynchronous clock domain
// spyglass disable_block Ac_glitch04
// SMD: Reports clock domain crossings subject to glitches
// spyglass disable_block Clock_sync05a
// SMD: Reports primary inputs sampled by multiple clock domains
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets synchronized more than once in the same clock domain
// spyglass disable_block Ac_cdc01a
// SMD: Checks data loss for multi-flop or sync cell or qualifier synchronized clock domain
// SJ:  CDC register does not need to check for CDC rules
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {PAR_RESET, RST};
  else if (lden == 1'b1)
    mu8spjb6 <= {^dnxt, dnxt};
end
assign qout = mu8spjb6[DW-1:0];
assign error = mu8spjb6[DW] != (^qout);
// spyglass enable_block UnrecSynthDir-ML
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ac_unsync02
// spyglass enable_block Ar_asyncdeassert01
// spyglass enable_block Ar_unsync01
// spyglass enable_block Reset_sync02
// spyglass enable_block Ac_glitch04
// spyglass enable_block Clock_sync05a
// spyglass enable_block Reset_sync04
// spyglass enable_block Ac_cdc01a
endmodule
module sdio_gnrl_dfflr # (
  parameter DW   = 32
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
endmodule
module sdio_gnrl_cdc_dfflr # (
  parameter DW   = 32
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block Ac_unsync01
// SMD: Checks unsynchronized crossings for scalar signals
// spyglass disable_block Ac_unsync02
// SMD: Checks unsynchronized crossings for vector signals
// spyglass disable_block Ar_asyncdeassert01
// SMD: Reports if reset signal is asynchronously deasserted
// spyglass disable_block Ar_unsync01
// SMD: Reports unsynchronized reset signals in the design
// spyglass disable_block Reset_sync02
// SMD: Reports asynchronous reset signals which are generated in asynchronous clock domain
// spyglass disable_block Ac_glitch04
// SMD: Reports clock domain crossings subject to glitches
// spyglass disable_block Clock_sync05a
// SMD: Reports primary inputs sampled by multiple clock domains
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets synchronized more than once in the same clock domain
// spyglass disable_block Ac_cdc01a
// SMD: Checks data loss for multi-flop or sync cell or qualifier synchronized clock domain
// SJ:  CDC register does not need to check for CDC rules
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ac_unsync02
// spyglass enable_block Ar_asyncdeassert01
// spyglass enable_block Ar_unsync01
// spyglass enable_block Reset_sync02
// spyglass enable_block Ac_glitch04
// spyglass enable_block Clock_sync05a
// spyglass enable_block Reset_sync04
// spyglass enable_block Ac_cdc01a
endmodule
module sdio_gnrl_prot_dfflr # (
  parameter DW   = 32
) (
  output              error,
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW:0] mu8spjb6;
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {(DW+1){1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= {^dnxt, dnxt};
end
assign qout = mu8spjb6[DW-1:0];
assign error = mu8spjb6[DW] != (^qout);
// spyglass enable_block UnrecSynthDir-ML
endmodule
module sdio_gnrl_prot_cdc_dfflr # (
  parameter DW   = 32
) (
  output              error,
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW:0] mu8spjb6;
// spyglass disable_block Ac_unsync01
// SMD: Checks unsynchronized crossings for scalar signals
// spyglass disable_block Ac_unsync02
// SMD: Checks unsynchronized crossings for vector signals
// spyglass disable_block Ar_asyncdeassert01
// SMD: Reports if reset signal is asynchronously deasserted
// spyglass disable_block Ar_unsync01
// SMD: Reports unsynchronized reset signals in the design
// spyglass disable_block Reset_sync02
// SMD: Reports asynchronous reset signals which are generated in asynchronous clock domain
// spyglass disable_block Ac_glitch04
// SMD: Reports clock domain crossings subject to glitches
// spyglass disable_block Clock_sync05a
// SMD: Reports primary inputs sampled by multiple clock domains
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets synchronized more than once in the same clock domain
// spyglass disable_block Ac_cdc01a
// SMD: Checks data loss for multi-flop or sync cell or qualifier synchronized clock domain
// SJ:  CDC register does not need to check for CDC rules
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {(DW+1){1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= {^dnxt, dnxt};
end
assign qout = mu8spjb6[DW-1:0];
assign error = mu8spjb6[DW] != (^qout);
// spyglass enable_block UnrecSynthDir-ML
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ac_unsync02
// spyglass enable_block Ar_asyncdeassert01
// spyglass enable_block Ar_unsync01
// spyglass enable_block Reset_sync02
// spyglass enable_block Ac_glitch04
// spyglass enable_block Clock_sync05a
// spyglass enable_block Reset_sync04
// spyglass enable_block Ac_cdc01a
endmodule
module sdio_gnrl_dfflrc # (
  parameter DW   = 32
) (
  input               clr,
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else if (clr == 1'b1)
    mu8spjb6 <= {DW{1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
endmodule
module sdio_gnrl_cdc_dfflrc # (
  parameter DW   = 32
) (
  input               clr,
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block Ac_unsync01
// SMD: Checks unsynchronized crossings for scalar signals
// spyglass disable_block Ac_unsync02
// SMD: Checks unsynchronized crossings for vector signals
// spyglass disable_block Ar_asyncdeassert01
// SMD: Reports if reset signal is asynchronously deasserted
// spyglass disable_block Ar_unsync01
// SMD: Reports unsynchronized reset signals in the design
// spyglass disable_block Reset_sync02
// SMD: Reports asynchronous reset signals which are generated in asynchronous clock domain
// spyglass disable_block Ac_glitch04
// SMD: Reports clock domain crossings subject to glitches
// spyglass disable_block Clock_sync05a
// SMD: Reports primary inputs sampled by multiple clock domains
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets synchronized more than once in the same clock domain
// spyglass disable_block Ac_cdc01a
// SMD: Checks data loss for multi-flop or sync cell or qualifier synchronized clock domain
// SJ:  CDC register does not need to check for CDC rules
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else if (clr == 1'b1)
    mu8spjb6 <= {DW{1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ac_unsync02
// spyglass enable_block Ar_asyncdeassert01
// spyglass enable_block Ar_unsync01
// spyglass enable_block Reset_sync02
// spyglass enable_block Ac_glitch04
// spyglass enable_block Clock_sync05a
// spyglass enable_block Reset_sync04
// spyglass enable_block Ac_cdc01a
endmodule
module sdio_gnrl_dffl # (
  parameter DW   = 32
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
endmodule
module sdio_gnrl_cdc_dffl # (
  parameter DW   = 32
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block Ac_unsync01
// SMD: Checks unsynchronized crossings for scalar signals
// spyglass disable_block Ac_unsync02
// SMD: Checks unsynchronized crossings for vector signals
// spyglass disable_block Ar_asyncdeassert01
// SMD: Reports if reset signal is asynchronously deasserted
// spyglass disable_block Ar_unsync01
// SMD: Reports unsynchronized reset signals in the design
// spyglass disable_block Reset_sync02
// SMD: Reports asynchronous reset signals which are generated in asynchronous clock domain
// spyglass disable_block Ac_glitch04
// SMD: Reports clock domain crossings subject to glitches
// spyglass disable_block Clock_sync05a
// SMD: Reports primary inputs sampled by multiple clock domains
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets synchronized more than once in the same clock domain
// spyglass disable_block Ac_cdc01a
// SMD: Checks data loss for multi-flop or sync cell or qualifier synchronized clock domain
// SJ:  CDC register does not need to check for CDC rules
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ac_unsync02
// spyglass enable_block Ar_asyncdeassert01
// spyglass enable_block Ar_unsync01
// spyglass enable_block Reset_sync02
// spyglass enable_block Ac_glitch04
// spyglass enable_block Clock_sync05a
// spyglass enable_block Reset_sync04
// spyglass enable_block Ac_cdc01a
endmodule
module sdio_gnrl_dff # (
  parameter DW   = 32
) (
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
endmodule
module sdio_gnrl_cdc_dff # (
  parameter DW   = 32
) (
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block Ac_unsync01
// SMD: Checks unsynchronized crossings for scalar signals
// spyglass disable_block Ac_unsync02
// SMD: Checks unsynchronized crossings for vector signals
// spyglass disable_block Ar_asyncdeassert01
// SMD: Reports if reset signal is asynchronously deasserted
// spyglass disable_block Ar_unsync01
// SMD: Reports unsynchronized reset signals in the design
// spyglass disable_block Reset_sync02
// SMD: Reports asynchronous reset signals which are generated in asynchronous clock domain
// spyglass disable_block Ac_glitch04
// SMD: Reports clock domain crossings subject to glitches
// spyglass disable_block Clock_sync05a
// SMD: Reports primary inputs sampled by multiple clock domains
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets synchronized more than once in the same clock domain
// spyglass disable_block Ac_cdc01a
// SMD: Checks data loss for multi-flop or sync cell or qualifier synchronized clock domain
// SJ:  CDC register does not need to check for CDC rules
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ac_unsync02
// spyglass enable_block Ar_asyncdeassert01
// spyglass enable_block Ar_unsync01
// spyglass enable_block Reset_sync02
// spyglass enable_block Ac_glitch04
// spyglass enable_block Clock_sync05a
// spyglass enable_block Reset_sync04
// spyglass enable_block Ac_cdc01a
endmodule
module sdio_gnrl_dffrs # (
  parameter DW   = 32
, parameter [DW-1:0]  RST  = {DW{1'b1}}
) (
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= RST;
  else
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
endmodule
module sdio_gnrl_cdc_dffrs # (
  parameter DW   = 32
, parameter [DW-1:0]  RST  = {DW{1'b1}}
) (
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block Ac_unsync01
// SMD: Checks unsynchronized crossings for scalar signals
// spyglass disable_block Ac_unsync02
// SMD: Checks unsynchronized crossings for vector signals
// spyglass disable_block Ar_asyncdeassert01
// SMD: Reports if reset signal is asynchronously deasserted
// spyglass disable_block Ar_unsync01
// SMD: Reports unsynchronized reset signals in the design
// spyglass disable_block Reset_sync02
// SMD: Reports asynchronous reset signals which are generated in asynchronous clock domain
// spyglass disable_block Ac_glitch04
// SMD: Reports clock domain crossings subject to glitches
// spyglass disable_block Clock_sync05a
// SMD: Reports primary inputs sampled by multiple clock domains
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets synchronized more than once in the same clock domain
// spyglass disable_block Ac_cdc01a
// SMD: Checks data loss for multi-flop or sync cell or qualifier synchronized clock domain
// SJ:  CDC register does not need to check for CDC rules
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= RST;
  else
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ac_unsync02
// spyglass enable_block Ar_asyncdeassert01
// spyglass enable_block Ar_unsync01
// spyglass enable_block Reset_sync02
// spyglass enable_block Ac_glitch04
// spyglass enable_block Clock_sync05a
// spyglass enable_block Reset_sync04
// spyglass enable_block Ac_cdc01a
endmodule
module sdio_gnrl_dffr # (
  parameter DW   = 32
) (
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
endmodule
module sdio_gnrl_cdc_dffr # (
  parameter DW   = 32
) (
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
// spyglass disable_block Ac_unsync01
// SMD: Checks unsynchronized crossings for scalar signals
// spyglass disable_block Ac_unsync02
// SMD: Checks unsynchronized crossings for vector signals
// spyglass disable_block Ar_asyncdeassert01
// SMD: Reports if reset signal is asynchronously deasserted
// spyglass disable_block Ar_unsync01
// SMD: Reports unsynchronized reset signals in the design
// spyglass disable_block Reset_sync02
// SMD: Reports asynchronous reset signals which are generated in asynchronous clock domain
// spyglass disable_block Ac_glitch04
// SMD: Reports clock domain crossings subject to glitches
// spyglass disable_block Clock_sync05a
// SMD: Reports primary inputs sampled by multiple clock domains
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets synchronized more than once in the same clock domain
// spyglass disable_block Ac_cdc01a
// SMD: Checks data loss for multi-flop or sync cell or qualifier synchronized clock domain
// SJ:  CDC register does not need to check for CDC rules
// spyglass disable_block UnrecSynthDir-ML 
// SMD: Synthesis directive is not recognized 
// SJ:  infer_multibit is okay to be here
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
// spyglass enable_block UnrecSynthDir-ML
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ac_unsync02
// spyglass enable_block Ar_asyncdeassert01
// spyglass enable_block Ar_unsync01
// spyglass enable_block Reset_sync02
// spyglass enable_block Ac_glitch04
// spyglass enable_block Clock_sync05a
// spyglass enable_block Reset_sync04
// spyglass enable_block Ac_cdc01a
endmodule
module sdio_hand_mux (X, S, D0, D1);
  parameter N = 1;
  output [N-1:0] X;
  input          S;
  input  [N-1:0] D0, D1;
  genvar gvi;
  generate
  for (gvi=0;gvi<N;gvi=gvi+1) begin: GEN_hand_mux_mult
    sdio_hand_mux_bit
     U_hand_mux_bit (
        .X  (X[gvi])
      , .S  (S)
      , .D0 (D0[gvi])
      , .D1 (D1[gvi])
    );
    end 
  endgenerate
endmodule 
module sdio_gnrl_pipe_stage # (
  parameter CUT_READY = 0,
  parameter PAYLOAD_NORST = 0,
  parameter DP = 1,
  parameter DW = 32,
  parameter EW = DP == 0 ? 1 : ((DW-1)/64+1) + 1
) (
  input           i_vld,
  output          i_rdy,
  input  [DW-1:0] i_dat,
  output          o_vld,
  input           o_rdy,
  output [DW-1:0] o_dat,
  input           clk,
  input           rst_n
);
  genvar zyod33;
  generate 
  if(DP == 0) begin: dvpogtgtaokyw
      assign o_vld = i_vld;
      assign i_rdy = o_rdy;
      assign o_dat = i_dat;
  end
  else begin: hq4we39bcct2
      wire tfg65l4rq;
      wire xovok62;
      wire plcb43cn;
      wire qmm5xj7602;
      wire buntd6lyr;
      assign tfg65l4rq = i_vld & i_rdy;
      assign xovok62 = o_vld & o_rdy;
      assign plcb43cn = tfg65l4rq | xovok62;
      assign buntd6lyr = tfg65l4rq | (~xovok62);
sdio_gnrl_dfflr #(1) o5sm6_ezj0 (plcb43cn, buntd6lyr, qmm5xj7602, clk, rst_n);
    if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_dffl #(DW) p0h_y3ynxzt11 (tfg65l4rq, i_dat, o_dat, clk, rst_n);
    end
    else begin: lsj8oc4vo
sdio_gnrl_dfflr #(DW) pahw0w_h517 (tfg65l4rq, i_dat, o_dat, clk, rst_n);
    end
      assign o_vld = qmm5xj7602;
      if(CUT_READY == 1) begin:zx3zppx4bdss_l
          assign i_rdy = (~qmm5xj7602);
      end
      else begin:bnzuc64my8yotquyxmz
          assign i_rdy = (~qmm5xj7602) | xovok62;
      end
  end
  endgenerate
endmodule
module sdio_gnrl_sync # (
  parameter DP = 2,
  parameter DW = 32,
  parameter [DW-1:0] RST_VAL = {DW{1'b0}}
) (
  input  [DW-1:0] din_a,
  output [DW-1:0] dout,
  input           rst_n,
  input           clk
);
`ifdef SYNTHESIS
 e603_gnrl_tech_sync #(
  .DP      (DP),
  .DW      (DW),
  .RST_VAL (RST_VAL)
) nonlhws (
  .din_a (din_a  ),
  .dout  (dout   ),
  .rst_n (rst_n  ),
  .clk   (clk    )
);
`else
  wire [DW-1:0] ocl1eh0cw [DP-1:0];
  genvar zyod33;
  generate
  for(zyod33=0;zyod33<DP;zyod33=zyod33+1) begin:hbx5wzh7
    if(zyod33==0) begin:yytwajlol34m
      sdio_gnrl_cdc_dffrs #(DW, RST_VAL) sync_gnrl_cdc_dest_dffrs(din_a,         ocl1eh0cw[0], clk, rst_n);  
    end
    else begin:aqslqoe0if2p42r1kw
sdio_gnrl_dffrs #(DW, RST_VAL) mvpt0xva_nk(ocl1eh0cw[zyod33-1], ocl1eh0cw[zyod33], clk, rst_n);
    end
  end
  endgenerate
  assign dout = ocl1eh0cw[DP-1];
`endif
endmodule
module sdio_gnrl_bus_sync (
  clk_s
  , rst_s_n
  , bus_s
  , clk_d
  , rst_d_n
  , bus_d
);
  parameter DW = 8;
  parameter DP = 2;
  input           clk_s;
  input           rst_s_n;
  input  [DW-1:0] bus_s;
  input           clk_d;
  input           rst_d_n;
  output [DW-1:0] bus_d;
  wire          c2_3bfbn;
  wire [DW-1:0] topah7ec;
  wire          zpftgdilpgw;
  wire          s2juwe;
  wire          oucfyjzf;
  wire [DW-1:0] ztjdd_g9vb;
  wire          dq83vdxmfor1;
  wire          c7qxuy8uw;
  sdio_gnrl_sync  #(
  .DW(1),
  .DP(DP))
  ui6i7eh1km7fr8 (
  .clk(clk_s),
  .rst_n(rst_s_n),
  .din_a(oucfyjzf),
  .dout(zpftgdilpgw)
  );
  assign s2juwe = c2_3bfbn ^~ zpftgdilpgw;
  wire g57qngpr4;
  assign g57qngpr4 = s2juwe ^ c2_3bfbn;
sdio_gnrl_dffr #(1) aawd68y_qbb1r2700 (g57qngpr4, c2_3bfbn, clk_s, rst_s_n);
  wire [DW-1:0] j7nc8ps_gc4d;
  assign j7nc8ps_gc4d = s2juwe ? bus_s : topah7ec;
  sdio_gnrl_cdc_dffr #(DW) U_bus_s_r_gnrl_cdc_dest_dffr (j7nc8ps_gc4d, topah7ec, clk_s, rst_s_n);  
  sdio_gnrl_sync  #(
  .DW(1),
  .DP(DP))
  wq6wol60esk1jp0xwit (
  .clk(clk_d),
  .rst_n(rst_d_n),
  .din_a(c2_3bfbn),
  .dout(dq83vdxmfor1)
  );
  assign c7qxuy8uw = oucfyjzf ^ dq83vdxmfor1;
  wire gdc4f0_l3;
  assign gdc4f0_l3 = c7qxuy8uw ^ oucfyjzf;
sdio_gnrl_dffr #(1) r_17v3jmw3_vtu (gdc4f0_l3, oucfyjzf, clk_d, rst_d_n);
  wire [DW-1:0] dnirhjde_jp4ce;
  assign dnirhjde_jp4ce = c7qxuy8uw ? topah7ec : ztjdd_g9vb;
  sdio_gnrl_cdc_dffr #(DW) U_bus_d_r_gnrl_cdc_dest_dffr (dnirhjde_jp4ce, ztjdd_g9vb, clk_d, rst_d_n); 
  assign bus_d = ztjdd_g9vb;
endmodule
module sdio_gnrl_rrobin_1cycle # (
    parameter ARBT_NUM = 4
)(
  output rrobin_active,
  output[ARBT_NUM-1:0] grt_vec,
  input [ARBT_NUM-1:0] req_vec,
  input arbt_ena,
  input clk,
  input rst_n
);
wire               qm6uphqvb9w;
wire               ay3inlc7esnc8;
wire [ARBT_NUM-1:0] nij4iu0isn;
wire [ARBT_NUM-1:0] io603al4;
wire [ARBT_NUM-1:0] m14znsr_hekiy5j3;
wire [ARBT_NUM-1:0] vopg5ab7mmi0yp8v2if0;
genvar zyod33;
generate
  for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
  begin:b55mifo9
    assign m14znsr_hekiy5j3[zyod33] = |req_vec[zyod33:0];
  end
endgenerate
assign vopg5ab7mmi0yp8v2if0 = {m14znsr_hekiy5j3[ARBT_NUM-2:0],1'b0};
wire [ARBT_NUM-1:0] nz48be6rsny3hiv1chavm2xj7;
assign nz48be6rsny3hiv1chavm2xj7= vopg5ab7mmi0yp8v2if0 & req_vec;
wire qf8r9k_xyvx7ooz60bo = ~(|nz48be6rsny3hiv1chavm2xj7);
wire o3jlwf_zxg9168kyy = (|req_vec);
wire ar2pcf5farztsd5f405  = ~qf8r9k_xyvx7ooz60bo;
assign qm6uphqvb9w = o3jlwf_zxg9168kyy & ar2pcf5farztsd5f405;
assign ay3inlc7esnc8  = qm6uphqvb9w & arbt_ena;
sdio_gnrl_dfflrs #(ARBT_NUM) wgfpx52zsqy (ay3inlc7esnc8, nij4iu0isn, io603al4, clk, rst_n);
wire [ARBT_NUM-1:0] e4iy1811asrkv4zu;
wire [ARBT_NUM-1:0] h3823rv6pyx5fayqv7;
wire [ARBT_NUM-1:0] qyt3fhsla33fbnb3;
wire [ARBT_NUM-1:0] dnoicu8os_j;
wire [ARBT_NUM-1:0] vp0svimp60o;
wire [ARBT_NUM-1:0] lvnk7eemabbv6mjd5t;
wire [ARBT_NUM-1:0] mdxm1iesyvp;
wire [ARBT_NUM-1:0] b1pyacioc570;
wire [ARBT_NUM-1:0] dk42uo4croc7a;
assign rrobin_active = 1'b0;
assign dk42uo4croc7a = req_vec;
assign e4iy1811asrkv4zu = io603al4 & dk42uo4croc7a;
assign h3823rv6pyx5fayqv7 = (~io603al4) & dk42uo4croc7a;
generate
  for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
  begin:galwkrysrtimofo2137k
    if(zyod33==0) begin: ekshcxaue
      assign qyt3fhsla33fbnb3[0] = e4iy1811asrkv4zu[0];
      assign lvnk7eemabbv6mjd5t[0] = h3823rv6pyx5fayqv7[0];
      assign dnoicu8os_j[0] = qyt3fhsla33fbnb3[0];
      assign mdxm1iesyvp[0] = lvnk7eemabbv6mjd5t[0];
    end
    else begin: t52jbe_u5p6cb5
      assign qyt3fhsla33fbnb3[zyod33] = |e4iy1811asrkv4zu[zyod33:0];
      assign lvnk7eemabbv6mjd5t[zyod33] = |h3823rv6pyx5fayqv7[zyod33:0];
      assign dnoicu8os_j[zyod33] = (~qyt3fhsla33fbnb3[zyod33-1]) & qyt3fhsla33fbnb3[zyod33];
      assign mdxm1iesyvp[zyod33] = (~lvnk7eemabbv6mjd5t[zyod33-1]) & lvnk7eemabbv6mjd5t[zyod33];
    end
  end
endgenerate
assign vp0svimp60o = dnoicu8os_j;
assign b1pyacioc570 = mdxm1iesyvp;
wire w3btruu = |(io603al4 & dk42uo4croc7a);
assign grt_vec = w3btruu ?  vp0svimp60o : b1pyacioc570;
assign nij4iu0isn = w3btruu ?  {qyt3fhsla33fbnb3[ARBT_NUM-2:0],1'b0} : {lvnk7eemabbv6mjd5t[ARBT_NUM-2:0],1'b0};
endmodule
module sdio_gnrl_rrobin_1cycle_da # (
    parameter ARBT_NUM = 4
)(
  output rrobin_active,
  output[ARBT_NUM-1:0] grt_vec,
  input [ARBT_NUM-1:0] req_vec,
  input [ARBT_NUM-1:0] buz_vec,
  input arbt_ena,
  input arbt_rply,
  input clk,
  input rst_n
);
wire                qm6uphqvb9w;
wire [ARBT_NUM-1:0] m14znsr_hekiy5j3;
wire [ARBT_NUM-1:0] vopg5ab7mmi0yp8v2if0;
genvar zyod33;
generate
  for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
  begin:b55mifo9
    assign m14znsr_hekiy5j3[zyod33] = |req_vec[zyod33:0];
  end
endgenerate
assign vopg5ab7mmi0yp8v2if0 = {m14znsr_hekiy5j3[ARBT_NUM-2:0],1'b0};
wire [ARBT_NUM-1:0] nz48be6rsny3hiv1chavm2xj7 = vopg5ab7mmi0yp8v2if0 & req_vec;
wire qf8r9k_xyvx7ooz60bo = ~(|nz48be6rsny3hiv1chavm2xj7);
wire o3jlwf_zxg9168kyy = (|req_vec);
wire ar2pcf5farztsd5f405  = ~qf8r9k_xyvx7ooz60bo;
assign qm6uphqvb9w = o3jlwf_zxg9168kyy & ar2pcf5farztsd5f405;
wire                ay3inlc7esnc8;
wire [ARBT_NUM-1:0] nij4iu0isn;
wire [ARBT_NUM-1:0] io603al4;
wire                k6xo00gyltmn0jl;
wire [ARBT_NUM-1:0] ubob08d8x9g98375;
wire [ARBT_NUM-1:0] apbeh146yo;
wire                hvrfuswmi6c3g67pv;
wire [ARBT_NUM-1:0] uog87lf8bneoa4b8;
wire [ARBT_NUM-1:0] n9z3ae7x892ihn1;
wire                dz62ocpxy9u1i;
wire [ARBT_NUM-1:0] oj_1btpmxkcsokv;
wire [ARBT_NUM-1:0] wery2xlib7nri;
wire                mzxa5p3g6a0t5_t2s;
wire                ppcp7el6knwb81jodb;
wire                e30o8ycv2m9um9u0tf249;
wire                jh46_jb0jqst6nykazsk;
wire                jnmarl0d22c7hkjsr61;
wire                qz_zg81ujlah4gdsgms;
sdio_gnrl_dfflrs #(ARBT_NUM) wgfpx52zsqy (ay3inlc7esnc8, nij4iu0isn, io603al4, clk, rst_n);
sdio_gnrl_dfflrs #(ARBT_NUM) ki7v1sld32wjm (k6xo00gyltmn0jl, ubob08d8x9g98375, apbeh146yo, clk, rst_n);
sdio_gnrl_dfflrs #(ARBT_NUM, {{(ARBT_NUM-1){1'b0}}, 1'b1}) s0wq3gnnxyc1l4u2 (hvrfuswmi6c3g67pv, uog87lf8bneoa4b8, n9z3ae7x892ihn1, clk, rst_n);
sdio_gnrl_dfflrs #(ARBT_NUM, {{(ARBT_NUM-1){1'b0}}, 1'b1}) j6sprp5szb20uc312 (dz62ocpxy9u1i, oj_1btpmxkcsokv, wery2xlib7nri, clk, rst_n);
sdio_gnrl_dfflr #(1) bxjfi4a1epo_dwwev6px2_ (e30o8ycv2m9um9u0tf249, ppcp7el6knwb81jodb, mzxa5p3g6a0t5_t2s, clk, rst_n);
sdio_gnrl_dfflr #(1) nvb81ysmc5v1p9w8t94hy (qz_zg81ujlah4gdsgms, jnmarl0d22c7hkjsr61, jh46_jb0jqst6nykazsk, clk, rst_n);
wire [ARBT_NUM-1:0] e4iy1811asrkv4zu;
wire [ARBT_NUM-1:0] h3823rv6pyx5fayqv7;
wire [ARBT_NUM-1:0] j74dowqbq4_19_2ry3mj;
wire [ARBT_NUM-1:0] h0yk9ldu806wpfdg40p8;
wire [ARBT_NUM-1:0] qyt3fhsla33fbnb3;
wire [ARBT_NUM-1:0] lvnk7eemabbv6mjd5t;
wire [ARBT_NUM-1:0] h_l3q7wq2i6yen1w;
wire [ARBT_NUM-1:0] aboixs576qhwafuw88;
wire [ARBT_NUM-1:0] dnoicu8os_j;
wire [ARBT_NUM-1:0] mdxm1iesyvp;
wire [ARBT_NUM-1:0] tistajiu3kj1;
wire [ARBT_NUM-1:0] tpmmvuzntgxdf1;
assign rrobin_active = 1'b0;
assign e4iy1811asrkv4zu = io603al4 & req_vec;
assign h3823rv6pyx5fayqv7 = (~io603al4) & req_vec;
assign j74dowqbq4_19_2ry3mj = apbeh146yo & buz_vec;
assign h0yk9ldu806wpfdg40p8 = (~apbeh146yo) & buz_vec;
generate
  for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
  begin:galwkrysrtimofo2137k
    if(zyod33==0) begin: ekshcxaue
      assign qyt3fhsla33fbnb3[0] = e4iy1811asrkv4zu[0];
      assign lvnk7eemabbv6mjd5t[0] = h3823rv6pyx5fayqv7[0];
      assign h_l3q7wq2i6yen1w[0] = j74dowqbq4_19_2ry3mj[0];
      assign aboixs576qhwafuw88[0] = h0yk9ldu806wpfdg40p8[0];
      assign dnoicu8os_j[0] = qyt3fhsla33fbnb3[0];
      assign mdxm1iesyvp[0] = lvnk7eemabbv6mjd5t[0];
      assign tistajiu3kj1[0] = h_l3q7wq2i6yen1w[0];
      assign tpmmvuzntgxdf1[0] = aboixs576qhwafuw88[0];
    end
    else begin: t52jbe_u5p6cb5
      assign qyt3fhsla33fbnb3[zyod33] = |e4iy1811asrkv4zu[zyod33:0];
      assign lvnk7eemabbv6mjd5t[zyod33] = |h3823rv6pyx5fayqv7[zyod33:0];
      assign h_l3q7wq2i6yen1w[zyod33] = |j74dowqbq4_19_2ry3mj[zyod33:0];
      assign aboixs576qhwafuw88[zyod33] = |h0yk9ldu806wpfdg40p8[zyod33:0];
      assign dnoicu8os_j[zyod33] = (~qyt3fhsla33fbnb3[zyod33-1]) & qyt3fhsla33fbnb3[zyod33];
      assign mdxm1iesyvp[zyod33] = (~lvnk7eemabbv6mjd5t[zyod33-1]) & lvnk7eemabbv6mjd5t[zyod33];
      assign tistajiu3kj1[zyod33] = (~h_l3q7wq2i6yen1w[zyod33-1]) & h_l3q7wq2i6yen1w[zyod33];
      assign tpmmvuzntgxdf1[zyod33] = (~aboixs576qhwafuw88[zyod33-1]) & aboixs576qhwafuw88[zyod33];
    end
  end
endgenerate
wire lyfy7rqfhp = |e4iy1811asrkv4zu;
wire cfjtdafrj1b = |j74dowqbq4_19_2ry3mj;
wire wh2sie74t4 = |(req_vec & n9z3ae7x892ihn1);
wire [ARBT_NUM-1:0] c_qhm4gmha8l0 = lyfy7rqfhp ? dnoicu8os_j: mdxm1iesyvp;
wire tjwzzki_1co8tt_ = |(n9z3ae7x892ihn1 & c_qhm4gmha8l0);
wire qmwgf3fjk9zj2 = ~(|(n9z3ae7x892ihn1 & buz_vec));
assign grt_vec = wh2sie74t4 ? n9z3ae7x892ihn1 : c_qhm4gmha8l0;
wire [ARBT_NUM-1:0] fp0hk25exvrfup682_c = lyfy7rqfhp ? qyt3fhsla33fbnb3 : lvnk7eemabbv6mjd5t;
assign ay3inlc7esnc8 = (~wh2sie74t4 | tjwzzki_1co8tt_) & qm6uphqvb9w & arbt_ena;
assign nij4iu0isn = {fp0hk25exvrfup682_c[ARBT_NUM-2:0],1'b0};
wire [ARBT_NUM-1:0] mmcnau4w9ofkxaede83_me = cfjtdafrj1b ? h_l3q7wq2i6yen1w : aboixs576qhwafuw88;
wire [ARBT_NUM-1:0] ruqn2jd_vycpc6ctvbnce6vz = cfjtdafrj1b ? tistajiu3kj1 : tpmmvuzntgxdf1;
wire   z4mi9ap3vbk1eyhp = wh2sie74t4 & arbt_ena;
wire   bi6fgcu7z61y = mzxa5p3g6a0t5_t2s & arbt_rply;
wire   soqvyvqdomhmxwr5 = jh46_jb0jqst6nykazsk & z4mi9ap3vbk1eyhp;
wire   tke1u6xma4m   = bi6fgcu7z61y | soqvyvqdomhmxwr5;
assign k6xo00gyltmn0jl = ((wh2sie74t4 & ~tke1u6xma4m) | qmwgf3fjk9zj2) & arbt_ena;
assign ubob08d8x9g98375 = {mmcnau4w9ofkxaede83_me[ARBT_NUM-2:0],1'b0};
assign hvrfuswmi6c3g67pv = k6xo00gyltmn0jl | tke1u6xma4m;
assign uog87lf8bneoa4b8 = tke1u6xma4m ? wery2xlib7nri : ruqn2jd_vycpc6ctvbnce6vz;
assign dz62ocpxy9u1i = z4mi9ap3vbk1eyhp | bi6fgcu7z61y;
assign oj_1btpmxkcsokv = n9z3ae7x892ihn1;
assign e30o8ycv2m9um9u0tf249 = arbt_ena & o3jlwf_zxg9168kyy;
assign ppcp7el6knwb81jodb = wh2sie74t4;
assign qz_zg81ujlah4gdsgms = tke1u6xma4m;
assign jnmarl0d22c7hkjsr61 = bi6fgcu7z61y;
endmodule
module sdio_gnrl_rrobin # (
    parameter ARBT_NUM = 4
)(
  output rrobin_active,
  output[ARBT_NUM-1:0] grt_vec,
  input [ARBT_NUM-1:0] req_vec,
  input arbt_ena,
  input clk,
  input rst_n
);
wire               qm6uphqvb9w;
wire               ay3inlc7esnc8;
wire               n1l9iqtcgtf1i;
wire [ARBT_NUM-1:0] nij4iu0isn;
wire [ARBT_NUM-1:0] io603al4;
wire [ARBT_NUM-1:0] m14znsr_hekiy5j3;
wire [ARBT_NUM-1:0] vopg5ab7mmi0yp8v2if0;
genvar zyod33;
generate
  for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
  begin:b55mifo9
    assign m14znsr_hekiy5j3[zyod33] = |req_vec[zyod33:0];
  end
endgenerate
assign vopg5ab7mmi0yp8v2if0 = {m14znsr_hekiy5j3[ARBT_NUM-2:0],1'b0};
wire [ARBT_NUM-1:0] nz48be6rsny3hiv1chavm2xj7;
assign nz48be6rsny3hiv1chavm2xj7= vopg5ab7mmi0yp8v2if0 & req_vec;
wire qf8r9k_xyvx7ooz60bo = ~(|nz48be6rsny3hiv1chavm2xj7);
wire o3jlwf_zxg9168kyy = (|req_vec);
wire ar2pcf5farztsd5f405  = ~qf8r9k_xyvx7ooz60bo;
assign qm6uphqvb9w = o3jlwf_zxg9168kyy & ar2pcf5farztsd5f405;
assign ay3inlc7esnc8  = qm6uphqvb9w & arbt_ena;
generate
  if(ARBT_NUM == 2) begin: ihgp67jurfuj45gx_wtxh
    assign n1l9iqtcgtf1i = ~(io603al4[0]);
  end
  else begin: ww6aqvf8aaylaqhu1
    assign n1l9iqtcgtf1i = ~(|io603al4[ARBT_NUM-2:0]);
  end
endgenerate
sdio_gnrl_dfflrs #(ARBT_NUM) wgfpx52zsqy (ay3inlc7esnc8, nij4iu0isn, io603al4, clk, rst_n);
wire [ARBT_NUM-1:0] e4iy1811asrkv4zu;
wire [ARBT_NUM-1:0] h3823rv6pyx5fayqv7;
wire [ARBT_NUM-1:0] qyt3fhsla33fbnb3;
wire [ARBT_NUM-1:0] dnoicu8os_j;
wire [ARBT_NUM-1:0] vp0svimp60o;
wire [ARBT_NUM-1:0] lvnk7eemabbv6mjd5t;
wire [ARBT_NUM-1:0] mdxm1iesyvp;
wire [ARBT_NUM-1:0] b1pyacioc570;
wire [ARBT_NUM-1:0] piqi85pa2q8;
wire [ARBT_NUM-1:0] nfc5_guuim;
wire rcxcpv3rlehs;
wire fml26efio7n;
wire c64irz9rzs55y;
wire [ARBT_NUM-1:0] dk42uo4croc7a;
assign fml26efio7n = (|grt_vec) & (~arbt_ena);
assign c64irz9rzs55y = (arbt_ena | (~(|dk42uo4croc7a))) & (|piqi85pa2q8);
assign rcxcpv3rlehs = fml26efio7n | c64irz9rzs55y;
assign nfc5_guuim = c64irz9rzs55y ? {ARBT_NUM{1'b0}} : (~grt_vec);
sdio_gnrl_dfflr #(ARBT_NUM) g1_3bsx0qu (rcxcpv3rlehs, nfc5_guuim, piqi85pa2q8, clk, rst_n);
assign rrobin_active = (|piqi85pa2q8);
assign dk42uo4croc7a = req_vec & (~piqi85pa2q8);
assign e4iy1811asrkv4zu = io603al4 & dk42uo4croc7a;
assign h3823rv6pyx5fayqv7 = (~io603al4) & dk42uo4croc7a;
generate
  for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
  begin:galwkrysrtimofo2137k
    if(zyod33==0) begin: ekshcxaue
      assign qyt3fhsla33fbnb3[0] = e4iy1811asrkv4zu[0];
      assign lvnk7eemabbv6mjd5t[0] = h3823rv6pyx5fayqv7[0];
      assign dnoicu8os_j[0] = qyt3fhsla33fbnb3[0];
      assign mdxm1iesyvp[0] = lvnk7eemabbv6mjd5t[0];
    end
    else begin: t52jbe_u5p6cb5
      assign qyt3fhsla33fbnb3[zyod33] = |e4iy1811asrkv4zu[zyod33:0];
      assign lvnk7eemabbv6mjd5t[zyod33] = |h3823rv6pyx5fayqv7[zyod33:0];
      assign dnoicu8os_j[zyod33] = (~qyt3fhsla33fbnb3[zyod33-1]) & qyt3fhsla33fbnb3[zyod33];
      assign mdxm1iesyvp[zyod33] = (~lvnk7eemabbv6mjd5t[zyod33-1]) & lvnk7eemabbv6mjd5t[zyod33];
    end
  end
endgenerate
assign vp0svimp60o = dnoicu8os_j;
assign b1pyacioc570 = mdxm1iesyvp;
wire w3btruu = |(io603al4 & dk42uo4croc7a);
assign grt_vec = w3btruu ?  vp0svimp60o : b1pyacioc570;
assign nij4iu0isn = w3btruu ?  {qyt3fhsla33fbnb3[ARBT_NUM-2:0],1'b0} : {lvnk7eemabbv6mjd5t[ARBT_NUM-2:0],1'b0};
endmodule
module sdio_gnrl_rrobin_cut # (
    parameter ARBT_NUM = 4
)(
  output rrobin_active,
  output[ARBT_NUM-1:0] grt_vec,
  input [ARBT_NUM-1:0] req_vec,
  input arbt_ena,
  input [ARBT_NUM-1:0] req_mask,
  input req_mask_set,
  input clk,
  input rst_n
);
  wire lrxvst82cytqu6 = (|req_mask);
  wire fai844_tfplrfnyf6a36gf = req_mask_set & (~lrxvst82cytqu6);
wire [ARBT_NUM-1:0] jia1qnm_0_0bk;
wire               qm6uphqvb9w;
wire               ay3inlc7esnc8;
wire               n1l9iqtcgtf1i;
wire [ARBT_NUM-1:0] nij4iu0isn;
wire [ARBT_NUM-1:0] io603al4;
wire [ARBT_NUM-1:0] m14znsr_hekiy5j3;
wire [ARBT_NUM-1:0] vopg5ab7mmi0yp8v2if0;
genvar zyod33;
generate
  for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
  begin:b55mifo9
    assign m14znsr_hekiy5j3[zyod33] = |req_vec[zyod33:0];
  end
endgenerate
assign vopg5ab7mmi0yp8v2if0 = {m14znsr_hekiy5j3[ARBT_NUM-2:0],1'b0};
wire [ARBT_NUM-1:0] nz48be6rsny3hiv1chavm2xj7;
assign nz48be6rsny3hiv1chavm2xj7= vopg5ab7mmi0yp8v2if0 & req_vec;
wire qf8r9k_xyvx7ooz60bo = ~(|nz48be6rsny3hiv1chavm2xj7);
wire o3jlwf_zxg9168kyy = (|req_vec);
wire ar2pcf5farztsd5f405  = ~qf8r9k_xyvx7ooz60bo;
assign qm6uphqvb9w = o3jlwf_zxg9168kyy & ar2pcf5farztsd5f405;
wire l2mo82u2op;
assign ay3inlc7esnc8  = (qm6uphqvb9w & arbt_ena) | l2mo82u2op;
generate
  if(ARBT_NUM == 2) begin: ihgp67jurfuj45gx_wtxh
    assign n1l9iqtcgtf1i = ~(io603al4[0]);
  end
  else begin: ww6aqvf8aaylaqhu1
    assign n1l9iqtcgtf1i = ~(|io603al4[ARBT_NUM-2:0]);
  end
endgenerate
wire [ARBT_NUM-1:0] e9dla81bmeo2;
sdio_gnrl_dfflrs #(ARBT_NUM) wgfpx52zsqy (ay3inlc7esnc8, nij4iu0isn, io603al4, clk, rst_n);
wire [ARBT_NUM-1:0] e4iy1811asrkv4zu;
wire [ARBT_NUM-1:0] h3823rv6pyx5fayqv7;
wire [ARBT_NUM-1:0] qyt3fhsla33fbnb3;
wire [ARBT_NUM-1:0] dnoicu8os_j;
wire [ARBT_NUM-1:0] lvnk7eemabbv6mjd5t;
wire [ARBT_NUM-1:0] mdxm1iesyvp;
wire [ARBT_NUM-1:0] vp0svimp60o;
wire [ARBT_NUM-1:0] b1pyacioc570;
wire [ARBT_NUM-1:0] vzvppxpopdyndp89aj;
wire [ARBT_NUM-1:0] h0j8klwtothrp3c;
wire [ARBT_NUM-1:0] rv5c8c6iu67b8wo0h;
wire [ARBT_NUM-1:0] g_c2y_78a1;
wire [ARBT_NUM-1:0] vm1pgsokwg7kobz9m4d;
wire [ARBT_NUM-1:0] m1770mxyeqjh;
wire [ARBT_NUM-1:0] piqi85pa2q8;
wire [ARBT_NUM-1:0] nfc5_guuim;
wire rcxcpv3rlehs;
wire fml26efio7n;
wire c64irz9rzs55y;
wire [ARBT_NUM-1:0] dk42uo4croc7a;
wire [ARBT_NUM-1:0] jfkxavtcxmbcqa;
wire [ARBT_NUM-1:0] p8kkqt8egc3nc7tqeh1;
assign p8kkqt8egc3nc7tqeh1 = req_vec & piqi85pa2q8;
assign fml26efio7n = (|jia1qnm_0_0bk) & (~arbt_ena) & (~lrxvst82cytqu6);
assign c64irz9rzs55y = (arbt_ena | (~(|p8kkqt8egc3nc7tqeh1))) & (|piqi85pa2q8);
assign rcxcpv3rlehs = fml26efio7n | c64irz9rzs55y;
assign nfc5_guuim = c64irz9rzs55y ? {ARBT_NUM{1'b0}} : (~jia1qnm_0_0bk);
sdio_gnrl_dfflr #(ARBT_NUM) g1_3bsx0qu (rcxcpv3rlehs, nfc5_guuim, piqi85pa2q8, clk, rst_n);
assign rrobin_active = (|piqi85pa2q8);
wire x0vakbdi3e5 = rrobin_active;
assign dk42uo4croc7a = req_vec;
assign jfkxavtcxmbcqa = dk42uo4croc7a & (~grt_vec);
assign e4iy1811asrkv4zu = io603al4 & dk42uo4croc7a;
assign h3823rv6pyx5fayqv7 = (~io603al4) & dk42uo4croc7a;
assign vzvppxpopdyndp89aj = io603al4 & jfkxavtcxmbcqa;
assign h0j8klwtothrp3c = (~io603al4) & jfkxavtcxmbcqa;
generate
  for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
  begin:galwkrysrtimofo2137k
    if(zyod33==0) begin: ekshcxaue
      assign qyt3fhsla33fbnb3[0] = e4iy1811asrkv4zu[0];
      assign lvnk7eemabbv6mjd5t[0] = h3823rv6pyx5fayqv7[0];
      assign dnoicu8os_j[0] = qyt3fhsla33fbnb3[0];
      assign mdxm1iesyvp[0] = lvnk7eemabbv6mjd5t[0];
      assign rv5c8c6iu67b8wo0h[0] = vzvppxpopdyndp89aj[0];
      assign vm1pgsokwg7kobz9m4d[0] = h0j8klwtothrp3c[0];
      assign g_c2y_78a1[0] = rv5c8c6iu67b8wo0h[0];
      assign m1770mxyeqjh[0] = vm1pgsokwg7kobz9m4d[0];
      assign e9dla81bmeo2[0] = io603al4[0];
    end
    else begin: t52jbe_u5p6cb5
      assign qyt3fhsla33fbnb3[zyod33] = |e4iy1811asrkv4zu[zyod33:0];
      assign lvnk7eemabbv6mjd5t[zyod33] = |h3823rv6pyx5fayqv7[zyod33:0];
      assign dnoicu8os_j[zyod33] = (~qyt3fhsla33fbnb3[zyod33-1]) & qyt3fhsla33fbnb3[zyod33];
      assign mdxm1iesyvp[zyod33] = (~lvnk7eemabbv6mjd5t[zyod33-1]) & lvnk7eemabbv6mjd5t[zyod33];
      assign rv5c8c6iu67b8wo0h[zyod33] = |vzvppxpopdyndp89aj[zyod33:0];
      assign vm1pgsokwg7kobz9m4d[zyod33] = |h0j8klwtothrp3c[zyod33:0];
      assign g_c2y_78a1[zyod33] = (~rv5c8c6iu67b8wo0h[zyod33-1]) & rv5c8c6iu67b8wo0h[zyod33];
      assign m1770mxyeqjh[zyod33] = (~vm1pgsokwg7kobz9m4d[zyod33-1]) & vm1pgsokwg7kobz9m4d[zyod33];
      assign e9dla81bmeo2[zyod33] = (~io603al4[zyod33-1]) & io603al4[zyod33];
    end
  end
endgenerate
wire w3btruu = |(io603al4 & dk42uo4croc7a);
wire gu5xgneks = |(io603al4 & jfkxavtcxmbcqa);
assign vp0svimp60o = dnoicu8os_j;
assign b1pyacioc570 = mdxm1iesyvp;
    assign grt_vec = x0vakbdi3e5 ? (~piqi85pa2q8) : lrxvst82cytqu6 ? (~req_mask) : e9dla81bmeo2;
    assign jia1qnm_0_0bk = w3btruu ?  vp0svimp60o : b1pyacioc570;
    assign l2mo82u2op = ((~(|(grt_vec & dk42uo4croc7a))) & (|dk42uo4croc7a)) 
                     & (~lrxvst82cytqu6) 
                     & (~x0vakbdi3e5);
    assign nij4iu0isn = l2mo82u2op ? (w3btruu ? {qyt3fhsla33fbnb3[ARBT_NUM-1:0]} : {lvnk7eemabbv6mjd5t[ARBT_NUM-1:0]}) :
                                   (gu5xgneks ? {rv5c8c6iu67b8wo0h[ARBT_NUM-1:0]} : {vm1pgsokwg7kobz9m4d[ARBT_NUM-1:0]}) ;
endmodule
module sdio_gnrl_rrobin_time # (
    parameter ARBT_NUM = 4
)(
  output rrobin_active,
  output[ARBT_NUM-1:0] grt_vec,
  input [ARBT_NUM-1:0] req_vec,
  input [ARBT_NUM-1:0] req_mask,
  input arbt_ena,
  input clk,
  input rst_n
);
  genvar zyod33;
  wire [ARBT_NUM-1:0] jmxb9u94tiqj2;
  wire [ARBT_NUM-1:0] w6joi2zbtlat;
  wire xwtuuf3s7l0tdeg7;
  wire lrxvst82cytqu6 = (|req_mask);
  wire qo9pqioewd9tlxrrwoa = arbt_ena & lrxvst82cytqu6;
  sdio_gnrl_rrobin # (
      .ARBT_NUM(ARBT_NUM)
  )u_gnrl_rrobin(
    .rrobin_active(xwtuuf3s7l0tdeg7),
    .grt_vec (jmxb9u94tiqj2),
    .req_vec (w6joi2zbtlat),
    .arbt_ena(qo9pqioewd9tlxrrwoa),
    .clk     (clk     ),
    .rst_n   (rst_n   )
  );
  wire kjjsb7xmk58n2y5o;
  wire ubp626vvurc5;
  wire gk6eom14thxd8gz;
  wire [ARBT_NUM-1:0] pijm8sguhvt8rxzvy;
  wire [ARBT_NUM-1:0] julk34ohxjp99k;
  sdio_gnrl_fifo # (
       .DP(ARBT_NUM+1),
       .DW(ARBT_NUM),
       .CUT_READY(1)
  ) iy10zm2yhuvnd2xs4(
    .i_vld   (kjjsb7xmk58n2y5o),
    .i_rdy   (),
    .i_dat   (pijm8sguhvt8rxzvy),
    .o_vld   (ubp626vvurc5),
    .o_rdy   (gk6eom14thxd8gz),
    .o_dat   (julk34ohxjp99k),
    .clk     (clk  ),
    .rst_n   (rst_n)
  );
  wire [ARBT_NUM-1:0] z0n8ysrrmh;
  wire [ARBT_NUM-1:0] b4014n7ezd68t0621;
  wire [ARBT_NUM-1:0] rzbp6123n2fv5n;
  wire [ARBT_NUM-1:0] n3hz9t_71yrp9;
  wire [ARBT_NUM-1:0] qh33z8ocv0zgro2g;
  wire [ARBT_NUM-1:0] iw3oous7v81emw2iawa;
  generate
    for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
    begin:bmy4kxkc247g
        assign n3hz9t_71yrp9[zyod33] = (~z0n8ysrrmh[zyod33]) & (~(grt_vec[zyod33] & arbt_ena)) & req_vec[zyod33]
                               & (~(
                                    lrxvst82cytqu6 ? grt_vec[zyod33] : 1'b0
                                    )
                                 )
                               ;
        assign iw3oous7v81emw2iawa[zyod33] = ubp626vvurc5 & julk34ohxjp99k[zyod33] & ((grt_vec[zyod33] & arbt_ena) | (~req_vec[zyod33]));
        assign qh33z8ocv0zgro2g[zyod33] = z0n8ysrrmh[zyod33] & iw3oous7v81emw2iawa[zyod33];
        assign rzbp6123n2fv5n[zyod33] = n3hz9t_71yrp9[zyod33] | qh33z8ocv0zgro2g[zyod33];
        assign b4014n7ezd68t0621[zyod33] = (~qh33z8ocv0zgro2g[zyod33]);
sdio_gnrl_dfflr #(1) kcf8f6fdaq5vsw7b6ob (rzbp6123n2fv5n[zyod33], b4014n7ezd68t0621[zyod33], z0n8ysrrmh[zyod33], clk, rst_n);
    end
  endgenerate
  assign kjjsb7xmk58n2y5o = (|n3hz9t_71yrp9);
  assign pijm8sguhvt8rxzvy = n3hz9t_71yrp9;
  wire [ARBT_NUM-1:0] r5sofutvw4xzn7szaw2qimz;
  wire [ARBT_NUM-1:0] t6omtklaip21ncc9141y = req_vec & julk34ohxjp99k & (~r5sofutvw4xzn7szaw2qimz);
  assign gk6eom14thxd8gz = ubp626vvurc5 & (~(|t6omtklaip21ncc9141y));
  wire [ARBT_NUM-1:0] f_1cjb6apgaj169qaz2dyi;
  wire [ARBT_NUM-1:0] i8zh6wke_10wnaktv4eqi;
  wire [ARBT_NUM-1:0] criujngj2xowf8wl3q4gux;
  wire [ARBT_NUM-1:0] c5ls6iowh69lo1phdebg;
  generate
    for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
    begin:xg8nkt8f7ac30j8r5ajw5qb
        assign criujngj2xowf8wl3q4gux[zyod33] = (~r5sofutvw4xzn7szaw2qimz[zyod33]) & iw3oous7v81emw2iawa[zyod33] & (~gk6eom14thxd8gz);
        assign c5ls6iowh69lo1phdebg[zyod33] = r5sofutvw4xzn7szaw2qimz[zyod33] & gk6eom14thxd8gz;
        assign i8zh6wke_10wnaktv4eqi[zyod33] = criujngj2xowf8wl3q4gux[zyod33] | c5ls6iowh69lo1phdebg[zyod33];
        assign f_1cjb6apgaj169qaz2dyi[zyod33] = (~c5ls6iowh69lo1phdebg[zyod33]);
sdio_gnrl_dfflr #(1) dfj5fmcsvwcapig8b8zzcw (i8zh6wke_10wnaktv4eqi[zyod33], f_1cjb6apgaj169qaz2dyi[zyod33], r5sofutvw4xzn7szaw2qimz[zyod33], clk, rst_n);
    end
  endgenerate
  assign w6joi2zbtlat =
      lrxvst82cytqu6 ? {ARBT_NUM{1'b0}} :
      ubp626vvurc5    ? t6omtklaip21ncc9141y :
                      req_vec;
  assign grt_vec = lrxvst82cytqu6 ? (~req_mask) : jmxb9u94tiqj2;
  assign rrobin_active = xwtuuf3s7l0tdeg7 | ubp626vvurc5;
endmodule
module sdio_gnrl_cdc_tx
# (
  parameter PAYLOAD_NORST = 0,
  parameter DW = 32,
  parameter SYNC_DP = 2
) (
  input  i_vld,
  output i_rdy,
  input  [DW-1:0] i_dat,
  output o_vld,
  input  o_rdy_a,
  output [DW-1:0] o_dat,
  input  clk,
  input  rst_n
);
wire qhi2zdafkjm75k;
sdio_gnrl_sync #(
    .DP(SYNC_DP),
    .DW(1)
) dhpf88n5y6k9t19c4 (
         .clk   (clk),
         .rst_n (rst_n),
         .din_a (o_rdy_a),
         .dout  (qhi2zdafkjm75k)
        );
wire qmm5xj7602;
wire [DW-1:0] ikmo_lul;
wire tfg65l4rq = i_vld & i_rdy;
wire xovok62 = o_vld & qhi2zdafkjm75k;
wire plcb43cn = tfg65l4rq | xovok62;
wire buntd6lyr = tfg65l4rq | (~xovok62);
sdio_gnrl_cdc_dfflr #(1) o5sm6_ezj0(plcb43cn, buntd6lyr, qmm5xj7602, clk, rst_n); 
generate
if(PAYLOAD_NORST == 1) begin: yi2keguojod3
sdio_gnrl_cdc_dfflr #(DW) pahw0w_h517(tfg65l4rq, i_dat, ikmo_lul, clk, rst_n);  
end
else begin: lsj8oc4vo
sdio_gnrl_cdc_dffl #(DW) p0h_y3ynxzt11(tfg65l4rq, i_dat, ikmo_lul, clk, rst_n);  
end
endgenerate
wire ebu9rnewj_lwjllbx;
sdio_gnrl_dffr #(1) jk05nbm7hu91b66atb_v(qhi2zdafkjm75k, ebu9rnewj_lwjllbx, clk, rst_n);
wire xm5j1cx3ef1n = (~qhi2zdafkjm75k) & ebu9rnewj_lwjllbx;
wire juic8y3a1z;
wire plq4i48x241_d = tfg65l4rq;
wire l_rnilltl5 = xm5j1cx3ef1n;
wire e7f_o_0d = plq4i48x241_d | l_rnilltl5;
wire tj8itc8p = plq4i48x241_d | (~l_rnilltl5);
sdio_gnrl_dfflr #(1) o78pp4mfi6v5jmrpxby(e7f_o_0d, tj8itc8p, juic8y3a1z, clk, rst_n);
assign o_vld = qmm5xj7602;
assign o_dat = ikmo_lul;
assign i_rdy = (~juic8y3a1z) | l_rnilltl5;
endmodule
module sdio_gnrl_cdc_req_channel
# (
  parameter SYNC_DP = 2
) (
  input  req_i, 
  output req_o, 
  input  ack_a, 
  input  clk,
  input  rst_n 
);
  sdio_gnrl_cdc_tx # (
     .DW      (1),
     .SYNC_DP (SYNC_DP)
   ) ga8352gxxyu07ybfu1aog (
  .i_vld   (req_i),
  .i_rdy   (),
  .i_dat   (1'b0),
  .o_vld   (req_o),
  .o_rdy_a (ack_a),
  .o_dat   (),
  .clk     (clk),
  .rst_n   (rst_n)
);
endmodule
module sdio_gnrl_bypbuf # (
  parameter PAYLOAD_NORST = 0,
  parameter DP = 1,
  parameter DW = 32
) (
  input           i_vld,
  output          i_rdy,
  input  [DW-1:0] i_dat,
  output          o_vld,
  input           o_rdy,
  output [DW-1:0] o_dat,
  output          fifo_o_vld,
  input           clk,
  input           rst_n
);
  wire          azxlt9rhg5xd;
  wire          j1dl_2snn1;
  wire [DW-1:0] t_txk047vz1_s7f;
  wire          gtma1c2mcymbtr6;
  wire [DW-1:0] khjk8dkvq8cgal;
  sdio_gnrl_fifo # (
       .PAYLOAD_NORST(PAYLOAD_NORST),
       .DP(DP),
       .DW(DW),
       .CUT_READY(1)
  ) ikqxaw135rm09658zf(
    .i_vld   (azxlt9rhg5xd),
    .i_rdy   (j1dl_2snn1),
    .i_dat   (t_txk047vz1_s7f),
    .o_vld   (fifo_o_vld),
    .o_rdy   (gtma1c2mcymbtr6),
    .o_dat   (khjk8dkvq8cgal),
    .clk     (clk  ),
    .rst_n   (rst_n)
  );
  assign i_rdy = j1dl_2snn1;
  wire n_i47kg = i_vld & o_rdy & (~fifo_o_vld);
  assign gtma1c2mcymbtr6 = o_rdy;
  assign o_vld = fifo_o_vld | i_vld;
  assign o_dat = fifo_o_vld ? khjk8dkvq8cgal : i_dat;
  assign t_txk047vz1_s7f  = i_dat;
  assign azxlt9rhg5xd = i_vld & (~n_i47kg);
endmodule
module sdio_gnrl_ratio_bypbuf # (
  parameter PAYLOAD_NORST = 0,
  parameter DP = 8,
  parameter DW = 32
) (
  input           clk_en,
  input           i_vld,
  output          i_rdy,
  input  [DW-1:0] i_dat,
  output          o_vld,
  input           o_rdy,
  output [DW-1:0] o_dat,
  input           clk,
  input           rst_n
);
  wire          azxlt9rhg5xd;
  wire          j1dl_2snn1;
  wire [DW-1:0] t_txk047vz1_s7f;
  wire          ubp626vvurc5;
  wire          gtma1c2mcymbtr6;
  wire [DW-1:0] khjk8dkvq8cgal;
  sdio_gnrl_ratio_fifo # (
       .PAYLOAD_NORST(PAYLOAD_NORST),
       .I_SUPPORT_RATIO(1),
       .O_SUPPORT_RATIO(1),
       .DP(DP),
       .DW(DW)
  ) ec_xbiwod5_rjuesv4x(
    .i_clk_en(clk_en),
    .o_clk_en(clk_en),
    .i_vld   (azxlt9rhg5xd),
    .i_rdy   (j1dl_2snn1),
    .i_dat   (t_txk047vz1_s7f),
    .o_vld   (ubp626vvurc5),
    .o_rdy   (gtma1c2mcymbtr6),
    .o_dat   (khjk8dkvq8cgal),
    .o_fifo_active(),
    .clk     (clk  ),
    .rst_n   (rst_n)
  );
  assign i_rdy = j1dl_2snn1;
  wire n_i47kg = i_vld & o_rdy & (~ubp626vvurc5);
  assign gtma1c2mcymbtr6 = o_rdy;
  assign o_vld = ubp626vvurc5 | i_vld;
  assign o_dat = ubp626vvurc5 ? khjk8dkvq8cgal : i_dat;
  assign t_txk047vz1_s7f  = i_dat;
  assign azxlt9rhg5xd = i_vld & (~n_i47kg);
endmodule
module sdio_gnrl_stck # (
  parameter PAYLOAD_NORST = 0,
  parameter DP   = 8,
  parameter DW   = 32
) (
  input           i_wen,
  input  [DW-1:0] i_dat,
  input           o_ren,
  output [DW-1:0] o_dat,
  input           clk,
  input           rst_n
);
  wire [DW-1:0] j2ulx4qhzt6lr [DP-1:0];
  wire [DP-1:0] awm5wlzw6lh;
  wire [DP:0] oj7d_c;
  wire [DP:0] ygfrhv2;
  wire [DP:0] jtq949j67;
  wire [DP:0] j5rme6;
  wire bb7bhv = (o_ren ^ i_wen );
  assign jtq949j67 = i_wen ? (j5rme6 << 1) : (j5rme6 >> 1);
sdio_gnrl_dfflrs #(1)  v9onou3lach3(bb7bhv, jtq949j67[0]   , j5rme6[0]   , clk, rst_n);
sdio_gnrl_dfflr  #(DP) s1kmy6yeth7j9ydxn(bb7bhv, jtq949j67[DP:1], j5rme6[DP:1], clk, rst_n);
  assign oj7d_c = j5rme6; 
  assign ygfrhv2 = (j5rme6 >> 1); 
  genvar zyod33;
  generate 
    for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:aeo4f786mqb3e
      assign awm5wlzw6lh[zyod33] = i_wen & oj7d_c[zyod33];      
    if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_dffl  #(DW) bu0j0cbv6rvelf9 (awm5wlzw6lh[zyod33], i_dat, j2ulx4qhzt6lr[zyod33], clk, rst_n);
    end
    else begin: lsj8oc4vo
sdio_gnrl_dfflr #(DW) kow6ybpfchab7gt38(awm5wlzw6lh[zyod33], i_dat, j2ulx4qhzt6lr[zyod33], clk, rst_n);
    end
    end
  endgenerate
  integer t;
  reg [DW-1:0] j45yhs2ojom0i;
  always @*
  begin : sosqjh1rrq34
    j45yhs2ojom0i = {DW{1'b0}};
    for(t=0; t<DP; t=t+1) begin
      j45yhs2ojom0i = j45yhs2ojom0i | ({DW{ygfrhv2[t]}} & j2ulx4qhzt6lr[t]);
    end
  end
  assign o_dat = j45yhs2ojom0i;
endmodule
module sdio_gnrl_ratio_fifo # (
  parameter PAYLOAD_NORST = 0,
  parameter I_SUPPORT_RATIO = 0,
  parameter O_SUPPORT_RATIO = 0,
  parameter REG_OUT = 0,
  parameter DP   = 8,
  parameter DW   = 32
) (
  input           i_clk_en,
  input           i_vld,
  output          i_rdy,
  input  [DW-1:0] i_dat,
  input           o_clk_en,
  output          o_vld,
  input           o_rdy,
  output [DW-1:0] o_dat,
  output          o_fifo_active,
  input           clk,
  input           rst_n
);
genvar zyod33;
generate
  if(DP == 0) begin: qmqs20k9uyma
     assign o_vld = i_vld;
     assign i_rdy = o_rdy;
     assign o_dat = i_dat;
     assign o_fifo_active =  i_vld;
  end
  else begin: kfuzu1wzm87
    wire [DW-1:0] jyb_xrvmlkepac [DP-1:0];
    wire [DW-1:0] niyrz4zsknv [DP-1:0];
    wire [DP-1:0] rreodx8nr3a;
    wire xmzf = i_vld & i_rdy & i_clk_en;
    wire u6lh = o_vld & o_rdy & o_clk_en;
    wire [DP-1:0] b9mzd4qdyk38db; 
    wire [DP-1:0] jgpriggtm2y_fwywc;
    wire [DP-1:0] ot40c525e9q7lz;
    wire [DP-1:0] ll6f8tv1_r2d1h;
    wire [DP-1:0] rgpkcprjgc_w9a;
      if (DP == 1) begin:zrm_75v31pedl5_bzle
          assign jgpriggtm2y_fwywc = 1'b1;
          assign ll6f8tv1_r2d1h = 1'b1;
      end
      else begin:o_if029toe7x7terfxikwqj
          assign jgpriggtm2y_fwywc =
            ot40c525e9q7lz[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                            (ot40c525e9q7lz << 1);
          assign ll6f8tv1_r2d1h =
            rgpkcprjgc_w9a[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                            (rgpkcprjgc_w9a << 1);
      end
sdio_gnrl_dfflrs #(1)    ykwyawz_btbqa9homx3  (u6lh, jgpriggtm2y_fwywc[0]     , ot40c525e9q7lz[0]     , clk, rst_n);
sdio_gnrl_dfflrs #(1)    c7pydzj7ovdygd4aj1  (xmzf, ll6f8tv1_r2d1h[0]     , rgpkcprjgc_w9a[0]     , clk, rst_n);
      if(DP>1) begin:clkm1t5c1xs
sdio_gnrl_dfflr  #(DP-1) a9egrdivdf59anpv72p4iu  (u6lh, jgpriggtm2y_fwywc[DP-1:1], ot40c525e9q7lz[DP-1:1], clk, rst_n);
sdio_gnrl_dfflr  #(DP-1) lvg4hw2b7ocga7kwrt  (xmzf, ll6f8tv1_r2d1h[DP-1:1], rgpkcprjgc_w9a[DP-1:1], clk, rst_n);
      end
    assign b9mzd4qdyk38db = u6lh ? jgpriggtm2y_fwywc : ot40c525e9q7lz;
    wire [DP:0] oj7d_c;
    wire [DP:0] ygfrhv2;
    wire [DP:0] jtq949j67;
    wire [DP:0] j5rme6;
    wire bb7bhv = (u6lh ^ xmzf );
    assign jtq949j67 = xmzf ? {j5rme6[DP-1:0], 1'b1} : (j5rme6 >> 1);
sdio_gnrl_dfflrs #(1)  v9onou3lach3     (bb7bhv, jtq949j67[0]     , j5rme6[0]     ,     clk, rst_n);
sdio_gnrl_dfflr  #(DP) mgngavv5i6kdpvrx     (bb7bhv, jtq949j67[DP:1], j5rme6[DP:1],     clk, rst_n);
    assign oj7d_c = {1'b0,j5rme6[DP:1]};
    assign ygfrhv2 = {1'b0,j5rme6[DP:1]};
  wire vcda0zbgh57i6;
  if (I_SUPPORT_RATIO == 0) begin : w06ty89wv67he78rv
    assign i_rdy = (~oj7d_c[DP-1]);
    assign vcda0zbgh57i6 = 1'b0;
  end
  else begin: ro7o_w4dd_35bavf
    wire eykvyutwit5d;
    wire xmpen02zkjq95;
    wire g_fnw5e87x;
    wire ypmhsecm2fishwa;
    wire begs5txif4ww4syix7o6;
    wire xxduwtzzl57lvgelbu7;
    wire g0fsl8byow1ktt72w88;
    wire z2jcbfdv7xjt78lrk4r;
    wire w462z43whq5pi2akfge;
    assign ypmhsecm2fishwa = bb7bhv;
    assign begs5txif4ww4syix7o6 = (ypmhsecm2fishwa && !i_clk_en);
    assign xxduwtzzl57lvgelbu7 = (w462z43whq5pi2akfge && i_clk_en);
    assign g0fsl8byow1ktt72w88 = begs5txif4ww4syix7o6 || xxduwtzzl57lvgelbu7;
    assign z2jcbfdv7xjt78lrk4r = begs5txif4ww4syix7o6;
sdio_gnrl_dfflr  #(1) lztx_qnk5aiebeitcb4f1    (g0fsl8byow1ktt72w88, z2jcbfdv7xjt78lrk4r, w462z43whq5pi2akfge,     clk, rst_n);
    assign eykvyutwit5d = i_clk_en && (ypmhsecm2fishwa || w462z43whq5pi2akfge);
    assign xmpen02zkjq95 = (bb7bhv) ? (~jtq949j67[DP]) : (~oj7d_c[DP-1]);
sdio_gnrl_dfflrs  #(1) d8gle62u048i1kd    (eykvyutwit5d, xmpen02zkjq95, g_fnw5e87x,     clk, rst_n);
    assign i_rdy = g_fnw5e87x;
    assign vcda0zbgh57i6 = w462z43whq5pi2akfge;
  end
    for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:oe5rsotr0ghvfl
      assign rreodx8nr3a[zyod33] = xmzf & rgpkcprjgc_w9a[zyod33];
      if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_dffl   #(DW) dwpadh5cajhr0s  (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
      end
      else begin: lsj8oc4vo
sdio_gnrl_dfflr  #(DW) u6vxeldg1cpy9bd0ai (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
      end
      assign jyb_xrvmlkepac[zyod33] = rreodx8nr3a[zyod33] ? i_dat : niyrz4zsknv[zyod33];
    end
    integer t;
    wire [DW-1:0] j45yhs2ojom0i;
    if(REG_OUT == 0) begin:ryi755vbqjpdrspl
    reg [DW-1:0] rvekbwm94_2g1;
        always @*
        begin : sosqjh1rrq34
          rvekbwm94_2g1 = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            rvekbwm94_2g1 = rvekbwm94_2g1 | ({DW{ot40c525e9q7lz[t]}} & niyrz4zsknv[t]);
          end
        end
    assign j45yhs2ojom0i = rvekbwm94_2g1;
    if (O_SUPPORT_RATIO == 0) begin : snaaccddjkzhior78m
        assign o_dat = j45yhs2ojom0i;
    end
    else begin: ne28ujwjk5q
        assign o_dat = j45yhs2ojom0i & {DW{o_vld}};
    end
    end
    else begin:hr23f8vxpi5ab_7q5yidy1
        reg [DW-1:0] md1jj1lh30i77nmk;
        always @*
        begin : sosqjh1rrq34
          md1jj1lh30i77nmk = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            md1jj1lh30i77nmk = md1jj1lh30i77nmk | ({DW{b9mzd4qdyk38db[t]}} & jyb_xrvmlkepac[t]);
          end
        end
        wire q_eosgs901ch = 
                     (~o_vld) ? xmzf :
                     (jtq949j67[0] & u6lh);
sdio_gnrl_dfflr #(DW) mbjepxkxu4_ce92d7  (q_eosgs901ch, md1jj1lh30i77nmk, j45yhs2ojom0i, clk, rst_n);
    assign o_dat = j45yhs2ojom0i;
    end
  wire dbmo2svd4diih;
  if (O_SUPPORT_RATIO == 0) begin : snaaccddjkzhior78m
    assign o_vld = (ygfrhv2[0]);
    assign dbmo2svd4diih = 1'b0;
  end
  else begin : ne28ujwjk5q
    wire wqh1xk12tb1wx4;
    wire cwuiap7kj2jc;
    wire qyk_33qh;
    wire b8qj2jum3wuyfu8vn;
    wire jtbjc9y8pb6z0zpnrvmai;
    wire odzuk4meol1h4l9p1f;
    wire dborpey8np5_dbhujp;
    wire h2qv646ipfychw2gzf79a6s;
    wire dszoj11p6dfb5oc5puz;
    assign b8qj2jum3wuyfu8vn = bb7bhv;
    assign jtbjc9y8pb6z0zpnrvmai = (b8qj2jum3wuyfu8vn   && !o_clk_en);
    assign odzuk4meol1h4l9p1f = (dszoj11p6dfb5oc5puz &&  o_clk_en);
    assign dborpey8np5_dbhujp = jtbjc9y8pb6z0zpnrvmai || odzuk4meol1h4l9p1f;
    assign h2qv646ipfychw2gzf79a6s = jtbjc9y8pb6z0zpnrvmai;
sdio_gnrl_dfflr  #(1) qa40h5xybc9965bize9x7hpb    (dborpey8np5_dbhujp, h2qv646ipfychw2gzf79a6s, dszoj11p6dfb5oc5puz,     clk, rst_n);
    assign wqh1xk12tb1wx4 = o_clk_en && (b8qj2jum3wuyfu8vn || dszoj11p6dfb5oc5puz);
    assign cwuiap7kj2jc = (bb7bhv) ? (jtq949j67[1]) : (ygfrhv2[0]);
sdio_gnrl_dfflr  #(1) jvoejq3q94bf2y9p_1    (wqh1xk12tb1wx4, cwuiap7kj2jc, qyk_33qh,     clk, rst_n);
    assign o_vld = qyk_33qh;
    assign dbmo2svd4diih = dszoj11p6dfb5oc5puz;
  end
  assign o_fifo_active =  i_vld || vcda0zbgh57i6 || o_vld || dbmo2svd4diih;
  end
endgenerate
endmodule
module sdio_gnrl_loop_stck # (
  parameter PAYLOAD_NORST = 0,
    parameter DP = 4,
    parameter DW = 32
)(
    input  i_wen,
    input  o_ren,
    input  [DW-1:0] i_dat,
    output [DW-1:0] o_dat,
    input  clk,
    input  rst_n
);
  wire [DW-1:0] j2ulx4qhzt6lr [DP-1:0];
  wire [DP-1:0] awm5wlzw6lh;
  wire [DP-1:0] oj7d_c;
  wire [DP-1:0] ygfrhv2;
  wire [DP-1:0] jtq949j67;
  wire [DP-1:0] j5rme6;
  wire bb7bhv = (o_ren ^ i_wen);
  assign jtq949j67 =     o_ren ?
                   (j5rme6[0] ? {1'b1,{DP-1{1'b0}}} : (j5rme6 >> 1)) :
                (j5rme6[DP-1] ? {{DP-1{1'b0}},1'b1} : (j5rme6 << 1))
                             ;
sdio_gnrl_dfflrs #(1)    v9onou3lach3(bb7bhv, jtq949j67[0]     , j5rme6[0]     , clk, rst_n);
sdio_gnrl_dfflr  #(DP-1) s1kmy6yeth7j9ydxn(bb7bhv, jtq949j67[DP-1:1], j5rme6[DP-1:1], clk, rst_n);
  assign oj7d_c = j5rme6; 
  assign ygfrhv2 = (j5rme6 == {{DP-1{1'b0}},1'b1}) ? {1'b1, {DP-1{1'b0}}}
                                                : (j5rme6 >> 1); 
  genvar zyod33;
  generate 
    for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:aeo4f786mqb3e
      assign awm5wlzw6lh[zyod33] = i_wen & oj7d_c[zyod33];      
      if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_dffl   #(DW) bu0j0cbv6rvelf9  (awm5wlzw6lh[zyod33], i_dat, j2ulx4qhzt6lr[zyod33], clk, rst_n);
      end
      else begin: lsj8oc4vo
sdio_gnrl_dfflr  #(DW) kow6ybpfchab7gt38 (awm5wlzw6lh[zyod33], i_dat, j2ulx4qhzt6lr[zyod33], clk, rst_n);
      end
    end
  endgenerate
  integer t;
  reg [DW-1:0] j45yhs2ojom0i;
  always @*
  begin : sosqjh1rrq34
    j45yhs2ojom0i = {DW{1'b0}};
    for(t=0; t<DP; t=t+1) begin
      j45yhs2ojom0i = j45yhs2ojom0i | ({DW{ygfrhv2[t]}} & j2ulx4qhzt6lr[t]);
    end
  end
  assign o_dat = j45yhs2ojom0i;
endmodule
module sdio_gnrl_cdc_buf
# (
  parameter PAYLOAD_NORST = 0,
  parameter I_ACTIVE_CUT_IVLD = 0,
  parameter DW = 32,
  parameter SYNC_DP = 2
) (
  input  i_clk,
  input  i_rst_n,
  input  i_vld,
  output i_rdy,
  input  [DW-1:0] i_dat,
  output i_cdc_buf_active,
  output o_cdc_buf_active,
  input  o_clk,
  input  o_rst_n,
  output o_vld,
  input  o_rdy,
  output [DW-1:0] o_dat
);
  wire igh_xd;
  wire js62qrh;
  wire [DW-1:0] hjd2j_9;
  sdio_gnrl_cdc_tx # (
    .PAYLOAD_NORST(PAYLOAD_NORST),
    .DW(DW),
    .SYNC_DP(SYNC_DP)
  ) adhahu64jblsrz(
    .i_vld  (i_vld),
    .i_rdy  (i_rdy),
    .i_dat  (i_dat),
    .o_vld  (igh_xd ),
    .o_rdy_a(js62qrh ),
    .o_dat  (hjd2j_9),
    .clk    (i_clk),
    .rst_n  (i_rst_n)
  );
  sdio_gnrl_cdc_rx # (
    .PAYLOAD_NORST(PAYLOAD_NORST),
    .DW(DW),
    .SYNC_DP(SYNC_DP)
   ) n58ygxtl_h6et3rwd(
    .i_vld_a (igh_xd ),
    .i_rdy   (js62qrh ),
    .i_dat   (hjd2j_9),
    .o_vld   (o_vld),
    .o_rdy   (o_rdy),
    .o_dat   (o_dat ),
    .clk    (o_clk),
    .rst_n  (o_rst_n)
  );
    generate 
        if(I_ACTIVE_CUT_IVLD == 1) begin: c4ryrb1vtx0vogk
  assign i_cdc_buf_active = igh_xd;
        end
        else begin: t2107pm1ybzn_mvufyj
  assign i_cdc_buf_active = i_vld  | igh_xd;
        end
    endgenerate
  assign o_cdc_buf_active = js62qrh | o_vld;
endmodule
module sdio_gnrl_2w1r_fifo # (
  parameter PAYLOAD_NORST = 0,
  parameter CUT_READY = 0,
  parameter MSKO = 0,
  parameter FIFO_REG_OUT = 0,
  parameter DP   = 8,
  parameter DW   = 32
) (
  input           i_vld0,
  input           i_vld1,
  output          i_rdy,
  input  [DW-1:0] i_dat0,
  input  [DW-1:0] i_dat1,
  output          o_vld,
  input           o_rdy,
  output [DW-1:0] o_dat,
  input           clk,
  input           rst_n
);
    wire [DW-1:0] jyb_xrvmlkepac [DP-1:0];
    wire [DW-1:0] bj7w712y4zlgc [DP-1:0];
    wire [DW-1:0] niyrz4zsknv [DP-1:0];
    wire [DP-1:0] b_bu0nqyxg3;
    wire [DP-1:0] np2ey8u6fspg;
    wire [DP-1:0] rreodx8nr3a;
    wire cxuiif23c = i_vld0 & i_rdy;
    wire g8gn0lw = i_vld1 & i_rdy;
    wire xmzf = (i_vld0 | i_vld1) & i_rdy;
    wire u6lh = o_vld & o_rdy;
    wire jubaeochg3vfh = cxuiif23c & g8gn0lw;
    wire [DP-1:0] jgpriggtm2y_fwywc;
    wire [DP-1:0] b9mzd4qdyk38db;
    wire [DP-1:0] ot40c525e9q7lz;
    wire [DP-1:0] ll6f8tv1_r2d1h;
    wire [DP-1:0] rgpkcprjgc_w9a;
    wire [DP-1:0] da85h5lrnc7oc238oqf94o = rgpkcprjgc_w9a << 1;
    wire [DP-1:0] kuojepy99g8 = rgpkcprjgc_w9a;
    wire [DP-1:0] ye66h5f6bs3upg = rgpkcprjgc_w9a[DP-1] ? {{DP-1{1'b0}}, 1'b1} : da85h5lrnc7oc238oqf94o;
    assign jgpriggtm2y_fwywc =
          ot40c525e9q7lz[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                          (ot40c525e9q7lz << 1);
    assign ll6f8tv1_r2d1h =
          rgpkcprjgc_w9a[DP-1] ? (jubaeochg3vfh ? {{DP-2{1'b0}}, 2'b10} : {{DP-1{1'b0}}, 1'b1}):
          rgpkcprjgc_w9a[DP-2] ? (jubaeochg3vfh ? {{DP-1{1'b0}}, 1'b1}  : da85h5lrnc7oc238oqf94o):
                             (jubaeochg3vfh ? (rgpkcprjgc_w9a << 2)    : da85h5lrnc7oc238oqf94o);
sdio_gnrl_dfflrs #(1)    ykwyawz_btbqa9homx3 (u6lh, jgpriggtm2y_fwywc[0]     , ot40c525e9q7lz[0]     , clk, rst_n);
sdio_gnrl_dfflrs #(1)    c7pydzj7ovdygd4aj1 (xmzf, ll6f8tv1_r2d1h[0]     , rgpkcprjgc_w9a[0]     , clk, rst_n);
sdio_gnrl_dfflr  #(DP-1) a9egrdivdf59anpv72p4iu (u6lh, jgpriggtm2y_fwywc[DP-1:1], ot40c525e9q7lz[DP-1:1], clk, rst_n);
sdio_gnrl_dfflr  #(DP-1) lvg4hw2b7ocga7kwrt (xmzf, ll6f8tv1_r2d1h[DP-1:1], rgpkcprjgc_w9a[DP-1:1], clk, rst_n);
    assign b9mzd4qdyk38db = u6lh  ? jgpriggtm2y_fwywc : ot40c525e9q7lz;
    wire [DP:0] oj7d_c;
    wire [DP:0] ygfrhv2;
    wire [DP:0] jtq949j67;
    wire [DP:0] j5rme6;
    wire bb7bhv =
                 (~(   (~(u6lh | cxuiif23c | g8gn0lw)) 
                      | (u6lh & (cxuiif23c ^ g8gn0lw))  
                    ))
                ;
    assign jtq949j67 =
                        ((~u6lh) & cxuiif23c & g8gn0lw)  ? {j5rme6[DP-2:0], 2'b11} :
                      (u6lh & (~cxuiif23c) & (~g8gn0lw)) ? (j5rme6 >> 1)
                                                : {j5rme6[DP-1:0], 1'b1}
                                                ;
sdio_gnrl_dfflrs #(1)  v9onou3lach3     (bb7bhv, jtq949j67[0]   , j5rme6[0]   ,     clk, rst_n);
sdio_gnrl_dfflr  #(DP) mgngavv5i6kdpvrx     (bb7bhv, jtq949j67[DP:1], j5rme6[DP:1],     clk, rst_n);
    assign oj7d_c = {1'b0,j5rme6[DP:1]};
    assign ygfrhv2 = {1'b0,j5rme6[DP:1]};
    genvar zyod33;
    generate 
    assign i_rdy = (~oj7d_c[DP-2]) | ((~oj7d_c[DP-1]) & (~(i_vld0 & i_vld1)));
      for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:oe5rsotr0ghvfl
        assign b_bu0nqyxg3[zyod33] = ((cxuiif23c|g8gn0lw) & kuojepy99g8[zyod33]);
        assign np2ey8u6fspg[zyod33] = ((cxuiif23c&g8gn0lw) & ye66h5f6bs3upg[zyod33]);
        assign rreodx8nr3a[zyod33]  = b_bu0nqyxg3[zyod33] | np2ey8u6fspg[zyod33];
        assign bj7w712y4zlgc[zyod33] = ({DW{b_bu0nqyxg3[zyod33]}} & (cxuiif23c ? i_dat0 : i_dat1))
                               | ({DW{np2ey8u6fspg[zyod33]}} & i_dat1)
                               ;
        if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_dffl   #(DW) dwpadh5cajhr0s  (rreodx8nr3a[zyod33],bj7w712y4zlgc[zyod33], niyrz4zsknv[zyod33], clk, rst_n);
        end
        else begin: lsj8oc4vo
sdio_gnrl_dfflr  #(DW) u6vxeldg1cpy9bd0ai (rreodx8nr3a[zyod33],bj7w712y4zlgc[zyod33], niyrz4zsknv[zyod33], clk, rst_n);
        end
        assign jyb_xrvmlkepac[zyod33] = rreodx8nr3a[zyod33] ? bj7w712y4zlgc[zyod33] : niyrz4zsknv[zyod33];
      end
    integer t;
    reg [DW-1:0] j45yhs2ojom0i;
    if(FIFO_REG_OUT == 0) begin:ryi755vbqjpdrspl
        always @*
        begin : sosqjh1rrq34
          j45yhs2ojom0i = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            j45yhs2ojom0i = j45yhs2ojom0i | ({DW{ot40c525e9q7lz[t]}} & niyrz4zsknv[t]);
          end
        end
    end
    else begin:hr23f8vxpi5ab_7q5yidy1
        reg [DW-1:0] md1jj1lh30i77nmk;
        wire [DW-1:0] d5kxup_m14;
        always @*
        begin : sosqjh1rrq34
          md1jj1lh30i77nmk = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            md1jj1lh30i77nmk = md1jj1lh30i77nmk | ({DW{b9mzd4qdyk38db[t]}} & jyb_xrvmlkepac[t]);
          end
        end
sdio_gnrl_dffr #(DW) j50inruuyv7ebtpj7  (md1jj1lh30i77nmk, d5kxup_m14, clk, rst_n);
        always @*
        begin : zu7415nupak_xh
            j45yhs2ojom0i = d5kxup_m14;
        end
    end
    endgenerate
    assign o_dat = j45yhs2ojom0i;
    assign o_vld = (ygfrhv2[0]);
endmodule
module sdio_gnrl_cdc_pulse
# (
  parameter I_ACTIVE_CUT_IVLD = 0,
  parameter SYNC_DP = 2
) (
  input  i_clk,
  input  i_rst_n,
  input  i_pulse,
  output i_active,
  output o_active,
  input  o_clk,
  input  o_rst_n,
  output o_pulse
);
sdio_gnrl_cdc_buf
# (
    .DW         (1      ),
    .I_ACTIVE_CUT_IVLD (I_ACTIVE_CUT_IVLD),
    .SYNC_DP    (SYNC_DP)
) u_gnrl_cdc_buf (
    .i_clk           (i_clk       ),
    .i_rst_n         (i_rst_n     ),
    .i_vld           (i_pulse     ),
    .i_rdy           (            ),
    .i_dat           (1'b0        ),
    .i_cdc_buf_active(i_active    ),
    .o_cdc_buf_active(o_active    ),
    .o_clk           (o_clk       ),
    .o_rst_n         (o_rst_n     ),
    .o_vld           (o_pulse     ),
    .o_rdy           (1'b1        ),
    .o_dat           (            )
);
endmodule
module sdio_gnrl_cdc_fifo #(
  parameter PAYLOAD_NORST = 0,
  parameter SMALL_DP_EN    = 0,
  parameter SMALL_DP       = 6,
  parameter SMALL_DP_PTR_W = 3,
  parameter DP   = 5,
  parameter DP_PTR_W   = 3,
  parameter DW   = 32,
  parameter SYNC_DP = 2
) (
  input  i_clk,
  input  i_rst_n,
  input  i_vld,
  output i_rdy,
  input  [DW-1:0] i_dat,
  output i_cdc_fifo_active,
  output o_cdc_fifo_active,
  input  o_clk,
  input  o_rst_n,
  output o_vld,
  input  o_rdy,
  output [DW-1:0] o_dat
);
  wire          otmj7   ;
  wire [DW-1:0] ip0gqy6;
  wire          c85n ;
  wire          x45gh8k   ;
  wire [DW-1:0] be92c8;
  wire          v1yo02r;
  wire          p8a2v6jenc;
  sdio_gnrl_async_fifo #(.DW(DW), .DP(DP),  .DP_PTR_W(DP_PTR_W), .SYNC_DP(SYNC_DP), 
                               .SMALL_DP_EN(SMALL_DP_EN),
       .PAYLOAD_NORST(PAYLOAD_NORST),
                               .SMALL_DP(SMALL_DP),  .SMALL_DP_PTR_W(SMALL_DP_PTR_W))
  sou40mf6fokv (
    .wclk     (i_clk),
    .wrst_n   (i_rst_n),
    .wr       (otmj7),
    .wdata    (ip0gqy6),
    .wwmk     (),
    .full     (c85n),
    .w_empty  (p8a2v6jenc),
    .rclk     (o_clk),
    .rrst_n   (o_rst_n),
    .rd       (x45gh8k),
    .rdata    (be92c8),
    .rwmk     (),
    .empty    (v1yo02r)
  );
  assign i_rdy = ~c85n;
  assign otmj7 = i_vld & i_rdy;
  assign ip0gqy6 = i_dat;
  assign o_vld = ~v1yo02r;
  assign x45gh8k = o_vld & o_rdy;
  assign o_dat = be92c8;
  assign i_cdc_fifo_active = (~p8a2v6jenc);
  assign o_cdc_fifo_active = ~v1yo02r;
endmodule
module sdio_gnrl_data_mux # (
  parameter DW = 8,
  parameter N  = 2,
  parameter SW = N<=1 ? 1 : N<=2**0 ? 0 : N<=2**1 ? 1 : N<=2**2 ? 2 : N<=2**3 ? 3 : N<=2**4 ? 4 : N<=2**5 ? 5 : N<=2**6 ? 6 : N<=2**7 ? 7 : N<=2**8 ? 8 : N<=2**9 ? 9 : N<=2**10 ? 10 : N<=2**11 ? 11 : N<=2**12 ? 12 : N<=2**13 ? 13 : N<=2**14 ? 14 : N<=2**15 ? 15 : N<=2**16 ? 16 : N<=2**17 ? 17 : N<=2**18 ? 18 : N<=2**19 ? 19 : N<=2**20 ? 20 : N<=2**21 ? 21 : N<=2**22 ? 22 : N<=2**23 ? 23 : N<=2**24 ? 24 : N<=2**25 ? 25 : N<=2**26 ? 26 : N<=2**27 ? 27 : N<=2**28 ? 28 : N<=2**29 ? 29 : N<=2**30 ? 30 : N<=2**31 ? 31 : 32
)(
  output   [DW-1:0] out_data,
  input  [N*DW-1:0] in_data,
  input    [SW-1:0] sel
);
  wire [DW-1:0] o6tp9oapry [N-1:0];
  wire  [N-1:0] nriv60yi15 [DW-1:0];
  wire  [N-1:0] vx026a1p6zieo0tx;
  genvar ylh, td3xl1_;
  generate
  for (ylh=0; ylh<N; ylh=ylh+1) begin: jabu3whdfeo_0y_r
    assign o6tp9oapry[ylh] = in_data[ylh*DW +: DW];
    assign vx026a1p6zieo0tx[ylh] = (ylh[SW-1:0] == sel);
    for (td3xl1_=0; td3xl1_<DW; td3xl1_=td3xl1_+1) begin: k_ehc40eqblimdkzb8
      assign nriv60yi15[td3xl1_][ylh] = o6tp9oapry[ylh][td3xl1_];
    end 
  end 
  for (ylh=0; ylh<DW; ylh=ylh+1) begin: ha2_zk1dc6uv
    assign out_data[ylh] = |(vx026a1p6zieo0tx & nriv60yi15[ylh]);
  end 
  endgenerate
endmodule
module sdio_gnrl_mem_line #(
  parameter DW = 8
)(
  input           clk,
  input           rst_n,
  input           wr,
  input  [DW-1:0] wdata,
  output [DW-1:0] mem
);
sdio_gnrl_dfflr #(DW) k_fohl0rl (wr, wdata, mem, clk, rst_n);
endmodule
module sdio_gnrl_async_mem_line #(
  parameter PAYLOAD_NORST = 0,
  parameter DW = 8
)(
  input           clk,
  input           rst_n,
  input           wr,
  input  [DW-1:0] wdata,
  output [DW-1:0] mem
);
      generate
        if(PAYLOAD_NORST == 1) begin: wxvqhx9c0s3m5
      sdio_gnrl_cdc_dffl  #(DW) plylmmoj  (wr, wdata, mem, clk, rst_n);  
        end
        else begin: h09eexcxl288
      sdio_gnrl_cdc_dfflr #(DW) k_fohl0rl (wr, wdata, mem, clk, rst_n);  
        end
      endgenerate
endmodule
module sdio_gnrl_hsk_arbt # (
  parameter DW = 64,
  parameter ARBT_SCHEME = 3,
  parameter ARBT_NUM = 4,
  parameter ARBT_PTR_W = 2
) (
  output          arbt_active,
  input           clk_en,
  output          o_valid,
  input           o_ready,
  output [DW-1:0] o_data,
  output          o_first,
  output          o_last,
  output [ARBT_NUM*1-1:0]     i_bus_ready,
  input  [ARBT_NUM*1-1:0]     i_bus_valid,
  input  [ARBT_NUM*DW-1:0]    i_bus_data,
  input  [ARBT_NUM-1:0]       i_bus_first,
  input  [ARBT_NUM-1:0]       i_bus_last,
  input  [ARBT_NUM*1-1:0]     i_bus_sel_vec,
  output [ARBT_NUM*1-1:0]     o_bus_sel_vec,
  input  clk,
  input  rst_n
  );
  localparam ARBT_SCHEME_PRIORITY  = 0;
  localparam ARBT_SCHEME_RROBIN    = 1;
  localparam ARBT_SCHEME_DIRECT_SEL_1HOT = 2;
  localparam ARBT_SCHEME_DIRECT_SEL_PRIORITY = 3;
  localparam ARBT_SCHEME_RROBIN4   = 4;
  wire qeps83syap64o771;
  wire [ARBT_NUM-1:0] crrklfd1m2rs6;
  wire [ARBT_NUM*1-1:0] nmr9l4r1qun9n7law4j00;
  wire [ARBT_NUM*1-1:0] qtr2s55ejba59kq9;
  wire [ARBT_NUM*1-1:0] mcbp1xdbjgxp82peth6;
genvar zyod33;
generate 
  if(ARBT_NUM == 1) begin:l4gysa2zusj4w3z70
    assign i_bus_ready   = o_ready    ;
    assign o_valid       = i_bus_valid;
    assign o_data        = i_bus_data;
    assign o_first       = i_bus_first;
    assign o_last        = i_bus_last;
    assign qeps83syap64o771 = 1'b0;
    assign crrklfd1m2rs6 = {ARBT_NUM{1'b0}};
    assign o_bus_sel_vec = 1'b1;
  end
  else begin:b0v5ggsgkl0ndenaxam7
    integer t;
    wire [ARBT_NUM-1:0] w6r3oczfw7qktc3w;
    wire [ARBT_NUM-1:0] j4bzhizomlk_l0;
    wire [DW-1:0] ctsczwus[ARBT_NUM-1:0];
    wire [1-1:0]  k2dx37np[ARBT_NUM-1:0];
    wire [1-1:0]  y9m2986g [ARBT_NUM-1:0];
    reg [DW-1:0] s86c0vnztqk39;
    reg          qdasjmcdc41x9c8i;
    reg          kge7y1_jk74vjfa;
    assign o_bus_sel_vec = j4bzhizomlk_l0;
    wire m6zb3mk1c;
    wire [ARBT_NUM-1:0] e4id9zc3nicxd0upmu;
    wire mk5lxvpwf6_5enj;
    wire l5a85ds5f3ly8xm6;
    wire uun2w9vhr7oh6_8sb;
    assign l5a85ds5f3ly8xm6 = o_first & m6zb3mk1c;
    assign uun2w9vhr7oh6_8sb = (|crrklfd1m2rs6) & o_last & m6zb3mk1c;
    assign mk5lxvpwf6_5enj = clk_en & (l5a85ds5f3ly8xm6 | uun2w9vhr7oh6_8sb);
    assign e4id9zc3nicxd0upmu = uun2w9vhr7oh6_8sb ? {ARBT_NUM{1'b0}} : (~j4bzhizomlk_l0); 
sdio_gnrl_dfflr #(ARBT_NUM) f4hsdz6498_nhr8nx (mk5lxvpwf6_5enj, e4id9zc3nicxd0upmu, crrklfd1m2rs6, clk, rst_n);
    assign mcbp1xdbjgxp82peth6   = (~crrklfd1m2rs6) & i_bus_valid;
    assign i_bus_ready       = (~crrklfd1m2rs6) & qtr2s55ejba59kq9;
    assign nmr9l4r1qun9n7law4j00 = (~crrklfd1m2rs6) & i_bus_sel_vec;
    for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
    begin:tsqdi1bddt45
      assign ctsczwus [zyod33] = i_bus_data[(zyod33+1)*DW-1 : zyod33*DW    ];
      assign k2dx37np[zyod33] = i_bus_first[(zyod33+1)*1-1 : zyod33*1    ];
      assign y9m2986g [zyod33] = i_bus_last [(zyod33+1)*1-1 : zyod33*1    ];
      assign qtr2s55ejba59kq9[zyod33] = w6r3oczfw7qktc3w[zyod33] & o_ready;
    end
    assign m6zb3mk1c = o_valid & o_ready;
    if(ARBT_SCHEME == ARBT_SCHEME_PRIORITY) begin:vse4djfcoaz0_43ayw8vv
      for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
      begin:zhgr5whl3_zllwvg75d_ht
        if(zyod33==0) begin: yytwajlol34m
          assign w6r3oczfw7qktc3w[zyod33] =  1'b1;
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33] & mcbp1xdbjgxp82peth6[zyod33];
        end
        else begin:aqslqoe0if2p42r1kw
          assign w6r3oczfw7qktc3w[zyod33] =  ~(|mcbp1xdbjgxp82peth6[zyod33-1:0]);
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33] & mcbp1xdbjgxp82peth6[zyod33];
        end
      end
      assign o_valid = |mcbp1xdbjgxp82peth6;
    end
   if(ARBT_SCHEME == ARBT_SCHEME_RROBIN) begin:k4qtizacs12rhs_x
     sdio_gnrl_rrobin # (
         .ARBT_NUM(ARBT_NUM)
     )u_sdio_gnrl_rrobin(
       .rrobin_active (qeps83syap64o771),
       .grt_vec  (w6r3oczfw7qktc3w),
       .req_vec  (mcbp1xdbjgxp82peth6),
       .arbt_ena (m6zb3mk1c & clk_en),
       .clk      (clk),
       .rst_n    (rst_n)
     );
     assign j4bzhizomlk_l0 = w6r3oczfw7qktc3w;
     assign o_valid = |mcbp1xdbjgxp82peth6;
   end
   else begin: tz_31vay7_k9_
     assign qeps83syap64o771 = 1'b0;
   end
   if(ARBT_SCHEME == ARBT_SCHEME_DIRECT_SEL_1HOT) begin:ym7z013npv4d335h
     assign w6r3oczfw7qktc3w = nmr9l4r1qun9n7law4j00;
     assign j4bzhizomlk_l0 = w6r3oczfw7qktc3w;
     assign o_valid = |(mcbp1xdbjgxp82peth6 & nmr9l4r1qun9n7law4j00);
   end
   if(ARBT_SCHEME == ARBT_SCHEME_DIRECT_SEL_PRIORITY) begin:pkcnhgt88ra15bet3ybncbj4gd2
      for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
      begin:zhgr5whl3_zllwvg75d_ht
        if(zyod33==0) begin: yytwajlol34m
          assign w6r3oczfw7qktc3w[zyod33] =  1'b1;
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33] & nmr9l4r1qun9n7law4j00[zyod33];
        end
        else if(zyod33==(ARBT_NUM-1)) begin: n9rhk_odki4l7
          assign w6r3oczfw7qktc3w[zyod33] =  ~(|nmr9l4r1qun9n7law4j00[zyod33-1:0]);
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33];
        end
        else begin:aqslqoe0if2p42r1kw
          assign w6r3oczfw7qktc3w[zyod33] =  ~(|nmr9l4r1qun9n7law4j00[zyod33-1:0]);
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33] & nmr9l4r1qun9n7law4j00[zyod33];
        end
      end
      assign o_valid = |(mcbp1xdbjgxp82peth6 & j4bzhizomlk_l0);
    end
   if(ARBT_SCHEME == ARBT_SCHEME_RROBIN4) begin:fmgea_uw5u_uiffay
      sdio_gnrl_rbin4 # (
          .ARBT_NUM(ARBT_NUM)
      )u_sdio_gnrl_rbin4(
        .grt_vec  (w6r3oczfw7qktc3w),
        .req_vec  (nmr9l4r1qun9n7law4j00),
        .arbt_ena (m6zb3mk1c & clk_en & (~l5a85ds5f3ly8xm6)),
        .rbin4_active (),
        .clk      (clk),
        .rst_n    (rst_n)
      );
      assign j4bzhizomlk_l0 = w6r3oczfw7qktc3w & nmr9l4r1qun9n7law4j00;
      assign o_valid = |(mcbp1xdbjgxp82peth6 & j4bzhizomlk_l0);
   end
    always @ (*) begin : jlekx6bp3syeq992h
      s86c0vnztqk39  = {DW  {1'b0}};
      qdasjmcdc41x9c8i = 1'b0;
      kge7y1_jk74vjfa  = 1'b0;
      for(t = 0; t < ARBT_NUM; t = t+1) begin
        s86c0vnztqk39  = s86c0vnztqk39  | ({DW{j4bzhizomlk_l0[t]}} & ctsczwus [t]);
        qdasjmcdc41x9c8i = qdasjmcdc41x9c8i | (    j4bzhizomlk_l0[t]   & k2dx37np[t]);
        kge7y1_jk74vjfa  = kge7y1_jk74vjfa  | (    j4bzhizomlk_l0[t]   & y9m2986g [t]);
      end
    end
    assign o_data  = s86c0vnztqk39;
    assign o_first = qdasjmcdc41x9c8i;
    assign o_last  = kge7y1_jk74vjfa;
  end
  endgenerate 
  assign arbt_active = (|i_bus_valid) | qeps83syap64o771;
endmodule
module sdio_gnrl_hsk_arbt_1cycle # (
  parameter DW = 64,
  parameter ARBT_SCHEME = 3,
  parameter ARBT_NUM = 4,
  parameter ARBT_PTR_W = 2
) (
  output          arbt_active,
  input           clk_en,
  output          o_valid,
  input           o_ready,
  output [DW-1:0] o_data,
  output [ARBT_NUM*1-1:0]     i_bus_ready,
  input  [ARBT_NUM*1-1:0]     i_bus_valid,
  input  [ARBT_NUM*1-1:0]     i_bus_busy,
  input  [ARBT_NUM*DW-1:0]    i_bus_data,
  input                       i_bus_grt_rply,
  input  [ARBT_NUM*1-1:0]     i_bus_sel_vec,
  output [ARBT_NUM*1-1:0]     o_bus_sel_vec,
  input  clk,
  input  rst_n
  );
  localparam ARBT_SCHEME_PRIORITY  = 0;
  localparam ARBT_SCHEME_RROBIN    = 1;
  localparam ARBT_SCHEME_DIRECT_SEL_1HOT = 2;
  localparam ARBT_SCHEME_DIRECT_SEL_PRIORITY = 3;
  localparam ARBT_SCHEME_RROBIN4   = 4;
  localparam ARBT_SCHEME_RROBIN_DA = 6;
  wire qeps83syap64o771;
  wire [ARBT_NUM*1-1:0] nmr9l4r1qun9n7law4j00;
  wire [ARBT_NUM*1-1:0] qtr2s55ejba59kq9;
  wire [ARBT_NUM*1-1:0] mcbp1xdbjgxp82peth6;
genvar zyod33;
generate 
  if(ARBT_NUM == 1) begin:l4gysa2zusj4w3z70
    assign i_bus_ready   = o_ready    ;
    assign o_valid       = i_bus_valid;
    assign o_data        = i_bus_data;
    assign qeps83syap64o771 = 1'b0;
    assign o_bus_sel_vec = 1'b1;
  end
  else begin:b0v5ggsgkl0ndenaxam7
    integer t;
    wire [ARBT_NUM-1:0] w6r3oczfw7qktc3w;
    wire [ARBT_NUM-1:0] j4bzhizomlk_l0;
    wire [DW-1:0] ctsczwus[ARBT_NUM-1:0];
    reg [DW-1:0] s86c0vnztqk39;
    assign o_bus_sel_vec = j4bzhizomlk_l0;
    wire m6zb3mk1c;
    assign mcbp1xdbjgxp82peth6   = i_bus_valid;
    assign i_bus_ready       = qtr2s55ejba59kq9;
    assign nmr9l4r1qun9n7law4j00 = i_bus_sel_vec;
    for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
    begin:tsqdi1bddt45
      assign ctsczwus [zyod33] = i_bus_data[(zyod33+1)*DW-1 : zyod33*DW    ];
      assign qtr2s55ejba59kq9[zyod33] = w6r3oczfw7qktc3w[zyod33] & o_ready;
    end
    assign m6zb3mk1c = o_valid & o_ready;
    if(ARBT_SCHEME == ARBT_SCHEME_PRIORITY) begin:vse4djfcoaz0_43ayw8vv
      for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
      begin:zhgr5whl3_zllwvg75d_ht
        if(zyod33==0) begin: yytwajlol34m
          assign w6r3oczfw7qktc3w[zyod33] =  1'b1;
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33] & mcbp1xdbjgxp82peth6[zyod33];
        end
        else begin:aqslqoe0if2p42r1kw
          assign w6r3oczfw7qktc3w[zyod33] =  ~(|mcbp1xdbjgxp82peth6[zyod33-1:0]);
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33] & mcbp1xdbjgxp82peth6[zyod33];
        end
      end
      assign o_valid = |mcbp1xdbjgxp82peth6;
    end
   if(ARBT_SCHEME == ARBT_SCHEME_RROBIN) begin:k4qtizacs12rhs_x
    wire qjoy2bgp3ah_8eg9pb = clk_en & o_ready;
     sdio_gnrl_rrobin_1cycle # (
         .ARBT_NUM(ARBT_NUM)
     )u_sdio_gnrl_rrobin(
       .rrobin_active (qeps83syap64o771),
       .grt_vec  (w6r3oczfw7qktc3w),
       .req_vec  (mcbp1xdbjgxp82peth6),
       .arbt_ena (qjoy2bgp3ah_8eg9pb),
       .clk      (clk),
       .rst_n    (rst_n)
     );
     assign j4bzhizomlk_l0 = w6r3oczfw7qktc3w;
     assign o_valid = |mcbp1xdbjgxp82peth6;
   end
   else if(ARBT_SCHEME == ARBT_SCHEME_RROBIN_DA) begin:kypftyr2ehmvzh89rkz40
    wire qjoy2bgp3ah_8eg9pb = clk_en & o_ready;
     sdio_gnrl_rrobin_1cycle_da # (
         .ARBT_NUM(ARBT_NUM)
     )u_sdio_gnrl_rrobin(
       .rrobin_active (qeps83syap64o771),
       .grt_vec  (w6r3oczfw7qktc3w),
       .buz_vec  (i_bus_busy),
       .req_vec  (mcbp1xdbjgxp82peth6),
       .arbt_ena (qjoy2bgp3ah_8eg9pb),
       .arbt_rply(i_bus_grt_rply),
       .clk      (clk),
       .rst_n    (rst_n)
     );
     assign j4bzhizomlk_l0 = w6r3oczfw7qktc3w;
     assign o_valid = |mcbp1xdbjgxp82peth6;
   end
   else begin: tz_31vay7_k9_
     assign qeps83syap64o771 = 1'b0;
   end
   if(ARBT_SCHEME == ARBT_SCHEME_DIRECT_SEL_1HOT) begin:ym7z013npv4d335h
     assign w6r3oczfw7qktc3w = nmr9l4r1qun9n7law4j00;
     assign j4bzhizomlk_l0 = w6r3oczfw7qktc3w;
     assign o_valid = |(mcbp1xdbjgxp82peth6 & nmr9l4r1qun9n7law4j00);
   end
   if(ARBT_SCHEME == ARBT_SCHEME_DIRECT_SEL_PRIORITY) begin:pkcnhgt88ra15bet3ybncbj4gd2
      for(zyod33 = 0; zyod33 < ARBT_NUM; zyod33 = zyod33+1)
      begin:zhgr5whl3_zllwvg75d_ht
        if(zyod33==0) begin: yytwajlol34m
          assign w6r3oczfw7qktc3w[zyod33] =  1'b1;
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33] & nmr9l4r1qun9n7law4j00[zyod33];
        end
        else if(zyod33==(ARBT_NUM-1)) begin: n9rhk_odki4l7
          assign w6r3oczfw7qktc3w[zyod33] =  ~(|nmr9l4r1qun9n7law4j00[zyod33-1:0]);
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33];
        end
        else begin:aqslqoe0if2p42r1kw
          assign w6r3oczfw7qktc3w[zyod33] =  ~(|nmr9l4r1qun9n7law4j00[zyod33-1:0]);
          assign j4bzhizomlk_l0[zyod33] = w6r3oczfw7qktc3w[zyod33] & nmr9l4r1qun9n7law4j00[zyod33];
        end
      end
      assign o_valid = |(mcbp1xdbjgxp82peth6 & j4bzhizomlk_l0);
    end
   if(ARBT_SCHEME == ARBT_SCHEME_RROBIN4) begin:fmgea_uw5u_uiffay
      sdio_gnrl_rbin4 # (
          .ARBT_NUM(ARBT_NUM)
      )u_sdio_gnrl_rbin4(
        .grt_vec  (w6r3oczfw7qktc3w),
        .req_vec  (nmr9l4r1qun9n7law4j00),
        .rbin4_active (),
        .arbt_ena (clk_en),
        .clk      (clk),
        .rst_n    (rst_n)
      );
      assign j4bzhizomlk_l0 = w6r3oczfw7qktc3w & nmr9l4r1qun9n7law4j00;
      assign o_valid = |(mcbp1xdbjgxp82peth6 & j4bzhizomlk_l0);
   end
    always @ (*) begin : jlekx6bp3syeq992h
      s86c0vnztqk39  = {DW  {1'b0}};
      for(t = 0; t < ARBT_NUM; t = t+1) begin
        s86c0vnztqk39  = s86c0vnztqk39  | ({DW{j4bzhizomlk_l0[t]}} & ctsczwus [t]);
      end
    end
    assign o_data  = s86c0vnztqk39;
  end
  endgenerate 
  assign arbt_active = (|i_bus_valid) | qeps83syap64o771;
endmodule
module sdio_gnrl_xshft_rng (clk, rst_n, load, seed, en, rnd);
  localparam DW = 32;
  localparam [DW-1:0] INIT = 32'h0000_1208;
  input           clk;
  input           rst_n;
  input           load;
  input  [DW-1:0] seed;
  input           en;
  output [DW-1:0] rnd;
  wire [DW-1:0] w66a53aj = rnd ^ (rnd >> 13);
  wire [DW-1:0] mtd1zky7w = w66a53aj ^ (w66a53aj << 3);
  wire [DW-1:0] aou125awd = mtd1zky7w ^ (mtd1zky7w >> 17);
  wire          o5hg1v3r;
  wire [DW-1:0] nwancw08;
  assign o5hg1v3r = load | en;
  assign nwancw08 = load ? seed : aou125awd;
sdio_gnrl_dfflrs #(DW,INIT) t1gds0j2s7uw22(o5hg1v3r, nwancw08, rnd, clk, rst_n);
endmodule 
module sdio_gnrl_async_fifo_ctl # (
  parameter DP = 4,
  parameter DP_PTR_W = 2,
  parameter WWMK = 1,
  parameter RWMK = 1,
  parameter SYNC_DP = 2,
  parameter        AW = (DP <= 1) ? 1 : DP_PTR_W 
)(
  input           wclk,
  input           wrst_n,
  input           wr,
  output          wwmk,
  output          full,
  output          w_empty,
  output [AW-1:0] waddr,
  input           rclk,
  input           rrst_n,
  input           rd,
  output          rwmk,
  output          empty,
  output [AW-1:0] raddr,
  output          r_cs
);
  localparam [AW:0] PTR_START = {{1'b1},{(AW){1'b0}}} - DP;
  localparam [AW:0] PTR_END   = (~PTR_START);
  localparam [AW:0] PTR_START_G = bin2gray(PTR_START);
  wire   [AW:0] xuhv8a8lt9z;
  wire          uhydco1vv28b;
  wire   [AW:0] aile9v4o5, k85njydoiwdjh;
  wire [AW-1:0] aelyqs8emm;
  wire   [AW:0] jio2qw95_q6j8, jtfewiztsvlv;
  wire [AW-1:0] defi7gogyjrak;
  wire   [AW:0] uo3jf4;
  wire   [AW:0] mpsh_9c9;
  wire   [AW:0] r2dt6s7veaa;
  wire [AW-1:0] w4_4qkf0bdgf0h;
  wire          js0l1zoypx60a;
  wire   [AW:0] rf7_qttup9b_y;
  wire   [AW:0] ht96eflevtdunk;
  wire          uace787_4c;
  wire   [AW:0] j_3qu4n0gfs1, ycybe4a6hca1;
  wire   [AW:0] asrlevn2s5v0b, si138ubbhci;
  wire [AW-1:0] tnnxb7rf3iug05;
  wire   [AW:0] c543z;
  wire   [AW:0] gu63orhqn1e;
  wire   [AW:0] pr9t39kwn_;
  wire [AW-1:0] ujaqaw3jbuf6;
  wire          dsuyd27nx5;
  wire   [AW:0] ezm6b6wvii_;
  sdio_gnrl_sync #(
  .DW(AW+1),
  .RST_VAL(PTR_START_G),
  .DP(SYNC_DP))
  xfc1fcu2hmv35k4cpe (
  .clk(wclk),
  .rst_n(wrst_n),
  .din_a(gu63orhqn1e),
  .dout(xuhv8a8lt9z)
  );
  sdio_gnrl_sync #(
  .DW(AW+1),
  .RST_VAL(PTR_START_G),
  .DP(SYNC_DP))
  nnct8aiurc_7t9tl9iv (
  .clk(rclk),
  .rst_n(rrst_n),
  .din_a(mpsh_9c9),
  .dout(ht96eflevtdunk)
  );
  assign uhydco1vv28b = wr & (~full);
  assign aile9v4o5   = ((uo3jf4 == PTR_END) ? PTR_START : uo3jf4 + ({(AW+1){1'b1}} >> (AW+1-1)));
  assign k85njydoiwdjh = bin2gray(aile9v4o5);
  assign aelyqs8emm  = bf0n9gyh0jchw(aile9v4o5);
  assign jio2qw95_q6j8   = uhydco1vv28b ? aile9v4o5 : uo3jf4;
  assign jtfewiztsvlv = bin2gray(jio2qw95_q6j8);
  assign defi7gogyjrak  = bf0n9gyh0jchw(jio2qw95_q6j8);
  assign uo3jf4 = avcyhbvpp(mpsh_9c9);
sdio_gnrl_dfflrs #(AW+1, PTR_START_G) mzstx97pl_8dkg (uhydco1vv28b, k85njydoiwdjh, mpsh_9c9, wclk, wrst_n);
sdio_gnrl_dfflr  #(AW)                y5se9q9vq7aa   (uhydco1vv28b, aelyqs8emm, waddr, wclk, wrst_n);
  assign r2dt6s7veaa = avcyhbvpp(xuhv8a8lt9z);
  assign w4_4qkf0bdgf0h = bf0n9gyh0jchw(r2dt6s7veaa);
  assign js0l1zoypx60a = (jtfewiztsvlv[AW] ^ xuhv8a8lt9z[AW]);
  wire irgzh0i6ltu;
  assign irgzh0i6ltu = js0l1zoypx60a & (defi7gogyjrak == w4_4qkf0bdgf0h);
sdio_gnrl_dffr #(1) ughy_h8sm (irgzh0i6ltu, full, wclk, wrst_n);
  wire x6b41jsrjingr0;
  assign x6b41jsrjingr0 = (~js0l1zoypx60a) & (defi7gogyjrak == w4_4qkf0bdgf0h);
sdio_gnrl_dffrs #(1, 1'b1) vtvq825ux725xd3lj (x6b41jsrjingr0, w_empty, wclk, wrst_n);
  assign rf7_qttup9b_y = js0l1zoypx60a ? {1'b0, w4_4qkf0bdgf0h} - (DP[AW:0]-WWMK[AW:0])
                               : {1'b0, w4_4qkf0bdgf0h} + WWMK[AW:0];
  wire to9w6nga3o;
  assign to9w6nga3o = ({1'b0, defi7gogyjrak} >= rf7_qttup9b_y) | (js0l1zoypx60a & rf7_qttup9b_y[AW]);
sdio_gnrl_dffr #(1) aziq18_md8 (to9w6nga3o, wwmk, wclk, wrst_n);
  assign uace787_4c = rd & (~empty);
  wire yln2lc2wyj;
  assign r_cs = (~yln2lc2wyj) & (empty | rd);
  assign j_3qu4n0gfs1   = ((c543z == PTR_END) ? PTR_START : c543z + ({(AW+1){1'b1}} >> (AW+1-1)));
  assign ycybe4a6hca1 = bin2gray(j_3qu4n0gfs1);
  assign asrlevn2s5v0b   = uace787_4c ? j_3qu4n0gfs1 : c543z;
  assign si138ubbhci = bin2gray(asrlevn2s5v0b);
  assign tnnxb7rf3iug05  = bf0n9gyh0jchw(asrlevn2s5v0b);
  assign c543z = avcyhbvpp(gu63orhqn1e);
sdio_gnrl_dfflrs #(AW+1, PTR_START_G) ziwbb9srqhwagv8q41 (uace787_4c, ycybe4a6hca1, gu63orhqn1e, rclk, rrst_n);
  assign raddr = tnnxb7rf3iug05;
  assign pr9t39kwn_ = avcyhbvpp(ht96eflevtdunk);
  assign ujaqaw3jbuf6 = bf0n9gyh0jchw(pr9t39kwn_);
  assign dsuyd27nx5 = (si138ubbhci[AW] ^ ht96eflevtdunk[AW]);
  wire f0nh8n63m_s8;
  assign f0nh8n63m_s8 = (~dsuyd27nx5) & (tnnxb7rf3iug05 == ujaqaw3jbuf6);
sdio_gnrl_dffrs #(1, 1'b1) zbfnzbhogdty (f0nh8n63m_s8, empty, rclk, rrst_n);
  assign yln2lc2wyj = f0nh8n63m_s8;
  assign ezm6b6wvii_ = dsuyd27nx5 ? {1'b0, ujaqaw3jbuf6} + (DP[AW:0]-RWMK[AW:0])
                               : {1'b0, ujaqaw3jbuf6} - RWMK[AW:0];
  wire x6na2e6by20;
  assign x6na2e6by20 = ({1'b0, tnnxb7rf3iug05} <= ezm6b6wvii_) & (dsuyd27nx5 | (~ezm6b6wvii_[AW]));
sdio_gnrl_dffrs #(1, 1'b1) ckygeo67lciel (x6na2e6by20, rwmk, rclk, rrst_n);
  function automatic [AW:0] bin2gray;
    input [AW:0] bin;
    bin2gray = bin ^ (bin>>1);
  endfunction
  function automatic [AW:0] avcyhbvpp;
    input [AW:0] gray;
    integer zyod33;
    for (zyod33=0; zyod33<AW+1; zyod33=zyod33+1) begin
      avcyhbvpp[zyod33] = (^(gray>>zyod33));
    end
  endfunction
  function automatic [AW-1:0] bf0n9gyh0jchw;
    input [AW:0] ptr;
    bf0n9gyh0jchw = ptr[AW] ? ptr[AW-1:0] : (ptr[AW-1:0] - PTR_START[AW-1:0]);
  endfunction
endmodule 
module sdio_gnrl_async_fifo #(
  parameter PAYLOAD_NORST    = 0,
  parameter SMALL_DP_EN    = 0,
  parameter SMALL_DP       = 6,
  parameter SMALL_DP_PTR_W = 3,
  parameter DW = 4,
  parameter DP = 4,
  parameter DP_PTR_W = 2,
  parameter WWMK = 1,
  parameter RWMK = 1,
  parameter SYNC_DP = 2 
)(
  input           wclk,
  input           wrst_n,
  input           wr,
  input  [DW-1:0] wdata,
  output          wwmk,
  output          full,
  output          w_empty,
  input           rclk,
  input           rrst_n,
  input           rd,
  output [DW-1:0] rdata,
  output          rwmk,
  output          empty
);
  localparam I_DP       = SMALL_DP_EN ? SMALL_DP       : (DP < 8 ) ? 8 : DP;
  localparam I_DP_PTR_W = SMALL_DP_EN ? SMALL_DP_PTR_W : (DP < 8 ) ? 3 : DP_PTR_W;
  localparam AW = I_DP_PTR_W;
  wire [AW-1:0] l0vzcq, ojig6nlxc;
 wire wmm66qiu9;
  sdio_gnrl_async_fifo_ctl #(
  .DP(I_DP),
  .DP_PTR_W(I_DP_PTR_W),
  .WWMK(WWMK),
  .RWMK(RWMK),
  .SYNC_DP(SYNC_DP))
  uc84ezs8c5 (
  .wclk(wclk),
  .wrst_n(wrst_n),
  .wr(wr),
  .full(full),
  .wwmk(wwmk),
  .waddr(l0vzcq),
  .rclk(rclk),
  .rrst_n(rrst_n),
  .rd(rd),
  .empty(empty),
  .rwmk(rwmk),
  .raddr(ojig6nlxc),
  .r_cs(wmm66qiu9),
  .w_empty(w_empty)
  );
  sdio_gnrl_async_sdp_ram #(
  .PAYLOAD_NORST(PAYLOAD_NORST),
  .DW(DW),
  .DP(I_DP),
  .DP_PTR_W(AW),
  .REG_OUT(1))
  isj2b9 (
  .wclk(wclk),
  .wrst_n(wrst_n),
  .wr(wr),
  .waddr(l0vzcq),
  .wdata(wdata),
  .rclk(rclk),
  .rrst_n(rrst_n),
  .rd(wmm66qiu9),
  .raddr(ojig6nlxc),
  .rdata(rdata)
  );
endmodule 
module sdio_hand_mux_bit (X, S, D0, D1);
  output         X;
  input          S;
  input          D0, D1;
`ifdef TECH_SMIC14SFP_9T
  CLKMUX2V2_96D9T16R u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_SMIC40NLL_8T
  CKMUX2V2_8TR40 u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_SMIC40NLL_12T
  CLKMUX2V2_12TR40 u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_SMIC40NLL_12T_3V3
  MUX2V2_12TROD33 u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_SMIC40NLL_SNPS
  STN_MUX2_DG_4 u_std_mux2 (.X(X), .D0(D0), .D1(D1), .S(S));
`endif
`ifdef TECH_TSMC28_HPCP_9T
  CKMUX2D4BWP30P140 u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_TSMC22_ULP_9T
  CKMUX2D4BWP30P140 u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_TSMC22_ULP_7T
  CKMUX2D1BWP7T30P140 u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_TSMC22_ULP_ARM_9T
  MXGL2_X4B_A9PP140ZTS_C40 u_std_mux2 (.Y(X), .A(D0), .B(D1), .S0(S));
`endif
`ifdef TECH_TSMC22_ULL_9T
  CKMUX2D1BWP35P140 u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_TSMC22_ULL_7T
  CKMUX2D1BWP7T35P140 u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_TSMC12_FFC_9T_CPD
  CKMUX2D1BWP16P90CPD u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_TSMC12_FFC_7D5T_CPD
  CKMUX2D1BWP7D5T16P96CPD u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_TSMC12_FFC_6T_CPD
  CKMUX2D1BWP6T16P96CPD u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_UMC28_HPC_ARM_7T
  MXGL2_X6B_A7PP140ZTR_C40 u_std_mux2 (.Y(X), .A(D0), .B(D1), .S0(S));
`endif
`ifdef TECH_SMIC28HKCP_7T
  CKMUX2V2_140P7T30R u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_SMIC28HKCP_12T
  CLKMUX2V4_140P12T30R u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifdef TECH_SMIC28HKCP_9T
  CLKMUX2V4_140P9T30R u_std_mux2 (.Z(X), .I0(D0), .I1(D1), .S(S));
`endif
`ifndef TECH_SMIC14SFP_9T 
`ifndef TECH_SMIC40NLL_8T 
`ifndef TECH_SMIC40NLL_12T 
`ifndef TECH_SMIC40NLL_12T_3V3 
`ifndef TECH_SMIC40NLL_SNPS 
`ifndef TECH_TSMC28_HPCP_9T 
`ifndef TECH_TSMC22_ULP_9T 
`ifndef TECH_TSMC22_ULP_7T 
`ifndef TECH_TSMC22_ULP_ARM_9T 
`ifndef TECH_TSMC22_ULL_9T 
`ifndef TECH_TSMC22_ULL_7T 
`ifndef TECH_TSMC12_FFC_9T_CPD 
`ifndef TECH_TSMC12_FFC_7D5T_CPD 
`ifndef TECH_TSMC12_FFC_6T_CPD 
`ifndef TECH_UMC28_HPC_ARM_7T 
`ifndef TECH_SMIC28HKCP_7T 
`ifndef TECH_SMIC28HKCP_12T 
`ifndef TECH_SMIC28HKCP_9T 
  assign X = S ?  D1 : D0;
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
`endif 
endmodule 
module sdio_gnrl_sdp_ram #(
  parameter DW = 8,
  parameter DP = 4,
  parameter DP_PTR_W = 2,
  parameter REG_OUT = 1,
  parameter AW = (DP <= 1) ? 1 : DP_PTR_W
)(
  input           wclk,
  input           wrst_n,
  input           wr,
  input  [AW-1:0] waddr,
  input  [DW-1:0] wdata,
  input           rclk,
  input           rrst_n,
  input           rd,
  input  [AW-1:0] raddr,
  output [DW-1:0] rdata
);
  wire    [DP-1:0] lpy87v_p1cdrz29, oj99usyt4sq;
  wire [DP*DW-1:0] srd;
  wire    [DW-1:0] fxli5swyu;
  genvar ylh;
  generate
  for (ylh=0; ylh<DP; ylh=ylh+1) begin: yzbiaobub4gtwxcgs
    assign lpy87v_p1cdrz29[ylh] = wr & (waddr == ylh[AW-1:0]);
  end 
  endgenerate
  generate
  for (ylh=0; ylh<DP; ylh=ylh+1) begin: ba5u267pm
  sdio_gnrl_mem_line #(.DW(DW)) 
  ds3budo50vaee9q (
  .clk(wclk), 
  .rst_n(wrst_n), 
  .wr(lpy87v_p1cdrz29[ylh]), 
  .wdata(wdata), 
  .mem(srd[ylh*DW+DW-1:ylh*DW])
  );
  end 
  endgenerate
  sdio_gnrl_data_mux #(.DW(DW), .N(DP))
  hy8k3je0md8 (
  .out_data(fxli5swyu),
  .in_data(srd),
  .sel(raddr)
  );
  generate
  if (REG_OUT > 0) begin: t70ht09qz6s7
sdio_gnrl_dfflr #(DW) mnynj9me6ux (rd, fxli5swyu, rdata, rclk, rrst_n);
  end 
  else begin: fzybe207a3p
    assign rdata = fxli5swyu;
  end 
  endgenerate
endmodule 
module sdio_gnrl_async_sdp_ram #(
  parameter DW = 8,
  parameter DP = 4,
  parameter DP_PTR_W = 2,
  parameter REG_OUT = 1,
  parameter PAYLOAD_NORST = 0,
  parameter AW = (DP <= 1) ? 1 : DP_PTR_W
)(
  input           wclk,
  input           wrst_n,
  input           wr,
  input  [AW-1:0] waddr,
  input  [DW-1:0] wdata,
  input           rclk,
  input           rrst_n,
  input           rd,
  input  [AW-1:0] raddr,
  output [DW-1:0] rdata
);
  wire    [DP-1:0] lpy87v_p1cdrz29, oj99usyt4sq;
  wire [DP*DW-1:0] srd;
  wire    [DW-1:0] fxli5swyu;
  genvar ylh;
  generate
  for (ylh=0; ylh<DP; ylh=ylh+1) begin: yzbiaobub4gtwxcgs
    assign lpy87v_p1cdrz29[ylh] = wr & (waddr == ylh[AW-1:0]);
  end 
  endgenerate
  generate
  for (ylh=0; ylh<DP; ylh=ylh+1) begin: ba5u267pm
  sdio_gnrl_async_mem_line #(.DW(DW), .PAYLOAD_NORST(PAYLOAD_NORST)) 
  ds3budo50vaee9q (
  .clk(wclk), 
  .rst_n(wrst_n), 
  .wr(lpy87v_p1cdrz29[ylh]), 
  .wdata(wdata), 
  .mem(srd[ylh*DW+DW-1:ylh*DW])
  );
  end 
  endgenerate
  sdio_gnrl_data_mux #(.DW(DW), .N(DP))
  hy8k3je0md8 (
  .out_data(fxli5swyu),
  .in_data(srd),
  .sel(raddr)
  );
  generate
  if (REG_OUT > 0) begin: t70ht09qz6s7
    if(PAYLOAD_NORST == 1) begin: wxvqhx9c0s3m5
    sdio_gnrl_cdc_dffl  #(DW) rdata_gnrl_cdc_dest_dffl  (rd, fxli5swyu, rdata, rclk, rrst_n);
    end
    else begin: h09eexcxl288
    sdio_gnrl_cdc_dfflr #(DW) rdata_gnrl_cdc_dest_dfflr (rd, fxli5swyu, rdata, rclk, rrst_n);
    end
  end 
  else begin: fzybe207a3p
    assign rdata = fxli5swyu;
  end 
  endgenerate
endmodule 
module sdio_reset_sync #(
  parameter RST_SYNC_LEVEL = 2
)(
  input  clk,        
  input  rst_n_a,    
  input  reset_bypass,  
  output rst_n_sync
);
  wire gpkcbh8vldzw7iqc;
  sdio_gnrl_sync #(
  .DW(1), 
  .DP(RST_SYNC_LEVEL)
  ) ncvfw5a8mx (
  .clk(clk), 
  .rst_n(rst_n_a), 
  .din_a(1'b1), 
  .dout(gpkcbh8vldzw7iqc)
  );
`ifndef SYNTHESIS
  assign rst_n_sync = reset_bypass ? rst_n_a : gpkcbh8vldzw7iqc;
`else
  sdio_hand_mux_bit n5609l1jc2t_m8 ( .D0(gpkcbh8vldzw7iqc), .D1(rst_n_a), .S(reset_bypass), .X(rst_n_sync) );
`endif
endmodule
module sdio_gnrl_cdc_rx
# (
  parameter PAYLOAD_NORST = 0,
  parameter READY_THROUGH = 0,
  parameter DW = 32,
  parameter SYNC_DP = 2
) (
  input  i_vld_a, 
  output i_rdy, 
  input  [DW-1:0] i_dat,
  output o_vld, 
  input  o_rdy, 
  output [DW-1:0] o_dat,
  input  clk,
  input  rst_n 
);
wire s_2rar7n07qd6bb;
sdio_gnrl_sync #(.DP(SYNC_DP), .DW(1)) x3c51prtob63kyalw (
     .clk   (clk),
     .rst_n (rst_n),
     .din_a (i_vld_a),
     .dout  (s_2rar7n07qd6bb)
    );
wire x2toa_r7drijimj9;
sdio_gnrl_dffr #(1) cpaflpmdwdcfmlif632(s_2rar7n07qd6bb, x2toa_r7drijimj9, clk, rst_n);
wire a87b1ashf2guzys8wbbcy = (~s_2rar7n07qd6bb) & x2toa_r7drijimj9;
wire lemfy11;
wire g_fnw5e87x;
wire or2ndyjcknjwc;
wire j0uc6s8xo;
generate
  if(READY_THROUGH == 0) begin: nn0jzid27deu5od5djda5
    assign j0uc6s8xo = lemfy11 & s_2rar7n07qd6bb 
                 & (~g_fnw5e87x)
                 ;
    assign or2ndyjcknjwc = j0uc6s8xo;
  end
  else begin: fw8oj22pv1qzqr51moj2pf
    assign j0uc6s8xo = s_2rar7n07qd6bb 
               & o_vld & o_rdy
               ;
    assign or2ndyjcknjwc = (~g_fnw5e87x) & lemfy11 & s_2rar7n07qd6bb;
  end
endgenerate
wire o4wwn2ehdo4lu = a87b1ashf2guzys8wbbcy;
wire cxzg5m4vn0 = j0uc6s8xo |   o4wwn2ehdo4lu;
wire p4baqg6kj_j_ = j0uc6s8xo | (~o4wwn2ehdo4lu);
sdio_gnrl_cdc_dfflr #(1) i_rdy_gnrl_cdc_dfflr(cxzg5m4vn0, p4baqg6kj_j_, g_fnw5e87x, clk, rst_n); 
assign i_rdy = g_fnw5e87x;
wire wbdg4pwv0;
wire [DW-1:0] wzztwzvh3ij;
generate
    if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_cdc_dffl  #(DW) buf_dat_gnrl_cdc_dest_dffl (or2ndyjcknjwc, i_dat, wzztwzvh3ij, clk, rst_n); 
    end
    else begin: lsj8oc4vo
sdio_gnrl_cdc_dfflr #(DW) buf_dat_gnrl_cdc_dest_dfflr(or2ndyjcknjwc, i_dat, wzztwzvh3ij, clk, rst_n); 
    end
endgenerate
wire s4j0yvyygubd = or2ndyjcknjwc;
wire mh4etuxx02b9sz = o_vld & o_rdy;
wire m93we1usi_xvkh = s4j0yvyygubd | mh4etuxx02b9sz;
wire nki6dumohzqmht = s4j0yvyygubd | (~mh4etuxx02b9sz);
sdio_gnrl_dfflr #(1) uur52sjrmfnjvyf(m93we1usi_xvkh, nki6dumohzqmht, wbdg4pwv0, clk, rst_n);
assign lemfy11 = (~wbdg4pwv0);
assign o_vld = wbdg4pwv0;
assign o_dat = wzztwzvh3ij;
endmodule 
module sdio_gnrl_cdc_ack_channel
# (
  parameter SYNC_DP = 2
) (
  input  req_a, 
  output ack_o, 
  output req_o, 
  input  clk,
  input  rst_n 
);
  sdio_gnrl_cdc_rx # (
     .READY_THROUGH(1),
     .DW      (1),
     .SYNC_DP (SYNC_DP)
   ) brbhiuisx4p28rdfw0n (
  .i_vld_a (req_a), 
  .i_rdy   (ack_o), 
  .i_dat   (1'b0),
  .o_vld   (req_o), 
  .o_rdy   (1'b1), 
  .o_dat   (),
  .clk     (clk),
  .rst_n   (rst_n)
);
endmodule
module sdio_gnrl_fifo_wflg # (
  parameter CUT_READY = 0,
  parameter MSKO = 0,
  parameter PAYLOAD_NORST = 0,
  parameter REGOUT_NORST = 0,
  parameter REG_OUT = 0,
  parameter DP   = 8,
  parameter DP_PTR_W = 4,
  parameter DW   = 32
) (
  input           i_vld, 
  output          i_rdy, 
  input  [DW-1:0] i_dat,
  output          o_vld, 
  input           o_rdy, 
  output [DW-1:0] o_dat,
  output [DP-1:0]   intl_vec, 
  output reg [DP_PTR_W-1:0]   intl_vec_encode,
  input             cleanfifo, 
  input           clk,
  input           rst_n
);
genvar zyod33;
generate 
  if(DP == 0) begin: qmqs20k9uyma
     assign o_vld = i_vld;
     assign i_rdy = o_rdy;
     assign o_dat = i_dat;
  end
  else begin: kfuzu1wzm87
    wire [DW-1:0] jyb_xrvmlkepac [DP-1:0];
    wire [DW-1:0] niyrz4zsknv [DP-1:0];
    wire [DP-1:0] rreodx8nr3a;
    wire xmzf = i_vld & i_rdy | cleanfifo;
    wire u6lh = o_vld & o_rdy | cleanfifo;
    wire [DP-1:0] jgpriggtm2y_fwywc; 
    wire [DP-1:0] ot40c525e9q7lz;
    wire [DP-1:0] ll6f8tv1_r2d1h; 
    wire [DP-1:0] rgpkcprjgc_w9a;
    if(DP == 1) begin:phzw717paedi9
      assign jgpriggtm2y_fwywc = cleanfifo ? 1'b0 : 1'b1; 
    end
    else begin:oq0bb8qqlg1ftq9082tp
      assign jgpriggtm2y_fwywc = cleanfifo        ? {{DP-1{1'b0}}, 1'b1} :
                            ot40c525e9q7lz[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                                               (ot40c525e9q7lz << 1);
   end
    if(DP == 1) begin:szvd_uo_t1rphsu
      assign ll6f8tv1_r2d1h = cleanfifo ? 1'b0 : 1'b1; 
    end
    else begin:tvq5s2c1hmu7vnkviz0nn0
      assign ll6f8tv1_r2d1h = cleanfifo        ? {{DP-1{1'b0}}, 1'b1} :
                            rgpkcprjgc_w9a[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                                               (rgpkcprjgc_w9a << 1);
    end
// spyglass disable_block FlopSRConst
// SMD: master RTL_FDPE) is always set
// SJ:  Here is not a real issue
sdio_gnrl_dfflrs #(1)    ykwyawz_btbqa9homx3  (u6lh, jgpriggtm2y_fwywc[0]     , ot40c525e9q7lz[0]     , clk, rst_n);
sdio_gnrl_dfflrs #(1)    c7pydzj7ovdygd4aj1  (xmzf, ll6f8tv1_r2d1h[0]     , rgpkcprjgc_w9a[0]     , clk, rst_n);
// spyglass enable_block FlopSRConst
    if(DP > 1) begin:clkm1t5c1xs
sdio_gnrl_dfflr  #(DP-1) a9egrdivdf59anpv72p4iu  (u6lh, jgpriggtm2y_fwywc[DP-1:1], ot40c525e9q7lz[DP-1:1], clk, rst_n);
sdio_gnrl_dfflr  #(DP-1) lvg4hw2b7ocga7kwrt  (xmzf, ll6f8tv1_r2d1h[DP-1:1], rgpkcprjgc_w9a[DP-1:1], clk, rst_n);
    end
    wire [DP-1:0] oj7d_c;
    wire [DP-1:0] ygfrhv2;
    wire [DP-1:0] jtq949j67; 
    wire [DP-1:0] j5rme6;
    wire bb7bhv = (u6lh ^ xmzf ) | cleanfifo;
sdio_gnrl_dfflr  #(DP) hn3ax05gtnm     (bb7bhv, jtq949j67, j5rme6,     clk, rst_n);
  wire [DP:0] xtkegwiuyp1327sqdyad = {j5rme6,1'b0};
  assign intl_vec = j5rme6;
  integer x;
  reg [31:0] o7;
  always @ (*) begin
    intl_vec_encode = {DP_PTR_W{1'b0}};
    for(x=1 ; x<=DP ; x=x+1) begin
      if(xtkegwiuyp1327sqdyad[x] == 1'b1) begin
        o7 = $unsigned(x);
        intl_vec_encode = o7[DP_PTR_W-1:0];
        end
      end
    end
    assign oj7d_c = j5rme6;
    assign ygfrhv2 = j5rme6;
    if(DP == 1) begin:foak_f95t2olcq
        assign jtq949j67 = cleanfifo ? 1'b0 : xmzf ? 1'b1 : (j5rme6 >> 1);  
        if(CUT_READY == 1) begin:zx3zppx4bdss_l
          assign i_rdy = (~oj7d_c[DP-1]);
        end
        else begin:bnzuc64my8yotquyxmz
          assign i_rdy = (~oj7d_c[DP-1]) | (u6lh & ~cleanfifo);
        end
    end
    else begin : zyyv__9aqcfn__s
      assign jtq949j67 = cleanfifo ? {DP{1'b0}} : xmzf ? {j5rme6[DP-2:0], 1'b1} : (j5rme6 >> 1);  
      assign i_rdy = (~oj7d_c[DP-1]);
    end
    for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:oe5rsotr0ghvfl
      assign rreodx8nr3a[zyod33] = xmzf & rgpkcprjgc_w9a[zyod33];
    if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_dffl  #(DW) dwpadh5cajhr0s (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
    end
    else begin: lsj8oc4vo
sdio_gnrl_dfflr  #(DW) u6vxeldg1cpy9bd0ai (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
    end
      assign jyb_xrvmlkepac[zyod33] = rreodx8nr3a[zyod33] ? i_dat : niyrz4zsknv[zyod33];
    end
    integer t;
    wire [DW-1:0] j45yhs2ojom0i;
    if(REG_OUT == 0) begin:ryi755vbqjpdrspl
    reg [DW-1:0] rvekbwm94_2g1;
        always @*
        begin : sosqjh1rrq34
          rvekbwm94_2g1 = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            rvekbwm94_2g1 = rvekbwm94_2g1 | ({DW{ot40c525e9q7lz[t]}} & niyrz4zsknv[t]);
          end
        end
    assign j45yhs2ojom0i = rvekbwm94_2g1;
    end
    else begin:hr23f8vxpi5ab_7q5yidy1
        reg [DW-1:0] gifw1k3mdchzul7v;
        always @*
        begin : sosqjh1rrq34
          gifw1k3mdchzul7v = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            gifw1k3mdchzul7v = gifw1k3mdchzul7v | ({DW{jgpriggtm2y_fwywc[t]}} & niyrz4zsknv[t]);
          end
        end
        wire q_eosgs901ch = 
                        o_vld ? u6lh & jtq949j67[0] :
                                xmzf;
        wire [DW-1:0] md1jj1lh30i77nmk = ~ygfrhv2[1] ? i_dat : gifw1k3mdchzul7v;
      if(REGOUT_NORST == 0) begin:ryi755vbqjpdrspl
sdio_gnrl_dfflr #(DW) mbjepxkxu4_ce92d7  (q_eosgs901ch, md1jj1lh30i77nmk, j45yhs2ojom0i, clk, rst_n);
      end
      else begin: q3juj7l_rhjmmqo6je6hohn
sdio_gnrl_dffl  #(DW) m4315jiymjl7bxx   (q_eosgs901ch, md1jj1lh30i77nmk, j45yhs2ojom0i, clk, rst_n);
      end
    end
    if(MSKO == 1) begin:y_u3oxptq26c7xuc
        assign o_dat = {DW{o_vld}} & j45yhs2ojom0i;
    end
    else begin:obqti4sc53op0kcl0qe4
        assign o_dat = j45yhs2ojom0i;
    end
    assign o_vld = (ygfrhv2[0]);
  end
endgenerate
endmodule 
module sdio_gnrl_fifo_wflg_extends # (
  parameter CUT_READY = 0,
  parameter MSKO = 0,
  parameter PAYLOAD_NORST = 0,
  parameter REGOUT_NORST = 0,
  parameter REG_OUT = 0,
  parameter DP   = 8,
  parameter COPY_WIDTH = 10,
  parameter DP_PTR_W = 4,
  parameter DW   = 32
) (
  input           i_vld, 
  output          i_rdy, 
  input  [DW-1:0] i_dat,
  output          o_vld, 
  input           o_rdy, 
  output [DW-1:0] o_dat,
  output [DP-1:0]   intl_vec, 
  output reg [DP_PTR_W-1:0]   intl_vec_encode,
  input             cleanfifo, 
  output [COPY_WIDTH-1:0] copy_vld,
  input           clk,
  input           rst_n
);
genvar zyod33;
generate 
  if(DP == 0) begin: qmqs20k9uyma
     assign o_vld = i_vld;
     assign i_rdy = o_rdy;
     assign o_dat = i_dat;
  end
  else begin: kfuzu1wzm87
    wire [DW-1:0] jyb_xrvmlkepac [DP-1:0];
    wire [DW-1:0] niyrz4zsknv [DP-1:0];
    wire [DP-1:0] rreodx8nr3a;
    wire xmzf = i_vld & i_rdy | cleanfifo;
    wire u6lh = o_vld & o_rdy | cleanfifo;
    wire [DP-1:0] b9mzd4qdyk38db; 
    wire [DP-1:0] jgpriggtm2y_fwywc; 
    wire [DP-1:0] ot40c525e9q7lz;
    wire [DP-1:0] ll6f8tv1_r2d1h; 
    wire [DP-1:0] rgpkcprjgc_w9a;
    if(DP == 1) begin:phzw717paedi9
      assign jgpriggtm2y_fwywc = cleanfifo ? 1'b0 : 1'b1; 
    end
    else begin:oq0bb8qqlg1ftq9082tp
      assign jgpriggtm2y_fwywc = cleanfifo        ? {{DP-1{1'b0}}, 1'b1} :
                            ot40c525e9q7lz[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                                               (ot40c525e9q7lz << 1);
   end
    if(DP == 1) begin:szvd_uo_t1rphsu
      assign ll6f8tv1_r2d1h = cleanfifo ? 1'b0 : 1'b1; 
    end
    else begin:tvq5s2c1hmu7vnkviz0nn0
      assign ll6f8tv1_r2d1h = cleanfifo        ? {{DP-1{1'b0}}, 1'b1} :
                            rgpkcprjgc_w9a[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                                               (rgpkcprjgc_w9a << 1);
    end
sdio_gnrl_dfflrs #(1)    ykwyawz_btbqa9homx3  (u6lh, jgpriggtm2y_fwywc[0]     , ot40c525e9q7lz[0]     , clk, rst_n);
sdio_gnrl_dfflrs #(1)    c7pydzj7ovdygd4aj1  (xmzf, ll6f8tv1_r2d1h[0]     , rgpkcprjgc_w9a[0]     , clk, rst_n);
    if(DP > 1) begin:clkm1t5c1xs
sdio_gnrl_dfflr  #(DP-1) a9egrdivdf59anpv72p4iu  (u6lh, jgpriggtm2y_fwywc[DP-1:1], ot40c525e9q7lz[DP-1:1], clk, rst_n);
sdio_gnrl_dfflr  #(DP-1) lvg4hw2b7ocga7kwrt  (xmzf, ll6f8tv1_r2d1h[DP-1:1], rgpkcprjgc_w9a[DP-1:1], clk, rst_n);
    end
    assign b9mzd4qdyk38db = u6lh ? jgpriggtm2y_fwywc : ot40c525e9q7lz;
    wire [DP-1:0] oj7d_c;
    wire [DP-1:0] ygfrhv2;
    wire [DP-1:0] jtq949j67; 
    wire [DP-1:0] j5rme6;
    wire bb7bhv = (u6lh ^ xmzf ) | cleanfifo;
sdio_gnrl_dfflr  #(DP) hn3ax05gtnm     (bb7bhv, jtq949j67, j5rme6,     clk, rst_n);
    wire [COPY_WIDTH-1:0] smac2fe52v2fxnr;
    assign smac2fe52v2fxnr = {COPY_WIDTH{jtq949j67[0]}};
sdio_gnrl_dfflr  #(COPY_WIDTH) gs7suz03_eq7e2djj     (bb7bhv, smac2fe52v2fxnr, copy_vld,     clk, rst_n);
  wire [DP:0] xtkegwiuyp1327sqdyad = {j5rme6,1'b0};
  assign intl_vec = j5rme6;
  integer x;
  reg [31:0] o7;
  always @ (*) begin
    intl_vec_encode = {DP_PTR_W{1'b0}};
    for(x=1 ; x<=DP ; x=x+1) begin
      if(xtkegwiuyp1327sqdyad[x] == 1'b1) begin
        o7 = $unsigned(x);
        intl_vec_encode = o7[DP_PTR_W-1:0];
        end
      end
    end
    assign oj7d_c = j5rme6;
    assign ygfrhv2 = j5rme6;
    if(DP == 1) begin:foak_f95t2olcq
        assign jtq949j67 = cleanfifo ? 1'b0 : xmzf ? 1'b1 : (j5rme6 >> 1);  
        if(CUT_READY == 1) begin:zx3zppx4bdss_l
          assign i_rdy = (~oj7d_c[DP-1]);
        end
        else begin:bnzuc64my8yotquyxmz
          assign i_rdy = (~oj7d_c[DP-1]) | (u6lh & ~cleanfifo);
        end
    end
    else begin : zyyv__9aqcfn__s
      assign jtq949j67 = cleanfifo ? {DP{1'b0}} : xmzf ? {j5rme6[DP-2:0], 1'b1} : (j5rme6 >> 1);  
     if(CUT_READY == 1) begin:wxxfxrbo1dh9ruso 
      assign i_rdy = (~oj7d_c[DP-1]);
     end
     else begin:ofxh041jnidw14coinnp_
      assign i_rdy = (~oj7d_c[DP-1]) | u6lh;
     end
    end
    for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:oe5rsotr0ghvfl
      assign rreodx8nr3a[zyod33] = xmzf & rgpkcprjgc_w9a[zyod33];
    if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_dffl  #(DW) dwpadh5cajhr0s (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
    end
    else begin: lsj8oc4vo
sdio_gnrl_dfflr  #(DW) u6vxeldg1cpy9bd0ai (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
    end
      assign jyb_xrvmlkepac[zyod33] = rreodx8nr3a[zyod33] ? i_dat : niyrz4zsknv[zyod33];
    end
    integer t;
    wire [DW-1:0] j45yhs2ojom0i;
    if(REG_OUT == 0) begin:ryi755vbqjpdrspl
    reg [DW-1:0] rvekbwm94_2g1;
        always @*
        begin : sosqjh1rrq34
          rvekbwm94_2g1 = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            rvekbwm94_2g1 = rvekbwm94_2g1 | ({DW{ot40c525e9q7lz[t]}} & niyrz4zsknv[t]);
          end
        end
    assign j45yhs2ojom0i = rvekbwm94_2g1;
    end
    else begin:hr23f8vxpi5ab_7q5yidy1
        reg [DW-1:0] md1jj1lh30i77nmk;
        always @*
        begin : sosqjh1rrq34
          md1jj1lh30i77nmk = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            md1jj1lh30i77nmk = md1jj1lh30i77nmk | ({DW{b9mzd4qdyk38db[t]}} & jyb_xrvmlkepac[t]);
          end
        end
        wire q_eosgs901ch = 
                     (~o_vld) ? xmzf :
                     (jtq949j67[0] & u6lh);
sdio_gnrl_dfflr #(DW) mbjepxkxu4_ce92d7  (q_eosgs901ch, md1jj1lh30i77nmk, j45yhs2ojom0i, clk, rst_n);
    end
    if(MSKO == 1) begin:y_u3oxptq26c7xuc
        assign o_dat = {DW{o_vld}} & j45yhs2ojom0i;
    end
    else begin:obqti4sc53op0kcl0qe4
        assign o_dat = j45yhs2ojom0i;
    end
    assign o_vld = (ygfrhv2[0]);
  end
endgenerate
endmodule
module sdio_gnrl_fifo # (
  parameter CUT_READY = 0,
  parameter MSKO = 0,
  parameter PAYLOAD_NORST = 0,
  parameter REGOUT_NORST = 0,
  parameter REG_OUT = 0,
  parameter DP   = 8,
  parameter DW   = 32
) (
  input           i_vld, 
  output          i_rdy, 
  input  [DW-1:0] i_dat,
  output          o_vld, 
  input           o_rdy, 
  output [DW-1:0] o_dat,
  input           clk,
  input           rst_n
);
genvar zyod33;
generate 
  if(DP == 0) begin: qmqs20k9uyma
     assign o_vld = i_vld;
     assign i_rdy = o_rdy;
     assign o_dat = i_dat;
  end
  else begin: kfuzu1wzm87
    wire [DW-1:0] jyb_xrvmlkepac [DP-1:0];
    wire [DW-1:0] niyrz4zsknv [DP-1:0];
    wire [DP-1:0] rreodx8nr3a;
    wire xmzf = i_vld & i_rdy;
    wire u6lh = o_vld & o_rdy;
    wire [DP-1:0] jgpriggtm2y_fwywc; 
    wire [DP-1:0] ot40c525e9q7lz;
    wire [DP-1:0] ll6f8tv1_r2d1h; 
    wire [DP-1:0] rgpkcprjgc_w9a;
    if(DP == 1) begin:phzw717paedi9
      assign jgpriggtm2y_fwywc = 1'b1; 
    end
    else begin:oq0bb8qqlg1ftq9082tp
      assign jgpriggtm2y_fwywc = 
          ot40c525e9q7lz[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                          (ot40c525e9q7lz << 1);
   end
    if(DP == 1) begin:szvd_uo_t1rphsu
      assign ll6f8tv1_r2d1h = 1'b1; 
    end
    else begin:tvq5s2c1hmu7vnkviz0nn0
      assign ll6f8tv1_r2d1h =
          rgpkcprjgc_w9a[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                          (rgpkcprjgc_w9a << 1);
    end
// spyglass disable_block FlopSRConst
// SMD: master RTL_FDPE) is always set
// SJ:  Here is not a real issue
sdio_gnrl_dfflrs #(1)    ykwyawz_btbqa9homx3  (u6lh, jgpriggtm2y_fwywc[0]     , ot40c525e9q7lz[0]     , clk, rst_n);
sdio_gnrl_dfflrs #(1)    c7pydzj7ovdygd4aj1  (xmzf, ll6f8tv1_r2d1h[0]     , rgpkcprjgc_w9a[0]     , clk, rst_n);
// spyglass enable_block FlopSRConst
    if(DP > 1) begin:clkm1t5c1xs
sdio_gnrl_dfflr  #(DP-1) a9egrdivdf59anpv72p4iu  (u6lh, jgpriggtm2y_fwywc[DP-1:1], ot40c525e9q7lz[DP-1:1], clk, rst_n);
sdio_gnrl_dfflr  #(DP-1) lvg4hw2b7ocga7kwrt  (xmzf, ll6f8tv1_r2d1h[DP-1:1], rgpkcprjgc_w9a[DP-1:1], clk, rst_n);
    end
    wire [DP-1:0] oj7d_c;
    wire [DP-1:0] ygfrhv2;
    wire [DP-1:0] jtq949j67; 
    wire [DP-1:0] j5rme6;
    wire bb7bhv = (u6lh ^ xmzf );
sdio_gnrl_dfflr  #(DP) hn3ax05gtnm     (bb7bhv, jtq949j67, j5rme6,     clk, rst_n);
    assign oj7d_c = j5rme6;
    assign ygfrhv2 = j5rme6;
    if(DP == 1) begin:foak_f95t2olcq
        assign jtq949j67 = xmzf ? 1'b1 : (j5rme6 >> 1);  
        if(CUT_READY == 1) begin:zx3zppx4bdss_l
          assign i_rdy = (~oj7d_c[DP-1]);
        end
        else begin:bnzuc64my8yotquyxmz
          assign i_rdy = (~oj7d_c[DP-1]) | u6lh;
        end
    end
    else begin : zyyv__9aqcfn__s
      assign jtq949j67 = xmzf ? {j5rme6[DP-2:0], 1'b1} : (j5rme6 >> 1);  
      assign i_rdy = (~oj7d_c[DP-1]);
    end
    for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:oe5rsotr0ghvfl
      assign rreodx8nr3a[zyod33] = xmzf & rgpkcprjgc_w9a[zyod33];
    if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_dffl  #(DW) dwpadh5cajhr0s (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
    end
    else begin: lsj8oc4vo
sdio_gnrl_dfflr  #(DW) u6vxeldg1cpy9bd0ai (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
    end
      assign jyb_xrvmlkepac[zyod33] = rreodx8nr3a[zyod33] ? i_dat : niyrz4zsknv[zyod33];
    end
    integer t;
    wire [DW-1:0] j45yhs2ojom0i;
    if(REG_OUT == 0) begin:ryi755vbqjpdrspl
    reg [DW-1:0] rvekbwm94_2g1;
        always @*
        begin : sosqjh1rrq34
          rvekbwm94_2g1 = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            rvekbwm94_2g1 = rvekbwm94_2g1 | ({DW{ot40c525e9q7lz[t]}} & niyrz4zsknv[t]);
          end
        end
    assign j45yhs2ojom0i = rvekbwm94_2g1;
    end
    else begin:hr23f8vxpi5ab_7q5yidy1
        reg [DW-1:0] gifw1k3mdchzul7v;
        always @*
        begin : sosqjh1rrq34
          gifw1k3mdchzul7v = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            gifw1k3mdchzul7v = gifw1k3mdchzul7v | ({DW{jgpriggtm2y_fwywc[t]}} & niyrz4zsknv[t]);
          end
        end
        wire q_eosgs901ch = 
                        o_vld ? u6lh & jtq949j67[0] :
                                xmzf;
        wire [DW-1:0] md1jj1lh30i77nmk = ~ygfrhv2[1] ? i_dat : gifw1k3mdchzul7v;
      if(REGOUT_NORST == 0) begin:ryi755vbqjpdrspl
sdio_gnrl_dfflr #(DW) mbjepxkxu4_ce92d7  (q_eosgs901ch, md1jj1lh30i77nmk, j45yhs2ojom0i, clk, rst_n);
      end
      else begin: q3juj7l_rhjmmqo6je6hohn
sdio_gnrl_dffl  #(DW) m4315jiymjl7bxx   (q_eosgs901ch, md1jj1lh30i77nmk, j45yhs2ojom0i, clk, rst_n);
      end
    end
    if(MSKO == 1) begin:y_u3oxptq26c7xuc
        assign o_dat = {DW{o_vld}} & j45yhs2ojom0i;
    end
    else begin:obqti4sc53op0kcl0qe4
        assign o_dat = j45yhs2ojom0i;
    end
    assign o_vld = (ygfrhv2[0]);
  end
endgenerate
endmodule 
module sdio_gnrl_fifo_extends # (
  parameter CUT_READY = 0,
  parameter MSKO = 0,
  parameter PAYLOAD_NORST = 0,
  parameter REGOUT_NORST = 0,
  parameter REG_OUT = 0,
  parameter DP   = 8,
  parameter DW   = 32
) (
  input           i_vld, 
  output          i_rdy, 
  input  [DW-1:0] i_dat,
  output          o_vld, 
  input           o_rdy, 
  output [DW-1:0] o_dat,
  input           clk,
  input           rst_n
);
genvar zyod33;
generate 
  if(DP == 0) begin: qmqs20k9uyma
     assign o_vld = i_vld;
     assign i_rdy = o_rdy;
     assign o_dat = i_dat;
  end
  else begin: kfuzu1wzm87
    wire [DW-1:0] jyb_xrvmlkepac [DP-1:0];
    wire [DW-1:0] niyrz4zsknv [DP-1:0];
    wire [DP-1:0] rreodx8nr3a;
    wire xmzf = i_vld & i_rdy;
    wire u6lh = o_vld & o_rdy;
    wire [DP-1:0] b9mzd4qdyk38db; 
    wire [DP-1:0] jgpriggtm2y_fwywc; 
    wire [DP-1:0] ot40c525e9q7lz;
    wire [DP-1:0] ll6f8tv1_r2d1h; 
    wire [DP-1:0] rgpkcprjgc_w9a;
    if(DP == 1) begin:phzw717paedi9
      assign jgpriggtm2y_fwywc = 1'b1; 
    end
    else begin:oq0bb8qqlg1ftq9082tp
      assign jgpriggtm2y_fwywc = 
          ot40c525e9q7lz[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                          (ot40c525e9q7lz << 1);
   end
    if(DP == 1) begin:szvd_uo_t1rphsu
      assign ll6f8tv1_r2d1h = 1'b1; 
    end
    else begin:tvq5s2c1hmu7vnkviz0nn0
      assign ll6f8tv1_r2d1h =
          rgpkcprjgc_w9a[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                          (rgpkcprjgc_w9a << 1);
    end
sdio_gnrl_dfflrs #(1)    ykwyawz_btbqa9homx3  (u6lh, jgpriggtm2y_fwywc[0]     , ot40c525e9q7lz[0]     , clk, rst_n);
sdio_gnrl_dfflrs #(1)    c7pydzj7ovdygd4aj1  (xmzf, ll6f8tv1_r2d1h[0]     , rgpkcprjgc_w9a[0]     , clk, rst_n);
    if(DP > 1) begin:clkm1t5c1xs
sdio_gnrl_dfflr  #(DP-1) a9egrdivdf59anpv72p4iu  (u6lh, jgpriggtm2y_fwywc[DP-1:1], ot40c525e9q7lz[DP-1:1], clk, rst_n);
sdio_gnrl_dfflr  #(DP-1) lvg4hw2b7ocga7kwrt  (xmzf, ll6f8tv1_r2d1h[DP-1:1], rgpkcprjgc_w9a[DP-1:1], clk, rst_n);
    end
    assign b9mzd4qdyk38db = u6lh ? jgpriggtm2y_fwywc : ot40c525e9q7lz;
    wire [DP-1:0] oj7d_c;
    wire [DP-1:0] ygfrhv2;
    wire [DP-1:0] jtq949j67; 
    wire [DP-1:0] j5rme6;
    wire bb7bhv = (u6lh ^ xmzf );
sdio_gnrl_dfflr  #(DP) hn3ax05gtnm     (bb7bhv, jtq949j67, j5rme6,     clk, rst_n);
    assign oj7d_c = j5rme6;
    assign ygfrhv2 = j5rme6;
    if(DP == 1) begin:foak_f95t2olcq
        assign jtq949j67 = xmzf ? 1'b1 : (j5rme6 >> 1);  
        if(CUT_READY == 1) begin:zx3zppx4bdss_l
          assign i_rdy = (~oj7d_c[DP-1]);
        end
        else begin:bnzuc64my8yotquyxmz
          assign i_rdy = (~oj7d_c[DP-1]) | u6lh;
        end
    end
    else begin : zyyv__9aqcfn__s
      assign jtq949j67 = xmzf ? {j5rme6[DP-2:0], 1'b1} : (j5rme6 >> 1);  
     if(CUT_READY == 1) begin:wxxfxrbo1dh9ruso 
      assign i_rdy = (~oj7d_c[DP-1]);
     end
     else begin:ofxh041jnidw14coinnp_
      assign i_rdy = (~oj7d_c[DP-1]) | u6lh;
     end
    end
    for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:oe5rsotr0ghvfl
      assign rreodx8nr3a[zyod33] = xmzf & rgpkcprjgc_w9a[zyod33];
    if(PAYLOAD_NORST == 1) begin:yi2keguojod3
sdio_gnrl_dffl  #(DW) dwpadh5cajhr0s (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
    end
    else begin: lsj8oc4vo
sdio_gnrl_dfflr  #(DW) u6vxeldg1cpy9bd0ai (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
    end
      assign jyb_xrvmlkepac[zyod33] = rreodx8nr3a[zyod33] ? i_dat : niyrz4zsknv[zyod33];
    end
    integer t;
    wire [DW-1:0] j45yhs2ojom0i;
    if(REG_OUT == 0) begin:ryi755vbqjpdrspl
    reg [DW-1:0] rvekbwm94_2g1;
        always @*
        begin : sosqjh1rrq34
          rvekbwm94_2g1 = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            rvekbwm94_2g1 = rvekbwm94_2g1 | ({DW{ot40c525e9q7lz[t]}} & niyrz4zsknv[t]);
          end
        end
    assign j45yhs2ojom0i = rvekbwm94_2g1;
    end
    else begin:hr23f8vxpi5ab_7q5yidy1
        reg [DW-1:0] md1jj1lh30i77nmk;
        always @*
        begin : sosqjh1rrq34
          md1jj1lh30i77nmk = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            md1jj1lh30i77nmk = md1jj1lh30i77nmk | ({DW{b9mzd4qdyk38db[t]}} & jyb_xrvmlkepac[t]);
          end
        end
        wire q_eosgs901ch = 
                     (~o_vld) ? xmzf :
                     (jtq949j67[0] & u6lh);
sdio_gnrl_dfflr #(DW) mbjepxkxu4_ce92d7  (q_eosgs901ch, md1jj1lh30i77nmk, j45yhs2ojom0i, clk, rst_n);
    end
    if(MSKO == 1) begin:y_u3oxptq26c7xuc
        assign o_dat = {DW{o_vld}} & j45yhs2ojom0i;
    end
    else begin:obqti4sc53op0kcl0qe4
        assign o_dat = j45yhs2ojom0i;
    end
    assign o_vld = (ygfrhv2[0]);
  end
endgenerate
endmodule 
module httpcamh0tmfjgmvhu9tq
(
 input  wire                ntfvn09s31u9_t3w,
 input  wire                c4wmn9x0tiqe,
 input  wire                lh16w9beizuu5b2,
 input  wire                b9qjj1p33jh20xd,
 output wire                y86bin6hqgld38moihaz9l9hm46,
 input  wire                galaluy047z,
 input  wire                iztasdnqoh654gu,
 input  wire                juh54k4vkvfwojkpq6,
 input  wire  [3:0]         v6t89tsx_60scl7w7vb8u9ucoyfb,
 output wire                ljvcn952hmgl22p_3cu5,
 input  wire                lczv3cn,
 input  wire                r38027_km3,
 input  wire  [31:0]        o6fjghx2bmnlz,
 input  wire  [31:0]        vg8peads9erjbnw4w7,
 input  wire                fl4y0hv,
 input  wire                wiyfxtmib7,
 input  wire                yuoy0hg,
 input  wire                nhmow92ziyrfc2,
 output wire                drqkxqyd0a5rd,
 output wire                cp8ikq5kpelal,
 output wire                mjhapl283osr4on,
 output wire                wpbckwjv7lsmlw105ai2,
 output wire                hj1zd5izbnc61kc,
 output wire                ljrz9lmuuytll,
 output wire                sz8f8tb7qt0y4s5tf,
 output wire                o5ael5lxk3ws3,
 output wire                ic_vhizwroluvm613bzbv47,
 output wire                ntge8ydizi5phdjgr7hs2jc,
 output wire                sklzb7wzqf229gf,
 output wire                rnj4r1so54nq3sc
 );
 wire [31:0] rgllvhoe5tui3;
 assign mjhapl283osr4on = (~rgllvhoe5tui3[0]) ;
 assign wpbckwjv7lsmlw105ai2 = (rgllvhoe5tui3 == 32'h0);
 wire z_1m_y4u ; 
sdio_hand_mux r6wdjgfzxrvirc8v1z4juq43e (.X(z_1m_y4u), 
        .S(nhmow92ziyrfc2), 
        .D0(~lczv3cn), 
        .D1(lczv3cn)
        );
    wire lqpre3cjc3bi91;
    wire e_pba150aqcfm;
    wire zyrs6qblz2y0ui0cotqnf;
    wire [31:0] aa8w5awlac;
    wire f53rj24bu43yl6sp = (aa8w5awlac != 32'h0) | lqpre3cjc3bi91 & yuoy0hg;
    wire k9861ty6m92i = fl4y0hv | f53rj24bu43yl6sp;
    wire kkkrlr5f97suqj_q = (aa8w5awlac == rgllvhoe5tui3) ;
    wire c_05rvhys6eg18o = (aa8w5awlac == (rgllvhoe5tui3>>1)) ;
    wire c5u7hoqxobqj = (k9861ty6m92i | kkkrlr5f97suqj_q) & (iztasdnqoh654gu ? fl4y0hv : 1'b1);
    wire [31:0] q81u3aed75szry2_ = kkkrlr5f97suqj_q ? 32'h0
    : k9861ty6m92i ? aa8w5awlac + 32'h1
    : 32'h0 
    ;
sdio_gnrl_dfflr #(32) fejwxnu28gshs517 (c5u7hoqxobqj, q81u3aed75szry2_, aa8w5awlac, lczv3cn, r38027_km3);
    wire [31:0] bs7__2j8c6b978bbx9; 
sdio_gnrl_dfflr #(32) szeulu1cj2n_odxao1 (zyrs6qblz2y0ui0cotqnf, vg8peads9erjbnw4w7, bs7__2j8c6b978bbx9, lczv3cn, r38027_km3);
    wire j5nseci3mllzctml7_jh87 = ~(|bs7__2j8c6b978bbx9);
sdio_gnrl_dfflr #(32) h3hkhdn25zm93fj3c (kkkrlr5f97suqj_q, o6fjghx2bmnlz, rgllvhoe5tui3, lczv3cn, r38027_km3);
    wire wpurpd0wefq_ = kkkrlr5f97suqj_q & e_pba150aqcfm;
sdio_gnrl_dfflrs #(1) ja9worullccn8w1mloja (wpurpd0wefq_, galaluy047z, lqpre3cjc3bi91, lczv3cn, r38027_km3);
    assign cp8ikq5kpelal = ljrz9lmuuytll ;
    wire [3:0] wscxe6hax9xzfnrf;
    wire  x9_vyufeiqyyqjhu1v = hj1zd5izbnc61kc & juh54k4vkvfwojkpq6 | (~juh54k4vkvfwojkpq6);
    wire [3:0] ctiniz2yulhta5bw5t1n8 = y86bin6hqgld38moihaz9l9hm46 | (~juh54k4vkvfwojkpq6) ? 4'b0
                                 : wscxe6hax9xzfnrf + 4'b1
                                 ;
sdio_gnrl_dfflr #(4) v88u8gpn_8bcr_vl_okqz63fd (x9_vyufeiqyyqjhu1v, ctiniz2yulhta5bw5t1n8, wscxe6hax9xzfnrf, lczv3cn, r38027_km3);
    assign y86bin6hqgld38moihaz9l9hm46 = (wscxe6hax9xzfnrf == v6t89tsx_60scl7w7vb8u9ucoyfb) & hj1zd5izbnc61kc;
    wire qdrqm23x5oudq84q =  lh16w9beizuu5b2 & b9qjj1p33jh20xd;
    wire s79op61lzkn4 = fl4y0hv ? (~e_pba150aqcfm) 
                      : qdrqm23x5oudq84q  ? 1'b1
                      : 1'b0;
    wire jyl0btcz237rir = ( lqpre3cjc3bi91 ? (fl4y0hv & kkkrlr5f97suqj_q & (~(sklzb7wzqf229gf & (~e_pba150aqcfm))) | ((~fl4y0hv) & kkkrlr5f97suqj_q & sklzb7wzqf229gf & e_pba150aqcfm))
    : kkkrlr5f97suqj_q & fl4y0hv) 
    | qdrqm23x5oudq84q
    | c4wmn9x0tiqe 
    ;
sdio_gnrl_dfflr #(1) g601sh8og9g69eq00gvhj (jyl0btcz237rir, s79op61lzkn4, e_pba150aqcfm, lczv3cn, r38027_km3);
    wire ntts6hstyt;
    wire ojsis1civ4qag9 = yuoy0hg;
    wire l0fc_ag9_5_y9m = kkkrlr5f97suqj_q;
    wire qc44z3xv1wftgeyp = (~l0fc_ag9_5_y9m);
    wire pydi304mnq7hnt = ojsis1civ4qag9 | l0fc_ag9_5_y9m;
sdio_gnrl_dfflr #(1) fvl42f10lu_0qmy56g5 (pydi304mnq7hnt, qc44z3xv1wftgeyp, ntts6hstyt, lczv3cn, r38027_km3);
    assign sklzb7wzqf229gf = lqpre3cjc3bi91 ? (ntts6hstyt | yuoy0hg) & kkkrlr5f97suqj_q  : yuoy0hg; 
    assign ljvcn952hmgl22p_3cu5 = lqpre3cjc3bi91;
    assign drqkxqyd0a5rd = e_pba150aqcfm ; 
    wire q2ysvcnisqfps = fl4y0hv & kkkrlr5f97suqj_q;
    wire c_6rqih0z6l = q2ysvcnisqfps & (~e_pba150aqcfm);
    wire r99f5ra8kwl = q2ysvcnisqfps & e_pba150aqcfm;
    wire jals6lfbl1n  = (sz8f8tb7qt0y4s5tf & (~bs7__2j8c6b978bbx9[0]));
    wire ngd26cjvlu5hjx4 = (sz8f8tb7qt0y4s5tf & bs7__2j8c6b978bbx9[0]);
    wire [31:0] kdk2fjw7j9llfq;
    wire tskm0joi8l4cpzz3z = (kdk2fjw7j9llfq != 32'h0) ;
    wire vtt1lavjmc3nr5ful8n = (kdk2fjw7j9llfq == bs7__2j8c6b978bbx9);
    wire y0t8w_idntfrjqizr = (~vtt1lavjmc3nr5ful8n) & tskm0joi8l4cpzz3z;
    wire xik7d6ivx2thajncq1 = jals6lfbl1n | y0t8w_idntfrjqizr;
    wire p0kfowsx4keat7 = vtt1lavjmc3nr5ful8n & (~j5nseci3mllzctml7_jh87) & tskm0joi8l4cpzz3z | j5nseci3mllzctml7_jh87 ;
    wire yufu555p9kbm7bnivs = (xik7d6ivx2thajncq1 | p0kfowsx4keat7 ) & wiyfxtmib7 & fl4y0hv;
  wire [31:0] ujz3kszr353uydis = p0kfowsx4keat7 ? 32'h0
                             : xik7d6ivx2thajncq1 ? kdk2fjw7j9llfq + 32'h2
                             : 32'h0 
                             ;
sdio_gnrl_dfflr #(32) pbs90smhwuico2q9qgl (yufu555p9kbm7bnivs, ujz3kszr353uydis, kdk2fjw7j9llfq, lczv3cn, r38027_km3);
  wire [31:0] et6hs4gqdooh12;
  wire hn34w1heg2tlw2gnxc = (et6hs4gqdooh12 == bs7__2j8c6b978bbx9);
  wire oxf8_lpkkcoq0xyy793 = (et6hs4gqdooh12 != 32'h0) ;
  wire qkvhmv_wb9elr7kku86 = (~hn34w1heg2tlw2gnxc) & oxf8_lpkkcoq0xyy793;
  wire liqt1pfih0bmx83u_ = (et6hs4gqdooh12 == 32'h0);
  wire ugo0bu2gmr73zxi6po6 = ngd26cjvlu5hjx4 | qkvhmv_wb9elr7kku86;
  wire bvtske7t6f1e_bh = hn34w1heg2tlw2gnxc & oxf8_lpkkcoq0xyy793 ;
  wire nx9dcxvnbx9ly6k = (ugo0bu2gmr73zxi6po6 | bvtske7t6f1e_bh) & wiyfxtmib7 & fl4y0hv;
  wire [31:0] mpfnn6mnv6vxvpfy4 = bvtske7t6f1e_bh ? 32'h0
                             : et6hs4gqdooh12 + (liqt1pfih0bmx83u_ ? 32'h1 : 32'h2 )
                             ;
sdio_gnrl_dfflr #(32) ygluq8420qxjyttsmp (nx9dcxvnbx9ly6k, mpfnn6mnv6vxvpfy4, et6hs4gqdooh12, z_1m_y4u, r38027_km3);
  wire [31:0] iuca3d0ohbit5j;
  wire pr32vkwiv5sucj9j = (iuca3d0ohbit5j != 32'h0);
  wire aqswptefpwzkumk = (iuca3d0ohbit5j == bs7__2j8c6b978bbx9);
  wire myaojjlkd_un51r8zf5 = (~aqswptefpwzkumk) & pr32vkwiv5sucj9j;
  wire gpavjvxgqz0nay0vpk = (jals6lfbl1n & (y0t8w_idntfrjqizr | p0kfowsx4keat7)) | myaojjlkd_un51r8zf5;
  wire fqlrfxvoxdhw021lu = aqswptefpwzkumk & (~j5nseci3mllzctml7_jh87) & pr32vkwiv5sucj9j | j5nseci3mllzctml7_jh87 ;
  wire qlr97ifywod55yz3il = (gpavjvxgqz0nay0vpk | fqlrfxvoxdhw021lu )  & wiyfxtmib7 & fl4y0hv;
  wire [31:0] r0qzxw8u5x4u3rl1zt = fqlrfxvoxdhw021lu ? 32'h0
                             : gpavjvxgqz0nay0vpk ? iuca3d0ohbit5j + 32'h2
                             : 32'h0 
                             ;
sdio_gnrl_dfflr #(32) y__kl3t9ubfxo6evq7y (qlr97ifywod55yz3il, r0qzxw8u5x4u3rl1zt, iuca3d0ohbit5j, lczv3cn, r38027_km3);
  wire [31:0] mn2tzr_7uiofjzya;
  wire ur8mv7zno5om5mn = (mn2tzr_7uiofjzya != 32'h0) ;
  wire el5p_h1xeopd3iqutpb = (mn2tzr_7uiofjzya == bs7__2j8c6b978bbx9);
  wire gsyopm0v9k9to98 = (~el5p_h1xeopd3iqutpb) & ur8mv7zno5om5mn;
  wire kimt85k9o5_r8lem = (mn2tzr_7uiofjzya == 32'h0);
  wire fyyyk4nqi874xl7j = (ngd26cjvlu5hjx4 & (qkvhmv_wb9elr7kku86 | bvtske7t6f1e_bh)) | gsyopm0v9k9to98;
  wire vb5fck5lt1w9x1pwc7r = el5p_h1xeopd3iqutpb & ur8mv7zno5om5mn ;
  wire v7ef7ighmh_sqzf3j = (fyyyk4nqi874xl7j | vb5fck5lt1w9x1pwc7r) & wiyfxtmib7 & fl4y0hv;
  wire [31:0] d4rnw599pjf_xv = vb5fck5lt1w9x1pwc7r ? 32'h0
                             : (mn2tzr_7uiofjzya + (kimt85k9o5_r8lem ? 32'h1 : 32'h2))
                             ;
sdio_gnrl_dfflr #(32) dqgv19e2xuv_e9pd4w (v7ef7ighmh_sqzf3j, d4rnw599pjf_xv, mn2tzr_7uiofjzya, z_1m_y4u, r38027_km3);
  assign zyrs6qblz2y0ui0cotqnf = (~tskm0joi8l4cpzz3z) & (~oxf8_lpkkcoq0xyy793) & (~pr32vkwiv5sucj9j)  & (~ur8mv7zno5om5mn);
   wire uz_p4g3kqayfcfdm8iwmljw2r_1 = (p0kfowsx4keat7 
                            | fqlrfxvoxdhw021lu 
                            ) & (~j5nseci3mllzctml7_jh87)
                            | (j5nseci3mllzctml7_jh87 & ic_vhizwroluvm613bzbv47) 
                            ;
   wire r7zyh60kkjls63665l_fwv4bcllsvl = ( 
                             bvtske7t6f1e_bh 
                            | vb5fck5lt1w9x1pwc7r
                            ) & (~j5nseci3mllzctml7_jh87)
                            ;
  wire  ce3cq57etwgrnfxrkfcy34hisqlu;
sdio_gnrl_dffr #(1) kh8l97h5c7k0joyivsk1jg ( uz_p4g3kqayfcfdm8iwmljw2r_1, ce3cq57etwgrnfxrkfcy34hisqlu, lczv3cn, r38027_km3);
  wire  mm_kb1r4s2b16h5zvuucsh2hn;
sdio_gnrl_dffr #(1) e9twwieg_xr58leraqqvvgn ( r7zyh60kkjls63665l_fwv4bcllsvl, mm_kb1r4s2b16h5zvuucsh2hn, z_1m_y4u, r38027_km3);
  assign hj1zd5izbnc61kc = c_6rqih0z6l; 
  assign ljrz9lmuuytll = r99f5ra8kwl; 
  assign sz8f8tb7qt0y4s5tf = c_6rqih0z6l | r99f5ra8kwl;
  assign o5ael5lxk3ws3 = sz8f8tb7qt0y4s5tf; 
  assign ic_vhizwroluvm613bzbv47 = c_05rvhys6eg18o & fl4y0hv;
  assign ntge8ydizi5phdjgr7hs2jc = wpbckwjv7lsmlw105ai2 ? fl4y0hv : ce3cq57etwgrnfxrkfcy34hisqlu | mm_kb1r4s2b16h5zvuucsh2hn;
  assign rnj4r1so54nq3sc = e_pba150aqcfm; 
endmodule
module v6xjcd_5032y54f
(
    input                lczv3cn,
    input                r38027_km3,
    output        [15:0] r3vi2c1fh,
    output               f3evaxx8f9dr86i701a,
    input                px3xebad9kl,
    input                ygli0hkz,
    input                fv1t4udtvxdm,
    input                ho56_v0li6,
    input                t0g2vtmb
  );
   wire [15:0] pg343;
   wire [15:0] yvsbjhg ;
   wire yj5ydhi_ = t0g2vtmb | fv1t4udtvxdm;
   wire rh6dndzd2jnn = ho56_v0li6;
   wire ib1nqvaf_13 = (yj5ydhi_ | rh6dndzd2jnn) & px3xebad9kl;
   assign yvsbjhg[0]     = ygli0hkz ^ pg343[15];
   assign yvsbjhg[4:1]   = pg343[3:0]; 
   assign yvsbjhg[5]     = pg343[4] ^ yvsbjhg[0];
   assign yvsbjhg[11:6]  = pg343[10:5]; 
   assign yvsbjhg[12]    = pg343[11] ^ yvsbjhg[0];
   assign yvsbjhg[15:13] = pg343[14:12]; 
   wire [15:0] mp3407fiylvj = ho56_v0li6    ? 16'h0
                       : t0g2vtmb ? yvsbjhg
                       : fv1t4udtvxdm  ? {pg343[14:0],1'b0}
                       : pg343
                       ;
sdio_gnrl_dfflr #(16) jxyex5n12w092wwunqe (ib1nqvaf_13, mp3407fiylvj, pg343, lczv3cn, r38027_km3);
   assign r3vi2c1fh = pg343;
   assign f3evaxx8f9dr86i701a = pg343[15];
endmodule
module hetqpjqj7c6fx221im
(
    input         lczv3cn,
    input         r38027_km3,
    output  [6:0] hh8dah7,
    output        s_f72w0s8hak9_im,
    input         px3xebad9kl,
    input         ygli0hkz,
    input         fv1t4udtvxdm,
    input         ho56_v0li6,
    input         t0g2vtmb
  );
   wire [6:0] pg343;
   wire [6:0] yvsbjhg ;
   wire yj5ydhi_ = t0g2vtmb | fv1t4udtvxdm;
   wire rh6dndzd2jnn = ho56_v0li6;
   wire ib1nqvaf_13 = (yj5ydhi_ | rh6dndzd2jnn) & px3xebad9kl;
   assign yvsbjhg[0]     = ygli0hkz ^ pg343[6];
   assign yvsbjhg[2:1]   = pg343[1:0]; 
   assign yvsbjhg[3]     = pg343[2] ^ yvsbjhg[0];
   assign yvsbjhg[6:4]   = pg343[5:3]; 
   wire [6:0] mp3407fiylvj =  ho56_v0li6    ? 7'h0
                       : t0g2vtmb ? yvsbjhg
                       : fv1t4udtvxdm  ? {pg343[5:0],1'b0}
                       : pg343
                       ;
sdio_gnrl_dfflr #(7) jxyex5n12w092wwunqe (ib1nqvaf_13, mp3407fiylvj, pg343, lczv3cn, r38027_km3);
   assign hh8dah7 = pg343;
   assign s_f72w0s8hak9_im = pg343[6];
endmodule
module fpw5umxwbnhzklg7gch5
#(
    parameter ra2aj3fukykd9j = 32,
    parameter fmv57175hz8809 = 8,
    parameter xi5np3lftgtezged = 3
)
(
    input                      lczv3cn,
    input                      r38027_km3,
    input                      ho56_v0li6,
    input                      ylweqzg4l2,
    output                     jm5sdmj,
    input                      lyg_g62ta,
    output  [ra2aj3fukykd9j-1 : 0] aqikf5g,
    output                     al_bfsrdm,
    input                      cadqltzy,
    output [xi5np3lftgtezged:0]jov1vyjapbtr,
    input                      pxdlrpyubv4n,
    input   [ra2aj3fukykd9j-1 : 0] ygli0hkz,
    output                     euwxj8gh
);
    wire [xi5np3lftgtezged:0]      nw14yqx3xxb;    
    reg [xi5np3lftgtezged:0]      d6trhxhl6wsh; 
    wire                           i6v52owi3i7mr;   
    sdio_gnrl_fifo_wflg #(
       .CUT_READY (1),
       .MSKO      (0),
       .REG_OUT   (1),
       .DP        (fmv57175hz8809),
       .DW        (ra2aj3fukykd9j),
       .DP_PTR_W  (xi5np3lftgtezged+1)
    ) vc21qvjkfaa (
      .clk             (lczv3cn),
      .rst_n           (r38027_km3),
      .cleanfifo       (ho56_v0li6 ),
      .i_vld           (pxdlrpyubv4n),
      .i_rdy           (euwxj8gh),
      .i_dat           (ygli0hkz),
      .o_vld           (al_bfsrdm),
      .o_rdy           (cadqltzy),
      .o_dat           (aqikf5g),
      .intl_vec        (),
      .intl_vec_encode (jov1vyjapbtr)
    );
    assign nw14yqx3xxb = fmv57175hz8809[xi5np3lftgtezged:0] - jov1vyjapbtr;
    assign i6v52owi3i7mr = (nw14yqx3xxb == d6trhxhl6wsh);
    assign jm5sdmj = euwxj8gh & ~i6v52owi3i7mr;
    always @(posedge lczv3cn, negedge r38027_km3)
    begin: y3mmifiutmiji6nvau6
        if (r38027_km3 == 1'b0)
            d6trhxhl6wsh <= {xi5np3lftgtezged+1{1'b0}};
        else
        begin
            if(jm5sdmj && lyg_g62ta & ylweqzg4l2)
            begin
                if (~pxdlrpyubv4n || ~euwxj8gh)
                    d6trhxhl6wsh <= d6trhxhl6wsh + {{xi5np3lftgtezged{1'b0}},1'b1};
            end
            else if (pxdlrpyubv4n && euwxj8gh & ylweqzg4l2)
                d6trhxhl6wsh <= d6trhxhl6wsh - {{xi5np3lftgtezged{1'b0}},1'b1};
        end
    end
endmodule
module c8jhxlzu53pvqb0s (
    input                         mxwg8lfgv4pge1 ,
    output                        qi_euczbjhgo1za ,
    input                         cuu3goyrnwc9hf  ,
    input  [12-1:0]         t3lk20ui52aqc6  ,
    input  [32-1:0]         rs8qfdkpko8pq ,
    output                        l_geblczxuwi5x4e ,
    input                         ptdklfwbs2d13 ,
    output [32-1:0]         nuvz1doibyin1uaa ,
    output                        et608shl82a38k37n_tc,
    output                        qp0wn9ujlwcuhkd9yza,
    output  [31:0]                ttye50jd2n0mdj429lscfjl,
    output  [31:0]                k7o146duw1l_7lhmiut_lcw,
    output  [31:0]                g5ikzrx34od9pu8jyexvv,
    output  [31:0]                ileysv9olfjwrm_t236qmf0,
    output                        agra657i0o0nz9,
    input   [15:0]                ax9vv3ea604fyn521,
    input                         yyorn42v7r0yxtj,
    input                         aehb61u1do,
    input                         a6azftdcm48ofiwjze7i7rh,
    input                         btxjg7ygg8tk_7on,
    input                         y1bj5jcmhudj7gqo,
    output   [5:0]                b26mynubin8b_le,
    output   [31:0]               pnqfvawpm88z_eyd,
    output   [7:0]                kwy_caex2pniarrt90nhz,
    output   [5:0]                o9c9btcp91rsvpk0vspg,
    output   [31:0]               ckit4a72az0719r4043o,
    output   [5:0]                eceqrr444i1sfi27buo2zh9kd,
    input   [127:0]               l199zjdlz5zp4wxl3g,
    input   [127:0]               rpx40ivicuzwht_yj9s,
    output                        pj8yn_v__lbubab,
    output                        s9ca2h_c0vo3ir21,
    output   [1:0]                m6zj5v0w5_3ihev8i,
    output   [11:0]               ex_g7yz76ioj6b3ga7izf99,
    output   [15:0]               wjpeqvmhl4olz7lwfq7ml,
    input [31:0]                  cnppfcsxxqf4urcv  ,
    input                         tas51wt1y2anvic5x ,
    output                        spk75u9zmwe9atpcj ,
    output [31:0]                 p4j35gwurjv5  ,
    output                        ze1nmdpmvow7c319 ,
    input                         fo4edb6fq0rlivyj ,
    input                         cb88v39q9jwt3pvnrr,
    input                         qn6b671v_v_entk63c2t,
    input [6:0] rennjjy_nc,
    input [6:0] je8cka,
    output                        x7kd6gw9z3nq,
    output                        h5fyr6xf,
    output                        iydyd8j,
    output                        d_ud4rxc,
    output                        guy4snzyohyiz,
    output                        coewl0jbxtbda4v,
    output                        q9v4i7v_w83ghvywxf,
    output                        d7pq3_iwww34lz9qrvnrj_sl90cb,
    output                        heo8n9249c37,
    output                        g_4093g7113,
    output                        rtjb59lqioc,
    output  [15:0]                i5obq0coq3_dxi8wgp5w,
    output  [15:0]                b8qdnc0532plw6lmf_7s3,
    output  [15:0]                h2y116axdf7diunbyy,
    output                        goutmvirnojskgvv6amvi,
    output                        spzm6_w92pynok5p4ar,
    output                        c_2t5bufod3tjs,
    output                        gsunngjkz0hnaqx2o644yb89hd,
    output                        y95x5hdagddvs0pyu8wndgmosp,
    output                        sij8tpctkajmr03fg7gpam,
    output                        ha5dwnleavf9avv,
    output                        dus0b998jzvic,
    output                        agzf9f66rtwmzvpra,
    output                        rox3z1ajkb2vlfdt,
    output                        nbdjwtss8giqeaiucom,
    output  [3:0]                 d538tqnpwv5nxljp33ioggy53kljin,
    input                         usa73t6hje0c , 
    input                         bt949sros6 , 
    input                         i8z0n9wj94uk6 , 
    input                         cd4cglo9i , 
    input                         eenfsp7uc ,
    input                         cou6jkjrtkyb,
    input                         l57u_ksc8__zzlul,
    input                         e92f6_ec7b7,
    input                         x5xpw_q76_9x1xhfigf0kjk4us,
    input   [15:0]                h_p_v40ojzhzuo,
    input   [15:0]                rg7ozwpk7xwi6vdbg8,
    input   [15:0]                st_xbxcknhpf,
    output [31:0]                 wddz9ajtz98uzxa1y13_rd_6yf,
    output                        a8ksd2cml1857c , 
    output                        h1zz0n82qird6 , 
    output                        wkp4c4o8i9jz7qrr , 
    output                        xgce667c9h1v9_2 , 
    output                        fmmfcow0bhw_n , 
    output                        t9h8f8az1xl6lnxb ,
    output                        bvwpeiqbd9vorm_z , 
    output                        dzey_2yh25ke6udi,
    output                        hk5bt7sgcl_w,
    output [9:0]                  okiluofya4d,
    output  [1:0]                 t72myhasn0g1ns,
    output                        el90ghiy_pow7iut1mrhem,
    output                        gcmeduaxfy2t07z2tp0pt,
    output  [1:0]                 vudvag_p2zmadu0,
    output                        erlun2j0p7c9b3kgbw,
    output                        ugsaaedtn1grq7,
    input                         itzmb3pv762occb74z2bqy,
    output                        rg_d619o1c7drrtakc,
    input                         ri2ziyy,
    input                         r46kf
);
     localparam  uwrgm1oivt1de06hok = 6 + 1;
     localparam  jo_msal9loubiruk8t     = 8;
     localparam  wmwaive7bs_r7_m_3           = 8'h00 ;
     localparam  qu1saw_nopi348ua            = 8'h04 ;
     localparam  uq6xg349hd             = 8'h08 ;
     localparam  gbt3epns923                 = 8'h0C ;
     localparam  jc7quc9gr0abki6v3           = 8'h10 ;
     localparam  vp9ga2s0rhk            = 8'h14 ;
     localparam  q1df8l2zyaizef9             = 8'h18 ;
     localparam  v4fkiv6ax5oh5i0            = 8'h1c ;
     localparam  wd2cl5iyaiiad             = 8'h20 ;
     localparam  o_hioq1logji4            = 8'h24 ;
     localparam  f3x7pr51m4eb9j75id1         = 8'h28 ;
     localparam  v76in2e52uj              = 8'h2C ;
     localparam  oxe4pdr72               = 8'h30 ;
     localparam  tao8sd9qpi               = 8'h34 ;
     localparam  h8qgutxmk               = 8'h38 ;
     localparam  stdiga15hvnbg               = 8'h3c ;
     localparam  c8ig6o391na0epbr            = 8'h40 ;
     localparam  yw4dwvt1t0             = 8'h44 ;
     localparam  x9xoqc2jxkyn0vyu1vc         = 8'h48 ;
     localparam  b16txyyb4l5lp5u03zp6        = 8'h4c ;
     localparam  d1__16jepphyqfszxbbb1q    = 8'h50 ;
     localparam  mvg3kvokhh2jayz7zdg3gm    = 8'h54 ;
     localparam  iwp35afbkrus3byzsq0otjo   = 8'h58 ;
     localparam  cx05pj2626v4uriwwzzkjwak   = 8'h5c ;
     localparam  mbuqeenkxnafu            = 8'h60 ;
     localparam  jj3egtpwp76kjzx            = 8'h64 ;
     localparam  xycxg12vbv8            = 8'h68 ;
     localparam  mygpxpk61tqqrf            = 8'h6c ;
     localparam  atu5qoyovd                 = 8'h70 ;
     localparam  wyrigyzyg                 = 8'h74 ;
     localparam  e2bw0xf951uonr6mh         = 8'h78 ;
     localparam  g3bmrmw35wotriw3d        = 8'h7c ;
     localparam  yworkswhk8ixxbb_h3u        = 8'h80 ;
     localparam  jfcuwdfu388hiry089jt5a9gm   = 8'h84 ;
     localparam  n0vsk1cpzmn4ckx9dmao9rp = 8'h88 ;
     localparam  xk6lkhrtk3l_8qah5          = 8'h8c ;
     localparam  pxlw6i7ve83as            = 8'h90 ;
     localparam  gyhy486esq0k0               = 8'h94 ;
     localparam  g8p1jxaa0r38           = 8'h98 ;
     localparam  e3sodultrd1zygxd          = 8'ha0 ;
     localparam  xevey8uz882pyziy6          = 8'ha4 ;
     localparam  u40ujf131dxaoh          = 8'ha8 ;
     localparam  z0kufwisjtqbjjti          = 8'hac ;
     localparam  pvys0bg7ae              = 8'h00 ;
     localparam  ify15w_77s45r              = 8'h01 ;
     localparam  r3l_j3l6joxzrr              = 8'h02 ;
     localparam  asvlndmcnlmd              = 8'h03 ;
     localparam  m22mq0sxe9q_8ji        = 8'h04 ;
     localparam  rguqtv793slt0dy        = 8'h05 ;
     localparam  k7k0sman34x35cgen_e        = 8'h06 ;
     localparam  vq376mscfu9bee5        = 8'h07 ;
     localparam  hd6m8vbz4w0qi4ii         = 8'h08 ;
     localparam  b6qhxchvrkdvb66w         = 8'h09 ;
     localparam  x2u4m3pgztwq1ht         = 8'h0a ;
     localparam  m77xivj7oy2ne05zg         = 8'h0b ;
     localparam  llo4ku1hwrcig          = 8'h0c ;
     localparam  jnoha9eaggxtua9          = 8'h0d ;
     localparam  k_wn4t_kikyrc63i          = 8'h0e ;
     localparam  nmgkkr00k28sqn2ewx          = 8'h0f ;
     localparam  r4_mml8gjv5so4y2b1gh        = 8'h10 ;
     localparam  ouidtsvt5elqxi9kr5u        = 8'h11 ;
     localparam  rilp24wzgpm0i95h        = 8'h12 ;
     localparam  fw1w40d92_p7g34w3a        = 8'h13 ;
     localparam  aipo_gskco0rg3         = 8'h14 ;
     localparam  bifozyxenxs14fj37         = 8'h15 ;
     localparam  rsx065kn24y24u         = 8'h16 ;
     localparam  ztbuuzbh1kcx2xb3         = 8'h17 ;
     localparam  n7b2kcleo0uxcdlbsb          = 8'h18 ;
     localparam  f77uh7pmhfdnw          = 8'h19 ;
     localparam  f6y7s32bw7_9svk          = 8'h1a ;
     localparam  cai3os7tuh0b9          = 8'h1b ;
     localparam  djsp5a60whgyfxck903b5rygg              = 8'h1c ;
     localparam  wf2l0ui1pon81p2eqyxjs5e040              = 8'h1d ;
     localparam  aq0oo8lgop9toqd1c9v3e5ijlwe6              = 8'h1e ;
     localparam  yrm14ykbwkvw21h0fcvixi82              = 8'h1f ;
     wire qg9cxb3j66gdphvucf;
     wire h9v5e_bsrlv6bm                 = mxwg8lfgv4pge1 & qi_euczbjhgo1za;
     wire ftd2ksof8y0u                   = h9v5e_bsrlv6bm & (~cuu3goyrnwc9hf);
     wire nscv603l221e50                   = h9v5e_bsrlv6bm & cuu3goyrnwc9hf;
     wire ldtvg0uu43xy21q                = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == wd2cl5iyaiiad);
     wire cy4ymd0luxh84ta27_07               = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == o_hioq1logji4);
     wire ag_hnglnqh65urlkjvii_4            = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == f3x7pr51m4eb9j75id1);
     wire e5381tdpvp2yxztx                 = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == v76in2e52uj);
     wire ywbhx7dz04bc2_                  = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == gyhy486esq0k0);
     wire m68lsejqsep100nt21              = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == g8p1jxaa0r38);
     wire yl3ryni1v82p77                  = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == oxe4pdr72);
     wire j5a8pc_b6t14ds                  = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == tao8sd9qpi);
     wire tohrnzuss_t5                  = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == h8qgutxmk);
     wire ce6dp9hjhqx6mmme                  = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == stdiga15hvnbg);
     wire iyrv4y7u0izse0szi             = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == e3sodultrd1zygxd);
     wire gqx1mtua57hsy3i3y             = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == xevey8uz882pyziy6);
     wire verodocg1qjvypc1yte1pj             = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == u40ujf131dxaoh);
     wire nveclehq31sj8o0jmyb             = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == z0kufwisjtqbjjti);
     wire oo6crn15m1mcyssa9xw               = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == c8ig6o391na0epbr);
     wire ir32l79_amqc_9                = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == yw4dwvt1t0);
     wire ue3fdwdzy1o2_t_ckuu2            = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == x9xoqc2jxkyn0vyu1vc);
     wire lv5wkmjuyd9kbamrngchr           = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == b16txyyb4l5lp5u03zp6);
     wire key9t4a7mp0k25                = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == mbuqeenkxnafu);
     wire wymdvbm3b7ltn3w                = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == jj3egtpwp76kjzx);
     wire g5dphdg3rk5dpmo                = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == xycxg12vbv8);
     wire plqdpl21lue983a3                = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == mygpxpk61tqqrf);
     wire rh_icf3xodxlben                    = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == atu5qoyovd);
     wire ln4z7_my90lv8z                    = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == wyrigyzyg);
     wire h7iipa31kzmlp0hnz1dy              = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == wmwaive7bs_r7_m_3);
     wire nl1_rxvaisg9rplz6hi0           = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == g3bmrmw35wotriw3d);
     wire w0tp3vuxqk8hx3r9drd               = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == qu1saw_nopi348ua);
     wire sj8u8fy4r5uoed                = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == uq6xg349hd);
     wire foupa8utugtmrsp8vlq              = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == jc7quc9gr0abki6v3);
     wire cqtkuc7im3x4ce7oqtwh4uzs           = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == yworkswhk8ixxbb_h3u);
     wire bgsx2j_7o9anqnner60               = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == vp9ga2s0rhk);
     wire vc_a10ptia_237j2qd                = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == q1df8l2zyaizef9);
     wire z4m7l6wu5u                    = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == gbt3epns923);
     wire qrdfjf4z0q8ax9wvg5            = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == e2bw0xf951uonr6mh);
     wire hrolfhao_gyftip4f2z3           = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == d1__16jepphyqfszxbbb1q);
     wire f0y_cjquqx3n1ag80g48jlya1          = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == jfcuwdfu388hiry089jt5a9gm);
     wire jvzk1sfx5qv5p5n5ad9w3np       = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == mvg3kvokhh2jayz7zdg3gm);
     wire c86faeipgmpcd7r3svvy444gd3      = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == iwp35afbkrus3byzsq0otjo);
     wire xd8wu1qw187q9ck2iglisvhd      = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == cx05pj2626v4uriwwzzkjwak);
     wire kt1ysgbivvb5w1p5               = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == v4fkiv6ax5oh5i0);
     wire l50_iw0hdtbb28w4g246gn2fqh    = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == n0vsk1cpzmn4ckx9dmao9rp);
     wire ovhl4ds8cplpoe7kb8r5             = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == xk6lkhrtk3l_8qah5);
     wire ep7aplq9f2pxy67mo               = (t3lk20ui52aqc6[jo_msal9loubiruk8t-1:0] == pxlw6i7ve83as);
     wire ipfyglkaph1evhb                    = ldtvg0uu43xy21q             & ftd2ksof8y0u ; 
     wire n7tk95b51vq_r                   = cy4ymd0luxh84ta27_07            & ftd2ksof8y0u ;         
     wire p_17urj5t_8lggvz                = ag_hnglnqh65urlkjvii_4         & ftd2ksof8y0u ;       
     wire tm630b2mx94                     = e5381tdpvp2yxztx              & ftd2ksof8y0u ;  
     wire hdvs5pp0roe2                      = ywbhx7dz04bc2_               & ftd2ksof8y0u ;  
     wire cdzzm62elnfc679                  = m68lsejqsep100nt21           & ftd2ksof8y0u ;  
     wire j7s2wofqhm79843                   = oo6crn15m1mcyssa9xw            & ftd2ksof8y0u ;        
     wire plp0va3eyj                    = ir32l79_amqc_9             & ftd2ksof8y0u ;        
     wire stitlg2zg7hykdf                   = ep7aplq9f2pxy67mo            & ftd2ksof8y0u ;        
     wire fi60kj1uo9wvongk                = ue3fdwdzy1o2_t_ckuu2         & ftd2ksof8y0u ;        
     wire vbgtfsllw9j5iqi20bny               = lv5wkmjuyd9kbamrngchr        & ftd2ksof8y0u ;          
     wire q460cud4856td_                   = key9t4a7mp0k25             & ftd2ksof8y0u ;          
     wire a20riat423bwt                   = g5dphdg3rk5dpmo             & ftd2ksof8y0u ;          
     wire fj0phumlwof4                   = plqdpl21lue983a3             & ftd2ksof8y0u ; 
     wire wgeqsf                        = rh_icf3xodxlben                 & ftd2ksof8y0u ;          
     wire sygtfc3m2o0                        = ln4z7_my90lv8z                 & ftd2ksof8y0u ; 
     wire ame5iy6ro9mc22fwr                  = h7iipa31kzmlp0hnz1dy           & ftd2ksof8y0u ; 
     wire og6s0sgo7baxb0f2xg               = nl1_rxvaisg9rplz6hi0        & ftd2ksof8y0u ; 
     wire thlnsjrq6hi                   = w0tp3vuxqk8hx3r9drd            & ftd2ksof8y0u ; 
     wire lsnhletjhp                    = sj8u8fy4r5uoed             & ftd2ksof8y0u ; 
     wire ri599f6u3e8w1z                  = foupa8utugtmrsp8vlq           & ftd2ksof8y0u ; 
     wire bnx9gnxge2uzjlprj0               = cqtkuc7im3x4ce7oqtwh4uzs        & ftd2ksof8y0u ; 
     wire i1xsweukw1dk4h                   = bgsx2j_7o9anqnner60            & ftd2ksof8y0u ; 
     wire r4yhsqzt7h                    = vc_a10ptia_237j2qd             & ftd2ksof8y0u ; 
     wire kz96koy5ft                        = z4m7l6wu5u                 & ftd2ksof8y0u ; 
     wire bdq7su86rywal0icxiu                = qrdfjf4z0q8ax9wvg5         & ftd2ksof8y0u ; 
     wire gzsx200c4jmw6xr2gvr               = hrolfhao_gyftip4f2z3        & ftd2ksof8y0u ; 
     wire grpt1u0dtlh9bep_dai_              = f0y_cjquqx3n1ag80g48jlya1       & ftd2ksof8y0u ; 
     wire r07hp2c_e3vcnfkqa17yae           = jvzk1sfx5qv5p5n5ad9w3np    & ftd2ksof8y0u ; 
     wire v3ls3hnvy1ret9gpeh9si          = c86faeipgmpcd7r3svvy444gd3   & ftd2ksof8y0u ; 
     wire hpq2zpk0ewnzb_83m08tnxi          = xd8wu1qw187q9ck2iglisvhd   & ftd2ksof8y0u ; 
     wire zew3v_e569dcm5i6z6b737zy48        = l50_iw0hdtbb28w4g246gn2fqh & ftd2ksof8y0u ;
     wire qg44og_9jqwl9                    = ldtvg0uu43xy21q             & nscv603l221e50 ; 
     wire x1q_uufiiahbkfow                  = m68lsejqsep100nt21           & nscv603l221e50 ; 
     wire m75nun5ea70t                   = cy4ymd0luxh84ta27_07            & nscv603l221e50 ;         
     wire qtvwxz99lftmvmgu                = ag_hnglnqh65urlkjvii_4         & nscv603l221e50 ;       
     wire pk4lrizee                      = yl3ryni1v82p77               & nscv603l221e50 ;     
     wire du9fbnanx                      = j5a8pc_b6t14ds               & nscv603l221e50 ;    
     wire x0ny6afk                      = tohrnzuss_t5               & nscv603l221e50 ;         
     wire ay978dvig35x                      = ce6dp9hjhqx6mmme               & nscv603l221e50 ;      
     wire iaxt4x3cyikrdm0da                 = iyrv4y7u0izse0szi          & nscv603l221e50 ;     
     wire qze5at76xag1d57zmj                 = gqx1mtua57hsy3i3y          & nscv603l221e50 ;    
     wire ffda94zy23za0is                 = verodocg1qjvypc1yte1pj          & nscv603l221e50 ;         
     wire het97c6elsen1x3my                 = nveclehq31sj8o0jmyb          & nscv603l221e50 ;   
     wire ns71s_h1arj51j0                   = oo6crn15m1mcyssa9xw            & nscv603l221e50 ;        
     wire gycr9rhq2wxb8u                    = ir32l79_amqc_9             & nscv603l221e50 ;        
     wire fbnq2d411owbgs3w8                = ue3fdwdzy1o2_t_ckuu2         & nscv603l221e50 ;        
     wire p10_eoo5l3yu504u_n46               = lv5wkmjuyd9kbamrngchr        & nscv603l221e50 ;
     wire jvzrvaou7xom                   = wymdvbm3b7ltn3w             & nscv603l221e50 ;
     wire a3puvtnq5wbdk4                   = g5dphdg3rk5dpmo             & nscv603l221e50 ;          
     wire i_nd0555vsxzsp                   = plqdpl21lue983a3             & nscv603l221e50 ; 
     wire awuf0prl0                        = rh_icf3xodxlben                 & nscv603l221e50 ;          
     wire suibpsy                        = ln4z7_my90lv8z                 & nscv603l221e50 ;
     wire rf36qo25w_u1q9i                  = h7iipa31kzmlp0hnz1dy           & nscv603l221e50 ; 
     wire j1gop08czvw4tib73i1               = nl1_rxvaisg9rplz6hi0        & nscv603l221e50 ; 
     wire djkqnexgu0zok3                   = w0tp3vuxqk8hx3r9drd            & nscv603l221e50 ; 
     wire k14e5wndpuq                    = sj8u8fy4r5uoed             & nscv603l221e50 ; 
     wire hj_hvtik47yklk                  = foupa8utugtmrsp8vlq           & nscv603l221e50 ; 
     wire tw1hic_3v1ss2mz82ts               = cqtkuc7im3x4ce7oqtwh4uzs        & nscv603l221e50 ; 
     wire vrzmhb1jomo979fk                   = bgsx2j_7o9anqnner60            & nscv603l221e50 ; 
     wire l88t7k3k3h                    = vc_a10ptia_237j2qd             & nscv603l221e50 ; 
     wire ny8phs1bi                        = z4m7l6wu5u                 & nscv603l221e50 ; 
     wire clo3ojypopfg6b7l                = qrdfjf4z0q8ax9wvg5         & nscv603l221e50 ; 
     wire c2csj4kv58cr34idqdu               = hrolfhao_gyftip4f2z3        & nscv603l221e50 ; 
     wire b13s2mzlnmq07uqmfmhn              = f0y_cjquqx3n1ag80g48jlya1       & nscv603l221e50 ; 
     wire mqkny29e4a7yg                   = kt1ysgbivvb5w1p5            & nscv603l221e50 ; 
     wire rq5avpvkufugu627ns2zmy           = jvzk1sfx5qv5p5n5ad9w3np    & nscv603l221e50 ; 
     wire xa9jj252_vrz65hqrqozri          = c86faeipgmpcd7r3svvy444gd3   & nscv603l221e50 ; 
     wire duek7dmj7gxiaitoenhjpeqvt          = xd8wu1qw187q9ck2iglisvhd   & nscv603l221e50 ; 
     wire gint0i47ztn1ca1wrckke690onv        = l50_iw0hdtbb28w4g246gn2fqh & nscv603l221e50 ;
     wire x_bvo8ix9gl0kjdxxh                 = ovhl4ds8cplpoe7kb8r5          & nscv603l221e50 ;
     wire bs6sek5p6dik                   = ep7aplq9f2pxy67mo            & nscv603l221e50 ;
  wire [31:0] sku9z5p3py2_tin7fsp2;
  wire [10-1:0]         pctk6hlgp8ia3ju86_kt_e0l;
  wire                  sgjtgh2bm4znt0y_iwus0wgvxijvvw = cdzzm62elnfc679;
  wire [10-1:0]         trlp3e7_vuzaycp6893qve9iy2j1asvv = rs8qfdkpko8pq[9:0];
  wire [10-1:0]         ctdd98fn82w3h5dtgres376wop3 = trlp3e7_vuzaycp6893qve9iy2j1asvv;
sdio_gnrl_dfflrs #(10, 10'h3ff) cjea06dm9cozoo7u3l76_v5fi(sgjtgh2bm4znt0y_iwus0wgvxijvvw,ctdd98fn82w3h5dtgres376wop3,pctk6hlgp8ia3ju86_kt_e0l,ri2ziyy,r46kf);
  assign sku9z5p3py2_tin7fsp2 = {
                            22'h0
                           ,pctk6hlgp8ia3ju86_kt_e0l
                           };
  wire [31:0] ncpise_lhtm6tvdzh0;
  wire [6-1:0]         je2x55k701gr08bfoc482es;
  wire                 o54py_mcjgcwiq6xiobs00 = ipfyglkaph1evhb;
  wire [6-1:0]         wd_7w3tnkldrovryc0s5yavfpogg9_0mj = rs8qfdkpko8pq[13:8];
  wire [6-1:0]         iu28niha9kt_nk7jcxkh46_j_tq = wd_7w3tnkldrovryc0s5yavfpogg9_0mj;
sdio_gnrl_dfflrs #(6, 6'h0) cc__9g0pxmkhz1b81w7gs3ca(o54py_mcjgcwiq6xiobs00,iu28niha9kt_nk7jcxkh46_j_tq,je2x55k701gr08bfoc482es,ri2ziyy,r46kf);
  wire [1-1:0]         q58kctsscg8r7klyknuue46rwbr0k;
  wire                 x_kapjoxbxmi3tmr7egd3w0cyj03hkw = ipfyglkaph1evhb;
  wire [1-1:0]         nc2figpdp6pb83foeevdmdrabffsf1jlrfua66ywh = rs8qfdkpko8pq[7:7];
  wire [1-1:0]         xspfwyifnmt1hhxxmoq1sp9mqmkye4t9zj = nc2figpdp6pb83foeevdmdrabffsf1jlrfua66ywh;
sdio_gnrl_dfflrs #(1, 1'h1) gvbdohy03tg01oowb2b992x43yt7d1(x_kapjoxbxmi3tmr7egd3w0cyj03hkw,xspfwyifnmt1hhxxmoq1sp9mqmkye4t9zj,q58kctsscg8r7klyknuue46rwbr0k,ri2ziyy,r46kf);
  wire [1-1:0]         k497r67z_6wq7flhw64vrm94k65_;
  wire                 kd4rup151836u0nlyxz2inmha5rqytvmpg = ipfyglkaph1evhb;
  wire [1-1:0]         dr0w05_dlufmm017uhtm2470c87uhkbp6z_dll6 = rs8qfdkpko8pq[6:6];
  wire [1-1:0]         a9wxprjjw4brpnm3x7yo1rdxrac549p6 = dr0w05_dlufmm017uhtm2470c87uhkbp6z_dll6;
sdio_gnrl_dfflrs #(1, 1'h0) xeq2thg22j0_6wg5itdpt6lthj2m6oxz(kd4rup151836u0nlyxz2inmha5rqytvmpg,a9wxprjjw4brpnm3x7yo1rdxrac549p6,k497r67z_6wq7flhw64vrm94k65_,ri2ziyy,r46kf);
  wire [1-1:0]         x1tc7vew96e89atm24uuof8qkioybbj5cf_;
  wire                 d6tvl8_6p_aswyftm9qq8s0_bqhudiejtvq = ipfyglkaph1evhb;
  wire [1-1:0]         i92oak4_r_f5cxyi8rdh5tr8a9jwqbjlicl676ncl78x = rs8qfdkpko8pq[5:5];
  wire [1-1:0]         uw64wuaaipol80mxi9ja4ekfa906mfn2akii = i92oak4_r_f5cxyi8rdh5tr8a9jwqbjlicl676ncl78x;
sdio_gnrl_dfflrs #(1, 1'h0) ufpfmv12il_0ghjpuvilcnv6w_zi5cdde(d6tvl8_6p_aswyftm9qq8s0_bqhudiejtvq,uw64wuaaipol80mxi9ja4ekfa906mfn2akii,x1tc7vew96e89atm24uuof8qkioybbj5cf_,ri2ziyy,r46kf);
  wire [1-1:0]         u773mwsni4bxg74j2d2eq5h7ihbiuq9q;
  wire                 tl_62m48lvd__gspvhfcxty184cwp = ipfyglkaph1evhb;
  wire [1-1:0]         brack6214rs6ciacd3kijo73wf8h54km7x33u = rs8qfdkpko8pq[4:4];
  wire [1-1:0]         sek26rfaac66d27v7q4xtftwsnlyg1s5 = brack6214rs6ciacd3kijo73wf8h54km7x33u;
sdio_gnrl_dfflrs #(1, 1'h0) bdle2zx0tr3294b8yl2qvladmyl2h7k(tl_62m48lvd__gspvhfcxty184cwp,sek26rfaac66d27v7q4xtftwsnlyg1s5,u773mwsni4bxg74j2d2eq5h7ihbiuq9q,ri2ziyy,r46kf);
  wire [1-1:0]         ue0bxk_gzma84k5az_fdudvnj;
  wire                 i3gs2not1h3hmkrnm0z99gb9iz1 = ipfyglkaph1evhb;
  wire [1-1:0]         nq2gd9_klxq7dlva_0i6soen3ukgj08o = rs8qfdkpko8pq[3:3];
  wire [1-1:0]         jdbb1zyo1h0dvrljwa8ta_4z3fzpgg = nq2gd9_klxq7dlva_0i6soen3ukgj08o;
sdio_gnrl_dfflrs #(1, 1'h0) pxa6uqgquinuo6i3oib70h9l(i3gs2not1h3hmkrnm0z99gb9iz1,jdbb1zyo1h0dvrljwa8ta_4z3fzpgg,ue0bxk_gzma84k5az_fdudvnj,ri2ziyy,r46kf);
  wire [1-1:0]         y66ec0x3z4r9lmal5zhjf2k97;
  wire                 plgxb3eqso_7t9q0gnzta0yy = ipfyglkaph1evhb;
  wire [1-1:0]         h6zjxbg_isbrk0jjchbhol0fvp2gzqa0 = rs8qfdkpko8pq[2:2];
  wire [1-1:0]         kme9dpyra2zc0i4d_sq4b9l3o = h6zjxbg_isbrk0jjchbhol0fvp2gzqa0;
sdio_gnrl_dfflrs #(1, 1'h0) p3jmfyq0qeoa4klpc96i47wr3sr(plgxb3eqso_7t9q0gnzta0yy,kme9dpyra2zc0i4d_sq4b9l3o,y66ec0x3z4r9lmal5zhjf2k97,ri2ziyy,r46kf);
  wire [1-1:0]         qde1fekg4cmvcxq6icajm6e2w;
  wire                 ldf21lgu1_vs1stcmus8uw8pg14rjhan = ipfyglkaph1evhb;
  wire [1-1:0]         nzcder919lw5dvf8ovi6evqg4u9emcqgo1fzq = rs8qfdkpko8pq[1:1];
  wire [1-1:0]         m_b3cwk_umdo55pvblxhvbo4cspeq = nzcder919lw5dvf8ovi6evqg4u9emcqgo1fzq;
sdio_gnrl_dfflrs #(1, 1'h0) yh8otlx780vn0d5iw_ivhhkab(ldf21lgu1_vs1stcmus8uw8pg14rjhan,m_b3cwk_umdo55pvblxhvbo4cspeq,qde1fekg4cmvcxq6icajm6e2w,ri2ziyy,r46kf);
  wire [1-1:0]         yaovqr573od8yn0_2bqzftd3dil3v;
  wire                 g3q29cj8mdslid76x9kw1i7w_4w = ipfyglkaph1evhb;
  wire [1-1:0]         ay8sebl59i9ghz0sze05glfyffd2k2v43ghe4o = rs8qfdkpko8pq[0:0];
  wire [1-1:0]         hhykcet4ilp1ss0lxr_7jmg4kkrpy = ay8sebl59i9ghz0sze05glfyffd2k2v43ghe4o;
sdio_gnrl_dfflrs #(1, 1'h0) t14vararr0uxp463h5sg4ka_h(g3q29cj8mdslid76x9kw1i7w_4w,hhykcet4ilp1ss0lxr_7jmg4kkrpy,yaovqr573od8yn0_2bqzftd3dil3v,ri2ziyy,r46kf);
  assign ncpise_lhtm6tvdzh0 = {
          18'd0
        , je2x55k701gr08bfoc482es
        , q58kctsscg8r7klyknuue46rwbr0k
        , k497r67z_6wq7flhw64vrm94k65_
        , x1tc7vew96e89atm24uuof8qkioybbj5cf_
        , u773mwsni4bxg74j2d2eq5h7ihbiuq9q
        , ue0bxk_gzma84k5az_fdudvnj
        , y66ec0x3z4r9lmal5zhjf2k97
        , qde1fekg4cmvcxq6icajm6e2w
        , yaovqr573od8yn0_2bqzftd3dil3v
    };
     wire [32-1:0]        nyoxu2m44nu2nkbbzg;
     wire [31:0] yl65iqysuazadbe0oflzmg852;
     wire [31:0] nleakp0k88367f20 = rs8qfdkpko8pq;
sdio_gnrl_dfflr #(32) sd8w3ipase_90cvqy (n7tk95b51vq_r, nleakp0k88367f20, yl65iqysuazadbe0oflzmg852, ri2ziyy, r46kf);
  assign nyoxu2m44nu2nkbbzg = {
          yl65iqysuazadbe0oflzmg852
    };
      wire [32-1:0]        whkl3p5gqgw86sfyg;
     wire lz7fuv9koxgjowvppahdvx2mm;
     wire ecf2zaatj7v1y = rs8qfdkpko8pq[0];
sdio_gnrl_dfflr #(1) awwhmusym_3kkxy43n (p_17urj5t_8lggvz, ecf2zaatj7v1y, lz7fuv9koxgjowvppahdvx2mm, ri2ziyy, r46kf);
     wire lmsuxdrpwgbq_ffn68gq3z_kmwfmb;
     wire y06cmqtpuqixan_v = rs8qfdkpko8pq[1];
sdio_gnrl_dfflr #(1) eppta9bpq47hd6z (p_17urj5t_8lggvz, y06cmqtpuqixan_v, lmsuxdrpwgbq_ffn68gq3z_kmwfmb, ri2ziyy, r46kf);
     wire [1:0] gi9gh0qxut770cc6cx31g12cnjs18ul;
     wire [1:0] oxyitzmn35vw2d = rs8qfdkpko8pq[3:2];
sdio_gnrl_dfflr #(2) ekytbq_or9soktp0g (p_17urj5t_8lggvz, oxyitzmn35vw2d, gi9gh0qxut770cc6cx31g12cnjs18ul, ri2ziyy, r46kf);
     wire [11:0] kra4ifr95fp92erbc4cgwat33_nmmy;
     wire [11:0] eo7dy278wz2_q8h0der = rs8qfdkpko8pq[31:20];
sdio_gnrl_dfflr #(12) tztr_p0ekm8it6to_dd2k2n (p_17urj5t_8lggvz, eo7dy278wz2_q8h0der, kra4ifr95fp92erbc4cgwat33_nmmy, ri2ziyy, r46kf);
     wire [15:0] yavjar3d4uc36d8f43mayprukbx;
     wire [15:0] s4i8h14au82f7mstj0fh = rs8qfdkpko8pq[19:4];
sdio_gnrl_dfflr #(16) xk9derrmrzr4p2f8wkztap (p_17urj5t_8lggvz, s4i8h14au82f7mstj0fh, yavjar3d4uc36d8f43mayprukbx, ri2ziyy, r46kf);
  assign whkl3p5gqgw86sfyg = {
          kra4ifr95fp92erbc4cgwat33_nmmy
        , yavjar3d4uc36d8f43mayprukbx
        , gi9gh0qxut770cc6cx31g12cnjs18ul
        , lmsuxdrpwgbq_ffn68gq3z_kmwfmb
        , lz7fuv9koxgjowvppahdvx2mm
    };
     wire [32-1:0]        amu8g6tc15o0;
     wire zi67zxmuzonog3cbp5nme;
     wire yiafftztjntk20lwiho = tm630b2mx94 ;
     wire bh5as01utyix2o7tjh = zi67zxmuzonog3cbp5nme;
     wire rdm9nno8xnzb8sfizq = rs8qfdkpko8pq[0] & (~bh5as01utyix2o7tjh);
     wire q8llzuy5la7x12s00wi = yiafftztjntk20lwiho | bh5as01utyix2o7tjh;
sdio_gnrl_dfflr #(1) ykvkw737jxwfoojh5 (q8llzuy5la7x12s00wi, rdm9nno8xnzb8sfizq, zi67zxmuzonog3cbp5nme, ri2ziyy, r46kf);
  assign amu8g6tc15o0 = {
          31'd0
        , zi67zxmuzonog3cbp5nme
    };
     wire [32-1:0]        g__cozghpq00h;
     wire plsj7z0kbwf3bzv0bne;
     wire fm37x3h3fz686u = hdvs5pp0roe2 ;
     wire y4oosgiss_16y = plsj7z0kbwf3bzv0bne;
     wire qxq3fbpol1q_vul = rs8qfdkpko8pq[0] & (~y4oosgiss_16y);
     wire tsyh9l9bph0yv = fm37x3h3fz686u | y4oosgiss_16y;
sdio_gnrl_dfflr #(1) fs386cqrq9v6lz9j (tsyh9l9bph0yv, qxq3fbpol1q_vul, plsj7z0kbwf3bzv0bne, ri2ziyy, r46kf);
  assign g__cozghpq00h = {
          31'd0
        , plsj7z0kbwf3bzv0bne
    };
  wire [32-1:0]        s6uti1uy9;
  wire [1-1:0]         zcpxgi771i6padzmneu;
  wire                 zqk7alxhecl19hsg202 = kz96koy5ft 
                                          ;
  wire [1-1:0]         g05e_00x1ggy2t84mfmcghnxle = 
                                                 rs8qfdkpko8pq[0:0];
  wire [1-1:0]         k8yvy73trn_26q8ixcwy = g05e_00x1ggy2t84mfmcghnxle;
sdio_gnrl_dfflrs #(1, 1'h0) wuyhcvhan1wapxqwmyq92(zqk7alxhecl19hsg202,k8yvy73trn_26q8ixcwy,zcpxgi771i6padzmneu,ri2ziyy,r46kf);
  wire [1-1:0]         szgdb329qlilzw_ecd;
  wire                 m1jdj_dxgng4vqbj_1xhupz = kz96koy5ft 
                                          ;
  wire [1-1:0]         a8ksmtjiframwvgr1co9mqtk = 
                                                 rs8qfdkpko8pq[1:1];
  wire [1-1:0]         fy9d_in7m_nn8b0yna8 = a8ksmtjiframwvgr1co9mqtk;
sdio_gnrl_dfflrs #(1, 1'h0) vtc7vq8fpi_a7nbfwfa(m1jdj_dxgng4vqbj_1xhupz,fy9d_in7m_nn8b0yna8,szgdb329qlilzw_ecd,ri2ziyy,r46kf);
  wire [1-1:0]         cr5vd7zl0cq9aq9crq46mhkd7e;
  wire                 egt16koall03tq712hbnri2hdi = kz96koy5ft 
                                                 ;
  wire [1-1:0]         c92geriqy7u4jix5a94jt4h_oatp38eds3 = 
                                                       rs8qfdkpko8pq[2:2];
  wire [1-1:0]         tt_nxkjn5aige8x9dykcsz6rb04r_ = c92geriqy7u4jix5a94jt4h_oatp38eds3;
sdio_gnrl_dfflrs #(1, 1'h0) ez3zegc925jnmd3jm0da31fe(egt16koall03tq712hbnri2hdi,tt_nxkjn5aige8x9dykcsz6rb04r_,cr5vd7zl0cq9aq9crq46mhkd7e,ri2ziyy,r46kf);
  wire [1-1:0]         f200vubhpxhpqidkhz9nr;
  wire                 o090e9bk4613sfonhs277y = kz96koy5ft 
                                            ;
  wire [1-1:0]         qvuno9yej98f48j77s8c3410au7 = 
                                                  rs8qfdkpko8pq[3:3];
  wire [1-1:0]         dqnfmyf3eer930ud10pjb9 = qvuno9yej98f48j77s8c3410au7;
sdio_gnrl_dfflrs #(1, 1'h1) n6x60a_mh6b4l579z9(o090e9bk4613sfonhs277y,dqnfmyf3eer930ud10pjb9,f200vubhpxhpqidkhz9nr,ri2ziyy,r46kf);
  wire [1-1:0]         kk6k5_uvu6wehm2ogwazdh9e72mqbfn_;
  wire                 nc8n433ktpgtymdup0elgqzhdcncm0rby012m = kz96koy5ft 
                                                         ;
  wire [1-1:0]         gob_ewd31rheexlmuamykexm2fpkp1s13ijdp6b = 
                                                               rs8qfdkpko8pq[4:4];
  wire [1-1:0]         hue4tufyl1yb9d7ybbd0z1cq0serp3nlkq = gob_ewd31rheexlmuamykexm2fpkp1s13ijdp6b;
sdio_gnrl_dfflrs #(1, 1'h0) u5q4vrw0slyv5483xwuqhsx61znm23u(nc8n433ktpgtymdup0elgqzhdcncm0rby012m,hue4tufyl1yb9d7ybbd0z1cq0serp3nlkq,kk6k5_uvu6wehm2ogwazdh9e72mqbfn_,ri2ziyy,r46kf);
  wire [1-1:0]         dzyzpj4yl8lxbruw8i;
  wire                 qpge9vfz8n0pz2cc1a32 = kz96koy5ft
                                            | erlun2j0p7c9b3kgbw
                                            ;
  wire [1-1:0]         sm59fynef5nss4_yqqymlpzbxi_1_g = 
                                                  erlun2j0p7c9b3kgbw ? 1'b0 :
                                                  rs8qfdkpko8pq[5:5];
  wire [1-1:0]         xh81j6lfomgsnqxu4f8uzh8 = sm59fynef5nss4_yqqymlpzbxi_1_g;
sdio_gnrl_dfflrs #(1, 1'h1) yq49f38fhu46cq1fpqm24na(qpge9vfz8n0pz2cc1a32,xh81j6lfomgsnqxu4f8uzh8,dzyzpj4yl8lxbruw8i,ri2ziyy,r46kf);
  wire [1-1:0]         yg09pjci8qewnp36k37xnthpdpql5;
  wire                 scp5cwughgmlzx95kscczlvgael = kz96koy5ft 
                                                   ;
  wire [1-1:0]         rsm4jck3f_h05rravgfnydtaf1s16ge7t_ix4 = 
                                                          rs8qfdkpko8pq[6:6];
  wire [1-1:0]         wyiiyv831gqsvnl4e5w15g3dudgyw = rsm4jck3f_h05rravgfnydtaf1s16ge7t_ix4;
sdio_gnrl_dfflrs #(1, 1'h1) xa35hjl8m7oqps3vjtl7292e0qob(scp5cwughgmlzx95kscczlvgael,wyiiyv831gqsvnl4e5w15g3dudgyw,yg09pjci8qewnp36k37xnthpdpql5,ri2ziyy,r46kf);
  wire [1-1:0]         gq7mlwgi0yt6rp6u4vo0to2r2a2w;
  wire                 kbsddl0qzmnmkgkk00ddv0cqiqvl8 = kz96koy5ft 
                                                     ;
  wire [1-1:0]         edy4uc9d8tuckhwm0a1__hvflnb46y2n998 = 
                                                           rs8qfdkpko8pq[7:7];
  wire [1-1:0]         jqj31pgr6wmi7osrlc_2qqlh90epx3zj = edy4uc9d8tuckhwm0a1__hvflnb46y2n998;
sdio_gnrl_dfflrs #(1, 1'h1) ew2j6tb13i3709bby3aqa27lse0cx(kbsddl0qzmnmkgkk00ddv0cqiqvl8,jqj31pgr6wmi7osrlc_2qqlh90epx3zj,gq7mlwgi0yt6rp6u4vo0to2r2a2w,ri2ziyy,r46kf);
  wire [1-1:0]         pyu4xu841np25aop47ie8cmv8;
  wire                 f0cp2dwubwnc9o1tb5piph5wm1viq6 = kz96koy5ft 
                                                  ;
  wire [1-1:0]         e6sohk9y02rafpg2oafgp8d9ktjpi573 =
                                                        rs8qfdkpko8pq[8:8];
  wire [1-1:0]         cv8o9ymjk6m1w6dkeob90hznm6o = e6sohk9y02rafpg2oafgp8d9ktjpi573;
sdio_gnrl_dfflrs #(1, 1'h0) l7az17ja8ogkbxhfmngn1l2s(f0cp2dwubwnc9o1tb5piph5wm1viq6,cv8o9ymjk6m1w6dkeob90hznm6o,pyu4xu841np25aop47ie8cmv8,ri2ziyy,r46kf);
  wire [1-1:0]         yfqgbimrsj5l6s9ecw98e_eqw8yje;
  wire                 b92ay_9rlf76szo2cjjxa_644ql0e_8tb = kz96koy5ft 
                                                    ;
  wire [1-1:0]         e52_p876k44afi4d6_4w5u194ju3v79vpwx42 =
                                                          rs8qfdkpko8pq[9:9];
  wire [1-1:0]         kdjv8d3ypdro46m69szdyu_yq3g4jy = e52_p876k44afi4d6_4w5u194ju3v79vpwx42;
sdio_gnrl_dfflrs #(1, 1'h0) rj6_8j_izkn_gcr98lkdwd1m0cig9(b92ay_9rlf76szo2cjjxa_644ql0e_8tb,kdjv8d3ypdro46m69szdyu_yq3g4jy,yfqgbimrsj5l6s9ecw98e_eqw8yje,ri2ziyy,r46kf);
  wire [1-1:0]         kv62_zxdvs2nv307wdnxd4;
  wire                 upqifq5gn85px3uf9l3ecaf = kz96koy5ft 
                                               ;
  wire [1-1:0]         rrm5ds_k5gqqiggzthc9fwg59gaxs2c3 = 
                                                     rs8qfdkpko8pq[10:10];
  wire [1-1:0]         s4dgus_qe07cmwbm8gkqojh = rrm5ds_k5gqqiggzthc9fwg59gaxs2c3;
sdio_gnrl_dfflrs #(1, 1'h0) q3qzn8g5mnvb804b0zz115yl_(upqifq5gn85px3uf9l3ecaf,s4dgus_qe07cmwbm8gkqojh,kv62_zxdvs2nv307wdnxd4,ri2ziyy,r46kf);
  wire [1-1:0]         ivghamr_q4qmprhv5flpwt1;
  wire                 kfybm9d16t6z6dgbmfvtn9b1t70 = kz96koy5ft 
                                              ;
  wire [1-1:0]         vm4l2e2c_bs5vtgae77je1jov4o8u_a5g = 
                                                     rs8qfdkpko8pq[11:11];
  wire [1-1:0]         r0tcjaeobww7dqzzxu42wwc4j = vm4l2e2c_bs5vtgae77je1jov4o8u_a5g;
sdio_gnrl_dfflrs #(1, 1'h0) oz1oc55h90jtg5vcspkmfm7y(kfybm9d16t6z6dgbmfvtn9b1t70,r0tcjaeobww7dqzzxu42wwc4j,ivghamr_q4qmprhv5flpwt1,ri2ziyy,r46kf);
  wire [1-1:0]         n0ujlpfpy88_2cqkfax0iuis51onfl;
  wire                 k2f1a77de869t4aisjt0sp8319ckwn5nu = kz96koy5ft 
                                                     ;
  wire [1-1:0]         ws847042py4935hw7e7o5q4yzmklm7ylyhsp = 
                                                           rs8qfdkpko8pq[13:13];
  wire [1-1:0]         gd3g1smpwqert64nqwpm0ejnkiqg4ip8 = ws847042py4935hw7e7o5q4yzmklm7ylyhsp;
sdio_gnrl_dfflrs #(1, 1'h1) xon32vmclc040ggpa99jywaipapt2u92(k2f1a77de869t4aisjt0sp8319ckwn5nu,gd3g1smpwqert64nqwpm0ejnkiqg4ip8,n0ujlpfpy88_2cqkfax0iuis51onfl,ri2ziyy,r46kf);
  wire [1-1:0]         wvlaqy4jdu3jo65130_ru2khta6n8_7u;
  wire                 a158wpd5vl4jnt3hy1v3k7e5e2yr9c = kz96koy5ft 
                                                      ;
  wire [1-1:0]         x6molaq_z9lci32c8h18rp6dmd2ym_rm_sh = 
                                                             rs8qfdkpko8pq[14:14];
  wire [1-1:0]         rw7qxl0a0au_2_8vaa7ok6975nqqepw = x6molaq_z9lci32c8h18rp6dmd2ym_rm_sh;
sdio_gnrl_dfflrs #(1, 1'h0) o6ywzxsjs0bykzv2l1vrafpkeiqt(a158wpd5vl4jnt3hy1v3k7e5e2yr9c,rw7qxl0a0au_2_8vaa7ok6975nqqepw,wvlaqy4jdu3jo65130_ru2khta6n8_7u,ri2ziyy,r46kf);
  wire [2-1:0]         pmr6rnu4bz89cj749j5;
  wire                 x8ah8mm3ph4ppaw84md1ftvs0a = kz96koy5ft;
  wire [2-1:0]         ffrpia8c6wy5t5188w_ycd662053 = rs8qfdkpko8pq[19:18];
  wire [2-1:0]         d10uul2sf21f9odoqpf8kz6w = ffrpia8c6wy5t5188w_ycd662053;
sdio_gnrl_dfflrs #(2, 2'h0) ua6d3ilu8qgiu7q7iyll5hn(x8ah8mm3ph4ppaw84md1ftvs0a,d10uul2sf21f9odoqpf8kz6w,pmr6rnu4bz89cj749j5,ri2ziyy,r46kf);
  wire [1-1:0]         i2acefpb6petzagqjtmm26lzglsuiv;
  wire [1-1:0]         lfp049b43nzp5c5f1tstdzntesk4k4cfbi9;
  wire                 am8w4uxebybjudxdy3dsh2lplzj1yk7 = kz96koy5ft;
  wire [1-1:0]         g2_3dahno5a37pfmy2fn_0vx92375sw_27be1ux6 = rs8qfdkpko8pq[20];
  wire [1-1:0]         d90y1ra11xr5m1oho1vq1ww0qofz_juyvgl = g2_3dahno5a37pfmy2fn_0vx92375sw_27be1ux6;
sdio_gnrl_dfflrs #(1, 1'h0) w9wkkwyayu0msu56z3_r69twq0v82szqwl(am8w4uxebybjudxdy3dsh2lplzj1yk7,d90y1ra11xr5m1oho1vq1ww0qofz_juyvgl,i2acefpb6petzagqjtmm26lzglsuiv,ri2ziyy,r46kf);
sdio_gnrl_dffr #(1) vcloohapfapn40wdqid20xue0jx0s_5yqk (i2acefpb6petzagqjtmm26lzglsuiv,lfp049b43nzp5c5f1tstdzntesk4k4cfbi9,ri2ziyy,r46kf);
  wire  qp9h30vaen11e7md63axaci6y89y = (~i2acefpb6petzagqjtmm26lzglsuiv) & lfp049b43nzp5c5f1tstdzntesk4k4cfbi9 ;
  wire [2-1:0]         sr19n1ywngusphv0qtt4g;
  wire                 vaodfcpwslqie8_kjsz4oj165 = kz96koy5ft & (sr19n1ywngusphv0qtt4g != 2'b11);
  wire [2-1:0]         kz4zxfzit0v89hqa5juu4vii2_g9 = (rs8qfdkpko8pq[22:21] == 2'b01) ? sr19n1ywngusphv0qtt4g : rs8qfdkpko8pq[22:21];
  wire [2-1:0]         l0ntehzf7hqq2kajursp_kzf = kz4zxfzit0v89hqa5juu4vii2_g9;
sdio_gnrl_dfflrs #(2, 2'h0) dntszfzqo2mgvdvigsxmk3(vaodfcpwslqie8_kjsz4oj165,l0ntehzf7hqq2kajursp_kzf,sr19n1ywngusphv0qtt4g,ri2ziyy,r46kf);
  wire gteewmr9rmhuw_2lfj0 = kz96koy5ft;
  wire qqzbgx4h_tknqnwm5ox = kz96koy5ft & (rs8qfdkpko8pq[22:21] == 2'b00);
  wire w6trljqbwyuvtoay;
sdio_gnrl_dfflrs #(1, 1'h0) tlop0ufzypcpz78b0k8jabvk0f9fsrq1bg (gteewmr9rmhuw_2lfj0,qqzbgx4h_tknqnwm5ox,w6trljqbwyuvtoay,ri2ziyy,r46kf);
  assign ugsaaedtn1grq7 = w6trljqbwyuvtoay;
  wire [1-1:0]         w_pdamnrdftxjegttc8wv1lkvibhnpj;
  wire                 d8o7dl557nlvwfab6yb_105371b9cs8bsb = kz96koy5ft;
  wire [1-1:0]         afg696jx5_a7xhi3l5whdasywuflm_i8x_ysn111 = rs8qfdkpko8pq[23];
  wire [1-1:0]         ns0rl3n0_mw22md7n0gk3u66zuhboopsd5324 = afg696jx5_a7xhi3l5whdasywuflm_i8x_ysn111;
sdio_gnrl_dfflrs #(1, 1'h0) pww9p92osiy83u35jhovgxh2bilk9ad(d8o7dl557nlvwfab6yb_105371b9cs8bsb,ns0rl3n0_mw22md7n0gk3u66zuhboopsd5324,w_pdamnrdftxjegttc8wv1lkvibhnpj,ri2ziyy,r46kf);
  wire [1-1:0]         t_ri80y_15j0mtdodpzkqhdch_3y9jar6;
sdio_gnrl_dffr #(1) av__53w4t0vd0mrlmyt1mhdkckk5r5zztq2a (w_pdamnrdftxjegttc8wv1lkvibhnpj,t_ri80y_15j0mtdodpzkqhdch_3y9jar6,ri2ziyy,r46kf);
  assign  gcmeduaxfy2t07z2tp0pt = (~w_pdamnrdftxjegttc8wv1lkvibhnpj) & t_ri80y_15j0mtdodpzkqhdch_3y9jar6;
  wire ys38rwd_zt9tnq402x0z329;
  wire dgaixwhe7cx6yudpe40weby = gcmeduaxfy2t07z2tp0pt;
  wire tm3c36e9cy2ar4afcc6ogqk8v = qp9h30vaen11e7md63axaci6y89y;
  wire gh963zanx3jle0r1cd2vt9iif6_r = (~tm3c36e9cy2ar4afcc6ogqk8v);
  wire po9hjtfdf060rmfnid_5_9rffm = dgaixwhe7cx6yudpe40weby | tm3c36e9cy2ar4afcc6ogqk8v;
sdio_gnrl_dfflrs #(1, 1'h0) b3mnjsaaplcrfd8r5us6y (po9hjtfdf060rmfnid_5_9rffm,gh963zanx3jle0r1cd2vt9iif6_r,ys38rwd_zt9tnq402x0z329,ri2ziyy,r46kf);
  wire whgnw4j8j3otscuqla9_a = i2acefpb6petzagqjtmm26lzglsuiv & x5xpw_q76_9x1xhfigf0kjk4us & eenfsp7uc;
  wire gul39dz5oevi7of2cvluw = i2acefpb6petzagqjtmm26lzglsuiv & x5xpw_q76_9x1xhfigf0kjk4us & (~eenfsp7uc);
  wire [1-1:0]         y2x732cxadne6xgg9vruqu10od;
  wire                 imlvmw4dvg_5sklpu3ic7h0nfsw = kz96koy5ft;
  wire [1-1:0]         glocukyatj1utck4njb9q7278yjm_8o = rs8qfdkpko8pq[24];
  wire [1-1:0]         u96xovekrfl4hq4dzfb99j5qaql6 = glocukyatj1utck4njb9q7278yjm_8o;
sdio_gnrl_dfflrs #(1, 1'h0) dferpj_b4mz15bb1lwuxwy(imlvmw4dvg_5sklpu3ic7h0nfsw,u96xovekrfl4hq4dzfb99j5qaql6,y2x732cxadne6xgg9vruqu10od,ri2ziyy,r46kf);
  wire [1-1:0]         ef5yjaawinoxce_xggomjkxf0p;
  wire                 k2ogwl2ngc28we234fq8hkp9le8o = kz96koy5ft;
  wire [1-1:0]         wp1ousvfc_yf4fuwo8lgkegw37iz646 = rs8qfdkpko8pq[25];
  wire [1-1:0]         m5jo2r2r9tzn17kkst83n4jh6m = wp1ousvfc_yf4fuwo8lgkegw37iz646;
sdio_gnrl_dfflrs #(1, 1'h0) k6idvwkrs6j8ls5gnlp4f1m5qw(k2ogwl2ngc28we234fq8hkp9le8o,m5jo2r2r9tzn17kkst83n4jh6m,ef5yjaawinoxce_xggomjkxf0p,ri2ziyy,r46kf);
  wire [1-1:0]         eaddj21gurebwqfo33x1zspa;
  wire                 narpskuukpcgob8gsb1lvdfl87zixx = kz96koy5ft;
  wire [1-1:0]         bwni6z7sfru9wo7sipj228z7r_1w905 = rs8qfdkpko8pq[26];
  wire [1-1:0]         s0xqo0p4m26qiy_ise8p8elyt = bwni6z7sfru9wo7sipj228z7r_1w905;
sdio_gnrl_dfflrs #(1, 1'h1) swg__i9ls21kngk8ebszgff3ohk(narpskuukpcgob8gsb1lvdfl87zixx,s0xqo0p4m26qiy_ise8p8elyt,eaddj21gurebwqfo33x1zspa,ri2ziyy,r46kf);
  wire [4-1:0]         hun9o0d_ret2nstu49i_i5osagauz53j853y;
  wire                 ztwj01kggige5gic_1btmojhvg3luj5x1xd_ = kz96koy5ft;
  wire [4-1:0]         we91ixqf95o310xhgudj76_bcbtmg_3xr69vx3a7b9 = rs8qfdkpko8pq[31:28];
  wire [4-1:0]         ritcwiv0f6c1a0bhc92d65gwv7m8sc56otstv = we91ixqf95o310xhgudj76_bcbtmg_3xr69vx3a7b9;
sdio_gnrl_dfflrs #(4, 4'h7) j4helmn08izwi_g89t17g7ds5_f3x4hq_2(ztwj01kggige5gic_1btmojhvg3luj5x1xd_,ritcwiv0f6c1a0bhc92d65gwv7m8sc56otstv,hun9o0d_ret2nstu49i_i5osagauz53j853y,ri2ziyy,r46kf);
  wire uubocamtlw6i5fyr = btxjg7ygg8tk_7on ; 
  wire g9hrna4u7lmf29g = y1bj5jcmhudj7gqo ; 
  assign s6uti1uy9 = {
          hun9o0d_ret2nstu49i_i5osagauz53j853y
        , 1'b0
        , eaddj21gurebwqfo33x1zspa
        , ef5yjaawinoxce_xggomjkxf0p
        , y2x732cxadne6xgg9vruqu10od
        , w_pdamnrdftxjegttc8wv1lkvibhnpj
        , sr19n1ywngusphv0qtt4g
        , i2acefpb6petzagqjtmm26lzglsuiv
        , pmr6rnu4bz89cj749j5
        , 3'b0
        , 3'b0
        , ivghamr_q4qmprhv5flpwt1  
        , kv62_zxdvs2nv307wdnxd4
        , yfqgbimrsj5l6s9ecw98e_eqw8yje  
        , pyu4xu841np25aop47ie8cmv8  
        , gq7mlwgi0yt6rp6u4vo0to2r2a2w  
        , yg09pjci8qewnp36k37xnthpdpql5
        , dzyzpj4yl8lxbruw8i  
        , kk6k5_uvu6wehm2ogwazdh9e72mqbfn_
        , f200vubhpxhpqidkhz9nr
        , cr5vd7zl0cq9aq9crq46mhkd7e
        , szgdb329qlilzw_ecd
        , zcpxgi771i6padzmneu
    };
  assign d538tqnpwv5nxljp33ioggy53kljin = hun9o0d_ret2nstu49i_i5osagauz53j853y;
  wire [32-1:0]        m1wr2mcidxaejr9mf;
  wire [32-1:0]        s25249txi5adh1x55mnk58;
  wire [32-1:0]        qnn26zm92a2plx423qccwhajumrpji;
  wire                 tgcmqbp36f0x433814r9z03uccqzl74 = bdq7su86rywal0icxiu;
  wire [32-1:0]        x8gqkpyghhu1q4jq6unhvawib04yxo6ko4y2xeqb = rs8qfdkpko8pq;
  wire [32-1:0]        cwyukl0u5eglcogrroz681o_vcpi3fxa = x8gqkpyghhu1q4jq6unhvawib04yxo6ko4y2xeqb;
sdio_gnrl_dfflrs #(32, 32'h0) b3jbbiudpm7lc_su26rjht12wgx2(tgcmqbp36f0x433814r9z03uccqzl74,cwyukl0u5eglcogrroz681o_vcpi3fxa,qnn26zm92a2plx423qccwhajumrpji,ri2ziyy,r46kf);
  wire [32-1:0]        njov3wdls7aoja56lp_yx;
  wire                 t63x28aoiz0u4p2e4byw = j7s2wofqhm79843;
  wire [32-1:0]        ntpo625dd4ps6jw8q8chgtgjmk = rs8qfdkpko8pq;
  wire [32-1:0]        vw3lp82dn2apkv70ssbv9cr7p = ntpo625dd4ps6jw8q8chgtgjmk;
sdio_gnrl_dfflrs #(32, 32'h0) mc439sn8hrzb_ncfctwu(t63x28aoiz0u4p2e4byw,vw3lp82dn2apkv70ssbv9cr7p,njov3wdls7aoja56lp_yx,ri2ziyy,r46kf);
  assign m1wr2mcidxaejr9mf = njov3wdls7aoja56lp_yx;
  assign s25249txi5adh1x55mnk58 = qnn26zm92a2plx423qccwhajumrpji;
     wire [32-1:0]        a0ffw2r7vjkj4o;
     wire [32-1:0]        uwhvllzmp37xq3b90i;
     wire q6p_jiasjo5vu3c = aehb61u1do | yyorn42v7r0yxtj | plp0va3eyj;
     wire [15:0] gzsudkkux20;
     wire [15:0] v3if5w8h9_arx = plp0va3eyj ? (rs8qfdkpko8pq[1] ? 16'b0 : gzsudkkux20) : ax9vv3ea604fyn521 ;
sdio_gnrl_dfflr #(16) ey2dbj22nhaw8roxd (q6p_jiasjo5vu3c, v3if5w8h9_arx, gzsudkkux20, ri2ziyy, r46kf);
     wire [6-1:0] iykzx8fq69d59a0__kor23ccs0rrv4eu9u = gzsudkkux20[13:8];
     wire [6-1:0] f9o6hfjydv5e0iq9cc1ukuogh0b3obud = gzsudkkux20[5:0];
     wire ekcsc5j6fdnjnnn7001nx8;
     wire j075fvm6de = yyorn42v7r0yxtj | plp0va3eyj;
     wire ca9e_8jj9m = plp0va3eyj ? (rs8qfdkpko8pq[0] ? 1'b0 : ekcsc5j6fdnjnnn7001nx8) : 1'b1 ;
sdio_gnrl_dfflr #(1) n2y9ro7c7 (j075fvm6de, ca9e_8jj9m, ekcsc5j6fdnjnnn7001nx8, ri2ziyy, r46kf);
     wire phlajsmjyz1noz9egpj;
     wire mq5e5jx9c3e = aehb61u1do | plp0va3eyj;
     wire inn7weulk = plp0va3eyj ? (rs8qfdkpko8pq[1] ? 1'b0 : phlajsmjyz1noz9egpj) : 1'b1 ;
sdio_gnrl_dfflr #(1) l_k43pi8jl0ib8 (mq5e5jx9c3e, inn7weulk, phlajsmjyz1noz9egpj, ri2ziyy, r46kf);
     wire xzj3oyhzl00xb422_9beetsxtv;
     wire mnt2sxnfrdm8klwulv = usa73t6hje0c | plp0va3eyj;
     wire d8vz7ovjhpag2lcryc5 = plp0va3eyj ? (rs8qfdkpko8pq[2] ? 1'b0 : xzj3oyhzl00xb422_9beetsxtv) : 1'b1 ;
sdio_gnrl_dfflr #(1) qdb9zvleynw48kslp8e (mnt2sxnfrdm8klwulv, d8vz7ovjhpag2lcryc5, xzj3oyhzl00xb422_9beetsxtv, ri2ziyy, r46kf);
     wire m1s0uyksystkkl3u1ytf2jd4;
     wire lbgebtqe4ge3fo12 = bt949sros6 | plp0va3eyj;
     wire s0wcmywg58x4zmgdzj = plp0va3eyj ? (rs8qfdkpko8pq[3] ? 1'b0 : m1s0uyksystkkl3u1ytf2jd4) : 1'b1 ;
sdio_gnrl_dfflr #(1) jyuss3sjtgvzp279xo4q (lbgebtqe4ge3fo12, s0wcmywg58x4zmgdzj, m1s0uyksystkkl3u1ytf2jd4, ri2ziyy, r46kf);
     wire oboc_osn163j1zg82hj_gbu8h;
     wire b6pf4gp_eg0vzv = i8z0n9wj94uk6 | plp0va3eyj;
     wire d0d8ly7rwm5_w3gym = plp0va3eyj ? (rs8qfdkpko8pq[4] ? 1'b0 : oboc_osn163j1zg82hj_gbu8h) : 1'b1 ;
sdio_gnrl_dfflr #(1) bspj2dy4zfl1bv_a91zru (b6pf4gp_eg0vzv, d0d8ly7rwm5_w3gym, oboc_osn163j1zg82hj_gbu8h, ri2ziyy, r46kf);
     wire u8u7w6r9o9svogos6amfqdavo;
     wire fmk9fvzb2q5yua = cd4cglo9i | plp0va3eyj;
     wire ry0ziytdvuxdm = plp0va3eyj ? (rs8qfdkpko8pq[5] ? 1'b0 : u8u7w6r9o9svogos6amfqdavo) : 1'b1 ;
sdio_gnrl_dfflr #(1) xqyq4aby4vmt1mior9wk (fmk9fvzb2q5yua, ry0ziytdvuxdm, u8u7w6r9o9svogos6amfqdavo, ri2ziyy, r46kf);
     wire am1owukx5oeohwvt1lb9wq = (~eenfsp7uc) 
                             ;
     wire yv4bnbga9lu;
sdio_gnrl_dffr #(1) s6yve4o7k8r2gobiz_o (eenfsp7uc, yv4bnbga9lu, ri2ziyy, r46kf);
     assign qg9cxb3j66gdphvucf = (~yv4bnbga9lu) & eenfsp7uc;
     wire zisw4ai3xxf8k5pdu68mj4bk9ujq7l007;
     wire ap_zcagra7ehvecizwody;
sdio_gnrl_dffr #(1) p12l9602ni2nyfz_3kwsgzov (itzmb3pv762occb74z2bqy, ap_zcagra7ehvecizwody, ri2ziyy, r46kf);
     wire i983klw0fbqp66p85nzbi4f2a9 = (~itzmb3pv762occb74z2bqy) & ap_zcagra7ehvecizwody;
     wire b3yyc8rzilpy88lygmi65lb6 = i983klw0fbqp66p85nzbi4f2a9 | plp0va3eyj & rs8qfdkpko8pq[7] & (~zisw4ai3xxf8k5pdu68mj4bk9ujq7l007);
     wire c56laf33pq26tig10gkv = (plp0va3eyj & rs8qfdkpko8pq[7]) ? 1'b1 
                              : i983klw0fbqp66p85nzbi4f2a9 ? 1'b0 
                              : zisw4ai3xxf8k5pdu68mj4bk9ujq7l007
                              ;
sdio_gnrl_dfflr #(1) u8p4ocao_5o0xv_oqfb8y (b3yyc8rzilpy88lygmi65lb6, c56laf33pq26tig10gkv, zisw4ai3xxf8k5pdu68mj4bk9ujq7l007, ri2ziyy, r46kf);
     wire ophdmx6rgllgtimfzmdiw9oo;
     wire ararke2utnify1f = cou6jkjrtkyb | plp0va3eyj;
     wire yu61fsisv7g62 = plp0va3eyj ? (rs8qfdkpko8pq[8] ? 1'b0 : ophdmx6rgllgtimfzmdiw9oo) : 1'b1 ;
sdio_gnrl_dfflr #(1) chv2p1kk3s5lumes8zj6 (ararke2utnify1f, yu61fsisv7g62, ophdmx6rgllgtimfzmdiw9oo, ri2ziyy, r46kf);
     assign rg_d619o1c7drrtakc = (plp0va3eyj & rs8qfdkpko8pq[7]);
     assign agra657i0o0nz9 = plp0va3eyj & rs8qfdkpko8pq[0];
     wire hnq631msdt1f_tf26idtnq_1_iv6f4 = a6azftdcm48ofiwjze7i7rh;
     wire [15:0] r187zambvfcmugmsdyvgh5d1 = h_p_v40ojzhzuo;
     wire zkgo818ss1kf2l9ra1ppkojxxw;
     wire ahmx_dtg377ld1h = l57u_ksc8__zzlul 
                         | plp0va3eyj 
                         ;
     wire foprlo3vhav3py667l7 = plp0va3eyj ? (rs8qfdkpko8pq[9] ? 1'b0 : zkgo818ss1kf2l9ra1ppkojxxw) : 1'b1 ;
sdio_gnrl_dfflr #(1) f1777silzht8s6pzs9x1w (ahmx_dtg377ld1h, foprlo3vhav3py667l7, zkgo818ss1kf2l9ra1ppkojxxw, ri2ziyy, r46kf);
     wire mdipve6tb8kg72cge40a7y2p0;
     wire b1ergyt2lv4e_vj7 = (qg9cxb3j66gdphvucf | plp0va3eyj) & ivghamr_q4qmprhv5flpwt1;
     wire aifr6bh07ocqiiqs = plp0va3eyj ? (rs8qfdkpko8pq[10] ? 1'b0 : mdipve6tb8kg72cge40a7y2p0) : 1'b1 ;
sdio_gnrl_dfflr #(1) zy7ofmds2_rx996qjbb (b1ergyt2lv4e_vj7, aifr6bh07ocqiiqs, mdipve6tb8kg72cge40a7y2p0, ri2ziyy, r46kf);
     wire okg0mqj8qsnz5vbwob64ikwh3q7r445bd;
     wire mrcp1tpzzrjy8zdqpfw1vhcjlb6uwe0oq51kq = whgnw4j8j3otscuqla9_a | plp0va3eyj;
     wire ogz5xqan0lr5d76o1u9mji8zx1ehcnfewj2w = plp0va3eyj ? (rs8qfdkpko8pq[11] ? 1'b0 : okg0mqj8qsnz5vbwob64ikwh3q7r445bd) : whgnw4j8j3otscuqla9_a;
sdio_gnrl_dfflr #(1) rnkupu25am5idxmcwwv2_l6ehw1yhukp5p0vxk0be (mrcp1tpzzrjy8zdqpfw1vhcjlb6uwe0oq51kq, ogz5xqan0lr5d76o1u9mji8zx1ehcnfewj2w, okg0mqj8qsnz5vbwob64ikwh3q7r445bd, ri2ziyy, r46kf);
     wire jgfdvop3bs0lvdf21h1x6thxu9xjir27tr;
     wire xgzx6ixc93gkj1r4hmqhzy5tsdx9axhthuowqqn = gul39dz5oevi7of2cvluw | plp0va3eyj;
     wire pkyx4zrze4gqs6uqxcilbxvwau3pcmzvxdnf0e = plp0va3eyj ? (rs8qfdkpko8pq[12] ? 1'b0 : jgfdvop3bs0lvdf21h1x6thxu9xjir27tr) : gul39dz5oevi7of2cvluw;
sdio_gnrl_dfflr #(1) x53ekyeqhyuemkdj_druvbr5p8r820lvcvbkf577o (xgzx6ixc93gkj1r4hmqhzy5tsdx9axhthuowqqn, pkyx4zrze4gqs6uqxcilbxvwau3pcmzvxdnf0e, jgfdvop3bs0lvdf21h1x6thxu9xjir27tr, ri2ziyy, r46kf);
     wire f4rj9a8s6hy7n6jt3qtyhvqxy6q;
     wire hosmbomi7bwcjulehn6v6nt6ea3umxk = uubocamtlw6i5fyr | plp0va3eyj;
     wire ep3727ztwst5b5pa0_bjqqfodzv6zt96 = plp0va3eyj ? (rs8qfdkpko8pq[13] ? 1'b0 : f4rj9a8s6hy7n6jt3qtyhvqxy6q) : uubocamtlw6i5fyr;
sdio_gnrl_dfflr #(1) bfs2_5jthvlgbhbbqx1wc754mi_w9w46eci (hosmbomi7bwcjulehn6v6nt6ea3umxk, ep3727ztwst5b5pa0_bjqqfodzv6zt96, f4rj9a8s6hy7n6jt3qtyhvqxy6q, ri2ziyy, r46kf);
     wire cjp325sucbhukdo8od0vlo7lfmd1l;
     wire im_ymosfmgk6bdeo_3ch0mvm7pghlbf = g9hrna4u7lmf29g | plp0va3eyj;
     wire rucd3ul06d7wb5xijow4rmr1f1z90kanqf = plp0va3eyj ? (rs8qfdkpko8pq[14] ? 1'b0 : cjp325sucbhukdo8od0vlo7lfmd1l) : g9hrna4u7lmf29g;
sdio_gnrl_dfflr #(1) t9f7476gy53evu9eow904d_0rh12imk9sj6s (im_ymosfmgk6bdeo_3ch0mvm7pghlbf, rucd3ul06d7wb5xijow4rmr1f1z90kanqf, cjp325sucbhukdo8od0vlo7lfmd1l, ri2ziyy, r46kf);
     wire j90nam3gxnohzatqy392bzym72k;
     wire amm6ze19nv9zw4ytf26o2ze4tq6 = plp0va3eyj;
     wire x3zk5t757jkx2_bp4ms3n3d7h6c = rs8qfdkpko8pq[31];
sdio_gnrl_dfflrs #(1) sx4jryhtw4jkik1c36hhorriafuuajd1wa (amm6ze19nv9zw4ytf26o2ze4tq6, x3zk5t757jkx2_bp4ms3n3d7h6c, j90nam3gxnohzatqy392bzym72k, ri2ziyy, r46kf);
     wire x79v22m4kqwuhui3uullhzee5emll3ukz;
     wire sndkwfj4cmqk_9xrxkmp7aocxabc2qghui = plp0va3eyj | i2acefpb6petzagqjtmm26lzglsuiv & x5xpw_q76_9x1xhfigf0kjk4us | qp9h30vaen11e7md63axaci6y89y;
     wire k4kf8oaik306y_3kglwy__cf5gsdsfesrnfaiy = plp0va3eyj ? (rs8qfdkpko8pq[22] ? 1'b0 : x79v22m4kqwuhui3uullhzee5emll3ukz) 
                                             : qp9h30vaen11e7md63axaci6y89y ? 1'b0
                                             : 1'b1;
sdio_gnrl_dfflr #(1) z0hdt8kh1f4rv8_3sc5xatjfssots2iztieipypr (sndkwfj4cmqk_9xrxkmp7aocxabc2qghui, k4kf8oaik306y_3kglwy__cf5gsdsfesrnfaiy, x79v22m4kqwuhui3uullhzee5emll3ukz, ri2ziyy, r46kf);
     wire ox43wf4uf9owc6x4xz8o47rov0 = (~e92f6_ec7b7);
  assign a0ffw2r7vjkj4o = {
          j90nam3gxnohzatqy392bzym72k
        , hnq631msdt1f_tf26idtnq_1_iv6f4
        , iykzx8fq69d59a0__kor23ccs0rrv4eu9u
        , 1'b0
        , x79v22m4kqwuhui3uullhzee5emll3ukz
        , f9o6hfjydv5e0iq9cc1ukuogh0b3obud
        , ox43wf4uf9owc6x4xz8o47rov0
        , cjp325sucbhukdo8od0vlo7lfmd1l
        , f4rj9a8s6hy7n6jt3qtyhvqxy6q
        , jgfdvop3bs0lvdf21h1x6thxu9xjir27tr
        , okg0mqj8qsnz5vbwob64ikwh3q7r445bd
        , mdipve6tb8kg72cge40a7y2p0
        , zkgo818ss1kf2l9ra1ppkojxxw
        , ophdmx6rgllgtimfzmdiw9oo
        , zisw4ai3xxf8k5pdu68mj4bk9ujq7l007
        , am1owukx5oeohwvt1lb9wq
        , u8u7w6r9o9svogos6amfqdavo
        , oboc_osn163j1zg82hj_gbu8h
        , m1s0uyksystkkl3u1ytf2jd4
        , xzj3oyhzl00xb422_9beetsxtv
        , phlajsmjyz1noz9egpj
        , ekcsc5j6fdnjnnn7001nx8
    };
  assign guy4snzyohyiz = j90nam3gxnohzatqy392bzym72k;
  assign uwhvllzmp37xq3b90i = {
       6'h0
     ,10'b0
     , r187zambvfcmugmsdyvgh5d1
      };
  wire [32-1:0]        i2dndr_nt_pb9gcvvk24a;
  wire [6-1:0]         lkt0ft5v8s0di0xlfjgccyr1kya;
  wire                 fz54zntz_12cp6huiuoadu107xiokhqo = fi60kj1uo9wvongk;
  wire [6-1:0]         ps822bs8qk7ehu7n7bqwi9r2iqn6xcaun = rs8qfdkpko8pq[13:8];
  wire [6-1:0]         ijo0s79dmghh8yrtobaomz0lwfn_cydr = ps822bs8qk7ehu7n7bqwi9r2iqn6xcaun;
sdio_gnrl_dfflrs #(6, 6'h0) py0ewad0dehmh2gb97ctf97uvwgb(fz54zntz_12cp6huiuoadu107xiokhqo,ijo0s79dmghh8yrtobaomz0lwfn_cydr,lkt0ft5v8s0di0xlfjgccyr1kya,ri2ziyy,r46kf);
  wire [1-1:0]         tvbf6y5w5n4394bl9db2ec_ky64tjamxzfme6;
  wire                 wa21xi1kpxn5bjndercx4fn3ln23wspogi2mry7j = fi60kj1uo9wvongk;
  wire [1-1:0]         mwwh3_axpsikxagd879cx7t5me5zvnuzdaunjnfgjpehnjay = rs8qfdkpko8pq[5:5];
  wire [1-1:0]         gxu3frvf04e2wqwl5daodh9rh1vrtq9x3px6caxfycs8 = mwwh3_axpsikxagd879cx7t5me5zvnuzdaunjnfgjpehnjay;
sdio_gnrl_dfflrs #(1, 1'h0) q_hbmi_4unvrlugmj6fun37s9fedzftsak0gsu(wa21xi1kpxn5bjndercx4fn3ln23wspogi2mry7j,gxu3frvf04e2wqwl5daodh9rh1vrtq9x3px6caxfycs8,tvbf6y5w5n4394bl9db2ec_ky64tjamxzfme6,ri2ziyy,r46kf);
  wire [1-1:0]         na_f71k9spp80ubs224vv_tyyi9zvlmwmpt;
  wire                 tis72i3p6g5ar927j67nlpx3zowrvuxy8tlc = fi60kj1uo9wvongk;
  wire [1-1:0]         lzuhz0a0o9kokxpufim1xt6iautgzzgucq9yv6jwf = rs8qfdkpko8pq[4:4];
  wire [1-1:0]         bbrly6r24f7kt6xabn2dr5vmv4sshf3xz6e_c = lzuhz0a0o9kokxpufim1xt6iautgzzgucq9yv6jwf;
sdio_gnrl_dfflrs #(1, 1'h0) lp93yo3h16npc631u8qm5snn9txy_guy84cs(tis72i3p6g5ar927j67nlpx3zowrvuxy8tlc,bbrly6r24f7kt6xabn2dr5vmv4sshf3xz6e_c,na_f71k9spp80ubs224vv_tyyi9zvlmwmpt,ri2ziyy,r46kf);
  wire [1-1:0]         go7v9rnplfgdte4h5qswq1t8yeh_pna;
  wire                 foz6ekqcv5c291wteklgjbofa_xie1n0y = fi60kj1uo9wvongk;
  wire [1-1:0]         gmiuxelm7hpwl2o1ijdk7864a2f3qfm97uc8hb0pm = rs8qfdkpko8pq[3:3];
  wire [1-1:0]         gcbs1jhhwk39o3ynq3btr_5ctp34a51x4 = gmiuxelm7hpwl2o1ijdk7864a2f3qfm97uc8hb0pm;
sdio_gnrl_dfflrs #(1, 1'h0) tdfupbeuhh2y050xn27a06fhg3xpq3(foz6ekqcv5c291wteklgjbofa_xie1n0y,gcbs1jhhwk39o3ynq3btr_5ctp34a51x4,go7v9rnplfgdte4h5qswq1t8yeh_pna,ri2ziyy,r46kf);
  wire [1-1:0]         djb69z8femqpx5f8ydagxvjh7ebq9xt;
  wire                 u0bdo97woe0y2t7klphf_4wtwl5ms9 = fi60kj1uo9wvongk;
  wire [1-1:0]         unizprskpzy36do9336r00p07rodzeujfa7p = rs8qfdkpko8pq[2:2];
  wire [1-1:0]         pqh1c1klhib865lrmch4l8r_ujebuuu7d = unizprskpzy36do9336r00p07rodzeujfa7p;
sdio_gnrl_dfflrs #(1, 1'h0) h39k6kn6_piwq7y1ngnd0yk_kn8jp(u0bdo97woe0y2t7klphf_4wtwl5ms9,pqh1c1klhib865lrmch4l8r_ujebuuu7d,djb69z8femqpx5f8ydagxvjh7ebq9xt,ri2ziyy,r46kf);
  wire [1-1:0]         gvzqp5frx5pf4ljos0ny843095qqfxv0a1;
  wire                 jjpmhb56llje_r21jqusq8qsdp1njcu5 = fi60kj1uo9wvongk;
  wire [1-1:0]         iwg7mbqf15rjkvf1yuhbn17tfyoih306cpe4m393 = rs8qfdkpko8pq[1:1];
  wire [1-1:0]         vpqzcasdce0yqsgzmu9kv6wnpc1j1hqzcc = iwg7mbqf15rjkvf1yuhbn17tfyoih306cpe4m393;
sdio_gnrl_dfflrs #(1, 1'h0) vr8dn977ba8f5y4kttnpqn_d75q8m6v8dw(jjpmhb56llje_r21jqusq8qsdp1njcu5,vpqzcasdce0yqsgzmu9kv6wnpc1j1hqzcc,gvzqp5frx5pf4ljos0ny843095qqfxv0a1,ri2ziyy,r46kf);
  wire [1-1:0]         ag8_d9n33gnyrevbw6ytg6s4f4u7nb3ltg;
  wire                 wc3n99cfnnzcp_b9v8i2h7izk9sx9v290l = fi60kj1uo9wvongk;
  wire [1-1:0]         ykzmrxng05sd9ca4c_syqimw0l35i4drde7aio9bb0s = rs8qfdkpko8pq[0:0];
  wire [1-1:0]         g0hnjwntcbrw_y9ap5uz6ppt1do3ubjtkj = ykzmrxng05sd9ca4c_syqimw0l35i4drde7aio9bb0s;
sdio_gnrl_dfflrs #(1, 1'h0) ohk5reagbzy7rz5kp77lu026d5n7izz(wc3n99cfnnzcp_b9v8i2h7izk9sx9v290l,g0hnjwntcbrw_y9ap5uz6ppt1do3ubjtkj,ag8_d9n33gnyrevbw6ytg6s4f4u7nb3ltg,ri2ziyy,r46kf);
  assign i2dndr_nt_pb9gcvvk24a = {
          18'd0
        , lkt0ft5v8s0di0xlfjgccyr1kya
        , 2'd0
        , tvbf6y5w5n4394bl9db2ec_ky64tjamxzfme6
        , na_f71k9spp80ubs224vv_tyyi9zvlmwmpt
        , go7v9rnplfgdte4h5qswq1t8yeh_pna
        , djb69z8femqpx5f8ydagxvjh7ebq9xt
        , gvzqp5frx5pf4ljos0ny843095qqfxv0a1
        , ag8_d9n33gnyrevbw6ytg6s4f4u7nb3ltg
    };
  wire [32-1:0]        dlwipakzr0lq521kydb9yhj;
  wire [32-1:0]        klwoyavac774l7r50g533n_9j0qwvdhf;
  wire                 pqg_pfv92hwxhg28r9u54fogkzowg5zdnm = vbgtfsllw9j5iqi20bny;
  wire [32-1:0]        hk_09q9ufwms_jpkd7lv0l0gi_2lw6wlzf4hcd1 = rs8qfdkpko8pq[31:0];
  wire [32-1:0]        sh0wdjtca2xsaeojzq2odx2chgq1nw9 = hk_09q9ufwms_jpkd7lv0l0gi_2lw6wlzf4hcd1;
sdio_gnrl_dfflrs #(32, 32'h0) p7v_r6hljikqy_b5ni88147nxsjnfu(pqg_pfv92hwxhg28r9u54fogkzowg5zdnm,sh0wdjtca2xsaeojzq2odx2chgq1nw9,klwoyavac774l7r50g533n_9j0qwvdhf,ri2ziyy,r46kf);
  assign dlwipakzr0lq521kydb9yhj = {
          klwoyavac774l7r50g533n_9j0qwvdhf
    };
  wire [32-1:0]        fw1pc27m6evun0x2;
  wire [uwrgm1oivt1de06hok-1:0]         wn7tq2n48ihkly7veb42ly;
  wire                 gm_5y6g9zbgpqr_0azczun9jf68_e = a20riat423bwt;
  wire [uwrgm1oivt1de06hok-1:0]         v29pcjamc8bq3obsymzbv_f3ckpla3gdtv = rs8qfdkpko8pq[uwrgm1oivt1de06hok-1:0];
  wire [uwrgm1oivt1de06hok-1:0]         lkb7_p7bnl0cbd9ffckvt5d2y7orx = v29pcjamc8bq3obsymzbv_f3ckpla3gdtv;
sdio_gnrl_dfflrs #(uwrgm1oivt1de06hok, 0) iwsznpsww0mvxwox4vp1yuz7s5c(gm_5y6g9zbgpqr_0azczun9jf68_e,lkb7_p7bnl0cbd9ffckvt5d2y7orx,wn7tq2n48ihkly7veb42ly,ri2ziyy,r46kf);
  assign fw1pc27m6evun0x2 = {
          {32-uwrgm1oivt1de06hok{1'b0}}
        , wn7tq2n48ihkly7veb42ly
    };
  wire [32-1:0]        hj0uham8kg5bve_;
  wire [uwrgm1oivt1de06hok-1:0]         snybo25ygfhmm5thw13fh_2rvh;
  wire                 hbq9oemw12voqj78w3a4_9gw7 = fj0phumlwof4;
  wire [uwrgm1oivt1de06hok-1:0]         g_jpoolvjjt6zo_3kaew6brqjwxhul9 = rs8qfdkpko8pq[uwrgm1oivt1de06hok-1:0];
  wire [uwrgm1oivt1de06hok-1:0]         z1bchjbi8r7lqifryt32b5tef = g_jpoolvjjt6zo_3kaew6brqjwxhul9;
sdio_gnrl_dfflrs #(uwrgm1oivt1de06hok, 0) cmuiiz3fggm5_6wlb_4g7nk(hbq9oemw12voqj78w3a4_9gw7,z1bchjbi8r7lqifryt32b5tef,snybo25ygfhmm5thw13fh_2rvh,ri2ziyy,r46kf);
  assign hj0uham8kg5bve_ = {
          {32-uwrgm1oivt1de06hok{1'b0}}
        , snybo25ygfhmm5thw13fh_2rvh
    };
  wire [32-1:0]        i_nmnba24fb2in;
  wire gaq8kka6y = (wn7tq2n48ihkly7veb42ly > rennjjy_nc) ;
  wire uml7j8 = (snybo25ygfhmm5thw13fh_2rvh < je8cka) ;
  wire q6su8nexrhihn39d9ga11 = ~tas51wt1y2anvic5x ;
  wire k_4b5_r1m5daepyt26  = ~fo4edb6fq0rlivyj;
  wire [1-1:0]         rez7fdfqru5pykmtxd8_ha = k_4b5_r1m5daepyt26;
  wire [1-1:0]         xja_i5jylpm1_j6ii1a = q6su8nexrhihn39d9ga11;
  wire [1-1:0]         c9z0m_p87h0_ftdj15 = cb88v39q9jwt3pvnrr;
  wire [1-1:0]         bhdjusthn7ujk3usika = qn6b671v_v_entk63c2t;
  wire [1-1:0]         fw2oe2lv9dkr2uqz9 = uml7j8;
  wire [1-1:0]         kfwjgo_gypemyq_uuxd5 = gaq8kka6y;
  assign i_nmnba24fb2in = {
          22'd0
        , 4'b0
        , bhdjusthn7ujk3usika
        , c9z0m_p87h0_ftdj15
        , rez7fdfqru5pykmtxd8_ha
        , xja_i5jylpm1_j6ii1a
        , fw2oe2lv9dkr2uqz9
        , kfwjgo_gypemyq_uuxd5
    };
  wire [32-1:0]        uxfvfw7otzs3hp;
  wire [1-1:0]         t75ne0z5ytb7x2e9jqxczet2c5wlv;
  wire                 c54rp99yfulufvx6cdvtcigymbo46ya = sygtfc3m2o0;
  wire [1-1:0]         sp_f1g0kohll7x178id9f4c2iqt1rqafcmg_r1 = rs8qfdkpko8pq[14:14];
  wire [1-1:0]         rs2x3qgevitjfxb80zmkn8ovail7g7 = sp_f1g0kohll7x178id9f4c2iqt1rqafcmg_r1;
sdio_gnrl_dfflrs #(1, 1'h0) bmgvuxonp0d13hg_ptv00fatium(c54rp99yfulufvx6cdvtcigymbo46ya,rs2x3qgevitjfxb80zmkn8ovail7g7,t75ne0z5ytb7x2e9jqxczet2c5wlv,ri2ziyy,r46kf);
  wire [1-1:0]         xxv_aipeqfx24khmg3de4wrf7e;
  wire                 bgvzvxy2g8xnhk0cm42abztgsycucx9b = sygtfc3m2o0;
  wire [1-1:0]         f_xjgmdh09d42jgg05xopasncpb1na1_luven5 = rs8qfdkpko8pq[13:13];
  wire [1-1:0]         thkj2vm143k94c5_mrotg50ynmuiter = f_xjgmdh09d42jgg05xopasncpb1na1_luven5;
sdio_gnrl_dfflrs #(1, 1'h0) iqy4nipxa9_khf_a0s6ivua6y9(bgvzvxy2g8xnhk0cm42abztgsycucx9b,thkj2vm143k94c5_mrotg50ynmuiter,xxv_aipeqfx24khmg3de4wrf7e,ri2ziyy,r46kf);
  wire [1-1:0]         s_ff23ze49iwerntwqxbxv6j4upa9ox4;
  wire                 vjlyo_oy7wzlsevzv_2u3whaq3v3a4l58nc36dq = sygtfc3m2o0;
  wire [1-1:0]         e3jml_1p29u0lpt7cx5gdlljqlyzsjfepv4o961ugb = rs8qfdkpko8pq[12:12];
  wire [1-1:0]         acanl88o6ei0m_ve_rg7s29d8hymzbwcdp6 = e3jml_1p29u0lpt7cx5gdlljqlyzsjfepv4o961ugb;
sdio_gnrl_dfflrs #(1, 1'h0) tg_6e39yjiha_2eb8mr3it12oiin801bju0(vjlyo_oy7wzlsevzv_2u3whaq3v3a4l58nc36dq,acanl88o6ei0m_ve_rg7s29d8hymzbwcdp6,s_ff23ze49iwerntwqxbxv6j4upa9ox4,ri2ziyy,r46kf);
  wire [1-1:0]         itffpek45_uc1yfwtst00znf_j_6q3yu;
  wire                 n1rbjgs5lzj4bsi7hywxo3586gj6k5j7n_1jw = sygtfc3m2o0;
  wire [1-1:0]         o57ytmlkiqhuhkpma_tq8oa2kh22vm7yx41n2288u6_ = rs8qfdkpko8pq[11:11];
  wire [1-1:0]         dgub47d2nmos_zis9_skhhv22m7llzi09q = o57ytmlkiqhuhkpma_tq8oa2kh22vm7yx41n2288u6_;
sdio_gnrl_dfflrs #(1, 1'h0) n3iqcb1mjb0_f_y5xnkaqyikyd4751jxr(n1rbjgs5lzj4bsi7hywxo3586gj6k5j7n_1jw,dgub47d2nmos_zis9_skhhv22m7llzi09q,itffpek45_uc1yfwtst00znf_j_6q3yu,ri2ziyy,r46kf);
  wire [1-1:0]         eliq5fmhd2lc97pzjjmws8i9c6h;
  wire                 ub7wil2q8we86jw5fphogyjtw7xlr = sygtfc3m2o0;
  wire [1-1:0]         v5260ie9227oz1l8n4jaatphj2dcxnol6 = rs8qfdkpko8pq[10:10];
  wire [1-1:0]         le7e06juhuzo8vt2678h4x7eg1_6g = v5260ie9227oz1l8n4jaatphj2dcxnol6;
sdio_gnrl_dfflrs #(1, 1'h0) oztr6udz8ch4k9t9a3_m468io(ub7wil2q8we86jw5fphogyjtw7xlr,le7e06juhuzo8vt2678h4x7eg1_6g,eliq5fmhd2lc97pzjjmws8i9c6h,ri2ziyy,r46kf);
  wire [1-1:0]         a5woh71a18o42ppyamymfegf1dtz;
  wire                 lal1a7aa7qxhemo2b180q_jfv = sygtfc3m2o0;
  wire [1-1:0]         thurrwemghj12g97hgjsq0zz3x7v89t3pg = rs8qfdkpko8pq[9:9];
  wire [1-1:0]         vhxoqtrmctytu7xd2xvyj4uq3wjz = thurrwemghj12g97hgjsq0zz3x7v89t3pg;
sdio_gnrl_dfflrs #(1, 1'h0) yulrjkfmmrbe0h8mr8b6w2mkxq(lal1a7aa7qxhemo2b180q_jfv,vhxoqtrmctytu7xd2xvyj4uq3wjz,a5woh71a18o42ppyamymfegf1dtz,ri2ziyy,r46kf);
  wire [1-1:0]         mbrrlevdjb10e8ncyn39ijh;
  wire                 lv73vts93q9609enc1ccy2ozuudyr = sygtfc3m2o0;
  wire [1-1:0]         we3by47vdq8vqz6pb7td26hh5p7_254 = rs8qfdkpko8pq[8:8];
  wire [1-1:0]         v1q1egkzbtq5u_hw31vfvo1_8 = we3by47vdq8vqz6pb7td26hh5p7_254;
sdio_gnrl_dfflrs #(1, 1'h0) xj9feyj6jfdqbnunj56rlbfrlva(lv73vts93q9609enc1ccy2ozuudyr,v1q1egkzbtq5u_hw31vfvo1_8,mbrrlevdjb10e8ncyn39ijh,ri2ziyy,r46kf);
  wire [1-1:0]         j9a7ptchsoiwmitxoaxkbt9zpr;
  wire                 newdhin0ngriy_kj4o4z_z56y = sygtfc3m2o0;
  wire [1-1:0]         plj1fylqlybff7cbq3bt0q_72k0js8fcr = rs8qfdkpko8pq[7:7];
  wire [1-1:0]         uwa2gmjw5tv0hhaymrms4k8qn8 = plj1fylqlybff7cbq3bt0q_72k0js8fcr;
sdio_gnrl_dfflrs #(1, 1'h0) w4ze75_fccq632m18za6xv1ff(newdhin0ngriy_kj4o4z_z56y,uwa2gmjw5tv0hhaymrms4k8qn8,j9a7ptchsoiwmitxoaxkbt9zpr,ri2ziyy,r46kf);
  wire [1-1:0]         v_m5s7nj_iy7umxkrj5i1_2nfm;
  wire                 abe5t3zex_ykhoubhpedw86gw_iq = sygtfc3m2o0;
  wire [1-1:0]         wchzaf1i4aee9dvnwcv6hilk_67nza9sw = rs8qfdkpko8pq[6:6];
  wire [1-1:0]         rots46l8vruw3rkj67eg52s_ = wchzaf1i4aee9dvnwcv6hilk_67nza9sw;
sdio_gnrl_dfflrs #(1, 1'h0) nz1l1g_eu4cy22o6kvlruqfue(abe5t3zex_ykhoubhpedw86gw_iq,rots46l8vruw3rkj67eg52s_,v_m5s7nj_iy7umxkrj5i1_2nfm,ri2ziyy,r46kf);
  wire [1-1:0]         owqlyv4q9l5154fd1s4kw3t1b;
  wire                 uoj_j3vkdq6urc0xo5c69wihpls = sygtfc3m2o0;
  wire [1-1:0]         oxa9wkuvncr7lfotmmpzsapsob3mu3v6 = rs8qfdkpko8pq[5:5];
  wire [1-1:0]         nzv_vq05bsznbdu7vukricc49 = oxa9wkuvncr7lfotmmpzsapsob3mu3v6;
sdio_gnrl_dfflrs #(1, 1'h0) poyji4bid3ad6kcq2b3c7l5f(uoj_j3vkdq6urc0xo5c69wihpls,nzv_vq05bsznbdu7vukricc49,owqlyv4q9l5154fd1s4kw3t1b,ri2ziyy,r46kf);
  wire [1-1:0]         pfh7z_7z4k3d93srls96aaxfqhg;
  wire                 vc8f4vo2zcs59hweb0_c61ltzb0i9 = sygtfc3m2o0;
  wire [1-1:0]         tg9zebkzi8g00z3jfxa5n8eg37dqiq = rs8qfdkpko8pq[4:4];
  wire [1-1:0]         myv6zgu04_tokx39v62b96f5 = tg9zebkzi8g00z3jfxa5n8eg37dqiq;
sdio_gnrl_dfflrs #(1, 1'h0) ac7tu3y7e08fgnijho5azt(vc8f4vo2zcs59hweb0_c61ltzb0i9,myv6zgu04_tokx39v62b96f5,pfh7z_7z4k3d93srls96aaxfqhg,ri2ziyy,r46kf);
  wire [1-1:0]         d7njar7_7iwnqtptj35dvao;
  wire                 pjxyz7ivw5p5s3dolb0a6wif = sygtfc3m2o0;
  wire [1-1:0]         um9r03x6lckeje31r9u3k0zjrba328 = rs8qfdkpko8pq[3:3];
  wire [1-1:0]         d1t1gntrc9tie80w13htfv7 = um9r03x6lckeje31r9u3k0zjrba328;
sdio_gnrl_dfflrs #(1, 1'h0) pnwe12bgc77enip50mmc0mrrw(pjxyz7ivw5p5s3dolb0a6wif,d1t1gntrc9tie80w13htfv7,d7njar7_7iwnqtptj35dvao,ri2ziyy,r46kf);
  wire [1-1:0]         iezaics9162o391jab3bl;
  wire                 r8wdq_kwquax7ubhkvlf2z8ek = sygtfc3m2o0;
  wire [1-1:0]         c79o2djov67ldv6ywqnfdagp4vppndtks = rs8qfdkpko8pq[2:2];
  wire [1-1:0]         btlv264dvyn9kt99megj9kau01 = c79o2djov67ldv6ywqnfdagp4vppndtks;
sdio_gnrl_dfflrs #(1, 1'h0) mpps7x8gegegsk91n7ov(r8wdq_kwquax7ubhkvlf2z8ek,btlv264dvyn9kt99megj9kau01,iezaics9162o391jab3bl,ri2ziyy,r46kf);
  wire [1-1:0]         pl9kcxxl7_ra56dq3xd;
  wire                 x02fu2rnoflt_gfjdszdsy9_ = sygtfc3m2o0;
  wire [1-1:0]         u7lya6fody7c3_2dkgl58_x0wv_opn6 = rs8qfdkpko8pq[1:1];
  wire [1-1:0]         a9kc4xxec8l21tat38t_e1 = u7lya6fody7c3_2dkgl58_x0wv_opn6;
sdio_gnrl_dfflrs #(1, 1'h0) w8lcq3wvo8thox1sldylo_ft(x02fu2rnoflt_gfjdszdsy9_,a9kc4xxec8l21tat38t_e1,pl9kcxxl7_ra56dq3xd,ri2ziyy,r46kf);
  wire [1-1:0]         hrtn_8pn7as_360h1ap_tiy7;
  wire                 zz012bfq07x1hx32c0wowsbkx = sygtfc3m2o0;
  wire [1-1:0]         aalh6kdae7wyo4yp4lgqmznxyc37y0 = rs8qfdkpko8pq[0:0];
  wire [1-1:0]         bjmfgkz48kqvn4dur7p_e = aalh6kdae7wyo4yp4lgqmznxyc37y0;
sdio_gnrl_dfflrs #(1, 1'h0) x6jv7bips8a8urv3r0m(zz012bfq07x1hx32c0wowsbkx,bjmfgkz48kqvn4dur7p_e,hrtn_8pn7as_360h1ap_tiy7,ri2ziyy,r46kf);
  assign uxfvfw7otzs3hp = {
          13'd0
        , 4'b0
        , t75ne0z5ytb7x2e9jqxczet2c5wlv
        , xxv_aipeqfx24khmg3de4wrf7e
        , s_ff23ze49iwerntwqxbxv6j4upa9ox4
        , itffpek45_uc1yfwtst00znf_j_6q3yu
        , eliq5fmhd2lc97pzjjmws8i9c6h
        , a5woh71a18o42ppyamymfegf1dtz
        , mbrrlevdjb10e8ncyn39ijh 
        , j9a7ptchsoiwmitxoaxkbt9zpr
        , v_m5s7nj_iy7umxkrj5i1_2nfm
        , owqlyv4q9l5154fd1s4kw3t1b
        , pfh7z_7z4k3d93srls96aaxfqhg
        , d7njar7_7iwnqtptj35dvao
        , iezaics9162o391jab3bl
        , pl9kcxxl7_ra56dq3xd
        , hrtn_8pn7as_360h1ap_tiy7
    };
  wire [32-1:0]        m28_rw8s7wyx;
  wire [32-1:0]        xr79fxf5dqu911e8 =  l199zjdlz5zp4wxl3g[31:0];
  assign m28_rw8s7wyx = {
          xr79fxf5dqu911e8
    };
  wire [32-1:0]        cmwcu6v0tudbw;
  wire [32-1:0]        loh9mw6yxx0xz55ixo = l199zjdlz5zp4wxl3g[63:32];
  assign cmwcu6v0tudbw = {
          loh9mw6yxx0xz55ixo
    };
  wire [32-1:0]        azr3vg8xmz8;
  wire [32-1:0]        aaxwiud3vqwsxphxdp0r = l199zjdlz5zp4wxl3g[95:64];
  assign azr3vg8xmz8 = {
          aaxwiud3vqwsxphxdp0r
    };
  wire [32-1:0]        ci1iarufh30;
  wire [32-1:0]        tu0_i8zm6t6s74ax4 = l199zjdlz5zp4wxl3g[127:96];
  assign ci1iarufh30 = {
          tu0_i8zm6t6s74ax4
    };
  wire [32-1:0]        p6x9nsk62p5_re9248k;
  wire [32-1:0]        z_3qv9tbac1taglxrprtuupoz4cyn =  rpx40ivicuzwht_yj9s[31:0];
  assign p6x9nsk62p5_re9248k = {
          z_3qv9tbac1taglxrprtuupoz4cyn
    };
  wire [32-1:0]        sphy8htns1nimhscuh;
  wire [32-1:0]        r_69q068b1iivcdzfo5id8nc3xhlpw = rpx40ivicuzwht_yj9s[63:32];
  assign sphy8htns1nimhscuh = {
          r_69q068b1iivcdzfo5id8nc3xhlpw
    };
  wire [32-1:0]        nerqorv2mfq43_kg491;
  wire [32-1:0]        w9ltrdao7psl67ja7pe4u8yqng0 = rpx40ivicuzwht_yj9s[95:64];
  assign nerqorv2mfq43_kg491 = {
          w9ltrdao7psl67ja7pe4u8yqng0
    };
  wire [32-1:0]        lgmkumjuhnw5rgge;
  wire [32-1:0]        g_nmy8ghgnur5ark8nmsb1jdck62_g6 = rpx40ivicuzwht_yj9s[127:96];
  assign lgmkumjuhnw5rgge = {
          g_nmy8ghgnur5ark8nmsb1jdck62_g6
    };
  wire [32-1:0]        i4f7nuefng5zky0wrklvr2yabp4;
  wire [32-1:0]        cbk0owqxox5daqvz1ncqvhyirhz9t48rievg54omf_yqj;
  wire                 s9bnif40tdfmm5gkrfoylkj3kfn82azu0moz0p8153 = gzsx200c4jmw6xr2gvr;
  wire [32-1:0]        mha041sdobjnafe0fcu9phrrgvd10kgeyqg15sstr2vxf9li = rs8qfdkpko8pq[31:0];
  wire [32-1:0]        sb21w7psd2ii6t5aktb4edf82vcfkhkn5teloe7jyjs4t90 = mha041sdobjnafe0fcu9phrrgvd10kgeyqg15sstr2vxf9li;
sdio_gnrl_dfflrs #(32, 32'h7ff) mzh5azokx8g041v1edjwv2rdjar1vm12ty1bgp99fa(s9bnif40tdfmm5gkrfoylkj3kfn82azu0moz0p8153,sb21w7psd2ii6t5aktb4edf82vcfkhkn5teloe7jyjs4t90,cbk0owqxox5daqvz1ncqvhyirhz9t48rievg54omf_yqj,ri2ziyy,r46kf);
  assign i4f7nuefng5zky0wrklvr2yabp4 = {
           cbk0owqxox5daqvz1ncqvhyirhz9t48rievg54omf_yqj
    };
  assign g5ikzrx34od9pu8jyexvv = i4f7nuefng5zky0wrklvr2yabp4;
  wire [32-1:0]        j5hf9ajw8u4ppvpiurwznbi3sjn2w;
  wire [32-1:0]        d0alnmu3ho5pvydhf9wtoddtcv1pu2yn99cpgrkil8on;
  wire                 adt28_kg0ndavg8g76pajg6agg06nclr0zsle45ax6tpr = grpt1u0dtlh9bep_dai_;
  wire [32-1:0]        ixjms5mtvdk74lemw3veo_mfckls77dukxydg1d7hgxhix33r1 = rs8qfdkpko8pq[31:0];
  wire [32-1:0]        vk2v9znsqo2le4k_vthpz34ftb7lpmcmcduxfb235_1b8ik_7 = ixjms5mtvdk74lemw3veo_mfckls77dukxydg1d7hgxhix33r1;
sdio_gnrl_dfflrs #(32, 32'h7) f4acuwak4bknqax19cs4v615htxta5o099qcaiqmfzfhf(adt28_kg0ndavg8g76pajg6agg06nclr0zsle45ax6tpr,vk2v9znsqo2le4k_vthpz34ftb7lpmcmcduxfb235_1b8ik_7,d0alnmu3ho5pvydhf9wtoddtcv1pu2yn99cpgrkil8on,ri2ziyy,r46kf);
  assign j5hf9ajw8u4ppvpiurwznbi3sjn2w = {
           d0alnmu3ho5pvydhf9wtoddtcv1pu2yn99cpgrkil8on
    };
  assign ileysv9olfjwrm_t236qmf0 = j5hf9ajw8u4ppvpiurwznbi3sjn2w;
  wire [32-1:0]        ohgu8mn_vspiuqqlp999w02n_jf;
  wire [16-1:0]        y5vvcmr8_20ch3b3rrrtl6lte25tj_z0crtb9jx6;
  wire                 bw157dpzl_i3peamio6c5rka0tazwp0_kfft5iqth49zo = r07hp2c_e3vcnfkqa17yae;
  wire [16-1:0]        cgnc3at7_0dps2jgk3uq69qw1jaofrybnkx9k2_l9aq936w = rs8qfdkpko8pq[15:0];
  wire [16-1:0]        xb15rvjz4mvl8khhkwntd5xjy7e5c0xy7hhf6wcl = cgnc3at7_0dps2jgk3uq69qw1jaofrybnkx9k2_l9aq936w;
sdio_gnrl_dfflrs #(16, 16'd73) ad_co70rmpkrc0o5g9gh0w7h9j0rx4y77zndorgnv4g(bw157dpzl_i3peamio6c5rka0tazwp0_kfft5iqth49zo,xb15rvjz4mvl8khhkwntd5xjy7e5c0xy7hhf6wcl,y5vvcmr8_20ch3b3rrrtl6lte25tj_z0crtb9jx6,ri2ziyy,r46kf);
  assign ohgu8mn_vspiuqqlp999w02n_jf = {
            16'h0
           ,y5vvcmr8_20ch3b3rrrtl6lte25tj_z0crtb9jx6
    };
  wire [32-1:0]        t5snizib42y7fm175rvkkvkgahe2;
  wire [16-1:0]        qgoq2_yuhmx8ljw9gs0vpexakb_wthgfqf0_xa2rfwsgbnb7u;
  wire                 ozkqdruli_ky3sypytz9bz2qu_sjzyq3q_dlc_m_00sfoy = zew3v_e569dcm5i6z6b737zy48;
  wire [16-1:0]        r9eystor_05744a22roa278adh_mmx4omifeytq24z2ibtzysaemsc9o = rs8qfdkpko8pq[15:0];
  wire [16-1:0]        czl8haty8xzjbkss76piwbnyaroth_l_ohdz9ngwu66658_9v = r9eystor_05744a22roa278adh_mmx4omifeytq24z2ibtzysaemsc9o;
sdio_gnrl_dfflrs #(16, 16'd32) ez_e5kxwe7vmegbkvo3ko6m6i56yqwnrc7ylt15ndzlc_2(ozkqdruli_ky3sypytz9bz2qu_sjzyq3q_dlc_m_00sfoy,czl8haty8xzjbkss76piwbnyaroth_l_ohdz9ngwu66658_9v,qgoq2_yuhmx8ljw9gs0vpexakb_wthgfqf0_xa2rfwsgbnb7u,ri2ziyy,r46kf);
  assign t5snizib42y7fm175rvkkvkgahe2 = {
            16'h0
           ,qgoq2_yuhmx8ljw9gs0vpexakb_wthgfqf0_xa2rfwsgbnb7u
    };
  assign wddz9ajtz98uzxa1y13_rd_6yf = t5snizib42y7fm175rvkkvkgahe2;
   wire [32-1:0]        qskfbhffgweit58b;
   wire [15:0] cl7oxcxsbzrz0xpq6ukqe1aq9uxj9_ = rg7ozwpk7xwi6vdbg8;
   wire [6:0] r4xq22zgo0drt_rimimnydsei5xex = st_xbxcknhpf[6:0];
   wire [6:0] a8s5j25tc6y01ul77hp0yapl4rfpolw_ = st_xbxcknhpf[14:8];
   assign qskfbhffgweit58b = {
        16'b0
       ,1'b0
       ,a8s5j25tc6y01ul77hp0yapl4rfpolw_
       ,1'b0
       ,r4xq22zgo0drt_rimimnydsei5xex
       };
  wire [32-1:0]        ybron14knwrtol_1nizrrn6sg_bm;
  wire [16-1:0]        pkhysdtqoh7lrph0ru7s6j14q1wjamsp3lo5z4uy1riq;
  wire                 ne5tt_sktoh4__qh_5auvtyjiylta4wdyfjbbc96s4z1ex2 = v3ls3hnvy1ret9gpeh9si;
  wire [16-1:0]        fo4u3tg69e1dqi301zr3ayhhc4ado_cr5l6lbifbypzdogzut = rs8qfdkpko8pq[15:0];
  wire [16-1:0]        z6fta5vyor8coqp0b2tdswjovnahsp2x8lqeknupbw = fo4u3tg69e1dqi301zr3ayhhc4ado_cr5l6lbifbypzdogzut;
sdio_gnrl_dfflrs #(16, 16'h64) q64ix85n0btyum3xl1lsr237_h4v33hm_gnzu72yl0(ne5tt_sktoh4__qh_5auvtyjiylta4wdyfjbbc96s4z1ex2,z6fta5vyor8coqp0b2tdswjovnahsp2x8lqeknupbw,pkhysdtqoh7lrph0ru7s6j14q1wjamsp3lo5z4uy1riq,ri2ziyy,r46kf);
  assign ybron14knwrtol_1nizrrn6sg_bm = {
            16'h0
           ,pkhysdtqoh7lrph0ru7s6j14q1wjamsp3lo5z4uy1riq
    };
  wire [32-1:0]        votzecs008ggcnhxhdgijqzg;
  wire [16-1:0]        m3t1b7h2p9etj74hp47oses0folb3eyaovurmyuw99k2w;
  wire                 eja9sexxe9x6vtdrodnj60zgws4bvq1nq5y_3m5lxe01u = hpq2zpk0ewnzb_83m08tnxi;
  wire [16-1:0]        sjdumqdw0opfsnim88296xad7finus_0umhazoym6gxzcavo0vo = rs8qfdkpko8pq[15:0];
  wire [16-1:0]        skt0mjd59ux65ayjhaibvdaw31at_hmjn0syz0ku25t = sjdumqdw0opfsnim88296xad7finus_0umhazoym6gxzcavo0vo;
sdio_gnrl_dfflrs #(16, 16'd16) ibzmmzlo53073opjlw69dse1x8au_3n__ng49nbj8(eja9sexxe9x6vtdrodnj60zgws4bvq1nq5y_3m5lxe01u,skt0mjd59ux65ayjhaibvdaw31at_hmjn0syz0ku25t,m3t1b7h2p9etj74hp47oses0folb3eyaovurmyuw99k2w,ri2ziyy,r46kf);
  assign votzecs008ggcnhxhdgijqzg = {
             16'h0
           , m3t1b7h2p9etj74hp47oses0folb3eyaovurmyuw99k2w
    };
  wire [32-1:0]        w341k8pblps1dr;
  wire [32-1:0]        h33cot_1pu7lc934t8phm5wkijhsl = w341k8pblps1dr;
  assign w341k8pblps1dr = 32'h00010300;
     assign x7kd6gw9z3nq                = gaq8kka6y                                 & uxfvfw7otzs3hp[0];
     assign h5fyr6xf                = uml7j8                                 & uxfvfw7otzs3hp[1];
     assign iydyd8j                   = ekcsc5j6fdnjnnn7001nx8                      & uxfvfw7otzs3hp[2];
     assign d_ud4rxc                   = phlajsmjyz1noz9egpj                    & uxfvfw7otzs3hp[3];
     assign a8ksd2cml1857c             = xzj3oyhzl00xb422_9beetsxtv                & uxfvfw7otzs3hp[4]; 
     assign h1zz0n82qird6             = m1s0uyksystkkl3u1ytf2jd4                & uxfvfw7otzs3hp[5]; 
     assign wkp4c4o8i9jz7qrr             = oboc_osn163j1zg82hj_gbu8h                & uxfvfw7otzs3hp[6]; 
     assign xgce667c9h1v9_2             = u8u7w6r9o9svogos6amfqdavo                & uxfvfw7otzs3hp[7]; 
     assign fmmfcow0bhw_n             = ophdmx6rgllgtimfzmdiw9oo                & uxfvfw7otzs3hp[8];
     assign t9h8f8az1xl6lnxb            = zkgo818ss1kf2l9ra1ppkojxxw               & uxfvfw7otzs3hp[9];
     assign bvwpeiqbd9vorm_z             = mdipve6tb8kg72cge40a7y2p0                & uxfvfw7otzs3hp[10];
     assign y95x5hdagddvs0pyu8wndgmosp   = okg0mqj8qsnz5vbwob64ikwh3q7r445bd      & uxfvfw7otzs3hp[11];
     assign sij8tpctkajmr03fg7gpam   = jgfdvop3bs0lvdf21h1x6thxu9xjir27tr      & uxfvfw7otzs3hp[12];
     assign ha5dwnleavf9avv             = f4rj9a8s6hy7n6jt3qtyhvqxy6q            & uxfvfw7otzs3hp[13];
     assign dus0b998jzvic             = cjp325sucbhukdo8od0vlo7lfmd1l            & uxfvfw7otzs3hp[14];
     assign b26mynubin8b_le            = je2x55k701gr08bfoc482es;
     assign pnqfvawpm88z_eyd           = nyoxu2m44nu2nkbbzg;
     assign kwy_caex2pniarrt90nhz      = ncpise_lhtm6tvdzh0[7:0];
     assign o9c9btcp91rsvpk0vspg        = lkt0ft5v8s0di0xlfjgccyr1kya;
     assign ckit4a72az0719r4043o       = dlwipakzr0lq521kydb9yhj;
     assign eceqrr444i1sfi27buo2zh9kd  = i2dndr_nt_pb9gcvvk24a[5:0];
     assign pj8yn_v__lbubab           = lz7fuv9koxgjowvppahdvx2mm;
     assign s9ca2h_c0vo3ir21          = lmsuxdrpwgbq_ffn68gq3z_kmwfmb;
     assign m6zj5v0w5_3ihev8i         = gi9gh0qxut770cc6cx31g12cnjs18ul;
     assign ex_g7yz76ioj6b3ga7izf99   = kra4ifr95fp92erbc4cgwat33_nmmy;
     assign wjpeqvmhl4olz7lwfq7ml    = yavjar3d4uc36d8f43mayprukbx;
     assign et608shl82a38k37n_tc        = zi67zxmuzonog3cbp5nme;
     assign qp0wn9ujlwcuhkd9yza         = plsj7z0kbwf3bzv0bne;
     assign ttye50jd2n0mdj429lscfjl      = njov3wdls7aoja56lp_yx;
     assign k7o146duw1l_7lhmiut_lcw    = qnn26zm92a2plx423qccwhajumrpji;
     assign q9v4i7v_w83ghvywxf         = kv62_zxdvs2nv307wdnxd4 ? 1'b1 : cr5vd7zl0cq9aq9crq46mhkd7e;
     assign coewl0jbxtbda4v              = f200vubhpxhpqidkhz9nr ;
     assign heo8n9249c37              = zcpxgi771i6padzmneu;
     assign g_4093g7113              = szgdb329qlilzw_ecd;
     assign rtjb59lqioc              = (dzyzpj4yl8lxbruw8i | i2acefpb6petzagqjtmm26lzglsuiv) & (~ys38rwd_zt9tnq402x0z329);
     assign d7pq3_iwww34lz9qrvnrj_sl90cb = kk6k5_uvu6wehm2ogwazdh9e72mqbfn_;
     assign goutmvirnojskgvv6amvi       = yg09pjci8qewnp36k37xnthpdpql5;
     assign spzm6_w92pynok5p4ar     = gq7mlwgi0yt6rp6u4vo0to2r2a2w;
     assign gsunngjkz0hnaqx2o644yb89hd   = yfqgbimrsj5l6s9ecw98e_eqw8yje; 
     assign dzey_2yh25ke6udi           = kv62_zxdvs2nv307wdnxd4; 
     assign hk5bt7sgcl_w            = ivghamr_q4qmprhv5flpwt1; 
     assign c_2t5bufod3tjs             = pyu4xu841np25aop47ie8cmv8;
     assign okiluofya4d              = pctk6hlgp8ia3ju86_kt_e0l;
     assign t72myhasn0g1ns            = sr19n1ywngusphv0qtt4g;
     assign agzf9f66rtwmzvpra          = y2x732cxadne6xgg9vruqu10od;
     assign rox3z1ajkb2vlfdt         = ef5yjaawinoxce_xggomjkxf0p;
     assign nbdjwtss8giqeaiucom         = eaddj21gurebwqfo33x1zspa;
     assign el90ghiy_pow7iut1mrhem   = i2acefpb6petzagqjtmm26lzglsuiv;
     assign vudvag_p2zmadu0             = pmr6rnu4bz89cj749j5;
     assign erlun2j0p7c9b3kgbw        = ys38rwd_zt9tnq402x0z329;
     assign spk75u9zmwe9atpcj           = jvzrvaou7xom;
     wire [32-1:0]        eu_1ql6n95jcleeuqiv49s = rs8qfdkpko8pq;
     wire [32-1:0]        lh0vm7jdncfpsu0e;
     assign lh0vm7jdncfpsu0e = {
          eu_1ql6n95jcleeuqiv49s
     };
     assign p4j35gwurjv5  = lh0vm7jdncfpsu0e;
     assign ze1nmdpmvow7c319 = q460cud4856td_;
     wire [32-1:0]        ukjgz7kqewb0hqw5l;
     wire [32-1:0]        gxyghz80slh1li2kouhvi0ad = cnppfcsxxqf4urcv;
  assign ukjgz7kqewb0hqw5l = {
          gxyghz80slh1li2kouhvi0ad
    };
    assign  i5obq0coq3_dxi8wgp5w  = ohgu8mn_vspiuqqlp999w02n_jf[15:0] ;
    assign  b8qdnc0532plw6lmf_7s3 = ybron14knwrtol_1nizrrn6sg_bm[15:0] ;
    assign  h2y116axdf7diunbyy = votzecs008ggcnhxhdgijqzg [15:0] ;
     wire [32-1:0] mq9n48gbif_cl6qzi = 32'h0
                                  | ({32{pk4lrizee}} & m28_rw8s7wyx)
                                  | ({32{du9fbnanx}} & cmwcu6v0tudbw)
                                  | ({32{x0ny6afk}} & azr3vg8xmz8)
                                  | ({32{ay978dvig35x}} & ci1iarufh30)
                                  | ({32{iaxt4x3cyikrdm0da}} & p6x9nsk62p5_re9248k)
                                  | ({32{qze5at76xag1d57zmj}} & sphy8htns1nimhscuh)
                                  | ({32{ffda94zy23za0is}} & nerqorv2mfq43_kg491)
                                  | ({32{het97c6elsen1x3my}} & lgmkumjuhnw5rgge)
                                  | ({32{ns71s_h1arj51j0}} & m1wr2mcidxaejr9mf)
                                  | ({32{clo3ojypopfg6b7l}} & s25249txi5adh1x55mnk58)
                                  | ({32{gycr9rhq2wxb8u}} & a0ffw2r7vjkj4o)
                                  | ({32{bs6sek5p6dik}} & uwhvllzmp37xq3b90i)
                                  | ({32{a3puvtnq5wbdk4}} & fw1pc27m6evun0x2)
                                  | ({32{i_nd0555vsxzsp}} & hj0uham8kg5bve_)
                                  | ({32{ny8phs1bi}} & s6uti1uy9)
                                  | ({32{jvzrvaou7xom}} & ukjgz7kqewb0hqw5l)
                                  | ({32{awuf0prl0}} & i_nmnba24fb2in)
                                  | ({32{suibpsy}} & uxfvfw7otzs3hp)
                                  | ({32{qg44og_9jqwl9}} &  ncpise_lhtm6tvdzh0 )
                                  | ({32{x1q_uufiiahbkfow}} &  sku9z5p3py2_tin7fsp2 )
                                  | ({32{fbnq2d411owbgs3w8}} & i2dndr_nt_pb9gcvvk24a)
                                  | ({32{m75nun5ea70t}} & nyoxu2m44nu2nkbbzg)
                                  | ({32{p10_eoo5l3yu504u_n46}} & dlwipakzr0lq521kydb9yhj)
                                  | ({32{qtvwxz99lftmvmgu}} & whkl3p5gqgw86sfyg)
                                  | ({32{c2csj4kv58cr34idqdu}} & i4f7nuefng5zky0wrklvr2yabp4)
                                  | ({32{rq5avpvkufugu627ns2zmy}} & ohgu8mn_vspiuqqlp999w02n_jf)
                                  | ({32{duek7dmj7gxiaitoenhjpeqvt}} & votzecs008ggcnhxhdgijqzg)
                                  | ({32{xa9jj252_vrz65hqrqozri}} & ybron14knwrtol_1nizrrn6sg_bm)
                                  | ({32{b13s2mzlnmq07uqmfmhn}} & j5hf9ajw8u4ppvpiurwznbi3sjn2w)
                                  | ({32{mqkny29e4a7yg}} & w341k8pblps1dr)
                                  | ({32{gint0i47ztn1ca1wrckke690onv}} & t5snizib42y7fm175rvkkvkgahe2)
                                  | ({32{x_bvo8ix9gl0kjdxxh}} & qskfbhffgweit58b)
                                  ;
  wire ob8z8livyemha710u ;
  wire kskb11shhtzrtgvpid4sm ;
  wire [32-1:0] t3ry9gk2ep_3qyfvsrb9u;
  sdio_gnrl_pipe_stage # (
    .CUT_READY (0),
    .DP  (1),
    .DW  (32)
  ) q4sadjz19m_7tbgm9_vyvfu (
    .i_vld(mxwg8lfgv4pge1),
    .i_rdy(qi_euczbjhgo1za),
    .i_dat(mq9n48gbif_cl6qzi ),
    .o_vld(ob8z8livyemha710u),
    .o_rdy(kskb11shhtzrtgvpid4sm),  
    .o_dat(t3ry9gk2ep_3qyfvsrb9u ),  
    .clk  (ri2ziyy),
    .rst_n(r46kf)
  );
  assign l_geblczxuwi5x4e = ob8z8livyemha710u;
  assign kskb11shhtzrtgvpid4sm = ptdklfwbs2d13;
  assign nuvz1doibyin1uaa = t3ry9gk2ep_3qyfvsrb9u;
endmodule
module ioxpnqbc7aqwqrifv (
    input              mxwg8lfgv4pge1                 ,
  output             qi_euczbjhgo1za                 ,
  input              mqxw6of2d4b4nr7b                   ,
  input              cuu3goyrnwc9hf                  ,
  input  [  11:   0] t3lk20ui52aqc6                  ,
  input  [  31:   0] rs8qfdkpko8pq                 ,
  input  [   3:   0] swwpvt6gm3cz8                 ,
  input  [   2:   0] pccr2d0febxqx                  ,
  input              vah0tsdviw4b                  ,
  input              u7u7t6iaofiovjc                  ,
  input  [   7:   0] xwpttmbn8xqi2b0qg                  ,
  input  [   1:   0] j7onlxu8c84rohjl3                ,
  input  [   1:   0] abuhy0_a307fr_734f                 ,
  input              xi4mxnyfh8q6pd2                 ,
  input  [   2:   0] le80uwswd0y0q8                 ,
  input  [   1:   0] p5nleje0lb8ux                  ,
  input              ptdklfwbs2d13                 ,
  output             l_geblczxuwi5x4e                 ,
  output             r1ukfidrb_5kvibw                   ,
  output             nhup3xqrnngwbqsg_e               ,
  output [  31:   0] nuvz1doibyin1uaa                 ,
  input              faqpcbe4751rx                  ,
  output             es2eisdm0qu3                  ,
  output             wkwscugp5re                    ,
  output             ce4q39qw2gn0                   ,
  input              j0ymi3se1vtv                  ,
  output             ula1fsl673girmu                  ,
  output             jy8f6iovbm                    ,
  output             aoofou61a0iq                   ,
  input              s35jhrn02ch4omla86m                ,
  output             agxndvfnxt1lq3nz                ,
  output             f649ftjq8dd47v7s                  ,
  output             pc2xuy_fyjus3                 ,
  input              ipatp60owfx8c9                ,
  output             kiypykzrw_fdhxb                ,
  output             hvblb8fnvykeisty                  ,
  output             loao5ar4y59i7dy                 ,
  input              axf_lvtru_gky2vx                ,
  output             y0ifgrg4j8xe1z_e                ,
  output             y_utkzr29tc_rjqx9                  ,
  output             utnb83_6j8sa_k                 ,
  input              dkndzqtx29xy_gey8p                ,
  output             mj4c7hhslgsjy9bt                ,
  output             i6573hvtpcm16                  ,
  output             zxmk7fbbwufsu2wy8                 ,
  input              esqkfu_ee6jfpik74y                ,
  output             drlefxcf3_j2lppdm_                ,
  output             va0j6og_ll80oj                  ,
  output             dy2liyrkkic1u                 ,
  input              s3x0920mp6a8e_k7xox                ,
  output             pm30xgj2vj2smr71b1u                ,
  output             j8qu4ksipdiygyj2r                  ,
  output             tyd569koo37unwhw                 ,
  input              hkmux_qq6fgq58j                ,
  output             gfb43rrs4k_3sx1jaka                ,
  output             crxkbbsftdo8e                  ,
  output             cbb6qt91iz4rzait2                 ,
  input              biaikjakr36558d                ,
  output             m0kao6qjv0umm2ulcgd                ,
  output             a56yiaqw9t1t0                  ,
  output             x5o1z7p1fq7zycs                 ,
  input              ri2ziyy                           ,
  input              r46kf                         ,
  input              x9t4ls4jmm                      ,
  input              nhmow92ziyrfc2                  ,
  output             c_6y8qe_ucl                      
);
 localparam  uwrgm1oivt1de06hok = 6;
 wire dlmwxsha8xcd;
sdio_gnrl_dffr #(1) drwuiauphh4u2ro79w (1'b1, dlmwxsha8xcd, ri2ziyy, r46kf);
 wire jesyol8j2mzc9p7rg;
 wire n3w802chksaybtkdgd_xl = mxwg8lfgv4pge1 & dlmwxsha8xcd;
 assign qi_euczbjhgo1za = jesyol8j2mzc9p7rg & dlmwxsha8xcd;
  wire        ct51mag5yve9;
  wire        vfoa34j_u2mi;
  wire        yhhl9de6pqf;
  wire        f_tcdutrmtyh;
  wire  [7:0] wm7w9dybdwy;
  wire  [7:0] q3v56zbk1;
  wire  [7:0] j5lpulyyl0y6tq;
   wire   [31:0]  txti0f6fk82008m;
   wire   [31:0]  iss4yfb4_08lnvg4qsr;
   wire           md6qdskpzh9gx_tp1km;
   wire           t3jn32i_lctw1bd0kuq;
   wire   [31:0]  vk906z_iuoaj;
   wire           fcdvc3nlqjhmitd3116;
   wire           p52gwjhx63ijx2e66yn5;
   wire   [31:0]  ez5d43vnbev4mi;
   wire           txhjs9q2krxvsv_1yvj8vad;
   wire           z88hfe5nfr43v3h6mjyze_i;
   wire   [31:0]  c3j4v_pcrpv3m0lujizizmc;
   wire           il4xl25n7maairf0po8r_xftz;
   wire           vpdt0vvzutz6wgrezzyx6;
   wire           oy_xqe59adc18av0t3a9043o8dh;
   wire           qzxedrzvtc1jidr_7ly19yw2k;
   wire           vlex3ee1x3uffk5dcob691grer;
   wire           jx3zf3w25k79245e5thoxhw3g;
   wire   [31:0]  eylfh9om1fgq1c;
   wire           dsdgq_1fvdgiek6lf;
   wire           pmhvdyh26y2x4531o;
   wire   [31:0]  l7r8z49kpgjp3;
   wire           tv84ye8hrmdye0wv;
   wire           spwra0niad0la30fev0c;
   wire   [31:0]  dc87mz60m;
   wire           th4v1fn833whmi9d;
   wire           cm9fjjf3g82yprv1d;
   wire   [31:0]  c2x4ec82bjq;
   wire           l0wy6y5ntv2khk_k;
   wire           hfxw5o3cith07p8o;
   wire     [5:0] a8vrqhuhofxl;
   wire    [31:0] tv7jhpskh;
   wire     [7:0] pe7npxqli2dhiy;
   wire     [5:0] uw36v64wbbn3iguh0;
   wire    [31:0] m4v_yf_kn5rznb;
   wire     [5:0] n657wtw4ds5a48mh29o69q;
   wire   [127:0] n3ybvlkmy0vbdp;
   wire   [127:0] ne19nr14x8ucikuk;
   wire           n_vl1e1u80;
   wire           f2fd9vp2pz8a;
   wire     [1:0] uc8m2ukpnka;
   wire     [11:0] kdz9fii4gxcf8nmmsr;
   wire     [15:0]s28u06kqhlkryua_;
   wire           qqxbkscdbj;
   wire           arqwpvp2psfdjvi;
   wire  [uwrgm1oivt1de06hok:0] rennjjy_nc;
   wire  [uwrgm1oivt1de06hok:0] je8cka;
   wire    [15:0] zgkty0kh1op3;
   wire           j4_qlu0mlj4;
   wire           lr3gatfqora7khzh0hp;
   wire           fl5q6cvqdw5ri17nn;
   wire           ee6ptp9j2vinoog44_6g;
   wire           ssifydbti49zjmzo_ef;
   wire           o9yjinw;
   wire           ix00rwky4;
   wire           z8d6aggc6t;
   wire           si3iliqaji;
   wire           ep81qennkfss;
   wire     [31:0]xe52lwmjkncnkgwar;
   wire           mjpt9;
   wire           ij002p9rged2ak_;
   wire           wznckfxx0g1;
   wire           kz9brlabiztcoo6;
   wire           ttlx0bb8pnknhrf9r;
   wire           embfqomp0b7xixzq;
   wire           uj77n6yj56es04lr4u;
   wire  [31:0]   snj91rw_6s2lav_y3;
   wire           xs2f3mdds5djz0c;
   wire           omxhwmgnjlbq5i;
   wire           vvr14_h_p5m;
   wire           cbbe8bxfq7vw7ehz;
   wire           rsc8sznfqmdd76r;
   wire           pffv2ox53j123l25fg;
   wire           didovdkh7z;
   wire           q7ms2svxkcnk37a;
   wire           idlm74clk0r_;
   wire           efox5ltvv4azm;
   wire           q0jkim6j1pr0sbq;
   wire           kjrt0vjvn ;
   wire           i71y4eae ;
   wire           kffimtdq ;
   wire x7kd6gw9z3nq;
   wire h5fyr6xf;
   wire d_ud4rxc;
   wire iydyd8j;
   wire ylweqzg4l2;
   wire wiyfxtmib7;
   wire ug_op0zbnc25ditffl;
   wire q0hhzjkzymizlouesuxy613;
   wire ioq4xf2u0hg2;
   wire lke7scx_kt96j2;
   wire agra657i0o0nz9;
   wire gxdn5d1rcg00ydm7_u_;
   wire fhzqgozhq1pyh2151h;
   wire n_0gc1jrwbwbesrc8890l;
   wire xc7kofn0twnf2_s4mn3dhb04iki;
   wire j1fgrs1bp6t8do4_o257aq11;
   wire v6lppuzeqzopbd9;
   wire qh_q1y_m1f ;
   wire g6j4godv7g7i5wza;
   wire wwoo3chlfik ;
   wire e4ml3nl9vqtyqoqli9 ;
   wire kp1y3g0y0vn__ ;
   wire [31:0] g5ikzrx34od9pu8jyexvv;
   wire [31:0] ileysv9olfjwrm_t236qmf0;
   wire  [15:0] sm_q4lw3biyezjpcwh;
   wire  [15:0] xxp4yei2ow6k19vagc;
   wire  [15:0] y525w_27oa4xjncj0o8e;
   wire         vdo68osi5psq1rn0;
   wire [15:0] rg7ozwpk7xwi6vdbg8;
   wire [15:0] st_xbxcknhpf;
   wire [31:0] wddz9ajtz98uzxa1y13_rd_6yf;
   wire v47faz8hre6oocgu6rhbgs;
   wire uzopx8pyez3fomb3nq; 
   wire [9:0] rvm_9mbg6;
   wire  usa73t6hje0c ; 
   wire  bt949sros6 ; 
   wire  i8z0n9wj94uk6 ; 
   wire  cd4cglo9i ; 
   wire  cou6jkjrtkyb ; 
   wire  gjo8v81xeh28v2e ; 
   wire  x_kf5c8jqsasp80m7dj ; 
   wire  a8ksd2cml1857c ; 
   wire  h1zz0n82qird6 ; 
   wire  wkp4c4o8i9jz7qrr ; 
   wire  xgce667c9h1v9_2 ; 
   wire  fmmfcow0bhw_n ; 
   wire  t9h8f8az1xl6lnxb ; 
   wire  bvwpeiqbd9vorm_z ;
   wire  v26pk2xgtez1;
   wire  wofz2exuh798h;
   wire  cttbrwkd2ba10dq7;
   wire  fk6on7eodq4jlrhg1;
   wire  kakm8d3jlxyfilzjo68;
   wire  ng3v7afmxhngxxz;
   wire  gww0vhmdwv29174u8xm;
   wire [3:0] o6obdgtij2wgjkulvk_av836v9nc7a;
   wire [1:0] ai1wz5k_jiipo;
   wire  pcgnqquxcq831qurodoqn9pd7;
   wire  d4sah1mq1xosh6pfz5fl;
   wire [1:0] nmme9ivahrxd6dt;
   wire  zg5sg41vdk6x0fw7pc5lqa59j;
   wire  j1g0igyehdyfyzioxv2_y7md;
   wire  ws0w4rks5wvu;
   wire  oqzel76vp9p245nf;
   wire itzmb3pv762occb74z2bqy;
   wire  l66187bdmpw7glyepwt0xngma;
   wire  y83hwd_mqfdc4jh24c;
   wire  q3ma3m63h11toilhcdx;
   wire  ejw7oi93ww9le1xickgr_;
   wire  cge6m9pk6bphk1h; 
   wire  qgek6hz5rfs6m;
   wire  j3rwka8z1juhdw;
   wire  q1e2zddumw8;
   wire  ziear5bore7x2;
   wire  lmv6pr9gghsx_q5a6;
   wire  nrrkt63zg9dcb66a;
   wire cpdh57_xi982sd8a3pfmut5b;
   wire x5xpw_q76_9x1xhfigf0kjk4us;
    wire l8v1f1cqfu9t1ogms1fbh_e;
  sdio_gnrl_sync #(.DP(2),.DW(1)) jglpjbbt_toli7gtk9q0xv5k7brh (gww0vhmdwv29174u8xm, l8v1f1cqfu9t1ogms1fbh_e,qgek6hz5rfs6m,x9t4ls4jmm);
  wire d2w7_h66f_zuwh; 
  sdio_gnrl_sync #(.DP(2),.DW(1)) k_cb9lc0e3p97109j31_ (wwoo3chlfik, e4ml3nl9vqtyqoqli9,qgek6hz5rfs6m,x9t4ls4jmm);
  sdio_gnrl_sync #(.DP(2),.DW(1)) plrz5im4xgzsevl (q3v56zbk1[1], q3ma3m63h11toilhcdx,qgek6hz5rfs6m,x9t4ls4jmm);
sdio_gnrl_dffr #(1) ghfh821chhe4hz5 (q3ma3m63h11toilhcdx, ejw7oi93ww9le1xickgr_ ,x9t4ls4jmm ,qgek6hz5rfs6m);
  sdio_gnrl_sync #(.DP(2),.DW(1)) e8z2ymof003w52bo (q3v56zbk1[0], y83hwd_mqfdc4jh24c,r46kf,ri2ziyy);
  sdio_reset_sync #( .RST_SYNC_LEVEL(2))  sdio_reset_sync ( .clk(x9t4ls4jmm), .rst_n_a(r46kf), .reset_bypass(nhmow92ziyrfc2), .rst_n_sync(qgek6hz5rfs6m));
   wire k9z_szx16sqg1mee_2yely;
   wire vp8naci04rzo3r_uvuxz = gxdn5d1rcg00ydm7_u_;
   wire jffak_c03udmniw4weg = j1fgrs1bp6t8do4_o257aq11;
   wire y03ajt1r8ikxhlvvwwq3 = vp8naci04rzo3r_uvuxz | jffak_c03udmniw4weg;
   wire flybgy_dph15b9p9nrwcjycj = (~jffak_c03udmniw4weg);
sdio_gnrl_dfflr #(1) pncs7cugb_42_0ztilqjh (y03ajt1r8ikxhlvvwwq3, flybgy_dph15b9p9nrwcjycj, k9z_szx16sqg1mee_2yely, ri2ziyy, r46kf);
   wire q5q74je8loqjwae85tvzef5sra3;
   wire bb7lpc8dq9rvtxt7csf31v7b = fhzqgozhq1pyh2151h;
   wire hmt9wfbjxe7lb6_4hdu2_bsh = xc7kofn0twnf2_s4mn3dhb04iki;
   wire twv70lsl3jwy_r52p_7tbba4191re = bb7lpc8dq9rvtxt7csf31v7b | hmt9wfbjxe7lb6_4hdu2_bsh;
   wire klsdozdaseg9553_dui9hdijbsq = (~hmt9wfbjxe7lb6_4hdu2_bsh);
sdio_gnrl_dfflr #(1) lds_0nfmpml6gn_841qjj8jcyn0a (twv70lsl3jwy_r52p_7tbba4191re, klsdozdaseg9553_dui9hdijbsq, q5q74je8loqjwae85tvzef5sra3, x9t4ls4jmm, qgek6hz5rfs6m);
   wire o5ngg6gwnc3dlji8rm5evfrrpmtz1ef0y;
   wire r9fq4jtv79twmptc3ad2vdkqfnf1xl72 = (~q5q74je8loqjwae85tvzef5sra3) & qgek6hz5rfs6m;
   sdio_hand_mux ph0wpo5j3dwoljw_i45e9vj (.X(o5ngg6gwnc3dlji8rm5evfrrpmtz1ef0y), .S(nhmow92ziyrfc2), .D0(r9fq4jtv79twmptc3ad2vdkqfnf1xl72), .D1(qgek6hz5rfs6m));
   wire dhlvy3009fvslc1rmrt_gkfnszx;
   wire ut0nye6hqvl4ub3gr50fpbf_02 = (~k9z_szx16sqg1mee_2yely)
                                   & r46kf;
   sdio_hand_mux gl5ohdo4y3ju47n86jwmbq_rh (.X(dhlvy3009fvslc1rmrt_gkfnszx), .S(nhmow92ziyrfc2), .D0(ut0nye6hqvl4ub3gr50fpbf_02), .D1(r46kf));
   wire v99hxfa9chjlmu_gq52ee612frp3n;
   wire wkk0fu0z_9clw4mt67gsrp4iv99ew = (~k9z_szx16sqg1mee_2yely) & r46kf ;
   sdio_hand_mux mpbrlepsu0xn64h2ntol65_y8 (.X(v99hxfa9chjlmu_gq52ee612frp3n), .S(nhmow92ziyrfc2), .D0(wkk0fu0z_9clw4mt67gsrp4iv99ew), .D1(r46kf));
   assign itzmb3pv762occb74z2bqy = k9z_szx16sqg1mee_2yely 
                            ;
   wire tjqw5ktk41ttiyvdvwp ;
   wire a5t5cky26qdmnu = 
                        qgek6hz5rfs6m 
                       ;
   sdio_hand_mux cb1ng6wrzaiif3i7z0fsvx (.X(tjqw5ktk41ttiyvdvwp), .S(nhmow92ziyrfc2), .D0(a5t5cky26qdmnu), .D1(qgek6hz5rfs6m));
   wire e3x0z3h7wur1zw91ra24qxlv;
  sdio_reset_sync #( .RST_SYNC_LEVEL(2))  v1oa0yij6_8h7cdfx9fketcofg_ ( .clk(x9t4ls4jmm), .rst_n_a(tjqw5ktk41ttiyvdvwp), .reset_bypass(nhmow92ziyrfc2), .rst_n_sync(e3x0z3h7wur1zw91ra24qxlv));
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     mixbl1hik3pk9nz3z5o
     (
     .i_clk   (ri2ziyy),
     .i_rst_n (r46kf),
     .i_pulse (o9yjinw),
     .i_active(),
     .o_active(),
     .o_clk   (x9t4ls4jmm),
     .o_rst_n (qgek6hz5rfs6m),
     .o_pulse (z8d6aggc6t)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     s7cdpuwvqup41rdj1
     (
     .i_clk   (ri2ziyy),
     .i_rst_n (r46kf),
     .i_pulse (ix00rwky4),
     .i_active(),
     .o_active(),
     .o_clk   (x9t4ls4jmm),
     .o_rst_n (qgek6hz5rfs6m),
     .o_pulse (si3iliqaji)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     rd37k7ifcwidt2kcn0
     (
     .i_clk   (ri2ziyy),
     .i_rst_n (r46kf),
     .i_pulse (agra657i0o0nz9),
     .i_active(),
     .o_active(),
     .o_clk   (x9t4ls4jmm),
     .o_rst_n (qgek6hz5rfs6m),
     .o_pulse (v6lppuzeqzopbd9)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     rmkps1zmzsunvfrgs6_ti4s7njs
     (
     .i_clk   (ri2ziyy),
     .i_rst_n (r46kf),
     .i_pulse (gxdn5d1rcg00ydm7_u_),
     .i_active(),
     .o_active(),
     .o_clk   (x9t4ls4jmm),
     .o_rst_n (qgek6hz5rfs6m),
     .o_pulse (fhzqgozhq1pyh2151h)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     y5dr0abgp3k0u_dq1zpy_wzzgi42
     (
     .i_clk   (x9t4ls4jmm),
     .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (fhzqgozhq1pyh2151h),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (n_0gc1jrwbwbesrc8890l)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     gsde52cxxtdr536yw9yz8s3i5tt3ezl3_
     (
     .i_clk   (ri2ziyy),
     .i_rst_n (r46kf),
     .i_pulse (n_0gc1jrwbwbesrc8890l),
     .i_active(),
     .o_active(),
     .o_clk   (x9t4ls4jmm),
     .o_rst_n (qgek6hz5rfs6m),
     .o_pulse (xc7kofn0twnf2_s4mn3dhb04iki)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     px6wgqc7lbsygatylnc3t_267bwf
     (
     .i_clk   (x9t4ls4jmm),
     .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (xc7kofn0twnf2_s4mn3dhb04iki),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (j1fgrs1bp6t8do4_o257aq11)
   );
   wire  y6p6b5nxoxv8ze1h;
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     t7244vyvm6qf9c2iv
     (
     .i_clk   (x9t4ls4jmm),
     .i_pulse (ij002p9rged2ak_),
     .i_rst_n (qgek6hz5rfs6m),
     .i_active(y6p6b5nxoxv8ze1h),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (kz9brlabiztcoo6)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     gx0bihsxildkngev2z4b19gop
     (
     .i_clk   (x9t4ls4jmm),
     .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (uj77n6yj56es04lr4u),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (embfqomp0b7xixzq)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     jk54lqktn5lja
     (
     .i_clk   (x9t4ls4jmm),
     .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (wznckfxx0g1),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (ttlx0bb8pnknhrf9r)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     iq3kgeoimjsdjfi5z1czdfdahcfv
     (
    .i_clk   (x9t4ls4jmm),
    .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (lr3gatfqora7khzh0hp),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (ssifydbti49zjmzo_ef)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     nvod_f9_5plqwctb63hksb7mll
     (
   .i_clk   (x9t4ls4jmm),
    .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (fl5q6cvqdw5ri17nn),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (ee6ptp9j2vinoog44_6g)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     b80e_onu4k09ljcj00ifi0
     (
     .i_clk   (x9t4ls4jmm),
     .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (cou6jkjrtkyb),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (gjo8v81xeh28v2e)
   );
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     fif43v_91mimmumaocmxa20lz
     (
     .i_clk   (x9t4ls4jmm),
     .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (cpdh57_xi982sd8a3pfmut5b),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (x5xpw_q76_9x1xhfigf0kjk4us)
   );
     wire cb88v39q9jwt3pvnrr = ~fcdvc3nlqjhmitd3116;
     wire qn6b671v_v_entk63c2t = ~t3jn32i_lctw1bd0kuq;
     wire [15:0] gcofrc_oi_txyqm; 
     wire [15:0] xe4zssqe1dlpjbv3wvv = 
                                 gcofrc_oi_txyqm;
    c8jhxlzu53pvqb0s   teb3jii8 (
        .ri2ziyy                       ( ri2ziyy                      ),
        .r46kf                     ( r46kf                    ),
        .mxwg8lfgv4pge1             ( n3w802chksaybtkdgd_xl        ),
        .qi_euczbjhgo1za             ( jesyol8j2mzc9p7rg        ),
        .cuu3goyrnwc9hf              ( cuu3goyrnwc9hf             ),
        .t3lk20ui52aqc6              ( t3lk20ui52aqc6             ),
        .rs8qfdkpko8pq             ( rs8qfdkpko8pq            ),
        .l_geblczxuwi5x4e             ( l_geblczxuwi5x4e            ),
        .ptdklfwbs2d13             ( ptdklfwbs2d13            ),
        .nuvz1doibyin1uaa             ( nuvz1doibyin1uaa            ),
        .iydyd8j                     ( iydyd8j                    ),
        .d_ud4rxc                     ( d_ud4rxc                    ),
        .cnppfcsxxqf4urcv              ( l7r8z49kpgjp3                ),
        .tas51wt1y2anvic5x             ( tv84ye8hrmdye0wv          ),
        .spk75u9zmwe9atpcj             ( hfxw5o3cith07p8o          ),
        .p4j35gwurjv5              ( dc87mz60m                ),
        .ze1nmdpmvow7c319             ( th4v1fn833whmi9d          ),
        .fo4edb6fq0rlivyj             ( pmhvdyh26y2x4531o          ),
        .rennjjy_nc                    ( rennjjy_nc                   ),
        .je8cka                    ( je8cka                   ),
        .q9v4i7v_w83ghvywxf           ( ug_op0zbnc25ditffl            ),
        .d7pq3_iwww34lz9qrvnrj_sl90cb   ( q0hhzjkzymizlouesuxy613    ),
        .coewl0jbxtbda4v                ( ioq4xf2u0hg2                 ),
        .guy4snzyohyiz             ( lke7scx_kt96j2              ),
        .heo8n9249c37                ( ylweqzg4l2                   ),
        .g_4093g7113                ( wiyfxtmib7                   ),
        .x7kd6gw9z3nq                  ( x7kd6gw9z3nq                 ),
        .h5fyr6xf                  ( h5fyr6xf                 ),
        .agra657i0o0nz9                ( agra657i0o0nz9               ),
        .e92f6_ec7b7                  ( g6j4godv7g7i5wza            ),
        .rg_d619o1c7drrtakc         ( gxdn5d1rcg00ydm7_u_        ),
        .itzmb3pv762occb74z2bqy         ( itzmb3pv762occb74z2bqy        ),
        .x5xpw_q76_9x1xhfigf0kjk4us    ( x5xpw_q76_9x1xhfigf0kjk4us   ),
        .g5ikzrx34od9pu8jyexvv     ( g5ikzrx34od9pu8jyexvv    ),
        .ileysv9olfjwrm_t236qmf0    ( ileysv9olfjwrm_t236qmf0   ),
        .rg7ozwpk7xwi6vdbg8             ( rg7ozwpk7xwi6vdbg8            ),
        .st_xbxcknhpf              ( st_xbxcknhpf             ),
        .wddz9ajtz98uzxa1y13_rd_6yf   ( wddz9ajtz98uzxa1y13_rd_6yf  ),
        .i5obq0coq3_dxi8wgp5w         ( sm_q4lw3biyezjpcwh          ),
        .b8qdnc0532plw6lmf_7s3        ( xxp4yei2ow6k19vagc         ),
        .h2y116axdf7diunbyy        ( y525w_27oa4xjncj0o8e         ),
        .goutmvirnojskgvv6amvi         ( vdo68osi5psq1rn0          ),
        .spzm6_w92pynok5p4ar       ( v47faz8hre6oocgu6rhbgs        ),
        .rtjb59lqioc                ( wwoo3chlfik                 ),
        .okiluofya4d                ( rvm_9mbg6                 ),
        .et608shl82a38k37n_tc          ( o9yjinw                  ),
        .qp0wn9ujlwcuhkd9yza           ( ix00rwky4                   ),
        .ttye50jd2n0mdj429lscfjl        ( xe52lwmjkncnkgwar            ),
        .k7o146duw1l_7lhmiut_lcw      ( snj91rw_6s2lav_y3         ),
        .h_p_v40ojzhzuo               ( xe4zssqe1dlpjbv3wvv         ),
        .eenfsp7uc                   ( y83hwd_mqfdc4jh24c         ),
        .ax9vv3ea604fyn521             ( zgkty0kh1op3                 ),
        .l57u_ksc8__zzlul              ( embfqomp0b7xixzq           ),
        .yyorn42v7r0yxtj                ( kz9brlabiztcoo6             ),
        .aehb61u1do                ( ttlx0bb8pnknhrf9r             ),
        .btxjg7ygg8tk_7on           ( ssifydbti49zjmzo_ef        ),       
        .y1bj5jcmhudj7gqo           ( ee6ptp9j2vinoog44_6g        ),       
        .a6azftdcm48ofiwjze7i7rh        ( q0jkim6j1pr0sbq            ),
        .usa73t6hje0c                 ( usa73t6hje0c                ), 
        .bt949sros6                 ( bt949sros6                ), 
        .i8z0n9wj94uk6                 ( i8z0n9wj94uk6                ), 
        .cd4cglo9i                 ( cd4cglo9i                ),
        .cou6jkjrtkyb                 ( x_kf5c8jqsasp80m7dj          ),
        .cb88v39q9jwt3pvnrr        ( cb88v39q9jwt3pvnrr       ),
        .qn6b671v_v_entk63c2t         ( qn6b671v_v_entk63c2t        ),
        .a8ksd2cml1857c               ( a8ksd2cml1857c              ), 
        .h1zz0n82qird6               ( h1zz0n82qird6              ), 
        .wkp4c4o8i9jz7qrr               ( wkp4c4o8i9jz7qrr              ), 
        .xgce667c9h1v9_2               ( xgce667c9h1v9_2              ),
        .fmmfcow0bhw_n               ( fmmfcow0bhw_n              ),
        .t9h8f8az1xl6lnxb              ( t9h8f8az1xl6lnxb             ),
        .bvwpeiqbd9vorm_z               ( bvwpeiqbd9vorm_z              ),
        .agzf9f66rtwmzvpra            ( fk6on7eodq4jlrhg1           ),
        .rox3z1ajkb2vlfdt           ( kakm8d3jlxyfilzjo68          ),
        .nbdjwtss8giqeaiucom           ( ng3v7afmxhngxxz          ),
        .dzey_2yh25ke6udi             ( wofz2exuh798h            ),
        .hk5bt7sgcl_w              ( cttbrwkd2ba10dq7             ),
        .c_2t5bufod3tjs               ( v26pk2xgtez1              ),
        .t72myhasn0g1ns              ( nmme9ivahrxd6dt             ),
        .el90ghiy_pow7iut1mrhem     ( pcgnqquxcq831qurodoqn9pd7    ),
        .gcmeduaxfy2t07z2tp0pt      ( d4sah1mq1xosh6pfz5fl     ),
        .vudvag_p2zmadu0               ( ai1wz5k_jiipo              ),
        .erlun2j0p7c9b3kgbw          ( gww0vhmdwv29174u8xm         ),
        .d538tqnpwv5nxljp33ioggy53kljin( o6obdgtij2wgjkulvk_av836v9nc7a),
        .y95x5hdagddvs0pyu8wndgmosp     ( zg5sg41vdk6x0fw7pc5lqa59j    ),
        .sij8tpctkajmr03fg7gpam     ( j1g0igyehdyfyzioxv2_y7md    ),
        .gsunngjkz0hnaqx2o644yb89hd     ( l66187bdmpw7glyepwt0xngma    ),
        .ha5dwnleavf9avv               ( ws0w4rks5wvu              ),
        .dus0b998jzvic               ( oqzel76vp9p245nf              ),
        .ugsaaedtn1grq7             ( lmv6pr9gghsx_q5a6            ),
        .b26mynubin8b_le              ( a8vrqhuhofxl                 ),
        .pnqfvawpm88z_eyd             ( tv7jhpskh                ),
        .kwy_caex2pniarrt90nhz        ( pe7npxqli2dhiy           ),
        .o9c9btcp91rsvpk0vspg          ( uw36v64wbbn3iguh0             ),
        .ckit4a72az0719r4043o         ( m4v_yf_kn5rznb            ),
        .eceqrr444i1sfi27buo2zh9kd    ( n657wtw4ds5a48mh29o69q       ),
        .l199zjdlz5zp4wxl3g            ( n3ybvlkmy0vbdp               ),
        .rpx40ivicuzwht_yj9s       ( ne19nr14x8ucikuk          ),
        .pj8yn_v__lbubab             ( n_vl1e1u80                ),
        .s9ca2h_c0vo3ir21            ( f2fd9vp2pz8a               ),
        .m6zj5v0w5_3ihev8i           ( uc8m2ukpnka              ),
        .ex_g7yz76ioj6b3ga7izf99     ( kdz9fii4gxcf8nmmsr        ),
        .wjpeqvmhl4olz7lwfq7ml      ( s28u06kqhlkryua_         )
    );
  wire cf1jp6isaukho50ws9;
    wire slvng3gm39rlkxz1;
   sdio_gnrl_sync #(.DW(1), .DP(2)) q_fuzhonj4twu5 (.clk(x9t4ls4jmm), .rst_n(qgek6hz5rfs6m), .din_a(z8d6aggc6t), .dout(ep81qennkfss));
    httpcamh0tmfjgmvhu9tq x_wued2hhhcjrc2
    (
        .ntfvn09s31u9_t3w  ( j3rwka8z1juhdw   ),
        .c4wmn9x0tiqe     ( q1e2zddumw8      ),
        .lh16w9beizuu5b2      ( ziear5bore7x2       ),
        .b9qjj1p33jh20xd   ( lmv6pr9gghsx_q5a6    ),
        .y86bin6hqgld38moihaz9l9hm46 (cpdh57_xi982sd8a3pfmut5b),
        .juh54k4vkvfwojkpq6( l8v1f1cqfu9t1ogms1fbh_e ),
        .v6t89tsx_60scl7w7vb8u9ucoyfb (o6obdgtij2wgjkulvk_av836v9nc7a),
        .yuoy0hg           ( mjpt9            ),
        .ljvcn952hmgl22p_3cu5 ( slvng3gm39rlkxz1  ),
        .lczv3cn           ( x9t4ls4jmm         ),
        .r38027_km3          ( qgek6hz5rfs6m  ),
        .hj1zd5izbnc61kc   ( xs2f3mdds5djz0c       ),
        .ljrz9lmuuytll   ( omxhwmgnjlbq5i       ),
        .sz8f8tb7qt0y4s5tf   ( vvr14_h_p5m       ),
        .o5ael5lxk3ws3   ( didovdkh7z       ),
        .wiyfxtmib7          ( wiyfxtmib7           ),
        .galaluy047z      ( nrrkt63zg9dcb66a   ),
        .iztasdnqoh654gu ( cge6m9pk6bphk1h  ),
        .nhmow92ziyrfc2    ( nhmow92ziyrfc2     ),
        .sklzb7wzqf229gf      ( ij002p9rged2ak_       ),
        .rnj4r1so54nq3sc   ( q7ms2svxkcnk37a       ),
        .ic_vhizwroluvm613bzbv47 ( cbbe8bxfq7vw7ehz ),
        .ntge8ydizi5phdjgr7hs2jc ( rsc8sznfqmdd76r ),
        .mjhapl283osr4on ( idlm74clk0r_     ),
        .wpbckwjv7lsmlw105ai2( pffv2ox53j123l25fg    ),
        .o6fjghx2bmnlz       ( xe52lwmjkncnkgwar    ),
        .cp8ikq5kpelal    ( efox5ltvv4azm        ),
        .vg8peads9erjbnw4w7   ( snj91rw_6s2lav_y3 ),
        .fl4y0hv          ( g6j4godv7g7i5wza    ),
        .drqkxqyd0a5rd      ( ct51mag5yve9          )
    );
     assign g6j4godv7g7i5wza = j3rwka8z1juhdw & qh_q1y_m1f;
     fpw5umxwbnhzklg7gch5
    #(
        .ra2aj3fukykd9j   (32),
        .fmv57175hz8809 (64),
        .xi5np3lftgtezged(uwrgm1oivt1de06hok)
    )
     vc21qvjkfaa
    (
        .lczv3cn     (ri2ziyy                ),
        .r38027_km3    (r46kf              ),
        .ho56_v0li6     (kjrt0vjvn           ),
        .ylweqzg4l2    (ylweqzg4l2             ),
        .jm5sdmj     (i71y4eae           ),
        .lyg_g62ta     (kffimtdq           ),
        .aqikf5g    (vk906z_iuoaj       ),
        .al_bfsrdm   (fcdvc3nlqjhmitd3116 ),
        .cadqltzy   (p52gwjhx63ijx2e66yn5 ),
        .jov1vyjapbtr(rennjjy_nc             ),
        .pxdlrpyubv4n   (dsdgq_1fvdgiek6lf    ),
        .ygli0hkz    (eylfh9om1fgq1c          ),
        .euwxj8gh   (pmhvdyh26y2x4531o    )
    );
  wire sb53jfpd9_kdrhqao90e = fcdvc3nlqjhmitd3116 & p52gwjhx63ijx2e66yn5;
  wire ciqzzqmxtplhbtm;
  wire hjl1xxonj33pd8;
  wire p6uj_kjrj7cldwm4iawr;
  assign d2w7_h66f_zuwh = sb53jfpd9_kdrhqao90e 
                     ;
  wire d6fjam_o25m8rjo = txhjs9q2krxvsv_1yvj8vad 
                     & z88hfe5nfr43v3h6mjyze_i 
                     ;
  assign txhjs9q2krxvsv_1yvj8vad = (~p6uj_kjrj7cldwm4iawr);
       sdio_gnrl_async_fifo  
           #(
           .DW(32)
           )
       xebyj8oqj__dxtt_ ( 
       .wclk    (ri2ziyy), 
       .wrst_n  (dhlvy3009fvslc1rmrt_gkfnszx), 
       .wr      (d2w7_h66f_zuwh), 
       .wdata   (vk906z_iuoaj), 
       .wwmk    (), 
       .full    (hjl1xxonj33pd8),
       .w_empty (ciqzzqmxtplhbtm),
       .rclk    (x9t4ls4jmm), 
       .rrst_n  (o5ngg6gwnc3dlji8rm5evfrrpmtz1ef0y), 
       .rd      (d6fjam_o25m8rjo), 
       .rdata   (ez5d43vnbev4mi), 
       .rwmk    (), 
       .empty   (p6uj_kjrj7cldwm4iawr)
       );
  assign p52gwjhx63ijx2e66yn5 = 
                            (~hjl1xxonj33pd8);
     fpw5umxwbnhzklg7gch5
    #(
        .ra2aj3fukykd9j   (32),
        .fmv57175hz8809 (64),
        .xi5np3lftgtezged(uwrgm1oivt1de06hok)
    )
     tdrc0uwx769q
    (
        .lczv3cn     (ri2ziyy               ),
        .r38027_km3    (r46kf             ),
        .ho56_v0li6     (itzmb3pv762occb74z2bqy ),
        .jm5sdmj     (                  ),
        .lyg_g62ta     (1'b0              ),
        .ylweqzg4l2    (ylweqzg4l2            ),
        .aqikf5g    (l7r8z49kpgjp3         ),
        .al_bfsrdm   (tv84ye8hrmdye0wv   ),
        .cadqltzy   (spwra0niad0la30fev0c   ),
        .jov1vyjapbtr(je8cka            ),
        .pxdlrpyubv4n   (md6qdskpzh9gx_tp1km),
        .ygli0hkz    (txti0f6fk82008m      ),
        .euwxj8gh   (t3jn32i_lctw1bd0kuq)
    );
  wire icu7aly9z63lp08ddtsqezn = md6qdskpzh9gx_tp1km & t3jn32i_lctw1bd0kuq;
  wire xn80rfmai5nctx8u8ty;
  wire hwul715z8og6_c4c_q8;
  wire iftzwwa256zewg = il4xl25n7maairf0po8r_xftz 
                     & vpdt0vvzutz6wgrezzyx6 
                     ;
  wire xh48k8qxx9wm5ydhh = icu7aly9z63lp08ddtsqezn 
                     ;
  assign vpdt0vvzutz6wgrezzyx6 = (~xn80rfmai5nctx8u8ty);
       sdio_gnrl_async_fifo  
           #(
           .DW(32)
           )
       mj2jan_nljhe1 ( 
       .wclk    (x9t4ls4jmm), 
       .wrst_n  (o5ngg6gwnc3dlji8rm5evfrrpmtz1ef0y), 
       .wr      (iftzwwa256zewg), 
       .wdata   (c3j4v_pcrpv3m0lujizizmc), 
       .wwmk    (), 
       .full    (xn80rfmai5nctx8u8ty),
       .w_empty (cf1jp6isaukho50ws9),
       .rclk    (ri2ziyy), 
       .rrst_n  (v99hxfa9chjlmu_gq52ee612frp3n), 
       .rd      (xh48k8qxx9wm5ydhh), 
       .rdata   (iss4yfb4_08lnvg4qsr), 
       .rwmk    (), 
       .empty   (hwul715z8og6_c4c_q8)
       );
  assign md6qdskpzh9gx_tp1km = 
                            (~hwul715z8og6_c4c_q8);
    tw0g3i7jl525opz41lv totpqd809_77zv (
        .lczv3cn                      ( x9t4ls4jmm                 ),
        .r38027_km3                     ( e3x0z3h7wur1zw91ra24qxlv          ),
        .qgek6hz5rfs6m                 ( qgek6hz5rfs6m               ),
        .m9ju_obn4pmha                ( ep81qennkfss               ),
        .agra657i0o0nz9                 ( v6lppuzeqzopbd9               ),
        .ib5wwsurj4ye                 ( si3iliqaji                 ),
        .xlamacf6vaj                   ( a8vrqhuhofxl                 ),
        .w564a9eqpo1                  ( tv7jhpskh                ),
        .cgsf_4fw_868uixe6u             ( pe7npxqli2dhiy           ),
        .l__zxgq4uysdbjzx5               ( uw36v64wbbn3iguh0             ),
        .eopkutczkd7pnk              ( m4v_yf_kn5rznb            ),
        .l64jknb_blswjhga3ahd         ( n657wtw4ds5a48mh29o69q       ),
        .tk4kjyypu23tq2                 ( n3ybvlkmy0vbdp               ),
        .ps2qanrlas_jhxguz            ( ne19nr14x8ucikuk          ),
        .qtrpk9tmiygq0                  ( n_vl1e1u80                ),
        .ysm34bdzkpfwqy                 ( f2fd9vp2pz8a               ),
        .mef6pz7wky8                ( uc8m2ukpnka              ),
        .n06jxxux2kra522pn8          ( kdz9fii4gxcf8nmmsr        ),
        .oek_aiemroj9httja91b2           ( s28u06kqhlkryua_         ),
        .sfc8z6ce                      ( mjpt9                    ),
        .tihou7giktswpm4                 ( j4_qlu0mlj4               ),
        .jn1vqljcjmhbzhu5c            ( lr3gatfqora7khzh0hp          ),
        .lo13ulq1cqk5ucx17t            ( fl5q6cvqdw5ri17nn          ),
        .ujh3s3is5                   ( zgkty0kh1op3                 ),
        .eudx6z1_6                   ( qh_q1y_m1f                 ),
        .s5upgf3pot8ypw9_              ( q0jkim6j1pr0sbq            ),
        .hpx0qqw7eo979f               ( uj77n6yj56es04lr4u           ),
        .f7jojb_ei69nmep             ( fk6on7eodq4jlrhg1           ),
        .mvg2uod0f8i5h9__q645            ( kakm8d3jlxyfilzjo68          ),
        .an1vq2wnlx7avgy            ( ng3v7afmxhngxxz          ),
        .akskkzkq9vmjg0eoe9ejjrw         ( l8v1f1cqfu9t1ogms1fbh_e       ),
        .gdayv_v5udtp5x93tt              ( wofz2exuh798h            ),
        .jc3av1ye6lr9h               ( cttbrwkd2ba10dq7             ),
        .zitsxnxkg6e                ( v26pk2xgtez1              ),
        .hnq5mymx3_xyl_q4                ( ai1wz5k_jiipo              ),
        .qrpvq1k7fhmyecbaiwh9c      ( pcgnqquxcq831qurodoqn9pd7    ),
        .b4iuotuo9jk2gl21zq3ai       ( d4sah1mq1xosh6pfz5fl     ),
        .at1ugdl2dzu_hqg               ( nmme9ivahrxd6dt             ),
        .b9qjj1p33jh20xd              ( lmv6pr9gghsx_q5a6            ),
        .px3xebad9kl                 ( xs2f3mdds5djz0c               ),
        .ntlhx_m4cwv2is                 ( omxhwmgnjlbq5i               ),
        .rjlma4yfh29we                 ( vvr14_h_p5m               ),
        .gxb5b03yuuk0_                 ( didovdkh7z               ),
        .a4xpl3wgvhzrlyw            ( cbbe8bxfq7vw7ehz          ),
        .u16tcme0kzincfd2h            ( rsc8sznfqmdd76r          ),
        .hnuzxe36tu1kx3                 ( q7ms2svxkcnk37a               ),
        .yqihalm9oqcj35t               ( idlm74clk0r_             ),
        .dvvdm0wywfwyo5sl              ( pffv2ox53j123l25fg            ),
        .k8ur5tmjmxy                   ( wiyfxtmib7                   ),
        .wwb5bn6954vu                  ( efox5ltvv4azm                ),
        .o87t4pnz3ylkal6            ( ug_op0zbnc25ditffl            ),
        .i2aen5gc13jwm0                 ( ioq4xf2u0hg2                 ),
        .gslmljs2wh3xblb4y9ug            ( e4ml3nl9vqtyqoqli9            ),
        .iek3uwep361fjynh            ( slvng3gm39rlkxz1          ),
        .t6gdkdngru3l_ssm             ( nrrkt63zg9dcb66a           ),
        .udqaodtzx8vqb2dyqv3w6wxemu    ( q0hhzjkzymizlouesuxy613    ),
        .nhmow92ziyrfc2               ( nhmow92ziyrfc2             ),
        .gc0nysovke_pmgmxzl          ( vdo68osi5psq1rn0          ),
        .rjh4rfus0ddh2haeqfvz        ( v47faz8hre6oocgu6rhbgs        ),
        .msbig0_o9iuy56ai3d_sc      ( l66187bdmpw7glyepwt0xngma    ),
        .g5ikzrx34od9pu8jyexvv      ( g5ikzrx34od9pu8jyexvv    ),
        .ileysv9olfjwrm_t236qmf0     ( ileysv9olfjwrm_t236qmf0   ),
        .hnwzjff0yweh4               ( kp1y3g0y0vn__             ),
        .g_kvt0ndiotf8k             ( j3rwka8z1juhdw           ),
        .ykp3rsjs_nw5cspm                ( q1e2zddumw8              ),
        .o07ep_zwkhg6                 ( ziear5bore7x2               ),
        .xn36o896k9xctcxsrk          ( sm_q4lw3biyezjpcwh          ),
        .dcfbrmxklvk3k527hpd         ( xxp4yei2ow6k19vagc         ),
        .p2nd00iq0ot6z_2r1h         ( y525w_27oa4xjncj0o8e         ),
        .jei_o2zgrfpn2                 ( uzopx8pyez3fomb3nq       ),
        .st_xbxcknhpf               ( st_xbxcknhpf             ),
        .rg7ozwpk7xwi6vdbg8              ( rg7ozwpk7xwi6vdbg8            ),
        .wddz9ajtz98uzxa1y13_rd_6yf    ( wddz9ajtz98uzxa1y13_rd_6yf  ),
        .vi2yjdqmw4rsfinydju9          ( ez5d43vnbev4mi           ),
        .suu86gfec5_q7q8tmn         ( oy_xqe59adc18av0t3a9043o8dh ),
        .j_22owq22ygfp83tlkymx0         ( qzxedrzvtc1jidr_7ly19yw2k ),
        .snnj17b9zawct6n7sh         ( c3j4v_pcrpv3m0lujizizmc      ),
        .nahnyoriw3y4r6rdpdn5jd2        ( jx3zf3w25k79245e5thoxhw3g ),
        .rlixu6nnh60an0djhpn6x0j        ( vlex3ee1x3uffk5dcob691grer ),
        .nhlanc0cisb                ( gcofrc_oi_txyqm              ),
        .y5u3u9h83new6z3za            ( cge6m9pk6bphk1h          ),
        .vfoa34j_u2mi                    ( vfoa34j_u2mi                  ),
        .yhhl9de6pqf                    ( yhhl9de6pqf                  ),
        .f_tcdutrmtyh                ( f_tcdutrmtyh              ),
        .wm7w9dybdwy                   ( wm7w9dybdwy                 ),
        .q3v56zbk1                   ( q3v56zbk1                 ),
        .j5lpulyyl0y6tq               ( j5lpulyyl0y6tq             )
  );
    assign es2eisdm0qu3 = ct51mag5yve9;
    assign ula1fsl673girmu = 
                        vfoa34j_u2mi;
    assign jy8f6iovbm   = 
                        (!f_tcdutrmtyh);
    assign wkwscugp5re   = 
                        1'b1
                        ;
    assign yhhl9de6pqf = 
                     j0ymi3se1vtv
                     ;
    assign agxndvfnxt1lq3nz = 
                               wm7w9dybdwy[0];
    assign f649ftjq8dd47v7s   = 
                               (~j5lpulyyl0y6tq[0]);
    assign q3v56zbk1[0]      = 
                               s35jhrn02ch4omla86m;
    assign kiypykzrw_fdhxb = 
                               wm7w9dybdwy[1];
    assign hvblb8fnvykeisty   = 
                               (~j5lpulyyl0y6tq[1]);
    assign q3v56zbk1[1]      = 
                               ipatp60owfx8c9;
    assign y0ifgrg4j8xe1z_e = 
                               wm7w9dybdwy[2];
    assign y_utkzr29tc_rjqx9   = 
                               (~j5lpulyyl0y6tq[2]);
    assign q3v56zbk1[2]      = 
                               axf_lvtru_gky2vx;
    assign mj4c7hhslgsjy9bt = 
                               wm7w9dybdwy[3];
    assign i6573hvtpcm16   = 
                               (~j5lpulyyl0y6tq[3]);
    assign q3v56zbk1[3]      = 
                               dkndzqtx29xy_gey8p;
    assign drlefxcf3_j2lppdm_ = 
                               wm7w9dybdwy[4];
    assign va0j6og_ll80oj   = 
                               (~j5lpulyyl0y6tq[4]);
    assign q3v56zbk1[4]      = 
                               esqkfu_ee6jfpik74y;
    assign pm30xgj2vj2smr71b1u = 
                               wm7w9dybdwy[5];
    assign j8qu4ksipdiygyj2r   = 
                               (~j5lpulyyl0y6tq[5]);
    assign q3v56zbk1[5]      = 
                               s3x0920mp6a8e_k7xox;
    assign gfb43rrs4k_3sx1jaka = 
                               wm7w9dybdwy[6];
    assign crxkbbsftdo8e   = 
                               (~j5lpulyyl0y6tq[6]);
    assign q3v56zbk1[6]      = 
                               hkmux_qq6fgq58j;
    assign m0kao6qjv0umm2ulcgd = 
                               wm7w9dybdwy[7];
    assign a56yiaqw9t1t0   = 
                               (~j5lpulyyl0y6tq[7]);
    assign q3v56zbk1[7]      = 
                               biaikjakr36558d;
    assign x_kf5c8jqsasp80m7dj = gjo8v81xeh28v2e ;
     wire m8d7a2gh;
sdio_gnrl_dffr #(1) dqnlsxcmsdi5_x61p (qqxbkscdbj, m8d7a2gh, x9t4ls4jmm, qgek6hz5rfs6m);
    assign wznckfxx0g1 = qqxbkscdbj & ~m8d7a2gh;
    assign oy_xqe59adc18av0t3a9043o8dh = txhjs9q2krxvsv_1yvj8vad
                                    ;
    assign z88hfe5nfr43v3h6mjyze_i = qzxedrzvtc1jidr_7ly19yw2k 
                                ;
    assign vlex3ee1x3uffk5dcob691grer = vpdt0vvzutz6wgrezzyx6;
    assign il4xl25n7maairf0po8r_xftz = jx3zf3w25k79245e5thoxhw3g 
                                ; 
    assign txti0f6fk82008m  = 
                          iss4yfb4_08lnvg4qsr ; 
    assign qqxbkscdbj = (zgkty0kh1op3[5:0] != 6'h0) | j4_qlu0mlj4;
    assign dsdgq_1fvdgiek6lf    =                                th4v1fn833whmi9d ; 
    assign eylfh9om1fgq1c          =                                dc87mz60m ;
    assign kffimtdq           =                                1'b0 ;
    assign kjrt0vjvn           = itzmb3pv762occb74z2bqy; 
    assign cm9fjjf3g82yprv1d    =                                pmhvdyh26y2x4531o ;
    assign spwra0niad0la30fev0c    =                                hfxw5o3cith07p8o ;
    assign l0wy6y5ntv2khk_k    =                                tv84ye8hrmdye0wv ;
    assign c2x4ec82bjq          =                                l7r8z49kpgjp3;
    assign r1ukfidrb_5kvibw        = 1'b0;
    assign nhup3xqrnngwbqsg_e    = 1'b0;
    wire kya7h5h1podqhwe1gomec9e = z88hfe5nfr43v3h6mjyze_i 
                            & (~txhjs9q2krxvsv_1yvj8vad) 
                            ;
    wire jrox1m26t4309m24t_;
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     iaasrhks9djnrkfqlue2
     (
     .i_clk   (x9t4ls4jmm),
     .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (kya7h5h1podqhwe1gomec9e),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (jrox1m26t4309m24t_)
   );
    assign  usa73t6hje0c = jrox1m26t4309m24t_ 
                      ;
    wire b1a76zo3kgr8ds4ps85jv;
   sdio_gnrl_cdc_pulse
   # (
     .SYNC_DP (2)
   ) 
     d_kqw4cp8bqf3_y5krb1w
     (
     .i_clk   (x9t4ls4jmm),
     .i_rst_n (qgek6hz5rfs6m),
     .i_pulse (uzopx8pyez3fomb3nq),
     .i_active(),
     .o_active(),
     .o_clk   (ri2ziyy),
     .o_rst_n (r46kf),
     .o_pulse (b1a76zo3kgr8ds4ps85jv)
   );
    assign uzopx8pyez3fomb3nq = (~vpdt0vvzutz6wgrezzyx6) 
                              & il4xl25n7maairf0po8r_xftz 
                              & (~wwoo3chlfik) 
                              ;
    assign cd4cglo9i          = b1a76zo3kgr8ds4ps85jv 
                              ; 
    assign bt949sros6          = (~pmhvdyh26y2x4531o) & dsdgq_1fvdgiek6lf; 
    assign i8z0n9wj94uk6          = hfxw5o3cith07p8o & (~tv84ye8hrmdye0wv); 
    assign cou6jkjrtkyb          = ejw7oi93ww9le1xickgr_ & (~q3ma3m63h11toilhcdx) & kp1y3g0y0vn__ & j3rwka8z1juhdw & j5lpulyyl0y6tq[1];
    assign c_6y8qe_ucl = x7kd6gw9z3nq 
                    | h5fyr6xf 
                    | d_ud4rxc 
                    | iydyd8j 
                    | a8ksd2cml1857c  
                    | h1zz0n82qird6  
                    | wkp4c4o8i9jz7qrr  
                    | xgce667c9h1v9_2 
                    | fmmfcow0bhw_n 
                    | t9h8f8az1xl6lnxb
                    | bvwpeiqbd9vorm_z
                    | zg5sg41vdk6x0fw7pc5lqa59j
                    | j1g0igyehdyfyzioxv2_y7md
                    | ws0w4rks5wvu
                    | oqzel76vp9p245nf
                    ;
    assign ce4q39qw2gn0 = rvm_9mbg6[0];
    assign aoofou61a0iq = rvm_9mbg6[1];
    assign pc2xuy_fyjus3 = rvm_9mbg6[2];
    assign loao5ar4y59i7dy = rvm_9mbg6[3];
    assign utnb83_6j8sa_k = rvm_9mbg6[4];
    assign zxmk7fbbwufsu2wy8 = rvm_9mbg6[5];
    assign dy2liyrkkic1u = rvm_9mbg6[6];
    assign tyd569koo37unwhw = rvm_9mbg6[7];
    assign cbb6qt91iz4rzait2 = rvm_9mbg6[8];
    assign x5o1z7p1fq7zycs = rvm_9mbg6[9];
endmodule
module tw0g3i7jl525opz41lv
(
    input wire          lczv3cn,
    input wire          r38027_km3,
    input wire          qgek6hz5rfs6m,
    input wire          agra657i0o0nz9,
    input wire          m9ju_obn4pmha,
    input wire          ib5wwsurj4ye,
    input wire   [5:0]  xlamacf6vaj,
    input wire  [31:0]  w564a9eqpo1,
    input wire   [7:0]  cgsf_4fw_868uixe6u,
    input wire    [5:0] l__zxgq4uysdbjzx5,
    input wire   [31:0] eopkutczkd7pnk,
    input wire    [5:0] l64jknb_blswjhga3ahd,
    input wire          qtrpk9tmiygq0,
    input wire          ysm34bdzkpfwqy,
    input wire   [1:0]  mef6pz7wky8,
    input wire  [11:0]  n06jxxux2kra522pn8,
    input wire  [15:0]  oek_aiemroj9httja91b2,
    input wire          nhmow92ziyrfc2 ,
    input wire          f7jojb_ei69nmep,
    input wire          px3xebad9kl,
    input wire          zitsxnxkg6e,
    input wire          ntlhx_m4cwv2is,
    input wire          rjlma4yfh29we,
    input wire          gxb5b03yuuk0_,
    input wire          u16tcme0kzincfd2h,
    input wire          a4xpl3wgvhzrlyw,
    input wire          k8ur5tmjmxy,
    input wire          hnuzxe36tu1kx3,
    input wire          yqihalm9oqcj35t,
    input wire          dvvdm0wywfwyo5sl,
    input wire          wwb5bn6954vu,
    input wire          o87t4pnz3ylkal6 ,
    input wire          i2aen5gc13jwm0      ,
    input wire  [1:0]   hnq5mymx3_xyl_q4   ,
    input wire          an1vq2wnlx7avgy,
    input wire          qrpvq1k7fhmyecbaiwh9c,
    input wire          b4iuotuo9jk2gl21zq3ai,
    input wire  [1:0]   at1ugdl2dzu_hqg,
    input wire          b9qjj1p33jh20xd,
    input wire [31:0]   g5ikzrx34od9pu8jyexvv,
    input wire [31:0]   ileysv9olfjwrm_t236qmf0,
    input wire          udqaodtzx8vqb2dyqv3w6wxemu,
    input wire          iek3uwep361fjynh,
    input wire          gslmljs2wh3xblb4y9ug,
    input wire          gdayv_v5udtp5x93tt,
    input wire          jc3av1ye6lr9h,
    input wire          mvg2uod0f8i5h9__q645,
    input wire          akskkzkq9vmjg0eoe9ejjrw,
    input wire  [15:0]  xn36o896k9xctcxsrk,
    input wire  [15:0]  dcfbrmxklvk3k527hpd,
    input wire  [15:0]  p2nd00iq0ot6z_2r1h,
    input wire          gc0nysovke_pmgmxzl,
    input wire          rjh4rfus0ddh2haeqfvz,
    input wire          msbig0_o9iuy56ai3d_sc,
    input wire [31:0]   wddz9ajtz98uzxa1y13_rd_6yf,
    input wire          jei_o2zgrfpn2,
    output wire         eudx6z1_6,
    output wire         sfc8z6ce,
    output wire         tihou7giktswpm4,
    output wire         jn1vqljcjmhbzhu5c,
    output wire         lo13ulq1cqk5ucx17t,
    output wire         g_kvt0ndiotf8k,
    output wire         ykp3rsjs_nw5cspm,
    output wire         o07ep_zwkhg6,
    output wire  [15:0] ujh3s3is5,
    output wire [127:0] tk4kjyypu23tq2,
    output wire [127:0] ps2qanrlas_jhxguz,
    output wire [15:0]  nhlanc0cisb,
    output wire         s5upgf3pot8ypw9_,
    output wire         hpx0qqw7eo979f,
    output wire         hnwzjff0yweh4,
    output wire         y5u3u9h83new6z3za,
    output wire         t6gdkdngru3l_ssm,
    output wire [15:0]  st_xbxcknhpf,
    output wire [15:0]  rg7ozwpk7xwi6vdbg8,
    input  wire  [31:0] vi2yjdqmw4rsfinydju9, 
    input  wire         suu86gfec5_q7q8tmn,
    output wire         j_22owq22ygfp83tlkymx0, 
    output wire  [31:0] snnj17b9zawct6n7sh, 
    output wire         nahnyoriw3y4r6rdpdn5jd2,
    input  wire         rlixu6nnh60an0djhpn6x0j, 
    input  wire         yhhl9de6pqf,
    output wire         vfoa34j_u2mi,
    output wire         f_tcdutrmtyh,
    output wire   [7:0] wm7w9dybdwy,
    input  wire   [7:0] q3v56zbk1,
    output wire   [7:0] j5lpulyyl0y6tq
  );
    localparam bsdxl9vqmdni      = 2'h0; 
    localparam r2v8uc_xukxdcxu     = 2'h1;  
    localparam i5wsmzqur754u4      = 2'h2;  
    localparam ws3ko1rvdjz299ham = 2;
    wire eilekzzyohhmi1zc9n;
    wire km0wiz_m85vu7;
    wire n_vl1e1u80;
    wire t8ls_d8epyb20e;
    wire amrf6pheb_r31ttry2;
    wire m8wn59w0vp8mie4znti5yvp_z4ss;
    wire fueq_4_jw0xh5kttcutc;
    wire ph7fazez463s3o5uqlhmy4n;
    wire dxzxwmk7l2p1dcaw10az4wfxfpstuw;
    wire wgzrl8nu7oudwt6xjlj8yonrmwahm;
    wire nsdg4bd8a88tes;
    wire        b9w2chb8qxabl;
    wire        vwbxx02jcsl2;
    wire        fe7a52bvkgasxtht;   
    wire  [5:0] a8vrqhuhofxl;  
    wire [31:0] tv7jhpskh;
    wire  [7:0] pe7npxqli2dhiy;
    wire  [5:0] wvjh9zl6os9wmf;
    wire        nbv789gm7mpl317_d;
    wire        qxp17qld1mykfmk7o;
    wire  [5:0] uw36v64wbbn3iguh0;
    wire [31:0] m4v_yf_kn5rznb;
    wire  [5:0] n657wtw4ds5a48mh29o69q;
    wire        g6zs6zoy8hq80z;
    wire        mjpt9;
    wire        a0pn3j81yvryt;
    wire [5:0]  py08rmttc7ogv5p0;
    wire        m5vm4xbpja;
    wire        qb93jt8wbrr9;
    wire        sk1oehg8n4gjg2l9g8;
    wire        sfuzditpf6xkjs;
    wire        mal354aby_ublbho;
    wire        ns8ebjy455bkn0l;
    wire        mvcxu0tbl2d;
    wire        iysc_d0ypgmxisqnc;
    wire        usae8bxqvejyr4;
    wire        shr7td0e35qguhbsrc = (hnq5mymx3_xyl_q4 == 2'b01);
    wire        j67cz9tdm3e5wtng78q = (hnq5mymx3_xyl_q4 == 2'b10);
    assign      ykp3rsjs_nw5cspm = (at1ugdl2dzu_hqg == 2'b10);
    assign      o07ep_zwkhg6 = (at1ugdl2dzu_hqg == 2'b00);
    assign      g_kvt0ndiotf8k = (at1ugdl2dzu_hqg == 2'b11);
    wire        ai1wz5k_jiipo = (shr7td0e35qguhbsrc | j67cz9tdm3e5wtng78q);
    wire        p2sf3nda5zjd76he3j7 = gslmljs2wh3xblb4y9ug & (~ai1wz5k_jiipo);
    wire        chp_ggs8hwxen = (~shr7td0e35qguhbsrc) & cgsf_4fw_868uixe6u[7];
    wire        bq6scjvk0k3x6aen99x;
    wire        uzzvqcjht5lwnsk_ ;
    wire        vw2bytlrzc0kw_p9nilm9;
    assign      t6gdkdngru3l_ssm = p2sf3nda5zjd76he3j7;
    wire t4131jmbnymobrhjm5j;
    wire [ws3ko1rvdjz299ham-1:0] j9e9y0z9nr7hkr9tx;
    wire [ws3ko1rvdjz299ham-1:0] aeiokfzwts8fc4;
    wire [ws3ko1rvdjz299ham-1:0] eielk5d5poroqcoco15;
    wire [ws3ko1rvdjz299ham-1:0] qqi796b_2w03o53ylbwm;
    wire [ws3ko1rvdjz299ham-1:0] wo3l9e261306otjnobag;
    wire hoeb6h_8_upz1y0tktfze47ib5;
    wire i114yvarem87hdkifmeghxtlav;
    wire via12_eeh7ahvjwy14mfs9z0;
    wire gq8_9gnisasvvpn1s3rcr_v  = (j9e9y0z9nr7hkr9tx == bsdxl9vqmdni);
    wire ziefrbio6o9l9mswj9xkv3bd = (j9e9y0z9nr7hkr9tx == r2v8uc_xukxdcxu);
    wire qb23dquc_sc_4bimxkprzzrp2k  = (j9e9y0z9nr7hkr9tx == i5wsmzqur754u4);
    wire qlmm0c_lxnt1tm60sxbz;
    wire sx657ne9aez39hduu;
    wire xm0g3oe6e3tztg4rya = m9ju_obn4pmha; 
    wire lcmnz41_jjx0ti_eez5 = sx657ne9aez39hduu; 
    wire tot_jfos2rsj_8iau = xm0g3oe6e3tztg4rya;
    wire g_9cm1q8zg30er5na = xm0g3oe6e3tztg4rya | lcmnz41_jjx0ti_eez5 ;
sdio_gnrl_dfflr #(1) egoc5lxgae8jvqjojru9lc (g_9cm1q8zg30er5na, tot_jfos2rsj_8iau, qlmm0c_lxnt1tm60sxbz, lczv3cn, r38027_km3);
    wire xirivf4v8r62kakdzo4i8h;
sdio_gnrl_dffr #(1) ypmhr2770xultny28dq07a9 (shr7td0e35qguhbsrc, xirivf4v8r62kakdzo4i8h, lczv3cn, r38027_km3);
   wire ctn058q59yjtbm0j = cgsf_4fw_868uixe6u[6] & qtrpk9tmiygq0 & m9ju_obn4pmha;
    wire l9qcp1cywbsw6oi_e1;
    wire qvymuxa2viduv0_m = ib5wwsurj4ye | ctn058q59yjtbm0j; 
    wire wg2jm71wfyee91_z7a4 = sfc8z6ce; 
    wire w9pfhj9mtwn260j92osqn = qvymuxa2viduv0_m;
    wire tb2gr1rlt7smne5wvvegn = qvymuxa2viduv0_m | wg2jm71wfyee91_z7a4 ;
sdio_gnrl_dfflr #(1) dhuyhwbn3hjvl_9ry2r1fvkxy (tb2gr1rlt7smne5wvvegn, w9pfhj9mtwn260j92osqn, l9qcp1cywbsw6oi_e1, lczv3cn, r38027_km3);
    wire jew5z2dhziakf;
    wire sx1vx5vam00il7jgf6j = sfc8z6ce & xirivf4v8r62kakdzo4i8h; 
    wire zs9sl_4qyqypxhrin = jew5z2dhziakf & (~xirivf4v8r62kakdzo4i8h); 
    wire jx8dyn9dsmoju55r9l = sx1vx5vam00il7jgf6j;
    wire gl7ei4mcubaezzl7lr = sx1vx5vam00il7jgf6j | zs9sl_4qyqypxhrin ;
sdio_gnrl_dfflr #(1) wjrqkfg13t36izrmc3d07msk (gl7ei4mcubaezzl7lr, jx8dyn9dsmoju55r9l, jew5z2dhziakf, lczv3cn, r38027_km3);
    wire fmoax_guh6ag37xw5uuv45uu;
    wire qnwy0m3inx9xwhs7dhfuejcc = (xirivf4v8r62kakdzo4i8h & (~shr7td0e35qguhbsrc)) & (~jew5z2dhziakf); 
    wire uixinw2og78vd1jim9a2tgmv7m = sfc8z6ce; 
    wire tiedabqikv3fjvcyowvjfr04 = qnwy0m3inx9xwhs7dhfuejcc;
    wire cfkj9tbkv0jlyb1ap212jb = qnwy0m3inx9xwhs7dhfuejcc | uixinw2og78vd1jim9a2tgmv7m ;
sdio_gnrl_dfflr #(1) y7f8tkf0mq07odje2wzxe12w_g4_9 (cfkj9tbkv0jlyb1ap212jb, tiedabqikv3fjvcyowvjfr04, fmoax_guh6ag37xw5uuv45uu, lczv3cn, r38027_km3);
    wire r8_xepajlb3mig = (l9qcp1cywbsw6oi_e1 | ib5wwsurj4ye | vw2bytlrzc0kw_p9nilm9) ;
    assign vw2bytlrzc0kw_p9nilm9 = fmoax_guh6ag37xw5uuv45uu | qnwy0m3inx9xwhs7dhfuejcc;
    wire h8mft4x_17eip1sr = (m9ju_obn4pmha | qlmm0c_lxnt1tm60sxbz) & n_vl1e1u80 ;
    wire qgiy5bwc298_hu0jfhg = (oek_aiemroj9httja91b2 == 16'h0);
    wire aej6mvu521r3f_qv20wcn8 = (h8mft4x_17eip1sr & qgiy5bwc298_hu0jfhg) ;
    wire u2ja8t400gp;
    wire he8bsvhais7 = ~g6zs6zoy8hq80z; 
    wire wjb0duj518se_ = g6zs6zoy8hq80z & qxp17qld1mykfmk7o; 
    wire ecf2zaatj7v1y = he8bsvhais7 ? qtrpk9tmiygq0 
                     : wjb0duj518se_ ? 1'b0
                     : 1'b0
                     ;
    wire iek8crocaxv_7wo5 = he8bsvhais7 | wjb0duj518se_ ;
    wire ddz6xtr7plh4hw = iek8crocaxv_7wo5 ;
sdio_gnrl_dfflr #(1) a_ibrm4gn47ss9t97h4 (ddz6xtr7plh4hw, ecf2zaatj7v1y, u2ja8t400gp, lczv3cn, r38027_km3);
    wire prcftr15c7h9ec;
    wire duulusenzuo046cbhjm68 = b9w2chb8qxabl; 
    wire pj004ic3eng1btfkfs = sfc8z6ce; 
    wire hi1mr446onu_3zevv5i2 = (~pj004ic3eng1btfkfs) ;
    wire jobwgxl_g0dlutw9ooy = duulusenzuo046cbhjm68 | pj004ic3eng1btfkfs ;
    wire jgu0yztfauijc9e_0 = jobwgxl_g0dlutw9ooy ;
sdio_gnrl_dfflr #(1) g8sf_d6bd2otf14t968mx (jgu0yztfauijc9e_0, hi1mr446onu_3zevv5i2, prcftr15c7h9ec, lczv3cn, r38027_km3);
    wire ki8s7_e0iqtsxj;
    wire fevmxmc9xjfbd_z8t0p = ctn058q59yjtbm0j & prcftr15c7h9ec; 
    wire uns9_5jkpyd3m7rrlq6o = sfc8z6ce; 
    wire m1o89acckpn47zqoo = fevmxmc9xjfbd_z8t0p;
    wire ieymh0rlidxdq67j60g3a = fevmxmc9xjfbd_z8t0p | uns9_5jkpyd3m7rrlq6o ;
sdio_gnrl_dfflr #(1) hpp6e34dp8qlwa9a28rbdp1 (ieymh0rlidxdq67j60g3a, m1o89acckpn47zqoo, ki8s7_e0iqtsxj, lczv3cn, r38027_km3);
    wire m61rfc88ai1yqcno;
    wire qyanvd7fnyw536zp43 = prcftr15c7h9ec & b9w2chb8qxabl; 
    wire nadvdut2qrvyi913sfr = sfc8z6ce; 
    wire gc10tndh2hm9ag5zcywul = (~nadvdut2qrvyi913sfr) ;
    wire gx2e4trinkovtvpqjp5g5 = qyanvd7fnyw536zp43 | nadvdut2qrvyi913sfr ;
    wire jurulthfwum6ax_eja = gx2e4trinkovtvpqjp5g5 ;
sdio_gnrl_dfflr #(1) g9yf_kk9ji_ndyhjqx4x1o (jurulthfwum6ax_eja, gc10tndh2hm9ag5zcywul, m61rfc88ai1yqcno, lczv3cn, r38027_km3);
    wire ldvc4e1pnv14;
    wire f2sdcnw9rog8oj8w = sfuzditpf6xkjs & b9w2chb8qxabl & prcftr15c7h9ec; 
    wire zufxjqzrsw8ktym = sfc8z6ce; 
    wire gt38ve2tfhem6y8f = f2sdcnw9rog8oj8w ;
    wire kz2o3uwrn3fgozd = f2sdcnw9rog8oj8w | zufxjqzrsw8ktym ;
    wire u8o7kliouuum07w = kz2o3uwrn3fgozd ;
sdio_gnrl_dfflr #(1) kxgbhdgn_byjsxhfm3 (u8o7kliouuum07w, gt38ve2tfhem6y8f, ldvc4e1pnv14, lczv3cn, r38027_km3);
    wire m85jz7eqgzvfhb;
    wire odlvgj_n7o94 = g6zs6zoy8hq80z; 
    wire jftn1cpdvhv = prcftr15c7h9ec & (b9w2chb8qxabl | sfc8z6ce) | agra657i0o0nz9; 
    wire mix6k4ubeaz = ~jftn1cpdvhv ;
    wire scfc109hxrylux0v = odlvgj_n7o94 | jftn1cpdvhv ;
    wire b5g58qx3zxrvg = scfc109hxrylux0v ;
sdio_gnrl_dfflr #(1) q0lpqk9f2en8em0j13zv (b5g58qx3zxrvg, mix6k4ubeaz, m85jz7eqgzvfhb, lczv3cn, r38027_km3);
    wire lu8g7fc8uj5yxm8b7;
    wire l_1txec5df;
    assign uzzvqcjht5lwnsk_ = k8ur5tmjmxy & (~lu8g7fc8uj5yxm8b7);
    wire uibkz8vl19yl4w40 = (sfuzditpf6xkjs | tihou7giktswpm4 | r8_xepajlb3mig | ai1wz5k_jiipo) & m5vm4xbpja; 
    wire maht6dr5eo6iur3r = sfc8z6ce | lu8g7fc8uj5yxm8b7 & nsdg4bd8a88tes; 
    wire kg5f64ixmghbz0 = (~maht6dr5eo6iur3r) ;
    wire qy15dldj2t044 = uibkz8vl19yl4w40 | maht6dr5eo6iur3r ;
    wire tn6zdlb_y1vy7 = qy15dldj2t044 & ((px3xebad9kl & (~uzzvqcjht5lwnsk_)) 
                                      | a4xpl3wgvhzrlyw & uzzvqcjht5lwnsk_ & (~ysm34bdzkpfwqy) 
                                      | u16tcme0kzincfd2h & uzzvqcjht5lwnsk_ & (ysm34bdzkpfwqy) 
                                      | maht6dr5eo6iur3r
                                      );
sdio_gnrl_dfflr #(1) b9qf10y5egz0edyun (tn6zdlb_y1vy7, kg5f64ixmghbz0, l_1txec5df, lczv3cn, r38027_km3);
    wire cfk__eq1m0b0ezswhrd_t = nbv789gm7mpl317_d & r8_xepajlb3mig;
    assign nsdg4bd8a88tes = cfk__eq1m0b0ezswhrd_t ? 1'b1 : l_1txec5df;
    wire rxfvc1ymr4kqwufakd = km0wiz_m85vu7 & f7jojb_ei69nmep & (~lu8g7fc8uj5yxm8b7) & (~cgsf_4fw_868uixe6u[6]); 
    wire ndkaj3ib0j1bieh_ = nsdg4bd8a88tes; 
    wire rtuqsxdulxeq4jiz = (~ndkaj3ib0j1bieh_) ;
    wire zhw4zg_vis1gzslk = rxfvc1ymr4kqwufakd | ndkaj3ib0j1bieh_ ;
    wire m_vc6xvxju_irhqbli = zhw4zg_vis1gzslk ;
sdio_gnrl_dfflr #(1) de2u4gu4blau_43_uk11030n (m_vc6xvxju_irhqbli, rtuqsxdulxeq4jiz, lu8g7fc8uj5yxm8b7, lczv3cn, r38027_km3);
    assign bq6scjvk0k3x6aen99x = lu8g7fc8uj5yxm8b7 | rxfvc1ymr4kqwufakd & (~nsdg4bd8a88tes);
    wire kqxhyn5dk7ga2w4w31oa;
    wire t_kzc11ctzbusxesnr353br =( (b9w2chb8qxabl & an1vq2wnlx7avgy & (~f7jojb_ei69nmep)) 
                                | (lu8g7fc8uj5yxm8b7 & nsdg4bd8a88tes & an1vq2wnlx7avgy & f7jojb_ei69nmep)
                                )
                                ; 
    wire sp1cj6pfk9g_g96r7390_r = sfc8z6ce; 
    wire xqpjl492r6k92o6gjk5x7pmyt = (~sp1cj6pfk9g_g96r7390_r) ;
    wire cos2tw6vz0dk1glef39ufw9nj = t_kzc11ctzbusxesnr353br | sp1cj6pfk9g_g96r7390_r ;
    wire ey13t48gj5fzhclaeilk6ycr = cos2tw6vz0dk1glef39ufw9nj ;
sdio_gnrl_dfflr #(1) k7g58cjincu_1n6e86mvcxazjd (ey13t48gj5fzhclaeilk6ycr, xqpjl492r6k92o6gjk5x7pmyt, kqxhyn5dk7ga2w4w31oa, lczv3cn, r38027_km3);
    wire zqbst5t9k9kcbmxg;
    wire r9929pufeqty2h_xzvx = usae8bxqvejyr4; 
    wire gf1n0hp6xk0d0pslyxt = sfc8z6ce; 
    wire p05snoo41p9904zk___86 = (~gf1n0hp6xk0d0pslyxt) ;
    wire u0lovx49g165gwks1x_ = r9929pufeqty2h_xzvx | gf1n0hp6xk0d0pslyxt ;
    wire um582bq81o9026tq9y = u0lovx49g165gwks1x_ & px3xebad9kl;
sdio_gnrl_dfflr #(1) rim71b0kvofgdy9rbx6eh0tln (um582bq81o9026tq9y, p05snoo41p9904zk___86, zqbst5t9k9kcbmxg, lczv3cn, r38027_km3);
    wire lmng6im1hzqgxwjdi1;
    wire gfuqlqs4dtzezc49 = mal354aby_ublbho; 
    wire ku9ol9v6uja6sl4t1 = a0pn3j81yvryt; 
    wire yn6ta9z79dtj99qnts = a0pn3j81yvryt ? 1'b0 
                          : mal354aby_ublbho ? ns8ebjy455bkn0l 
                          : 1'b0
                          ;
    wire ksshs2m2udyki7jp4naw = gfuqlqs4dtzezc49 | ku9ol9v6uja6sl4t1 ;
    wire tgibokma3j1urnudrffa = ksshs2m2udyki7jp4naw & px3xebad9kl;
sdio_gnrl_dfflr #(1) wzbq2paa677h_eu1vd706v (tgibokma3j1urnudrffa, yn6ta9z79dtj99qnts, lmng6im1hzqgxwjdi1, lczv3cn, r38027_km3);
    wire cnwhkjzy3z_gceqcz1h = cfk__eq1m0b0ezswhrd_t ? b9w2chb8qxabl : qb93jt8wbrr9;
    wire k93yjpylsfe9tgm55o = o87t4pnz3ylkal6 | ki8s7_e0iqtsxj;
    assign hoeb6h_8_upz1y0tktfze47ib5   = gq8_9gnisasvvpn1s3rcr_v & h8mft4x_17eip1sr;
    assign i114yvarem87hdkifmeghxtlav  = ziefrbio6o9l9mswj9xkv3bd & cnwhkjzy3z_gceqcz1h;
    assign via12_eeh7ahvjwy14mfs9z0   = qb23dquc_sc_4bimxkprzzrp2k & ((k93yjpylsfe9tgm55o ? (lmng6im1hzqgxwjdi1 | ldvc4e1pnv14) : 1'b1 ) && nsdg4bd8a88tes | agra657i0o0nz9 );
    assign eielk5d5poroqcoco15        = (aej6mvu521r3f_qv20wcn8 | r8_xepajlb3mig | gdayv_v5udtp5x93tt) ? i5wsmzqur754u4 : r2v8uc_xukxdcxu ;
    assign qqi796b_2w03o53ylbwm       = i5wsmzqur754u4;
    assign wo3l9e261306otjnobag        = bsdxl9vqmdni;
    assign t4131jmbnymobrhjm5j = hoeb6h_8_upz1y0tktfze47ib5
                          | i114yvarem87hdkifmeghxtlav
                          | via12_eeh7ahvjwy14mfs9z0
                          ;
    assign aeiokfzwts8fc4 = ({ws3ko1rvdjz299ham{ hoeb6h_8_upz1y0tktfze47ib5   }}) & eielk5d5poroqcoco15            
                          | ({ws3ko1rvdjz299ham{ i114yvarem87hdkifmeghxtlav  }}) & qqi796b_2w03o53ylbwm
                          | ({ws3ko1rvdjz299ham{ via12_eeh7ahvjwy14mfs9z0   }}) & wo3l9e261306otjnobag
                          ;
    assign sx657ne9aez39hduu = (px3xebad9kl & (~uzzvqcjht5lwnsk_)) 
                         | (a4xpl3wgvhzrlyw & uzzvqcjht5lwnsk_ & (~ysm34bdzkpfwqy))  
                         | (u16tcme0kzincfd2h & uzzvqcjht5lwnsk_ & (ysm34bdzkpfwqy))
                         ;
    wire y5vi74vo8hfzs6n = t4131jmbnymobrhjm5j ;
sdio_gnrl_dfflr #(ws3ko1rvdjz299ham) ad0t9ad0ocexhh2o2f35 (y5vi74vo8hfzs6n, aeiokfzwts8fc4, j9e9y0z9nr7hkr9tx, lczv3cn, r38027_km3);
    wire cp9qf9fke1n3ch1ak = ~suu86gfec5_q7q8tmn;
    wire ji88ix87mv_j9e4  = ~rlixu6nnh60an0djhpn6x0j;
    wire s0jmcxeq6s1h0asago = prcftr15c7h9ec;
    wire dmnh947v4cmkwv7d = (~g_kvt0ndiotf8k) & b9qjj1p33jh20xd;
  dkm9ot9b2rj7y4kogzcu kdc_ebchj6 (
    .m9784q7ukmn3si58c70oo_hls       ( ph7fazez463s3o5uqlhmy4n      ),
    .ri2ziyy                        ( lczv3cn                     ),
    .r46kf                      ( r38027_km3                    ),
    .qgek6hz5rfs6m                 ( qgek6hz5rfs6m                ),
    .w3pibny_m                     ( mvcxu0tbl2d                    ),
    .wiu1s04x6zdw                 ( agra657i0o0nz9                ),
    .ai6qc7womk1r                ( fe7a52bvkgasxtht               ),
    .s2jh1nempl                 ( r8_xepajlb3mig            ),
    .hqepeupn1i672                   ( a8vrqhuhofxl                  ),
    .d7n__4eepibg1b                  ( tv7jhpskh                 ),
    .o11gjfkp0o48qa6             ( pe7npxqli2dhiy            ),
    .f6c5u_qu3x_b68tj8xt4k2zy7       ( vw2bytlrzc0kw_p9nilm9      ),
    .ntlhx_m4cwv2is                 ( ntlhx_m4cwv2is                ),
    .px3xebad9kl                 ( px3xebad9kl                ),
    .ntfvn09s31u9_t3w             ( g_kvt0ndiotf8k            ),
    .c4wmn9x0tiqe                ( ykp3rsjs_nw5cspm               ),
    .lh16w9beizuu5b2                 ( dmnh947v4cmkwv7d             ),
    .wwb5bn6954vu                  ( wwb5bn6954vu                 ),
    .hc5muz31u4                 ( nsdg4bd8a88tes             ),
    .s0jmcxeq6s1h0asago             ( s0jmcxeq6s1h0asago            ),
    .opcd3lqf_2oq                  ( qtrpk9tmiygq0                 ),
    .udqaodtzx8vqb2dyqv3w6wxemu    ( udqaodtzx8vqb2dyqv3w6wxemu   ),
    .jc3av1ye6lr9h               ( jc3av1ye6lr9h              ),
    .galaluy047z                 ( iek3uwep361fjynh           ),
    .g1880fxg1                   ( q3v56zbk1                  ),
    .xn36o896k9xctcxsrk          ( xn36o896k9xctcxsrk         ),
    .dcfbrmxklvk3k527hpd         ( dcfbrmxklvk3k527hpd        ),
    .p2nd00iq0ot6z_2r1h         ( p2nd00iq0ot6z_2r1h        ),
    .q6xj2owp6tumpa0_w2hh         ( cp9qf9fke1n3ch1ak          ),
    .ubfebspi89cdng2_9          ( ji88ix87mv_j9e4           ),
    .o87t4pnz3ylkal6            ( o87t4pnz3ylkal6           ),
    .dvv9js337kdzasybz56e9dx         ( shr7td0e35qguhbsrc        ),
    .vn02561rj8l2z_erne20lhu5        ( j67cz9tdm3e5wtng78q       ),
    .qrpvq1k7fhmyecbaiwh9c      ( qrpvq1k7fhmyecbaiwh9c     ),
    .f7jojb_ei69nmep             ( f7jojb_ei69nmep            ),
    .an1vq2wnlx7avgy            ( an1vq2wnlx7avgy           ),
    .st_xbxcknhpf               ( st_xbxcknhpf              ),
    .ynni_e015eh                 ( tk4kjyypu23tq2                ),
    .l492_zdzcnnei4mb            ( ps2qanrlas_jhxguz           ),
    .hb4y0ustf02qb              ( t8ls_d8epyb20e             ),
    .iydyd8j                      ( b9w2chb8qxabl                 ),
    .cvsvk6xosj0                   ( wvjh9zl6os9wmf              ),
    .f0mni1qb4r5w                 ( vwbxx02jcsl2              ),
    .cqs_civ18w638bbgo9              ( eilekzzyohhmi1zc9n             ),
    .lut7o63_57lmo7p7               ( km0wiz_m85vu7              ),
    .ux5w82gexeytghebefxj5p          ( amrf6pheb_r31ttry2         ),
    .mcgzedty04ejyfth6esf4xrr6cq8   ( m8wn59w0vp8mie4znti5yvp_z4ss  ),
    .gcr859d221zevs7awpmpr7          ( fueq_4_jw0xh5kttcutc         ),
    .fl5ljtet0tf1r18n990sw          (                           ),
    .l5vlj3d                    ( vfoa34j_u2mi                   ),
    .glgiw3s5j7p                    ( yhhl9de6pqf                   ),
    .mxwegalt668qkv                ( f_tcdutrmtyh               )
  );
  n8j4biemqitai_6h20vkz_ himeq5osdhzzep (
    .ri2ziyy                        ( lczv3cn                      ),
    .r46kf                      ( r38027_km3                     ),
    .qgek6hz5rfs6m                 ( qgek6hz5rfs6m                 ),
    .s2jh1nempl                 ( r8_xepajlb3mig             ),
    .agra657i0o0nz9                 ( agra657i0o0nz9                 ),
    .ujh3s3is5                   ( py08rmttc7ogv5p0              ),
    .zitsxnxkg6e                ( zitsxnxkg6e                ),
    .hxqzu4xws6                     ( mvcxu0tbl2d                     ),
    .ef0q7sx70v7r6i                 ( sk1oehg8n4gjg2l9g8              ),
    .l9idxnwgti8jh0lz               ( iysc_d0ypgmxisqnc               ),
    .n06jxxux2kra522pn8          ( n06jxxux2kra522pn8          ),
    .oek_aiemroj9httja91b2           ( oek_aiemroj9httja91b2           ),
    .ysm34bdzkpfwqy                 ( ysm34bdzkpfwqy                 ),
    .mef6pz7wky8                ( mef6pz7wky8                ),
    .h0bszfaqg28q45                ( qb93jt8wbrr9                ),
    .sfc8z6ce                      ( m5vm4xbpja                 ),
    .gopxzi6z                      ( tihou7giktswpm4                 ),
    .jn1vqljcjmhbzhu5c            ( jn1vqljcjmhbzhu5c            ),
    .lo13ulq1cqk5ucx17t            ( lo13ulq1cqk5ucx17t            ),
    .hpx0qqw7eo979f               ( hpx0qqw7eo979f               ),
    .s5upgf3pot8ypw9_              ( s5upgf3pot8ypw9_              ),
    .y5u3u9h83new6z3za            ( y5u3u9h83new6z3za            ),
    .jei_o2zgrfpn2                 ( jei_o2zgrfpn2                 ),
    .f7jojb_ei69nmep             ( f7jojb_ei69nmep             ),
    .an1vq2wnlx7avgy            ( an1vq2wnlx7avgy            ),
    .mvg2uod0f8i5h9__q645            ( mvg2uod0f8i5h9__q645            ),
    .bq6scjvk0k3x6aen99x          ( bq6scjvk0k3x6aen99x          ),
    .hf9ym2a2eh9uc2xbjnxq6ty7141   ( m8wn59w0vp8mie4znti5yvp_z4ss   ),
    .y3op3693r82a7al4x8189cf0hg6n5ux ( dxzxwmk7l2p1dcaw10az4wfxfpstuw ),
    .mcyxv2wkh0eihnrmm6kz5d85h82o ( wgzrl8nu7oudwt6xjlj8yonrmwahm ),
    .vi2yjdqmw4rsfinydju9          ( vi2yjdqmw4rsfinydju9          ), 
    .suu86gfec5_q7q8tmn         ( suu86gfec5_q7q8tmn         ),
    .j_22owq22ygfp83tlkymx0         ( j_22owq22ygfp83tlkymx0         ), 
    .snnj17b9zawct6n7sh         ( snnj17b9zawct6n7sh         ), 
    .nahnyoriw3y4r6rdpdn5jd2        ( nahnyoriw3y4r6rdpdn5jd2        ),
    .rlixu6nnh60an0djhpn6x0j        ( rlixu6nnh60an0djhpn6x0j        ),
    .g5ikzrx34od9pu8jyexvv      ( g5ikzrx34od9pu8jyexvv      ),
    .ileysv9olfjwrm_t236qmf0     ( ileysv9olfjwrm_t236qmf0     ),
    .gc0nysovke_pmgmxzl          ( gc0nysovke_pmgmxzl          ),
    .dvv9js337kdzasybz56e9dx         ( shr7td0e35qguhbsrc         ),
    .vn02561rj8l2z_erne20lhu5        ( j67cz9tdm3e5wtng78q        ),
    .rg7ozwpk7xwi6vdbg8              ( rg7ozwpk7xwi6vdbg8              ),
    .wddz9ajtz98uzxa1y13_rd_6yf    ( wddz9ajtz98uzxa1y13_rd_6yf    ),
    .rjh4rfus0ddh2haeqfvz        ( rjh4rfus0ddh2haeqfvz        ),
    .ntfvn09s31u9_t3w             ( g_kvt0ndiotf8k             ),
    .c4wmn9x0tiqe                ( ykp3rsjs_nw5cspm                ),
    .lh16w9beizuu5b2                 ( dmnh947v4cmkwv7d             ),
    .nhmow92ziyrfc2               ( nhmow92ziyrfc2               ),
    .ntlhx_m4cwv2is                 ( ntlhx_m4cwv2is                 ),
    .px3xebad9kl                 ( px3xebad9kl                 ),
    .gxb5b03yuuk0_                 ( gxb5b03yuuk0_                 ),
    .rjlma4yfh29we                 ( rjlma4yfh29we                 ),
    .k8ur5tmjmxy                   ( k8ur5tmjmxy              ),
    .hnuzxe36tu1kx3                 ( hnuzxe36tu1kx3                 ),
    .galaluy047z                 ( iek3uwep361fjynh            ),
    .u16tcme0kzincfd2h            ( u16tcme0kzincfd2h            ),
    .a4xpl3wgvhzrlyw            ( a4xpl3wgvhzrlyw            ),
    .yqihalm9oqcj35t               ( yqihalm9oqcj35t               ),
    .dvvdm0wywfwyo5sl              ( dvvdm0wywfwyo5sl              ),
    .wwb5bn6954vu                  ( wwb5bn6954vu                  ),
    .o87t4pnz3ylkal6            ( o87t4pnz3ylkal6            ),
    .i2aen5gc13jwm0                 ( i2aen5gc13jwm0                 ),
    .gdayv_v5udtp5x93tt              ( gdayv_v5udtp5x93tt              ),
    .nhlanc0cisb                ( nhlanc0cisb                ),
    .cxh0zffxy9sc6                ( pe7npxqli2dhiy[6]          ),
    .drqmmbcvyc                  ( fueq_4_jw0xh5kttcutc          ),
    .y9nffq1claqkfzysy8            ( nbv789gm7mpl317_d            ),
    .wm7w9dybdwy                   ( wm7w9dybdwy                   ),
    .q3v56zbk1                   ( q3v56zbk1                   ),
    .j5lpulyyl0y6tq               ( j5lpulyyl0y6tq               )
  );
    wire x5qr2q7j6dfvj7p6trg2mwi;
    wire cnsdxe8bn7e3h5pht0k8o62yq_ = ib5wwsurj4ye;
    wire hhq8t3wqjwk0il_w_4_1xm9b83t7kz = fe7a52bvkgasxtht;
    wire o82vvuzpd2mqxk5mo1bdpvcvie = cnsdxe8bn7e3h5pht0k8o62yq_ | hhq8t3wqjwk0il_w_4_1xm9b83t7kz;
    wire ult451dxhwezn_n6569mj0mju = (~hhq8t3wqjwk0il_w_4_1xm9b83t7kz);
sdio_gnrl_dfflr #(1) hdmqu12tli68ti5lg_zhg3ygpufcg1ft7 (o82vvuzpd2mqxk5mo1bdpvcvie, ult451dxhwezn_n6569mj0mju, x5qr2q7j6dfvj7p6trg2mwi, lczv3cn, qgek6hz5rfs6m);
    wire w0wm9vrxpqd2x = (mef6pz7wky8 == 2'b0);
    wire otav382fwxotdqd9mmek7pnb5y8eh3;
   sdio_gnrl_sync #(.DP(2),.DW(1)) pea17uzpycsk_ttgvm4s1y2r (msbig0_o9iuy56ai3d_sc, otav382fwxotdqd9mmek7pnb5y8eh3,qgek6hz5rfs6m,lczv3cn);
    wire m82s342owc2ah5vb0t3tn;
    wire g0m4z_vyoj0tiemwk5b = dxzxwmk7l2p1dcaw10az4wfxfpstuw & (~ph7fazez463s3o5uqlhmy4n) | w0wm9vrxpqd2x;
    wire g_cvrjmszx1jg6om2aay = qtrpk9tmiygq0 & (amrf6pheb_r31ttry2 & (~pe7npxqli2dhiy[6]) | wgzrl8nu7oudwt6xjlj8yonrmwahm);
    wire s2qhiziluw2df3jbrid9uy_ = g0m4z_vyoj0tiemwk5b | g_cvrjmszx1jg6om2aay;
    wire tfbos05t8jkl9scapfclc8u = (~g_cvrjmszx1jg6om2aay);
sdio_gnrl_dfflrs #(1) sir5oqktk_6042pnv0tjvaz9 (s2qhiziluw2df3jbrid9uy_, tfbos05t8jkl9scapfclc8u, m82s342owc2ah5vb0t3tn, lczv3cn, qgek6hz5rfs6m);
    assign hnwzjff0yweh4       = (m82s342owc2ah5vb0t3tn | w0wm9vrxpqd2x) & otav382fwxotdqd9mmek7pnb5y8eh3;
    assign eudx6z1_6           = vwbxx02jcsl2 & (~s5upgf3pot8ypw9_) | sk1oehg8n4gjg2l9g8 & s5upgf3pot8ypw9_ | akskkzkq9vmjg0eoe9ejjrw ;
    wire qyfxoxvdt0jos4xwjvzy9o1;
    assign g6zs6zoy8hq80z          = (  ziefrbio6o9l9mswj9xkv3bd 
                                 | qb23dquc_sc_4bimxkprzzrp2k 
                                 | (gq8_9gnisasvvpn1s3rcr_v & gdayv_v5udtp5x93tt)
                                 ) & (b9w2chb8qxabl | (ai1wz5k_jiipo & qyfxoxvdt0jos4xwjvzy9o1)) & (~j67cz9tdm3e5wtng78q);
    assign a0pn3j81yvryt        = via12_eeh7ahvjwy14mfs9z0 ;
    assign sfuzditpf6xkjs       = (i114yvarem87hdkifmeghxtlav | qb23dquc_sc_4bimxkprzzrp2k);
    assign mal354aby_ublbho        = hoeb6h_8_upz1y0tktfze47ib5 ; 
    assign ns8ebjy455bkn0l     = aej6mvu521r3f_qv20wcn8 ;
    assign qxp17qld1mykfmk7o = (ziefrbio6o9l9mswj9xkv3bd | qb23dquc_sc_4bimxkprzzrp2k | (gq8_9gnisasvvpn1s3rcr_v & gdayv_v5udtp5x93tt)) 
                           & k93yjpylsfe9tgm55o
                           & (gdayv_v5udtp5x93tt ? x5qr2q7j6dfvj7p6trg2mwi : cnwhkjzy3z_gceqcz1h & (~sfc8z6ce));
    assign ujh3s3is5           = {2'b00,py08rmttc7ogv5p0,2'b00,wvjh9zl6os9wmf};
    assign uw36v64wbbn3iguh0       = l__zxgq4uysdbjzx5;
    assign m4v_yf_kn5rznb      = eopkutczkd7pnk;
    assign n657wtw4ds5a48mh29o69q = l64jknb_blswjhga3ahd;
    assign n_vl1e1u80          = u2ja8t400gp;
    wire t2retozb4            = (m85jz7eqgzvfhb | g6zs6zoy8hq80z );
    wire n0ygv3hegu1u075kgkb      = t2retozb4 & (~ki8s7_e0iqtsxj);
    assign qyfxoxvdt0jos4xwjvzy9o1 = ((ai1wz5k_jiipo & f7jojb_ei69nmep & (~lu8g7fc8uj5yxm8b7)) | (ai1wz5k_jiipo & an1vq2wnlx7avgy & (~f7jojb_ei69nmep))) & km0wiz_m85vu7
                                | (ai1wz5k_jiipo & an1vq2wnlx7avgy & f7jojb_ei69nmep & lu8g7fc8uj5yxm8b7 & (~kqxhyn5dk7ga2w4w31oa)) & nsdg4bd8a88tes
                                ;
    assign iysc_d0ypgmxisqnc   =(~r8_xepajlb3mig) & 
                           ( ai1wz5k_jiipo ?  qyfxoxvdt0jos4xwjvzy9o1
                          :  t2retozb4      ? 1'b0 
                          : ((~ai1wz5k_jiipo) & n_vl1e1u80 & ((ysm34bdzkpfwqy & km0wiz_m85vu7) | (~ysm34bdzkpfwqy & eilekzzyohhmi1zc9n)))
                          )
                          ;
    assign fe7a52bvkgasxtht    =
                           t2retozb4 ? qxp17qld1mykfmk7o    
                          : m9ju_obn4pmha   
                          ; 
    assign a8vrqhuhofxl       = n0ygv3hegu1u075kgkb ? uw36v64wbbn3iguh0       : xlamacf6vaj      ; 
    assign tv7jhpskh      = n0ygv3hegu1u075kgkb ? m4v_yf_kn5rznb      : w564a9eqpo1     ; 
    assign pe7npxqli2dhiy = n0ygv3hegu1u075kgkb ? {1'b1,1'b1,n657wtw4ds5a48mh29o69q[5],1'b0,n657wtw4ds5a48mh29o69q[3:0]} : cgsf_4fw_868uixe6u;
    assign usae8bxqvejyr4     = f7jojb_ei69nmep & an1vq2wnlx7avgy & chp_ggs8hwxen & kqxhyn5dk7ga2w4w31oa & nsdg4bd8a88tes 
                          | (~f7jojb_ei69nmep) & (~chp_ggs8hwxen) & (~an1vq2wnlx7avgy) & b9w2chb8qxabl
                          | (~f7jojb_ei69nmep) & (~chp_ggs8hwxen) & an1vq2wnlx7avgy & nsdg4bd8a88tes
                          | (~f7jojb_ei69nmep) & chp_ggs8hwxen & (~an1vq2wnlx7avgy) & b9w2chb8qxabl
                          | (~f7jojb_ei69nmep) & chp_ggs8hwxen & an1vq2wnlx7avgy & prcftr15c7h9ec & nsdg4bd8a88tes
                          | f7jojb_ei69nmep & (~chp_ggs8hwxen) & (~an1vq2wnlx7avgy) & nsdg4bd8a88tes
                          | f7jojb_ei69nmep & (~chp_ggs8hwxen) & an1vq2wnlx7avgy & kqxhyn5dk7ga2w4w31oa & nsdg4bd8a88tes
                          | f7jojb_ei69nmep & chp_ggs8hwxen & (~an1vq2wnlx7avgy) & prcftr15c7h9ec & nsdg4bd8a88tes
                          ;
    assign sfc8z6ce          = ai1wz5k_jiipo ? (cgsf_4fw_868uixe6u[6] ? (nbv789gm7mpl317_d & zqbst5t9k9kcbmxg & prcftr15c7h9ec & m61rfc88ai1yqcno ) : usae8bxqvejyr4 )
                          : t2retozb4 ? mjpt9 
                          : b9w2chb8qxabl
                          ;
    assign mjpt9          = (k93yjpylsfe9tgm55o ? (prcftr15c7h9ec & b9w2chb8qxabl & nsdg4bd8a88tes) : nsdg4bd8a88tes);
endmodule
module dkm9ot9b2rj7y4kogzcu
(
    output wire         m9784q7ukmn3si58c70oo_hls,
    input wire         r46kf,
    input wire         ri2ziyy,
    input wire         qgek6hz5rfs6m,
    input wire         wiu1s04x6zdw,
    input wire         ai6qc7womk1r,
    input wire         s2jh1nempl,
    input wire   [5:0] hqepeupn1i672,
    input wire  [31:0] d7n__4eepibg1b,
    input wire   [7:0] o11gjfkp0o48qa6,
    input wire         w3pibny_m,
    input wire         px3xebad9kl,
    input wire         ntlhx_m4cwv2is,
    input wire         wwb5bn6954vu,
    input wire         hc5muz31u4,
    input wire         opcd3lqf_2oq,
    input wire         udqaodtzx8vqb2dyqv3w6wxemu,
    input wire         galaluy047z,
    input wire  [7:0]  g1880fxg1,
    input wire  [15:0] xn36o896k9xctcxsrk,
    input wire  [15:0] dcfbrmxklvk3k527hpd,
    input wire  [15:0] p2nd00iq0ot6z_2r1h,
    input wire         q6xj2owp6tumpa0_w2hh ,
    input wire         ubfebspi89cdng2_9  ,
    input wire         jc3av1ye6lr9h , 
    input wire         o87t4pnz3ylkal6 , 
    input wire         s0jmcxeq6s1h0asago ,
    input wire         dvv9js337kdzasybz56e9dx,
    input wire         vn02561rj8l2z_erne20lhu5, 
    input wire         qrpvq1k7fhmyecbaiwh9c, 
    input wire         f7jojb_ei69nmep, 
    input wire         an1vq2wnlx7avgy,
    input wire         ntfvn09s31u9_t3w,
    input wire         c4wmn9x0tiqe,
    input wire         lh16w9beizuu5b2,
    input wire         f6c5u_qu3x_b68tj8xt4k2zy7,
    output wire [127:0] ynni_e015eh,
    output wire [127:0] l492_zdzcnnei4mb,
    output wire         cqs_civ18w638bbgo9,
    output wire         lut7o63_57lmo7p7,
    output wire         iydyd8j,
    output wire   [5:0] cvsvk6xosj0,
    output wire         f0mni1qb4r5w,
    output wire [15:0]  st_xbxcknhpf,
    output wire         hb4y0ustf02qb,
    output wire         mcgzedty04ejyfth6esf4xrr6cq8,
    output wire         ux5w82gexeytghebefxj5p,
    output wire         gcr859d221zevs7awpmpr7,
    output wire         fl5ljtet0tf1r18n990sw, 
    input  wire         glgiw3s5j7p,
    output wire         l5vlj3d,
    output wire         mxwegalt668qkv
  );
  localparam q3a_qhn0oez6_qdw42u8s       = 6'b000001;
  localparam v0hhe9qxzuhhudtnf13fb87     = 6'b000010;
  localparam s13b4jxcpo94wa6jrqjzj587  = 6'b000011;
  localparam ul6tm3dcrmxwpkzx49kfgcto113sh = 6'b000100;
  localparam oj1ivcnekf       = 4'h0 ;       
  localparam xp1ywa6n       = 4'h1 ;  
  localparam w1h5vy1qq52z  = 4'h2 ;       
  localparam rrlsospx6sjar4   = 4'h3 ;        
  localparam hi8185471wkfyi9    = 4'h4 ;        
  localparam o1109sg0s4y_gn     = 4'h5 ;          
  localparam zm1j07j8v6tjx   = 4'h6 ;              
  localparam z5hlzuxfdfu     = 4'h7 ;           
  localparam o6gkn52i3g579i   = 4'h8 ;        
  localparam h7lnf2zapq8vo8zf7xnhcp  = 4'h9 ;     
  localparam ur8r11o0daif     = 4'ha ;     
  localparam dt73g95xelrq   = 4'hb ;   
  localparam ectin_osl     = 4'hc ;    
  localparam fcpgtbcklx8   = 4'hd ;    
  localparam kmwl_8o3l2erbib   = 4'he ;    
  localparam ws3ko1rvdjz299ham = 4;
  wire       ogwbfmqpmwsu;
  wire       toxvtnkxpanrf4644sqf;
  wire       oaskgu6kaundv;
  wire [15:0] x0gqe67kb9sud;
  wire [6:0] yvsbjhg;
  wire       msu6hae3td;
  wire       a2y_p5uge6to;
  wire       ku1o1xek2lz;
  wire       an6dkw9hhw5m_f;
  wire       vg0d7ni5a9wfdgv;
  wire       dpeuk5xi              = o11gjfkp0o48qa6[0];
  wire [15:0]mppwc0f57             = o11gjfkp0o48qa6[1] ? 16'd133 : 16'd37 ;
  wire       e6bd2jc7_zj9q             = o11gjfkp0o48qa6[2];
  wire       soudyfw29             = o11gjfkp0o48qa6[3];
  wire       w_88bplku5ik            = o11gjfkp0o48qa6[4];
  wire       cjnz7ru4n9vk0cpd5_       = o11gjfkp0o48qa6[5];
  wire       ux7zrh_oequxxxqndaz6xf = o11gjfkp0o48qa6[6];
  wire       hmcqg_vi9c0du1zwuv3dd1oss = o11gjfkp0o48qa6[7];
  wire       bpbdner0qg23w1s = ~g1880fxg1[0];
  wire       ai1wz5k_jiipo = dvv9js337kdzasybz56e9dx | vn02561rj8l2z_erne20lhu5;
  wire t4131jmbnymobrhjm5j;
  wire [ws3ko1rvdjz299ham-1:0] aeiokfzwts8fc4;
  wire [ws3ko1rvdjz299ham-1:0] j9e9y0z9nr7hkr9tx;
  wire [ws3ko1rvdjz299ham-1:0] ifm4f61h58jxyo;
  wire [ws3ko1rvdjz299ham-1:0] ijhwll59ny41qsoqt;
  wire [ws3ko1rvdjz299ham-1:0] smdw9y2sx_wqe1l4e6u4;
  wire [ws3ko1rvdjz299ham-1:0] kq0_9jcwsk2_89a4cxjse89;
  wire [ws3ko1rvdjz299ham-1:0] yql0ujpi41lq_ea_hlg4;
  wire [ws3ko1rvdjz299ham-1:0] pa3vt3yxwom3dckzr;
  wire [ws3ko1rvdjz299ham-1:0] vn4nr0tnalv2g3hsyplh7;
  wire [ws3ko1rvdjz299ham-1:0] ajrb0zbh0pfc5be7hv;
  wire [ws3ko1rvdjz299ham-1:0] gtzhwct5_lzh5d81xn_qy2z;
  wire [ws3ko1rvdjz299ham-1:0] gz9vs23momwvkpzhgdsd;
  wire [ws3ko1rvdjz299ham-1:0] fv134bfyn5o6irrq9r4pb2r;
  wire [ws3ko1rvdjz299ham-1:0] id8yd3i7tw6vbjqu_;      
  wire [ws3ko1rvdjz299ham-1:0] v6ia5i1hosw8zwnbsw;      
  wire [ws3ko1rvdjz299ham-1:0] m8wgtqtw3q8dp1flp9q;      
  wire [ws3ko1rvdjz299ham-1:0] zo9q4t25_3a99conzycmhx;      
  wire f86884rwtdpj4yjo9ubx;
  wire h4qbvxwxt49p0ncmjxcb;
  wire fs6ztpipuxlpyxv0ib2vw7ygt;
  wire lwbbu7phddob_jskmwap9m7g;
  wire yi5mrwf4_1fxc8xepgbv75;
  wire etvhkv1lp03km76qfnx8y4;
  wire klyx_f6kq8fo1mv_vz9vwacb;
  wire kzhloeccbudrt_as8_xpg6u;
  wire q6y8gft_t7zvrv4ov9sc5yy;
  wire gf5cxtwreo0hbgnlcgnvccsma;
  wire o02qvazqk7h10vsyr9n9se5_;
  wire ldic36ub7bs1__ux7m48ey3i;   
  wire rvj3b6axho03po9slrgzsymesff_;   
  wire ozr6w8sftjyfmifp21e_srv;   
  wire utrdl2xbauc1v8ap0a4hnivwrjbqxp;   
  wire gv3cqc0xjsdt2l_gn9yg       = (j9e9y0z9nr7hkr9tx == oj1ivcnekf       );
  wire k_d8ubsroodv2n7sci31a71       = (j9e9y0z9nr7hkr9tx == xp1ywa6n       );
  wire cqrv5q1h8nr4zfgtzi53ea8  = (j9e9y0z9nr7hkr9tx == w1h5vy1qq52z  );
  wire zvxa5ha3xtxrm_otprvmzv   = (j9e9y0z9nr7hkr9tx == rrlsospx6sjar4   );
  wire rzh_ifko8lys5__yn2h3jh5lof    = (j9e9y0z9nr7hkr9tx == hi8185471wkfyi9    );
  wire k1f4zr60v9h1pc01wc8y     = (j9e9y0z9nr7hkr9tx == o1109sg0s4y_gn     );
  wire u_wyia52cnfyu7wr6tki5l   = (j9e9y0z9nr7hkr9tx == zm1j07j8v6tjx   );
  wire ft89lx1381fhl6_41gyv9h     = (j9e9y0z9nr7hkr9tx == z5hlzuxfdfu     );
  wire ctyjchlb_ew2alvt862388s1j   = (j9e9y0z9nr7hkr9tx == o6gkn52i3g579i   );
  wire rcjctodzmesx_137hty3cbqrcsaga = (j9e9y0z9nr7hkr9tx == h7lnf2zapq8vo8zf7xnhcp    );
  wire bo1a4j65x761sp_q8eqr5ha8     = (j9e9y0z9nr7hkr9tx == ur8r11o0daif     );
  wire yiu_3s290ga_1r4a_4mvqwkz98i   = (j9e9y0z9nr7hkr9tx == dt73g95xelrq   );
  wire t604ss4q7elas44sf22nht0     = (j9e9y0z9nr7hkr9tx == ectin_osl     );
  wire i9ecmh94n79cy6guosm5nf8bhu   = (j9e9y0z9nr7hkr9tx == fcpgtbcklx8   );
  wire hpxct8s__mqhe5wm489580   = (j9e9y0z9nr7hkr9tx == kmwl_8o3l2erbib   );
 wire jub5uvbqqfph25i9vi6vgfn;
  wire b1e345orqvnv781aair8wkih = ai6qc7womk1r & (~gv3cqc0xjsdt2l_gn9yg) & (~o87t4pnz3ylkal6);
  wire y_u5t5j9zv0pnymdipxbso1dk = gv3cqc0xjsdt2l_gn9yg & px3xebad9kl;
  wire ct1xghyiw1riqb43oq7be7vi = b1e345orqvnv781aair8wkih;
  wire cx4caj06eqvrrwt3dibid23v = b1e345orqvnv781aair8wkih | y_u5t5j9zv0pnymdipxbso1dk;
sdio_gnrl_dfflr #(1) p1d9e767oysjvb5j45yfc75lysm5ynydg11o (cx4caj06eqvrrwt3dibid23v, ct1xghyiw1riqb43oq7be7vi, jub5uvbqqfph25i9vi6vgfn, ri2ziyy, r46kf);
  wire seik4p0y_0lsvb5wp5t6;
  wire o5d1s3nf9k_tl83053 = ai6qc7womk1r ;
  wire nz6fo4b0vr1vbqoaggq_ = px3xebad9kl;
  wire wfaz43zsa48gcn63yc6 = o5d1s3nf9k_tl83053;
  wire k8rk05vcfrsv_yjt_1pr48 = o5d1s3nf9k_tl83053 | nz6fo4b0vr1vbqoaggq_;
sdio_gnrl_dfflr #(1) tpoyf3hfqlt27ibkrzsxwt82bl93g9l (k8rk05vcfrsv_yjt_1pr48, wfaz43zsa48gcn63yc6, seik4p0y_0lsvb5wp5t6, ri2ziyy, r46kf);
  wire sxsobiqbwc2zdh6 = (seik4p0y_0lsvb5wp5t6 | jub5uvbqqfph25i9vi6vgfn);
  assign f86884rwtdpj4yjo9ubx       = gv3cqc0xjsdt2l_gn9yg & sxsobiqbwc2zdh6; 
  assign h4qbvxwxt49p0ncmjxcb       = k_d8ubsroodv2n7sci31a71 & ogwbfmqpmwsu ;
  assign fs6ztpipuxlpyxv0ib2vw7ygt  = cqrv5q1h8nr4zfgtzi53ea8 & ( (~w3pibny_m) | ogwbfmqpmwsu) ;
  assign lwbbu7phddob_jskmwap9m7g   = zvxa5ha3xtxrm_otprvmzv;
  assign yi5mrwf4_1fxc8xepgbv75    = rzh_ifko8lys5__yn2h3jh5lof;
  assign etvhkv1lp03km76qfnx8y4     = k1f4zr60v9h1pc01wc8y;
  assign klyx_f6kq8fo1mv_vz9vwacb   = u_wyia52cnfyu7wr6tki5l & ogwbfmqpmwsu;
  assign kzhloeccbudrt_as8_xpg6u     = ft89lx1381fhl6_41gyv9h & ogwbfmqpmwsu;
  assign q6y8gft_t7zvrv4ov9sc5yy   = ctyjchlb_ew2alvt862388s1j & ((~glgiw3s5j7p) | ogwbfmqpmwsu);
  assign gf5cxtwreo0hbgnlcgnvccsma     = bo1a4j65x761sp_q8eqr5ha8;
  assign o02qvazqk7h10vsyr9n9se5_   = yiu_3s290ga_1r4a_4mvqwkz98i & ogwbfmqpmwsu;
  assign ldic36ub7bs1__ux7m48ey3i     = t604ss4q7elas44sf22nht0 & ogwbfmqpmwsu;
  assign rvj3b6axho03po9slrgzsymesff_   = i9ecmh94n79cy6guosm5nf8bhu & ogwbfmqpmwsu;
  assign ozr6w8sftjyfmifp21e_srv   = hpxct8s__mqhe5wm489580 & ogwbfmqpmwsu;
  assign utrdl2xbauc1v8ap0a4hnivwrjbqxp = rcjctodzmesx_137hty3cbqrcsaga & ogwbfmqpmwsu ; 
  wire qencsbn23fg20kvy = (dvv9js337kdzasybz56e9dx | (~hmcqg_vi9c0du1zwuv3dd1oss));
  assign ifm4f61h58jxyo            = w_88bplku5ik ? kmwl_8o3l2erbib 
                                   : qencsbn23fg20kvy ? oj1ivcnekf
                                   : rrlsospx6sjar4;
  assign m8wgtqtw3q8dp1flp9q        = qencsbn23fg20kvy ? oj1ivcnekf : rrlsospx6sjar4;
  assign zo9q4t25_3a99conzycmhx      = oj1ivcnekf;
  assign ijhwll59ny41qsoqt            = udqaodtzx8vqb2dyqv3w6wxemu ? h7lnf2zapq8vo8zf7xnhcp : oj1ivcnekf;
  assign smdw9y2sx_wqe1l4e6u4       = xp1ywa6n;
  assign kq0_9jcwsk2_89a4cxjse89        = o1109sg0s4y_gn;
  assign yql0ujpi41lq_ea_hlg4         = dpeuk5xi ? fcpgtbcklx8 : xp1ywa6n;
  assign pa3vt3yxwom3dckzr          = zm1j07j8v6tjx;
  assign vn4nr0tnalv2g3hsyplh7        = z5hlzuxfdfu;
  assign ajrb0zbh0pfc5be7hv          = hi8185471wkfyi9;
  assign gtzhwct5_lzh5d81xn_qy2z        = (~glgiw3s5j7p) ? ur8r11o0daif : oj1ivcnekf;
  assign gz9vs23momwvkpzhgdsd          = (~glgiw3s5j7p) ? dt73g95xelrq : oj1ivcnekf;
  assign fv134bfyn5o6irrq9r4pb2r        = e6bd2jc7_zj9q ? ectin_osl : xp1ywa6n ;
  assign id8yd3i7tw6vbjqu_          = soudyfw29 ? w1h5vy1qq52z : xp1ywa6n;
  assign v6ia5i1hosw8zwnbsw        = o6gkn52i3g579i ;
  assign ux5w82gexeytghebefxj5p = yi5mrwf4_1fxc8xepgbv75 & px3xebad9kl;
  assign mcgzedty04ejyfth6esf4xrr6cq8 = i9ecmh94n79cy6guosm5nf8bhu;
  assign t4131jmbnymobrhjm5j = f86884rwtdpj4yjo9ubx
                        | h4qbvxwxt49p0ncmjxcb
                        | fs6ztpipuxlpyxv0ib2vw7ygt
                        | lwbbu7phddob_jskmwap9m7g
                        | yi5mrwf4_1fxc8xepgbv75
                        | etvhkv1lp03km76qfnx8y4
                        | klyx_f6kq8fo1mv_vz9vwacb
                        | kzhloeccbudrt_as8_xpg6u
                        | q6y8gft_t7zvrv4ov9sc5yy
                        | gf5cxtwreo0hbgnlcgnvccsma
                        | o02qvazqk7h10vsyr9n9se5_
                        | ldic36ub7bs1__ux7m48ey3i     
                        | rvj3b6axho03po9slrgzsymesff_     
                        | ozr6w8sftjyfmifp21e_srv 
                        | utrdl2xbauc1v8ap0a4hnivwrjbqxp    
                        ;   
  assign aeiokfzwts8fc4 =   ({ws3ko1rvdjz299ham{ f86884rwtdpj4yjo9ubx       }} ) & ifm4f61h58jxyo
                          | ({ws3ko1rvdjz299ham{ h4qbvxwxt49p0ncmjxcb       }} ) & ijhwll59ny41qsoqt
                          | ({ws3ko1rvdjz299ham{ fs6ztpipuxlpyxv0ib2vw7ygt  }} ) & smdw9y2sx_wqe1l4e6u4
                          | ({ws3ko1rvdjz299ham{ lwbbu7phddob_jskmwap9m7g   }} ) & kq0_9jcwsk2_89a4cxjse89
                          | ({ws3ko1rvdjz299ham{ yi5mrwf4_1fxc8xepgbv75    }} ) & yql0ujpi41lq_ea_hlg4
                          | ({ws3ko1rvdjz299ham{ etvhkv1lp03km76qfnx8y4     }} ) & pa3vt3yxwom3dckzr
                          | ({ws3ko1rvdjz299ham{ klyx_f6kq8fo1mv_vz9vwacb   }} ) & vn4nr0tnalv2g3hsyplh7
                          | ({ws3ko1rvdjz299ham{ kzhloeccbudrt_as8_xpg6u     }} ) & ajrb0zbh0pfc5be7hv
                          | ({ws3ko1rvdjz299ham{ q6y8gft_t7zvrv4ov9sc5yy   }} ) & gtzhwct5_lzh5d81xn_qy2z
                          | ({ws3ko1rvdjz299ham{ gf5cxtwreo0hbgnlcgnvccsma     }} ) & gz9vs23momwvkpzhgdsd
                          | ({ws3ko1rvdjz299ham{ o02qvazqk7h10vsyr9n9se5_   }} ) & fv134bfyn5o6irrq9r4pb2r
                          | ({ws3ko1rvdjz299ham{ ldic36ub7bs1__ux7m48ey3i     }} ) & id8yd3i7tw6vbjqu_ 
                          | ({ws3ko1rvdjz299ham{ rvj3b6axho03po9slrgzsymesff_   }} ) & v6ia5i1hosw8zwnbsw 
                          | ({ws3ko1rvdjz299ham{ ozr6w8sftjyfmifp21e_srv   }} ) & m8wgtqtw3q8dp1flp9q 
                          | ({ws3ko1rvdjz299ham{ utrdl2xbauc1v8ap0a4hnivwrjbqxp }} ) & zo9q4t25_3a99conzycmhx 
                          ;
   wire y5vi74vo8hfzs6n = t4131jmbnymobrhjm5j & px3xebad9kl ;
sdio_gnrl_dfflr #(ws3ko1rvdjz299ham) ad0t9ad0ocexhh2o2f35 (y5vi74vo8hfzs6n, aeiokfzwts8fc4, j9e9y0z9nr7hkr9tx, ri2ziyy, r46kf);
  wire otwp3_uof7dtm;
  wire umna453jjaohbtabp = oaskgu6kaundv;
  wire jy76eyk1m8a5uxyzo = ogwbfmqpmwsu | fs6ztpipuxlpyxv0ib2vw7ygt;
  wire gqqqx3gisuv2g0rmyw = umna453jjaohbtabp;
  wire ok_rkg38je130ddy6jk = umna453jjaohbtabp | jy76eyk1m8a5uxyzo;
sdio_gnrl_dfflr #(1) uln1aakdbsoc8fj0oy7c2i3aaj9 (ok_rkg38je130ddy6jk, gqqqx3gisuv2g0rmyw, otwp3_uof7dtm, ri2ziyy, r46kf);
  wire [15:0] ws5sf0h;
  wire [15:0] vhf0y78xf9pk = oaskgu6kaundv ? x0gqe67kb9sud
                     : ogwbfmqpmwsu ? 16'hffff
                     : otwp3_uof7dtm ? ws5sf0h - 16'h1
                     : ws5sf0h
                     ;
  wire z94f9sb1fld = oaskgu6kaundv 
               | ogwbfmqpmwsu 
               | otwp3_uof7dtm
               ;
  wire l1bouo9 = z94f9sb1fld & px3xebad9kl;
sdio_gnrl_dfflr #(16) ss2qjuoihnu7bp8p495wg (l1bouo9, vhf0y78xf9pk, ws5sf0h, ri2ziyy, r46kf);
  assign gcr859d221zevs7awpmpr7 = k_d8ubsroodv2n7sci31a71 & (ws5sf0h == 16'hf) & px3xebad9kl;
  assign oaskgu6kaundv = etvhkv1lp03km76qfnx8y4 
                     | klyx_f6kq8fo1mv_vz9vwacb 
                     | yi5mrwf4_1fxc8xepgbv75 
                     | gf5cxtwreo0hbgnlcgnvccsma & (~glgiw3s5j7p)
                     | (f86884rwtdpj4yjo9ubx & w_88bplku5ik )
                     | o02qvazqk7h10vsyr9n9se5_
                     | ldic36ub7bs1__ux7m48ey3i
                     | fs6ztpipuxlpyxv0ib2vw7ygt
                     | rvj3b6axho03po9slrgzsymesff_
                     | h4qbvxwxt49p0ncmjxcb & udqaodtzx8vqb2dyqv3w6wxemu
                     ;
  assign x0gqe67kb9sud = etvhkv1lp03km76qfnx8y4   ? 16'd37
                      : rvj3b6axho03po9slrgzsymesff_ ? dcfbrmxklvk3k527hpd 
                      : (yi5mrwf4_1fxc8xepgbv75 & dpeuk5xi) ? 16'd1
                      : klyx_f6kq8fo1mv_vz9vwacb ? 16'd6
                      : (f86884rwtdpj4yjo9ubx & w_88bplku5ik ) ? xn36o896k9xctcxsrk 
                      : (gf5cxtwreo0hbgnlcgnvccsma & (~glgiw3s5j7p)) ? mppwc0f57
                      : (ldic36ub7bs1__ux7m48ey3i & soudyfw29 ) ? 16'hffff
                      : (h4qbvxwxt49p0ncmjxcb & udqaodtzx8vqb2dyqv3w6wxemu)  ?  p2nd00iq0ot6z_2r1h 
                      : (o02qvazqk7h10vsyr9n9se5_ & e6bd2jc7_zj9q) ? 16'd6
                      : 16'd15
                      ;
  assign ogwbfmqpmwsu = (ws5sf0h == 16'h0);
  assign toxvtnkxpanrf4644sqf = (ws5sf0h == 16'h7);
  wire m4w63d_des3uphoogx_yjwm;
  wire p7l9fgikdnzfpsc4ftvvdfr = ozr6w8sftjyfmifp21e_srv;
sdio_gnrl_dfflr #(1) sbbmk8b5mrop8zzo409uv51 (p7l9fgikdnzfpsc4ftvvdfr, p7l9fgikdnzfpsc4ftvvdfr, m4w63d_des3uphoogx_yjwm, ri2ziyy, qgek6hz5rfs6m);
  wire djvwqkkxdym;
  wire mjpt9 = ( ( (h4qbvxwxt49p0ncmjxcb & (~udqaodtzx8vqb2dyqv3w6wxemu))
               | utrdl2xbauc1v8ap0a4hnivwrjbqxp 
               | (q6y8gft_t7zvrv4ov9sc5yy & (gtzhwct5_lzh5d81xn_qy2z == oj1ivcnekf))
               | (gf5cxtwreo0hbgnlcgnvccsma & (gz9vs23momwvkpzhgdsd == oj1ivcnekf))
               | f86884rwtdpj4yjo9ubx & qencsbn23fg20kvy
                 ) & px3xebad9kl) ? 1'b1 : 1'b0 ;
sdio_gnrl_dffr #(1) na9_8sb_yoph_v1kqwk6g6 (mjpt9, djvwqkkxdym, ri2ziyy, r46kf);
  wire qzc235l8;
  wire dm514aruoesrj6t = f86884rwtdpj4yjo9ubx ;
  wire ij32gbzczko_vc = djvwqkkxdym; 
  wire arhqmctdgwkfd = dm514aruoesrj6t | ij32gbzczko_vc;
  wire ak0t81nxwk8c4f4 = (~ij32gbzczko_vc) ;
sdio_gnrl_dfflr #(1) yrj_fbmanbda7ow6 (arhqmctdgwkfd, ak0t81nxwk8c4f4, qzc235l8, ri2ziyy, r46kf);
  assign f0mni1qb4r5w = galaluy047z ? qzc235l8 : 1'b1 ; 
  wire pdef4u11fme32evvp =  (sxsobiqbwc2zdh6 & gv3cqc0xjsdt2l_gn9yg);
  wire [37:0] awncarja;
  wire [37:0] evbdz983hs = pdef4u11fme32evvp ? {hqepeupn1i672,d7n__4eepibg1b} 
                      : u_wyia52cnfyu7wr6tki5l ? {awncarja[36:0],1'b0}
                      : awncarja
                      ;
  wire soa7xyoenbg3 = pdef4u11fme32evvp  | u_wyia52cnfyu7wr6tki5l;
  wire imc8vykb = soa7xyoenbg3 & px3xebad9kl ;
sdio_gnrl_dfflr #(38) kzozv7umwx0w_3fgbjh (imc8vykb, evbdz983hs, awncarja, ri2ziyy, r46kf);
  wire lhe98fpuscqsqgp7vctbdtd = s0jmcxeq6s1h0asago & o87t4pnz3ylkal6;
  wire bkufmx6w993s2s3reupp =  (~lhe98fpuscqsqgp7vctbdtd);
  wire [135:0] bhwkch;
  wire fi4peqbfs = yiu_3s290ga_1r4a_4mvqwkz98i;
  wire ljcb1vys = 1'b0;
  wire ot8leza = fi4peqbfs ;
  wire tjs63pchi = ot8leza & px3xebad9kl & bkufmx6w993s2s3reupp | ljcb1vys;
  wire [135:0] nh9fjvd0 = ljcb1vys ? 136'b0 : {bhwkch[134:0],glgiw3s5j7p};
sdio_gnrl_dfflr #(136) rvdcu23g055hu8l11 (tjs63pchi, nh9fjvd0, bhwkch, ri2ziyy, qgek6hz5rfs6m);
  wire [135:0] oe14dzsct_ub;
  wire f6bwog38ovyqrxh2 = yiu_3s290ga_1r4a_4mvqwkz98i;
  wire los12cqd2itvzrvtf =  1'b0;
  wire z279tjyeswwmy = f6bwog38ovyqrxh2 ;
  wire s97m5kyorndyey5 = z279tjyeswwmy & px3xebad9kl & lhe98fpuscqsqgp7vctbdtd | los12cqd2itvzrvtf;
  wire [135:0] sv2zw5_2cge16k = los12cqd2itvzrvtf ? 136'b0 : {oe14dzsct_ub[134:0],glgiw3s5j7p};
sdio_gnrl_dfflr #(136) jc1o8tu2qaa_qt3wmwlauhse (s97m5kyorndyey5, sv2zw5_2cge16k, oe14dzsct_ub, ri2ziyy, qgek6hz5rfs6m);
  wire [6:0] wto1cx8q3hcg7;
  wire kzsnwtel8dz = t604ss4q7elas44sf22nht0;
  wire pzyr848_9x765p0n =  1'b0;
  wire kni2gxd45ba797k = kzsnwtel8dz | pzyr848_9x765p0n;
  wire h2dy3j5_6h = kni2gxd45ba797k & px3xebad9kl & bkufmx6w993s2s3reupp;
  wire [6:0] bgpkuucf166nlxb2 = pzyr848_9x765p0n ? 7'b0 : {wto1cx8q3hcg7[5:0],glgiw3s5j7p};
sdio_gnrl_dfflr #(7) jeueaibwc7hpz9dbe09mpt (h2dy3j5_6h, bgpkuucf166nlxb2, wto1cx8q3hcg7, ri2ziyy, qgek6hz5rfs6m);
  wire [6:0] uz9aix1ivdpo84l38k;
  wire tppvzgb8euvuw55m = t604ss4q7elas44sf22nht0;
  wire q6iroiqahdwss_jux8g =  1'b0;
  wire zuz5q5nx86yogfdeheov = tppvzgb8euvuw55m | q6iroiqahdwss_jux8g;
  wire olmzcfv_b8zl8zdp5pj = zuz5q5nx86yogfdeheov & px3xebad9kl & lhe98fpuscqsqgp7vctbdtd;
  wire [6:0] fs6yfniboxpz387h = q6iroiqahdwss_jux8g ? 7'b0 : {uz9aix1ivdpo84l38k[5:0],glgiw3s5j7p};
sdio_gnrl_dfflr #(7) o2cqtj945fz95us3kah2nle08r072k (olmzcfv_b8zl8zdp5pj, fs6yfniboxpz387h, uz9aix1ivdpo84l38k, ri2ziyy, qgek6hz5rfs6m);
  wire nd1njz4099opn = (ctyjchlb_ew2alvt862388s1j & ogwbfmqpmwsu );
  wire x02yzde7lexqn = (bo1a4j65x761sp_q8eqr5ha8 & glgiw3s5j7p    );
  wire rjp5jrbirtoon_sdj5fo6 = rcjctodzmesx_137hty3cbqrcsaga & ogwbfmqpmwsu  & (~opcd3lqf_2oq);
  wire xr25j869o9e2kuntawnc = (rcjctodzmesx_137hty3cbqrcsaga | k_d8ubsroodv2n7sci31a71) & g1880fxg1[0] & udqaodtzx8vqb2dyqv3w6wxemu;
  wire f7noamolmgzcew5i5vq7pl;
  wire ey_ch82qyh14c857bacgs5if;
  sdio_gnrl_sync #(.DP(2),.DW(1)) hycpgmtoi_n2ats27mmf_f (xr25j869o9e2kuntawnc, f7noamolmgzcew5i5vq7pl, qgek6hz5rfs6m , ri2ziyy);
sdio_gnrl_dffr #(1) jvsf8xe5jupm6piom04b4bgn09j (f7noamolmgzcew5i5vq7pl, ey_ch82qyh14c857bacgs5if ,ri2ziyy ,qgek6hz5rfs6m);
  assign fl5ljtet0tf1r18n990sw = f7noamolmgzcew5i5vq7pl & (~ey_ch82qyh14c857bacgs5if) & jc3av1ye6lr9h;
  wire li2sejo_au553c2cvl = (cqrv5q1h8nr4zfgtzi53ea8 & ogwbfmqpmwsu)&(~opcd3lqf_2oq) 
                      | rjp5jrbirtoon_sdj5fo6 & bpbdner0qg23w1s & (~galaluy047z) 
                      ;
  wire ct_bs195m91pq38c7zvt = ( (   ((wto1cx8q3hcg7 != yvsbjhg)      & bkufmx6w993s2s3reupp) 
                              | ((uz9aix1ivdpo84l38k != yvsbjhg) & lhe98fpuscqsqgp7vctbdtd)
                            ) & k_d8ubsroodv2n7sci31a71 & dpeuk5xi
                          ) 
                          & cjnz7ru4n9vk0cpd5_;
  wire zr0yob3tiviyjfvh1eb4 =( (gv3cqc0xjsdt2l_gn9yg & seik4p0y_0lsvb5wp5t6  ) 
                        | nd1njz4099opn 
                        | x02yzde7lexqn 
                        | li2sejo_au553c2cvl
                        | ct_bs195m91pq38c7zvt 
                        ) ? 1'b1 : 1'b0;
  assign st_xbxcknhpf = {1'b0,uz9aix1ivdpo84l38k,1'b0,wto1cx8q3hcg7};
  wire [5:0] gzsudkkux20;
  wire [5:0] zgkty0kh1op3 = nd1njz4099opn  ? (gzsudkkux20 | q3a_qhn0oez6_qdw42u8s)
                      : x02yzde7lexqn   ? (gzsudkkux20 | v0hhe9qxzuhhudtnf13fb87)
                      : li2sejo_au553c2cvl ? (gzsudkkux20 | s13b4jxcpo94wa6jrqjzj587)
                      : ct_bs195m91pq38c7zvt ? (gzsudkkux20 | ul6tm3dcrmxwpkzx49kfgcto113sh)
                      : 6'h0
                      ;
  wire phbrqkkvb5ogwb = zr0yob3tiviyjfvh1eb4;
  wire p3xi9ecjjdtvj = wiu1s04x6zdw;
  wire q6p_jiasjo5vu3c = phbrqkkvb5ogwb ;
  wire qmzoul0xz1t = q6p_jiasjo5vu3c & px3xebad9kl | p3xi9ecjjdtvj;
  wire [5:0] v3if5w8h9_arx = wiu1s04x6zdw ? 6'b0 : zgkty0kh1op3;
sdio_gnrl_dfflr #(6) a0blfz41sw7ywr1ie4s9 (qmzoul0xz1t, v3if5w8h9_arx, gzsudkkux20, ri2ziyy, qgek6hz5rfs6m);
  wire nq827h_m_y5rih2t69 = m4w63d_des3uphoogx_yjwm & (dvv9js337kdzasybz56e9dx | f6c5u_qu3x_b68tj8xt4k2zy7);
  wire w1il_zc102dzgeoxx0psvm = zvxa5ha3xtxrm_otprvmzv 
                             | k1f4zr60v9h1pc01wc8y 
                             | u_wyia52cnfyu7wr6tki5l
                             | ft89lx1381fhl6_41gyv9h
                             | rzh_ifko8lys5__yn2h3jh5lof
                             | nq827h_m_y5rih2t69
                             | c4wmn9x0tiqe
                             | lh16w9beizuu5b2
                             ;
  wire ssm9g0q = (zvxa5ha3xtxrm_otprvmzv | nq827h_m_y5rih2t69 | c4wmn9x0tiqe) ? 1'b0      
               : u_wyia52cnfyu7wr6tki5l ? awncarja[37] 
               : ft89lx1381fhl6_41gyv9h   ? a2y_p5uge6to 
               : 1'b1                               
               ;
  wire fhdw0e9huy4 = w1il_zc102dzgeoxx0psvm ? 1'b0 : 1'b1;
  assign an6dkw9hhw5m_f = zvxa5ha3xtxrm_otprvmzv ? 1'b1 : 1'b0 ;
  assign ku1o1xek2lz = ( k1f4zr60v9h1pc01wc8y 
                    | u_wyia52cnfyu7wr6tki5l
                    | yiu_3s290ga_1r4a_4mvqwkz98i
                    ) ? 1'b1 : 1'b0;
  assign vg0d7ni5a9wfdgv = ft89lx1381fhl6_41gyv9h ? 1'b1 : 1'b0;
  wire hyewxy790up;
  wire v09kw7pbzu = ssm9g0q;
  wire cyum6p2c4vu4i = (ntlhx_m4cwv2is | c4wmn9x0tiqe | lh16w9beizuu5b2) ;
sdio_gnrl_dfflrs #(1) u5d_afxhyy_og50_p7t_0l (cyum6p2c4vu4i, v09kw7pbzu, hyewxy790up, ri2ziyy, r46kf);
  wire zm9dojo_y9bh;
  wire sxuxlcr02dsi0ovd = fhdw0e9huy4;
  wire et56ktuhatcxct4 = cyum6p2c4vu4i;
sdio_gnrl_dfflrs #(1) u943nv8e377_4avciw6iwxob (et56ktuhatcxct4, sxuxlcr02dsi0ovd, zm9dojo_y9bh, ri2ziyy, r46kf);
  wire e8jrq5f_hlyojnscwu7c1np;
  wire wrioumn1evcdoqwke4imcm6kto = ux7zrh_oequxxxqndaz6xf & lwbbu7phddob_jskmwap9m7g & px3xebad9kl;
  wire w4lj8t9mmb0u1y07_m5xg0 = k_d8ubsroodv2n7sci31a71 & ntlhx_m4cwv2is;
  wire hox_m4wlzr5e_1ad4_3ch6sqh = w4lj8t9mmb0u1y07_m5xg0 | wrioumn1evcdoqwke4imcm6kto;
  wire q1dy0cl75ltxiagqgxknotkeexe = (~w4lj8t9mmb0u1y07_m5xg0);
sdio_gnrl_dfflr #(1) grf2y6_t1x4qt_v4yc9mcv9r_7z3uof53mc (hox_m4wlzr5e_1ad4_3ch6sqh, q1dy0cl75ltxiagqgxknotkeexe, e8jrq5f_hlyojnscwu7c1np, ri2ziyy, r46kf);
  assign m9784q7ukmn3si58c70oo_hls = e8jrq5f_hlyojnscwu7c1np;
  wire yje6uys0j87nugj;
  wire tkflc_nuv9324190o3;
  wire aec6kgioa8ej_0k0n9 = k_d8ubsroodv2n7sci31a71 & (ws5sf0h == 16'hf);
  wire eilekzzyohhmi1zc9n = ( (~hmcqg_vi9c0du1zwuv3dd1oss) & (ozr6w8sftjyfmifp21e_srv | (f86884rwtdpj4yjo9ubx & (~w_88bplku5ik)))
                     | (aec6kgioa8ej_0k0n9 & (~hc5muz31u4) ) 
                     ) & px3xebad9kl;
sdio_gnrl_dffr #(1) bki893li1cf9xz0l8q565qcep (eilekzzyohhmi1zc9n, yje6uys0j87nugj, ri2ziyy, r46kf);
  wire km0wiz_m85vu7 = (
                       (qencsbn23fg20kvy & (ozr6w8sftjyfmifp21e_srv | (f86884rwtdpj4yjo9ubx & (~w_88bplku5ik)))) 
                     | rzh_ifko8lys5__yn2h3jh5lof & hmcqg_vi9c0du1zwuv3dd1oss
                     )  & px3xebad9kl;
sdio_gnrl_dffr #(1) rgykp9n4i9g122g0ug0r90j8e (km0wiz_m85vu7, tkflc_nuv9324190o3, ri2ziyy, r46kf);
  hetqpjqj7c6fx221im ndm2sbvfk7 (
    .lczv3cn        ( ri2ziyy  ),
    .r38027_km3       ( r46kf ),
    .hh8dah7       ( yvsbjhg  ),
    .px3xebad9kl   ( px3xebad9kl  ),
    .s_f72w0s8hak9_im( a2y_p5uge6to   ),
    .ygli0hkz       ( msu6hae3td    ),
    .fv1t4udtvxdm      ( vg0d7ni5a9wfdgv ),
    .ho56_v0li6        ( an6dkw9hhw5m_f   ),
    .t0g2vtmb     ( ku1o1xek2lz    )
  );
  assign msu6hae3td    = yiu_3s290ga_1r4a_4mvqwkz98i ? glgiw3s5j7p : ssm9g0q;
  assign l5vlj3d           = hyewxy790up;
  assign mxwegalt668qkv       = zm9dojo_y9bh;
  assign iydyd8j             = djvwqkkxdym & (~jub5uvbqqfph25i9vi6vgfn);
  assign ynni_e015eh        = bhwkch[127:0];
  assign l492_zdzcnnei4mb   = oe14dzsct_ub[127:0];
  assign cqs_civ18w638bbgo9     = yje6uys0j87nugj;
  assign lut7o63_57lmo7p7      = tkflc_nuv9324190o3;
  assign cvsvk6xosj0          = gzsudkkux20;
  assign hb4y0ustf02qb     = gv3cqc0xjsdt2l_gn9yg;
endmodule
module n8j4biemqitai_6h20vkz_
(
    input  wire         ri2ziyy,
    input  wire         r46kf,
    input  wire         qgek6hz5rfs6m,
    input  wire         agra657i0o0nz9,
    input  wire         s2jh1nempl,
    output wire   [5:0] ujh3s3is5,
    output wire         hxqzu4xws6,
    output wire         ef0q7sx70v7r6i,
    input  wire         l9idxnwgti8jh0lz,
    input  wire   [11:0] n06jxxux2kra522pn8,
    input  wire  [15:0] oek_aiemroj9httja91b2,
    input  wire         ysm34bdzkpfwqy,
    input  wire  [1:0]  mef6pz7wky8,
    output wire         h0bszfaqg28q45,
    input  wire         px3xebad9kl,
    input  wire         ntlhx_m4cwv2is,
    input  wire         nhmow92ziyrfc2,
    input  wire         rjlma4yfh29we,
    input  wire         f7jojb_ei69nmep,
    input  wire         an1vq2wnlx7avgy,
    input  wire         u16tcme0kzincfd2h,
    input  wire         a4xpl3wgvhzrlyw,
    input  wire         gxb5b03yuuk0_,
    input  wire         k8ur5tmjmxy,
    input  wire         hnuzxe36tu1kx3,
    input  wire         yqihalm9oqcj35t,
    input  wire         dvvdm0wywfwyo5sl,
    input  wire         wwb5bn6954vu,
    input  wire         o87t4pnz3ylkal6 ,
    input  wire         i2aen5gc13jwm0      ,
    input  wire         cxh0zffxy9sc6     ,
    input  wire         drqmmbcvyc ,
    input  wire         galaluy047z,
    input  wire         gc0nysovke_pmgmxzl,
    input  wire         rjh4rfus0ddh2haeqfvz,
    input  wire [31:0]  wddz9ajtz98uzxa1y13_rd_6yf,
    input  wire         zitsxnxkg6e,
    input  wire         gdayv_v5udtp5x93tt,
    input  wire         jei_o2zgrfpn2,
    input  wire         vn02561rj8l2z_erne20lhu5,
    input  wire         dvv9js337kdzasybz56e9dx,
    input  wire         mvg2uod0f8i5h9__q645,
    input  wire         hf9ym2a2eh9uc2xbjnxq6ty7141,
    input  wire         bq6scjvk0k3x6aen99x,
    input wire          ntfvn09s31u9_t3w,
    input wire          c4wmn9x0tiqe,
    input wire          lh16w9beizuu5b2,
    output wire [15:0]  rg7ozwpk7xwi6vdbg8,
    output wire         sfc8z6ce,
    output wire         gopxzi6z,
    output wire         hpx0qqw7eo979f,
    output wire         s5upgf3pot8ypw9_,
    output wire [15:0]  nhlanc0cisb,
    output wire         jn1vqljcjmhbzhu5c,
    output wire         lo13ulq1cqk5ucx17t,
    output wire         y9nffq1claqkfzysy8,
    output wire         y3op3693r82a7al4x8189cf0hg6n5ux,
    output wire         mcyxv2wkh0eihnrmm6kz5d85h82o,
    output wire         y5u3u9h83new6z3za,
    input  wire  [31:0] g5ikzrx34od9pu8jyexvv,
    input  wire  [31:0] ileysv9olfjwrm_t236qmf0,
    input  wire  [31:0] vi2yjdqmw4rsfinydju9, 
    input  wire         suu86gfec5_q7q8tmn,
    output wire         j_22owq22ygfp83tlkymx0, 
    output wire  [31:0] snnj17b9zawct6n7sh, 
    output wire         nahnyoriw3y4r6rdpdn5jd2,
    input  wire         rlixu6nnh60an0djhpn6x0j, 
    output wire   [7:0] wm7w9dybdwy,
    input  wire   [7:0] q3v56zbk1,
    output wire   [7:0] j5lpulyyl0y6tq
  );
  localparam q3a_qhn0oez6_qdw42u8s        = 6'h1 ;
  localparam ow_3nyc73uhyssvbhzcp       = 6'h2 ;
  localparam uzb3tru66fafrwv66ay0j27sparrt  = 6'h3 ;
  localparam ipx85njsp8lphv3dn79jvi7o   = 6'h4 ;
  localparam oj1ivcnekf                   = 5'h0 ;
  localparam xp1ywa6n                   = 5'h1 ;
  localparam rrlsospx6sjar4               = 5'h2 ;
  localparam hi8185471wkfyi9                = 5'h3 ;
  localparam zm1j07j8v6tjx               = 5'h4 ;
  localparam z5hlzuxfdfu                 = 5'h5 ;
  localparam sepd8hx29wmav7                 = 5'h6 ;
  localparam n1_dal9e5mvmnnks5             = 5'h7 ;
  localparam zv5folxo50                = 5'h8 ;
  localparam psvh8ar9ffkj5j6s0_4qcg         = 5'h9 ;
  localparam o6gkn52i3g579i               = 5'ha ;
  localparam aol1khdhb7w                = 5'hb ;
  localparam dt73g95xelrq               = 5'hc ;
  localparam ectin_osl                 = 5'hd ;
  localparam yxd8vos8d_g                  = 5'he ;
  localparam uz32vsfeejuqnb5n_6j           = 5'hf ;
  localparam qcv3r692n6xse8_rn5y_o       = 5'h10 ;
  localparam si7d_bdlyfu                 = 5'h11 ;
  localparam erqthnf8a5a7_z9_1              = 5'h12 ;
  localparam x22dbc8dxewqpqcjjln          = 5'h13 ;
  localparam ove1keitb8_5pl5we           = 5'h14 ;
  localparam ws3ko1rvdjz299ham          = 5;
  wire       ogwbfmqpmwsu;
  wire [31:0] x0gqe67kb9sud;
  wire       nram81jeokitgj_oc5dha;
  wire       oaskgu6kaundv;
  wire       pxr8yir7ujm8ox;
  wire       c59n90h_2jf;
  wire       vg0d7ni5a9wfdgv;
  wire [15:0]dr5092pij19 [7:0] ;
  wire [7:0] qa3tq4wj_0po_6d2emr_4;
  wire [7:0] ma_crd6ftxx8gbgb0qr5px76;
  wire [7:0] brlulodayvzctgtcxeexngodi;
  wire [7:0] tha8k2w4l29if7;
  wire [7:0] cceu_gm1ydxv_zeb43;
  wire [15:0]vc16c9mpmz [7:0] ;
  wire [7:0] r52iqmee59hluv2t0sde;
  wire [7:0] c1dkaq4khry17spoaottq;
  wire [7:0] a0m84gvjr3lrz75863sagsuc;
  wire [7:0] cd9aurq1b8zkxmwlf;
  wire [7:0] llnwz3o5l_l6wpy35;
  wire ai1wz5k_jiipo = vn02561rj8l2z_erne20lhu5 | dvv9js337kdzasybz56e9dx;
  wire y12ivsvul95mvknqda;
  wire gyis7oviopqvp4s9l;
  wire       z_1m_y4u ; 
  sdio_hand_mux sdrax87wrog3nmv44qfwh (.X(z_1m_y4u), .S(nhmow92ziyrfc2), .D0(~ri2ziyy), .D1(ri2ziyy));
  wire       glg3dym4wv = k8ur5tmjmxy & (~bq6scjvk0k3x6aen99x);
  wire       ku1o1xek2lz;
  wire       an6dkw9hhw5m_f;
  wire       mvcxu0tbl2d;
  wire       omhes0bmkk6;
  wire       mjpt9;
  wire       ope61haknbc4hpuyc4j6;
  wire       xvj8thqd_hxxebzp0k;
  wire       xp1j4p_j67_re9fh04k1;
  wire       vccxpn342mhjcng52;
  wire [2:0] c7c3y07f0fboxccnvr;
  wire [7:0] u4vehljado5;
  wire       peq874y4ouxh3tpop;
  wire       ngqkrs6caubd718g1tq38hwv1dp;
  wire       c2zrvq5jn84hkqq3an_op;
  wire       h5luyvmieypxcta0;
  wire       xpkcrgdgylkka38e8updvzn = 1'b0;
  wire       alutp3dhus3g3aqnji39 = 1'b0;
  wire       zl_cgu_264m2iid5ka = 1'b1;
  wire       vogcki5p1i5tv8hypf4uea8 = 1'b0;
  wire       d86zay5x74haaxt7_b7b = 1'b0;
  wire       wvnzijys2cpr7ef45jx = 1'b1;
  wire ehl3l7tbzfy1hz8 ; 
  wire gjuhfa8qi0off4 ; 
  wire m06syicdkd0ko2oh ; 
  wire zjfyfzhen8jp_0v3 ; 
  wire kwbz7l_18a6wdnw7s ;
  wire d50q7cnxh_tu7v4t ;
  wire dletywvbyl65l8u8r ;
  wire qnj8ewpax371dfm8_ ;
  wire spyhe991j9oxj3 ;
  wire d_k8v4bgightmy ;
  wire l9fep860b6nk6naw;
  wire g4wwbiijwakc518k0qo;
  wire ybit4wql4fd_1hwvj_2dgs;
  wire qcoc_k8niw91gnvei2;
  wire agpyi1dbehpppynd10i56nwh2g;
  wire jwv_n9ht8dn0ki1vkq9r9;
  wire pnebn6ywgs1xb0pz = jwv_n9ht8dn0ki1vkq9r9 | l9idxnwgti8jh0lz;
  wire vdsttcrsoygd_3s7        = (q3v56zbk1[0]);
  wire mqoxpdhtx6xq7yh28        = (~q3v56zbk1[0]);
  wire wygays4nr6160p3te58x        = (ogwbfmqpmwsu & (~ysm34bdzkpfwqy)) ;
  wire tksq29j8ru7a127v          = (~wygays4nr6160p3te58x) & vdsttcrsoygd_3s7;
  wire tcqgriu28m4atke           = tksq29j8ru7a127v & ((nram81jeokitgj_oc5dha & i2aen5gc13jwm0)  | s2jh1nempl);
  wire t4131jmbnymobrhjm5j;
  wire [ws3ko1rvdjz299ham-1:0] j9e9y0z9nr7hkr9tx;
  wire [ws3ko1rvdjz299ham-1:0] aeiokfzwts8fc4;
  wire [ws3ko1rvdjz299ham-1:0] ifm4f61h58jxyo;
  wire [ws3ko1rvdjz299ham-1:0] ijhwll59ny41qsoqt;
  wire [ws3ko1rvdjz299ham-1:0] kq0_9jcwsk2_89a4cxjse89;
  wire [ws3ko1rvdjz299ham-1:0] vn4nr0tnalv2g3hsyplh7;
  wire [ws3ko1rvdjz299ham-1:0] ajrb0zbh0pfc5be7hv;
  wire [ws3ko1rvdjz299ham-1:0] bmicni50pigrkw_gs;
  wire [ws3ko1rvdjz299ham-1:0] kvpiyjvyh61rh1t_wvtefz21f;
  wire [ws3ko1rvdjz299ham-1:0] ylnydm4272rs5r8r27arh8wsjg;
  wire [ws3ko1rvdjz299ham-1:0] p08d_0x15ad1qcpsowcdmx;
  wire [ws3ko1rvdjz299ham-1:0] n42rtmezk8nn2d0e43ug8a4lxn;
  wire [ws3ko1rvdjz299ham-1:0] gtzhwct5_lzh5d81xn_qy2z;
  wire [ws3ko1rvdjz299ham-1:0] fv134bfyn5o6irrq9r4pb2r;
  wire [ws3ko1rvdjz299ham-1:0] id8yd3i7tw6vbjqu_;
  wire [ws3ko1rvdjz299ham-1:0] w8srd8lnbby5tomg9j9e;
  wire [ws3ko1rvdjz299ham-1:0] u3ul1i9jcsdwyaqyki96pp17p;
  wire [ws3ko1rvdjz299ham-1:0] z80j8zvi8u26p35adcq;
  wire [ws3ko1rvdjz299ham-1:0] ei3b_kwfn_c6kxvu2ax;
  wire [ws3ko1rvdjz299ham-1:0] t1_e_lfys0k5f_f9lw1r02uk3nlu;
  wire [ws3ko1rvdjz299ham-1:0] jth1dbass5ibztcj3pph18nt5;
  wire f86884rwtdpj4yjo9ubx;
  wire h4qbvxwxt49p0ncmjxcb;
  wire lwbbu7phddob_jskmwap9m7g;
  wire klyx_f6kq8fo1mv_vz9vwacb;
  wire kzhloeccbudrt_as8_xpg6u;
  wire vd9bxxu67fltwkuuujc_g_gbid;
  wire sudu9x6fxgspb3ehrrz581sopcx;
  wire zi_jwg_ie4min69a_08ti_khyk_c24ov6;
  wire ii9xkuhfvyfmi5kqppbh_mw5;
  wire m3nnac76tumkcnk8qspo0l3ne1bkqnum;
  wire q6y8gft_t7zvrv4ov9sc5yy;
  wire o02qvazqk7h10vsyr9n9se5_;
  wire ldic36ub7bs1__ux7m48ey3i;
  wire qpzinwdt2ygbepq9hqx0;
  wire p3ganp852n0silnmocutwnozq_c1dk;
  wire ob4_d6lmvjd0qvpmwvze8xcu;
  wire l5qgmhdc6881qrhoy9664ozln;
  wire k88u9vf5ztdis8_lkz7hxvxspheeqt_1d;
  wire bm_xps5wkhksbomvr6k1d7s0x7cbvw_;
  wire prcn884lva67kz = bq6scjvk0k3x6aen99x & f7jojb_ei69nmep;
  wire gdek375zjivq8agk75elm;
  wire vj0awrwcw47ncv9wx;
  wire wh2io6xv4vnmovq6y                      = ( wygays4nr6160p3te58x | tksq29j8ru7a127v | ybit4wql4fd_1hwvj_2dgs );
  wire ce5c7i7skbf80s1bsbd0hsx                = hf9ym2a2eh9uc2xbjnxq6ty7141;
  wire yqcry36izzrhaxogmniy8as                   = gdayv_v5udtp5x93tt ? hf9ym2a2eh9uc2xbjnxq6ty7141 : ogwbfmqpmwsu;
  wire gv3cqc0xjsdt2l_gn9yg                   = (j9e9y0z9nr7hkr9tx == oj1ivcnekf);
  wire k_d8ubsroodv2n7sci31a71                   = (j9e9y0z9nr7hkr9tx == xp1ywa6n);
  wire zvxa5ha3xtxrm_otprvmzv               = (j9e9y0z9nr7hkr9tx == rrlsospx6sjar4);
  wire u_wyia52cnfyu7wr6tki5l               = (j9e9y0z9nr7hkr9tx == zm1j07j8v6tjx);
  wire ft89lx1381fhl6_41gyv9h                 = (j9e9y0z9nr7hkr9tx == z5hlzuxfdfu);
  wire tu5qfca9vvv4sn6cbtskbfo3o                 = (j9e9y0z9nr7hkr9tx == sepd8hx29wmav7);
  wire p1yma33ydk44rbnnpcsnj6t81hs             = (j9e9y0z9nr7hkr9tx == n1_dal9e5mvmnnks5);
  wire ztrxs9f2kmf32yondwtbq4ydvkqnnvgqm2       = (j9e9y0z9nr7hkr9tx == qcv3r692n6xse8_rn5y_o);
  wire jlnl3ab6elmu4mi0zapi0lgnio                = (j9e9y0z9nr7hkr9tx == zv5folxo50);
  wire qoh0yn9716poua4ejbv9d_v5h1sk72w1         = (j9e9y0z9nr7hkr9tx == psvh8ar9ffkj5j6s0_4qcg);
  wire ctyjchlb_ew2alvt862388s1j               = (j9e9y0z9nr7hkr9tx == o6gkn52i3g579i);
  wire yiu_3s290ga_1r4a_4mvqwkz98i               = (j9e9y0z9nr7hkr9tx == dt73g95xelrq);
  wire t604ss4q7elas44sf22nht0                 = (j9e9y0z9nr7hkr9tx == ectin_osl);
  wire hva32cmddw6_4j1h4ia6n2ps                  = (j9e9y0z9nr7hkr9tx == yxd8vos8d_g);
  wire r6iogd2amp5fozymxx8ktga4zxr           = (j9e9y0z9nr7hkr9tx == uz32vsfeejuqnb5n_6j);
  wire q5l86lxp_qj0alu5avow                 = (j9e9y0z9nr7hkr9tx == si7d_bdlyfu);
  wire dl_jkmsi68c82blpdvj6xup7g              = (j9e9y0z9nr7hkr9tx == erqthnf8a5a7_z9_1);
  wire d1xiy0plkrfpsjblwtoh9ehzeh0b          = (j9e9y0z9nr7hkr9tx == x22dbc8dxewqpqcjjln);
  wire oxk6dmt7oede6j59ifaakkzib_w3           = (j9e9y0z9nr7hkr9tx == ove1keitb8_5pl5we);
  wire a4k0prxuu52wman0qxojj4n4 = (s2jh1nempl | ogwbfmqpmwsu);
  assign f86884rwtdpj4yjo9ubx                = gv3cqc0xjsdt2l_gn9yg & pnebn6ywgs1xb0pz ;
  assign qpzinwdt2ygbepq9hqx0               = hva32cmddw6_4j1h4ia6n2ps & (ogwbfmqpmwsu ); 
  assign h4qbvxwxt49p0ncmjxcb                = k_d8ubsroodv2n7sci31a71 & (ogwbfmqpmwsu |  s2jh1nempl & gdayv_v5udtp5x93tt)  ;
  assign lwbbu7phddob_jskmwap9m7g            = zvxa5ha3xtxrm_otprvmzv & (glg3dym4wv ? ogwbfmqpmwsu : 1'b1) ;
  assign klyx_f6kq8fo1mv_vz9vwacb            = u_wyia52cnfyu7wr6tki5l & yqcry36izzrhaxogmniy8as;
  assign kzhloeccbudrt_as8_xpg6u              = ft89lx1381fhl6_41gyv9h & ogwbfmqpmwsu;
  assign vd9bxxu67fltwkuuujc_g_gbid              = tu5qfca9vvv4sn6cbtskbfo3o;
  assign sudu9x6fxgspb3ehrrz581sopcx          = p1yma33ydk44rbnnpcsnj6t81hs & (ogwbfmqpmwsu | gdek375zjivq8agk75elm) & j5lpulyyl0y6tq[0];
  assign zi_jwg_ie4min69a_08ti_khyk_c24ov6    = ztrxs9f2kmf32yondwtbq4ydvkqnnvgqm2 & ogwbfmqpmwsu;
  assign ii9xkuhfvyfmi5kqppbh_mw5             = jlnl3ab6elmu4mi0zapi0lgnio & wh2io6xv4vnmovq6y;
  assign m3nnac76tumkcnk8qspo0l3ne1bkqnum      = qoh0yn9716poua4ejbv9d_v5h1sk72w1 & ogwbfmqpmwsu;
  assign q6y8gft_t7zvrv4ov9sc5yy            = ctyjchlb_ew2alvt862388s1j & (mqoxpdhtx6xq7yh28 | a4k0prxuu52wman0qxojj4n4);
  assign o02qvazqk7h10vsyr9n9se5_            = yiu_3s290ga_1r4a_4mvqwkz98i & (yqcry36izzrhaxogmniy8as | (prcn884lva67kz & vj0awrwcw47ncv9wx));
  assign ldic36ub7bs1__ux7m48ey3i              = t604ss4q7elas44sf22nht0 & ogwbfmqpmwsu;
  assign p3ganp852n0silnmocutwnozq_c1dk        = r6iogd2amp5fozymxx8ktga4zxr;
  assign ob4_d6lmvjd0qvpmwvze8xcu              = q5l86lxp_qj0alu5avow;
  assign l5qgmhdc6881qrhoy9664ozln           = dl_jkmsi68c82blpdvj6xup7g;
  assign k88u9vf5ztdis8_lkz7hxvxspheeqt_1d       = d1xiy0plkrfpsjblwtoh9ehzeh0b & ogwbfmqpmwsu;
  assign bm_xps5wkhksbomvr6k1d7s0x7cbvw_        = oxk6dmt7oede6j59ifaakkzib_w3 & ogwbfmqpmwsu;
  assign ifm4f61h58jxyo                     = yxd8vos8d_g;
  assign w8srd8lnbby5tomg9j9e                    = (ysm34bdzkpfwqy | prcn884lva67kz) ? o6gkn52i3g579i : rrlsospx6sjar4 ;
  assign ijhwll59ny41qsoqt                     = x22dbc8dxewqpqcjjln ;
  assign kq0_9jcwsk2_89a4cxjse89                 = zm1j07j8v6tjx;
  assign vn4nr0tnalv2g3hsyplh7                 = gdayv_v5udtp5x93tt ? sepd8hx29wmav7 : z5hlzuxfdfu ;
  assign ajrb0zbh0pfc5be7hv                   = ogwbfmqpmwsu ? sepd8hx29wmav7 : z5hlzuxfdfu;
  assign bmicni50pigrkw_gs                   = gdayv_v5udtp5x93tt ? zv5folxo50 : n1_dal9e5mvmnnks5;
  assign kvpiyjvyh61rh1t_wvtefz21f               = ogwbfmqpmwsu ? x22dbc8dxewqpqcjjln : qcv3r692n6xse8_rn5y_o;
  assign ylnydm4272rs5r8r27arh8wsjg         = zv5folxo50 ;
  assign p08d_0x15ad1qcpsowcdmx                  = (wygays4nr6160p3te58x | tcqgriu28m4atke | ybit4wql4fd_1hwvj_2dgs) ? xp1ywa6n
                                            : (tksq29j8ru7a127v & (  ((~nram81jeokitgj_oc5dha) & i2aen5gc13jwm0) 
                                                                | ((~i2aen5gc13jwm0) & (~s2jh1nempl))
                                                               ) ) ? psvh8ar9ffkj5j6s0_4qcg
                                            : zv5folxo50
                                            ;
  assign n42rtmezk8nn2d0e43ug8a4lxn           = (ogwbfmqpmwsu & glg3dym4wv) ? ((~hnuzxe36tu1kx3) ? erqthnf8a5a7_z9_1 : yxd8vos8d_g)
                                            : (ogwbfmqpmwsu & (~glg3dym4wv)) ? rrlsospx6sjar4 
                                            : psvh8ar9ffkj5j6s0_4qcg;
  assign gtzhwct5_lzh5d81xn_qy2z                 = a4k0prxuu52wman0qxojj4n4 ? x22dbc8dxewqpqcjjln
                                            : (mqoxpdhtx6xq7yh28 & glg3dym4wv) ? uz32vsfeejuqnb5n_6j 
                                            : ((mqoxpdhtx6xq7yh28 & (~glg3dym4wv)) | prcn884lva67kz) ? dt73g95xelrq 
                                            : o6gkn52i3g579i
                                            ;
  assign u3ul1i9jcsdwyaqyki96pp17p             = dt73g95xelrq;
  assign fv134bfyn5o6irrq9r4pb2r                 = (gdayv_v5udtp5x93tt | prcn884lva67kz) ? si7d_bdlyfu : ectin_osl;
  assign id8yd3i7tw6vbjqu_                   = ogwbfmqpmwsu ? si7d_bdlyfu : ectin_osl;
  assign z80j8zvi8u26p35adcq                   = (agpyi1dbehpppynd10i56nwh2g & i2aen5gc13jwm0  | s2jh1nempl | prcn884lva67kz ) ? x22dbc8dxewqpqcjjln 
                                            : y12ivsvul95mvknqda ? ove1keitb8_5pl5we
                                            : o6gkn52i3g579i 
                                            ;
  assign jth1dbass5ibztcj3pph18nt5             = o6gkn52i3g579i;
  assign ei3b_kwfn_c6kxvu2ax                = yxd8vos8d_g;
  assign t1_e_lfys0k5f_f9lw1r02uk3nlu            = oj1ivcnekf;
  assign t4131jmbnymobrhjm5j = f86884rwtdpj4yjo9ubx
                        | h4qbvxwxt49p0ncmjxcb
                        | lwbbu7phddob_jskmwap9m7g
                        | klyx_f6kq8fo1mv_vz9vwacb
                        | kzhloeccbudrt_as8_xpg6u
                        | vd9bxxu67fltwkuuujc_g_gbid
                        | sudu9x6fxgspb3ehrrz581sopcx
                        | zi_jwg_ie4min69a_08ti_khyk_c24ov6
                        | ii9xkuhfvyfmi5kqppbh_mw5
                        | m3nnac76tumkcnk8qspo0l3ne1bkqnum
                        | q6y8gft_t7zvrv4ov9sc5yy
                        | o02qvazqk7h10vsyr9n9se5_
                        | ldic36ub7bs1__ux7m48ey3i                  
                        | qpzinwdt2ygbepq9hqx0                  
                        | p3ganp852n0silnmocutwnozq_c1dk                  
                        | ob4_d6lmvjd0qvpmwvze8xcu                  
                        | l5qgmhdc6881qrhoy9664ozln         
                        | k88u9vf5ztdis8_lkz7hxvxspheeqt_1d
                        | bm_xps5wkhksbomvr6k1d7s0x7cbvw_         
                        ;
  assign aeiokfzwts8fc4 = ({ws3ko1rvdjz299ham{ f86884rwtdpj4yjo9ubx               }}) & ifm4f61h58jxyo            
                        | ({ws3ko1rvdjz299ham{ h4qbvxwxt49p0ncmjxcb               }}) & ijhwll59ny41qsoqt            
                        | ({ws3ko1rvdjz299ham{ lwbbu7phddob_jskmwap9m7g           }}) & kq0_9jcwsk2_89a4cxjse89        
                        | ({ws3ko1rvdjz299ham{ klyx_f6kq8fo1mv_vz9vwacb           }}) & vn4nr0tnalv2g3hsyplh7        
                        | ({ws3ko1rvdjz299ham{ kzhloeccbudrt_as8_xpg6u             }}) & ajrb0zbh0pfc5be7hv          
                        | ({ws3ko1rvdjz299ham{ vd9bxxu67fltwkuuujc_g_gbid             }}) & bmicni50pigrkw_gs          
                        | ({ws3ko1rvdjz299ham{ sudu9x6fxgspb3ehrrz581sopcx         }}) & kvpiyjvyh61rh1t_wvtefz21f      
                        | ({ws3ko1rvdjz299ham{ zi_jwg_ie4min69a_08ti_khyk_c24ov6   }}) & ylnydm4272rs5r8r27arh8wsjg      
                        | ({ws3ko1rvdjz299ham{ ii9xkuhfvyfmi5kqppbh_mw5            }}) & p08d_0x15ad1qcpsowcdmx         
                        | ({ws3ko1rvdjz299ham{ m3nnac76tumkcnk8qspo0l3ne1bkqnum     }}) & n42rtmezk8nn2d0e43ug8a4lxn  
                        | ({ws3ko1rvdjz299ham{ q6y8gft_t7zvrv4ov9sc5yy           }}) & gtzhwct5_lzh5d81xn_qy2z        
                        | ({ws3ko1rvdjz299ham{ o02qvazqk7h10vsyr9n9se5_           }}) & fv134bfyn5o6irrq9r4pb2r        
                        | ({ws3ko1rvdjz299ham{ ldic36ub7bs1__ux7m48ey3i             }}) & id8yd3i7tw6vbjqu_
                        | ({ws3ko1rvdjz299ham{ qpzinwdt2ygbepq9hqx0              }}) & w8srd8lnbby5tomg9j9e
                        | ({ws3ko1rvdjz299ham{ p3ganp852n0silnmocutwnozq_c1dk       }}) & u3ul1i9jcsdwyaqyki96pp17p
                        | ({ws3ko1rvdjz299ham{ ob4_d6lmvjd0qvpmwvze8xcu             }}) & z80j8zvi8u26p35adcq
                        | ({ws3ko1rvdjz299ham{ l5qgmhdc6881qrhoy9664ozln          }}) & ei3b_kwfn_c6kxvu2ax
                        | ({ws3ko1rvdjz299ham{ k88u9vf5ztdis8_lkz7hxvxspheeqt_1d      }}) & t1_e_lfys0k5f_f9lw1r02uk3nlu
                        | ({ws3ko1rvdjz299ham{ bm_xps5wkhksbomvr6k1d7s0x7cbvw_       }}) & jth1dbass5ibztcj3pph18nt5
                        ;
  wire f5c_rburvuxi = ysm34bdzkpfwqy & (~gv3cqc0xjsdt2l_gn9yg);
  wire b0kjclghev4 = glg3dym4wv ? ( f5c_rburvuxi ? u16tcme0kzincfd2h : a4xpl3wgvhzrlyw) : px3xebad9kl ; 
  wire z9mtbr5w8zs6os4pp1vxzg_3 = l9idxnwgti8jh0lz;
  wire uho7tif7uy342djtd2pkmq = b0kjclghev4;
  wire w79o0oqmyxwfw5v8pce2kwtf = z9mtbr5w8zs6os4pp1vxzg_3;
  wire ay31qcqakhvye3fmwmery = z9mtbr5w8zs6os4pp1vxzg_3 | uho7tif7uy342djtd2pkmq;
sdio_gnrl_dfflr #(1) okakbtw3jn7rrcz7dx42g7uyj539eq9k (ay31qcqakhvye3fmwmery, w79o0oqmyxwfw5v8pce2kwtf, jwv_n9ht8dn0ki1vkq9r9, ri2ziyy, r46kf);
  wire v608pgdwbhmrbjz1u9gh7gng = mqoxpdhtx6xq7yh28 & px3xebad9kl & p1yma33ydk44rbnnpcsnj6t81hs & j5lpulyyl0y6tq[0];
  wire yybkv2q5gglcouo030zsgp3pf = gdek375zjivq8agk75elm & px3xebad9kl;
  wire uzpdui5g9drol4cmlfupuqt1r9am = (~yybkv2q5gglcouo030zsgp3pf);
  wire x4x_9baykia2th2ie7o6qb5wgruu = v608pgdwbhmrbjz1u9gh7gng | yybkv2q5gglcouo030zsgp3pf;
sdio_gnrl_dfflr #(1) vbcjyz_ruz64039q4lvyetv18vqqi (x4x_9baykia2th2ie7o6qb5wgruu,uzpdui5g9drol4cmlfupuqt1r9am, gdek375zjivq8agk75elm, ri2ziyy, r46kf);
  wire kdbupylwzq6md8y  = glg3dym4wv ? (b0kjclghev4 & ((~hnuzxe36tu1kx3) )) : b0kjclghev4;
  wire o697e7gi_a7g3ne_q52   = glg3dym4wv & b0kjclghev4 & hnuzxe36tu1kx3 ;
  wire y5vi74vo8hfzs6n = t4131jmbnymobrhjm5j & b0kjclghev4;
sdio_gnrl_dfflr #(ws3ko1rvdjz299ham) ad0t9ad0ocexhh2o2f35 (y5vi74vo8hfzs6n, aeiokfzwts8fc4, j9e9y0z9nr7hkr9tx, ri2ziyy, r46kf);
  wire eh3d77scyrgjbd71 = k88u9vf5ztdis8_lkz7hxvxspheeqt_1d ;
  wire k8alnzn6n4q3f0xtfao1r_mz91 = nram81jeokitgj_oc5dha & ctyjchlb_ew2alvt862388s1j;
  wire eutmpu65sd61doulum5wldqww7h3z = gv3cqc0xjsdt2l_gn9yg;
  wire hqa3vx5fbml7124dd6n9_pv4hqap = k8alnzn6n4q3f0xtfao1r_mz91 | eutmpu65sd61doulum5wldqww7h3z;
  wire xd8ctc8pkfjyzjtmki78u8uu = k8alnzn6n4q3f0xtfao1r_mz91 ;
  wire dxwai4udo280fu6lwi93cd2lt  = hqa3vx5fbml7124dd6n9_pv4hqap;
sdio_gnrl_dfflr #(1) fm8wbh6ff0mby0bcmsf946y3wbwy7 (dxwai4udo280fu6lwi93cd2lt, xd8ctc8pkfjyzjtmki78u8uu, agpyi1dbehpppynd10i56nwh2g, ri2ziyy, r46kf);
  sdio_gnrl_sync #(.DP(2),.DW(1)) bk6s47gjt8fvj5ts8qvndzhn1r (mvg2uod0f8i5h9__q645, y12ivsvul95mvknqda ,r46kf,ri2ziyy);
  wire rqvhms86yhus5tf1ut = jlnl3ab6elmu4mi0zapi0lgnio & tksq29j8ru7a127v & (~nram81jeokitgj_oc5dha);
  wire fopiayiwwhqg7c = (ctyjchlb_ew2alvt862388s1j & (mqoxpdhtx6xq7yh28 | s2jh1nempl) & (~glg3dym4wv));
  wire z4qjld7dca43amursm7mc = p1yma33ydk44rbnnpcsnj6t81hs & mqoxpdhtx6xq7yh28 & j5lpulyyl0y6tq[0];
  wire t681a79n07cnuoc = (p08d_0x15ad1qcpsowcdmx == x22dbc8dxewqpqcjjln) & ii9xkuhfvyfmi5kqppbh_mw5
                     | (gtzhwct5_lzh5d81xn_qy2z == x22dbc8dxewqpqcjjln) & q6y8gft_t7zvrv4ov9sc5yy
                     | (z80j8zvi8u26p35adcq == x22dbc8dxewqpqcjjln) & ob4_d6lmvjd0qvpmwvze8xcu
                     | (kvpiyjvyh61rh1t_wvtefz21f == x22dbc8dxewqpqcjjln) & sudu9x6fxgspb3ehrrz581sopcx
                     | h4qbvxwxt49p0ncmjxcb
                     ;
  wire r9rnrmgy8k8bgk_o9 = (z80j8zvi8u26p35adcq == o6gkn52i3g579i);
  wire uzvzx7z6oj8t9m__jq3adq3;
  wire djqwjseq4sl5pijj862kk6fi = y12ivsvul95mvknqda & ob4_d6lmvjd0qvpmwvze8xcu;
  assign oaskgu6kaundv = f86884rwtdpj4yjo9ubx
                     | qpzinwdt2ygbepq9hqx0
                     | lwbbu7phddob_jskmwap9m7g
                     | klyx_f6kq8fo1mv_vz9vwacb
                     | tu5qfca9vvv4sn6cbtskbfo3o
                     | z4qjld7dca43amursm7mc
                     | zi_jwg_ie4min69a_08ti_khyk_c24ov6 
                     | (p1yma33ydk44rbnnpcsnj6t81hs & ogwbfmqpmwsu)
                     | ii9xkuhfvyfmi5kqppbh_mw5
                     | fopiayiwwhqg7c
                     | r6iogd2amp5fozymxx8ktga4zxr
                     | o02qvazqk7h10vsyr9n9se5_
                     | l5qgmhdc6881qrhoy9664ozln
                     | (m3nnac76tumkcnk8qspo0l3ne1bkqnum  & glg3dym4wv )
                     | k88u9vf5ztdis8_lkz7hxvxspheeqt_1d
                     | t681a79n07cnuoc
                     | uzvzx7z6oj8t9m__jq3adq3
                     | djqwjseq4sl5pijj862kk6fi
                     ;
  wire j0vye3_vnvg = (mef6pz7wky8 == 2'b00) | bq6scjvk0k3x6aen99x;
  wire wnj4jjpcyf = (mef6pz7wky8 == 2'b01);
  wire xadq_sq7c_9 = (mef6pz7wky8 == 2'b10) | lh16w9beizuu5b2 | c4wmn9x0tiqe;
  wire sgr5397hfsvz = (wnj4jjpcyf | xadq_sq7c_9) ;
  assign pxr8yir7ujm8ox = zvxa5ha3xtxrm_otprvmzv 
                    | fopiayiwwhqg7c
                    | r6iogd2amp5fozymxx8ktga4zxr
                    | uzvzx7z6oj8t9m__jq3adq3
                    ;
  wire bua5aph4l10s;
  wire jea7amht1fd23 = oaskgu6kaundv;
  wire wm97s62yjyn41zsu = (ogwbfmqpmwsu & (~gdayv_v5udtp5x93tt)) | (gdayv_v5udtp5x93tt & ce5c7i7skbf80s1bsbd0hsx);
  wire sq7b79y78h7wbuq5g = jea7amht1fd23 | wm97s62yjyn41zsu;
  wire y8bmqoeraj5l = jea7amht1fd23 ? pxr8yir7ujm8ox 
                    : wm97s62yjyn41zsu ? 1'b0
                    : bua5aph4l10s
                    ;
  wire o2wanlnkf7vgex4 = sq7b79y78h7wbuq5g & b0kjclghev4 ;
sdio_gnrl_dfflr #(1) pt2in185hc5t37rqne1 (o2wanlnkf7vgex4, y8bmqoeraj5l, bua5aph4l10s, ri2ziyy, r46kf);
  assign c59n90h_2jf = yiu_3s290ga_1r4a_4mvqwkz98i | t604ss4q7elas44sf22nht0 ;
  assign vg0d7ni5a9wfdgv = ft89lx1381fhl6_41gyv9h ;
  wire tf4s6y267vpi5mj50e55;
  assign ku1o1xek2lz = ~(ft89lx1381fhl6_41gyv9h | tf4s6y267vpi5mj50e55 | tu5qfca9vvv4sn6cbtskbfo3o & ~(glg3dym4wv)) ;
  assign an6dkw9hhw5m_f = gv3cqc0xjsdt2l_gn9yg | hva32cmddw6_4j1h4ia6n2ps & glg3dym4wv | prcn884lva67kz | oxk6dmt7oede6j59ifaakkzib_w3;
  wire dq6pb4_qyrff_vgl29_ = (u_wyia52cnfyu7wr6tki5l | yiu_3s290ga_1r4a_4mvqwkz98i) ;
  wire dv48e4t38ydkdlxmw = gv3cqc0xjsdt2l_gn9yg & (~glg3dym4wv) & ysm34bdzkpfwqy;
  wire r2xcmjjytq1pjkfsidfrv = gv3cqc0xjsdt2l_gn9yg & (~glg3dym4wv) 
                          | (hva32cmddw6_4j1h4ia6n2ps & glg3dym4wv & (~ysm34bdzkpfwqy)) 
                          | l5qgmhdc6881qrhoy9664ozln
                          | (m3nnac76tumkcnk8qspo0l3ne1bkqnum  & glg3dym4wv )
                          | djqwjseq4sl5pijj862kk6fi
                          | t681a79n07cnuoc & ai1wz5k_jiipo
                          | ctyjchlb_ew2alvt862388s1j & a4k0prxuu52wman0qxojj4n4 
                          ;
  wire p2ccuwm8tsa9m8jtqi = zvxa5ha3xtxrm_otprvmzv 
                          | ctyjchlb_ew2alvt862388s1j  
                          | r6iogd2amp5fozymxx8ktga4zxr 
                          ;
  wire pfdenolvvf5j7ekc3qg04 = (dq6pb4_qyrff_vgl29_ & glg3dym4wv);
  wire atoc99s8r18o86iw5l2ie0b = (dq6pb4_qyrff_vgl29_ & (~glg3dym4wv));
  wire l_ruje5qhulb4lg3duqe = tu5qfca9vvv4sn6cbtskbfo3o;
  wire ndl8ux_vtinfkg20we = jlnl3ab6elmu4mi0zapi0lgnio;
  wire jcbadxx1xkmyxj_wornq58k = p1yma33ydk44rbnnpcsnj6t81hs;
  wire zn1xqri2d47ehu6_fpq = gv3cqc0xjsdt2l_gn9yg & glg3dym4wv;
  wire [11:0] ofs6k_x0caky5q4j_cionb = n06jxxux2kra522pn8 >>1 ;
  assign x0gqe67kb9sud = dv48e4t38ydkdlxmw      ? 32'd0
                      : r2xcmjjytq1pjkfsidfrv  ?  32'd1
                      : p2ccuwm8tsa9m8jtqi ? {20'h0,n06jxxux2kra522pn8}
                      : pfdenolvvf5j7ekc3qg04 ? (gdayv_v5udtp5x93tt ? 32'd2 : 32'd31)
                      : atoc99s8r18o86iw5l2ie0b ? (gdayv_v5udtp5x93tt ? (ogwbfmqpmwsu ? {20'h0,n06jxxux2kra522pn8} : 32'd1) : 32'd15)
                      : l_ruje5qhulb4lg3duqe ? wddz9ajtz98uzxa1y13_rd_6yf 
                      : ndl8ux_vtinfkg20we ? (glg3dym4wv ? {ileysv9olfjwrm_t236qmf0[30:0],1'b0} : ileysv9olfjwrm_t236qmf0)
                      : jcbadxx1xkmyxj_wornq58k ? (glg3dym4wv ? 32'd8 : 32'd3)
                      : zn1xqri2d47ehu6_fpq ? 32'd1
                      : t681a79n07cnuoc & (~ai1wz5k_jiipo)     ? 32'd16
                      : g5ikzrx34od9pu8jyexvv
                      ;
  assign uzvzx7z6oj8t9m__jq3adq3 = atoc99s8r18o86iw5l2ie0b & gdayv_v5udtp5x93tt & ogwbfmqpmwsu ;
  assign mvcxu0tbl2d = ~(gv3cqc0xjsdt2l_gn9yg | qoh0yn9716poua4ejbv9d_v5h1sk72w1 | zvxa5ha3xtxrm_otprvmzv | hva32cmddw6_4j1h4ia6n2ps);
  assign omhes0bmkk6 = yiu_3s290ga_1r4a_4mvqwkz98i;
  assign mjpt9 = eh3d77scyrgjbd71; 
  wire [2:0] alwngbwj3lb5r0hg;
  wire n0hz90htqmfzxwfjp8t = vd9bxxu67fltwkuuujc_g_gbid | ob4_d6lmvjd0qvpmwvze8xcu | (alwngbwj3lb5r0hg>0);
  wire r7xbg4fwfvgck2eqp_yn_ih = (alwngbwj3lb5r0hg == 3'b110) | s2jh1nempl;
  wire nh0g6gk4399tav72qu9bsg = (r7xbg4fwfvgck2eqp_yn_ih | n0hz90htqmfzxwfjp8t);
  wire ap0fd7zlkmbu3bwz1y96 = nh0g6gk4399tav72qu9bsg & g4wwbiijwakc518k0qo;
  wire [2:0] yjy0l_w28jql9h_d791 = r7xbg4fwfvgck2eqp_yn_ih ? 3'h0 
                                : n0hz90htqmfzxwfjp8t ? alwngbwj3lb5r0hg + 3'b1
                                : alwngbwj3lb5r0hg
                                ;
sdio_gnrl_dfflr #(3) b72qnxap129esr6dsyjrpk4jh (ap0fd7zlkmbu3bwz1y96, yjy0l_w28jql9h_d791, alwngbwj3lb5r0hg, ri2ziyy, r46kf);
  wire l78tmyo0dve5ll4hm4nqmez06b = (alwngbwj3lb5r0hg == 3'b100);
  wire kh7p58enaq4d_h = (drqmmbcvyc & cxh0zffxy9sc6);
  wire frq0lgw7r12pjpvmv3xnftt43ete9g4h4 = l78tmyo0dve5ll4hm4nqmez06b & (~s2jh1nempl);
  wire vmx05ds64p4jq8a4n_bmbcrnymhbmg_cd = (frq0lgw7r12pjpvmv3xnftt43ete9g4h4  | kh7p58enaq4d_h);
  wire uyso04unb4wn72w1cx5r = (zvxa5ha3xtxrm_otprvmzv | u_wyia52cnfyu7wr6tki5l | qoh0yn9716poua4ejbv9d_v5h1sk72w1);
  wire k1bf14ttsefe6bcndlf = (ctyjchlb_ew2alvt862388s1j | yiu_3s290ga_1r4a_4mvqwkz98i | q5l86lxp_qj0alu5avow);
  assign y3op3693r82a7al4x8189cf0hg6n5ux = vmx05ds64p4jq8a4n_bmbcrnymhbmg_cd & (~zitsxnxkg6e)
                                    | (zitsxnxkg6e & vmx05ds64p4jq8a4n_bmbcrnymhbmg_cd & nram81jeokitgj_oc5dha & (~(uyso04unb4wn72w1cx5r | k1bf14ttsefe6bcndlf)))
                                    ;
  assign mcyxv2wkh0eihnrmm6kz5d85h82o = r7xbg4fwfvgck2eqp_yn_ih & (~gv3cqc0xjsdt2l_gn9yg) & 
                                    ( (~nram81jeokitgj_oc5dha) & (~ysm34bdzkpfwqy)
                                    | (~(agpyi1dbehpppynd10i56nwh2g & d1xiy0plkrfpsjblwtoh9ehzeh0b) & ysm34bdzkpfwqy)
                                    )
                                    ;
  wire otwp3_uof7dtm;
  wire umna453jjaohbtabp = oaskgu6kaundv;
  wire jy76eyk1m8a5uxyzo = ogwbfmqpmwsu;
  wire ok_rkg38je130ddy6jk = umna453jjaohbtabp | jy76eyk1m8a5uxyzo;
  wire gqqqx3gisuv2g0rmyw = umna453jjaohbtabp ;
  wire j59wo39atdgqanzs3  = ok_rkg38je130ddy6jk & b0kjclghev4;
sdio_gnrl_dfflr #(1) gdcwasg9ifl9wbfxzhf4 (j59wo39atdgqanzs3, gqqqx3gisuv2g0rmyw, otwp3_uof7dtm, ri2ziyy, r46kf);
  wire dgp89ir_abdhstkujb64e = (gdayv_v5udtp5x93tt & tu5qfca9vvv4sn6cbtskbfo3o) | (bq6scjvk0k3x6aen99x & q5l86lxp_qj0alu5avow);
  wire [2:0] pxbgy7rypk;
  wire agepfhuhfjqa = (~vccxpn342mhjcng52);
  wire o4okrtw26smjv = vccxpn342mhjcng52 | dgp89ir_abdhstkujb64e | wm97s62yjyn41zsu;
  wire bw6sqxtffq9yh = (o4okrtw26smjv | agepfhuhfjqa) & bua5aph4l10s | dgp89ir_abdhstkujb64e;
  wire h_j3cadpx8w8wg = bw6sqxtffq9yh & b0kjclghev4;
  wire [2:0] y8y5fphthrkirw = o4okrtw26smjv ? 3'h0
                         : agepfhuhfjqa ? pxbgy7rypk + 3'b1
                         : pxbgy7rypk
                         ;
sdio_gnrl_dfflr #(3) dhqonaqzvhwhgx7ei7 (h_j3cadpx8w8wg, y8y5fphthrkirw, pxbgy7rypk, ri2ziyy, r46kf);
  assign vj0awrwcw47ncv9wx = (pxbgy7rypk == 3'h2);
  wire [15:0] cnnx5vzeep27p;
  wire f7vz89v2l071js = (gv3cqc0xjsdt2l_gn9yg & pnebn6ywgs1xb0pz)
                     | rqvhms86yhus5tf1ut
                     | (t604ss4q7elas44sf22nht0 & (~nram81jeokitgj_oc5dha) & ogwbfmqpmwsu)
                     ;
  wire [15:0] llcwyuqmbc6qcr = (s2jh1nempl | gdayv_v5udtp5x93tt) ? 16'h0 
                           : (gv3cqc0xjsdt2l_gn9yg | (hpx0qqw7eo979f & (~i2aen5gc13jwm0))) ? oek_aiemroj9httja91b2
                           : cnnx5vzeep27p - 16'h1
                           ;
  wire yl6vxf5ary2g4hfw = s2jh1nempl | gdayv_v5udtp5x93tt | f7vz89v2l071js & b0kjclghev4 ;
sdio_gnrl_dfflr #(16) yjdaxgdyxny4fagf (yl6vxf5ary2g4hfw, llcwyuqmbc6qcr, cnnx5vzeep27p, ri2ziyy, r46kf);
  assign nhlanc0cisb = cnnx5vzeep27p;
  wire hz2clagaqb7xqcn629bv =  i2aen5gc13jwm0 ? 1'b1 : nram81jeokitgj_oc5dha;
  assign hpx0qqw7eo979f = (ii9xkuhfvyfmi5kqppbh_mw5 | ldic36ub7bs1__ux7m48ey3i ) & hz2clagaqb7xqcn629bv & b0kjclghev4 & (~gdayv_v5udtp5x93tt);
  wire [31:0] ws5sf0h;
  wire l5c9sm9pzpml = oaskgu6kaundv | ogwbfmqpmwsu;
  wire jxxipallci8k = (otwp3_uof7dtm && ((~bua5aph4l10s) | vccxpn342mhjcng52));
  wire z94f9sb1fld = l5c9sm9pzpml | jxxipallci8k;
  wire [31:0] vhf0y78xf9pk = oaskgu6kaundv ? x0gqe67kb9sud 
                     : ogwbfmqpmwsu  ? 32'h3ff
                     : jxxipallci8k ? ws5sf0h - 32'h1
                     : ws5sf0h
                     ;
  wire l1bouo9 = z94f9sb1fld & b0kjclghev4 ;
sdio_gnrl_dfflrs #(32) u5ijlcnwiha09l (l1bouo9, vhf0y78xf9pk, ws5sf0h, ri2ziyy, r46kf);
  wire a2_w4509ybpf__85o2chv = yiu_3s290ga_1r4a_4mvqwkz98i | u_wyia52cnfyu7wr6tki5l;
  wire [1:0] nrs77d8cztldlkcr5;
  wire sg0xmo5s782spko1o = bua5aph4l10s & vccxpn342mhjcng52 & otwp3_uof7dtm;
  wire wnov_ex5n75ccxnvl = ogwbfmqpmwsu & nram81jeokitgj_oc5dha & a2_w4509ybpf__85o2chv & (~uzvzx7z6oj8t9m__jq3adq3) | dgp89ir_abdhstkujb64e | gv3cqc0xjsdt2l_gn9yg;
  wire daypbpxtir92fvp8_t98 = sg0xmo5s782spko1o | wnov_ex5n75ccxnvl;
  wire [1:0] aq0bn7vskyxot8spqgh9i = wnov_ex5n75ccxnvl ? 2'b0
                              : sg0xmo5s782spko1o ? nrs77d8cztldlkcr5 + 2'b1
                              : nrs77d8cztldlkcr5
                              ;
  wire nc264za6u_wp3f2nz = daypbpxtir92fvp8_t98 & b0kjclghev4 ;
sdio_gnrl_dfflr #(2) fo7z7bx4_hb6r5a28z (nc264za6u_wp3f2nz, aq0bn7vskyxot8spqgh9i, nrs77d8cztldlkcr5, ri2ziyy, r46kf);
  wire aqsracxgpxslz_26 = (nrs77d8cztldlkcr5 == 2'b00);
  wire wfpp61d0m__51c5 = (nrs77d8cztldlkcr5 == 2'b01);
  wire r11mpywn5dvpr__hu = (nrs77d8cztldlkcr5 == 2'b10);
  wire c5ebjjcolimuifvk = (nrs77d8cztldlkcr5 == 2'b11);
  assign c7c3y07f0fboxccnvr = j0vye3_vnvg ? 3'h7 
                          : wnj4jjpcyf ? 3'h1
                          : 3'h0
                          ;
  assign vccxpn342mhjcng52  = (pxbgy7rypk == c7c3y07f0fboxccnvr);
  wire [1:0] xqoiehiz8vub6;
  wire [1:0] y72y8jrf0uzen16doxson = wnj4jjpcyf ? 2'h3 : 2'h1 ;
  wire fp_eq5ouhk_tqfu6 = (xqoiehiz8vub6 == y72y8jrf0uzen16doxson);
  wire fa6qvfpd5vwwrywf = (~fp_eq5ouhk_tqfu6);
  wire vueqydiwhn1h = fp_eq5ouhk_tqfu6;
  wire ju1_fdnyhwdnlxn2 = (vueqydiwhn1h | fa6qvfpd5vwwrywf) & bua5aph4l10s ;
  wire mezj9_zmkg1wdlm = ju1_fdnyhwdnlxn2 & b0kjclghev4 & glg3dym4wv;
  wire [1:0] poyn48jcma95b = vueqydiwhn1h ? 2'h0 
                         : fa6qvfpd5vwwrywf ? xqoiehiz8vub6 + 2'b1
                         : xqoiehiz8vub6
                         ;
sdio_gnrl_dfflr #(2) lbi9hlcuyq3b9ve6ei4 (mezj9_zmkg1wdlm, poyn48jcma95b, xqoiehiz8vub6, ri2ziyy, r46kf);
  wire mbg29lzp7nsh = (ws5sf0h == 32'h0);
  wire rg_pw17br08zls = (ehl3l7tbzfy1hz8 & (ws5sf0h == 32'h0)
                      | gjuhfa8qi0off4 & (ws5sf0h <= 32'h1)
                      | m06syicdkd0ko2oh & (ws5sf0h <= 32'h2)
                      ) & (~gdayv_v5udtp5x93tt)
                      ;
  wire rsaai7kypzjqvn5mqzbfqk35 = ~(|n06jxxux2kra522pn8[11:2]);
  wire yei_um48bvirkv6 ;
  wire n7j_lr48zp3uza0reyogz_s = (oek_aiemroj9httja91b2 == 16'h1);
  wire knpry1kqjd6pqxawem8f0 = (oek_aiemroj9httja91b2 == 16'h2);
  assign h5luyvmieypxcta0 = rg_pw17br08zls 
                           & (nram81jeokitgj_oc5dha | ((n7j_lr48zp3uza0reyogz_s | knpry1kqjd6pqxawem8f0) & yei_um48bvirkv6))
                           ;
  assign ogwbfmqpmwsu = bua5aph4l10s ? ( mbg29lzp7nsh & vccxpn342mhjcng52) : mbg29lzp7nsh;
  assign nram81jeokitgj_oc5dha = (cnnx5vzeep27p == 16'h0);
  wire c2stbkyn9ueam2o = lwbbu7phddob_jskmwap9m7g & ( xpkcrgdgylkka38e8updvzn ? 1'b1 
                                                  : alutp3dhus3g3aqnji39 ? (aqsracxgpxslz_26 | r11mpywn5dvpr__hu)
                                                  : aqsracxgpxslz_26
                                                  );
  wire zn0mll47silgah293w = (c2stbkyn9ueam2o | (u_wyia52cnfyu7wr6tki5l & xvj8thqd_hxxebzp0k & (~c2stbkyn9ueam2o)));
  assign g4wwbiijwakc518k0qo = glg3dym4wv ? b0kjclghev4 : (ntlhx_m4cwv2is | (wwb5bn6954vu & (~ef0q7sx70v7r6i) & hnuzxe36tu1kx3));
  wire kvgj3mnkh_jo81a;
  wire r6c5ziv84ym8xmr5 = (zn0mll47silgah293w | kvgj3mnkh_jo81a) & (zvxa5ha3xtxrm_otprvmzv | u_wyia52cnfyu7wr6tki5l);
  wire axilkppobgeb63k1 = zn0mll47silgah293w & b0kjclghev4;
  wire ji8b2_wgula3n9g = r6c5ziv84ym8xmr5 & suu86gfec5_q7q8tmn;
  wire u4hu505j75r1pby03ys = (axilkppobgeb63k1 | ji8b2_wgula3n9g);
  wire dmi9hdc1mm29lnl = (~ji8b2_wgula3n9g) ;
sdio_gnrl_dfflr #(1) oplfbwianpkq2eb2buho (u4hu505j75r1pby03ys, dmi9hdc1mm29lnl, kvgj3mnkh_jo81a, ri2ziyy, r46kf);
  wire vbjtunnnne8 = r6c5ziv84ym8xmr5;
  wire [7:0] s0g0c3lyzmsbu;
  wire [7:0] nhz25tqf1yp01dpv;
  wire [7:0] rnmrka264vb = (zvxa5ha3xtxrm_otprvmzv | c4wmn9x0tiqe) ? 8'b0
                        : u_wyia52cnfyu7wr6tki5l ? u4vehljado5
                        : ft89lx1381fhl6_41gyv9h   ? (glg3dym4wv ? (kdbupylwzq6md8y ? cceu_gm1ydxv_zeb43 : llnwz3o5l_l6wpy35) : cceu_gm1ydxv_zeb43)
                        : (tu5qfca9vvv4sn6cbtskbfo3o | lh16w9beizuu5b2)   ? 8'hff
                        : gyis7oviopqvp4s9l & (~galaluy047z)  ?  (r9rnrmgy8k8bgk_o9 ? 8'hff : 8'hfb)
                        : 8'h0
                        ;
  wire kd3_leo9u11 = g4wwbiijwakc518k0qo | c4wmn9x0tiqe | lh16w9beizuu5b2;
sdio_gnrl_dfflr #(8) pyftl2uargcff6dn (kd3_leo9u11, rnmrka264vb, nhz25tqf1yp01dpv, z_1m_y4u, r46kf);
sdio_gnrl_dfflr #(8) e1jomxd9wmixjnh8bl (kd3_leo9u11, rnmrka264vb, s0g0c3lyzmsbu, ri2ziyy, r46kf);
  assign wm7w9dybdwy = glg3dym4wv ? (yqihalm9oqcj35t ? nhz25tqf1yp01dpv : s0g0c3lyzmsbu) : s0g0c3lyzmsbu;
  wire [7:0] y67em4qnwy831;
  wire [7:0] d3hz_rxufgsk9 = mjpt9 ? 8'h0
                         : j0vye3_vnvg ? {y67em4qnwy831[6:0] , q3v56zbk1[0]}
                         : wnj4jjpcyf ? {y67em4qnwy831[3:0] , q3v56zbk1[3:0]}
                         : xadq_sq7c_9 ? q3v56zbk1
                         : y67em4qnwy831
                         ;
  wire bkvw92mogsvm07p = omhes0bmkk6 | t604ss4q7elas44sf22nht0 | mjpt9;
  wire xd50fv5qeh67  = bkvw92mogsvm07p & b0kjclghev4;
sdio_gnrl_dfflr #(8) mvm1r1uozzmo9lc (xd50fv5qeh67, d3hz_rxufgsk9, y67em4qnwy831, ri2ziyy, r46kf);
  wire [3:0] tbaswct8ktlmcxl5g1cln;
  wire o6p914387pcqvv1t3b8oipe0e62014234nrlmbmyt = ztrxs9f2kmf32yondwtbq4ydvkqnnvgqm2 & (~ogwbfmqpmwsu);
  wire [3:0] h5lx3ry4f6x78j03qwyqwh3 = {tbaswct8ktlmcxl5g1cln[2:0] , q3v56zbk1[0]};
  wire s1sc92xgxg4q469dtey = glg3dym4wv ? (dvvdm0wywfwyo5sl ? o6p914387pcqvv1t3b8oipe0e62014234nrlmbmyt : ztrxs9f2kmf32yondwtbq4ydvkqnnvgqm2) : (o6p914387pcqvv1t3b8oipe0e62014234nrlmbmyt | gdek375zjivq8agk75elm);
  wire r_gx112my0sjphb5od  = s1sc92xgxg4q469dtey & px3xebad9kl;
sdio_gnrl_dfflr #(4) uj23tz4bvb2v4h5tunrk92ymdd7x (r_gx112my0sjphb5od, h5lx3ry4f6x78j03qwyqwh3, tbaswct8ktlmcxl5g1cln, ri2ziyy, r46kf);
  wire eajwjfy444n = t604ss4q7elas44sf22nht0;
  wire [15:0] bybkcmpy959vl;
  wire [15:0] hv7lljeygkl;
  wire [15:0] nmqakcwcc;
  wire [15:0] d7ooyzimi43uz2;
  wire [15:0] varvhsjncrgd5;
  wire [15:0] fm67e3rtqlrfv;
  wire [15:0] z2924gcaj;
  wire [15:0] c02bo_q7df05r;
  wire [15:0] x71kp1m_t5okq = agra657i0o0nz9 ? 16'h0 : {bybkcmpy959vl[14:0] , q3v56zbk1[0]};
  wire [15:0] vkplawtd2j8c = agra657i0o0nz9 ? 16'h0 : {hv7lljeygkl[14:0] , q3v56zbk1[1]};
  wire [15:0] kz314eoon9kp = agra657i0o0nz9 ? 16'h0 : {nmqakcwcc[14:0] , q3v56zbk1[2]};
  wire [15:0] txwexbedgz6lyd = agra657i0o0nz9 ? 16'h0 : {d7ooyzimi43uz2[14:0] , q3v56zbk1[3]};
  wire [15:0] ae2z_cvwoqu_zo = agra657i0o0nz9 ? 16'h0 : {varvhsjncrgd5[14:0] , q3v56zbk1[4]};
  wire [15:0] roexnpyzyqgp9 = agra657i0o0nz9 ? 16'h0 : {fm67e3rtqlrfv[14:0] , q3v56zbk1[5]};
  wire [15:0] l5t6ikf0bqt3 = agra657i0o0nz9 ? 16'h0 : {z2924gcaj[14:0] , q3v56zbk1[6]};
  wire [15:0] ipiczlobr69ysk = agra657i0o0nz9 ? 16'h0 : {c02bo_q7df05r[14:0] , q3v56zbk1[7]};
  wire tkjx3ymvfqn  = eajwjfy444n & kdbupylwzq6md8y | agra657i0o0nz9;
  wire blwozpw5c3yibf  = tkjx3ymvfqn & sgr5397hfsvz      | agra657i0o0nz9;
  wire ttosynl7rzui7  = tkjx3ymvfqn & xadq_sq7c_9      | agra657i0o0nz9;
sdio_gnrl_dfflr #(16) nrwq_bslt11o86atu (tkjx3ymvfqn, x71kp1m_t5okq, bybkcmpy959vl, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) rpt0tiwcd46wwu72 (blwozpw5c3yibf, vkplawtd2j8c, hv7lljeygkl, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) sltl35oj37sf5u3jcyi6 (blwozpw5c3yibf, kz314eoon9kp, nmqakcwcc, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) kslrx_wbz7rbju0s7 (blwozpw5c3yibf, txwexbedgz6lyd, d7ooyzimi43uz2, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) li908r5qriu7vazk6ex9 (ttosynl7rzui7, ae2z_cvwoqu_zo, varvhsjncrgd5, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) ptbkot8m6b7iv2f4dyn_ (ttosynl7rzui7, roexnpyzyqgp9, fm67e3rtqlrfv, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) vhfks9do7gh30rc2dvb (ttosynl7rzui7, l5t6ikf0bqt3, z2924gcaj, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) dkjixrjuvdza_d1fj01v (ttosynl7rzui7, ipiczlobr69ysk, c02bo_q7df05r, ri2ziyy, r46kf);
  wire [15:0] e9k324l31662o8rmg;
  wire [15:0] b2nyohig83tylzt_n83o;
  wire [15:0] yxvx0xltoun7utdy6ruktk;
  wire [15:0] vuayehth26qtummcdhr;
  wire [15:0] nsv5p_t1ooz2f61vf4b04_;
  wire [15:0] c3xagxpskcdwrmhg0;
  wire [15:0] qt9wm9up2plfpt83tnqf;
  wire [15:0] v914ixp8kv9e0160d;
  wire [15:0] jca9jjecwpci0__zm29z = agra657i0o0nz9 ? 16'h0 : {e9k324l31662o8rmg[14:0] , q3v56zbk1[0]};
  wire [15:0] pjx5_21glplozwz80j5 = agra657i0o0nz9 ? 16'h0 : {b2nyohig83tylzt_n83o[14:0] , q3v56zbk1[1]};
  wire [15:0] xz17a2807ccq5ldmwa3i66qt = agra657i0o0nz9 ? 16'h0 : {yxvx0xltoun7utdy6ruktk[14:0] , q3v56zbk1[2]};
  wire [15:0] st7z5b2gy9519dhuqsi2gg7x = agra657i0o0nz9 ? 16'h0 : {vuayehth26qtummcdhr[14:0] , q3v56zbk1[3]};
  wire [15:0] drro9lixo48quh4q4jo = agra657i0o0nz9 ? 16'h0 : {nsv5p_t1ooz2f61vf4b04_[14:0] , q3v56zbk1[4]};
  wire [15:0] hbxjdy03rc4yuq8xrgw51 = agra657i0o0nz9 ? 16'h0 : {c3xagxpskcdwrmhg0[14:0] , q3v56zbk1[5]};
  wire [15:0] ytrftil_hgqgka3unogqh = agra657i0o0nz9 ? 16'h0 : {qt9wm9up2plfpt83tnqf[14:0] , q3v56zbk1[6]};
  wire [15:0] pa1mnxwz4rawy3vq9f2ukmv = agra657i0o0nz9 ? 16'h0 : {v914ixp8kv9e0160d[14:0] , q3v56zbk1[7]};
  wire yyox0eygtdin0o58je9l  = eajwjfy444n & o697e7gi_a7g3ne_q52     | agra657i0o0nz9;
  wire cqpg2btneqw_dfkae8yd  = yyox0eygtdin0o58je9l & sgr5397hfsvz | agra657i0o0nz9;
  wire yfpg6ehv281619e9w_8bwk9  = yyox0eygtdin0o58je9l & xadq_sq7c_9 | agra657i0o0nz9;
sdio_gnrl_dfflr #(16) durgp6585l_t7pp1d7ul35qj (yyox0eygtdin0o58je9l, jca9jjecwpci0__zm29z, e9k324l31662o8rmg, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) aggt13lmyi9npjb5yjma917 (cqpg2btneqw_dfkae8yd, pjx5_21glplozwz80j5, b2nyohig83tylzt_n83o, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) to44kt_hfbn2z6c1p8fhaw9zoj4 (cqpg2btneqw_dfkae8yd, xz17a2807ccq5ldmwa3i66qt, yxvx0xltoun7utdy6ruktk, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) u8t2q6bisxbg527s4d24ncg1 (cqpg2btneqw_dfkae8yd, st7z5b2gy9519dhuqsi2gg7x, vuayehth26qtummcdhr, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) dobvly_zax_9b9c76csm9zkm (yfpg6ehv281619e9w_8bwk9, drro9lixo48quh4q4jo, nsv5p_t1ooz2f61vf4b04_, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) wkwo_pk_dq3o8_bb0z_zr_afkpo6 (yfpg6ehv281619e9w_8bwk9, hbxjdy03rc4yuq8xrgw51, c3xagxpskcdwrmhg0, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) abr7nke9ymrwtbbzbiyyurk (yfpg6ehv281619e9w_8bwk9, ytrftil_hgqgka3unogqh, qt9wm9up2plfpt83tnqf, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) ecfzs0vstmt9idqw5fynzwup0 (yfpg6ehv281619e9w_8bwk9, pa1mnxwz4rawy3vq9f2ukmv, v914ixp8kv9e0160d, ri2ziyy, r46kf);
  assign rg7ozwpk7xwi6vdbg8 = bybkcmpy959vl;
  wire jeqkmzls73fae50qt3qfjr2 = o02qvazqk7h10vsyr9n9se5_ & b0kjclghev4;
  wire qvbjfmcpeoi7wwouck5;
sdio_gnrl_dffr #(1) dd1rr0ajkdq9l4n08onc0 (jeqkmzls73fae50qt3qfjr2, qvbjfmcpeoi7wwouck5, ri2ziyy, r46kf);
  wire [15:0] h0byfjzjlhit7t; 
  wire [15:0] myyxz1axh82tpj7ycb; 
  wire [15:0] v4pgir51hmbjii9; 
  wire [15:0] jjivwaedxxxwba3pou8; 
  wire [15:0] yrumc8vz3ffm2nmhpq1; 
  wire [15:0] sme_gq3sv5hdervvhw; 
  wire [15:0] qp14xkvw3kr3bmu4v; 
  wire [15:0] qwbueyuzdv23r2z;
  wire [15:0] yz9l5a6mpgns0t0r = agra657i0o0nz9 ? 16'h0 : dr5092pij19[0];
  wire [15:0] wbv_yaga523oaady = agra657i0o0nz9 ? 16'h0 : dr5092pij19[1];
  wire [15:0] z9c2_8gmcw60zeg6c = agra657i0o0nz9 ? 16'h0 : dr5092pij19[2];
  wire [15:0] jpubyz2faqvq6z12 = agra657i0o0nz9 ? 16'h0 : dr5092pij19[3];
  wire [15:0] wvumxgu7evabh2emy_gg3 = agra657i0o0nz9 ? 16'h0 : dr5092pij19[4];
  wire [15:0] fltffjgd_3jy0aq9nn6y1 = agra657i0o0nz9 ? 16'h0 : dr5092pij19[5];
  wire [15:0] u9vatmhpqhezh06xt = agra657i0o0nz9 ? 16'h0 : dr5092pij19[6];
  wire [15:0] pipydrbh9o7xsw73j4na = agra657i0o0nz9 ? 16'h0 : dr5092pij19[7];
  wire kb62gxgz5v8jk8tqp9y = qvbjfmcpeoi7wwouck5 | agra657i0o0nz9;
  wire oxugfhappsuiqq18atlf = qvbjfmcpeoi7wwouck5 & sgr5397hfsvz | agra657i0o0nz9;
  wire xq5z15yy8mlpeiw = qvbjfmcpeoi7wwouck5 & xadq_sq7c_9 | agra657i0o0nz9;
sdio_gnrl_dfflr #(16) mt78d4sfzun6lfxugiywduo9 (kb62gxgz5v8jk8tqp9y, yz9l5a6mpgns0t0r, h0byfjzjlhit7t, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) f_yzui1kv_04st91o_0gem7w2 (oxugfhappsuiqq18atlf, wbv_yaga523oaady, myyxz1axh82tpj7ycb, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) cmy6td6asuqmxt75cxl2kp (oxugfhappsuiqq18atlf, z9c2_8gmcw60zeg6c, v4pgir51hmbjii9, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) w4vdodbwhy_syq6p65pjh7 (oxugfhappsuiqq18atlf, jpubyz2faqvq6z12, jjivwaedxxxwba3pou8, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) pqbq50tcw96mchy8awlwhg (xq5z15yy8mlpeiw, wvumxgu7evabh2emy_gg3, yrumc8vz3ffm2nmhpq1, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) ttn_btseeka6l1e7bo799 (xq5z15yy8mlpeiw, fltffjgd_3jy0aq9nn6y1, sme_gq3sv5hdervvhw, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) u5niaxyki7fxsj2pwqvl (xq5z15yy8mlpeiw, u9vatmhpqhezh06xt, qp14xkvw3kr3bmu4v, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) xmf0yn3f80moog6muihjv9td (xq5z15yy8mlpeiw, pipydrbh9o7xsw73j4na, qwbueyuzdv23r2z, ri2ziyy, r46kf);
  wire [15:0] o49skpjntf87fvjfra6mve; 
  wire [15:0] t41vxkimlh6g5h_p5qsrbt; 
  wire [15:0] ioqwo9bneliny9il17onqpk; 
  wire [15:0] ivcpva7y2ynzzjsaj59jtbac; 
  wire [15:0] kkhw10v9zhw7ou5nt79kc627bp; 
  wire [15:0] en74tyij2h0r3j8xm35pwa4ubtt; 
  wire [15:0] bbseivbgq5xidqc3igefzzabp; 
  wire [15:0] lrbqbb_l7i0kjf58ilzn6n;
  wire [15:0] oayppsa5b6yjxnopei3xs8jts1 = agra657i0o0nz9 ? 16'h0 : vc16c9mpmz[0];
  wire [15:0] l2r09rs_1sqtr66_q95fwg7lw = agra657i0o0nz9 ? 16'h0 : vc16c9mpmz[1];
  wire [15:0] w41_b12an6zqzd_kphvvauh6k50 = agra657i0o0nz9 ? 16'h0 : vc16c9mpmz[2];
  wire [15:0] w7zxcvjo3az822vaztnleyua4uy26 = agra657i0o0nz9 ? 16'h0 : vc16c9mpmz[3];
  wire [15:0] urmjfyqqjsq4qyeg4pkqr0mic5y = agra657i0o0nz9 ? 16'h0 : vc16c9mpmz[4];
  wire [15:0] exhvn55e1rt74jdxlgnk2kn3oet4j = agra657i0o0nz9 ? 16'h0 : vc16c9mpmz[5];
  wire [15:0] v3sw_yh59q732e0kc9g7w0l6 = agra657i0o0nz9 ? 16'h0 : vc16c9mpmz[6];
  wire [15:0] wrs7x385_6kah95g4pzoueb9m = agra657i0o0nz9 ? 16'h0 : vc16c9mpmz[7];
  wire ftb06sx8qrs5atgki94gh74e = kb62gxgz5v8jk8tqp9y | agra657i0o0nz9; 
  wire p3cltv_w0m3x015ha_av71g = oxugfhappsuiqq18atlf | agra657i0o0nz9; 
  wire y5lnrzzaqt85otlaazij7wygxflj = xq5z15yy8mlpeiw | agra657i0o0nz9; 
sdio_gnrl_dfflr #(16) rdzaha18g1ujrusqarjzhbvkxj8w (ftb06sx8qrs5atgki94gh74e, oayppsa5b6yjxnopei3xs8jts1, o49skpjntf87fvjfra6mve, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) wifnnf_vqy7j8k3xa6e55wwin27a2 (p3cltv_w0m3x015ha_av71g, l2r09rs_1sqtr66_q95fwg7lw, t41vxkimlh6g5h_p5qsrbt, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) jad9znxxbs92zti5gqofqi_3rj0no (p3cltv_w0m3x015ha_av71g, w41_b12an6zqzd_kphvvauh6k50, ioqwo9bneliny9il17onqpk, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) waf9psh1vpk_2fbgdzmh50bq0mzk6s (p3cltv_w0m3x015ha_av71g, w7zxcvjo3az822vaztnleyua4uy26, ivcpva7y2ynzzjsaj59jtbac, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) qpscj11sfxpqimwdv6zwmfkexryl1t (y5lnrzzaqt85otlaazij7wygxflj, urmjfyqqjsq4qyeg4pkqr0mic5y, kkhw10v9zhw7ou5nt79kc627bp, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) n0ete803uqjnrg81n_vehw__4a64igru7 (y5lnrzzaqt85otlaazij7wygxflj, exhvn55e1rt74jdxlgnk2kn3oet4j, en74tyij2h0r3j8xm35pwa4ubtt, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) o0cpktpw_6swv3f8ete9aok48d35193wj (y5lnrzzaqt85otlaazij7wygxflj, v3sw_yh59q732e0kc9g7w0l6, bbseivbgq5xidqc3igefzzabp, ri2ziyy, r46kf);
sdio_gnrl_dfflr #(16) nh80ckv406vig7ctl60bqcy35ez5 (y5lnrzzaqt85otlaazij7wygxflj, wrs7x385_6kah95g4pzoueb9m, lrbqbb_l7i0kjf58ilzn6n, ri2ziyy, r46kf);
  wire o7m1h43uk221z59t9zz5hl96ts = (gv3cqc0xjsdt2l_gn9yg | ctyjchlb_ew2alvt862388s1j);
  wire kxt1p9ueat2c81f ;
  wire vq_pe1y5aeojo3iaq8e2 ;
  wire qw3jbx4ekf2sd164 ;
  wire ct_bs195m91pq38c7zvt =((h0byfjzjlhit7t != bybkcmpy959vl) 
                        | (myyxz1axh82tpj7ycb != hv7lljeygkl) & sgr5397hfsvz
                        | (v4pgir51hmbjii9 != nmqakcwcc) & sgr5397hfsvz
                        | (jjivwaedxxxwba3pou8 != d7ooyzimi43uz2) & sgr5397hfsvz 
                        | (yrumc8vz3ffm2nmhpq1 != varvhsjncrgd5) & xadq_sq7c_9
                        | (sme_gq3sv5hdervvhw != fm67e3rtqlrfv) & xadq_sq7c_9
                        | (qp14xkvw3kr3bmu4v != z2924gcaj) & xadq_sq7c_9
                        | (qwbueyuzdv23r2z != c02bo_q7df05r) & xadq_sq7c_9
                        | ((
                           | (o49skpjntf87fvjfra6mve != e9k324l31662o8rmg) 
                           | (t41vxkimlh6g5h_p5qsrbt != b2nyohig83tylzt_n83o) 
                           | (ioqwo9bneliny9il17onqpk != yxvx0xltoun7utdy6ruktk) 
                           | (ivcpva7y2ynzzjsaj59jtbac != vuayehth26qtummcdhr) 
                           | (kkhw10v9zhw7ou5nt79kc627bp != nsv5p_t1ooz2f61vf4b04_) 
                           | (en74tyij2h0r3j8xm35pwa4ubtt != c3xagxpskcdwrmhg0) 
                           | (bbseivbgq5xidqc3igefzzabp != qt9wm9up2plfpt83tnqf) 
                           | (lrbqbb_l7i0kjf58ilzn6n != v914ixp8kv9e0160d) 
                           ) & qw3jbx4ekf2sd164
                          )
                        ) & o7m1h43uk221z59t9zz5hl96ts & rjh4rfus0ddh2haeqfvz & (~ai1wz5k_jiipo)
                        ;
  wire [15:0] w154kj6l9072gn5qt;
  wire [15:0] xq8p482xf4t2pqjnbmr9 = wnj4jjpcyf ? {w154kj6l9072gn5qt[11:0] , q3v56zbk1[3:0]}
                              : xadq_sq7c_9 ? {q3v56zbk1 , w154kj6l9072gn5qt[15:8]}
                              : w154kj6l9072gn5qt
                              ;
  wire o0962o0gbx_j4qnil = omhes0bmkk6 & glg3dym4wv;
  wire qvbiuj2qlcxisl5olpr  = o0962o0gbx_j4qnil & b0kjclghev4;
sdio_gnrl_dfflr #(16) fs9v4nykbccoc5go6imw (qvbiuj2qlcxisl5olpr, xq8p482xf4t2pqjnbmr9, w154kj6l9072gn5qt, ri2ziyy, r46kf);
  wire [15:0] sc9m9yjfzbcvjeth = {xq8p482xf4t2pqjnbmr9[11:8],xq8p482xf4t2pqjnbmr9[3:0],xq8p482xf4t2pqjnbmr9[15:12],xq8p482xf4t2pqjnbmr9[7:4]};
  wire [15:0] x365c4k_q15r8 = sc9m9yjfzbcvjeth;
  wire [7:0] shhps9lca2c5u = d3hz_rxufgsk9 ;
  assign ope61haknbc4hpuyc4j6 = vbjtunnnne8 & (galaluy047z ? suu86gfec5_q7q8tmn : 1'b1);
  wire [31:0] sh2rxudht;
  wire x1_3k241ccyd0xw0h_q40p9pk9jl = omhes0bmkk6 & ((ehl3l7tbzfy1hz8 & h5luyvmieypxcta0) & gc0nysovke_pmgmxzl | vogcki5p1i5tv8hypf4uea8 & (~gc0nysovke_pmgmxzl)); 
  wire j78eqvridc1rvd6tpfxgjygahfo = omhes0bmkk6 & ((gjuhfa8qi0off4 & h5luyvmieypxcta0) & gc0nysovke_pmgmxzl | d86zay5x74haaxt7_b7b & (~gc0nysovke_pmgmxzl)); 
  wire g93p0fd1fh9j0zupxj_54z78 = omhes0bmkk6 & ((m06syicdkd0ko2oh & h5luyvmieypxcta0) & gc0nysovke_pmgmxzl ); 
  wire wv9uldxw__ffvbupkhcpdafhbw1 = omhes0bmkk6 & ((zjfyfzhen8jp_0v3 | (~h5luyvmieypxcta0)) & gc0nysovke_pmgmxzl | wvnzijys2cpr7ef45jx & (~gc0nysovke_pmgmxzl)); 
  wire [31:0] b4djccpoclcfjzfl = {32{x1_3k241ccyd0xw0h_q40p9pk9jl}} & {24'h0,d3hz_rxufgsk9}
                          | {32{j78eqvridc1rvd6tpfxgjygahfo}} & {16'h0,d3hz_rxufgsk9,sh2rxudht[15:8]}
                          | {32{g93p0fd1fh9j0zupxj_54z78}} & {8'h0,d3hz_rxufgsk9,sh2rxudht[23:8]}
                          | {32{wv9uldxw__ffvbupkhcpdafhbw1}} & {d3hz_rxufgsk9,sh2rxudht[31:8]}
                          | {32{(~omhes0bmkk6)}} & {d3hz_rxufgsk9,sh2rxudht[31:8]}
                          ;
  wire [31:0] ujnncgn7w_23b_afc = {32{x1_3k241ccyd0xw0h_q40p9pk9jl}} & {16'h0,x365c4k_q15r8}
                                | {32{j78eqvridc1rvd6tpfxgjygahfo}} & {16'h0,x365c4k_q15r8}
                                | {32{g93p0fd1fh9j0zupxj_54z78}} & {x365c4k_q15r8,sh2rxudht[31:16]}
                                | {32{wv9uldxw__ffvbupkhcpdafhbw1}} & {x365c4k_q15r8,sh2rxudht[31:16]}
                                | {32{(~omhes0bmkk6)}} & {x365c4k_q15r8,sh2rxudht[31:16]}
                                ;
  wire [31:0] t1z48gn0u1ybizy9aolwet = {32{x1_3k241ccyd0xw0h_q40p9pk9jl}} & {24'h0,shhps9lca2c5u}
                                | {32{j78eqvridc1rvd6tpfxgjygahfo}} & {16'h0,shhps9lca2c5u,sh2rxudht[15:8]}
                                | {32{g93p0fd1fh9j0zupxj_54z78}} & {8'h0,shhps9lca2c5u,sh2rxudht[23:8]}
                                | {32{wv9uldxw__ffvbupkhcpdafhbw1}} & {shhps9lca2c5u,sh2rxudht[31:8]}
                                | {32{(~omhes0bmkk6)}} & {shhps9lca2c5u,sh2rxudht[31:8]}
                                ;
  wire [31:0] jucyl6k599e = ope61haknbc4hpuyc4j6 ? vi2yjdqmw4rsfinydju9
                       : (fp_eq5ouhk_tqfu6 & glg3dym4wv & wnj4jjpcyf) ? ujnncgn7w_23b_afc
                       : (vccxpn342mhjcng52 & glg3dym4wv & xadq_sq7c_9) ? t1z48gn0u1ybizy9aolwet
                       : (vccxpn342mhjcng52 & (~glg3dym4wv)) ? b4djccpoclcfjzfl 
                       : sh2rxudht
                       ;
  wire rtccwysf_fs6 = (ope61haknbc4hpuyc4j6 | vccxpn342mhjcng52 );
  wire ntrecag5cq = agra657i0o0nz9;
  wire bt6pff4wc34cr = rtccwysf_fs6 | ntrecag5cq ;
  wire d_d8a_c2  = bt6pff4wc34cr & (b0kjclghev4 | l9fep860b6nk6naw);
sdio_gnrl_dfflr #(32) c2l4d3iawrbbbar (d_d8a_c2, jucyl6k599e, sh2rxudht, ri2ziyy, r46kf);
  wire oj05srm84wd_f51jpf = (xqoiehiz8vub6 == 2'b00);
  wire w_6cw7wrvruxmapd = (xqoiehiz8vub6 == 2'b01);
  wire h81ub0rv328f0w = (xqoiehiz8vub6 == 2'b10);
  wire kk_fkr6qfypedunlw4 = (xqoiehiz8vub6 == 2'b11);
  wire p0o96gkzpm = (pxbgy7rypk == 3'h0);
  wire jg4_n6wq_k8hyd = (pxbgy7rypk == 3'h1);
  wire [31:0] pvo2a8_b4 = sh2rxudht ;
  wire [3:0] gf4l8z7yfizf = glg3dym4wv ? (  oj05srm84wd_f51jpf ? pvo2a8_b4[7:4] 
                                     : w_6cw7wrvruxmapd ? pvo2a8_b4[15:12]
                                     : h81ub0rv328f0w ? pvo2a8_b4[3:0]
                                     : pvo2a8_b4[11:8]
                                    ) 
                       : (p0o96gkzpm ? pvo2a8_b4[7:4] : pvo2a8_b4[3:0]) ;
  wire [7:0] opri2hvj1a = {pvo2a8_b4[0],pvo2a8_b4[1],pvo2a8_b4[2],pvo2a8_b4[3],pvo2a8_b4[4],pvo2a8_b4[5],pvo2a8_b4[6],pvo2a8_b4[7]};
  assign u4vehljado5 = j0vye3_vnvg ? {7'h0 ,opri2hvj1a[pxbgy7rypk]}
                   : wnj4jjpcyf ? {4'h0 ,gf4l8z7yfizf}
                   : pvo2a8_b4[7:0]
                   ; 
  assign peq874y4ouxh3tpop = ~( u_wyia52cnfyu7wr6tki5l
                         | zvxa5ha3xtxrm_otprvmzv
                         | ft89lx1381fhl6_41gyv9h 
                         | tu5qfca9vvv4sn6cbtskbfo3o
                         | c4wmn9x0tiqe
                         | lh16w9beizuu5b2
                         )
                         ;
   wire zxzltwwm_m4uedcjlmxm = gyis7oviopqvp4s9l & (~galaluy047z)                                
                           | c4wmn9x0tiqe
                           | lh16w9beizuu5b2
                           ;
  assign ngqkrs6caubd718g1tq38hwv1dp = j0vye3_vnvg ? (~zxzltwwm_m4uedcjlmxm) :
                                ~( u_wyia52cnfyu7wr6tki5l
                                | zvxa5ha3xtxrm_otprvmzv
                                | ft89lx1381fhl6_41gyv9h 
                                | tu5qfca9vvv4sn6cbtskbfo3o
                                | zxzltwwm_m4uedcjlmxm
                                 )
                                ;
  wire e34b4r6uytx0njq5zp;
  wire ahs6_q4h2prw88t3kie;
  wire htth1hk131q7qatdiquzd43qci12y;
  wire y5um6ukm4mn5ankgnbx62rmumje7p;
sdio_gnrl_dfflrs #(1) q1y1wfpwyy8zfuncgmnwmlztu (kd3_leo9u11, peq874y4ouxh3tpop, e34b4r6uytx0njq5zp, z_1m_y4u, r46kf);
sdio_gnrl_dfflrs #(1) u_0cdt1wcgzb0rpoioc6tt8 (kd3_leo9u11, peq874y4ouxh3tpop, ahs6_q4h2prw88t3kie, ri2ziyy, r46kf);
sdio_gnrl_dfflrs #(1) rkma1ya3rg8hq1f0hrd8n2862v8rrcm9 (kd3_leo9u11, ngqkrs6caubd718g1tq38hwv1dp, htth1hk131q7qatdiquzd43qci12y, z_1m_y4u, r46kf);
sdio_gnrl_dfflrs #(1) rezu3t9ey0oyw5qjany0w5w_4x73nkb0u1m (kd3_leo9u11, ngqkrs6caubd718g1tq38hwv1dp, y5um6ukm4mn5ankgnbx62rmumje7p, ri2ziyy, r46kf);
  wire bh39lxwyorc69mrkm = glg3dym4wv ? (yqihalm9oqcj35t ? e34b4r6uytx0njq5zp : ahs6_q4h2prw88t3kie) : ahs6_q4h2prw88t3kie;
  assign c2zrvq5jn84hkqq3an_op = (yiu_3s290ga_1r4a_4mvqwkz98i ) & xp1j4p_j67_re9fh04k1 & b0kjclghev4;
  wire qdggy52239kdgctk;
  wire spxc1juna2vdz4zyzcng = c2zrvq5jn84hkqq3an_op;
  wire g738ieag2x3x1kit2lfrsl = qdggy52239kdgctk & (rlixu6nnh60an0djhpn6x0j | jei_o2zgrfpn2);
  wire qheohcj_9z4ys0i_bn1kyso = spxc1juna2vdz4zyzcng | g738ieag2x3x1kit2lfrsl;
  wire l051zgie9j5aht3sri = spxc1juna2vdz4zyzcng ;
sdio_gnrl_dfflr #(1) e7e8ck01z2vzqspxjibvbyuao (qheohcj_9z4ys0i_bn1kyso, l051zgie9j5aht3sri, qdggy52239kdgctk, ri2ziyy, r46kf);
  wire nj8ed52lqu64i7zdo3_ha = y12ivsvul95mvknqda & q5l86lxp_qj0alu5avow & b0kjclghev4;
  wire ebgdpacn7a8ysrue_jufav0e = (~y12ivsvul95mvknqda) & r9rnrmgy8k8bgk_o9 ;
  wire bf_xw2r3stdj96ktjuqowf_ = ~ebgdpacn7a8ysrue_jufav0e;
  wire g085ksn5hlsj75ojp6xmdq = nj8ed52lqu64i7zdo3_ha | ebgdpacn7a8ysrue_jufav0e;
sdio_gnrl_dfflr #(1) mv71v8fbkavwv03qf5amo (g085ksn5hlsj75ojp6xmdq, bf_xw2r3stdj96ktjuqowf_, tf4s6y267vpi5mj50e55 ,ri2ziyy, r46kf);
  assign gyis7oviopqvp4s9l =  tf4s6y267vpi5mj50e55 | nj8ed52lqu64i7zdo3_ha;
  wire qzc235l8;
  wire dm514aruoesrj6t = f86884rwtdpj4yjo9ubx 
                  | ((rlixu6nnh60an0djhpn6x0j | suu86gfec5_q7q8tmn) & (~gv3cqc0xjsdt2l_gn9yg) & (~y12ivsvul95mvknqda))
                  ;
  wire ij32gbzczko_vc = eh3d77scyrgjbd71 & b0kjclghev4 
                  | ((~rlixu6nnh60an0djhpn6x0j) & vccxpn342mhjcng52)  
                  | ((~suu86gfec5_q7q8tmn) & vbjtunnnne8 )
                  | y12ivsvul95mvknqda & bm_xps5wkhksbomvr6k1d7s0x7cbvw_  & b0kjclghev4
                  ;
  wire arhqmctdgwkfd = dm514aruoesrj6t | ij32gbzczko_vc;
  wire ak0t81nxwk8c4f4 = (~ij32gbzczko_vc) ;
sdio_gnrl_dfflr #(1) yrj_fbmanbda7ow6 (arhqmctdgwkfd, ak0t81nxwk8c4f4, qzc235l8, ri2ziyy, r46kf);
  assign ybit4wql4fd_1hwvj_2dgs = (tbaswct8ktlmcxl5g1cln != 4'h5) & (~gdayv_v5udtp5x93tt);
  wire doipg47hixjdcb0kut1ebcneannb = jlnl3ab6elmu4mi0zapi0lgnio & ybit4wql4fd_1hwvj_2dgs;
  wire [5:0] gzsudkkux20;
  wire uabji7h8rcmbh4mn_u26waq =  (ctyjchlb_ew2alvt862388s1j & ogwbfmqpmwsu);
  wire kkn5h2d3f5n0cgu5iz2xr9_l3pqy4f7 = (p1yma33ydk44rbnnpcsnj6t81hs & ogwbfmqpmwsu) 
                                       | doipg47hixjdcb0kut1ebcneannb 
                                       ;
  wire k96k1bu_gm4hl2u5bnnk = k_d8ubsroodv2n7sci31a71 & wygays4nr6160p3te58x & mqoxpdhtx6xq7yh28 & (~gdayv_v5udtp5x93tt); 
  wire phbrqkkvb5ogwb = k96k1bu_gm4hl2u5bnnk 
                  | uabji7h8rcmbh4mn_u26waq 
                  | kkn5h2d3f5n0cgu5iz2xr9_l3pqy4f7
                  | ct_bs195m91pq38c7zvt
                  ;
  wire p3xi9ecjjdtvj = agra657i0o0nz9 ;
  wire q6p_jiasjo5vu3c = phbrqkkvb5ogwb; 
  wire qmzoul0xz1t = q6p_jiasjo5vu3c | p3xi9ecjjdtvj;
  wire [5:0] v3if5w8h9_arx = p3xi9ecjjdtvj ? 6'h0  
                        : uabji7h8rcmbh4mn_u26waq ? (gzsudkkux20 | q3a_qhn0oez6_qdw42u8s)
                        : k96k1bu_gm4hl2u5bnnk ? (gzsudkkux20 | ow_3nyc73uhyssvbhzcp)
                        : kkn5h2d3f5n0cgu5iz2xr9_l3pqy4f7 ? (gzsudkkux20 | uzb3tru66fafrwv66ay0j27sparrt)
                        : ct_bs195m91pq38c7zvt ? (gzsudkkux20 | ipx85njsp8lphv3dn79jvi7o)
                        : gzsudkkux20
                        ;
sdio_gnrl_dfflr #(6) hvmgwojsuen92xwkdid (qmzoul0xz1t, v3if5w8h9_arx, gzsudkkux20, ri2ziyy, qgek6hz5rfs6m);
  wire ei9cok17if49dhx7 = (oek_aiemroj9httja91b2[1:0] == 2'b00);
  wire a6nyrntabd5h48_ = (oek_aiemroj9httja91b2[1:0] == 2'b01);
  wire v5z4uvqtd1pw3 = (oek_aiemroj9httja91b2[1:0] == 2'b10);
  wire j1roosvuw068ahfb = (oek_aiemroj9httja91b2[1:0] == 2'b11);
  wire vmd5m7ychtawe = (n06jxxux2kra522pn8[1:0] == 2'b00);
  wire sihlqhl4tlaykrp9 = (n06jxxux2kra522pn8[1:0] == 2'b01);
  wire yj49jn1d4ff9ofa4b = (n06jxxux2kra522pn8[1:0] == 2'b10);
  wire z431ojubhpj6h0q = (n06jxxux2kra522pn8[1:0] == 2'b11);
 assign yei_um48bvirkv6 = (rsaai7kypzjqvn5mqzbfqk35 & vmd5m7ychtawe);
  assign ehl3l7tbzfy1hz8 = vmd5m7ychtawe & ei9cok17if49dhx7
                     | yj49jn1d4ff9ofa4b & v5z4uvqtd1pw3
                     ;
  assign gjuhfa8qi0off4 = vmd5m7ychtawe & a6nyrntabd5h48_ 
                     | sihlqhl4tlaykrp9 & ei9cok17if49dhx7
                     | sihlqhl4tlaykrp9 & v5z4uvqtd1pw3
                     | yj49jn1d4ff9ofa4b & a6nyrntabd5h48_
                     ;
  assign m06syicdkd0ko2oh = vmd5m7ychtawe & v5z4uvqtd1pw3
                     | yj49jn1d4ff9ofa4b & ei9cok17if49dhx7
                     ;
  assign zjfyfzhen8jp_0v3 = vmd5m7ychtawe & j1roosvuw068ahfb
                     | sihlqhl4tlaykrp9 & a6nyrntabd5h48_
                     | sihlqhl4tlaykrp9 & j1roosvuw068ahfb
                     | yj49jn1d4ff9ofa4b & j1roosvuw068ahfb
                     | z431ojubhpj6h0q & ei9cok17if49dhx7
                     | z431ojubhpj6h0q & a6nyrntabd5h48_
                     | z431ojubhpj6h0q & v5z4uvqtd1pw3
                     | z431ojubhpj6h0q & j1roosvuw068ahfb
                     ;
  wire yuwkcnmgdcplx = aqsracxgpxslz_26 & vccxpn342mhjcng52;
  wire x48fixi6chekb = wfpp61d0m__51c5 & vccxpn342mhjcng52;
  wire uina6npy8scnka = r11mpywn5dvpr__hu & vccxpn342mhjcng52;
  wire fhj4vchdzkpa9e40 = c5ebjjcolimuifvk & vccxpn342mhjcng52;
  assign qcoc_k8niw91gnvei2 = fhj4vchdzkpa9e40 ;
  wire y20h8plzplvj6oo =  ehl3l7tbzfy1hz8 & yuwkcnmgdcplx;
  wire gezetdiy70chdp2b =  gjuhfa8qi0off4 & x48fixi6chekb;
  wire zn22dxp7pu80jwhzr =  m06syicdkd0ko2oh & uina6npy8scnka;
  wire vn6zd4wo01p5rd5duf7 =  zjfyfzhen8jp_0v3 & fhj4vchdzkpa9e40;
  wire g9fv0fxalx9b9u = (~gc0nysovke_pmgmxzl) & (~klyx_f6kq8fo1mv_vz9vwacb);
  assign qnj8ewpax371dfm8_ =  xpkcrgdgylkka38e8updvzn & vccxpn342mhjcng52 & g9fv0fxalx9b9u;
  assign spyhe991j9oxj3 =  alutp3dhus3g3aqnji39 & (x48fixi6chekb | fhj4vchdzkpa9e40) & g9fv0fxalx9b9u;
  assign d_k8v4bgightmy =  zl_cgu_264m2iid5ka & fhj4vchdzkpa9e40 & g9fv0fxalx9b9u;
  assign kwbz7l_18a6wdnw7s =  vogcki5p1i5tv8hypf4uea8 & vccxpn342mhjcng52 & (~gc0nysovke_pmgmxzl);
  assign d50q7cnxh_tu7v4t =  d86zay5x74haaxt7_b7b & (x48fixi6chekb | fhj4vchdzkpa9e40) & (~gc0nysovke_pmgmxzl);
  assign dletywvbyl65l8u8r =  wvnzijys2cpr7ef45jx & fhj4vchdzkpa9e40 & (~gc0nysovke_pmgmxzl);
  wire uk8i3a9gh3q4i = (mbg29lzp7nsh & nram81jeokitgj_oc5dha) & (~gdayv_v5udtp5x93tt);
  wire x52ar1b8xxk77cymmlr1v0zg = gc0nysovke_pmgmxzl & (uk8i3a9gh3q4i ? (( y20h8plzplvj6oo 
                                                                | gezetdiy70chdp2b 
                                                                | zn22dxp7pu80jwhzr 
                                                                | vn6zd4wo01p5rd5duf7 
                                                                ) & (~klyx_f6kq8fo1mv_vz9vwacb) 
                                                               )
                                                               : vccxpn342mhjcng52 & fhj4vchdzkpa9e40 & (~klyx_f6kq8fo1mv_vz9vwacb));
  assign xvj8thqd_hxxebzp0k = x52ar1b8xxk77cymmlr1v0zg 
                            | qnj8ewpax371dfm8_ 
                            | spyhe991j9oxj3 
                            | d_k8v4bgightmy
                            ;
  assign xp1j4p_j67_re9fh04k1 = x52ar1b8xxk77cymmlr1v0zg  
                            | kwbz7l_18a6wdnw7s 
                            | d50q7cnxh_tu7v4t 
                            | dletywvbyl65l8u8r
                            ;
  assign tha8k2w4l29if7 = c59n90h_2jf ? q3v56zbk1 : rnmrka264vb;
  assign cd9aurq1b8zkxmwlf = c59n90h_2jf ? q3v56zbk1 : rnmrka264vb;
  wire g7uocnrbae44t = sgr5397hfsvz & ku1o1xek2lz;
  wire kwwxmhyj57m2_yxj = xadq_sq7c_9 & ku1o1xek2lz;
  assign qa3tq4wj_0po_6d2emr_4[0] = ku1o1xek2lz;
  assign qa3tq4wj_0po_6d2emr_4[1] = g7uocnrbae44t;
  assign qa3tq4wj_0po_6d2emr_4[2] = g7uocnrbae44t;
  assign qa3tq4wj_0po_6d2emr_4[3] = g7uocnrbae44t;
  assign qa3tq4wj_0po_6d2emr_4[4] = kwwxmhyj57m2_yxj;
  assign qa3tq4wj_0po_6d2emr_4[5] = kwwxmhyj57m2_yxj;
  assign qa3tq4wj_0po_6d2emr_4[6] = kwwxmhyj57m2_yxj;
  assign qa3tq4wj_0po_6d2emr_4[7] = kwwxmhyj57m2_yxj;
  assign kxt1p9ueat2c81f = ku1o1xek2lz & glg3dym4wv;
  assign vq_pe1y5aeojo3iaq8e2 = g7uocnrbae44t & glg3dym4wv;
  assign qw3jbx4ekf2sd164 = kwwxmhyj57m2_yxj & glg3dym4wv;
  assign r52iqmee59hluv2t0sde[0] = kxt1p9ueat2c81f;
  assign r52iqmee59hluv2t0sde[1] = vq_pe1y5aeojo3iaq8e2;
  assign r52iqmee59hluv2t0sde[2] = vq_pe1y5aeojo3iaq8e2;
  assign r52iqmee59hluv2t0sde[3] = vq_pe1y5aeojo3iaq8e2;
  assign r52iqmee59hluv2t0sde[4] = qw3jbx4ekf2sd164;
  assign r52iqmee59hluv2t0sde[5] = qw3jbx4ekf2sd164;
  assign r52iqmee59hluv2t0sde[6] = qw3jbx4ekf2sd164;
  assign r52iqmee59hluv2t0sde[7] = qw3jbx4ekf2sd164;
  assign ma_crd6ftxx8gbgb0qr5px76[0] = an6dkw9hhw5m_f;
  assign ma_crd6ftxx8gbgb0qr5px76[1] = an6dkw9hhw5m_f;
  assign ma_crd6ftxx8gbgb0qr5px76[2] = an6dkw9hhw5m_f;
  assign ma_crd6ftxx8gbgb0qr5px76[3] = an6dkw9hhw5m_f;
  assign ma_crd6ftxx8gbgb0qr5px76[4] = an6dkw9hhw5m_f;
  assign ma_crd6ftxx8gbgb0qr5px76[5] = an6dkw9hhw5m_f;
  assign ma_crd6ftxx8gbgb0qr5px76[6] = an6dkw9hhw5m_f;
  assign ma_crd6ftxx8gbgb0qr5px76[7] = an6dkw9hhw5m_f;
  assign c1dkaq4khry17spoaottq[0] = an6dkw9hhw5m_f;
  assign c1dkaq4khry17spoaottq[1] = an6dkw9hhw5m_f;
  assign c1dkaq4khry17spoaottq[2] = an6dkw9hhw5m_f;
  assign c1dkaq4khry17spoaottq[3] = an6dkw9hhw5m_f;
  assign c1dkaq4khry17spoaottq[4] = an6dkw9hhw5m_f;
  assign c1dkaq4khry17spoaottq[5] = an6dkw9hhw5m_f;
  assign c1dkaq4khry17spoaottq[6] = an6dkw9hhw5m_f;
  assign c1dkaq4khry17spoaottq[7] = an6dkw9hhw5m_f;
  wire f4zy8j21zgt8zeod = sgr5397hfsvz & vg0d7ni5a9wfdgv;
  wire w5jlz08vl5i1pkewa0vb = xadq_sq7c_9 & vg0d7ni5a9wfdgv;
  assign brlulodayvzctgtcxeexngodi[0] = vg0d7ni5a9wfdgv;
  assign brlulodayvzctgtcxeexngodi[1] = f4zy8j21zgt8zeod;
  assign brlulodayvzctgtcxeexngodi[2] = f4zy8j21zgt8zeod;
  assign brlulodayvzctgtcxeexngodi[3] = f4zy8j21zgt8zeod;
  assign brlulodayvzctgtcxeexngodi[4] = w5jlz08vl5i1pkewa0vb;
  assign brlulodayvzctgtcxeexngodi[5] = w5jlz08vl5i1pkewa0vb;
  assign brlulodayvzctgtcxeexngodi[6] = w5jlz08vl5i1pkewa0vb;
  assign brlulodayvzctgtcxeexngodi[7] = w5jlz08vl5i1pkewa0vb;
  wire m6p7hgs3herkiwax1dxtz2ax = f4zy8j21zgt8zeod & glg3dym4wv;
  wire v4lyrbp5fka4e5ovev2 = w5jlz08vl5i1pkewa0vb & glg3dym4wv;
  assign a0m84gvjr3lrz75863sagsuc[0] = vg0d7ni5a9wfdgv & glg3dym4wv;
  assign a0m84gvjr3lrz75863sagsuc[1] = m6p7hgs3herkiwax1dxtz2ax;
  assign a0m84gvjr3lrz75863sagsuc[2] = m6p7hgs3herkiwax1dxtz2ax;
  assign a0m84gvjr3lrz75863sagsuc[3] = m6p7hgs3herkiwax1dxtz2ax;
  assign a0m84gvjr3lrz75863sagsuc[4] = v4lyrbp5fka4e5ovev2;
  assign a0m84gvjr3lrz75863sagsuc[5] = v4lyrbp5fka4e5ovev2;
  assign a0m84gvjr3lrz75863sagsuc[6] = v4lyrbp5fka4e5ovev2;
  assign a0m84gvjr3lrz75863sagsuc[7] = v4lyrbp5fka4e5ovev2;
  wire oc1_zr426hom7 = sgr5397hfsvz ? bh39lxwyorc69mrkm : 1'b1;
  wire czy5irhw6 = xadq_sq7c_9 ? bh39lxwyorc69mrkm : 1'b1;
  assign j5lpulyyl0y6tq[0] = bh39lxwyorc69mrkm;
  assign j5lpulyyl0y6tq[1] = oc1_zr426hom7;
  assign j5lpulyyl0y6tq[2] = glg3dym4wv ? (yqihalm9oqcj35t ? htth1hk131q7qatdiquzd43qci12y : y5um6ukm4mn5ankgnbx62rmumje7p) : y5um6ukm4mn5ankgnbx62rmumje7p; 
  assign j5lpulyyl0y6tq[3] = oc1_zr426hom7;
  assign j5lpulyyl0y6tq[4] = czy5irhw6;
  assign j5lpulyyl0y6tq[5] = czy5irhw6;
  assign j5lpulyyl0y6tq[6] = czy5irhw6;
  assign j5lpulyyl0y6tq[7] = czy5irhw6;
  assign h0bszfaqg28q45 = mjpt9 ;
  assign hxqzu4xws6 = mqoxpdhtx6xq7yh28;
  assign ef0q7sx70v7r6i = galaluy047z ? qzc235l8 : 1'b1;
  assign l9fep860b6nk6naw = (dvvdm0wywfwyo5sl & glg3dym4wv & (~qzc235l8) & dm514aruoesrj6t & u_wyia52cnfyu7wr6tki5l);
  assign j_22owq22ygfp83tlkymx0 = ope61haknbc4hpuyc4j6 & (b0kjclghev4 | l9fep860b6nk6naw);
  assign nahnyoriw3y4r6rdpdn5jd2 = qdggy52239kdgctk;
  assign snnj17b9zawct6n7sh = sh2rxudht;
  assign sfc8z6ce = mjpt9;
  assign jn1vqljcjmhbzhu5c = (y67em4qnwy831[2:0] == 3'b010) & ob4_d6lmvjd0qvpmwvze8xcu & prcn884lva67kz ;
  assign lo13ulq1cqk5ucx17t = (y67em4qnwy831[2:0] != 3'b010) & ob4_d6lmvjd0qvpmwvze8xcu & prcn884lva67kz ;
  assign gopxzi6z = phbrqkkvb5ogwb;
  assign ujh3s3is5 =  gzsudkkux20 ;
  assign s5upgf3pot8ypw9_ = (~gv3cqc0xjsdt2l_gn9yg);
  assign y9nffq1claqkfzysy8 = gv3cqc0xjsdt2l_gn9yg;
  assign y5u3u9h83new6z3za = u_wyia52cnfyu7wr6tki5l 
                         | yiu_3s290ga_1r4a_4mvqwkz98i 
                         | ft89lx1381fhl6_41gyv9h 
                         | t604ss4q7elas44sf22nht0 
                         | zvxa5ha3xtxrm_otprvmzv
                         | ctyjchlb_ew2alvt862388s1j
                         ;
        v6xjcd_5032y54f ziv_wg7g8s3yhebodcybu (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( kdbupylwzq6md8y     ),
          .r3vi2c1fh       ( dr5092pij19[0]       ),
          .f3evaxx8f9dr86i701a( cceu_gm1ydxv_zeb43[0]   ),
          .ygli0hkz        ( tha8k2w4l29if7[0]    ),
          .fv1t4udtvxdm       ( brlulodayvzctgtcxeexngodi[0] ),
          .ho56_v0li6         ( ma_crd6ftxx8gbgb0qr5px76[0]   ),
          .t0g2vtmb      ( qa3tq4wj_0po_6d2emr_4[0]    )
        );
        v6xjcd_5032y54f gqm05z82ty6rmgfk1ikk (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( kdbupylwzq6md8y     ),
          .r3vi2c1fh       ( dr5092pij19[1]       ),
          .f3evaxx8f9dr86i701a( cceu_gm1ydxv_zeb43[1]   ),
          .ygli0hkz        ( tha8k2w4l29if7[1]    ),
          .fv1t4udtvxdm       ( brlulodayvzctgtcxeexngodi[1] ),
          .ho56_v0li6         ( ma_crd6ftxx8gbgb0qr5px76[1]   ),
          .t0g2vtmb      ( qa3tq4wj_0po_6d2emr_4[1]    )
        );
        v6xjcd_5032y54f eotfu1pre17xuhy7r1t1 (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( kdbupylwzq6md8y     ),
          .r3vi2c1fh       ( dr5092pij19[2]       ),
          .f3evaxx8f9dr86i701a( cceu_gm1ydxv_zeb43[2]   ),
          .ygli0hkz        ( tha8k2w4l29if7[2]    ),
          .fv1t4udtvxdm       ( brlulodayvzctgtcxeexngodi[2] ),
          .ho56_v0li6         ( ma_crd6ftxx8gbgb0qr5px76[2]   ),
          .t0g2vtmb      ( qa3tq4wj_0po_6d2emr_4[2]    )
        );
        v6xjcd_5032y54f e9ezwximoa1x5qnzy98 (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( kdbupylwzq6md8y     ),
          .r3vi2c1fh       ( dr5092pij19[3]       ),
          .f3evaxx8f9dr86i701a( cceu_gm1ydxv_zeb43[3]   ),
          .ygli0hkz        ( tha8k2w4l29if7[3]    ),
          .fv1t4udtvxdm       ( brlulodayvzctgtcxeexngodi[3] ),
          .ho56_v0li6         ( ma_crd6ftxx8gbgb0qr5px76[3]   ),
          .t0g2vtmb      ( qa3tq4wj_0po_6d2emr_4[3]    )
        );
        v6xjcd_5032y54f je2zo29z9c068o1uwr8 (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( kdbupylwzq6md8y     ),
          .r3vi2c1fh       ( dr5092pij19[4]       ),
          .f3evaxx8f9dr86i701a( cceu_gm1ydxv_zeb43[4]   ),
          .ygli0hkz        ( tha8k2w4l29if7[4]    ),
          .fv1t4udtvxdm       ( brlulodayvzctgtcxeexngodi[4] ),
          .ho56_v0li6         ( ma_crd6ftxx8gbgb0qr5px76[4]   ),
          .t0g2vtmb      ( qa3tq4wj_0po_6d2emr_4[4]    )
        );
        v6xjcd_5032y54f oldtlxrf31nfev89g (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( kdbupylwzq6md8y     ),
          .r3vi2c1fh       ( dr5092pij19[5]       ),
          .f3evaxx8f9dr86i701a( cceu_gm1ydxv_zeb43[5]   ),
          .ygli0hkz        ( tha8k2w4l29if7[5]    ),
          .fv1t4udtvxdm       ( brlulodayvzctgtcxeexngodi[5] ),
          .ho56_v0li6         ( ma_crd6ftxx8gbgb0qr5px76[5]   ),
          .t0g2vtmb      ( qa3tq4wj_0po_6d2emr_4[5]    )
        );
        v6xjcd_5032y54f ddjrbrclg2vhjafk1u (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( kdbupylwzq6md8y     ),
          .r3vi2c1fh       ( dr5092pij19[6]       ),
          .f3evaxx8f9dr86i701a( cceu_gm1ydxv_zeb43[6]   ),
          .ygli0hkz        ( tha8k2w4l29if7[6]    ),
          .fv1t4udtvxdm       ( brlulodayvzctgtcxeexngodi[6] ),
          .ho56_v0li6         ( ma_crd6ftxx8gbgb0qr5px76[6]   ),
          .t0g2vtmb      ( qa3tq4wj_0po_6d2emr_4[6]    )
        );
        v6xjcd_5032y54f f8xpn3q6po_phu7xscf (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( kdbupylwzq6md8y     ),
          .r3vi2c1fh       ( dr5092pij19[7]       ),
          .f3evaxx8f9dr86i701a( cceu_gm1ydxv_zeb43[7]   ),
          .ygli0hkz        ( tha8k2w4l29if7[7]    ),
          .fv1t4udtvxdm       ( brlulodayvzctgtcxeexngodi[7] ),
          .ho56_v0li6         ( ma_crd6ftxx8gbgb0qr5px76[7]   ),
          .t0g2vtmb      ( qa3tq4wj_0po_6d2emr_4[7]    )
        );
        v6xjcd_5032y54f yq5a1kc1ncx4i0oo (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( o697e7gi_a7g3ne_q52     ),
          .r3vi2c1fh       ( vc16c9mpmz[0]       ),
          .f3evaxx8f9dr86i701a( llnwz3o5l_l6wpy35[0]   ),
          .ygli0hkz        ( cd9aurq1b8zkxmwlf[0]    ),
          .fv1t4udtvxdm       ( a0m84gvjr3lrz75863sagsuc[0] ),
          .ho56_v0li6         ( c1dkaq4khry17spoaottq[0]   ),
          .t0g2vtmb      ( r52iqmee59hluv2t0sde[0]    )
        );
        v6xjcd_5032y54f sxltckjv7fwug0sc3hq (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( o697e7gi_a7g3ne_q52     ),
          .r3vi2c1fh       ( vc16c9mpmz[1]       ),
          .f3evaxx8f9dr86i701a( llnwz3o5l_l6wpy35[1]   ),
          .ygli0hkz        ( cd9aurq1b8zkxmwlf[1]    ),
          .fv1t4udtvxdm       ( a0m84gvjr3lrz75863sagsuc[1] ),
          .ho56_v0li6         ( c1dkaq4khry17spoaottq[1]   ),
          .t0g2vtmb      ( r52iqmee59hluv2t0sde[1]    )
        );
        v6xjcd_5032y54f cad6prgnitzj7uh42 (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( o697e7gi_a7g3ne_q52     ),
          .r3vi2c1fh       ( vc16c9mpmz[2]       ),
          .f3evaxx8f9dr86i701a( llnwz3o5l_l6wpy35[2]   ),
          .ygli0hkz        ( cd9aurq1b8zkxmwlf[2]    ),
          .fv1t4udtvxdm       ( a0m84gvjr3lrz75863sagsuc[2] ),
          .ho56_v0li6         ( c1dkaq4khry17spoaottq[2]   ),
          .t0g2vtmb      ( r52iqmee59hluv2t0sde[2]    )
        );
        v6xjcd_5032y54f bz9aox2udjihuiakcj5 (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( o697e7gi_a7g3ne_q52     ),
          .r3vi2c1fh       ( vc16c9mpmz[3]       ),
          .f3evaxx8f9dr86i701a( llnwz3o5l_l6wpy35[3]   ),
          .ygli0hkz        ( cd9aurq1b8zkxmwlf[3]    ),
          .fv1t4udtvxdm       ( a0m84gvjr3lrz75863sagsuc[3] ),
          .ho56_v0li6         ( c1dkaq4khry17spoaottq[3]   ),
          .t0g2vtmb      ( r52iqmee59hluv2t0sde[3]    )
        );
        v6xjcd_5032y54f mjjnq9a_tpo8sl3cj (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( o697e7gi_a7g3ne_q52     ),
          .r3vi2c1fh       ( vc16c9mpmz[4]       ),
          .f3evaxx8f9dr86i701a( llnwz3o5l_l6wpy35[4]   ),
          .ygli0hkz        ( cd9aurq1b8zkxmwlf[4]    ),
          .fv1t4udtvxdm       ( a0m84gvjr3lrz75863sagsuc[4] ),
          .ho56_v0li6         ( c1dkaq4khry17spoaottq[4]   ),
          .t0g2vtmb      ( r52iqmee59hluv2t0sde[4]    )
        );
        v6xjcd_5032y54f ut6kulydm0f46usr (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( o697e7gi_a7g3ne_q52     ),
          .r3vi2c1fh       ( vc16c9mpmz[5]       ),
          .f3evaxx8f9dr86i701a( llnwz3o5l_l6wpy35[5]   ),
          .ygli0hkz        ( cd9aurq1b8zkxmwlf[5]    ),
          .fv1t4udtvxdm       ( a0m84gvjr3lrz75863sagsuc[5] ),
          .ho56_v0li6         ( c1dkaq4khry17spoaottq[5]   ),
          .t0g2vtmb      ( r52iqmee59hluv2t0sde[5]    )
        );
        v6xjcd_5032y54f r198ff49zvufcsqdkz7 (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( o697e7gi_a7g3ne_q52     ),
          .r3vi2c1fh       ( vc16c9mpmz[6]       ),
          .f3evaxx8f9dr86i701a( llnwz3o5l_l6wpy35[6]   ),
          .ygli0hkz        ( cd9aurq1b8zkxmwlf[6]    ),
          .fv1t4udtvxdm       ( a0m84gvjr3lrz75863sagsuc[6] ),
          .ho56_v0li6         ( c1dkaq4khry17spoaottq[6]   ),
          .t0g2vtmb      ( r52iqmee59hluv2t0sde[6]    )
        );
        v6xjcd_5032y54f haljm95a5j2ln2ogg9mkc (
          .lczv3cn         ( ri2ziyy            ),
          .r38027_km3        ( r46kf          ),
          .px3xebad9kl    ( o697e7gi_a7g3ne_q52     ),
          .r3vi2c1fh       ( vc16c9mpmz[7]       ),
          .f3evaxx8f9dr86i701a( llnwz3o5l_l6wpy35[7]   ),
          .ygli0hkz        ( cd9aurq1b8zkxmwlf[7]    ),
          .fv1t4udtvxdm       ( a0m84gvjr3lrz75863sagsuc[7] ),
          .ho56_v0li6         ( c1dkaq4khry17spoaottq[7]   ),
          .t0g2vtmb      ( r52iqmee59hluv2t0sde[7]    )
        );
endmodule
