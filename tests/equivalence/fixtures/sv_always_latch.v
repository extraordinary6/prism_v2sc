// Equivalence fixture: SystemVerilog ``always_latch``.
// Transparent latch: when ``en`` is high, ``q`` follows ``d``; when ``en``
// is low, ``q`` holds its previous value. The lowerer treats
// ``always_latch`` as combinational, but our staged ``__next_*`` pattern
// (``auto __next_q = q.read();`` then conditional writes then
// ``q.write(__next_q)``) preserves the prior value when no branch writes
// it, which matches latch semantics for this design.
module sv_always_latch (
  input  wire       en,
  input  wire [7:0] d,
  output reg  [7:0] q
);
  always_latch begin
    if (en) q = d;
  end
endmodule
