 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_subsys_axi1to2 # (
  parameter AW = 32,
  parameter DW = 32,
  parameter ID_W = 4,
  parameter USR_W = 4,
  parameter MW = 4,
  parameter SPLT_FIFO_OUTS_NUM    = 1,
  parameter SPLT_FIFO_OUTS_CNT_W  = 1,
  parameter SPLT_FIFO_CUT_READY   = 1,
  parameter O0_BASE_ADDR       = 32'h0000_0000,       
  parameter O0_BASE_REGION_LSB = 12 
)(
  input                            o0_axi_enable,
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
  input                            o0_axi_arready,
  output                           o0_axi_arvalid,
  output [ID_W-1:0]                o0_axi_arid,
  output [AW-1:0]                  o0_axi_araddr,
  output [7:0]                     o0_axi_arlen,
  output [2:0]                     o0_axi_arsize,
  output [1:0]                     o0_axi_arburst,
  output [1:0]                     o0_axi_arlock,
  output [3:0]                     o0_axi_arcache,
  output [2:0]                     o0_axi_arprot,
  output [3:0]                     o0_axi_arqos,
  output [3:0]                     o0_axi_arregion,
  output [USR_W-1:0]               o0_axi_aruser,
  input                            o0_axi_awready,
  output                           o0_axi_awvalid,
  output [ID_W-1:0]                o0_axi_awid,
  output [AW-1:0]                  o0_axi_awaddr,
  output [7:0]                     o0_axi_awlen,
  output [2:0]                     o0_axi_awsize,
  output [1:0]                     o0_axi_awburst,
  output [1:0]                     o0_axi_awlock,
  output [3:0]                     o0_axi_awcache,
  output [2:0]                     o0_axi_awprot,
  output [3:0]                     o0_axi_awqos,
  output [3:0]                     o0_axi_awregion,
  output [USR_W-1:0]               o0_axi_awuser, 
  input                            o0_axi_wready,
  output                           o0_axi_wvalid,
  output [ID_W-1:0]                o0_axi_wid,
  output [DW-1:0]                  o0_axi_wdata,
  output [MW-1:0]                  o0_axi_wstrb,
  output                           o0_axi_wlast,
  output                           o0_axi_rready,
  input                            o0_axi_rvalid,
  input [ID_W-1:0]                 o0_axi_rid,
  input [DW-1:0]                   o0_axi_rdata,
  input [1:0]                      o0_axi_rresp,
  input                            o0_axi_rlast,
  output                           o0_axi_bready,
  input                            o0_axi_bvalid,
  input [ID_W-1:0]                 o0_axi_bid,
  input [1:0]                      o0_axi_bresp,
  input                            o1_axi_arready,
  output                           o1_axi_arvalid,
  output [ID_W-1:0]                o1_axi_arid,
  output [AW-1:0]                  o1_axi_araddr,
  output [7:0]                     o1_axi_arlen,
  output [2:0]                     o1_axi_arsize,
  output [1:0]                     o1_axi_arburst,
  output [1:0]                     o1_axi_arlock,
  output [3:0]                     o1_axi_arcache,
  output [2:0]                     o1_axi_arprot,
  output [3:0]                     o1_axi_arqos,
  output [3:0]                     o1_axi_arregion,
  output [USR_W-1:0]               o1_axi_aruser,
  input                            o1_axi_awready,
  output                           o1_axi_awvalid,
  output [ID_W-1:0]                o1_axi_awid,
  output [AW-1:0]                  o1_axi_awaddr,
  output [7:0]                     o1_axi_awlen,
  output [2:0]                     o1_axi_awsize,
  output [1:0]                     o1_axi_awburst,
  output [1:0]                     o1_axi_awlock,
  output [3:0]                     o1_axi_awcache,
  output [2:0]                     o1_axi_awprot,
  output [3:0]                     o1_axi_awqos,
  output [3:0]                     o1_axi_awregion,
  output [USR_W-1:0]               o1_axi_awuser, 
  input                            o1_axi_wready,
  output                           o1_axi_wvalid,
  output [ID_W-1:0]                o1_axi_wid,
  output [DW-1:0]                  o1_axi_wdata,
  output [MW-1:0]                  o1_axi_wstrb,
  output                           o1_axi_wlast,
  output                           o1_axi_rready,
  input                            o1_axi_rvalid,
  input [ID_W-1:0]                 o1_axi_rid,
  input [DW-1:0]                   o1_axi_rdata,
  input [1:0]                      o1_axi_rresp,
  input                            o1_axi_rlast,
  output                           o1_axi_bready,
  input                            o1_axi_bvalid,
  input [ID_W-1:0]                 o1_axi_bid,
  input [1:0]                      o1_axi_bresp,
  input  clk,
  input  rst_n
  );
  localparam BASE_REGION_MSB = (AW-1);
  localparam SPLT_I_NUM = 2;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_arready;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_arvalid;
  wire  [SPLT_I_NUM*ID_W-1:0]                 splt_bus_axi_arid;
  wire  [SPLT_I_NUM*AW-1:0]                   splt_bus_axi_araddr;
  wire  [SPLT_I_NUM*8-1:0]                    splt_bus_axi_arlen;
  wire  [SPLT_I_NUM*3-1:0]                    splt_bus_axi_arsize;
  wire  [SPLT_I_NUM*2-1:0]                    splt_bus_axi_arburst;
  wire  [SPLT_I_NUM*2-1:0]                    splt_bus_axi_arlock;
  wire  [SPLT_I_NUM*4-1:0]                    splt_bus_axi_arcache;
  wire  [SPLT_I_NUM*3-1:0]                    splt_bus_axi_arprot;
  wire  [SPLT_I_NUM*4-1:0]                    splt_bus_axi_arqos;
  wire  [SPLT_I_NUM*4-1:0]                    splt_bus_axi_arregion;
  wire  [SPLT_I_NUM*USR_W-1:0]                splt_bus_axi_aruser;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_awready;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_awvalid;
  wire  [SPLT_I_NUM*ID_W-1:0]                 splt_bus_axi_awid;
  wire  [SPLT_I_NUM*AW-1:0]                   splt_bus_axi_awaddr;
  wire  [SPLT_I_NUM*8-1:0]                    splt_bus_axi_awlen;
  wire  [SPLT_I_NUM*3-1:0]                    splt_bus_axi_awsize;
  wire  [SPLT_I_NUM*2-1:0]                    splt_bus_axi_awburst;
  wire  [SPLT_I_NUM*2-1:0]                    splt_bus_axi_awlock;
  wire  [SPLT_I_NUM*4-1:0]                    splt_bus_axi_awcache;
  wire  [SPLT_I_NUM*3-1:0]                    splt_bus_axi_awprot;
  wire  [SPLT_I_NUM*4-1:0]                    splt_bus_axi_awqos;
  wire  [SPLT_I_NUM*4-1:0]                    splt_bus_axi_awregion;
  wire  [SPLT_I_NUM*USR_W-1:0]                splt_bus_axi_awuser; 
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_wready;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_wvalid;
  wire  [SPLT_I_NUM*ID_W-1:0]                 splt_bus_axi_wid;
  wire  [SPLT_I_NUM*DW-1:0]                   splt_bus_axi_wdata;
  wire  [SPLT_I_NUM*MW-1:0]                   splt_bus_axi_wstrb;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_wlast;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_rready;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_rvalid;
  wire  [SPLT_I_NUM*ID_W-1:0]                 splt_bus_axi_rid;
  wire  [SPLT_I_NUM*DW-1:0]                   splt_bus_axi_rdata;
  wire  [SPLT_I_NUM*2-1:0]                    splt_bus_axi_rresp;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_rlast;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_bready;
  wire  [SPLT_I_NUM*1-1:0]                    splt_bus_axi_bvalid;
  wire  [SPLT_I_NUM*ID_W-1:0]                 splt_bus_axi_bid;
  wire  [SPLT_I_NUM*2-1:0]                    splt_bus_axi_bresp;
  assign  splt_bus_axi_arready ={  o0_axi_arready
                                  ,o1_axi_arready
                                };
  assign {             o0_axi_arvalid
                      ,o1_axi_arvalid
                      } = splt_bus_axi_arvalid;
  assign {             o0_axi_arid
                      ,o1_axi_arid
                      } = splt_bus_axi_arid;
  assign  {            o0_axi_araddr
                      ,o1_axi_araddr
                      } = splt_bus_axi_araddr;
  assign  {            o0_axi_arlen
                      ,o1_axi_arlen
                      } = splt_bus_axi_arlen;
  assign  {            o0_axi_arsize
                      ,o1_axi_arsize
                      } = splt_bus_axi_arsize;
  assign  {            o0_axi_arburst
                      ,o1_axi_arburst
                      } = splt_bus_axi_arburst;
  assign  {            o0_axi_arlock
                      ,o1_axi_arlock
                      } = splt_bus_axi_arlock;
  assign  {            o0_axi_arcache
                      ,o1_axi_arcache
                      } = splt_bus_axi_arcache;
  assign  {            o0_axi_arprot
                      ,o1_axi_arprot
                      } = splt_bus_axi_arprot;
  assign  {            o0_axi_arqos
                      ,o1_axi_arqos
                      } = splt_bus_axi_arqos;
  assign  {            o0_axi_arregion
                      ,o1_axi_arregion
                      } = splt_bus_axi_arregion;
  assign  {            o0_axi_aruser
                      ,o1_axi_aruser
                      } = splt_bus_axi_aruser;
  assign  splt_bus_axi_awready = { 
                       o0_axi_awready
                      ,o1_axi_awready
                      };
  assign  {            o0_axi_awvalid
                      ,o1_axi_awvalid
                      } = splt_bus_axi_awvalid;
  assign  {            o0_axi_awid
                      ,o1_axi_awid
                      } = splt_bus_axi_awid;
  assign  {            o0_axi_awaddr
                      ,o1_axi_awaddr
                      } = splt_bus_axi_awaddr;
  assign  {            o0_axi_awlen
                      ,o1_axi_awlen
                      } = splt_bus_axi_awlen;
  assign  {            o0_axi_awsize
                      ,o1_axi_awsize
                      } = splt_bus_axi_awsize;
  assign  {            o0_axi_awburst
                      ,o1_axi_awburst
                      } = splt_bus_axi_awburst;
  assign  {            o0_axi_awlock
                      ,o1_axi_awlock
                      } = splt_bus_axi_awlock;
  assign  {            o0_axi_awcache
                      ,o1_axi_awcache
                      } = splt_bus_axi_awcache;
  assign  {            o0_axi_awprot
                      ,o1_axi_awprot
                      } = splt_bus_axi_awprot;
  assign  {            o0_axi_awqos
                      ,o1_axi_awqos
                      } = splt_bus_axi_awqos;
  assign  {            o0_axi_awregion
                      ,o1_axi_awregion
                      } = splt_bus_axi_awregion;
  assign  {            o0_axi_awuser
                      ,o1_axi_awuser
                      } = splt_bus_axi_awuser;
  assign splt_bus_axi_wready = { o0_axi_wready
                                ,o1_axi_wready
                               };
  assign  {             o0_axi_wvalid
                       ,o1_axi_wvalid
                       } = splt_bus_axi_wvalid;
  assign  {            o0_axi_wid
                      ,o1_axi_wid
                       } = splt_bus_axi_wid;
  assign  {            o0_axi_wdata
                      ,o1_axi_wdata
                       } = splt_bus_axi_wdata;
  assign  {            o0_axi_wstrb
                       ,o1_axi_wstrb
                       } = splt_bus_axi_wstrb;
  assign  {            o0_axi_wlast
                      ,o1_axi_wlast
                       } = splt_bus_axi_wlast;
  assign  {            o0_axi_rready
                      ,o1_axi_rready
                      } = splt_bus_axi_rready;
  assign splt_bus_axi_rvalid = {o0_axi_rvalid
                               ,o1_axi_rvalid
                               };
  assign splt_bus_axi_rid = {o0_axi_rid
                             ,o1_axi_rid
                             };
  assign splt_bus_axi_rdata = {o0_axi_rdata
                              ,o1_axi_rdata
                              };
  assign splt_bus_axi_rresp = {o0_axi_rresp
                              ,o1_axi_rresp
                              };
  assign splt_bus_axi_rlast = {o0_axi_rlast
                              ,o1_axi_rlast
                              };
  assign  {o0_axi_bready
          ,o1_axi_bready
                     } = splt_bus_axi_bready;
  assign  splt_bus_axi_bvalid = {o0_axi_bvalid
                                ,o1_axi_bvalid
                                };
  assign splt_bus_axi_bid = {o0_axi_bid
                            ,o1_axi_bid
                            };
  assign splt_bus_axi_bresp = {o0_axi_bresp
                              ,o1_axi_bresp
                              };
  wire axi_ar_o0 = o0_axi_enable & (i_axi_araddr     [BASE_REGION_MSB:O0_BASE_REGION_LSB] 
                     ==  O0_BASE_ADDR [BASE_REGION_MSB:O0_BASE_REGION_LSB] 
                    );
  wire axi_ar_o1 = ~axi_ar_o0;
  wire axi_aw_o0 = o0_axi_enable & (i_axi_awaddr     [BASE_REGION_MSB:O0_BASE_REGION_LSB] 
                     ==  O0_BASE_ADDR [BASE_REGION_MSB:O0_BASE_REGION_LSB] 
                    );
  wire axi_aw_o1 = ~axi_aw_o0;
  wire [SPLT_I_NUM-1:0] i_axi_ar_indic = {
                                          axi_ar_o0
                                         ,axi_ar_o1 } ;
  wire [SPLT_I_NUM-1:0] i_axi_aw_indic = {
                                          axi_aw_o0
                                         ,axi_aw_o1 } ;
  e603_subsys_axi_splt # (
  .FIFO_OUTS_NUM   (SPLT_FIFO_OUTS_NUM ),
  .FIFO_CUT_READY  (SPLT_FIFO_CUT_READY),
  .SPLT_NUM   (SPLT_I_NUM),
  .SPLT_PTR_W (SPLT_I_NUM),
  .SPLT_PTR_1HOT (1),
  .USR_W      (USR_W),
  .AW         (AW),
  .MW         (MW),
  .ID_W       (ID_W),
  .DW         (DW) 
  ) u_i_axi_splt(
   .i_axi_ar_indic   (i_axi_ar_indic),
   .i_axi_aw_indic   (i_axi_aw_indic),
   .i_axi_arready    (i_axi_arready),
   .i_axi_arvalid    (i_axi_arvalid),
   .i_axi_arid       (i_axi_arid),
   .i_axi_araddr     (i_axi_araddr),
   .i_axi_arlen      (i_axi_arlen),
   .i_axi_arsize     (i_axi_arsize),
   .i_axi_arburst    (i_axi_arburst),
   .i_axi_arlock     (i_axi_arlock),
   .i_axi_arcache    (i_axi_arcache),
   .i_axi_arprot     (i_axi_arprot),
   .i_axi_arqos      (i_axi_arqos),
   .i_axi_arregion   (i_axi_arregion),
   .i_axi_aruser     (i_axi_aruser),
   .i_axi_awready    (i_axi_awready),
   .i_axi_awvalid    (i_axi_awvalid),
   .i_axi_awid       (i_axi_awid),
   .i_axi_awaddr     (i_axi_awaddr),
   .i_axi_awlen      (i_axi_awlen),
   .i_axi_awsize     (i_axi_awsize),
   .i_axi_awburst    (i_axi_awburst),
   .i_axi_awlock     (i_axi_awlock),
   .i_axi_awcache    (i_axi_awcache),
   .i_axi_awprot     (i_axi_awprot),
   .i_axi_awqos      (i_axi_awqos),
   .i_axi_awregion   (i_axi_awregion),
   .i_axi_awuser     (i_axi_awuser), 
   .i_axi_wready     (i_axi_wready),
   .i_axi_wvalid     (i_axi_wvalid),
   .i_axi_wid        (i_axi_wid),
   .i_axi_wdata      (i_axi_wdata),
   .i_axi_wstrb      (i_axi_wstrb),
   .i_axi_wlast      (i_axi_wlast),
   .i_axi_rready     (i_axi_rready),
   .i_axi_rvalid     (i_axi_rvalid),
   .i_axi_rid        (i_axi_rid),
   .i_axi_rdata      (i_axi_rdata),
   .i_axi_rresp      (i_axi_rresp),
   .i_axi_rlast      (i_axi_rlast),
   .i_axi_bready     (i_axi_bready),
   .i_axi_bvalid     (i_axi_bvalid),
   .i_axi_bid        (i_axi_bid),
   .i_axi_bresp      (i_axi_bresp),
   .o_axi_arready    (splt_bus_axi_arready),
   .o_axi_arvalid    (splt_bus_axi_arvalid),
   .o_axi_arid       (splt_bus_axi_arid),
   .o_axi_araddr     (splt_bus_axi_araddr),
   .o_axi_arlen      (splt_bus_axi_arlen),
   .o_axi_arsize     (splt_bus_axi_arsize),
   .o_axi_arburst    (splt_bus_axi_arburst),
   .o_axi_arlock     (splt_bus_axi_arlock),
   .o_axi_arcache    (splt_bus_axi_arcache),
   .o_axi_arprot     (splt_bus_axi_arprot),
   .o_axi_arqos      (splt_bus_axi_arqos),
   .o_axi_arregion   (splt_bus_axi_arregion),
   .o_axi_aruser     (splt_bus_axi_aruser),
   .o_axi_awready    (splt_bus_axi_awready),
   .o_axi_awvalid    (splt_bus_axi_awvalid),
   .o_axi_awid       (splt_bus_axi_awid),
   .o_axi_awaddr     (splt_bus_axi_awaddr),
   .o_axi_awlen      (splt_bus_axi_awlen),
   .o_axi_awsize     (splt_bus_axi_awsize),
   .o_axi_awburst    (splt_bus_axi_awburst),
   .o_axi_awlock     (splt_bus_axi_awlock),
   .o_axi_awcache    (splt_bus_axi_awcache),
   .o_axi_awprot     (splt_bus_axi_awprot),
   .o_axi_awqos      (splt_bus_axi_awqos),
   .o_axi_awregion   (splt_bus_axi_awregion),
   .o_axi_awuser     (splt_bus_axi_awuser), 
   .o_axi_wready     (splt_bus_axi_wready),
   .o_axi_wvalid     (splt_bus_axi_wvalid),
   .o_axi_wid        (splt_bus_axi_wid),
   .o_axi_wdata      (splt_bus_axi_wdata),
   .o_axi_wstrb      (splt_bus_axi_wstrb),
   .o_axi_wlast      (splt_bus_axi_wlast),
   .o_axi_rready     (splt_bus_axi_rready),
   .o_axi_rvalid     (splt_bus_axi_rvalid),
   .o_axi_rid        (splt_bus_axi_rid),
   .o_axi_rdata      (splt_bus_axi_rdata),
   .o_axi_rresp      (splt_bus_axi_rresp),
   .o_axi_rlast      (splt_bus_axi_rlast),
   .o_axi_bready     (splt_bus_axi_bready),
   .o_axi_bvalid     (splt_bus_axi_bvalid),
   .o_axi_bid        (splt_bus_axi_bid),
   .o_axi_bresp      (splt_bus_axi_bresp),
   .clk              (clk  ),
   .rst_n            (rst_n)
  );
endmodule
