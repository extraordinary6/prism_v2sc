// Equivalence fixture: casez wildcard matching.
//
// Priority encoder over a 4-bit input. Each entry uses ``?`` wildcards,
// which casez treats as don't-cares. With our zero-X model, casez and
// casex are equivalent — the codegen lowers both to an if / else-if
// chain with mask/match comparisons, so the trace must match iverilog
// (which honors wildcard semantics natively).
module casez_priority (
  input  wire [3:0] op,
  output reg  [1:0] y
);
  always @(*) begin
    casez (op)
      4'b1???: y = 2'd0;
      4'b01??: y = 2'd1;
      4'b001?: y = 2'd2;
      4'b0001: y = 2'd3;
      default: y = 2'd3;
    endcase
  end
endmodule
