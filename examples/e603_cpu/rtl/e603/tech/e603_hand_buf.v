module e603_hand_buf (X, D);
  output X;
  input D;

 // below code should be replaced by lib cell for synthesis

`ifdef TECH_NUCLEI_DUMMY_STD_10T
    LVT_BUF_X4 u_std_buf (.Z(X), .A(D));
`else
  `ifdef FPGA_SOURCE
   assign X = D;
  `else
   wire t_n;
   assign t_n = ~D;
   assign X = ~t_n;
  `endif
`endif 


endmodule
