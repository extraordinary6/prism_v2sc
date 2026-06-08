// Wide mux feeding register - mux switching power
module wide_mux_reg(
  input wire clk,
  input wire [1:0] sel,
  input wire [31:0] data_a,
  input wire [31:0] data_b,
  input wire [31:0] data_c,
  input wire [31:0] data_d,
  output reg [31:0] result
);
  always @(posedge clk) begin
    case (sel)
      2'd0: result <= data_a;
      2'd1: result <= data_b;
      2'd2: result <= data_c;
      2'd3: result <= data_d;
    endcase
  end
endmodule
