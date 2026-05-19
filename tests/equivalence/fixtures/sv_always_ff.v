// Equivalence fixture: SystemVerilog ``always_ff`` keyword.
// Same semantics as ``always @(posedge clk or negedge rst_n)`` for an
// async-reset register, but with the SV form.
module sv_always_ff (
  input  wire       clk,
  input  wire       rst_n,
  input  wire [7:0] d,
  output reg  [7:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= 8'h00;
    else        q <= d;
  end
endmodule
