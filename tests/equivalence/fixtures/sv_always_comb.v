// Equivalence fixture: SystemVerilog ``always_comb`` keyword.
// Same semantics as ``always @(*)`` but with the SV form.
module sv_always_comb (
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       sel,
  output reg  [7:0] y
);
  always_comb begin
    if (sel) y = a + b;
    else     y = a - b;
  end
endmodule
