module stage #(parameter WIDTH = 8) (
  input wire clk,
  input wire rst_n,
  input wire valid_i,
  input wire [WIDTH-1:0] data_i,
  output reg valid_o,
  output reg [WIDTH-1:0] data_o
);
  wire [WIDTH-1:0] mixed;
  assign mixed = data_i ^ {WIDTH{valid_i}};

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_o <= 1'b0;
      data_o <= {WIDTH{1'b0}};
    end else begin
      valid_o <= valid_i;
      data_o <= mixed;
    end
  end
endmodule

module pipeline_top #(parameter WIDTH = 8) (
  input wire clk,
  input wire rst_n,
  input wire valid_i,
  input wire [WIDTH-1:0] data_i,
  output wire valid_o,
  output wire [WIDTH-1:0] data_o
);
  wire mid_valid;
  wire [WIDTH-1:0] mid_data;

  stage #(.WIDTH(WIDTH)) u0(
    .clk(clk), .rst_n(rst_n), .valid_i(valid_i), .data_i(data_i),
    .valid_o(mid_valid), .data_o(mid_data)
  );
  stage #(.WIDTH(WIDTH)) u1(
    .clk(clk), .rst_n(rst_n), .valid_i(mid_valid), .data_i(mid_data),
    .valid_o(valid_o), .data_o(data_o)
  );
endmodule
