// Equivalence fixture: procedural for-loop edge cases.
module procedural_for_edges (
  input  wire [7:0] din,
  input  wire [7:0] mask,
  output reg  [7:0] down,
  output reg  [7:0] window,
  output reg  [7:0] nested
);
  integer i;
  integer j;

  always @(*) begin
    for (i = 7; i > 0; i = i - 1) begin
      down[i] = din[7 - i];
    end
    down[0] = din[7];

    window = 8'h00;
    for (i = 2; i < 6; i = i + 1) begin
      window[i] = din[i] ^ mask[i - 2];
    end
    window[1:0] = 2'b01;
    window[7:6] = 2'b10;

    nested = 8'h00;
    for (i = 0; i < 2; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        nested[(i * 4) + j] = din[(j * 2) + i];
      end
    end
  end
endmodule
