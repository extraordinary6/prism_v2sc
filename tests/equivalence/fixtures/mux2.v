module mux2 (
  input  wire       sel,
  input  wire [3:0] a,
  input  wire [3:0] b,
  output wire [3:0] y
);
  assign y = sel ? b : a;
endmodule
