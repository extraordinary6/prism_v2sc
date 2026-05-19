// Equivalence fixture: casex wildcard matching.
//
// Same shape as the casez fixture but spelled with casex. Since the
// stimulus never drives X/Z bits (the RTL is fed integer values), casex
// behaves identically to casez here — the point of the fixture is just to
// pin that the codegen recognizes the ``casex`` keyword and emits the
// same mask/match chain rather than a plain switch.
module casex_priority (
  input  wire [3:0] op,
  output reg  [1:0] y
);
  always @(*) begin
    casex (op)
      4'b1???: y = 2'd0;
      4'b01??: y = 2'd1;
      4'b001?: y = 2'd2;
      4'b0001: y = 2'd3;
      default: y = 2'd3;
    endcase
  end
endmodule
