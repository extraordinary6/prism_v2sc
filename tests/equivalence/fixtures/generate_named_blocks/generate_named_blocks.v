// Conversion-only fixture: named generate blocks should elaborate to stable
// instance names in the generated header.
module gen_named_cell(input wire a, output wire y);
  assign y = ~a;
endmodule

module generate_named_blocks (
  input  wire [3:0] a,
  output wire [3:0] y
);
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : lane
      if ((i % 2) == 0) begin : even
        gen_named_cell u(.a(a[i]), .y(y[i]));
      end else begin : odd
        assign y[i] = a[i];
      end
    end
  endgenerate
endmodule
