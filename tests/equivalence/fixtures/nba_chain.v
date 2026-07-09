// Equivalence fixture: sequential nonblocking assignment chains must read
// pre-edge values. Earlier assignments in the same always block must not feed
// later RHS expressions through the generated __next_* temporaries.
module nba_chain (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       en,
  input  wire [7:0] din,
  input  wire [7:0] salt,
  output reg  [7:0] a,
  output reg  [7:0] b,
  output reg  [7:0] c,
  output reg  [7:0] mix
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      a   <= 8'h00;
      b   <= 8'h11;
      c   <= 8'h22;
      mix <= 8'h33;
    end else if (en) begin
      a   <= din;
      b   <= a ^ salt;
      c   <= b + 8'h01;
      mix <= a ^ b ^ c;
    end else begin
      a   <= a;
      b   <= b;
      c   <= c;
      mix <= mix + 8'h01;
    end
  end
endmodule
