module e603_hand_mux_bit (
  input  D0, // select source 0   
  input  D1, // select source 1 
  input  S,  // select, 0 select D0, 1 select D1
  output X   // select output
);

 // below code should be replaced by lib cell for synthesis

`ifdef TECH_NUCLEI_DUMMY_STD_10T
    
   LVT_MUX2_X2 u_std_mux2 (.Z(X), .A(D0), .B(D1), .S(S));
`else
   assign X = S ?  D1 : D0;
`endif 

endmodule
