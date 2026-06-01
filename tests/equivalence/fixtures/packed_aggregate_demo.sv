module packed_aggregate_demo(
  input  logic [3:0] a,
  input  logic [3:0] b,
  input  logic       flag,
  output logic [3:0] hi,
  output logic [3:0] lo,
  output logic [7:0] mirror
);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;
  typedef union packed { logic [7:0] wide; pair_t pair; } overlay_t;

  pair_t state;
  overlay_t overlay;

  always @(*) begin
    state.hi = a;
    state.lo = b;
    overlay.wide = flag ? {a, b} : {b, a};
  end

  assign hi = state.hi;
  assign lo = overlay.pair.lo;
  assign mirror = overlay.wide;
endmodule
