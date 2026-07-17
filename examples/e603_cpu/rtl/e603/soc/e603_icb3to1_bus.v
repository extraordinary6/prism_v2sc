 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_3to1_ficbnto1_bus #(
  parameter SUPPORT_LOCK = 1,
  parameter I_SUPPORT_RATIO = 0,
  parameter O_SUPPORT_RATIO = 0,
  parameter PAYLOAD_NORST = 0,
  parameter ICB_FIFO_CMD_DP = 0, 
  parameter ICB_FIFO_RSP_DP = 0, 
  parameter ICB_FIFO_CMD_CUT_READY = 1, 
  parameter ICB_FIFO_RSP_CUT_READY = 1, 
  parameter ARBT_FIFO_OUTS_NUM    = 1,
  parameter ARBT_FIFO_OUTS_CNT_W  = 1,
  parameter ARBT_FIFO_CUT_READY   = 1,
  parameter RRBIN_CUT_TIMING = 0,
  parameter ARBT_SCHEME = 3,
  parameter ARBT_ALLOW_0CYCL_RSP = 0
)(
  output icbnto1_active,
  input  i_clk_en,
  input  o_clk_en,
    output             o_icb_cmd_valid               ,
  input              o_icb_cmd_ready               ,
  output             o_icb_cmd_sel                 ,
  output             o_icb_cmd_read                ,
  output [  63:   0] o_icb_cmd_addr                ,
  output [  63:   0] o_icb_cmd_wdata               ,
  output [   7:   0] o_icb_cmd_wmask               ,
  output [   2:   0] o_icb_cmd_size                ,
  output             o_icb_cmd_lock                ,
  output             o_icb_cmd_excl                ,
  output [   7:   0] o_icb_cmd_xlen                ,
  output [   1:   0] o_icb_cmd_xburst              ,
  output [   1:   0] o_icb_cmd_modes               ,
  output             o_icb_cmd_dmode               ,
  output [   2:   0] o_icb_cmd_attri               ,
  output [   1:   0] o_icb_cmd_beat                ,
  output             o_icb_cmd_usr                 ,
  output             o_icb_rsp_ready               ,
  input              o_icb_rsp_valid               ,
  input              o_icb_rsp_err                 ,
  input              o_icb_rsp_excl_ok             ,
  input  [  63:   0] o_icb_rsp_rdata               ,
  input              o_icb_rsp_usr                 ,
    input              i0_icb_cmd_valid              ,
  output             i0_icb_cmd_ready              ,
  input              i0_icb_cmd_sel                ,
  input              i0_icb_cmd_read               ,
  input  [  63:   0] i0_icb_cmd_addr               ,
  input  [  63:   0] i0_icb_cmd_wdata              ,
  input  [   7:   0] i0_icb_cmd_wmask              ,
  input  [   2:   0] i0_icb_cmd_size               ,
  input              i0_icb_cmd_lock               ,
  input              i0_icb_cmd_excl               ,
  input  [   7:   0] i0_icb_cmd_xlen               ,
  input  [   1:   0] i0_icb_cmd_xburst             ,
  input  [   1:   0] i0_icb_cmd_modes              ,
  input              i0_icb_cmd_dmode              ,
  input  [   2:   0] i0_icb_cmd_attri              ,
  input  [   1:   0] i0_icb_cmd_beat               ,
  input              i0_icb_cmd_usr                ,
  input              i0_icb_rsp_ready              ,
  output             i0_icb_rsp_valid              ,
  output             i0_icb_rsp_err                ,
  output             i0_icb_rsp_excl_ok            ,
  output [  63:   0] i0_icb_rsp_rdata              ,
  output             i0_icb_rsp_usr                ,
    input              i1_icb_cmd_valid              ,
  output             i1_icb_cmd_ready              ,
  input              i1_icb_cmd_sel                ,
  input              i1_icb_cmd_read               ,
  input  [  63:   0] i1_icb_cmd_addr               ,
  input  [  63:   0] i1_icb_cmd_wdata              ,
  input  [   7:   0] i1_icb_cmd_wmask              ,
  input  [   2:   0] i1_icb_cmd_size               ,
  input              i1_icb_cmd_lock               ,
  input              i1_icb_cmd_excl               ,
  input  [   7:   0] i1_icb_cmd_xlen               ,
  input  [   1:   0] i1_icb_cmd_xburst             ,
  input  [   1:   0] i1_icb_cmd_modes              ,
  input              i1_icb_cmd_dmode              ,
  input  [   2:   0] i1_icb_cmd_attri              ,
  input  [   1:   0] i1_icb_cmd_beat               ,
  input              i1_icb_cmd_usr                ,
  input              i1_icb_rsp_ready              ,
  output             i1_icb_rsp_valid              ,
  output             i1_icb_rsp_err                ,
  output             i1_icb_rsp_excl_ok            ,
  output [  63:   0] i1_icb_rsp_rdata              ,
  output             i1_icb_rsp_usr                ,
    input              i2_icb_cmd_valid              ,
  output             i2_icb_cmd_ready              ,
  input              i2_icb_cmd_sel                ,
  input              i2_icb_cmd_read               ,
  input  [  63:   0] i2_icb_cmd_addr               ,
  input  [  63:   0] i2_icb_cmd_wdata              ,
  input  [   7:   0] i2_icb_cmd_wmask              ,
  input  [   2:   0] i2_icb_cmd_size               ,
  input              i2_icb_cmd_lock               ,
  input              i2_icb_cmd_excl               ,
  input  [   7:   0] i2_icb_cmd_xlen               ,
  input  [   1:   0] i2_icb_cmd_xburst             ,
  input  [   1:   0] i2_icb_cmd_modes              ,
  input              i2_icb_cmd_dmode              ,
  input  [   2:   0] i2_icb_cmd_attri              ,
  input  [   1:   0] i2_icb_cmd_beat               ,
  input              i2_icb_cmd_usr                ,
  input              i2_icb_rsp_ready              ,
  output             i2_icb_rsp_valid              ,
  output             i2_icb_rsp_err                ,
  output             i2_icb_rsp_excl_ok            ,
  output [  63:   0] i2_icb_rsp_rdata              ,
  output             i2_icb_rsp_usr                ,
  input  clk,
  input  rst_n
  );
    wire    [   2:   0] arbt_bus_icb_cmd_valid        ;
  wire    [   2:   0] arbt_bus_icb_cmd_ready        ;
  wire    [   2:   0] arbt_bus_icb_cmd_sel          ;
  wire    [   2:   0] arbt_bus_icb_cmd_read         ;
  wire    [ 191:   0] arbt_bus_icb_cmd_addr         ;
  wire    [ 191:   0] arbt_bus_icb_cmd_wdata        ;
  wire    [  23:   0] arbt_bus_icb_cmd_wmask        ;
  wire    [   8:   0] arbt_bus_icb_cmd_size         ;
  wire    [   2:   0] arbt_bus_icb_cmd_lock         ;
  wire    [   2:   0] arbt_bus_icb_cmd_excl         ;
  wire    [  23:   0] arbt_bus_icb_cmd_xlen         ;
  wire    [   5:   0] arbt_bus_icb_cmd_xburst       ;
  wire    [   5:   0] arbt_bus_icb_cmd_modes        ;
  wire    [   2:   0] arbt_bus_icb_cmd_dmode        ;
  wire    [   8:   0] arbt_bus_icb_cmd_attri        ;
  wire    [   5:   0] arbt_bus_icb_cmd_beat         ;
  wire    [   2:   0] arbt_bus_icb_cmd_usr          ;
  wire    [   2:   0] arbt_bus_icb_rsp_ready        ;
  wire    [   2:   0] arbt_bus_icb_rsp_valid        ;
  wire    [   2:   0] arbt_bus_icb_rsp_err          ;
  wire    [   2:   0] arbt_bus_icb_rsp_excl_ok      ;
  wire    [ 191:   0] arbt_bus_icb_rsp_rdata        ;
  wire    [   2:   0] arbt_bus_icb_rsp_usr          ;
    assign arbt_bus_icb_cmd_valid =
                           { i2_icb_cmd_valid
                           , i1_icb_cmd_valid
                           , i0_icb_cmd_valid
                           };
    assign arbt_bus_icb_cmd_sel =
                           { i2_icb_cmd_sel
                           , i1_icb_cmd_sel
                           , i0_icb_cmd_sel
                           };
    assign arbt_bus_icb_cmd_read =
                           { i2_icb_cmd_read
                           , i1_icb_cmd_read
                           , i0_icb_cmd_read
                           };
    assign arbt_bus_icb_cmd_addr =
                           { i2_icb_cmd_addr
                           , i1_icb_cmd_addr
                           , i0_icb_cmd_addr
                           };
    assign arbt_bus_icb_cmd_wdata =
                           { i2_icb_cmd_wdata
                           , i1_icb_cmd_wdata
                           , i0_icb_cmd_wdata
                           };
    assign arbt_bus_icb_cmd_wmask =
                           { i2_icb_cmd_wmask
                           , i1_icb_cmd_wmask
                           , i0_icb_cmd_wmask
                           };
    assign arbt_bus_icb_cmd_size =
                           { i2_icb_cmd_size
                           , i1_icb_cmd_size
                           , i0_icb_cmd_size
                           };
    assign arbt_bus_icb_cmd_lock =
                           { i2_icb_cmd_lock
                           , i1_icb_cmd_lock
                           , i0_icb_cmd_lock
                           };
    assign arbt_bus_icb_cmd_excl =
                           { i2_icb_cmd_excl
                           , i1_icb_cmd_excl
                           , i0_icb_cmd_excl
                           };
    assign arbt_bus_icb_cmd_xlen =
                           { i2_icb_cmd_xlen
                           , i1_icb_cmd_xlen
                           , i0_icb_cmd_xlen
                           };
    assign arbt_bus_icb_cmd_xburst =
                           { i2_icb_cmd_xburst
                           , i1_icb_cmd_xburst
                           , i0_icb_cmd_xburst
                           };
    assign arbt_bus_icb_cmd_modes =
                           { i2_icb_cmd_modes
                           , i1_icb_cmd_modes
                           , i0_icb_cmd_modes
                           };
    assign arbt_bus_icb_cmd_dmode =
                           { i2_icb_cmd_dmode
                           , i1_icb_cmd_dmode
                           , i0_icb_cmd_dmode
                           };
    assign arbt_bus_icb_cmd_attri =
                           { i2_icb_cmd_attri
                           , i1_icb_cmd_attri
                           , i0_icb_cmd_attri
                           };
    assign arbt_bus_icb_cmd_beat =
                           { i2_icb_cmd_beat
                           , i1_icb_cmd_beat
                           , i0_icb_cmd_beat
                           };
    assign arbt_bus_icb_cmd_usr =
                           { i2_icb_cmd_usr
                           , i1_icb_cmd_usr
                           , i0_icb_cmd_usr
                           };
      assign                 { i2_icb_cmd_ready
                           , i1_icb_cmd_ready
                           , i0_icb_cmd_ready
                           } = arbt_bus_icb_cmd_ready;
      assign                 { i2_icb_rsp_valid
                           , i1_icb_rsp_valid
                           , i0_icb_rsp_valid
                           } = arbt_bus_icb_rsp_valid;
      assign                 { i2_icb_rsp_err
                           , i1_icb_rsp_err
                           , i0_icb_rsp_err
                           } = arbt_bus_icb_rsp_err;
      assign                 { i2_icb_rsp_excl_ok
                           , i1_icb_rsp_excl_ok
                           , i0_icb_rsp_excl_ok
                           } = arbt_bus_icb_rsp_excl_ok;
      assign                 { i2_icb_rsp_rdata
                           , i1_icb_rsp_rdata
                           , i0_icb_rsp_rdata
                           } = arbt_bus_icb_rsp_rdata;
      assign                 { i2_icb_rsp_usr
                           , i1_icb_rsp_usr
                           , i0_icb_rsp_usr
                           } = arbt_bus_icb_rsp_usr;
    assign arbt_bus_icb_rsp_ready =
                           { i2_icb_rsp_ready
                           , i1_icb_rsp_ready
                           , i0_icb_rsp_ready
                           };
    wire                arbt_icb_cmd_valid            ;
  wire                arbt_icb_cmd_ready            ;
  wire                arbt_icb_cmd_sel              ;
  wire                arbt_icb_cmd_read             ;
  wire    [  63:   0] arbt_icb_cmd_addr             ;
  wire    [  63:   0] arbt_icb_cmd_wdata            ;
  wire    [   7:   0] arbt_icb_cmd_wmask            ;
  wire    [   2:   0] arbt_icb_cmd_size             ;
  wire                arbt_icb_cmd_lock             ;
  wire                arbt_icb_cmd_excl             ;
  wire    [   7:   0] arbt_icb_cmd_xlen             ;
  wire    [   1:   0] arbt_icb_cmd_xburst           ;
  wire    [   1:   0] arbt_icb_cmd_modes            ;
  wire                arbt_icb_cmd_dmode            ;
  wire    [   2:   0] arbt_icb_cmd_attri            ;
  wire    [   1:   0] arbt_icb_cmd_beat             ;
  wire                arbt_icb_cmd_usr              ;
  wire                arbt_icb_rsp_ready            ;
  wire                arbt_icb_rsp_valid            ;
  wire                arbt_icb_rsp_err              ;
  wire                arbt_icb_rsp_excl_ok          ;
  wire    [  63:   0] arbt_icb_rsp_rdata            ;
  wire                arbt_icb_rsp_usr              ;
    wire                buf_icb_cmd_valid             ;
  wire                buf_icb_cmd_ready             ;
  wire                buf_icb_cmd_sel               ;
  wire                buf_icb_cmd_read              ;
  wire    [  63:   0] buf_icb_cmd_addr              ;
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
  wire arbt_active;
  e603_gnrl_ficb_arbt # (
  .SUPPORT_LOCK(SUPPORT_LOCK),
  .ARBT_SCHEME (ARBT_SCHEME),
  .RRBIN_CUT_TIMING(RRBIN_CUT_TIMING),
    .PAYLOAD_NORST(PAYLOAD_NORST),
  .ALLOW_0CYCL_RSP (ARBT_ALLOW_0CYCL_RSP),
  .FIFO_OUTS_NUM   (ARBT_FIFO_OUTS_NUM),
  .FIFO_CUT_READY  (ARBT_FIFO_CUT_READY),
  .ARBT_NUM   (3),
  .ARBT_PTR_W (2),
  .CMD_UW      (1),
  .RSP_UW      (1),
  .AW         (64),
  .DW         (64) 
  ) u_icb_arbt(
  .clk_en(i_clk_en),
  .arbt_active            (arbt_active),
      .i_bus_icb_cmd_valid            (arbt_bus_icb_cmd_valid        [   2:   0]),
  .i_bus_icb_cmd_ready            (arbt_bus_icb_cmd_ready        [   2:   0]),
  .i_bus_icb_cmd_read             (arbt_bus_icb_cmd_read         [   2:   0]),
  .i_bus_icb_cmd_addr             (arbt_bus_icb_cmd_addr         [ 191:   0]),
  .i_bus_icb_cmd_wdata            (arbt_bus_icb_cmd_wdata        [ 191:   0]),
  .i_bus_icb_cmd_wmask            (arbt_bus_icb_cmd_wmask        [  23:   0]),
  .i_bus_icb_cmd_size             (arbt_bus_icb_cmd_size         [   8:   0]),
  .i_bus_icb_cmd_lock             (arbt_bus_icb_cmd_lock         [   2:   0]),
  .i_bus_icb_cmd_excl             (arbt_bus_icb_cmd_excl         [   2:   0]),
  .i_bus_icb_cmd_xlen             (arbt_bus_icb_cmd_xlen         [  23:   0]),
  .i_bus_icb_cmd_xburst           (arbt_bus_icb_cmd_xburst       [   5:   0]),
  .i_bus_icb_cmd_modes            (arbt_bus_icb_cmd_modes        [   5:   0]),
  .i_bus_icb_cmd_dmode            (arbt_bus_icb_cmd_dmode        [   2:   0]),
  .i_bus_icb_cmd_attri            (arbt_bus_icb_cmd_attri        [   8:   0]),
  .i_bus_icb_cmd_beat             (arbt_bus_icb_cmd_beat         [   5:   0]),
  .i_bus_icb_cmd_usr              (arbt_bus_icb_cmd_usr          [   2:   0]),
  .i_bus_icb_rsp_ready            (arbt_bus_icb_rsp_ready        [   2:   0]),
  .i_bus_icb_rsp_valid            (arbt_bus_icb_rsp_valid        [   2:   0]),
  .i_bus_icb_rsp_err              (arbt_bus_icb_rsp_err          [   2:   0]),
  .i_bus_icb_rsp_excl_ok          (arbt_bus_icb_rsp_excl_ok      [   2:   0]),
  .i_bus_icb_rsp_rdata            (arbt_bus_icb_rsp_rdata        [ 191:   0]),
  .i_bus_icb_rsp_usr              (arbt_bus_icb_rsp_usr          [   2:   0]),
      .o_icb_cmd_valid                (arbt_icb_cmd_valid                       ),
  .o_icb_cmd_ready                (arbt_icb_cmd_ready                       ),
  .o_icb_cmd_sel                  (arbt_icb_cmd_sel                         ),
  .o_icb_cmd_read                 (arbt_icb_cmd_read                        ),
  .o_icb_cmd_addr                 (arbt_icb_cmd_addr             [  63:   0]),
  .o_icb_cmd_wdata                (arbt_icb_cmd_wdata            [  63:   0]),
  .o_icb_cmd_wmask                (arbt_icb_cmd_wmask            [   7:   0]),
  .o_icb_cmd_size                 (arbt_icb_cmd_size             [   2:   0]),
  .o_icb_cmd_lock                 (arbt_icb_cmd_lock                        ),
  .o_icb_cmd_excl                 (arbt_icb_cmd_excl                        ),
  .o_icb_cmd_xlen                 (arbt_icb_cmd_xlen             [   7:   0]),
  .o_icb_cmd_xburst               (arbt_icb_cmd_xburst           [   1:   0]),
  .o_icb_cmd_modes                (arbt_icb_cmd_modes            [   1:   0]),
  .o_icb_cmd_dmode                (arbt_icb_cmd_dmode                       ),
  .o_icb_cmd_attri                (arbt_icb_cmd_attri            [   2:   0]),
  .o_icb_cmd_beat                 (arbt_icb_cmd_beat             [   1:   0]),
  .o_icb_cmd_usr                  (arbt_icb_cmd_usr                         ),
  .o_icb_rsp_ready                (arbt_icb_rsp_ready                       ),
  .o_icb_rsp_valid                (arbt_icb_rsp_valid                       ),
  .o_icb_rsp_err                  (arbt_icb_rsp_err                         ),
  .o_icb_rsp_excl_ok              (arbt_icb_rsp_excl_ok                     ),
  .o_icb_rsp_rdata                (arbt_icb_rsp_rdata            [  63:   0]),
  .o_icb_rsp_usr                  (arbt_icb_rsp_usr                         ),
    .i_bus_icb_cmd_sel_vec      (arbt_bus_icb_cmd_sel ) ,
  .clk                    (clk  )                     ,
  .rst_n                  (rst_n)
  );
  wire buffer_active;
  assign icbnto1_active = buffer_active | arbt_active;
  e603_gnrl_ficb_buffer # (
    .I_SUPPORT_RATIO(I_SUPPORT_RATIO),
    .O_SUPPORT_RATIO(O_SUPPORT_RATIO),
    .OUTS_CNT_W     (ARBT_FIFO_OUTS_CNT_W),
    .AW    (64),
    .DW    (64), 
    .PAYLOAD_NORST(PAYLOAD_NORST),
    .CMD_DP(ICB_FIFO_CMD_DP),
    .RSP_DP(ICB_FIFO_RSP_DP),
    .CMD_CUT_READY (ICB_FIFO_CMD_CUT_READY),
    .RSP_CUT_READY (ICB_FIFO_RSP_CUT_READY),
    .CMD_UW (1),
    .RSP_UW (1)
  )u_e603_icb_buffer(
    .i_clk_en   (i_clk_en),
    .o_clk_en   (o_clk_en),
    .icb_buffer_active (buffer_active),
      .i_icb_cmd_valid                (arbt_icb_cmd_valid                       ),
  .i_icb_cmd_ready                (arbt_icb_cmd_ready                       ),
  .i_icb_cmd_sel                  (arbt_icb_cmd_sel                         ),
  .i_icb_cmd_read                 (arbt_icb_cmd_read                        ),
  .i_icb_cmd_addr                 (arbt_icb_cmd_addr             [  63:   0]),
  .i_icb_cmd_wdata                (arbt_icb_cmd_wdata            [  63:   0]),
  .i_icb_cmd_wmask                (arbt_icb_cmd_wmask            [   7:   0]),
  .i_icb_cmd_size                 (arbt_icb_cmd_size             [   2:   0]),
  .i_icb_cmd_lock                 (arbt_icb_cmd_lock                        ),
  .i_icb_cmd_excl                 (arbt_icb_cmd_excl                        ),
  .i_icb_cmd_xlen                 (arbt_icb_cmd_xlen             [   7:   0]),
  .i_icb_cmd_xburst               (arbt_icb_cmd_xburst           [   1:   0]),
  .i_icb_cmd_modes                (arbt_icb_cmd_modes            [   1:   0]),
  .i_icb_cmd_dmode                (arbt_icb_cmd_dmode                       ),
  .i_icb_cmd_attri                (arbt_icb_cmd_attri            [   2:   0]),
  .i_icb_cmd_beat                 (arbt_icb_cmd_beat             [   1:   0]),
  .i_icb_cmd_usr                  (arbt_icb_cmd_usr                         ),
  .i_icb_rsp_ready                (arbt_icb_rsp_ready                       ),
  .i_icb_rsp_valid                (arbt_icb_rsp_valid                       ),
  .i_icb_rsp_err                  (arbt_icb_rsp_err                         ),
  .i_icb_rsp_excl_ok              (arbt_icb_rsp_excl_ok                     ),
  .i_icb_rsp_rdata                (arbt_icb_rsp_rdata            [  63:   0]),
  .i_icb_rsp_usr                  (arbt_icb_rsp_usr                         ),
      .o_icb_cmd_valid                (o_icb_cmd_valid                          ),
  .o_icb_cmd_ready                (o_icb_cmd_ready                          ),
  .o_icb_cmd_sel                  (o_icb_cmd_sel                            ),
  .o_icb_cmd_read                 (o_icb_cmd_read                           ),
  .o_icb_cmd_addr                 (o_icb_cmd_addr                [  63:   0]),
  .o_icb_cmd_wdata                (o_icb_cmd_wdata               [  63:   0]),
  .o_icb_cmd_wmask                (o_icb_cmd_wmask               [   7:   0]),
  .o_icb_cmd_size                 (o_icb_cmd_size                [   2:   0]),
  .o_icb_cmd_lock                 (o_icb_cmd_lock                           ),
  .o_icb_cmd_excl                 (o_icb_cmd_excl                           ),
  .o_icb_cmd_xlen                 (o_icb_cmd_xlen                [   7:   0]),
  .o_icb_cmd_xburst               (o_icb_cmd_xburst              [   1:   0]),
  .o_icb_cmd_modes                (o_icb_cmd_modes               [   1:   0]),
  .o_icb_cmd_dmode                (o_icb_cmd_dmode                          ),
  .o_icb_cmd_attri                (o_icb_cmd_attri               [   2:   0]),
  .o_icb_cmd_beat                 (o_icb_cmd_beat                [   1:   0]),
  .o_icb_cmd_usr                  (o_icb_cmd_usr                            ),
  .o_icb_rsp_ready                (o_icb_rsp_ready                          ),
  .o_icb_rsp_valid                (o_icb_rsp_valid                          ),
  .o_icb_rsp_err                  (o_icb_rsp_err                            ),
  .o_icb_rsp_excl_ok              (o_icb_rsp_excl_ok                        ),
  .o_icb_rsp_rdata                (o_icb_rsp_rdata               [  63:   0]),
  .o_icb_rsp_usr                  (o_icb_rsp_usr                            ),
    .clk                    (clk  ),
    .rst_n                  (rst_n)
  );
endmodule
