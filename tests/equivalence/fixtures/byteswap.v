// 32-bit byte-swap: pure combinational using part-select + concat.
module byteswap (
  input  wire [31:0] data_in,
  output wire [31:0] data_out
);
  assign data_out = {data_in[7:0], data_in[15:8], data_in[23:16], data_in[31:24]};
endmodule
