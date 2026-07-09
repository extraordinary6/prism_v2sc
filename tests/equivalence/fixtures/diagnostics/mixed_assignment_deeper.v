// Diagnostic fixture: nested mixed blocking/nonblocking writes to the same
// slice must remain a loud error.
module mixed_assignment_deeper (
  input  wire clk,
  input  wire rst_n,
  input  wire sel,
  input  wire a,
  input  wire b,
  output reg  [3:0] q
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 4'h0;
    end else begin
      q[0] <= a;
      if (sel) begin
        q[0] = b;
      end
    end
  end
endmodule
