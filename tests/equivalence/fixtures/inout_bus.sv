module inout_cell (
  input  wire oe,
  input  wire [3:0] din,
  inout  wire [3:0] pad,
  output wire [3:0] seen
);
  assign pad = oe ? din : 4'bzzzz;
  assign seen = pad;
endmodule

module inout_bus (
  input  wire       oe,
  input  wire [3:0] din,
  inout  wire [3:0] bus,
  output wire [3:0] seen,
  output wire [3:0] mixed
);
  inout_cell u (
    .oe(oe),
    .din(din),
    .pad(bus),
    .seen(seen)
  );

  assign mixed = bus ^ 4'hA;
endmodule
