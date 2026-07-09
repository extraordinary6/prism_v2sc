// Equivalence fixture: blocking assignments in one combinational process
// observe prior blocking writes in source order.
module blocking_comb_chain (
  input  wire [7:0] din,
  input  wire [7:0] mask,
  input  wire [1:0] mode,
  output reg  [7:0] y,
  output reg  [7:0] tap
);
  reg [7:0] stage;

  always @(*) begin
    stage = din;
    tap = stage ^ mask;
    if (mode[0]) begin
      stage = tap + 8'h03;
    end else begin
      stage = tap - 8'h01;
    end

    if (mode[1]) begin
      y = stage ^ din;
    end else begin
      stage[3:0] = mask[3:0];
      y = stage;
    end
  end
endmodule
