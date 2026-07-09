// Equivalence fixture: out-of-order non-overlapping part-select writes that
// assemble full vectors inside one combinational process.
module part_select_assembly (
  input  wire [3:0]  n0,
  input  wire [3:0]  n1,
  input  wire [3:0]  n2,
  input  wire [3:0]  n3,
  input  wire [15:0] lower,
  input  wire [15:0] upper,
  input  wire        flag,
  output reg  [15:0] assembled,
  output reg  [32:0] wide
);
  always @(*) begin
    assembled[7:4] = n1;
    assembled[15:12] = n3;
    assembled[3:0] = n0;
    assembled[11:8] = n2;

    wide[31:16] = upper;
    wide[0] = lower[0];
    wide[15:1] = lower[15:1];
    wide[32] = flag;
  end
endmodule
