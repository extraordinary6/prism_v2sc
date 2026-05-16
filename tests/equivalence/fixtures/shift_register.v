// 8-bit shift register with parallel load and serial-in/out.
// One always block per stored signal (hardware coding style).
module shift_register (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       load,
  input  wire       shift_en,
  input  wire [7:0] parallel_in,
  input  wire       serial_in,
  output wire [7:0] data_out,
  output wire       serial_out
);
  reg [7:0] data_reg;

  // Sole always block driving 'data_reg'.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_reg <= 8'h00;
    end else if (load) begin
      data_reg <= parallel_in;
    end else if (shift_en) begin
      data_reg <= {data_reg[6:0], serial_in};
    end
  end

  assign data_out   = data_reg;
  assign serial_out = data_reg[7];
endmodule
