import pkg_defs::*;

module package_multifile (
  input  logic [W-1:0] a,
  input  logic [W-1:0] b,
  output logic [W-1:0] y
);
  word_t tmp;

  always_comb begin
    tmp = mix(a, b);
    y = tmp;
  end
endmodule
