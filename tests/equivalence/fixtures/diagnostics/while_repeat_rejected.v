// Diagnostic fixture: procedural while/repeat loops are outside the supported
// lowering subset and must produce unsupported diagnostics.
module while_repeat_rejected (
  input  wire [7:0] a,
  input  wire [7:0] b,
  output reg  [7:0] y
);
  always @(*) begin
    y = a;
    while (y[0]) begin
      y = y >> 1;
    end
    repeat (2) begin
      y = y + b;
    end
  end
endmodule
