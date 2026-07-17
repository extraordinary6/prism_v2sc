 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_mrom # (
    parameter AW = 12,
    parameter DW = 32,
    parameter DP = 1024
)(
  input  [AW-1:2] rom_addr, 
  output [DW-1:0] rom_dout  
  );
  wire [31:0] mask_rom [0:DP-1];
  assign rom_dout = mask_rom[rom_addr]; 
  genvar i;
  generate 
   if(1) begin: jump_to_ram_gen
		assign mask_rom[0] = 32'h00000297;      
		assign mask_rom[1] = 32'h02028593;      
		assign mask_rom[2] = 32'hf1402573;      
		assign mask_rom[3] = 32'h0182b283;      
		assign mask_rom[4] = 32'h00028067;      
		assign mask_rom[5] = 32'h00000000;      
		assign mask_rom[6] = 32'h80000000;      
		assign mask_rom[7] = 32'h00000000;      
		assign mask_rom[8] = 32'h00000000;      
		assign mask_rom[9] = 32'h00000000;      
      for (i=10;i<1024;i=i+1) begin: rom_gen
          if(i==0) begin: rom0_gen
              assign mask_rom[i] = 32'h7ffff297; 
          end
          else if(i==1) begin: rom1_gen
              assign mask_rom[i] = 32'h00028067; 
          end
          else begin: rom_non01_gen
              assign mask_rom[i] = 32'h00000000; 
          end
      end
   end
   else begin: jump_to_non_ram_gen
    for (i=0;i<1024;i=i+1) begin: rom_gen
        if(i==0) begin: rom0_gen
            assign mask_rom[i] = 32'h100006f;
        end
        else if(i==1) begin: rom1_gen
            assign mask_rom[i] = 32'h13;
        end
        else if(i==2) begin: rom1_gen
            assign mask_rom[i] = 32'h13;
        end
        else if(i==3) begin: rom1_gen
            assign mask_rom[i] = 32'h6661;
        end
        else if(i==4) begin: rom1_gen
            assign mask_rom[i] = 32'h20400000 | 32'h000002b7;
        end
        else if(i==5) begin: rom1_gen
            assign mask_rom[i] = 32'h28067;
        end
        else begin: rom_non01_gen
            assign mask_rom[i] = 32'h00000000; 
        end
    end
   end
  endgenerate
endmodule
