// Diagnostic fixture: dynamic/non-synthesizable SystemVerilog constructs
// should be surfaced instead of silently ignored.
module dynamic_sv_rejected (
  input  logic clk,
  output logic y
);
  class packet;
    rand bit [7:0] data;
  endclass

  property stable_y;
    @(posedge clk) y;
  endproperty

  assert property (stable_y);

  assign y = 1'b0;
endmodule
