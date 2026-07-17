 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_subsys_axi_splt # (
  parameter AW = 32,
  parameter DW = 64,
  parameter ID_W =8,
  parameter MW = 4,
  parameter FIFO_OUTS_NUM = 8,
  parameter FIFO_CUT_READY = 0,
  parameter SPLT_NUM = 2,
  parameter SPLT_PTR_1HOT = 1,
  parameter SPLT_PTR_W = 2,
  parameter USR_W = 1 
) (
  input [SPLT_NUM-1:0]             i_axi_ar_indic,
  input [SPLT_NUM-1:0]             i_axi_aw_indic,
  output                           i_axi_arready,
  input                            i_axi_arvalid,
  input [ID_W-1:0]                 i_axi_arid,
  input [AW-1:0]                   i_axi_araddr,
  input [7:0]                      i_axi_arlen,
  input [2:0]                      i_axi_arsize,
  input [1:0]                      i_axi_arburst,
  input [1:0]                      i_axi_arlock,
  input [3:0]                      i_axi_arcache,
  input [2:0]                      i_axi_arprot,
  input [3:0]                      i_axi_arqos,
  input [3:0]                      i_axi_arregion,
  input [USR_W-1:0]                i_axi_aruser,
  output                           i_axi_awready,
  input                            i_axi_awvalid,
  input [ID_W-1:0]                 i_axi_awid,
  input [AW-1:0]                   i_axi_awaddr,
  input [7:0]                      i_axi_awlen,
  input [2:0]                      i_axi_awsize,
  input [1:0]                      i_axi_awburst,
  input [1:0]                      i_axi_awlock,
  input [3:0]                      i_axi_awcache,
  input [2:0]                      i_axi_awprot,
  input [3:0]                      i_axi_awqos,
  input [3:0]                      i_axi_awregion,
  input [USR_W-1:0]                i_axi_awuser, 
  output                           i_axi_wready,
  input                            i_axi_wvalid,
  input [ID_W-1:0]                 i_axi_wid,
  input [DW-1:0]                   i_axi_wdata,
  input [MW-1:0]                   i_axi_wstrb,
  input                            i_axi_wlast,
  input                            i_axi_rready,
  output                           i_axi_rvalid,
  output [ID_W-1:0]                i_axi_rid,
  output [DW-1:0]                  i_axi_rdata,
  output [1:0]                     i_axi_rresp,
  output                           i_axi_rlast,
  input                            i_axi_bready,
  output                           i_axi_bvalid,
  output [ID_W-1:0]                i_axi_bid,
  output [1:0]                     i_axi_bresp,
  input   [SPLT_NUM*1-1:0]         o_axi_arready,
  output  [SPLT_NUM*1-1:0]         o_axi_arvalid,
  output  [SPLT_NUM*ID_W-1:0]      o_axi_arid,
  output  [SPLT_NUM*AW-1:0]        o_axi_araddr,
  output  [SPLT_NUM*8-1:0]         o_axi_arlen,
  output  [SPLT_NUM*3-1:0]         o_axi_arsize,
  output  [SPLT_NUM*2-1:0]         o_axi_arburst,
  output  [SPLT_NUM*2-1:0]         o_axi_arlock,
  output  [SPLT_NUM*4-1:0]         o_axi_arcache,
  output  [SPLT_NUM*3-1:0]         o_axi_arprot,
  output  [SPLT_NUM*4-1:0]         o_axi_arqos,
  output  [SPLT_NUM*4-1:0]         o_axi_arregion,
  output  [SPLT_NUM*USR_W-1:0]     o_axi_aruser,
  input   [SPLT_NUM*1-1:0]         o_axi_awready,
  output  [SPLT_NUM*1-1:0]         o_axi_awvalid,
  output  [SPLT_NUM*ID_W-1:0]      o_axi_awid,
  output  [SPLT_NUM*AW-1:0]        o_axi_awaddr,
  output  [SPLT_NUM*8-1:0]         o_axi_awlen,
  output  [SPLT_NUM*3-1:0]         o_axi_awsize,
  output  [SPLT_NUM*2-1:0]         o_axi_awburst,
  output  [SPLT_NUM*2-1:0]         o_axi_awlock,
  output  [SPLT_NUM*4-1:0]         o_axi_awcache,
  output  [SPLT_NUM*3-1:0]         o_axi_awprot,
  output  [SPLT_NUM*4-1:0]         o_axi_awqos,
  output  [SPLT_NUM*4-1:0]         o_axi_awregion,
  output  [SPLT_NUM*USR_W-1:0]     o_axi_awuser, 
  input   [SPLT_NUM*1-1:0]         o_axi_wready,
  output  [SPLT_NUM*1-1:0]         o_axi_wvalid,
  output  [SPLT_NUM*ID_W-1:0]      o_axi_wid,
  output  [SPLT_NUM*DW-1:0]        o_axi_wdata,
  output  [SPLT_NUM*MW-1:0]        o_axi_wstrb,
  output  [SPLT_NUM*1-1:0]         o_axi_wlast,
  output  [SPLT_NUM*1-1:0]         o_axi_rready,
  input   [SPLT_NUM*1-1:0]         o_axi_rvalid,
  input   [SPLT_NUM*ID_W-1:0]      o_axi_rid,
  input   [SPLT_NUM*DW-1:0]        o_axi_rdata,
  input   [SPLT_NUM*2-1:0]         o_axi_rresp,
  input   [SPLT_NUM*1-1:0]         o_axi_rlast,
  output  [SPLT_NUM*1-1:0]         o_axi_bready,
  input   [SPLT_NUM*1-1:0]         o_axi_bvalid,
  input   [SPLT_NUM*ID_W-1:0]      o_axi_bid,
  input   [SPLT_NUM*2-1:0]         o_axi_bresp,
  input  clk,  
  input  rst_n
  );
  e603_gnrl_axi_splt_ar # (
    .AW              (AW),
    .DW              (DW),
    .ID_W            (ID_W),
    .MW              (MW),
    .FIFO_OUTS_NUM   (FIFO_OUTS_NUM),
    .FIFO_CUT_READY  (FIFO_CUT_READY),
    .SPLT_NUM        (SPLT_NUM),
    .SPLT_PTR_1HOT   (SPLT_PTR_1HOT),
    .SPLT_PTR_W      (SPLT_PTR_W),
    .USR_W           (USR_W)
) 
  u_gnrl_axi_splt_ar
  (
    .i_axi_ar_indic (i_axi_ar_indic),
    .i_axi_arready  (i_axi_arready),
    .i_axi_arvalid  (i_axi_arvalid),
    .i_axi_arid     (i_axi_arid),
    .i_axi_araddr   (i_axi_araddr),
    .i_axi_arlen    (i_axi_arlen),
    .i_axi_arsize   (i_axi_arsize),
    .i_axi_arburst  (i_axi_arburst),
    .i_axi_arlock   (i_axi_arlock),
    .i_axi_arcache  (i_axi_arcache),
    .i_axi_arprot   (i_axi_arprot),
    .i_axi_arqos    (i_axi_arqos),
    .i_axi_arregion (i_axi_arregion),
    .i_axi_aruser   (i_axi_aruser),
    .i_axi_rready   (i_axi_rready),
    .i_axi_rvalid   (i_axi_rvalid),
    .i_axi_rid      (i_axi_rid),
    .i_axi_rdata    (i_axi_rdata),
    .i_axi_rresp    (i_axi_rresp),
    .i_axi_rlast    (i_axi_rlast),
    .o_axi_arready  (o_axi_arready),
    .o_axi_arvalid  (o_axi_arvalid),
    .o_axi_arid     (o_axi_arid),
    .o_axi_araddr   (o_axi_araddr),
    .o_axi_arlen    (o_axi_arlen),
    .o_axi_arsize   (o_axi_arsize),
    .o_axi_arburst  (o_axi_arburst),
    .o_axi_arlock   (o_axi_arlock),
    .o_axi_arcache  (o_axi_arcache),
    .o_axi_arprot   (o_axi_arprot),
    .o_axi_arqos    (o_axi_arqos),
    .o_axi_arregion (o_axi_arregion),
    .o_axi_aruser   (o_axi_aruser),
    .o_axi_rready   (o_axi_rready),
    .o_axi_rvalid   (o_axi_rvalid),
    .o_axi_rid      (o_axi_rid),
    .o_axi_rdata    (o_axi_rdata),
    .o_axi_rresp    (o_axi_rresp),
    .o_axi_rlast    (o_axi_rlast),
    .clk            (clk),  
    .rst_n          (rst_n)
  );
  e603_gnrl_axi_splt_aw # (
    .AW              (AW),
    .DW              (DW),
    .ID_W            (ID_W),
    .MW              (MW),
    .FIFO_OUTS_NUM   (FIFO_OUTS_NUM),
    .FIFO_CUT_READY  (FIFO_CUT_READY),
    .SPLT_NUM        (SPLT_NUM),
    .SPLT_PTR_1HOT   (SPLT_PTR_1HOT),
    .SPLT_PTR_W      (SPLT_PTR_W),
    .USR_W           (USR_W)
) 
  u_gnrl_axi_splt_aw
  (
    .i_axi_aw_indic  (i_axi_aw_indic),
    .i_axi_awready   (i_axi_awready),
    .i_axi_awvalid   (i_axi_awvalid),
    .i_axi_awid      (i_axi_awid),
    .i_axi_awaddr    (i_axi_awaddr),
    .i_axi_awlen     (i_axi_awlen),
    .i_axi_awsize    (i_axi_awsize),
    .i_axi_awburst   (i_axi_awburst),
    .i_axi_awlock    (i_axi_awlock),
    .i_axi_awcache   (i_axi_awcache),
    .i_axi_awprot    (i_axi_awprot),
    .i_axi_awqos     (i_axi_awqos),
    .i_axi_awregion  (i_axi_awregion),
    .i_axi_awuser    (i_axi_awuser),  
    .i_axi_wready    (i_axi_wready),
    .i_axi_wvalid    (i_axi_wvalid),
    .i_axi_wid       (i_axi_wid),
    .i_axi_wdata     (i_axi_wdata),
    .i_axi_wstrb     (i_axi_wstrb),
    .i_axi_wlast     (i_axi_wlast),
    .i_axi_bready    (i_axi_bready),
    .i_axi_bvalid    (i_axi_bvalid),
    .i_axi_bid       (i_axi_bid),
    .i_axi_bresp     (i_axi_bresp),
    .o_axi_awready   (o_axi_awready),
    .o_axi_awvalid   (o_axi_awvalid),
    .o_axi_awid      (o_axi_awid),
    .o_axi_awaddr    (o_axi_awaddr),
    .o_axi_awlen     (o_axi_awlen),
    .o_axi_awsize    (o_axi_awsize),
    .o_axi_awburst   (o_axi_awburst),
    .o_axi_awlock    (o_axi_awlock),
    .o_axi_awcache   (o_axi_awcache),
    .o_axi_awprot    (o_axi_awprot),
    .o_axi_awqos     (o_axi_awqos),
    .o_axi_awregion  (o_axi_awregion),
    .o_axi_awuser    (o_axi_awuser), 
    .o_axi_wready    (o_axi_wready),
    .o_axi_wvalid    (o_axi_wvalid),
    .o_axi_wid       (o_axi_wid),
    .o_axi_wdata     (o_axi_wdata),
    .o_axi_wstrb     (o_axi_wstrb),
    .o_axi_wlast     (o_axi_wlast),
    .o_axi_bready    (o_axi_bready),
    .o_axi_bvalid    (o_axi_bvalid),
    .o_axi_bid       (o_axi_bid),
    .o_axi_bresp     (o_axi_bresp),
    .clk             (clk),  
    .rst_n           (rst_n)
  );
