interface stream_if;
  logic [7:0] req;
  logic [7:0] rsp;
  logic       valid;

  modport master(output req, output valid, input rsp);
  modport slave(input req, input valid, output rsp);
endinterface

module iface_source (
  input  wire [7:0] a,
  input  wire       en,
  stream_if.master  bus,
  output wire [7:0] echo
);
  assign bus.req = en ? (a ^ 8'h3c) : 8'h00;
  assign bus.valid = en;
  assign echo = bus.rsp;
endmodule

module iface_sink (
  stream_if.slave   bus,
  input  wire [7:0] bias,
  output wire [7:0] y
);
  assign bus.rsp = bus.valid ? (bus.req + bias) : (bias ^ 8'h55);
  assign y = bus.rsp;
endmodule

module interface_modport (
  input  wire [7:0] a,
  input  wire [7:0] bias,
  input  wire       en,
  output wire [7:0] y,
  output wire [7:0] echo
);
  stream_if bus();

  iface_source u_src (
    .a(a),
    .en(en),
    .bus(bus),
    .echo(echo)
  );

  iface_sink u_sink (
    .bus(bus),
    .bias(bias),
    .y(y)
  );
endmodule
