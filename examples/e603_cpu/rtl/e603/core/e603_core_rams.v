 /*                                                                      
  *  Copyright (c) 2018-2023 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */ 
`include "global.v"

module e603_core_rams (
  input              jtag_TCK                      ,
  input              jtag_TMS_in                   ,
  input              jtag_TDI                      ,
  output             jtag_TDO                      ,
  output             jtag_DRV_TDO                  ,
  output             jtag_TMS_out                  ,
  output             jtag_DRV_TMS                  ,
  output             jtag_BK_TMS                   ,
  output             jtag_dwen                     ,
  input              jtag_dwbypass                 ,
  input              i_dbg_stop                    ,
  input              override_dm_sleep             ,
  output             hart_halted                   ,
  output             dbg_stoptime                  ,
  input              mem_arready                   ,
  output             mem_arvalid                   ,
  output [  31:   0] mem_araddr                    ,
  output [   7:   0] mem_arlen                     ,
  output [   2:   0] mem_arsize                    ,
  output [   1:   0] mem_arburst                   ,
  output             mem_arlock                    ,
  output [   3:   0] mem_arcache                   ,
  output [   2:   0] mem_arprot                    ,
  output [   2:   0] mem_arid                      ,
  input              mem_awready                   ,
  output             mem_awvalid                   ,
  output [  31:   0] mem_awaddr                    ,
  output [   7:   0] mem_awlen                     ,
  output [   2:   0] mem_awsize                    ,
  output [   1:   0] mem_awburst                   ,
  output             mem_awlock                    ,
  output [   3:   0] mem_awcache                   ,
  output [   2:   0] mem_awprot                    ,
  output [   2:   0] mem_awid                      ,
  input              mem_wready                    ,
  output             mem_wvalid                    ,
  output [  63:   0] mem_wdata                     ,
  output [   7:   0] mem_wstrb                     ,
  output             mem_wlast                     ,
  output             mem_rready                    ,
  input              mem_rvalid                    ,
  input  [  63:   0] mem_rdata                     ,
  input  [   1:   0] mem_rresp                     ,
  input              mem_rlast                     ,
  input  [   2:   0] mem_rid                       ,
  output             mem_bready                    ,
  input              mem_bvalid                    ,
  input  [   1:   0] mem_bresp                     ,
  input  [   2:   0] mem_bid                       ,
  input              mem_clk_en                    ,
  output             tx_evt                        ,
  input              rx_evt                        ,
  input  [   9:   0] hart_id                       ,
  input  [  39:   0] reset_vector                  ,
  output             core_wfi_mode                 ,
  output             core_sleep_value              ,
  input              nice_mem_holdup               ,
  output             nice_req_valid                ,
  input              nice_req_ready                ,
  output [  31:   0] nice_req_instr                ,
  output [  63:   0] nice_req_rs1                  ,
  output [  63:   0] nice_req_rs2                  ,
  output             nice_req_mmode                ,
  output             nice_req_smode                ,
  input              nice_rsp_1cyc_type            ,
  input  [  63:   0] nice_rsp_1cyc_dat             ,
  input              nice_rsp_multicyc_valid       ,
  output             nice_rsp_multicyc_ready       ,
  input  [  63:   0] nice_rsp_multicyc_dat         ,
  input              nice_rsp_multicyc_err         ,
  input              nice_icb_cmd_valid            ,
  output             nice_icb_cmd_ready            ,
  input  [  31:   0] nice_icb_cmd_addr             ,
  input              nice_icb_cmd_read             ,
  input  [  63:   0] nice_icb_cmd_wdata            ,
  input  [   7:   0] nice_icb_cmd_wmask            ,
  input  [   2:   0] nice_icb_cmd_size             ,
  input              nice_icb_cmd_mmode            ,
  input              nice_icb_cmd_smode            ,
  output             nice_icb_rsp_valid            ,
  input              nice_icb_rsp_ready            ,
  output [  63:   0] nice_icb_rsp_rdata            ,
  output             nice_icb_rsp_err              ,
  input              dbg_toggle_a                  ,
  input              dcache_disable_init           ,
  input              icache_disable_init           ,
  input              mmu_tlb_disable_init          ,
  output             sysrstreq                     ,
  input              mtime_toggle_a                ,
  input              nmi                           ,
  input  [  63:   0] irq_i                         ,
  output             i0_trace_ivalid               ,
  output             i0_trace_iexception           ,
  output             i0_trace_interrupt            ,
  output [  63:   0] i0_trace_cause                ,
  output [  63:   0] i0_trace_tval                 ,
  output [  63:   0] i0_trace_iaddr                ,
  output [  31:   0] i0_trace_instr                ,
  output [   1:   0] i0_trace_priv                 ,
  output             i0_trace_bjp_taken            ,
  output             i0_trace_dmode                ,
  output             i0_trace_cmt_ena              ,
  input              core_clk_aon                  ,
  input              clkgate_bypass                ,
  input              stop_on_reset                 ,
  input              core_reset_n                  ,
  input              por_reset_n                   ,
  input              reset_bypass                  
 );


  wire                icache_tag0_cs                ;
  wire                icache_tag0_we                ;
  wire    [   7:   0] icache_tag0_addr              ;
  wire    [  21:   0] icache_tag0_din               ;
  wire    [  21:   0] icache_tag0_dout              ;
  wire                clk_icache_tag0               ;
  wire                icache_data0_cs               ;
  wire                icache_data0_we               ;
  wire    [  10:   0] icache_data0_addr             ;
  wire    [  63:   0] icache_data0_din              ;
  wire    [  63:   0] icache_data0_dout             ;
  wire                clk_icache_data0              ;
  wire                icache_tag1_cs                ;
  wire                icache_tag1_we                ;
  wire    [   7:   0] icache_tag1_addr              ;
  wire    [  21:   0] icache_tag1_din               ;
  wire    [  21:   0] icache_tag1_dout              ;
  wire                clk_icache_tag1               ;
  wire                icache_data1_cs               ;
  wire                icache_data1_we               ;
  wire    [  10:   0] icache_data1_addr             ;
  wire    [  63:   0] icache_data1_din              ;
  wire    [  63:   0] icache_data1_dout             ;
  wire                clk_icache_data1              ;
  wire                dcache_w0_tram_cs             ;
  wire                dcache_w0_tram_we             ;
  wire    [   7:   0] dcache_w0_tram_addr           ;
  wire    [  20:   0] dcache_w0_tram_din            ;
  wire    [  20:   0] dcache_w0_tram_dout           ;
  wire                clk_dcache_w0_tram            ;
  wire                dcache_w1_tram_cs             ;
  wire                dcache_w1_tram_we             ;
  wire    [   7:   0] dcache_w1_tram_addr           ;
  wire    [  20:   0] dcache_w1_tram_din            ;
  wire    [  20:   0] dcache_w1_tram_dout           ;
  wire                clk_dcache_w1_tram            ;
  wire                dcache_dram_b0_cs             ;
  wire                dcache_dram_b0_we             ;
  wire    [   3:   0] dcache_dram_b0_wem            ;
  wire    [   9:   0] dcache_dram_b0_addr           ;
  wire    [  31:   0] dcache_dram_b0_din            ;
  wire    [  31:   0] dcache_dram_b0_dout           ;
  wire                clk_dcache_dram_b0            ;
  wire                dcache_dram_b1_cs             ;
  wire                dcache_dram_b1_we             ;
  wire    [   3:   0] dcache_dram_b1_wem            ;
  wire    [   9:   0] dcache_dram_b1_addr           ;
  wire    [  31:   0] dcache_dram_b1_din            ;
  wire    [  31:   0] dcache_dram_b1_dout           ;
  wire                clk_dcache_dram_b1            ;
  wire                dcache_dram_b2_cs             ;
  wire                dcache_dram_b2_we             ;
  wire    [   3:   0] dcache_dram_b2_wem            ;
  wire    [   9:   0] dcache_dram_b2_addr           ;
  wire    [  31:   0] dcache_dram_b2_din            ;
  wire    [  31:   0] dcache_dram_b2_dout           ;
  wire                clk_dcache_dram_b2            ;
  wire                dcache_dram_b3_cs             ;
  wire                dcache_dram_b3_we             ;
  wire    [   3:   0] dcache_dram_b3_wem            ;
  wire    [   9:   0] dcache_dram_b3_addr           ;
  wire    [  31:   0] dcache_dram_b3_din            ;
  wire    [  31:   0] dcache_dram_b3_dout           ;
  wire                clk_dcache_dram_b3            ;
  wire                dcache_dram_b4_cs             ;
  wire                dcache_dram_b4_we             ;
  wire    [   3:   0] dcache_dram_b4_wem            ;
  wire    [   9:   0] dcache_dram_b4_addr           ;
  wire    [  31:   0] dcache_dram_b4_din            ;
  wire    [  31:   0] dcache_dram_b4_dout           ;
  wire                clk_dcache_dram_b4            ;
  wire                dcache_dram_b5_cs             ;
  wire                dcache_dram_b5_we             ;
  wire    [   3:   0] dcache_dram_b5_wem            ;
  wire    [   9:   0] dcache_dram_b5_addr           ;
  wire    [  31:   0] dcache_dram_b5_din            ;
  wire    [  31:   0] dcache_dram_b5_dout           ;
  wire                clk_dcache_dram_b5            ;
  wire                dcache_dram_b6_cs             ;
  wire                dcache_dram_b6_we             ;
  wire    [   3:   0] dcache_dram_b6_wem            ;
  wire    [   9:   0] dcache_dram_b6_addr           ;
  wire    [  31:   0] dcache_dram_b6_din            ;
  wire    [  31:   0] dcache_dram_b6_dout           ;
  wire                clk_dcache_dram_b6            ;
  wire                dcache_dram_b7_cs             ;
  wire                dcache_dram_b7_we             ;
  wire    [   3:   0] dcache_dram_b7_wem            ;
  wire    [   9:   0] dcache_dram_b7_addr           ;
  wire    [  31:   0] dcache_dram_b7_din            ;
  wire    [  31:   0] dcache_dram_b7_dout           ;
  wire                clk_dcache_dram_b7            ;
  wire                tlb_tram_way0_cs              ;
  wire                tlb_tram_way0_we              ;
  wire    [   6:   0] tlb_tram_way0_addr            ;
  wire    [  39:   0] tlb_tram_way0_din             ;
  wire    [  39:   0] tlb_tram_way0_dout            ;
  wire                clk_tlb_tram_way0             ;
  wire                tlb_tram_way1_cs              ;
  wire                tlb_tram_way1_we              ;
  wire    [   6:   0] tlb_tram_way1_addr            ;
  wire    [  39:   0] tlb_tram_way1_din             ;
  wire    [  39:   0] tlb_tram_way1_dout            ;
  wire                clk_tlb_tram_way1             ;
  wire                tlb_dram_way0_cs              ;
  wire                tlb_dram_way0_we              ;
  wire    [   6:   0] tlb_dram_way0_addr            ;
  wire    [  24:   0] tlb_dram_way0_din             ;
  wire    [  24:   0] tlb_dram_way0_dout            ;
  wire                clk_tlb_dram_way0             ;
  wire                tlb_dram_way1_cs              ;
  wire                tlb_dram_way1_we              ;
  wire    [   6:   0] tlb_dram_way1_addr            ;
  wire    [  24:   0] tlb_dram_way1_din             ;
  wire    [  24:   0] tlb_dram_way1_dout            ;
  wire                clk_tlb_dram_way1             ;
e603_core_wrapper u_core (
  .icache_tag0_cs                 (icache_tag0_cs                           ),
  .icache_tag0_we                 (icache_tag0_we                           ),
  .icache_tag0_addr               (icache_tag0_addr              [   7:   0]),
  .icache_tag0_din                (icache_tag0_din               [  21:   0]),
  .icache_tag0_dout               (icache_tag0_dout              [  21:   0]),
  .clk_icache_tag0                (clk_icache_tag0                          ),
  .icache_data0_cs                (icache_data0_cs                          ),
  .icache_data0_we                (icache_data0_we                          ),
  .icache_data0_addr              (icache_data0_addr             [  10:   0]),
  .icache_data0_din               (icache_data0_din              [  63:   0]),
  .icache_data0_dout              (icache_data0_dout             [  63:   0]),
  .clk_icache_data0               (clk_icache_data0                         ),
  .icache_tag1_cs                 (icache_tag1_cs                           ),
  .icache_tag1_we                 (icache_tag1_we                           ),
  .icache_tag1_addr               (icache_tag1_addr              [   7:   0]),
  .icache_tag1_din                (icache_tag1_din               [  21:   0]),
  .icache_tag1_dout               (icache_tag1_dout              [  21:   0]),
  .clk_icache_tag1                (clk_icache_tag1                          ),
  .icache_data1_cs                (icache_data1_cs                          ),
  .icache_data1_we                (icache_data1_we                          ),
  .icache_data1_addr              (icache_data1_addr             [  10:   0]),
  .icache_data1_din               (icache_data1_din              [  63:   0]),
  .icache_data1_dout              (icache_data1_dout             [  63:   0]),
  .clk_icache_data1               (clk_icache_data1                         ),
  .dcache_w0_tram_cs              (dcache_w0_tram_cs                        ),
  .dcache_w0_tram_we              (dcache_w0_tram_we                        ),
  .dcache_w0_tram_addr            (dcache_w0_tram_addr           [   7:   0]),
  .dcache_w0_tram_din             (dcache_w0_tram_din            [  20:   0]),
  .dcache_w0_tram_dout            (dcache_w0_tram_dout           [  20:   0]),
  .clk_dcache_w0_tram             (clk_dcache_w0_tram                       ),
  .dcache_w1_tram_cs              (dcache_w1_tram_cs                        ),
  .dcache_w1_tram_we              (dcache_w1_tram_we                        ),
  .dcache_w1_tram_addr            (dcache_w1_tram_addr           [   7:   0]),
  .dcache_w1_tram_din             (dcache_w1_tram_din            [  20:   0]),
  .dcache_w1_tram_dout            (dcache_w1_tram_dout           [  20:   0]),
  .clk_dcache_w1_tram             (clk_dcache_w1_tram                       ),
  .dcache_dram_b0_cs              (dcache_dram_b0_cs                        ),
  .dcache_dram_b0_we              (dcache_dram_b0_we                        ),
  .dcache_dram_b0_wem             (dcache_dram_b0_wem            [   3:   0]),
  .dcache_dram_b0_addr            (dcache_dram_b0_addr           [   9:   0]),
  .dcache_dram_b0_din             (dcache_dram_b0_din            [  31:   0]),
  .dcache_dram_b0_dout            (dcache_dram_b0_dout           [  31:   0]),
  .clk_dcache_dram_b0             (clk_dcache_dram_b0                       ),
  .dcache_dram_b1_cs              (dcache_dram_b1_cs                        ),
  .dcache_dram_b1_we              (dcache_dram_b1_we                        ),
  .dcache_dram_b1_wem             (dcache_dram_b1_wem            [   3:   0]),
  .dcache_dram_b1_addr            (dcache_dram_b1_addr           [   9:   0]),
  .dcache_dram_b1_din             (dcache_dram_b1_din            [  31:   0]),
  .dcache_dram_b1_dout            (dcache_dram_b1_dout           [  31:   0]),
  .clk_dcache_dram_b1             (clk_dcache_dram_b1                       ),
  .dcache_dram_b2_cs              (dcache_dram_b2_cs                        ),
  .dcache_dram_b2_we              (dcache_dram_b2_we                        ),
  .dcache_dram_b2_wem             (dcache_dram_b2_wem            [   3:   0]),
  .dcache_dram_b2_addr            (dcache_dram_b2_addr           [   9:   0]),
  .dcache_dram_b2_din             (dcache_dram_b2_din            [  31:   0]),
  .dcache_dram_b2_dout            (dcache_dram_b2_dout           [  31:   0]),
  .clk_dcache_dram_b2             (clk_dcache_dram_b2                       ),
  .dcache_dram_b3_cs              (dcache_dram_b3_cs                        ),
  .dcache_dram_b3_we              (dcache_dram_b3_we                        ),
  .dcache_dram_b3_wem             (dcache_dram_b3_wem            [   3:   0]),
  .dcache_dram_b3_addr            (dcache_dram_b3_addr           [   9:   0]),
  .dcache_dram_b3_din             (dcache_dram_b3_din            [  31:   0]),
  .dcache_dram_b3_dout            (dcache_dram_b3_dout           [  31:   0]),
  .clk_dcache_dram_b3             (clk_dcache_dram_b3                       ),
  .dcache_dram_b4_cs              (dcache_dram_b4_cs                        ),
  .dcache_dram_b4_we              (dcache_dram_b4_we                        ),
  .dcache_dram_b4_wem             (dcache_dram_b4_wem            [   3:   0]),
  .dcache_dram_b4_addr            (dcache_dram_b4_addr           [   9:   0]),
  .dcache_dram_b4_din             (dcache_dram_b4_din            [  31:   0]),
  .dcache_dram_b4_dout            (dcache_dram_b4_dout           [  31:   0]),
  .clk_dcache_dram_b4             (clk_dcache_dram_b4                       ),
  .dcache_dram_b5_cs              (dcache_dram_b5_cs                        ),
  .dcache_dram_b5_we              (dcache_dram_b5_we                        ),
  .dcache_dram_b5_wem             (dcache_dram_b5_wem            [   3:   0]),
  .dcache_dram_b5_addr            (dcache_dram_b5_addr           [   9:   0]),
  .dcache_dram_b5_din             (dcache_dram_b5_din            [  31:   0]),
  .dcache_dram_b5_dout            (dcache_dram_b5_dout           [  31:   0]),
  .clk_dcache_dram_b5             (clk_dcache_dram_b5                       ),
  .dcache_dram_b6_cs              (dcache_dram_b6_cs                        ),
  .dcache_dram_b6_we              (dcache_dram_b6_we                        ),
  .dcache_dram_b6_wem             (dcache_dram_b6_wem            [   3:   0]),
  .dcache_dram_b6_addr            (dcache_dram_b6_addr           [   9:   0]),
  .dcache_dram_b6_din             (dcache_dram_b6_din            [  31:   0]),
  .dcache_dram_b6_dout            (dcache_dram_b6_dout           [  31:   0]),
  .clk_dcache_dram_b6             (clk_dcache_dram_b6                       ),
  .dcache_dram_b7_cs              (dcache_dram_b7_cs                        ),
  .dcache_dram_b7_we              (dcache_dram_b7_we                        ),
  .dcache_dram_b7_wem             (dcache_dram_b7_wem            [   3:   0]),
  .dcache_dram_b7_addr            (dcache_dram_b7_addr           [   9:   0]),
  .dcache_dram_b7_din             (dcache_dram_b7_din            [  31:   0]),
  .dcache_dram_b7_dout            (dcache_dram_b7_dout           [  31:   0]),
  .clk_dcache_dram_b7             (clk_dcache_dram_b7                       ),
  .tlb_tram_way0_cs               (tlb_tram_way0_cs                         ),
  .tlb_tram_way0_we               (tlb_tram_way0_we                         ),
  .tlb_tram_way0_addr             (tlb_tram_way0_addr            [   6:   0]),
  .tlb_tram_way0_din              (tlb_tram_way0_din             [  39:   0]),
  .tlb_tram_way0_dout             (tlb_tram_way0_dout            [  39:   0]),
  .clk_tlb_tram_way0              (clk_tlb_tram_way0                        ),
  .tlb_tram_way1_cs               (tlb_tram_way1_cs                         ),
  .tlb_tram_way1_we               (tlb_tram_way1_we                         ),
  .tlb_tram_way1_addr             (tlb_tram_way1_addr            [   6:   0]),
  .tlb_tram_way1_din              (tlb_tram_way1_din             [  39:   0]),
  .tlb_tram_way1_dout             (tlb_tram_way1_dout            [  39:   0]),
  .clk_tlb_tram_way1              (clk_tlb_tram_way1                        ),
  .tlb_dram_way0_cs               (tlb_dram_way0_cs                         ),
  .tlb_dram_way0_we               (tlb_dram_way0_we                         ),
  .tlb_dram_way0_addr             (tlb_dram_way0_addr            [   6:   0]),
  .tlb_dram_way0_din              (tlb_dram_way0_din             [  24:   0]),
  .tlb_dram_way0_dout             (tlb_dram_way0_dout            [  24:   0]),
  .clk_tlb_dram_way0              (clk_tlb_dram_way0                        ),
  .tlb_dram_way1_cs               (tlb_dram_way1_cs                         ),
  .tlb_dram_way1_we               (tlb_dram_way1_we                         ),
  .tlb_dram_way1_addr             (tlb_dram_way1_addr            [   6:   0]),
  .tlb_dram_way1_din              (tlb_dram_way1_din             [  24:   0]),
  .tlb_dram_way1_dout             (tlb_dram_way1_dout            [  24:   0]),
  .clk_tlb_dram_way1              (clk_tlb_dram_way1                        ),
  .mem_arready                    (mem_arready                              ),
  .mem_arvalid                    (mem_arvalid                              ),
  .mem_araddr                     (mem_araddr                    [  31:   0]),
  .mem_arlen                      (mem_arlen                     [   7:   0]),
  .mem_arsize                     (mem_arsize                    [   2:   0]),
  .mem_arburst                    (mem_arburst                   [   1:   0]),
  .mem_arlock                     (mem_arlock                               ),
  .mem_arcache                    (mem_arcache                   [   3:   0]),
  .mem_arprot                     (mem_arprot                    [   2:   0]),
  .mem_arid                       (mem_arid                      [   2:   0]),
  .mem_awready                    (mem_awready                              ),
  .mem_awvalid                    (mem_awvalid                              ),
  .mem_awaddr                     (mem_awaddr                    [  31:   0]),
  .mem_awlen                      (mem_awlen                     [   7:   0]),
  .mem_awsize                     (mem_awsize                    [   2:   0]),
  .mem_awburst                    (mem_awburst                   [   1:   0]),
  .mem_awlock                     (mem_awlock                               ),
  .mem_awcache                    (mem_awcache                   [   3:   0]),
  .mem_awprot                     (mem_awprot                    [   2:   0]),
  .mem_awid                       (mem_awid                      [   2:   0]),
  .mem_wready                     (mem_wready                               ),
  .mem_wvalid                     (mem_wvalid                               ),
  .mem_wdata                      (mem_wdata                     [  63:   0]),
  .mem_wstrb                      (mem_wstrb                     [   7:   0]),
  .mem_wlast                      (mem_wlast                                ),
  .mem_rready                     (mem_rready                               ),
  .mem_rvalid                     (mem_rvalid                               ),
  .mem_rdata                      (mem_rdata                     [  63:   0]),
  .mem_rresp                      (mem_rresp                     [   1:   0]),
  .mem_rlast                      (mem_rlast                                ),
  .mem_rid                        (mem_rid                       [   2:   0]),
  .mem_bready                     (mem_bready                               ),
  .mem_bvalid                     (mem_bvalid                               ),
  .mem_bresp                      (mem_bresp                     [   1:   0]),
  .mem_bid                        (mem_bid                       [   2:   0]),
  .mem_clk_en                     (mem_clk_en                               ),
  .tx_evt                         (tx_evt                                   ),
  .rx_evt                         (rx_evt                                   ),
  .hart_id                        ({54'b0,hart_id                       [   9:   0]}),
  .reset_vector                   ({24'b0,reset_vector                  [  39:   0]}),
  .core_wfi_mode                  (core_wfi_mode                            ),
  .core_sleep_value               (core_sleep_value                         ),
  .nice_mem_holdup                (nice_mem_holdup                          ),
  .nice_req_valid                 (nice_req_valid                           ),
  .nice_req_ready                 (nice_req_ready                           ),
  .nice_req_instr                 (nice_req_instr                [  31:   0]),
  .nice_req_rs1                   (nice_req_rs1                  [  63:   0]),
  .nice_req_rs2                   (nice_req_rs2                  [  63:   0]),
  .nice_req_mmode                 (nice_req_mmode                           ),
  .nice_req_smode                 (nice_req_smode                           ),
  .nice_rsp_1cyc_type             (nice_rsp_1cyc_type                       ),
  .nice_rsp_1cyc_dat              (nice_rsp_1cyc_dat             [  63:   0]),
  .nice_rsp_1cyc_err              (1'b0),
  .nice_rsp_multicyc_valid        (nice_rsp_multicyc_valid                  ),
  .nice_rsp_multicyc_ready        (nice_rsp_multicyc_ready                  ),
  .nice_rsp_multicyc_dat          (nice_rsp_multicyc_dat         [  63:   0]),
  .nice_rsp_multicyc_err          (nice_rsp_multicyc_err                    ),
  .nice_icb_cmd_valid             (nice_icb_cmd_valid                       ),
  .nice_icb_cmd_ready             (nice_icb_cmd_ready                       ),
  .nice_icb_cmd_addr              (nice_icb_cmd_addr             [  31:   0]),
  .nice_icb_cmd_read              (nice_icb_cmd_read                        ),
  .nice_icb_cmd_wdata             (nice_icb_cmd_wdata            [  63:   0]),
  .nice_icb_cmd_wmask             (nice_icb_cmd_wmask            [   7:   0]),
  .nice_icb_cmd_size              (nice_icb_cmd_size             [   1:   0]),
  .nice_icb_cmd_mmode             (nice_icb_cmd_mmode                       ),
  .nice_icb_cmd_smode             (nice_icb_cmd_smode                       ),
  .nice_icb_rsp_valid             (nice_icb_rsp_valid                       ),
  .nice_icb_rsp_ready             (nice_icb_rsp_ready                       ),
  .nice_icb_rsp_rdata             (nice_icb_rsp_rdata            [  63:   0]),
  .nice_icb_rsp_err               (nice_icb_rsp_err                         ),
  .dbg_toggle_a                   (dbg_toggle_a                             ),
  .dcache_disable_init            (dcache_disable_init                      ),
  .icache_disable_init            (icache_disable_init                      ),
  .mmu_tlb_disable_init           (mmu_tlb_disable_init                     ),
  .sysrstreq                      (sysrstreq                                ),
  .mtime_toggle_a                 (mtime_toggle_a                           ),
  .nmi                            (nmi                                      ),
  .irq_i                          (irq_i                         [  63:   0]),
  .trace_ivalid                   (i0_trace_ivalid                          ),
  .trace_iexception               (i0_trace_iexception                      ),
  .trace_interrupt                (i0_trace_interrupt                       ),
  .trace_cause                    (i0_trace_cause                [  63:   0]),
  .trace_tval                     (i0_trace_tval                 [  63:   0]),
  .trace_iaddr                    (i0_trace_iaddr                [  63:   0]),
  .trace_instr                    (i0_trace_instr                [  31:   0]),
  .trace_priv                     (i0_trace_priv                 [   1:   0]),
  .trace_bjp_taken                (i0_trace_bjp_taken                       ),
  .trace_dmode                    (i0_trace_dmode                           ),
  .trace_cmt_ena                  (i0_trace_cmt_ena                         ),
  .core_clk_aon                   (core_clk_aon                             ),
  .clkgate_bypass                 (clkgate_bypass                           ),
  .stop_on_reset                  (stop_on_reset                            ),
  .core_reset_n                   (core_reset_n                             ),
  .por_reset_n                    (por_reset_n                              ),
  .reset_bypass                   (reset_bypass                             ),
  .jtag_TCK                       (jtag_TCK                                 ),
  .jtag_TMS_in                    (jtag_TMS_in                              ),
  .jtag_TDI                       (jtag_TDI                                 ),
  .jtag_TDO                       (jtag_TDO                                 ),
  .jtag_DRV_TDO                   (jtag_DRV_TDO                             ),
  .jtag_TMS_out                   (jtag_TMS_out                             ),
  .jtag_DRV_TMS                   (jtag_DRV_TMS                             ),
  .jtag_BK_TMS                    (jtag_BK_TMS                              ),
  .jtag_dwen                      (jtag_dwen                                ),
  .jtag_dwbypass                  (jtag_dwbypass                            ),
  .i_dbg_stop                     (i_dbg_stop                               ),
  .override_dm_sleep              (override_dm_sleep                        ),
  .hart_halted                    (hart_halted                              ),
  .dbg_stoptime                   (dbg_stoptime                             )
    );
e603_rams_wrapper u_rams (
  .icache_tag0_cs                 (icache_tag0_cs                           ),
  .icache_tag0_we                 (icache_tag0_we                           ),
  .icache_tag0_addr               (icache_tag0_addr              [   7:   0]),
  .icache_tag0_din                (icache_tag0_din               [  21:   0]),
  .icache_tag0_dout               (icache_tag0_dout              [  21:   0]),
  .clk_icache_tag0                (clk_icache_tag0                          ),
  .icache_data0_cs                (icache_data0_cs                          ),
  .icache_data0_we                (icache_data0_we                          ),
  .icache_data0_addr              (icache_data0_addr             [  10:   0]),
  .icache_data0_din               (icache_data0_din              [  63:   0]),
  .icache_data0_dout              (icache_data0_dout             [  63:   0]),
  .clk_icache_data0               (clk_icache_data0                         ),
  .icache_tag1_cs                 (icache_tag1_cs                           ),
  .icache_tag1_we                 (icache_tag1_we                           ),
  .icache_tag1_addr               (icache_tag1_addr              [   7:   0]),
  .icache_tag1_din                (icache_tag1_din               [  21:   0]),
  .icache_tag1_dout               (icache_tag1_dout              [  21:   0]),
  .clk_icache_tag1                (clk_icache_tag1                          ),
  .icache_data1_cs                (icache_data1_cs                          ),
  .icache_data1_we                (icache_data1_we                          ),
  .icache_data1_addr              (icache_data1_addr             [  10:   0]),
  .icache_data1_din               (icache_data1_din              [  63:   0]),
  .icache_data1_dout              (icache_data1_dout             [  63:   0]),
  .clk_icache_data1               (clk_icache_data1                         ),
  .dcache_w0_tram_cs              (dcache_w0_tram_cs                        ),
  .dcache_w0_tram_we              (dcache_w0_tram_we                        ),
  .dcache_w0_tram_addr            (dcache_w0_tram_addr           [   7:   0]),
  .dcache_w0_tram_din             (dcache_w0_tram_din            [  20:   0]),
  .dcache_w0_tram_dout            (dcache_w0_tram_dout           [  20:   0]),
  .clk_dcache_w0_tram             (clk_dcache_w0_tram                       ),
  .dcache_w1_tram_cs              (dcache_w1_tram_cs                        ),
  .dcache_w1_tram_we              (dcache_w1_tram_we                        ),
  .dcache_w1_tram_addr            (dcache_w1_tram_addr           [   7:   0]),
  .dcache_w1_tram_din             (dcache_w1_tram_din            [  20:   0]),
  .dcache_w1_tram_dout            (dcache_w1_tram_dout           [  20:   0]),
  .clk_dcache_w1_tram             (clk_dcache_w1_tram                       ),
  .dcache_dram_b0_cs              (dcache_dram_b0_cs                        ),
  .dcache_dram_b0_we              (dcache_dram_b0_we                        ),
  .dcache_dram_b0_wem             (dcache_dram_b0_wem            [   3:   0]),
  .dcache_dram_b0_addr            (dcache_dram_b0_addr           [   9:   0]),
  .dcache_dram_b0_din             (dcache_dram_b0_din            [  31:   0]),
  .dcache_dram_b0_dout            (dcache_dram_b0_dout           [  31:   0]),
  .clk_dcache_dram_b0             (clk_dcache_dram_b0                       ),
  .dcache_dram_b1_cs              (dcache_dram_b1_cs                        ),
  .dcache_dram_b1_we              (dcache_dram_b1_we                        ),
  .dcache_dram_b1_wem             (dcache_dram_b1_wem            [   3:   0]),
  .dcache_dram_b1_addr            (dcache_dram_b1_addr           [   9:   0]),
  .dcache_dram_b1_din             (dcache_dram_b1_din            [  31:   0]),
  .dcache_dram_b1_dout            (dcache_dram_b1_dout           [  31:   0]),
  .clk_dcache_dram_b1             (clk_dcache_dram_b1                       ),
  .dcache_dram_b2_cs              (dcache_dram_b2_cs                        ),
  .dcache_dram_b2_we              (dcache_dram_b2_we                        ),
  .dcache_dram_b2_wem             (dcache_dram_b2_wem            [   3:   0]),
  .dcache_dram_b2_addr            (dcache_dram_b2_addr           [   9:   0]),
  .dcache_dram_b2_din             (dcache_dram_b2_din            [  31:   0]),
  .dcache_dram_b2_dout            (dcache_dram_b2_dout           [  31:   0]),
  .clk_dcache_dram_b2             (clk_dcache_dram_b2                       ),
  .dcache_dram_b3_cs              (dcache_dram_b3_cs                        ),
  .dcache_dram_b3_we              (dcache_dram_b3_we                        ),
  .dcache_dram_b3_wem             (dcache_dram_b3_wem            [   3:   0]),
  .dcache_dram_b3_addr            (dcache_dram_b3_addr           [   9:   0]),
  .dcache_dram_b3_din             (dcache_dram_b3_din            [  31:   0]),
  .dcache_dram_b3_dout            (dcache_dram_b3_dout           [  31:   0]),
  .clk_dcache_dram_b3             (clk_dcache_dram_b3                       ),
  .dcache_dram_b4_cs              (dcache_dram_b4_cs                        ),
  .dcache_dram_b4_we              (dcache_dram_b4_we                        ),
  .dcache_dram_b4_wem             (dcache_dram_b4_wem            [   3:   0]),
  .dcache_dram_b4_addr            (dcache_dram_b4_addr           [   9:   0]),
  .dcache_dram_b4_din             (dcache_dram_b4_din            [  31:   0]),
  .dcache_dram_b4_dout            (dcache_dram_b4_dout           [  31:   0]),
  .clk_dcache_dram_b4             (clk_dcache_dram_b4                       ),
  .dcache_dram_b5_cs              (dcache_dram_b5_cs                        ),
  .dcache_dram_b5_we              (dcache_dram_b5_we                        ),
  .dcache_dram_b5_wem             (dcache_dram_b5_wem            [   3:   0]),
  .dcache_dram_b5_addr            (dcache_dram_b5_addr           [   9:   0]),
  .dcache_dram_b5_din             (dcache_dram_b5_din            [  31:   0]),
  .dcache_dram_b5_dout            (dcache_dram_b5_dout           [  31:   0]),
  .clk_dcache_dram_b5             (clk_dcache_dram_b5                       ),
  .dcache_dram_b6_cs              (dcache_dram_b6_cs                        ),
  .dcache_dram_b6_we              (dcache_dram_b6_we                        ),
  .dcache_dram_b6_wem             (dcache_dram_b6_wem            [   3:   0]),
  .dcache_dram_b6_addr            (dcache_dram_b6_addr           [   9:   0]),
  .dcache_dram_b6_din             (dcache_dram_b6_din            [  31:   0]),
  .dcache_dram_b6_dout            (dcache_dram_b6_dout           [  31:   0]),
  .clk_dcache_dram_b6             (clk_dcache_dram_b6                       ),
  .dcache_dram_b7_cs              (dcache_dram_b7_cs                        ),
  .dcache_dram_b7_we              (dcache_dram_b7_we                        ),
  .dcache_dram_b7_wem             (dcache_dram_b7_wem            [   3:   0]),
  .dcache_dram_b7_addr            (dcache_dram_b7_addr           [   9:   0]),
  .dcache_dram_b7_din             (dcache_dram_b7_din            [  31:   0]),
  .dcache_dram_b7_dout            (dcache_dram_b7_dout           [  31:   0]),
  .clk_dcache_dram_b7             (clk_dcache_dram_b7                       ),
  .tlb_tram_way0_cs               (tlb_tram_way0_cs                         ),
  .tlb_tram_way0_we               (tlb_tram_way0_we                         ),
  .tlb_tram_way0_addr             (tlb_tram_way0_addr            [   6:   0]),
  .tlb_tram_way0_din              (tlb_tram_way0_din             [  39:   0]),
  .tlb_tram_way0_dout             (tlb_tram_way0_dout            [  39:   0]),
  .clk_tlb_tram_way0              (clk_tlb_tram_way0                        ),
  .tlb_tram_way1_cs               (tlb_tram_way1_cs                         ),
  .tlb_tram_way1_we               (tlb_tram_way1_we                         ),
  .tlb_tram_way1_addr             (tlb_tram_way1_addr            [   6:   0]),
  .tlb_tram_way1_din              (tlb_tram_way1_din             [  39:   0]),
  .tlb_tram_way1_dout             (tlb_tram_way1_dout            [  39:   0]),
  .clk_tlb_tram_way1              (clk_tlb_tram_way1                        ),
  .tlb_dram_way0_cs               (tlb_dram_way0_cs                         ),
  .tlb_dram_way0_we               (tlb_dram_way0_we                         ),
  .tlb_dram_way0_addr             (tlb_dram_way0_addr            [   6:   0]),
  .tlb_dram_way0_din              (tlb_dram_way0_din             [  24:   0]),
  .tlb_dram_way0_dout             (tlb_dram_way0_dout            [  24:   0]),
  .clk_tlb_dram_way0              (clk_tlb_dram_way0                        ),
  .tlb_dram_way1_cs               (tlb_dram_way1_cs                         ),
  .tlb_dram_way1_we               (tlb_dram_way1_we                         ),
  .tlb_dram_way1_addr             (tlb_dram_way1_addr            [   6:   0]),
  .tlb_dram_way1_din              (tlb_dram_way1_din             [  24:   0]),
  .tlb_dram_way1_dout             (tlb_dram_way1_dout            [  24:   0]),
  .clk_tlb_dram_way1              (clk_tlb_dram_way1                        ),
  .clkgate_bypass                 (clkgate_bypass                           )
    );
endmodule
module e603_rams_wrapper (
  input              icache_tag0_cs                ,
  input              icache_tag0_we                ,
  input  [   7:   0] icache_tag0_addr              ,
  input  [  21:   0] icache_tag0_din               ,
  output [  21:   0] icache_tag0_dout              ,
  input              clk_icache_tag0               ,
  input              icache_data0_cs               ,
  input              icache_data0_we               ,
  input  [  10:   0] icache_data0_addr             ,
  input  [  63:   0] icache_data0_din              ,
  output [  63:   0] icache_data0_dout             ,
  input              clk_icache_data0              ,
  input              icache_tag1_cs                ,
  input              icache_tag1_we                ,
  input  [   7:   0] icache_tag1_addr              ,
  input  [  21:   0] icache_tag1_din               ,
  output [  21:   0] icache_tag1_dout              ,
  input              clk_icache_tag1               ,
  input              icache_data1_cs               ,
  input              icache_data1_we               ,
  input  [  10:   0] icache_data1_addr             ,
  input  [  63:   0] icache_data1_din              ,
  output [  63:   0] icache_data1_dout             ,
  input              clk_icache_data1              ,
  input              dcache_w0_tram_cs             ,
  input              dcache_w0_tram_we             ,
  input  [   7:   0] dcache_w0_tram_addr           ,
  input  [  20:   0] dcache_w0_tram_din            ,
  output [  20:   0] dcache_w0_tram_dout           ,
  input              clk_dcache_w0_tram            ,
  input              dcache_w1_tram_cs             ,
  input              dcache_w1_tram_we             ,
  input  [   7:   0] dcache_w1_tram_addr           ,
  input  [  20:   0] dcache_w1_tram_din            ,
  output [  20:   0] dcache_w1_tram_dout           ,
  input              clk_dcache_w1_tram            ,
  input              dcache_dram_b0_cs             ,
  input              dcache_dram_b0_we             ,
  input  [   3:   0] dcache_dram_b0_wem            ,
  input  [   9:   0] dcache_dram_b0_addr           ,
  input  [  31:   0] dcache_dram_b0_din            ,
  output [  31:   0] dcache_dram_b0_dout           ,
  input              clk_dcache_dram_b0            ,
  input              dcache_dram_b1_cs             ,
  input              dcache_dram_b1_we             ,
  input  [   3:   0] dcache_dram_b1_wem            ,
  input  [   9:   0] dcache_dram_b1_addr           ,
  input  [  31:   0] dcache_dram_b1_din            ,
  output [  31:   0] dcache_dram_b1_dout           ,
  input              clk_dcache_dram_b1            ,
  input              dcache_dram_b2_cs             ,
  input              dcache_dram_b2_we             ,
  input  [   3:   0] dcache_dram_b2_wem            ,
  input  [   9:   0] dcache_dram_b2_addr           ,
  input  [  31:   0] dcache_dram_b2_din            ,
  output [  31:   0] dcache_dram_b2_dout           ,
  input              clk_dcache_dram_b2            ,
  input              dcache_dram_b3_cs             ,
  input              dcache_dram_b3_we             ,
  input  [   3:   0] dcache_dram_b3_wem            ,
  input  [   9:   0] dcache_dram_b3_addr           ,
  input  [  31:   0] dcache_dram_b3_din            ,
  output [  31:   0] dcache_dram_b3_dout           ,
  input              clk_dcache_dram_b3            ,
  input              dcache_dram_b4_cs             ,
  input              dcache_dram_b4_we             ,
  input  [   3:   0] dcache_dram_b4_wem            ,
  input  [   9:   0] dcache_dram_b4_addr           ,
  input  [  31:   0] dcache_dram_b4_din            ,
  output [  31:   0] dcache_dram_b4_dout           ,
  input              clk_dcache_dram_b4            ,
  input              dcache_dram_b5_cs             ,
  input              dcache_dram_b5_we             ,
  input  [   3:   0] dcache_dram_b5_wem            ,
  input  [   9:   0] dcache_dram_b5_addr           ,
  input  [  31:   0] dcache_dram_b5_din            ,
  output [  31:   0] dcache_dram_b5_dout           ,
  input              clk_dcache_dram_b5            ,
  input              dcache_dram_b6_cs             ,
  input              dcache_dram_b6_we             ,
  input  [   3:   0] dcache_dram_b6_wem            ,
  input  [   9:   0] dcache_dram_b6_addr           ,
  input  [  31:   0] dcache_dram_b6_din            ,
  output [  31:   0] dcache_dram_b6_dout           ,
  input              clk_dcache_dram_b6            ,
  input              dcache_dram_b7_cs             ,
  input              dcache_dram_b7_we             ,
  input  [   3:   0] dcache_dram_b7_wem            ,
  input  [   9:   0] dcache_dram_b7_addr           ,
  input  [  31:   0] dcache_dram_b7_din            ,
  output [  31:   0] dcache_dram_b7_dout           ,
  input              clk_dcache_dram_b7            ,
  input              tlb_tram_way0_cs              ,
  input              tlb_tram_way0_we              ,
  input  [   6:   0] tlb_tram_way0_addr            ,
  input  [  39:   0] tlb_tram_way0_din             ,
  output [  39:   0] tlb_tram_way0_dout            ,
  input              clk_tlb_tram_way0             ,
  input              tlb_tram_way1_cs              ,
  input              tlb_tram_way1_we              ,
  input  [   6:   0] tlb_tram_way1_addr            ,
  input  [  39:   0] tlb_tram_way1_din             ,
  output [  39:   0] tlb_tram_way1_dout            ,
  input              clk_tlb_tram_way1             ,
  input              tlb_dram_way0_cs              ,
  input              tlb_dram_way0_we              ,
  input  [   6:   0] tlb_dram_way0_addr            ,
  input  [  24:   0] tlb_dram_way0_din             ,
  output [  24:   0] tlb_dram_way0_dout            ,
  input              clk_tlb_dram_way0             ,
  input              tlb_dram_way1_cs              ,
  input              tlb_dram_way1_we              ,
  input  [   6:   0] tlb_dram_way1_addr            ,
  input  [  24:   0] tlb_dram_way1_din             ,
  output [  24:   0] tlb_dram_way1_dout            ,
  input              clk_tlb_dram_way1             ,
  input              clkgate_bypass                
 );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(256),
    .DW(22),
    .MW(1),
    .AW(8) 
  )u_icache_tag0_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (icache_tag0_cs   ),
    .we   (icache_tag0_we   ),
    .wem  (icache_tag0_we    ),
    .addr (icache_tag0_addr ),
    .din  (icache_tag0_din  ),
    .dout (icache_tag0_dout ),
    .rst_n(1'b1),
    .clk  (clk_icache_tag0  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(2048),
    .DW(64),
    .MW(1),
    .AW(11) 
  )u_icache_data0_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (icache_data0_cs   ),
    .we   (icache_data0_we   ),
    .wem  (icache_data0_we    ),
    .addr (icache_data0_addr ),
    .din  (icache_data0_din  ),
    .dout (icache_data0_dout ),
    .rst_n(1'b1),
    .clk  (clk_icache_data0  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(256),
    .DW(22),
    .MW(1),
    .AW(8) 
  )u_icache_tag1_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (icache_tag1_cs   ),
    .we   (icache_tag1_we   ),
    .wem  (icache_tag1_we    ),
    .addr (icache_tag1_addr ),
    .din  (icache_tag1_din  ),
    .dout (icache_tag1_dout ),
    .rst_n(1'b1),
    .clk  (clk_icache_tag1  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(2048),
    .DW(64),
    .MW(1),
    .AW(11) 
  )u_icache_data1_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (icache_data1_cs   ),
    .we   (icache_data1_we   ),
    .wem  (icache_data1_we    ),
    .addr (icache_data1_addr ),
    .din  (icache_data1_din  ),
    .dout (icache_data1_dout ),
    .rst_n(1'b1),
    .clk  (clk_icache_data1  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(256),
    .DW(21),
    .MW(1),
    .AW(8) 
  )u_dcache_w0_tram_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_w0_tram_cs   ),
    .we   (dcache_w0_tram_we   ),
    .wem  (dcache_w0_tram_we    ),
    .addr (dcache_w0_tram_addr ),
    .din  (dcache_w0_tram_din  ),
    .dout (dcache_w0_tram_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_w0_tram  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(256),
    .DW(21),
    .MW(1),
    .AW(8) 
  )u_dcache_w1_tram_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_w1_tram_cs   ),
    .we   (dcache_w1_tram_we   ),
    .wem  (dcache_w1_tram_we    ),
    .addr (dcache_w1_tram_addr ),
    .din  (dcache_w1_tram_din  ),
    .dout (dcache_w1_tram_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_w1_tram  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(1024),
    .DW(32),
    .MW(4),
    .AW(10) 
  )u_dcache_dram_b0_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_dram_b0_cs   ),
    .we   (dcache_dram_b0_we   ),
    .wem  (dcache_dram_b0_wem   ),
    .addr (dcache_dram_b0_addr ),
    .din  (dcache_dram_b0_din  ),
    .dout (dcache_dram_b0_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_dram_b0  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(1024),
    .DW(32),
    .MW(4),
    .AW(10) 
  )u_dcache_dram_b1_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_dram_b1_cs   ),
    .we   (dcache_dram_b1_we   ),
    .wem  (dcache_dram_b1_wem   ),
    .addr (dcache_dram_b1_addr ),
    .din  (dcache_dram_b1_din  ),
    .dout (dcache_dram_b1_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_dram_b1  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(1024),
    .DW(32),
    .MW(4),
    .AW(10) 
  )u_dcache_dram_b2_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_dram_b2_cs   ),
    .we   (dcache_dram_b2_we   ),
    .wem  (dcache_dram_b2_wem   ),
    .addr (dcache_dram_b2_addr ),
    .din  (dcache_dram_b2_din  ),
    .dout (dcache_dram_b2_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_dram_b2  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(1024),
    .DW(32),
    .MW(4),
    .AW(10) 
  )u_dcache_dram_b3_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_dram_b3_cs   ),
    .we   (dcache_dram_b3_we   ),
    .wem  (dcache_dram_b3_wem   ),
    .addr (dcache_dram_b3_addr ),
    .din  (dcache_dram_b3_din  ),
    .dout (dcache_dram_b3_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_dram_b3  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(1024),
    .DW(32),
    .MW(4),
    .AW(10) 
  )u_dcache_dram_b4_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_dram_b4_cs   ),
    .we   (dcache_dram_b4_we   ),
    .wem  (dcache_dram_b4_wem   ),
    .addr (dcache_dram_b4_addr ),
    .din  (dcache_dram_b4_din  ),
    .dout (dcache_dram_b4_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_dram_b4  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(1024),
    .DW(32),
    .MW(4),
    .AW(10) 
  )u_dcache_dram_b5_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_dram_b5_cs   ),
    .we   (dcache_dram_b5_we   ),
    .wem  (dcache_dram_b5_wem   ),
    .addr (dcache_dram_b5_addr ),
    .din  (dcache_dram_b5_din  ),
    .dout (dcache_dram_b5_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_dram_b5  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(1024),
    .DW(32),
    .MW(4),
    .AW(10) 
  )u_dcache_dram_b6_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_dram_b6_cs   ),
    .we   (dcache_dram_b6_we   ),
    .wem  (dcache_dram_b6_wem   ),
    .addr (dcache_dram_b6_addr ),
    .din  (dcache_dram_b6_din  ),
    .dout (dcache_dram_b6_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_dram_b6  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(1024),
    .DW(32),
    .MW(4),
    .AW(10) 
  )u_dcache_dram_b7_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (dcache_dram_b7_cs   ),
    .we   (dcache_dram_b7_we   ),
    .wem  (dcache_dram_b7_wem   ),
    .addr (dcache_dram_b7_addr ),
    .din  (dcache_dram_b7_din  ),
    .dout (dcache_dram_b7_dout ),
    .rst_n(1'b1),
    .clk  (clk_dcache_dram_b7  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(128),
    .DW(40),
    .MW(1),
    .AW(7) 
  )u_tlb_tram_way0_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (tlb_tram_way0_cs   ),
    .we   (tlb_tram_way0_we   ),
    .wem  (tlb_tram_way0_we    ),
    .addr (tlb_tram_way0_addr ),
    .din  (tlb_tram_way0_din  ),
    .dout (tlb_tram_way0_dout ),
    .rst_n(1'b1),
    .clk  (clk_tlb_tram_way0  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(128),
    .DW(40),
    .MW(1),
    .AW(7) 
  )u_tlb_tram_way1_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (tlb_tram_way1_cs   ),
    .we   (tlb_tram_way1_we   ),
    .wem  (tlb_tram_way1_we    ),
    .addr (tlb_tram_way1_addr ),
    .din  (tlb_tram_way1_din  ),
    .dout (tlb_tram_way1_dout ),
    .rst_n(1'b1),
    .clk  (clk_tlb_tram_way1  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(128),
    .DW(25),
    .MW(1),
    .AW(7) 
  )u_tlb_dram_way0_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (tlb_dram_way0_cs   ),
    .we   (tlb_dram_way0_we   ),
    .wem  (tlb_dram_way0_we    ),
    .addr (tlb_dram_way0_addr ),
    .din  (tlb_dram_way0_din  ),
    .dout (tlb_dram_way0_dout ),
    .rst_n(1'b1),
    .clk  (clk_tlb_dram_way0  )
    );
  e603_gnrl_ram 
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(128),
    .DW(25),
    .MW(1),
    .AW(7) 
  )u_tlb_dram_way1_ram (
    .sd   (1'b0   ),
    .ds   (1'b0   ),
    .ls   (1'b0   ),
    .clkgate_bypass (clkgate_bypass),
    .cs   (tlb_dram_way1_cs   ),
    .we   (tlb_dram_way1_we   ),
    .wem  (tlb_dram_way1_we    ),
    .addr (tlb_dram_way1_addr ),
    .din  (tlb_dram_way1_din  ),
    .dout (tlb_dram_way1_dout ),
    .rst_n(1'b1),
    .clk  (clk_tlb_dram_way1  )
    );
endmodule
                                                               