endmodule
module e603_gnrl_axi_splt_ar # (
  parameter AW = 32,
  parameter DW = 64,
  parameter ID_W = 8,
  parameter MW   = 4,
  parameter FIFO_OUTS_NUM = 8,
  parameter FIFO_CUT_READY = 0,
  parameter SPLT_NUM = 2,
  parameter SPLT_PTR_1HOT = 1,
  parameter SPLT_PTR_W = 4,
  parameter USR_W = 1 
) (
  input [SPLT_NUM-1:0]             i_axi_ar_indic,
  output                           i_axi_arready,
  input                            i_axi_arvalid,
  input [ID_W-1:0]                 i_axi_arid,
  input [AW-1:0]                   i_axi_araddr,
  input [7:0]                      i_axi_arlen,
  input [2:0]                      i_axi_arsize,
  input [1:0]                      i_axi_arburst,
  input [1:0]                      i_axi_arlock,
  input [3:0]                      i_axi_arcache,
  input [2:0]                      i_axi_arprot,
  input [3:0]                      i_axi_arqos,
  input [3:0]                      i_axi_arregion,
  input [USR_W-1:0]                i_axi_aruser,
  input                            i_axi_rready,
  output                           i_axi_rvalid,
  output [ID_W-1:0]                i_axi_rid,
  output [DW-1:0]                  i_axi_rdata,
  output [1:0]                     i_axi_rresp,
  output                           i_axi_rlast,
  input   [SPLT_NUM*1-1:0]         o_axi_arready,
  output  [SPLT_NUM*1-1:0]         o_axi_arvalid,
  output  [SPLT_NUM*ID_W-1:0]      o_axi_arid,
  output  [SPLT_NUM*AW-1:0]        o_axi_araddr,
  output  [SPLT_NUM*8-1:0]         o_axi_arlen,
  output  [SPLT_NUM*3-1:0]         o_axi_arsize,
  output  [SPLT_NUM*2-1:0]         o_axi_arburst,
  output  [SPLT_NUM*2-1:0]         o_axi_arlock,
  output  [SPLT_NUM*4-1:0]         o_axi_arcache,
  output  [SPLT_NUM*3-1:0]         o_axi_arprot,
  output  [SPLT_NUM*4-1:0]         o_axi_arqos,
  output  [SPLT_NUM*4-1:0]         o_axi_arregion,
  output  [SPLT_NUM*USR_W-1:0]     o_axi_aruser,
  output  [SPLT_NUM*1-1:0]         o_axi_rready,
  input   [SPLT_NUM*1-1:0]         o_axi_rvalid,
  input   [SPLT_NUM*ID_W-1:0]      o_axi_rid,
  input   [SPLT_NUM*DW-1:0]        o_axi_rdata,
  input   [SPLT_NUM*2-1:0]         o_axi_rresp,
  input   [SPLT_NUM*1-1:0]         o_axi_rlast,
  input  clk,  
  input  rst_n
  );
