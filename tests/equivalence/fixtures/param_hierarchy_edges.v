// Equivalence fixture: multi-level parameter/localparam width propagation.
module param_leaf #(
  parameter WIDTH = 8,
  parameter LOW_W = 3
) (
  input  wire [WIDTH-1:0] a,
  input  wire [WIDTH-1:0] b,
  output wire [WIDTH:0]   sum,
  output wire [LOW_W-1:0] low_mix
);
  assign sum = {1'b0, a} + {1'b0, b};
  assign low_mix = a[LOW_W-1:0] ^ b[LOW_W-1:0];
endmodule

module param_mid #(
  parameter IN_W = 8,
  parameter LOW_W = 3
) (
  input  wire [IN_W-1:0] a,
  input  wire [IN_W-1:0] b,
  output wire [IN_W:0]   sum,
  output wire [LOW_W-1:0] low_mix
);
  localparam PASS_W = IN_W;

  param_leaf #(
    .WIDTH(PASS_W),
    .LOW_W(LOW_W)
  ) u_leaf (
    .a(a),
    .b(b),
    .sum(sum),
    .low_mix(low_mix)
  );
endmodule

module param_hierarchy_edges #(
  parameter BASE = 5
) (
  input  wire [BASE+2:0] a,
  input  wire [BASE+2:0] b,
  output wire [BASE+3:0] sum,
  output wire [2:0]      low_mix,
  output wire [7:0]      folded
);
  localparam CHILD_W = BASE + 3;
  localparam LOW_W = 3;

  wire [CHILD_W:0] leaf_sum;
  wire [LOW_W-1:0] leaf_low;

  param_mid #(
    .IN_W(CHILD_W),
    .LOW_W(LOW_W)
  ) u_mid (
    .a(a),
    .b(b),
    .sum(leaf_sum),
    .low_mix(leaf_low)
  );

  assign sum = leaf_sum;
  assign low_mix = leaf_low;
  assign folded = leaf_sum[7:0] ^ {5'b0, leaf_low};
endmodule
