module net_decl_assign(
  input  wire       a,
  input  wire       b,
  input  wire [3:0] data,
  output wire [3:0] y
);
  wire gate = a & b;
  wire [3:0] masked = data & {4{gate}};
  wire [3:0] selected = a ? masked : ~data;
  assign y = selected;
endmodule
