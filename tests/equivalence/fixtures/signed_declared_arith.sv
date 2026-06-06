// Equivalence fixture: signed-declared ports, internal signed signals, signed
// comparison, arithmetic right shift, and signed based literals.
module signed_declared_arith (
  input  wire signed [7:0] a,
  input  wire signed [7:0] b,
  input  wire        [2:0] sh,
  output wire signed [8:0] sum,
  output wire signed [7:0] shifted,
  output wire              lt,
  output wire signed [7:0] literal
);
  wire signed [8:0] a_ext;
  wire signed [8:0] b_ext;

  assign a_ext = a;
  assign b_ext = b;
  assign sum = a_ext + b_ext;
  assign shifted = a >>> sh;
  assign lt = a < b;
  assign literal = 8'shFF;
endmodule
