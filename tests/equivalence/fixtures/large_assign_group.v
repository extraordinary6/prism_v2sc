module large_assign_group (
  input  wire [7:0] a,
  output wire [7:0] y
);
  wire [7:0] stage [0:299];

  assign stage[0] = a;

  genvar index;
  generate
    for (index = 1; index < 300; index = index + 1) begin : gen_stage
      assign stage[index] = stage[index - 1];
    end
  endgenerate

  assign y = stage[299];
endmodule
