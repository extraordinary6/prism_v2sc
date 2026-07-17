module e603_gnrl_tech_clkgate (
  input   clk_in,          // clock input
  input   clkgate_bypass,  // clock bypass, if 1 the output clk is not gated
  input   clock_en,        // clock enable, if 0 the outptu clk is 0
  output  clk_out          // output clock
);
  // below code should be replaced by lib cell for synthesis

`ifdef TECH_NUCLEI_DUMMY_STD_10T
  LVT_CLKGATETST_X4 u_std_cg (.GCK(clk_out), .CK(clk_in), .E(clock_en), .SE(clkgate_bypass));
`else

  `ifdef FPGA_SOURCE
      
    assign clk_out = clk_in;
  `else
    reg enb;
    always@(*)
    if (!clk_in)
       enb <= (clock_en | clkgate_bypass);

    assign clk_out = enb & clk_in;
  `endif
`endif 


endmodule
