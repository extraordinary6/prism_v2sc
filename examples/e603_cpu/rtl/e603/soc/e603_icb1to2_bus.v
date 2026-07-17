 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_1to2_ficb1ton_bus #(
  parameter I_SUPPORT_RATIO = 0, 
  parameter O_SUPPORT_RATIO = 0,
  parameter ALLOW_DIFF =0,
  parameter ALLOW_0CYCL_RSP =0,
  parameter ICB_FIFO_CMD_BYPBUF = 0,
  parameter ICB_FIFO_CMD_DP = 0, 
  parameter ICB_FIFO_RSP_DP = 0, 
  parameter ICB_FIFO_CMD_CUT_READY = 1, 
  parameter ICB_FIFO_RSP_CUT_READY = 1, 
  parameter O0_BASE_ADDR       = 32'h0,       
  parameter O0_BASE_REGION_LSB = 12,
  parameter O1_BASE_ADDR       = 32'h0,       
  parameter O1_BASE_REGION_LSB = 12,
  parameter PAYLOAD_NORST    = 0,
  parameter SPLT_FIFO_OUTS_NUM    = 1,
  parameter SPLT_FIFO_OUTS_CNT_W  = 1,
  parameter SPLT_FIFO_CUT_READY   = 1 
)(
  input i_clk_en,
  input o_clk_en,
  output  icb1ton_active,
    input              i_icb_cmd_valid               ,
  output             i_icb_cmd_ready               ,
  input              i_icb_cmd_sel                 ,
  input              i_icb_cmd_read                ,
  input  [  31:   0] i_icb_cmd_addr                ,
  input  [  63:   0] i_icb_cmd_wdata               ,
  input  [   7:   0] i_icb_cmd_wmask               ,
  input  [   2:   0] i_icb_cmd_size                ,
  input              i_icb_cmd_lock                ,
  input              i_icb_cmd_excl                ,
  input  [   7:   0] i_icb_cmd_xlen                ,
  input  [   1:   0] i_icb_cmd_xburst              ,
  input  [   1:   0] i_icb_cmd_modes               ,
  input              i_icb_cmd_dmode               ,
  input  [   2:   0] i_icb_cmd_attri               ,
  input  [   1:   0] i_icb_cmd_beat                ,
  input              i_icb_cmd_usr                 ,
  input              i_icb_rsp_ready               ,
  output             i_icb_rsp_valid               ,
  output             i_icb_rsp_err                 ,
  output             i_icb_rsp_excl_ok             ,
  output [  63:   0] i_icb_rsp_rdata               ,
  output             i_icb_rsp_usr                 ,
  input                          o0_icb_enable,
    output             o0_icb_cmd_valid              ,
  input              o0_icb_cmd_ready              ,
  output             o0_icb_cmd_sel                ,
  output             o0_icb_cmd_read               ,
  output [  31:   0] o0_icb_cmd_addr               ,
  output [  63:   0] o0_icb_cmd_wdata              ,
  output [   7:   0] o0_icb_cmd_wmask              ,
  output [   2:   0] o0_icb_cmd_size               ,
  output             o0_icb_cmd_lock               ,
  output             o0_icb_cmd_excl               ,
  output [   7:   0] o0_icb_cmd_xlen               ,
  output [   1:   0] o0_icb_cmd_xburst             ,
  output [   1:   0] o0_icb_cmd_modes              ,
  output             o0_icb_cmd_dmode              ,
  output [   2:   0] o0_icb_cmd_attri              ,
  output [   1:   0] o0_icb_cmd_beat               ,
  output             o0_icb_cmd_usr                ,
  output             o0_icb_rsp_ready              ,
  input              o0_icb_rsp_valid              ,
  input              o0_icb_rsp_err                ,
  input              o0_icb_rsp_excl_ok            ,
  input  [  63:   0] o0_icb_rsp_rdata              ,
  input              o0_icb_rsp_usr                ,
    output             o1_icb_cmd_valid              ,
  input              o1_icb_cmd_ready              ,
  output             o1_icb_cmd_sel                ,
  output             o1_icb_cmd_read               ,
  output [  31:   0] o1_icb_cmd_addr               ,
  output [  63:   0] o1_icb_cmd_wdata              ,
  output [   7:   0] o1_icb_cmd_wmask              ,
  output [   2:   0] o1_icb_cmd_size               ,
  output             o1_icb_cmd_lock               ,
  output             o1_icb_cmd_excl               ,
  output [   7:   0] o1_icb_cmd_xlen               ,
  output [   1:   0] o1_icb_cmd_xburst             ,
  output [   1:   0] o1_icb_cmd_modes              ,
  output             o1_icb_cmd_dmode              ,
  output [   2:   0] o1_icb_cmd_attri              ,
  output [   1:   0] o1_icb_cmd_beat               ,
  output             o1_icb_cmd_usr                ,
  output             o1_icb_rsp_ready              ,
  input              o1_icb_rsp_valid              ,
  input              o1_icb_rsp_err                ,
  input              o1_icb_rsp_excl_ok            ,
  input  [  63:   0] o1_icb_rsp_rdata              ,
  input              o1_icb_rsp_usr                ,
  input  clk,
  input  rst_n
  );
    wire                buf_icb_cmd_valid             ;
  wire                buf_icb_cmd_ready             ;
  wire                buf_icb_cmd_sel               ;
  wire                buf_icb_cmd_read              ;
  wire    [  31:   0] buf_icb_cmd_addr              ;
  wire    [  63:   0] buf_icb_cmd_wdata             ;
  wire    [   7:   0] buf_icb_cmd_wmask             ;
  wire    [   2:   0] buf_icb_cmd_size              ;
  wire                buf_icb_cmd_lock              ;
  wire                buf_icb_cmd_excl              ;
  wire    [   7:   0] buf_icb_cmd_xlen              ;
  wire    [   1:   0] buf_icb_cmd_xburst            ;
  wire    [   1:   0] buf_icb_cmd_modes             ;
  wire                buf_icb_cmd_dmode             ;
  wire    [   2:   0] buf_icb_cmd_attri             ;
  wire    [   1:   0] buf_icb_cmd_beat              ;
  wire                buf_icb_cmd_usr               ;
  wire                buf_icb_rsp_ready             ;
  wire                buf_icb_rsp_valid             ;
  wire                buf_icb_rsp_err               ;
  wire                buf_icb_rsp_excl_ok           ;
  wire    [  63:   0] buf_icb_rsp_rdata             ;
  wire                buf_icb_rsp_usr               ;
  wire buffer_active;
  wire splt_active;
  assign icb1ton_active = buffer_active | splt_active;
  e603_gnrl_ficb_buffer # (
    .I_SUPPORT_RATIO(I_SUPPORT_RATIO),
    .O_SUPPORT_RATIO(O_SUPPORT_RATIO),
    .OUTS_CNT_W     (SPLT_FIFO_OUTS_CNT_W),
    .AW    (32),
    .DW    (64), 
    .RSP_DP(ICB_FIFO_RSP_DP),
    .CMD_BYPBUF(ICB_FIFO_CMD_BYPBUF),
    .CMD_DP(ICB_FIFO_CMD_DP),
    .PAYLOAD_NORST(PAYLOAD_NORST),
    .CMD_CUT_READY (ICB_FIFO_CMD_CUT_READY),
    .RSP_CUT_READY (ICB_FIFO_RSP_CUT_READY),
    .CMD_UW (1),
    .RSP_UW (1)
  )u_e603_icb_buffer(
    .i_clk_en   (i_clk_en),
    .o_clk_en   (o_clk_en),
    .icb_buffer_active (buffer_active),
      .i_icb_cmd_valid                (i_icb_cmd_valid                          ),
  .i_icb_cmd_ready                (i_icb_cmd_ready                          ),
  .i_icb_cmd_sel                  (i_icb_cmd_sel                            ),
  .i_icb_cmd_read                 (i_icb_cmd_read                           ),
  .i_icb_cmd_addr                 (i_icb_cmd_addr                [  31:   0]),
  .i_icb_cmd_wdata                (i_icb_cmd_wdata               [  63:   0]),
  .i_icb_cmd_wmask                (i_icb_cmd_wmask               [   7:   0]),
  .i_icb_cmd_size                 (i_icb_cmd_size                [   2:   0]),
  .i_icb_cmd_lock                 (i_icb_cmd_lock                           ),
  .i_icb_cmd_excl                 (i_icb_cmd_excl                           ),
  .i_icb_cmd_xlen                 (i_icb_cmd_xlen                [   7:   0]),
  .i_icb_cmd_xburst               (i_icb_cmd_xburst              [   1:   0]),
  .i_icb_cmd_modes                (i_icb_cmd_modes               [   1:   0]),
  .i_icb_cmd_dmode                (i_icb_cmd_dmode                          ),
  .i_icb_cmd_attri                (i_icb_cmd_attri               [   2:   0]),
  .i_icb_cmd_beat                 (i_icb_cmd_beat                [   1:   0]),
  .i_icb_cmd_usr                  (i_icb_cmd_usr                            ),
  .i_icb_rsp_ready                (i_icb_rsp_ready                          ),
  .i_icb_rsp_valid                (i_icb_rsp_valid                          ),
  .i_icb_rsp_err                  (i_icb_rsp_err                            ),
  .i_icb_rsp_excl_ok              (i_icb_rsp_excl_ok                        ),
  .i_icb_rsp_rdata                (i_icb_rsp_rdata               [  63:   0]),
  .i_icb_rsp_usr                  (i_icb_rsp_usr                            ),
      .o_icb_cmd_valid                (buf_icb_cmd_valid                        ),
  .o_icb_cmd_ready                (buf_icb_cmd_ready                        ),
  .o_icb_cmd_sel                  (buf_icb_cmd_sel                          ),
  .o_icb_cmd_read                 (buf_icb_cmd_read                         ),
  .o_icb_cmd_addr                 (buf_icb_cmd_addr              [  31:   0]),
  .o_icb_cmd_wdata                (buf_icb_cmd_wdata             [  63:   0]),
  .o_icb_cmd_wmask                (buf_icb_cmd_wmask             [   7:   0]),
  .o_icb_cmd_size                 (buf_icb_cmd_size              [   2:   0]),
  .o_icb_cmd_lock                 (buf_icb_cmd_lock                         ),
  .o_icb_cmd_excl                 (buf_icb_cmd_excl                         ),
  .o_icb_cmd_xlen                 (buf_icb_cmd_xlen              [   7:   0]),
  .o_icb_cmd_xburst               (buf_icb_cmd_xburst            [   1:   0]),
  .o_icb_cmd_modes                (buf_icb_cmd_modes             [   1:   0]),
  .o_icb_cmd_dmode                (buf_icb_cmd_dmode                        ),
  .o_icb_cmd_attri                (buf_icb_cmd_attri             [   2:   0]),
  .o_icb_cmd_beat                 (buf_icb_cmd_beat              [   1:   0]),
  .o_icb_cmd_usr                  (buf_icb_cmd_usr                          ),
  .o_icb_rsp_ready                (buf_icb_rsp_ready                        ),
  .o_icb_rsp_valid                (buf_icb_rsp_valid                        ),
  .o_icb_rsp_err                  (buf_icb_rsp_err                          ),
  .o_icb_rsp_excl_ok              (buf_icb_rsp_excl_ok                      ),
  .o_icb_rsp_rdata                (buf_icb_rsp_rdata             [  63:   0]),
  .o_icb_rsp_usr                  (buf_icb_rsp_usr                          ),
    .clk                    (clk  ),
    .rst_n                  (rst_n)
  );
    wire    [   1:   0] splt_bus_icb_cmd_valid        ;
  wire    [   1:   0] splt_bus_icb_cmd_ready        ;
  wire    [   1:   0] splt_bus_icb_cmd_sel          ;
  wire    [   1:   0] splt_bus_icb_cmd_read         ;
  wire    [  63:   0] splt_bus_icb_cmd_addr         ;
  wire    [ 127:   0] splt_bus_icb_cmd_wdata        ;
  wire    [  15:   0] splt_bus_icb_cmd_wmask        ;
  wire    [   5:   0] splt_bus_icb_cmd_size         ;
  wire    [   1:   0] splt_bus_icb_cmd_lock         ;
  wire    [   1:   0] splt_bus_icb_cmd_excl         ;
  wire    [  15:   0] splt_bus_icb_cmd_xlen         ;
  wire    [   3:   0] splt_bus_icb_cmd_xburst       ;
  wire    [   3:   0] splt_bus_icb_cmd_modes        ;
  wire    [   1:   0] splt_bus_icb_cmd_dmode        ;
  wire    [   5:   0] splt_bus_icb_cmd_attri        ;
  wire    [   3:   0] splt_bus_icb_cmd_beat         ;
  wire    [   1:   0] splt_bus_icb_cmd_usr          ;
  wire    [   1:   0] splt_bus_icb_rsp_ready        ;
  wire    [   1:   0] splt_bus_icb_rsp_valid        ;
  wire    [   1:   0] splt_bus_icb_rsp_err          ;
  wire    [   1:   0] splt_bus_icb_rsp_excl_ok      ;
  wire    [ 127:   0] splt_bus_icb_rsp_rdata        ;
  wire    [   1:   0] splt_bus_icb_rsp_usr          ;
      assign                 { o1_icb_cmd_sel
                           , o0_icb_cmd_sel
                           } = splt_bus_icb_cmd_sel;
      assign                 { o1_icb_cmd_valid
                           , o0_icb_cmd_valid
                           } = splt_bus_icb_cmd_valid;
      assign                 { o1_icb_cmd_read
                           , o0_icb_cmd_read
                           } = splt_bus_icb_cmd_read;
      assign                 { o1_icb_cmd_addr
                           , o0_icb_cmd_addr
                           } = splt_bus_icb_cmd_addr;
      assign                 { o1_icb_cmd_wdata
                           , o0_icb_cmd_wdata
                           } = splt_bus_icb_cmd_wdata;
      assign                 { o1_icb_cmd_wmask
                           , o0_icb_cmd_wmask
                           } = splt_bus_icb_cmd_wmask;
      assign                 { o1_icb_cmd_size
                           , o0_icb_cmd_size
                           } = splt_bus_icb_cmd_size;
      assign                 { o1_icb_cmd_lock
                           , o0_icb_cmd_lock
                           } = splt_bus_icb_cmd_lock;
      assign                 { o1_icb_cmd_excl
                           , o0_icb_cmd_excl
                           } = splt_bus_icb_cmd_excl;
      assign                 { o1_icb_cmd_xlen
                           , o0_icb_cmd_xlen
                           } = splt_bus_icb_cmd_xlen;
      assign                 { o1_icb_cmd_xburst
                           , o0_icb_cmd_xburst
                           } = splt_bus_icb_cmd_xburst;
      assign                 { o1_icb_cmd_modes
                           , o0_icb_cmd_modes
                           } = splt_bus_icb_cmd_modes;
      assign                 { o1_icb_cmd_dmode
                           , o0_icb_cmd_dmode
                           } = splt_bus_icb_cmd_dmode;
      assign                 { o1_icb_cmd_attri
                           , o0_icb_cmd_attri
                           } = splt_bus_icb_cmd_attri;
      assign                 { o1_icb_cmd_beat
                           , o0_icb_cmd_beat
                           } = splt_bus_icb_cmd_beat;
      assign                 { o1_icb_cmd_usr
                           , o0_icb_cmd_usr
                           } = splt_bus_icb_cmd_usr;
    assign splt_bus_icb_cmd_ready =
                           { o1_icb_cmd_ready
                           , o0_icb_cmd_ready
                           };
    assign splt_bus_icb_rsp_valid =
                           { o1_icb_rsp_valid
                           , o0_icb_rsp_valid
                           };
    assign splt_bus_icb_rsp_err =
                           { o1_icb_rsp_err
                           , o0_icb_rsp_err
                           };
    assign splt_bus_icb_rsp_excl_ok =
                           { o1_icb_rsp_excl_ok
                           , o0_icb_rsp_excl_ok
                           };
    assign splt_bus_icb_rsp_rdata =
                           { o1_icb_rsp_rdata
                           , o0_icb_rsp_rdata
                           };
    assign splt_bus_icb_rsp_usr =
                           { o1_icb_rsp_usr
                           , o0_icb_rsp_usr
                           };
      assign                 { o1_icb_rsp_ready
                           , o0_icb_rsp_ready
                           } = splt_bus_icb_rsp_ready;
      wire icb_cmd_o0 = (buf_icb_cmd_addr     [31:O0_BASE_REGION_LSB]
                         ==  O0_BASE_ADDR [31:O0_BASE_REGION_LSB] 
                        ) & o0_icb_enable 
                        ; 
      wire icb_cmd_o1 = 1'b1
                          & (~icb_cmd_o0)
                        ; 
  wire [2-1:0] buf_icb_splt_indic = 
      {
                      icb_cmd_o1
                    , icb_cmd_o0
      };
  e603_gnrl_ficb_splt # (
  .ALLOW_DIFF (ALLOW_DIFF),
  .ALLOW_0CYCL_RSP (ALLOW_0CYCL_RSP),
  .FIFO_OUTS_NUM   (SPLT_FIFO_OUTS_NUM ),
  .FIFO_CUT_READY  (SPLT_FIFO_CUT_READY),
  .SPLT_NUM   (2),
  .SPLT_PTR_W (2),
  .SPLT_PTR_1HOT (1),
  .PAYLOAD_NORST(PAYLOAD_NORST),
  .CMD_UW (1),
  .RSP_UW (1),
  .AW         (32),
  .DW         (64) 
  ) u_buf_icb_splt(
      .clk_en(o_clk_en),
  .i_icb_splt_indic       (buf_icb_splt_indic),        
  .splt_active            (splt_active),
      .i_icb_cmd_valid                (buf_icb_cmd_valid                        ),
  .i_icb_cmd_ready                (buf_icb_cmd_ready                        ),
  .i_icb_cmd_sel                  (buf_icb_cmd_sel                          ),
  .i_icb_cmd_read                 (buf_icb_cmd_read                         ),
  .i_icb_cmd_addr                 (buf_icb_cmd_addr              [  31:   0]),
  .i_icb_cmd_wdata                (buf_icb_cmd_wdata             [  63:   0]),
  .i_icb_cmd_wmask                (buf_icb_cmd_wmask             [   7:   0]),
  .i_icb_cmd_size                 (buf_icb_cmd_size              [   2:   0]),
  .i_icb_cmd_lock                 (buf_icb_cmd_lock                         ),
  .i_icb_cmd_excl                 (buf_icb_cmd_excl                         ),
  .i_icb_cmd_xlen                 (buf_icb_cmd_xlen              [   7:   0]),
  .i_icb_cmd_xburst               (buf_icb_cmd_xburst            [   1:   0]),
  .i_icb_cmd_modes                (buf_icb_cmd_modes             [   1:   0]),
  .i_icb_cmd_dmode                (buf_icb_cmd_dmode                        ),
  .i_icb_cmd_attri                (buf_icb_cmd_attri             [   2:   0]),
  .i_icb_cmd_beat                 (buf_icb_cmd_beat              [   1:   0]),
  .i_icb_cmd_usr                  (buf_icb_cmd_usr                          ),
  .i_icb_rsp_ready                (buf_icb_rsp_ready                        ),
  .i_icb_rsp_valid                (buf_icb_rsp_valid                        ),
  .i_icb_rsp_err                  (buf_icb_rsp_err                          ),
  .i_icb_rsp_excl_ok              (buf_icb_rsp_excl_ok                      ),
  .i_icb_rsp_rdata                (buf_icb_rsp_rdata             [  63:   0]),
  .i_icb_rsp_usr                  (buf_icb_rsp_usr                          ),
      .o_bus_icb_cmd_valid            (splt_bus_icb_cmd_valid        [   1:   0]),
  .o_bus_icb_cmd_ready            (splt_bus_icb_cmd_ready        [   1:   0]),
  .o_bus_icb_cmd_sel              (splt_bus_icb_cmd_sel          [   1:   0]),
  .o_bus_icb_cmd_read             (splt_bus_icb_cmd_read         [   1:   0]),
  .o_bus_icb_cmd_addr             (splt_bus_icb_cmd_addr         [  63:   0]),
  .o_bus_icb_cmd_wdata            (splt_bus_icb_cmd_wdata        [ 127:   0]),
  .o_bus_icb_cmd_wmask            (splt_bus_icb_cmd_wmask        [  15:   0]),
  .o_bus_icb_cmd_size             (splt_bus_icb_cmd_size         [   5:   0]),
  .o_bus_icb_cmd_lock             (splt_bus_icb_cmd_lock         [   1:   0]),
  .o_bus_icb_cmd_excl             (splt_bus_icb_cmd_excl         [   1:   0]),
  .o_bus_icb_cmd_xlen             (splt_bus_icb_cmd_xlen         [  15:   0]),
  .o_bus_icb_cmd_xburst           (splt_bus_icb_cmd_xburst       [   3:   0]),
  .o_bus_icb_cmd_modes            (splt_bus_icb_cmd_modes        [   3:   0]),
  .o_bus_icb_cmd_dmode            (splt_bus_icb_cmd_dmode        [   1:   0]),
  .o_bus_icb_cmd_attri            (splt_bus_icb_cmd_attri        [   5:   0]),
  .o_bus_icb_cmd_beat             (splt_bus_icb_cmd_beat         [   3:   0]),
  .o_bus_icb_cmd_usr              (splt_bus_icb_cmd_usr          [   1:   0]),
  .o_bus_icb_rsp_ready            (splt_bus_icb_rsp_ready        [   1:   0]),
  .o_bus_icb_rsp_valid            (splt_bus_icb_rsp_valid        [   1:   0]),
  .o_bus_icb_rsp_err              (splt_bus_icb_rsp_err          [   1:   0]),
  .o_bus_icb_rsp_excl_ok          (splt_bus_icb_rsp_excl_ok      [   1:   0]),
  .o_bus_icb_rsp_rdata            (splt_bus_icb_rsp_rdata        [ 127:   0]),
  .o_bus_icb_rsp_usr              (splt_bus_icb_rsp_usr          [   1:   0]),
  .clk                    (clk  )                     ,
  .rst_n                  (rst_n)
  );
endmodule
