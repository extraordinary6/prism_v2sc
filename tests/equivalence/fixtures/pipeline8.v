module stage8 (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       valid_i,
  input  wire [7:0] data_i,
  output reg        valid_o,
  output reg  [7:0] data_o
);
  wire [7:0] mixed;
  assign mixed = data_i ^ {8{valid_i}};

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_o <= 1'b0;
      data_o  <= 8'h00;
    end else begin
      valid_o <= valid_i;
      data_o  <= mixed;
    end
  end
endmodule

module pipeline8 (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       valid_i,
  input  wire [7:0] data_i,
  output wire       valid_o,
  output wire [7:0] data_o
);
  wire       mid_valid;
  wire [7:0] mid_data;

  stage8 u0 (
    .clk(clk), .rst_n(rst_n),
    .valid_i(valid_i), .data_i(data_i),
    .valid_o(mid_valid), .data_o(mid_data)
  );
  stage8 u1 (
    .clk(clk), .rst_n(rst_n),
    .valid_i(mid_valid), .data_i(mid_data),
    .valid_o(valid_o), .data_o(data_o)
  );
endmodule
