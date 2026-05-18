module task_function_seq (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       en,
  input  wire [3:0] a,
  input  wire [3:0] b,
  output reg  [3:0] y,
  output wire [3:0] fn_dbg
);
  function [3:0] blend;
    input [3:0] x;
    input [3:0] z;
    blend = (x ^ z) + 4'd1;
  endfunction

  task apply_mix;
    input [3:0] x;
    input [3:0] z;
    reg [3:0] mixed;
    mixed = blend(x, z);
  endtask

  assign fn_dbg = blend(a, b);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      y <= 4'h0;
    end else if (en) begin
      y <= blend(a, b);
    end
  end
endmodule
