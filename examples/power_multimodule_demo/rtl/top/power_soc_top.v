`include "power_defs.vh"

module power_soc_top (
  input  wire                 clk,
  input  wire                 rst_n,
  input  wire                 start,
  input  wire [3:0]           command,
  input  wire [`PMD_DATA_W-1:0] data_a,
  input  wire [`PMD_DATA_W-1:0] data_b,
  input  wire [`PMD_DATA_W-1:0] data_c,
  input  wire [`PMD_DATA_W-1:0] data_d,
  output wire [`PMD_DATA_W-1:0] result,
  output wire [`PMD_COUNT_W-1:0] packets
);
  wire busy;
  wire mix_mode;
  wire [1:0] mux_sel;
  wire [`PMD_DATA_W-1:0] q0;
  wire [`PMD_DATA_W-1:0] q1;
  wire [`PMD_DATA_W-1:0] q2;
  wire [`PMD_DATA_W-1:0] q3;
  wire [`PMD_DATA_W-1:0] mux_out;
  wire [`PMD_DATA_W-1:0] alu_out;
  wire [`PMD_DATA_W-1:0] accum_out;

  wire lane_en0;
  wire lane_en1;
  wire lane_en2;
  wire lane_en3;
  wire lane_en4;
  wire lane_en5;
  wire lane_en6;
  wire lane_en7;
  wire lane_en8;
  wire lane_en9;
  wire lane_en10;
  wire lane_en11;

  control_sequencer u_ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .command(command),
    .busy(busy),
    .mux_sel(mux_sel),
    .mix_mode(mix_mode),
    .packet_count(packets)
  );

  assign lane_en0 = busy & command[0];
  assign lane_en1 = busy & command[1];
  assign lane_en2 = busy & command[2];
  assign lane_en3 = busy & command[3];
  assign lane_en4 = busy & start;
  assign lane_en5 = busy & mux_sel[0];
  assign lane_en6 = busy & mux_sel[1];
  assign lane_en7 = busy & mix_mode;
  assign lane_en8 = busy & packets[0];
  assign lane_en9 = busy & packets[1];
  assign lane_en10 = busy & packets[2];
  assign lane_en11 = busy & packets[3];

  reg_bank u_regs (
    .clk(clk),
    .rst_n(rst_n),
    .load0(lane_en0),
    .load1(lane_en1),
    .load2(lane_en2),
    .load3(lane_en3),
    .d0(data_a),
    .d1(data_b),
    .d2(data_c),
    .d3(data_d),
    .q0(q0),
    .q1(q1),
    .q2(q2),
    .q3(q3)
  );

  wide_crossbar u_xbar (
    .sel(mux_sel),
    .in0(q0),
    .in1(q1),
    .in2(q2),
    .in3(q3),
    .out(mux_out)
  );

  vector_alu u_alu (
    .a(mux_out),
    .b(q1),
    .c(q2),
    .mask(accum_out),
    .mode(mix_mode),
    .result(alu_out)
  );

  wide_accumulator u_accum (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(alu_out),
    .accum(accum_out)
  );

  assign result = lane_en11 ? accum_out : alu_out;
endmodule

