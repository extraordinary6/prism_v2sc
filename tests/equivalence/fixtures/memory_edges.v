// Equivalence fixture: unpacked memory read/write edge cases.
module memory_edges (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       we,
  input  wire [1:0] wr_addr,
  input  wire [1:0] rd_addr,
  input  wire [7:0] din,
  output reg  [7:0] rd_data,
  output reg  [7:0] wr_old,
  output reg  [7:0] rd_xor
);
  reg [7:0] mem [0:3];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem[0]  <= 8'h11;
      mem[1]  <= 8'h22;
      mem[2]  <= 8'h44;
      mem[3]  <= 8'h88;
      rd_data <= 8'h00;
      wr_old  <= 8'h00;
      rd_xor  <= 8'h00;
    end else begin
      if (we) begin
        mem[wr_addr] <= din;
      end
      rd_data <= mem[rd_addr];
      wr_old  <= mem[wr_addr];
      rd_xor  <= mem[rd_addr] ^ din;
    end
  end
endmodule
