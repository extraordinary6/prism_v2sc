 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
module e603_subsys_nice_core (
  input              nice_rst_n                    ,
  input              nice_clk                      ,
  output             nice_active                   ,
  output             nice_mem_holdup               ,
  input              nice_req_valid                ,
  output             nice_req_ready                ,
  input  [  31:   0] nice_req_instr                ,
  input  [  63:   0] nice_req_rs1                  ,
  input  [  63:   0] nice_req_rs2                  ,
  input              nice_req_mmode                ,
  input              nice_req_smode                ,
  output             nice_rsp_1cyc_type            ,
  output [  63:   0] nice_rsp_1cyc_dat             ,
  output             nice_rsp_multicyc_valid       ,
  input              nice_rsp_multicyc_ready       ,
  output [  63:   0] nice_rsp_multicyc_dat         ,
  output             nice_rsp_multicyc_err         ,
  output             nice_icb_cmd_valid            ,
  input              nice_icb_cmd_ready            ,
  output [  31:   0] nice_icb_cmd_addr             ,
  output             nice_icb_cmd_read             ,
  output [  63:   0] nice_icb_cmd_wdata            ,
  output [   7:   0] nice_icb_cmd_wmask            ,
  output [   2:   0] nice_icb_cmd_size             ,
  output             nice_icb_cmd_mmode            ,
  output             nice_icb_cmd_smode            ,
  input              nice_icb_rsp_valid            ,
  output             nice_icb_rsp_ready            ,
  input  [  63:   0] nice_icb_rsp_rdata            ,
  input              nice_icb_rsp_err              
);
   localparam ROWBUF_DW = 32;
   localparam ROWBUF_DP = 4;
   localparam ROWBUF_IDX_W = 2;
   localparam ROW_IDX_W = 2;
   localparam COL_IDX_W = 4;
   localparam PIPE_NUM = 3;
  wire                         i_nice_icb_cmd_valid;
  wire                         i_nice_icb_cmd_ready;
  wire [32-1:0]     i_nice_icb_cmd_addr; 
  wire                         i_nice_icb_cmd_read; 
  wire                         i_nice_icb_cmd_mmode; 
  wire                         i_nice_icb_cmd_smode; 
  wire                         i_nice_icb_cmd_dmode=1'b0;
  wire  [64-1:0]     i_nice_icb_cmd_wdata;
  wire  [8-1:0]     i_nice_icb_cmd_wmask;
  wire                         i_nice_icb_cmd_lock=1'b0;
  wire                         i_nice_icb_cmd_excl=1'b0;
  wire  [2:0]                  i_nice_icb_cmd_size;
  wire                         i_nice_icb_rsp_valid;
  wire                         i_nice_icb_rsp_ready;
  wire                         i_nice_icb_rsp_err  ;
  wire                         i_nice_icb_rsp_eccerr = 1'b0;
  wire [5-1:0] i_nice_icb_rsp_eccerr_code = 5'h0;
  wire                         i_nice_icb_rsp_excl_ok;
  wire [64-1:0]      i_nice_icb_rsp_rdata;
  wire[2-1:0] i_nice_icb_cmd_usr;
  assign {
      nice_icb_cmd_smode, 
      nice_icb_cmd_mmode
      } = i_nice_icb_cmd_usr;
  assign i_nice_icb_cmd_usr = {
      i_nice_icb_cmd_smode, 
      i_nice_icb_cmd_mmode
      };
  e603_nice2lsu_wconv
