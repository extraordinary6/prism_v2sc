// Equivalence fixture: procedural for loops inside always blocks.
//
// Exercises three common synthesizable patterns:
// 1. Bit-reverse via indexed assignment
// 2. Parity calculation via accumulation
// 3. Parametric zero-fill (simulates a clearing loop)
//
// All loops have constant bounds that slang can resolve at elaboration time.
// The lowerer should unroll them into sequential statements.
module procedural_for #(
  parameter WIDTH = 8
) (
  input  wire              clk,
  input  wire              rst_n,
  input  wire [WIDTH-1:0]  din,
  output reg  [WIDTH-1:0]  reversed,
  output reg               parity,
  output reg  [WIDTH-1:0]  cleared
);
  integer i;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reversed <= {WIDTH{1'b0}};
      parity   <= 1'b0;
      cleared  <= {WIDTH{1'b0}};
    end else begin
      // Pattern 1: bit-reverse
      for (i = 0; i < WIDTH; i = i + 1) begin
        reversed[i] <= din[WIDTH - 1 - i];
      end

      // Pattern 2: parity (XOR reduction)
      parity <= 1'b0;
      for (i = 0; i < WIDTH; i = i + 1) begin
        parity <= parity ^ din[i];
      end

      // Pattern 3: parametric clear (writes same value to all bits)
      for (i = 0; i < WIDTH; i = i + 1) begin
        cleared[i] <= 1'b0;
      end
    end
  end
endmodule
