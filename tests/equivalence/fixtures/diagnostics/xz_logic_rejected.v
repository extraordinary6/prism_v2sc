// Diagnostic fixture: X/Z literals in ordinary two-state logic are not trace
// equivalent; the converter currently warns and collapses them to zero.
module xz_logic_rejected (
  input  wire [1:0] sel,
  input  wire [3:0] a,
  input  wire [3:0] b,
  output reg  [3:0] y
);
  always @(*) begin
    case (sel)
      2'b00: y = a;
      2'b01: y = 4'bxxxx;
      2'b10: y = 4'bzzzz;
      default: y = b;
    endcase
  end
endmodule