u_nice_icb_wconv (
    .clk                    (nice_clk  ),
    .rst_n                  (nice_rst_n),
    .i_icb_cmd_valid        (i_nice_icb_cmd_valid),
    .i_icb_cmd_ready        (i_nice_icb_cmd_ready),
    .i_icb_cmd_sel          (i_nice_icb_cmd_valid),
    .i_icb_cmd_read         (i_nice_icb_cmd_read ),
    .i_icb_cmd_addr         (i_nice_icb_cmd_addr ),
    .i_icb_cmd_wdata        (i_nice_icb_cmd_wdata),
    .i_icb_cmd_wmask        (i_nice_icb_cmd_wmask),
    .i_icb_cmd_lock         (i_nice_icb_cmd_lock ),
    .i_icb_cmd_excl         (i_nice_icb_cmd_excl ),
    .i_icb_cmd_size         (i_nice_icb_cmd_size),
    .i_icb_cmd_beat         (2'b0 ),
    .i_icb_cmd_usr          (i_nice_icb_cmd_usr  ),
    .i_icb_cmd_xburst       (2'b0),
    .i_icb_cmd_xlen         (8'b0  ),
    .i_icb_cmd_modes        (2'b0),
    .i_icb_cmd_dmode        (i_nice_icb_cmd_dmode ),
    .i_icb_cmd_attri        (3'b0 ),
    .i_icb_rsp_valid        (i_nice_icb_rsp_valid),
    .i_icb_rsp_ready        (i_nice_icb_rsp_ready),
    .i_icb_rsp_err          (i_nice_icb_rsp_err  ),
    .i_icb_rsp_excl_ok      (i_nice_icb_rsp_excl_ok),
    .i_icb_rsp_rdata        (i_nice_icb_rsp_rdata),
    .i_icb_rsp_usr          (),
    .o_icb_cmd_sel          (),
    .o_icb_cmd_valid        (nice_icb_cmd_valid  ),
    .o_icb_cmd_ready        (nice_icb_cmd_ready  ),
    .o_icb_cmd_read         (nice_icb_cmd_read   ),
    .o_icb_cmd_addr         (nice_icb_cmd_addr   ),
    .o_icb_cmd_wdata        (nice_icb_cmd_wdata  ),
    .o_icb_cmd_wmask        (nice_icb_cmd_wmask  ),
    .o_icb_cmd_lock         (   ),
    .o_icb_cmd_excl         (   ),
    .o_icb_cmd_size         (nice_icb_cmd_size   ),
    .o_icb_cmd_beat         (),
    .o_icb_cmd_usr          (),
    .o_icb_cmd_xburst       (),
    .o_icb_cmd_xlen         (),
    .o_icb_cmd_modes        (),
    .o_icb_cmd_dmode        ( ),
    .o_icb_cmd_attri        (),
    .o_icb_rsp_valid        (nice_icb_rsp_valid  ),
    .o_icb_rsp_ready        (nice_icb_rsp_ready  ),
    .o_icb_rsp_err          (nice_icb_rsp_err    ),
    .o_icb_rsp_excl_ok      (1'b0),
    .o_icb_rsp_rdata        (nice_icb_rsp_rdata  ),
    .o_icb_rsp_usr          (1'b0)
  );
// spyglass disable_block W484
// SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
// SJ:  Overflow is not cared
   wire [6:0] opcode      = {7{1'b1}} & nice_req_instr[6:0];
   wire [2:0] rv32_func3  = {3{1'b1}} & nice_req_instr[14:12];
   wire [6:0] rv32_func7  = {7{1'b1}} & nice_req_instr[31:25];
   wire opcode_custom0 = (opcode == 7'b0001011); 
   wire rv32_func3_000 = (rv32_func3 == 3'b000); 
   wire rv32_func3_001 = (rv32_func3 == 3'b001); 
   wire rv32_func3_010 = (rv32_func3 == 3'b010); 
   wire rv32_func3_011 = (rv32_func3 == 3'b011); 
   wire rv32_func3_100 = (rv32_func3 == 3'b100); 
   wire rv32_func3_101 = (rv32_func3 == 3'b101); 
   wire rv32_func3_110 = (rv32_func3 == 3'b110); 
   wire rv32_func3_111 = (rv32_func3 == 3'b111); 
   wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000); 
   wire rv32_func7_1000000 = (rv32_func7 == 7'b1000000); 
   wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001); 
   wire rv32_func7_0000010 = (rv32_func7 == 7'b0000010); 
   wire rv32_func7_0000011 = (rv32_func7 == 7'b0000011); 
   wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100); 
   wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101); 
   wire rv32_func7_0000110 = (rv32_func7 == 7'b0000110); 
   wire rv32_func7_0000111 = (rv32_func7 == 7'b0000111); 
   wire custom2_add      = opcode_custom0 & rv32_func3_111 & rv32_func7_0000000; 
   wire custom2_lbuf     = opcode_custom0 & rv32_func3_010 & rv32_func7_0000001; 
   wire custom2_sbuf     = opcode_custom0 & rv32_func3_010 & rv32_func7_0000010; 
   wire custom2_pipeadd  = opcode_custom0 & rv32_func3_111 & rv32_func7_0000011; 
   wire custom2_wsetup   = opcode_custom0 & rv32_func3_010 & rv32_func7_0000100; 
   wire custom2_rsetup   = opcode_custom0 & rv32_func3_100 & rv32_func7_0000101; 
   wire custom2_rowsum   = opcode_custom0 & rv32_func3_110 & rv32_func7_0000110; 
   wire custom2_crowbuf  = opcode_custom0 & rv32_func3_000 & rv32_func7_0000111; 
   wire custom_1cyc_op = custom2_add
                       | custom2_wsetup 
                       | custom2_rsetup 
                       | custom2_crowbuf
                       ;
   wire custom_multi_cyc_op = custom2_lbuf | custom2_sbuf | custom2_pipeadd | custom2_rowsum;
   wire custom_mem_op = custom2_lbuf | custom2_sbuf | custom2_rowsum;
   parameter NICE_FSM_WIDTH = 3; 
   parameter IDLE     = 3'd0; 
   parameter LBUF     = 3'd1; 
   parameter SBUF     = 3'd2; 
   parameter PIPE     = 3'd3; 
   parameter ROWSUM   = 3'd4; 
   wire [NICE_FSM_WIDTH-1:0] state_r; 
   wire [NICE_FSM_WIDTH-1:0] nxt_state; 
   wire [NICE_FSM_WIDTH-1:0] state_idle_nxt; 
   wire [NICE_FSM_WIDTH-1:0] state_lbuf_nxt; 
   wire [NICE_FSM_WIDTH-1:0] state_sbuf_nxt; 
   wire [NICE_FSM_WIDTH-1:0] state_pipe_nxt; 
   wire [NICE_FSM_WIDTH-1:0] state_rowsum_nxt; 
   wire nice_req_hsked;
   wire nice_rsp_hsked;
   wire nice_icb_rsp_hsked;
   wire illgel_instr = ~(custom_1cyc_op | custom_multi_cyc_op);
   wire state_idle_exit_ena; 
   wire state_lbuf_exit_ena; 
   wire state_sbuf_exit_ena; 
   wire state_pipe_exit_ena; 
   wire state_rowsum_exit_ena; 
   wire state_rbuf_exit_ena; 
   wire state_ena; 
   wire state_is_idle     = (state_r == IDLE); 
   wire state_is_lbuf     = (state_r == LBUF); 
   wire state_is_sbuf     = (state_r == SBUF); 
   wire state_is_pipe     = (state_r == PIPE); 
   wire state_is_rowsum   = (state_r == ROWSUM); 
   assign state_idle_exit_ena = state_is_idle & nice_req_hsked & ~custom_1cyc_op & ~illgel_instr; 
   assign state_idle_nxt =  custom2_lbuf    ? LBUF   : 
                            custom2_sbuf    ? SBUF   :
                            custom2_pipeadd ? PIPE   :
                            ROWSUM;
   wire lbuf_icb_rsp_hsked_last; 
   assign state_lbuf_exit_ena = state_is_lbuf & lbuf_icb_rsp_hsked_last; 
   assign state_lbuf_nxt = IDLE;
   wire sbuf_icb_rsp_hsked_last; 
   assign state_sbuf_exit_ena = state_is_sbuf & sbuf_icb_rsp_hsked_last; 
   assign state_sbuf_nxt = IDLE;
   wire pipe_empty; 
   assign state_pipe_exit_ena = state_is_pipe & pipe_empty; 
   assign state_pipe_nxt = IDLE;
   wire rowsum_done; 
   assign state_rowsum_exit_ena = state_is_rowsum & rowsum_done; 
   assign state_rowsum_nxt = IDLE;
   assign nxt_state =   ({NICE_FSM_WIDTH{state_idle_exit_ena   }} & state_idle_nxt   )
                      | ({NICE_FSM_WIDTH{state_lbuf_exit_ena   }} & state_lbuf_nxt   ) 
                      | ({NICE_FSM_WIDTH{state_sbuf_exit_ena   }} & state_sbuf_nxt   ) 
                      | ({NICE_FSM_WIDTH{state_pipe_exit_ena   }} & state_pipe_nxt   ) 
                      | ({NICE_FSM_WIDTH{state_rowsum_exit_ena }} & state_rowsum_nxt ) 
                      ;
   assign state_ena =   state_idle_exit_ena | state_lbuf_exit_ena   | state_sbuf_exit_ena
                      | state_pipe_exit_ena | state_rowsum_exit_ena;
e603_gnrl_dfflr #(NICE_FSM_WIDTH)   state_dfflr (state_ena, nxt_state, state_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   // spyglass disable_block W484
// SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
// SJ:  Overflow is not cared
   wire [ROW_IDX_W-1:0]  clonum = 2'b10;  
   wire [64-1:0] custom2_add_res    = nice_req_rs1   + nice_req_rs2; 
   // spyglass enable_block W484   
   wire [ROWBUF_IDX_W-1:0] lbuf_cnt_r; 
   wire [ROWBUF_IDX_W-1:0] lbuf_cnt_nxt; 
   wire lbuf_cnt_clr;
   wire lbuf_cnt_incr;
   wire lbuf_cnt_ena;
   wire lbuf_cnt_last;
   wire lbuf_icb_rsp_hsked;
   wire nice_rsp_valid_lbuf;
   wire nice_rsp_err_lbuf;
   wire nice_icb_cmd_valid_lbuf;
   assign lbuf_icb_rsp_hsked = state_is_lbuf & nice_icb_rsp_hsked;
   assign lbuf_icb_rsp_hsked_last = lbuf_icb_rsp_hsked & lbuf_cnt_last;
   assign lbuf_cnt_last = (lbuf_cnt_r == clonum);
   assign lbuf_cnt_clr = custom2_lbuf & nice_req_hsked;
   assign lbuf_cnt_incr = lbuf_icb_rsp_hsked & ~lbuf_cnt_last;
   assign lbuf_cnt_ena = lbuf_cnt_clr | lbuf_cnt_incr;
// spyglass disable_block W484
// SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
// SJ:  Overflow is not cared
   assign lbuf_cnt_nxt =   ({ROWBUF_IDX_W{lbuf_cnt_clr }} & {ROWBUF_IDX_W{1'b0}})
                         | ({ROWBUF_IDX_W{lbuf_cnt_incr}} & (lbuf_cnt_r + 1'b1) )
                         ;
// spyglass enable_block W484
e603_gnrl_dfflr #(ROWBUF_IDX_W)   lbuf_cnt_dfflr (lbuf_cnt_ena, lbuf_cnt_nxt, lbuf_cnt_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire nice_rsp_valid_lbuf_set = state_is_lbuf & lbuf_cnt_last & nice_icb_rsp_hsked;
   wire nice_rsp_valid_lbuf_clr = nice_rsp_valid_lbuf & nice_rsp_hsked;
   wire nice_rsp_valid_lbuf_ena = nice_rsp_valid_lbuf_set | nice_rsp_valid_lbuf_clr;
   wire nice_rsp_valid_lbuf_nxt = nice_rsp_valid_lbuf_set & ~nice_rsp_valid_lbuf_clr;
e603_gnrl_dfflr #(1)   nice_rsp_valid_lbuf_dfflr (nice_rsp_valid_lbuf_ena, nice_rsp_valid_lbuf_nxt, nice_rsp_valid_lbuf, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire nice_rsp_err_lbuf_set = state_is_lbuf & nice_icb_rsp_hsked;
   wire nice_rsp_err_lbuf_clr = nice_rsp_valid_lbuf & nice_rsp_hsked;
   wire nice_rsp_err_lbuf_ena = nice_rsp_err_lbuf_set | nice_rsp_err_lbuf_clr;
   wire nice_rsp_err_lbuf_nxt = nice_rsp_err_lbuf_clr ? 1'b0: (nice_rsp_err_lbuf | i_nice_icb_rsp_err);
e603_gnrl_dfflr #(1)   nice_rsp_err_lbuf_dfflr (nice_rsp_err_lbuf_ena, nice_rsp_err_lbuf_nxt, nice_rsp_err_lbuf, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire [ROWBUF_IDX_W-1:0] lbuf_cmd_cnt_r; 
   wire [ROWBUF_IDX_W-1:0] lbuf_cmd_cnt_nxt; 
   wire lbuf_cmd_cnt_clr;
   wire lbuf_cmd_cnt_incr;
   wire lbuf_cmd_cnt_ena;
   wire lbuf_cmd_cnt_last;
   wire lbuf_icb_cmd_hsked;
   assign lbuf_icb_cmd_hsked = nice_icb_cmd_valid_lbuf & i_nice_icb_cmd_ready;
   assign lbuf_cmd_cnt_last = (lbuf_cmd_cnt_r == clonum);
   assign lbuf_cmd_cnt_clr = lbuf_icb_rsp_hsked_last;
   assign lbuf_cmd_cnt_incr = lbuf_icb_cmd_hsked;
   assign lbuf_cmd_cnt_ena = lbuf_cmd_cnt_clr | lbuf_cmd_cnt_incr;
// spyglass disable_block W484
// SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
// SJ:  Overflow is not cared
   assign lbuf_cmd_cnt_nxt =   ({ROWBUF_IDX_W{lbuf_cmd_cnt_clr }} & {ROWBUF_IDX_W{1'b0}})
                             | ({ROWBUF_IDX_W{lbuf_cmd_cnt_incr}} & (lbuf_cmd_cnt_r + 1'b1) )
                             ;
// spyglass enable_block W484
e603_gnrl_dfflr #(ROWBUF_IDX_W)   lbuf_cmd_cnt_dfflr (lbuf_cmd_cnt_ena, lbuf_cmd_cnt_nxt, lbuf_cmd_cnt_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   assign nice_icb_cmd_valid_lbuf = (state_is_lbuf & (lbuf_cmd_cnt_r <= clonum));
   wire [ROWBUF_IDX_W-1:0] sbuf_cnt_r; 
   wire [ROWBUF_IDX_W-1:0] sbuf_cnt_nxt; 
   wire sbuf_cnt_clr;
   wire sbuf_cnt_incr;
   wire sbuf_cnt_ena;
   wire sbuf_cnt_last;
   wire sbuf_icb_cmd_hsked;
   wire sbuf_icb_rsp_hsked;
   wire nice_rsp_valid_sbuf;
   wire nice_rsp_err_sbuf;
   wire nice_icb_cmd_valid_sbuf;
   wire nice_icb_cmd_hsked;
   assign sbuf_icb_cmd_hsked = (state_is_sbuf | (state_is_idle & custom2_sbuf)) & nice_icb_cmd_hsked;
   assign sbuf_icb_rsp_hsked = state_is_sbuf & nice_icb_rsp_hsked;
   assign sbuf_icb_rsp_hsked_last = sbuf_icb_rsp_hsked & sbuf_cnt_last;
   assign sbuf_cnt_last = (sbuf_cnt_r == clonum);
   assign sbuf_cnt_clr = sbuf_icb_rsp_hsked_last;
   assign sbuf_cnt_incr = sbuf_icb_rsp_hsked & ~sbuf_cnt_last;
   assign sbuf_cnt_ena = sbuf_cnt_clr | sbuf_cnt_incr;
// spyglass disable_block W484
// SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
// SJ:  Overflow is not cared
   assign sbuf_cnt_nxt =   ({ROWBUF_IDX_W{sbuf_cnt_clr }} & {ROWBUF_IDX_W{1'b0}})
                         | ({ROWBUF_IDX_W{sbuf_cnt_incr}} & (sbuf_cnt_r + 1'b1) )
                         ;
// spyglass enable_block W484
e603_gnrl_dfflr #(ROWBUF_IDX_W)   sbuf_cnt_dfflr (sbuf_cnt_ena, sbuf_cnt_nxt, sbuf_cnt_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire nice_rsp_valid_sbuf_set = state_is_sbuf & sbuf_cnt_last & nice_icb_rsp_hsked;
   wire nice_rsp_valid_sbuf_clr = nice_rsp_valid_sbuf & nice_rsp_hsked;
   wire nice_rsp_valid_sbuf_ena = nice_rsp_valid_sbuf_set | nice_rsp_valid_sbuf_clr;
   wire nice_rsp_valid_sbuf_nxt = nice_rsp_valid_sbuf_set & ~nice_rsp_valid_sbuf_clr;
e603_gnrl_dfflr #(1)   nice_rsp_valid_sbuf_dfflr (nice_rsp_valid_sbuf_ena, nice_rsp_valid_sbuf_nxt, nice_rsp_valid_sbuf, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire nice_rsp_err_sbuf_set = state_is_sbuf & nice_icb_rsp_hsked;
   wire nice_rsp_err_sbuf_clr = nice_rsp_valid_sbuf & nice_rsp_hsked;
   wire nice_rsp_err_sbuf_ena = nice_rsp_err_sbuf_set | nice_rsp_err_sbuf_clr;
   wire nice_rsp_err_sbuf_nxt = nice_rsp_err_sbuf_clr ? 1'b0: (nice_rsp_err_sbuf | i_nice_icb_rsp_err);
e603_gnrl_dfflr #(1)   nice_rsp_err_sbuf_dfflr (nice_rsp_err_sbuf_ena, nice_rsp_err_sbuf_nxt, nice_rsp_err_sbuf, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire [ROWBUF_IDX_W-1:0] sbuf_cmd_cnt_r; 
   wire [ROWBUF_IDX_W-1:0] sbuf_cmd_cnt_nxt; 
   wire sbuf_cmd_cnt_clr;
   wire sbuf_cmd_cnt_incr;
   wire sbuf_cmd_cnt_ena;
   wire sbuf_cmd_cnt_last;
   assign sbuf_cmd_cnt_last = (sbuf_cmd_cnt_r == clonum);
   assign sbuf_cmd_cnt_clr = sbuf_icb_rsp_hsked_last;
   assign sbuf_cmd_cnt_incr = sbuf_icb_cmd_hsked;
   assign sbuf_cmd_cnt_ena = sbuf_cmd_cnt_clr | sbuf_cmd_cnt_incr;
// spyglass disable_block W484
// SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
// SJ:  Overflow is not cared
   assign sbuf_cmd_cnt_nxt =   ({ROWBUF_IDX_W{sbuf_cmd_cnt_clr }} & {ROWBUF_IDX_W{1'b0}})
                             | ({ROWBUF_IDX_W{sbuf_cmd_cnt_incr}} & (sbuf_cmd_cnt_r + 1'b1) )
                             ;
// spyglass enable_block W484
e603_gnrl_dfflr #(ROWBUF_IDX_W)   sbuf_cmd_cnt_dfflr (sbuf_cmd_cnt_ena, sbuf_cmd_cnt_nxt, sbuf_cmd_cnt_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   assign nice_icb_cmd_valid_sbuf = (state_is_sbuf & (sbuf_cmd_cnt_r <= clonum));
   wire pipe_req_hsked = (custom2_pipeadd & nice_req_hsked) | (state_is_pipe & nice_req_hsked);
   wire pipe_req_valid = (custom2_pipeadd & nice_req_valid);
   wire pipe_rsp_hsked = state_is_pipe & nice_rsp_hsked;
   wire pipe_rsp_ready = state_is_pipe & nice_rsp_multicyc_ready;
    // spyglass disable_block W484
    // SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
    // SJ:  Overflow is not cared
   wire [64-1:0] pipe_res_pre = nice_req_rs1 + nice_req_rs2; 
   // spyglass enable_block W484   
   wire [64-1:0] pipe_res;
   wire state_pipe_req_ready;
   wire nice_rsp_valid_pipe;
   wire [64-1:0] i_pipe_pack [PIPE_NUM-1:0];
   wire [64-1:0] o_pipe_pack [PIPE_NUM-1:0];
   wire [PIPE_NUM-1:0] i_pipe_vld;
   wire [PIPE_NUM-1:0] i_pipe_rdy;
   wire [PIPE_NUM-1:0] o_pipe_vld;
   wire [PIPE_NUM-1:0] o_pipe_rdy;
   assign i_pipe_vld = {o_pipe_vld[PIPE_NUM-2:0], pipe_req_valid};
   assign o_pipe_rdy = {nice_rsp_multicyc_ready, i_pipe_rdy[PIPE_NUM-1:1]};
   assign pipe_res = o_pipe_pack[PIPE_NUM-1];
   assign state_pipe_req_ready = state_is_pipe & i_pipe_rdy[0] & custom2_pipeadd;
   assign pipe_empty = ~(|o_pipe_vld[PIPE_NUM-2:0]) & o_pipe_vld[PIPE_NUM-1] & ~pipe_req_hsked & nice_rsp_hsked ; 
   assign nice_rsp_valid_pipe = state_is_pipe & o_pipe_vld[PIPE_NUM-1];
   genvar i;
   generate 
     for (i=0; i<PIPE_NUM; i=i+1) begin:gen_pipe_stage
       if(i==0) begin: pipe_0
         assign i_pipe_pack[i] = pipe_res_pre;
       e603_gnrl_bypbuf # (
         .DP(1),
         .DW(64)
       ) nice_pipe_stage (
         .i_vld(i_pipe_vld[i]), 
         .i_rdy(i_pipe_rdy[i]), 
         .i_dat(i_pipe_pack[i]),
         .o_vld(o_pipe_vld[i]), 
         .o_rdy(o_pipe_rdy[i]), 
         .o_dat(o_pipe_pack[i]),
         .fifo_o_vld(),
         .clk  (nice_clk),
         .rst_n(nice_rst_n)  
       );
       end
       else begin: pipe_not_zero
         assign i_pipe_pack[i] = o_pipe_pack[i-1];
       e603_gnrl_pipe_stage # (
         .CUT_READY(0),
         .DP(1),
         .DW(64)
       ) nice_pipe_stage (
         .i_vld(i_pipe_vld[i]), 
         .i_rdy(i_pipe_rdy[i]), 
         .i_dat(i_pipe_pack[i]),
         .o_vld(o_pipe_vld[i]), 
         .o_rdy(o_pipe_rdy[i]), 
         .o_dat(o_pipe_pack[i]),
         .clk  (nice_clk),
         .rst_n(nice_rst_n)  
       );
       end
     end
   endgenerate
   wire matrix_cfg_ena = custom2_wsetup & nice_req_hsked;
   wire [64-1:0] matrix_cfg_nxt = {{64-ROW_IDX_W{1'b0}},nice_req_rs1[ROW_IDX_W-1:0]};
   wire [64-1:0] matrix_cfg_r;
e603_gnrl_dfflr #(64)   matrix_cfg_dfflr (matrix_cfg_ena, matrix_cfg_nxt, matrix_cfg_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire [64-1:0] custom2_rsetup_res = ({64{custom2_rsetup}} & matrix_cfg_r); 
   wire [ROWBUF_IDX_W-1:0] rowbuf_cnt_r; 
   wire [ROWBUF_IDX_W-1:0] rowbuf_cnt_nxt; 
   wire rowbuf_cnt_clr;
   wire rowbuf_cnt_incr;
   wire rowbuf_cnt_ena;
   wire rowbuf_cnt_last;
   wire rowbuf_icb_rsp_hsked;
   wire rowbuf_rsp_hsked;
   wire nice_rsp_valid_rowsum;
   wire nice_rsp_err_rowsum;
   assign rowbuf_rsp_hsked = nice_rsp_valid_rowsum & nice_rsp_multicyc_ready;
   assign rowbuf_icb_rsp_hsked = state_is_rowsum & nice_icb_rsp_hsked;
   assign rowbuf_cnt_last = (rowbuf_cnt_r == clonum);
   assign rowbuf_cnt_clr = rowbuf_icb_rsp_hsked & rowbuf_cnt_last;
   assign rowbuf_cnt_incr = rowbuf_icb_rsp_hsked & ~rowbuf_cnt_last;
   assign rowbuf_cnt_ena = rowbuf_cnt_clr | rowbuf_cnt_incr;
// spyglass disable_block W484
// SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
// SJ:  Overflow is not cared
   assign rowbuf_cnt_nxt =   ({ROWBUF_IDX_W{rowbuf_cnt_clr }} & {ROWBUF_IDX_W{1'b0}})
                           | ({ROWBUF_IDX_W{rowbuf_cnt_incr}} & (rowbuf_cnt_r + 1'b1))
                           ;
// spyglass enable_block W484
e603_gnrl_dfflr #(ROWBUF_IDX_W)   rowbuf_cnt_dfflr (rowbuf_cnt_ena, rowbuf_cnt_nxt, rowbuf_cnt_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire nice_icb_cmd_valid_rowsum;
   wire [ROWBUF_IDX_W-1:0] rowbuf_cmd_cnt_r; 
   wire [ROWBUF_IDX_W-1:0] rowbuf_cmd_cnt_nxt; 
   wire rowbuf_cmd_cnt_clr;
   wire rowbuf_cmd_cnt_incr;
   wire rowbuf_cmd_cnt_ena;
   wire rowbuf_cmd_cnt_last;
   wire rowbuf_icb_cmd_hsked;
   wire rowbuf_cmd_hsked;
   wire nice_cmd_valid_rowsum;
   assign rowbuf_icb_cmd_hsked = nice_icb_cmd_valid_rowsum & i_nice_icb_cmd_ready;
   assign rowbuf_cmd_cnt_last = (rowbuf_cmd_cnt_r == clonum);
   assign rowbuf_cmd_cnt_clr = rowsum_done;
   assign rowbuf_cmd_cnt_incr = rowbuf_icb_cmd_hsked;
   assign rowbuf_cmd_cnt_ena = rowbuf_cmd_cnt_clr | rowbuf_cmd_cnt_incr;
// spyglass disable_block W484
// SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
// SJ:  Overflow is not cared
   assign rowbuf_cmd_cnt_nxt =   ({ROWBUF_IDX_W{rowbuf_cmd_cnt_clr }} & {ROWBUF_IDX_W{1'b0}})
                               | ({ROWBUF_IDX_W{rowbuf_cmd_cnt_incr}} & (rowbuf_cmd_cnt_r + 1'b1))
                               ;
// spyglass enable_block W484
e603_gnrl_dfflr #(ROWBUF_IDX_W)   rowbuf_cmd_cnt_dfflr (rowbuf_cmd_cnt_ena, rowbuf_cmd_cnt_nxt, rowbuf_cmd_cnt_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   assign nice_icb_cmd_valid_rowsum = (state_is_rowsum & (rowbuf_cmd_cnt_r <= clonum));
   wire [ROWBUF_DW-1:0] nice_icb_rsp_rdata_algn;
   wire rcv_data_buf_ena;
   wire rcv_data_buf_set;
   wire rcv_data_buf_clr;
   wire rcv_data_buf_valid;
   wire [ROWBUF_DW-1:0] rcv_data_buf; 
   wire [ROWBUF_IDX_W-1:0] rcv_data_buf_idx; 
   wire [ROWBUF_IDX_W-1:0] rcv_data_buf_idx_nxt; 
   assign rcv_data_buf_set = rowbuf_icb_rsp_hsked;
   assign rcv_data_buf_clr = rowbuf_rsp_hsked;
   assign rcv_data_buf_ena = rcv_data_buf_clr | rcv_data_buf_set;
   assign rcv_data_buf_idx_nxt =   ({ROWBUF_IDX_W{rcv_data_buf_clr}} & {ROWBUF_IDX_W{1'b0}})
                                 | ({ROWBUF_IDX_W{rcv_data_buf_set}} & rowbuf_cnt_r        );
e603_gnrl_dfflr #(1)   rcv_data_buf_valid_dfflr (1'b1, rcv_data_buf_set, rcv_data_buf_valid, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(ROWBUF_DW)   rcv_data_buf_dfflr (rcv_data_buf_ena, nice_icb_rsp_rdata_algn[ROWBUF_DW-1:0], rcv_data_buf, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(ROWBUF_IDX_W)   rowbuf_cnt_d_dfflr (rcv_data_buf_ena, rcv_data_buf_idx_nxt, rcv_data_buf_idx, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire [ROWBUF_DW-1:0] rowsum_acc_r;
   wire [ROWBUF_DW-1:0] rowsum_acc_nxt;
   wire [ROWBUF_DW-1:0] rowsum_acc_adder;
   wire rowsum_acc_ena;
   wire rowsum_acc_set;
   wire rowsum_acc_flg;
   wire [ROWBUF_DW-1:0] rowsum_res;
   assign rowsum_acc_set = rcv_data_buf_valid & (rcv_data_buf_idx == {ROWBUF_IDX_W{1'b0}});
   assign rowsum_acc_flg = rcv_data_buf_valid & (rcv_data_buf_idx != {ROWBUF_IDX_W{1'b0}});
       // spyglass disable_block W484
    // SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
    // SJ:  Overflow is not cared
   assign rowsum_acc_adder = rcv_data_buf + rowsum_acc_r;
      // spyglass enable_block W484
   assign rowsum_acc_ena = rowsum_acc_set | rowsum_acc_flg;
   assign rowsum_acc_nxt =   ({ROWBUF_DW{rowsum_acc_set}} & rcv_data_buf)
                           | ({ROWBUF_DW{rowsum_acc_flg}} & rowsum_acc_adder)
                           ;
e603_gnrl_dfflr #(ROWBUF_DW)   rowsum_acc_dfflr (rowsum_acc_ena, rowsum_acc_nxt, rowsum_acc_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   assign rowsum_done = state_is_rowsum & nice_rsp_hsked;
   assign rowsum_res  = rowsum_acc_r;
   assign nice_rsp_valid_rowsum = state_is_rowsum & (rcv_data_buf_idx == clonum) & ~rowsum_acc_flg;
   wire nice_rsp_err_rowsum_set = state_is_rowsum & nice_icb_rsp_hsked;
   wire nice_rsp_err_rowsum_clr = state_is_rowsum & nice_rsp_hsked;
   wire nice_rsp_err_rowsum_ena = nice_rsp_err_rowsum_set | nice_rsp_err_rowsum_clr;
   wire nice_rsp_err_rowsum_nxt = nice_rsp_err_rowsum_clr ? 1'b0: (nice_rsp_err_rowsum | i_nice_icb_rsp_err);
e603_gnrl_dfflr #(1)   nice_rsp_err_rowsum_dfflr (nice_rsp_err_rowsum_ena, nice_rsp_err_rowsum_nxt, nice_rsp_err_rowsum, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   wire rowbuf_clr = custom2_crowbuf & nice_req_hsked;
   wire [ROWBUF_DW-1:0] rowbuf_r [ROWBUF_DP-1:0];
   wire [ROWBUF_DW-1:0] rowbuf_wdat [ROWBUF_DP-1:0];
   wire [ROWBUF_DP-1:0]  rowbuf_we;
   wire [ROWBUF_IDX_W-1:0] rowbuf_idx_mux; 
   wire [ROWBUF_DW-1:0] rowbuf_wdat_mux; 
   wire rowbuf_wr_mux; 
   wire [ROWBUF_IDX_W-1:0] lbuf_idx = lbuf_cnt_r; 
   wire lbuf_wr = lbuf_icb_rsp_hsked; 
   wire [ROWBUF_DW-1:0] lbuf_wdata = nice_icb_rsp_rdata_algn[ROWBUF_DW-1:0];
   wire [ROWBUF_IDX_W-1:0] rowsum_idx = rcv_data_buf_idx; 
   wire rowsum_wr = rcv_data_buf_valid; 
// spyglass disable_block W484
// SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
// SJ:  Overflow is not cared
   wire [ROWBUF_DW-1:0] rowsum_wdata = rowbuf_r[rowsum_idx] + rcv_data_buf;
// spyglass enable_block W484
   assign rowbuf_wdat_mux =   ({ROWBUF_DW{lbuf_wr  }} & lbuf_wdata  )
                            | ({ROWBUF_DW{rowsum_wr}} & rowsum_wdata)
                            ;
   assign rowbuf_wr_mux   =  lbuf_wr | rowsum_wr;
   assign rowbuf_idx_mux  =   ({ROWBUF_IDX_W{lbuf_wr  }} & lbuf_idx  )
                            | ({ROWBUF_IDX_W{rowsum_wr}} & rowsum_idx)
                            ;  
   generate 
     for (i=0; i<ROWBUF_DP; i=i+1) begin:gen_rowbuf
       assign rowbuf_we[i] =   (rowbuf_wr_mux & (rowbuf_idx_mux == i[ROWBUF_IDX_W-1:0]))
                             | rowbuf_clr
                             ;
       assign rowbuf_wdat[i] =  rowbuf_clr ? {ROWBUF_DW{1'b0}} : rowbuf_wdat_mux;
e603_gnrl_dfflr #(ROWBUF_DW) rowbuf_dfflr (rowbuf_we[i], rowbuf_wdat[i], rowbuf_r[i], nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
     end
   endgenerate
   wire [32-1:0] maddr_acc_r; 
   assign nice_icb_cmd_hsked = i_nice_icb_cmd_valid & i_nice_icb_cmd_ready; 
   wire lbuf_maddr_ena    =   (state_is_idle & custom2_lbuf & nice_req_hsked)
                            | (state_is_lbuf & nice_icb_cmd_hsked)
                            ;
   wire sbuf_maddr_ena    =   (state_is_idle & custom2_sbuf & nice_req_hsked)
                            | (state_is_sbuf & nice_icb_cmd_hsked)
                            ;
   wire rowsum_maddr_ena  =   (state_is_idle & custom2_rowsum & nice_req_hsked)
                            | (state_is_rowsum & nice_icb_cmd_hsked)
                            ;
   wire  maddr_ena = lbuf_maddr_ena | sbuf_maddr_ena | rowsum_maddr_ena;
   wire  maddr_ena_idle = maddr_ena & state_is_idle;
   wire [32-1:0] maddr_acc_op1 = maddr_ena_idle ? nice_req_rs1[32-1:0] : maddr_acc_r; 
   wire [32-1:0] maddr_acc_op2 = maddr_ena_idle ? 32'h0 : 32'h4;  
    // spyglass disable_block W484
    // SMD: the LHS width should be greater than the RHS width to accommodate carry/borrow bit
    // SJ:  Overflow is not cared
   wire [32-1:0] maddr_acc_next = maddr_acc_op1 + maddr_acc_op2;
     // spyglass enable_block W484   
   wire  maddr_acc_ena = maddr_ena;
e603_gnrl_dfflr #(32)   maddr_acc_dfflr (maddr_acc_ena, maddr_acc_next, maddr_acc_r, nice_clk, nice_rst_n);// VPP_NO_REG_PARSE
   assign nice_req_hsked = nice_req_valid & nice_req_ready;
   assign nice_req_ready =   (state_is_idle & (custom_mem_op ? i_nice_icb_cmd_ready : 1'b1))
                          | (state_is_pipe & state_pipe_req_ready)
                          ;
   assign nice_rsp_1cyc_type = nice_req_hsked & (custom_1cyc_op | illgel_instr);
   assign nice_rsp_1cyc_dat   =   ({64{custom2_add
                                                         }}  & custom2_add_res   )
                            | ({64{custom2_rsetup}}  & custom2_rsetup_res)
                            ; 
   assign nice_rsp_hsked = nice_rsp_multicyc_valid & nice_rsp_multicyc_ready; 
   assign nice_icb_rsp_hsked = i_nice_icb_rsp_valid & i_nice_icb_rsp_ready;
   assign nice_rsp_multicyc_valid = nice_rsp_valid_rowsum | nice_rsp_valid_pipe | nice_rsp_valid_sbuf | nice_rsp_valid_lbuf;
   assign nice_rsp_multicyc_dat  =  ({64{state_is_pipe  }} & pipe_res   )
                          | ({64{state_is_rowsum}} & {32'b0, rowsum_res})
                          ; 
   assign nice_rsp_multicyc_err   =   (nice_rsp_valid_rowsum & nice_rsp_err_rowsum)
                           | (nice_rsp_valid_sbuf   & nice_rsp_err_sbuf  )
                           | (nice_rsp_valid_lbuf   & nice_rsp_err_lbuf  )
                            ;
   assign i_nice_icb_rsp_ready = 1'b1; 
   wire [ROWBUF_IDX_W-1:0] sbuf_idx = sbuf_cmd_cnt_r; 
   assign i_nice_icb_cmd_valid =  1'b0 
                              | nice_icb_cmd_valid_lbuf
                              | nice_icb_cmd_valid_sbuf
                              | nice_icb_cmd_valid_rowsum
                              ;
   assign i_nice_icb_cmd_addr  = 
                              maddr_acc_r;
   assign i_nice_icb_cmd_read  = 
                              state_is_sbuf ? 1'b0 : 
                              1'b1;
   assign i_nice_icb_cmd_wdata = 
                              state_is_sbuf ? {2{rowbuf_r[sbuf_idx]}} : 
                              64'b0; 
   assign i_nice_icb_cmd_wmask = {8{state_is_sbuf}} & (i_nice_icb_cmd_addr[2] ? 8'hf0 : 8'h0f);
   assign i_nice_icb_cmd_size  = 3'b010;
   assign i_nice_icb_cmd_mmode = 1'b1;
   assign i_nice_icb_cmd_smode = 1'b0;
   assign nice_mem_holdup    =  state_is_lbuf | state_is_sbuf | state_is_rowsum; 
   wire nice_rsp_fifo_wen = nice_icb_cmd_hsked;
   wire nice_rsp_fifo_ren = nice_icb_rsp_hsked;
   wire [2:0] nice_rsp_fifo_wdat = i_nice_icb_cmd_addr[2:0];
   wire [2:0] nice_rsp_fifo_rdat;
   wire nice_rsp_fifo_i_valid = nice_rsp_fifo_wen;
   wire nice_rsp_fifo_o_ready = nice_rsp_fifo_ren;
   wire [2:0] nice_icb_rsp_addr = nice_rsp_fifo_rdat;
  e603_gnrl_fifo # (
    .CUT_READY (1),
    .MSKO      (0),
    .DP  (ROWBUF_DP),
    .DW  (3)
  ) u_nice_rsp_fifo (
    .i_vld  (nice_rsp_fifo_i_valid),
    .i_rdy  (                     ),
    .i_dat  (nice_rsp_fifo_wdat   ),
    .o_vld  (                     ),
    .o_rdy  (nice_rsp_fifo_o_ready),  
    .o_dat  (nice_rsp_fifo_rdat   ),  
    .clk    (nice_clk             ),
    .rst_n  (nice_rst_n           )
  );
   wire [64-1:0] nice_icb_rsp_rdata_algn_pre = (i_nice_icb_rsp_rdata >> {nice_icb_rsp_addr[2],5'b0});
   assign nice_icb_rsp_rdata_algn = nice_icb_rsp_rdata_algn_pre[ROWBUF_DW-1:0];
   assign nice_active = state_is_idle ? ( nice_rsp_multicyc_valid | nice_req_valid) : 1'b1;
   // spyglass enable_block W484  
endmodule
