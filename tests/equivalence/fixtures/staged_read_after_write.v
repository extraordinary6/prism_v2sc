// Equivalence fixture: blocking read-after-write inside one combinational
// process should observe the just-written value.
module staged_read_after_write (
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       sel,
  output reg  [7:0] y,
  output reg  [7:0] tap
);
  reg [7:0] tmp;

  always @(*) begin
    tmp = a;
    if (sel) begin
      tmp = tmp + b;
    end else begin
      tmp = tmp ^ b;
    end
    y = tmp;
    tmp[3:0] = a[3:0];
    tap = tmp;
  end
endmodule
