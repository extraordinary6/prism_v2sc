// 8-bit ALU with separate always blocks per output signal (hardware coding style).
module alu (
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire [2:0] op,
  output reg  [7:0] result,
  output reg        zero,
  output reg        carry
);
  wire [8:0] add_full;
  assign add_full = {1'b0, a} + {1'b0, b};

  // result combinational logic: one always block driving 'result' only.
  always @(*) begin
    case (op)
      3'b000:  result = a + b;
      3'b001:  result = a - b;
      3'b010:  result = a & b;
      3'b011:  result = a | b;
      3'b100:  result = a ^ b;
      3'b101:  result = ~a;
      3'b110:  result = a << 1;
      3'b111:  result = a >> 1;
      default: result = 8'h00;
    endcase
  end

  // 'zero' flag: its own always block.
  always @(*) begin
    zero = (result == 8'h00);
  end

  // 'carry': its own always block; only meaningful for add op.
  always @(*) begin
    if (op == 3'b000) carry = add_full[8];
    else              carry = 1'b0;
  end
endmodule
