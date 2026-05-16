// 8-bit adder with carry-out via concat-extended sum.
module adder (
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       ci,
  output wire [7:0] sum,
  output wire       co
);
  wire [8:0] full;
  assign full = {1'b0, a} + {1'b0, b} + {8'b0, ci};
  assign sum  = full[7:0];
  assign co   = full[8];
endmodule
