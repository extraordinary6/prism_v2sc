// Equivalence fixture: 8-entry register file backed by an unpacked array
// (``reg [7:0] mem [0:7]``).
//
// Before this iteration the unpacked dimension was silently dropped, the
// packed dimension fell back to ``bool``, and ``mem`` ended up as a
// single ``sc_signal<bool>`` — every read/write produced garbage. The
// new codegen lowers unpacked arrays to per-cell sc_signal arrays
// (``sc_signal<sc_uint<8>> mem[8];``), letting SystemC's delta-cycle
// semantics give us Verilog nonblocking behavior per cell.
//
// Reset branch zeros every cell explicitly so iverilog and SystemC start
// from the same state — without a procedural ``for`` loop we have to
// unroll, but that's still legal synthesizable RTL.
module regfile_mem (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        we,
  input  wire [2:0]  addr,
  input  wire [7:0]  din,
  output reg  [7:0]  dout
);
  reg [7:0] mem [0:7];
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem[0] <= 8'h00;
      mem[1] <= 8'h00;
      mem[2] <= 8'h00;
      mem[3] <= 8'h00;
      mem[4] <= 8'h00;
      mem[5] <= 8'h00;
      mem[6] <= 8'h00;
      mem[7] <= 8'h00;
      dout   <= 8'h00;
    end else begin
      if (we) mem[addr] <= din;
      dout <= mem[addr];
    end
  end
endmodule
