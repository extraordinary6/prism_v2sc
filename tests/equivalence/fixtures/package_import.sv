// Package definition with constants, typedef, and function
package math_pkg;
  typedef enum logic [1:0] {
    OP_ADD = 2'b00,
    OP_SUB = 2'b01,
    OP_AND = 2'b10,
    OP_OR  = 2'b11
  } op_t;

  function automatic logic [7:0] saturate(
    input logic [8:0] val
  );
    if (val[8])  // overflow
      return 8'd255;
    else
      return val[7:0];
  endfunction
endpackage

// Import at file scope for better iverilog compatibility
import math_pkg::*;

// Module using package import
module package_import (
  input  logic       clk,
  input  logic       rst_n,
  input  logic [7:0] a,
  input  logic [7:0] b,
  input  logic [1:0] op_sel,
  output logic [7:0] result
);
  logic [8:0] sum;
  op_t operation;

  assign operation = op_t'(op_sel);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      result <= '0;
    end else begin
      case (operation)
        OP_ADD: begin
          sum = {1'b0, a} + {1'b0, b};
          result <= saturate(sum);
        end
        OP_SUB: begin
          result <= (a > b) ? (a - b) : 8'b0;
        end
        OP_AND: begin
          result <= a & b;
        end
        OP_OR: begin
          result <= a | b;
        end
        default: result <= '0;
      endcase
    end
  end
endmodule
