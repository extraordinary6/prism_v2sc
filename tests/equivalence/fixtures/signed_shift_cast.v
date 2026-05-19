// Equivalence fixture: arithmetic right shift via ``$signed`` cast.
//
// The input ``x`` is declared unsigned, so a plain ``x >>> n`` would
// behave like ``>>``. Wrapping it in ``$signed(x)`` flips the shift to
// arithmetic, which sign-extends the top bit. Without the codegen fix
// that turns ``$signed`` into a real ``sc_int<N>`` cast, the
// pre-existing implementation dropped the cast and the SystemC trace
// diverged from iverilog as soon as ``x`` had its top bit set.
module signed_shift_cast (
  input  wire [7:0] x,
  input  wire [2:0] n,
  output wire [7:0] y
);
  assign y = $signed(x) >>> n;
endmodule
