// Diagnostic fixture: mutually dependent combinational always blocks require
// a loud scheduler-approximation warning.
module comb_process_order (
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       sel,
  output reg  [7:0] mid,
  output reg  [7:0] y
);
  always @(*) begin
    mid = sel ? a : y;
  end

  always @(*) begin
    y = mid ^ b;
  end
endmodule
