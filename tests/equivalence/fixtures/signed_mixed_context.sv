// Equivalence fixture: signed/unsigned expressions with explicit extension
// and casts at the type boundary.
module signed_mixed_context (
  input  wire signed [7:0] s,
  input  wire        [7:0] u,
  input  wire signed [3:0] narrow_s,
  input  wire        [2:0] sh,
  input  wire              sel,
  output wire signed [8:0] sum_math,
  output wire signed [8:0] diff_math,
  output wire              lt_math,
  output wire              lt_bits,
  output wire signed [7:0] shifted_lo,
  output wire signed [8:0] chosen
);
  wire signed [8:0] s_ext;
  wire signed [8:0] u_ext;
  wire signed [8:0] narrow_ext;

  assign s_ext = s;
  assign u_ext = $signed({1'b0, u});
  assign narrow_ext = narrow_s;

  assign sum_math = s_ext + u_ext;
  assign diff_math = u_ext - s_ext + narrow_ext;
  assign lt_math = s_ext < u_ext;
  assign lt_bits = $unsigned(s) < u;
  assign shifted_lo = $signed(s[7:0]) >>> sh;
  assign chosen = sel ? s_ext : (u_ext + narrow_ext);
endmodule
