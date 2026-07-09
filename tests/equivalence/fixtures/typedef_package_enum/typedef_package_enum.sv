import enum_pkg::*;

module typedef_package_enum (
  input  logic [1:0] op_bits,
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic [7:0] y,
  output logic [1:0] op_seen
);
  op_t op;

  always_comb begin
    op = op_t'(op_bits);
    op_seen = op;
    case (op)
      OP_ADD: y = a + b;
      OP_XOR: y = a ^ b;
      OP_AND: y = a & b;
      default: y = 8'h00;
    endcase
  end
endmodule
