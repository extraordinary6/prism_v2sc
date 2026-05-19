// Equivalence fixture for slice-aware multi-writer aggregation.
//
// Two distinct always_ff blocks each write a different bit of the same
// 2-bit register ``q``. With naive codegen, this generates two SC_METHODs
// that both write ``q``, and SystemC aborts at runtime with
// ``SC_ID_MORE_THAN_ONE_SIGNAL_DRIVER_``. The codegen aggregation pass
// redirects each per-process write to a private ``__shadow_q_<idx>``
// signal and emits a single ``__assemble_q`` method that gathers both
// shadows back into ``q``.
//
// This fixture was previously unit-test-only (`test_phase8`'s
// slice-aware variant) — equivalence here pins runtime correctness, not
// just the diagnostic shape.
module slice_writers (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       a,
  input  wire       b,
  output reg  [1:0] q
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) q[0] <= 1'b0;
    else        q[0] <= a;
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) q[1] <= 1'b0;
    else        q[1] <= b;
  end
endmodule
