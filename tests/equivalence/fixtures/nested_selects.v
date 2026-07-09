// Equivalence fixture: nested ternary expressions and case defaults.
module nested_selects (
  input  wire [2:0] sel,
  input  wire [1:0] mode,
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire [7:0] c,
  input  wire [7:0] d,
  output wire [7:0] ternary_y,
  output reg  [7:0] case_y,
  output reg  [7:0] nested_case_y
);
  assign ternary_y = sel[2] ? (sel[1] ? a : b) : (sel[0] ? c : d);

  always @(*) begin
    case (mode)
      2'd0: case_y = a;
      2'd2: case_y = sel[0] ? b : c;
      default: case_y = d;
    endcase
  end

  always @(*) begin
    case (sel[1:0])
      2'b00: nested_case_y = a;
      2'b01: nested_case_y = b;
      default: nested_case_y = sel[2] ? c : d;
    endcase
  end
endmodule