generate 
  if(SPLT_NUM == 1) begin:gen_splt_num_eq_1
    assign      i_axi_arready   =  o_axi_arready;
    assign      o_axi_arvalid   =  i_axi_arvalid; 
    assign      o_axi_arid      =  i_axi_arid;
    assign      o_axi_araddr    =  i_axi_araddr;
    assign      o_axi_arlen     =  i_axi_arlen;
    assign      o_axi_arsize    =  i_axi_arsize; 
    assign      o_axi_arburst   =  i_axi_arburst;  
    assign      o_axi_arlock    =  i_axi_arlock;      
    assign      o_axi_arcache   =  i_axi_arcache;        
    assign      o_axi_arprot    =  i_axi_arprot;          
    assign      o_axi_arqos     =  i_axi_arqos;        
    assign      o_axi_arregion  =  i_axi_arregion;         
    assign      o_axi_aruser    =  i_axi_aruser;        
    assign      o_axi_rready    =  i_axi_rready;       
    assign      i_axi_rvalid    =  o_axi_rvalid;            
    assign      i_axi_rid       =  o_axi_rid;         
    assign      i_axi_rdata     =  o_axi_rdata;           
    assign      i_axi_rresp     =  o_axi_rresp;             
    assign      i_axi_rlast     =  o_axi_rlast;         
  end
  else begin:gen_splt_num_gt_1
    genvar i;
    genvar ii;
    integer j;
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_arready  ;
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_arvalid  ;
    wire  [ID_W-1:0]         o_buf_axi_arid     [SPLT_NUM-1:0];
    wire  [AW-1:0]           o_buf_axi_araddr   [SPLT_NUM-1:0];
    wire  [7:0]              o_buf_axi_arlen    [SPLT_NUM-1:0];
    wire  [2:0]              o_buf_axi_arsize   [SPLT_NUM-1:0];
    wire  [1:0]              o_buf_axi_arburst  [SPLT_NUM-1:0];
    wire  [1:0]              o_buf_axi_arlock   [SPLT_NUM-1:0];
    wire  [3:0]              o_buf_axi_arcache  [SPLT_NUM-1:0];
    wire  [2:0]              o_buf_axi_arprot   [SPLT_NUM-1:0];
    wire  [3:0]              o_buf_axi_arqos    [SPLT_NUM-1:0];
    wire  [3:0]              o_buf_axi_arregion [SPLT_NUM-1:0];
    wire  [USR_W-1:0]        o_buf_axi_aruser   [SPLT_NUM-1:0];
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_rready   ;
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_rvalid   ;
    wire  [ID_W-1:0]         o_buf_axi_rid      [SPLT_NUM-1:0];
    wire  [DW-1:0]           o_buf_axi_rdata    [SPLT_NUM-1:0];
    wire  [1:0]              o_buf_axi_rresp    [SPLT_NUM-1:0];
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_rlast    ;
    for(i = 0; i < SPLT_NUM; i = i+1)
    begin:gen_icb_distract
      assign  o_buf_axi_arready [i]                     =  o_axi_arready      [(i+1)*1 -1 : (i)*1];
      assign  o_axi_arvalid     [(i+1)*1  -1 : i*1]     =  o_buf_axi_arvalid  [i]; 
      assign  o_axi_arid        [(i+1)*ID_W  -1 : i*ID_W]  =  o_buf_axi_arid     [i];
      assign  o_axi_araddr      [(i+1)*AW  -1 : i*AW]    =  o_buf_axi_araddr   [i];
      assign  o_axi_arlen       [(i+1)*8  -1 : i*8]     =  o_buf_axi_arlen    [i];
      assign  o_axi_arsize      [(i+1)*3  -1 : i*3]     =  o_buf_axi_arsize   [i]; 
      assign  o_axi_arburst     [(i+1)*2  -1 : i*2]     =  o_buf_axi_arburst  [i];  
      assign  o_axi_arlock      [(i+1)*2  -1 : i*2]     =  o_buf_axi_arlock   [i];       
      assign  o_axi_arcache     [(i+1)*4  -1 : i*4]     =  o_buf_axi_arcache  [i];        
      assign  o_axi_arprot      [(i+1)*3  -1 : i*3]     =  o_buf_axi_arprot   [i];           
      assign  o_axi_arqos       [(i+1)*4  -1 : i*4]     =  o_buf_axi_arqos    [i];        
      assign  o_axi_arregion    [(i+1)*4  -1 : i*4]     =  o_buf_axi_arregion [i];         
      assign  o_axi_aruser      [(i+1)*USR_W  -1 : i*USR_W] =  o_buf_axi_aruser   [i];        
      assign  o_axi_rready      [(i+1)*1 - 1 : i*1]     =  o_buf_axi_rready   [i];       
      assign  o_buf_axi_rvalid  [i]                     =  o_axi_rvalid       [(i+1)*1 -1 :(i)*1];            
      assign  o_buf_axi_rid     [i]                     =  o_axi_rid          [(i+1)*ID_W -1 :(i)*ID_W];         
      assign  o_buf_axi_rdata   [i]                     =  o_axi_rdata        [(i+1)*DW -1 :(i)*DW];           
      assign  o_buf_axi_rresp   [i]                     =  o_axi_rresp        [(i+1)*2 -1 :(i)*2];             
      assign  o_buf_axi_rlast   [i]                     =  o_axi_rlast        [(i+1)*1 -1 :(i)*1];         
    end
    wire sel_o_axi_arready;
    wire i_axi_arready_pre;
    wire i_axi_arvalid_pre;
    wire i_axi_rready_pre;
    wire i_axi_rvalid_pre;
    wire [SPLT_PTR_W-1:0] o_axi_arrsp_port_id;
    wire [SPLT_NUM-1:0] o_axi_arready_excpt_this [SPLT_NUM-1:0];
    wire arid_fifo_bypass;
    wire arid_fifo_wen;
    wire arid_fifo_ren;
    wire arid_fifo_i_valid;
    wire arid_fifo_o_valid;
    wire arid_fifo_i_ready;
    wire arid_fifo_o_ready;
    wire [SPLT_PTR_W-1:0] arid_fifo_rdat;
    wire [SPLT_PTR_W-1:0] arid_fifo_wdat;
    wire arid_fifo_full;       
    wire arid_fifo_empty;       
    reg  sel_o_axi_arready_reg;
    always @ (*) begin : sel_o_axi_ready_PROC
      sel_o_axi_arready_reg = 1'b0;
        for(j = 0; j < SPLT_NUM; j = j+1) begin
          sel_o_axi_arready_reg = sel_o_axi_arready_reg | (i_axi_ar_indic[j] & o_buf_axi_arready[j]);
        end
    end
    assign sel_o_axi_arready = sel_o_axi_arready_reg;
    assign i_axi_arready_pre = sel_o_axi_arready;
    assign i_axi_arvalid_pre = i_axi_arvalid     & (~arid_fifo_full);
    assign i_axi_arready     = i_axi_arready_pre & (~arid_fifo_full);
    reg [SPLT_PTR_W-1:0] i_splt_indic_ar_id;
    if(SPLT_PTR_1HOT == 1) begin:gen_ptr_1hot
       always @ (*) begin : i_splt_indic_id_PROC
         i_splt_indic_ar_id = i_axi_ar_indic;
       end
    end
    else begin:gen_ptr_not_1hot
       always @ (*) begin : i_splt_indic_id_PROC
         i_splt_indic_ar_id = {SPLT_PTR_W{1'b0}};
         for(j = 0; j < SPLT_NUM; j = j+1) begin
           i_splt_indic_ar_id = i_splt_indic_ar_id | ({SPLT_PTR_W{i_axi_ar_indic[j]}} & $unsigned(j[SPLT_PTR_W-1:0]));
         end
       end
    end
    assign arid_fifo_wen = i_axi_arvalid & i_axi_arready;
    assign arid_fifo_ren = i_axi_rvalid & i_axi_rready & i_axi_rlast;
    assign arid_fifo_bypass = 1'b0 ; 
    assign o_axi_arrsp_port_id = arid_fifo_rdat;
    assign i_axi_rvalid     = i_axi_rvalid_pre;
    assign i_axi_rready_pre = i_axi_rready;
    assign arid_fifo_i_valid = arid_fifo_wen & (~arid_fifo_bypass);
    assign arid_fifo_full    = (~arid_fifo_i_ready);
    assign arid_fifo_o_ready = arid_fifo_ren  & (~arid_fifo_bypass);
    assign arid_fifo_empty   = (~arid_fifo_o_valid);
    assign arid_fifo_wdat   = i_splt_indic_ar_id;
    if(FIFO_OUTS_NUM == 1) begin:gen_fifo_dp_1
      e603_gnrl_pipe_stage # (
        .CUT_READY (FIFO_CUT_READY),
        .DP  (1),
        .DW  (SPLT_PTR_W)
      ) u_gnrl_arid_fifo (
        .i_vld(arid_fifo_i_valid),
        .i_rdy(arid_fifo_i_ready),
        .i_dat(arid_fifo_wdat ),
        .o_vld(arid_fifo_o_valid),
        .o_rdy(arid_fifo_o_ready),  
        .o_dat(arid_fifo_rdat ),  
        .clk  (clk),
        .rst_n(rst_n)
      );
    end
    else begin: gen_fifo_dp_gt_1
      e603_gnrl_fifo # (
        .CUT_READY (FIFO_CUT_READY),
        .MSKO      (0),
        .DP  (FIFO_OUTS_NUM),
        .DW  (SPLT_PTR_W)
      ) u_gnrl_arid_fifo (
        .i_vld(arid_fifo_i_valid),
        .i_rdy(arid_fifo_i_ready),
        .i_dat(arid_fifo_wdat ),
        .o_vld(arid_fifo_o_valid),
        .o_rdy(arid_fifo_o_ready),  
        .o_dat(arid_fifo_rdat ),  
        .clk  (clk),
        .rst_n(rst_n)
      );
    end
    for(i = 0; i < SPLT_NUM; i = i+1)
    begin:gen_o_buf_axi_arvalid
      for(ii = 0; ii < SPLT_NUM; ii = ii+1)
      begin:gen_o_axi_arready_excpt_this
         if(i == ii) begin: gen_same_i
           assign o_axi_arready_excpt_this[i][ii] = 1'b1;
         end
         else begin: gen_no_same_i
           assign o_axi_arready_excpt_this[i][ii] = o_buf_axi_arready[ii];
         end
      end
      assign o_buf_axi_arvalid[i] = i_axi_ar_indic[i] & i_axi_arvalid_pre;         
        assign o_buf_axi_arid     [i] =  i_axi_arid     ;
        assign o_buf_axi_araddr   [i] =  i_axi_araddr   ;
        assign o_buf_axi_arlen    [i] =  i_axi_arlen    ;
        assign o_buf_axi_arsize   [i] =  i_axi_arsize   ;
        assign o_buf_axi_arburst  [i] =  i_axi_arburst  ;
        assign o_buf_axi_arlock   [i] =  i_axi_arlock   ;
        assign o_buf_axi_arcache  [i] =  i_axi_arcache  ;
        assign o_buf_axi_arprot   [i] =  i_axi_arprot   ;
        assign o_buf_axi_arqos    [i] =  i_axi_arqos    ;
        assign o_buf_axi_arregion [i] =  i_axi_arregion ;
        assign o_buf_axi_aruser   [i] =  i_axi_aruser   ;
    end
    if(SPLT_PTR_1HOT == 1) begin:gen_ptr_1hot_rsp
        for(i = 0; i < SPLT_NUM; i = i+1)
        begin:gen_o_buf_axi_rready
          assign o_buf_axi_rready[i] = (o_axi_arrsp_port_id[i] & i_axi_rready_pre);
        end
        assign i_axi_rvalid_pre = |({SPLT_PTR_W{o_buf_axi_rvalid}} & o_axi_arrsp_port_id);
        reg [ID_W-1:0] sel_i_axi_rid;
        reg [DW-1:0]   sel_i_axi_rdata;
        reg [1:0]      sel_i_axi_rresp; 
        reg            sel_i_axi_rlast; 
        always @ (*) begin : sel_axi_arrsp_PROC
          sel_i_axi_rid    = {ID_W {1'b0}};
          sel_i_axi_rdata  = {DW   {1'b0}};
          sel_i_axi_rresp  = {2    {1'b0}}; 
          sel_i_axi_rlast  = 1'b0; 
          for(j = 0; j < SPLT_NUM; j = j+1) begin
            sel_i_axi_rid    = sel_i_axi_rid   | ({ID_W { o_axi_arrsp_port_id[j]}} & o_buf_axi_rid   [j] );
            sel_i_axi_rdata  = sel_i_axi_rdata | ({DW   { o_axi_arrsp_port_id[j]}} & o_buf_axi_rdata [j] );
            sel_i_axi_rresp  = sel_i_axi_rresp | ({2    { o_axi_arrsp_port_id[j]}} & o_buf_axi_rresp [j] ); 
            sel_i_axi_rlast  = sel_i_axi_rlast | (        o_axi_arrsp_port_id[j]   & o_buf_axi_rlast [j] ); 
          end
        end
        assign i_axi_rid    = sel_i_axi_rid   ;
        assign i_axi_rdata  = sel_i_axi_rdata ;
        assign i_axi_rresp  = sel_i_axi_rresp ; 
        assign i_axi_rlast  = sel_i_axi_rlast ; 
    end
    else begin:gen_ptr_not_1hot_rsp
        for(i = 0; i < SPLT_NUM; i = i+1)
        begin:gen_o_buf_axi_rready_o_buf_axi_bready
          assign o_buf_axi_rready[i] = (o_axi_arrsp_port_id == i[SPLT_PTR_W-1:0]) & i_axi_rready_pre;
        end
        assign i_axi_rvalid_pre = o_buf_axi_rvalid[o_axi_arrsp_port_id]; 
        assign i_axi_rid    = o_buf_axi_rid   [o_axi_arrsp_port_id];
        assign i_axi_rdata  = o_buf_axi_rdata [o_axi_arrsp_port_id];
        assign i_axi_rresp  = o_buf_axi_rresp [o_axi_arrsp_port_id]; 
        assign i_axi_rlast  = o_buf_axi_rlast [o_axi_arrsp_port_id];
    end
  end
  endgenerate 
endmodule
module e603_gnrl_axi_splt_aw # (
  parameter AW = 32,
  parameter DW = 64,
  parameter ID_W = 8,
  parameter MW = 4,
  parameter FIFO_OUTS_NUM = 8,
  parameter FIFO_CUT_READY = 0,
  parameter SPLT_NUM = 2,
  parameter SPLT_PTR_1HOT = 1,
  parameter SPLT_PTR_W = 4,
  parameter USR_W = 1 
) (
  input [SPLT_NUM-1:0]             i_axi_aw_indic,
  output                           i_axi_awready,
  input                            i_axi_awvalid,
  input [ID_W-1:0]                 i_axi_awid,
  input [AW-1:0]                   i_axi_awaddr,
  input [7:0]                      i_axi_awlen,
  input [2:0]                      i_axi_awsize,
  input [1:0]                      i_axi_awburst,
  input [1:0]                      i_axi_awlock,
  input [3:0]                      i_axi_awcache,
  input [2:0]                      i_axi_awprot,
  input [3:0]                      i_axi_awqos,
  input [3:0]                      i_axi_awregion,
  input [USR_W-1:0]                i_axi_awuser, 
  output                           i_axi_wready,
  input                            i_axi_wvalid,
  input [ID_W-1:0]                 i_axi_wid,
  input [DW-1:0]                   i_axi_wdata,
  input [MW-1:0]                   i_axi_wstrb,
  input                            i_axi_wlast,
  input                            i_axi_bready,
  output                           i_axi_bvalid,
  output [ID_W-1:0]                i_axi_bid,
  output [1:0]                     i_axi_bresp,
  input   [SPLT_NUM*1-1:0]         o_axi_awready,
  output  [SPLT_NUM*1-1:0]         o_axi_awvalid,
  output  [SPLT_NUM*ID_W-1:0]      o_axi_awid,
  output  [SPLT_NUM*AW-1:0]        o_axi_awaddr,
  output  [SPLT_NUM*8-1:0]         o_axi_awlen,
  output  [SPLT_NUM*3-1:0]         o_axi_awsize,
  output  [SPLT_NUM*2-1:0]         o_axi_awburst,
  output  [SPLT_NUM*2-1:0]         o_axi_awlock,
  output  [SPLT_NUM*4-1:0]         o_axi_awcache,
  output  [SPLT_NUM*3-1:0]         o_axi_awprot,
  output  [SPLT_NUM*4-1:0]         o_axi_awqos,
  output  [SPLT_NUM*4-1:0]         o_axi_awregion,
  output  [SPLT_NUM*USR_W-1:0]     o_axi_awuser, 
  input   [SPLT_NUM*1-1:0]         o_axi_wready,
  output  [SPLT_NUM*1-1:0]         o_axi_wvalid,
  output  [SPLT_NUM*ID_W-1:0]      o_axi_wid,
  output  [SPLT_NUM*DW-1:0]        o_axi_wdata,
  output  [SPLT_NUM*MW-1:0]        o_axi_wstrb,
  output  [SPLT_NUM*1-1:0]         o_axi_wlast,
  output  [SPLT_NUM*1-1:0]         o_axi_bready,
  input   [SPLT_NUM*1-1:0]         o_axi_bvalid,
  input   [SPLT_NUM*ID_W-1:0]      o_axi_bid,
  input   [SPLT_NUM*2-1:0]         o_axi_bresp,
  input  clk,  
  input  rst_n
  );
generate 
  if(SPLT_NUM == 1) begin:gen_splt_num_eq_1
    assign      i_axi_awready   =  o_axi_awready;     
    assign      o_axi_awvalid   =  i_axi_awvalid;          
    assign      o_axi_awid      =  i_axi_awid;        
    assign      o_axi_awaddr    =  i_axi_awaddr;          
    assign      o_axi_awlen     =  i_axi_awlen;           
    assign      o_axi_awsize    =  i_axi_awsize;       
    assign      o_axi_awburst   =  i_axi_awburst;    
    assign      o_axi_awlock    =  i_axi_awlock;       
    assign      o_axi_awcache   =  i_axi_awcache;      
    assign      o_axi_awprot    =  i_axi_awprot;        
    assign      o_axi_awqos     =  i_axi_awqos;         
    assign      o_axi_awregion  =  i_axi_awregion;         
    assign      o_axi_awuser    =  i_axi_awuser;        
    assign      i_axi_wready    =  o_axi_wready;          
    assign      o_axi_wvalid    =  i_axi_wvalid;           
    assign      o_axi_wid       =  i_axi_wid;              
    assign      o_axi_wdata     =  i_axi_wdata;           
    assign      o_axi_wstrb     =  i_axi_wstrb;           
    assign      o_axi_wlast     =  i_axi_wlast;         
    assign      o_axi_bready    =  i_axi_bready;         
    assign      i_axi_bvalid    =  o_axi_bvalid;        
    assign      i_axi_bid       =  o_axi_bid;      
    assign      i_axi_bresp     =  o_axi_bresp;          
  end
  else begin:gen_splt_num_gt_1
    genvar i;
    genvar ii;
    integer j;
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_awready  ;
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_awvalid  ;
    wire  [ID_W-1:0]         o_buf_axi_awid     [SPLT_NUM-1:0];
    wire  [AW-1:0]           o_buf_axi_awaddr   [SPLT_NUM-1:0];
    wire  [7:0]              o_buf_axi_awlen    [SPLT_NUM-1:0];
    wire  [2:0]              o_buf_axi_awsize   [SPLT_NUM-1:0];
    wire  [1:0]              o_buf_axi_awburst  [SPLT_NUM-1:0];
    wire  [1:0]              o_buf_axi_awlock   [SPLT_NUM-1:0];
    wire  [3:0]              o_buf_axi_awcache  [SPLT_NUM-1:0];
    wire  [2:0]              o_buf_axi_awprot   [SPLT_NUM-1:0];
    wire  [3:0]              o_buf_axi_awqos    [SPLT_NUM-1:0];
    wire  [3:0]              o_buf_axi_awregion [SPLT_NUM-1:0];
    wire  [USR_W-1:0]        o_buf_axi_awuser   [SPLT_NUM-1:0]; 
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_wready   ;
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_wvalid   ;
    wire  [ID_W-1:0]         o_buf_axi_wid      [SPLT_NUM-1:0];
    wire  [DW-1:0]           o_buf_axi_wdata    [SPLT_NUM-1:0];
    wire  [MW-1:0]           o_buf_axi_wstrb    [SPLT_NUM-1:0];
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_wlast    ;
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_bready   ;
    wire  [SPLT_NUM*1-1:0]   o_buf_axi_bvalid   ;
    wire  [ID_W-1:0]         o_buf_axi_bid      [SPLT_NUM-1:0];
    wire  [1:0]              o_buf_axi_bresp    [SPLT_NUM-1:0];
    for(i = 0; i < SPLT_NUM; i = i+1)
    begin:gen_icb_distract
      assign  o_buf_axi_awready [i]                     =  o_axi_awready      [(i+1)*1 -1 : (i)*1];     
      assign  o_axi_awvalid     [(i+1)*1 - 1:i*1]       =  o_buf_axi_awvalid  [i];          
      assign  o_axi_awid        [(i+1)*ID_W - 1:i*ID_W]    =  o_buf_axi_awid     [i];        
      assign  o_axi_awaddr      [(i+1)*AW - 1:i*AW]      =  o_buf_axi_awaddr   [i];          
      assign  o_axi_awlen       [(i+1)*8 - 1:i*8]       =  o_buf_axi_awlen    [i];           
      assign  o_axi_awsize      [(i+1)*3 - 1:i*3]       =  o_buf_axi_awsize   [i];       
      assign  o_axi_awburst     [(i+1)*2 - 1:i*2]       =  o_buf_axi_awburst  [i];    
      assign  o_axi_awlock      [(i+1)*2 - 1:i*2]       =  o_buf_axi_awlock   [i];       
      assign  o_axi_awcache     [(i+1)*4 - 1:i*4]       =  o_buf_axi_awcache  [i];      
      assign  o_axi_awprot      [(i+1)*3 - 1:i*3]       =  o_buf_axi_awprot   [i];        
      assign  o_axi_awqos       [(i+1)*4 - 1:i*4]       =  o_buf_axi_awqos    [i];         
      assign  o_axi_awregion    [(i+1)*4 - 1:i*4]       =  o_buf_axi_awregion [i];         
      assign  o_axi_awuser      [(i+1)*USR_W - 1:i*USR_W]   =  o_buf_axi_awuser   [i];        
      assign  o_buf_axi_wready  [i]                     =  o_axi_wready       [(i+1)*1 -1 :(i)*1];          
      assign  o_axi_wvalid      [(i+1)*1 - 1 : i*1]     =  o_buf_axi_wvalid   [i];           
      assign  o_axi_wid         [(i+1)*ID_W - 1 : i*ID_W]  =  o_buf_axi_wid      [i];              
      assign  o_axi_wdata       [(i+1)*DW - 1 : i*DW]    =  o_buf_axi_wdata    [i];           
      assign  o_axi_wstrb       [(i+1)*MW - 1 : i*MW]    =  o_buf_axi_wstrb    [i];           
      assign  o_axi_wlast       [(i+1)*1 - 1 : i*1]     =  o_buf_axi_wlast    [i];         
      assign  o_axi_bready      [(i+1)*1 - 1 : i*1]     =  o_buf_axi_bready   [(i+1)*1 -1 :(i)*1];         
      assign  o_buf_axi_bvalid  [i]                     =  o_axi_bvalid       [(i+1)*1 -1 :(i)*1];        
      assign  o_buf_axi_bid     [i]                     =  o_axi_bid          [(i+1)*ID_W -1 :(i)*ID_W];      
      assign  o_buf_axi_bresp   [i]                     =  o_axi_bresp        [(i+1)*2 -1 :(i)*2];          
    end
    wire sel_o_axi_awready;
    wire i_axi_awready_pre;
    wire i_axi_awvalid_pre;
    wire i_axi_wready_pre;
    wire i_axi_wvalid_pre;
    wire i_axi_bready_pre;
    wire i_axi_bvalid_pre;
    reg [SPLT_PTR_W-1:0] i_splt_indic_aw_id;
    wire [SPLT_PTR_W-1:0] o_axi_awrsp_port_id;
    wire [SPLT_PTR_W-1:0] o_axi_wdata_port_id;
    wire [SPLT_NUM-1:0] i_axi_w_indic;
    wire [SPLT_NUM-1:0] o_axi_awready_excpt_this [SPLT_NUM-1:0];
    wire [SPLT_NUM-1:0] o_axi_wready_excpt_this [SPLT_NUM-1:0];
    wire awid_fifo_bypass;
    wire awid_fifo_wen;
    wire awid_fifo_ren;
    wire awid_fifo_i_valid;
    wire awid_fifo_o_valid;
    wire awid_fifo_i_ready;
    wire awid_fifo_o_ready;
    wire [SPLT_PTR_W-1:0] awid_fifo_rdat;
    wire [SPLT_PTR_W-1:0] awid_fifo_wdat;
    wire awid_fifo_full;       
    wire awid_fifo_empty;
    wire aw_w_same_cycle;
    wire aw_w_fifo_bypass;
    wire aw_w_id_fifo_wen;
    wire aw_w_id_fifo_ren;
    wire aw_w_id_fifo_i_valid;
    wire aw_w_id_fifo_o_valid;
    wire aw_w_id_fifo_i_ready;
    wire aw_w_id_fifo_o_ready;
    wire [SPLT_NUM-1:0] aw_w_id_fifo_rdat_to1hot;
    wire [SPLT_PTR_W-1:0] aw_w_id_fifo_rdat;
    wire [SPLT_PTR_W-1:0] aw_w_id_fifo_wdat;
    wire aw_w_id_fifo_full;       
    wire aw_w_id_fifo_empty;
    wire aw_w_block;
    wire sel_o_axi_wready;
    reg  sel_o_axi_awready_reg;
    reg  sel_o_axi_wready_reg;
    always @ (*) begin : sel_o_axi_ready_PROC
        sel_o_axi_awready_reg = 1'b0;
        sel_o_axi_wready_reg = 1'b0;
          for(j = 0; j < SPLT_NUM; j = j+1) begin
            sel_o_axi_awready_reg = sel_o_axi_awready_reg | (i_axi_aw_indic[j] & o_buf_axi_awready[j]);
            sel_o_axi_wready_reg = sel_o_axi_wready_reg | (i_axi_w_indic[j] & o_buf_axi_wready[j]);
          end
    end
    assign sel_o_axi_awready = sel_o_axi_awready_reg;
    assign sel_o_axi_wready = sel_o_axi_wready_reg;
    assign i_axi_awready_pre = sel_o_axi_awready;
    assign i_axi_wready_pre = sel_o_axi_wready;
    assign i_axi_awvalid_pre = i_axi_awvalid     & (~aw_w_id_fifo_full) & (~awid_fifo_full);
    assign i_axi_awready     = i_axi_awready_pre & (~aw_w_id_fifo_full) & (~awid_fifo_full);
    assign i_axi_wvalid_pre = i_axi_wvalid   & (~aw_w_block);
    assign i_axi_wready     = i_axi_wready_pre & (~aw_w_block);
    if(SPLT_PTR_1HOT == 1) begin:gen_ptr_1hot
       always @ (*) begin : i_splt_indic_id_PROC
         i_splt_indic_aw_id = i_axi_aw_indic;
       end
    end
    else begin:gen_ptr_not_1hot
       always @ (*) begin : i_splt_indic_id_PROC
         i_splt_indic_aw_id = {SPLT_PTR_W{1'b0}};
         for(j = 0; j < SPLT_NUM; j = j+1) begin
           i_splt_indic_aw_id = i_splt_indic_aw_id | ({SPLT_PTR_W{i_axi_aw_indic[j]}} & $unsigned(j[SPLT_PTR_W-1:0]));
         end
       end
    end
    assign awid_fifo_wen = i_axi_awvalid & i_axi_awready;
    assign awid_fifo_ren = i_axi_bvalid & i_axi_bready;
    assign awid_fifo_bypass = awid_fifo_empty & awid_fifo_wen & awid_fifo_ren;
    assign o_axi_awrsp_port_id = awid_fifo_rdat;
    assign i_axi_bvalid     = i_axi_bvalid_pre;
    assign i_axi_bready_pre = i_axi_bready;
    assign awid_fifo_i_valid = awid_fifo_wen & (~awid_fifo_bypass);
    assign awid_fifo_full    = (~awid_fifo_i_ready);
    assign awid_fifo_o_ready = awid_fifo_ren & (~awid_fifo_bypass);
    assign awid_fifo_empty   = (~awid_fifo_o_valid);
    assign awid_fifo_wdat   = i_splt_indic_aw_id;
    assign aw_w_same_cycle = aw_w_id_fifo_empty &  i_axi_awvalid & i_axi_wvalid;
    assign aw_w_fifo_bypass = aw_w_same_cycle & (i_axi_awlen == 8'h0);
    assign aw_w_id_fifo_wen = i_axi_awvalid & i_axi_awready & (~aw_w_fifo_bypass);
    assign aw_w_id_fifo_ren = i_axi_wvalid & i_axi_wready & i_axi_wlast & (~aw_w_fifo_bypass);
    assign o_axi_wdata_port_id = aw_w_same_cycle ? aw_w_id_fifo_wdat : aw_w_id_fifo_rdat;
    assign i_axi_w_indic = aw_w_same_cycle ? i_axi_aw_indic : aw_w_id_fifo_rdat_to1hot;
    assign aw_w_id_fifo_i_valid = aw_w_id_fifo_wen ;
    assign aw_w_id_fifo_full    = (~aw_w_id_fifo_i_ready);
    assign aw_w_id_fifo_o_ready = aw_w_id_fifo_ren;
    assign aw_w_id_fifo_empty   = (~aw_w_id_fifo_o_valid);
    assign aw_w_id_fifo_wdat   = i_splt_indic_aw_id;
    assign aw_w_block = aw_w_id_fifo_empty & (~aw_w_same_cycle);
      e603_gnrl_fifo # (
        .CUT_READY (FIFO_CUT_READY),
        .MSKO      (0),
        .DP  (FIFO_OUTS_NUM),
        .DW  (SPLT_PTR_W )
      ) u_gnrl_aw_w_id_fifo (
        .i_vld(aw_w_id_fifo_i_valid),
        .i_rdy(aw_w_id_fifo_i_ready),
        .i_dat(aw_w_id_fifo_wdat ),
        .o_vld(aw_w_id_fifo_o_valid),
        .o_rdy(aw_w_id_fifo_o_ready),  
        .o_dat(aw_w_id_fifo_rdat ),  
        .clk  (clk),
        .rst_n(rst_n)
      );
    if(FIFO_OUTS_NUM == 1) begin:gen_fifo_dp_1
      e603_gnrl_pipe_stage # (
        .CUT_READY (FIFO_CUT_READY),
        .DP  (1),
        .DW  (SPLT_PTR_W)
      ) u_gnrl_aw_b_id_fifo (
        .i_vld(awid_fifo_i_valid),
        .i_rdy(awid_fifo_i_ready),
        .i_dat(awid_fifo_wdat ),
        .o_vld(awid_fifo_o_valid),
        .o_rdy(awid_fifo_o_ready),  
        .o_dat(awid_fifo_rdat ),  
        .clk  (clk),
        .rst_n(rst_n)
      );
    end
    else begin: gen_fifo_dp_gt_1
      e603_gnrl_fifo # (
        .CUT_READY (FIFO_CUT_READY),
        .MSKO      (0),
        .DP  (FIFO_OUTS_NUM),
        .DW  (SPLT_PTR_W)
      ) u_gnrl_aw_w_id_fifo (
        .i_vld(awid_fifo_i_valid),
        .i_rdy(awid_fifo_i_ready),
        .i_dat(awid_fifo_wdat ),
        .o_vld(awid_fifo_o_valid),
        .o_rdy(awid_fifo_o_ready),  
        .o_dat(awid_fifo_rdat ),  
        .clk  (clk),
        .rst_n(rst_n)
      );
    end
    for(i = 0; i < SPLT_NUM; i = i+1)
    begin:gen_o_buf_axi_awvalid
      for(ii = 0; ii < SPLT_NUM; ii = ii+1)
      begin:gen_o_axi_awready_excpt_this
         if(i == ii) begin: gen_same_i
           assign o_axi_awready_excpt_this[i][ii] = 1'b1;
           assign o_axi_wready_excpt_this[i][ii] = 1'b1;
         end
         else begin: gen_no_same_i
           assign o_axi_awready_excpt_this[i][ii] = o_buf_axi_awready[ii];
           assign o_axi_wready_excpt_this[i][ii] = o_buf_axi_wready[ii];
         end
      end
      assign o_buf_axi_awvalid[i] = i_axi_aw_indic[i] & i_axi_awvalid_pre;         
      assign o_buf_axi_wvalid[i] = i_axi_w_indic[i] & i_axi_wvalid_pre;         
        assign o_buf_axi_awid     [i] =  i_axi_awid     ;
        assign o_buf_axi_awaddr   [i] =  i_axi_awaddr   ;
        assign o_buf_axi_awlen    [i] =  i_axi_awlen    ;
        assign o_buf_axi_awsize   [i] =  i_axi_awsize   ;
        assign o_buf_axi_awburst  [i] =  i_axi_awburst  ;
        assign o_buf_axi_awlock   [i] =  i_axi_awlock   ;
        assign o_buf_axi_awcache  [i] =  i_axi_awcache  ;
        assign o_buf_axi_awprot   [i] =  i_axi_awprot   ;
        assign o_buf_axi_awqos    [i] =  i_axi_awqos    ;
        assign o_buf_axi_awregion [i] =  i_axi_awregion ;
        assign o_buf_axi_awuser   [i] =  i_axi_awuser   ;
        assign o_buf_axi_wid      [i] =  i_axi_wid      ; 
        assign o_buf_axi_wdata    [i] =  i_axi_wdata    ;  
        assign o_buf_axi_wstrb    [i] =  i_axi_wstrb    ;  
        assign o_buf_axi_wlast    [i] =  i_axi_wlast    ;  
    end
    if(SPLT_PTR_1HOT == 1) begin:gen_ptr_1hot_rsp
        for(i = 0; i < SPLT_NUM; i = i+1)
        begin:gen_o_buf_axi_bready
          assign o_buf_axi_bready[i] = (o_axi_awrsp_port_id[i] & i_axi_bready_pre);
        end
        assign i_axi_bvalid_pre = |({SPLT_PTR_W{o_buf_axi_bvalid}} & o_axi_awrsp_port_id);
        reg [ID_W-1:0] sel_i_axi_bid;
        reg [1:0]      sel_i_axi_bresp;
        always @ (*) begin : sel_axi_arrsp_PROC
          sel_i_axi_bid    = {ID_W {1'b0}};
          sel_i_axi_bresp  = {2    {1'b0}};
          for(j = 0; j < SPLT_NUM; j = j+1) begin
            sel_i_axi_bid    = sel_i_axi_bid   | ({ID_W {o_axi_awrsp_port_id[j]}} & o_buf_axi_bid[j]    );
            sel_i_axi_bresp  = sel_i_axi_bresp | ({2    {o_axi_awrsp_port_id[j]}} & o_buf_axi_bresp[j]  );
          end
        end
        assign i_axi_bid    = sel_i_axi_bid   ;
        assign i_axi_bresp  = sel_i_axi_bresp ;
    end
    else begin:gen_ptr_not_1hot_rsp
        for(i = 0; i < SPLT_NUM; i = i+1)
        begin:gen_o_buf_axi_bready
          assign o_buf_axi_bready[i] = (o_axi_awrsp_port_id == i[SPLT_PTR_W-1:0]) & i_axi_bready_pre;
        end
        assign i_axi_bvalid_pre = o_buf_axi_bvalid[o_axi_awrsp_port_id]; 
        assign i_axi_bid    = o_buf_axi_bid   [o_axi_awrsp_port_id];
        assign i_axi_bresp  = o_buf_axi_bresp [o_axi_awrsp_port_id];
    end
    if(SPLT_PTR_1HOT == 0) begin: ptr_no1hot_gen
        for(i = 0; i < SPLT_NUM; i = i+1)
        begin:gen_w_fifo_rdat_1hot
              assign aw_w_id_fifo_rdat_to1hot[i] = (aw_w_id_fifo_rdat == i[SPLT_PTR_W-1:0]);
        end
    end
    else begin: ptr_1hot_gen
        assign aw_w_id_fifo_rdat_to1hot = aw_w_id_fifo_rdat;
    end
  end
  endgenerate 
endmodule
