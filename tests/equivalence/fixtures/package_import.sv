// Package definition with constants and parameters
package math_pkg;
  // Operation codes as parameters (iverilog compatible)
  parameter logic [1:0] OP_ADD = 2'b00;
  parameter logic [1:0] OP_SUB = 2'b01;
  parameter logic [1:0] OP_AND = 2'b10;
  parameter logic [1:0] OP_OR  = 2'b11;

  // Saturation threshold
  parameter logic [7:0] SAT_MAX = 8'd255;
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
  // Import inside module for iverilog function resolution
  import math_pkg::*;

  logic [8:0] sum;
  logic [1:0] operation;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      result <= '0;
    end else begin
      case (op_sel)
        OP_ADD: begin
          sum = {1'b0, a} + {1'b0, b};
          result <= sum[8] ? SAT_MAX : sum[7:0];
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
