 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
`include "global.v"
module e603_subsys_irq_alloc #(
  parameter  N600_EXTER_IRQ_NUM = 51
)(
  output [N600_EXTER_IRQ_NUM-1:0] irq_out,
  input  uart0_irq,                
  input  udma_irq,
  input  sdio_irq,
    input  misc_irq0,
    input  misc_irq1,
  input  qspi0_irq, 
  input  qspi1_irq,
  input  qspi2_irq,
  input  ethernet_irq,
  input  clk,
  input  rst_n
  );
  wire [51:0] irq;
  assign irq[0 ] = uart0_irq ;  
  assign irq[1 ] = udma_irq ;   
  assign irq[2 ] = qspi0_irq ;  
  assign irq[3 ] = qspi1_irq ;  
  assign irq[4 ] = qspi2_irq ;  
  assign irq[5 ] = misc_irq0 ; 
  assign irq[6 ] = misc_irq1 ; 
  assign irq[7 ] = ethernet_irq;
  assign irq[8 ] = sdio_irq ; 
  assign irq[9 ] = 1'b0 ; 
  assign irq[10] = 1'b0 ; 
  assign irq[11] = 1'b0 ; 
  assign irq[12] = 1'b0 ; 
  assign irq[13] = 1'b0 ; 
  assign irq[14] = 1'b0 ; 
  assign irq[15] = 1'b0 ; 
  assign irq[16] = 1'b0 ; 
  assign irq[17] = 1'b0 ; 
  assign irq[18] = 1'b0 ; 
  assign irq[19] = 1'b0 ; 
  assign irq[20] = 1'b0 ; 
  assign irq[21] = 1'b0 ; 
  assign irq[22] = 1'b0 ; 
  assign irq[23] = 1'b0 ; 
  assign irq[24] = 1'b0 ; 
  assign irq[25] = 1'b0 ; 
  assign irq[26] = 1'b0 ; 
  assign irq[27] = 1'b0 ; 
  assign irq[28] = 1'b0 ; 
  assign irq[29] = 1'b0 ; 
  assign irq[30] = 1'b0 ; 
  assign irq[31] = 1'b0 ; 
  assign irq[32] = uart0_irq  ;
  assign irq[33] = udma_irq  ;
  assign irq[34] = qspi0_irq  ;
  assign irq[35] = qspi1_irq  ;   
  assign irq[36] = qspi2_irq  ;   
  assign irq[37+0] = misc_irq0;   
  assign irq[37+1] = misc_irq1;   
  assign irq[51:37+2] = {52-37-2{1'b0}};
  generate if(N600_EXTER_IRQ_NUM<=52) begin: irq_lesseq52
  assign irq_out = irq[N600_EXTER_IRQ_NUM-1:0];
end
else begin: irq_gt52 
  assign irq_out = {{(N600_EXTER_IRQ_NUM-52){1'b0}}, irq};
end
endgenerate
endmodule
