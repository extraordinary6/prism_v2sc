// Conversion-only fixture: two interface instances with distinct modports and
// directions flatten to stable top-level signals and bindings.
interface lane_if;
  logic [3:0] req;
  logic [3:0] rsp;
  logic       valid;
  modport source(output req, output valid, input rsp);
  modport sink(input req, input valid, output rsp);
endinterface

module lane_source(input logic [3:0] data, input logic en, lane_if.source lane, output logic [3:0] echo);
  assign lane.req = en ? data : 4'h0;
  assign lane.valid = en;
  assign echo = lane.rsp;
endmodule

module lane_sink(lane_if.sink lane, input logic [3:0] bias, output logic [3:0] y);
  assign lane.rsp = lane.valid ? (lane.req + bias) : (bias ^ 4'h9);
  assign y = lane.rsp;
endmodule

module interface_modport_variants(
  input  logic [3:0] a,
  input  logic [3:0] b,
  input  logic       en,
  output logic [3:0] ya,
  output logic [3:0] yb,
  output logic [3:0] echo_a,
  output logic [3:0] echo_b
);
  lane_if lane_a();
  lane_if lane_b();

  lane_source src_a(.data(a), .en(en),  .lane(lane_a), .echo(echo_a));
  lane_sink   snk_a(.lane(lane_a), .bias(b), .y(ya));
  lane_source src_b(.data(b), .en(!en), .lane(lane_b), .echo(echo_b));
  lane_sink   snk_b(.lane(lane_b), .bias(a), .y(yb));
endmodule
