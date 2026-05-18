// 8-bit ALU whose body is a Verilog function. Exercises function-lowering on
// both frontends: function definition, multi-parameter, case in body, call
// from an always_comb block.
module function_alu (
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire [2:0] op,
  output reg  [7:0] result
);
  function [7:0] do_op;
    input [2:0] op_in;
    input [7:0] x;
    input [7:0] z;
    begin
      case (op_in)
        3'b000:  do_op = x + z;
        3'b001:  do_op = x - z;
        3'b010:  do_op = x & z;
        3'b011:  do_op = x | z;
        3'b100:  do_op = x ^ z;
        3'b101:  do_op = ~x;
        3'b110:  do_op = x << 1;
        3'b111:  do_op = x >> 1;
        default: do_op = 8'h00;
      endcase
    end
  endfunction

  always @(*) begin
    result = do_op(op, a, b);
  end
endmodule
