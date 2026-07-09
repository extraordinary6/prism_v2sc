// Equivalence fixture: whole-vector inout resolution edges.
module inout_edge_cell (
  input  wire       drive,
  input  wire [7:0] din,
  inout  wire [7:0] pad,
  output wire [7:0] seen,
  output wire [7:0] folded
);
  assign pad = drive ? din : 8'bzzzzzzzz;
  assign seen = pad;
  assign folded = {pad[3:0], pad[7:4]} ^ 8'h5a;
endmodule

module inout_edges (
  input  wire       oe,
  input  wire [7:0] din,
  inout  wire [7:0] bus,
  output wire [7:0] child_seen,
  output wire [7:0] folded,
  output wire [7:0] top_seen
);
  inout_edge_cell u_cell (
    .drive(oe),
    .din(din),
    .pad(bus),
    .seen(child_seen),
    .folded(folded)
  );

  assign top_seen = bus;
endmodule
