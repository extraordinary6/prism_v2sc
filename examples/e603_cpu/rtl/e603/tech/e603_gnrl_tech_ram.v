module e603_gnrl_tech_ram
#(
  parameter DP = 512,      // Depth
  parameter FORCE_X2ZERO=0,// Read data X force to 0
  parameter DW = 32,       // Data width
  parameter MW = 4,        // Mask width
  parameter AW = 32        // Addres width
)
(
  input             sd,    // shutdown mode
  input             ds,    // deep sleep mode
  input             ls,    // light sleep mode

  input             rst_n, // Reset
  input             clk,   // Clock
  input  [DW-1  :0] din,   // sram write data
  input  [AW-1  :0] addr,  // sram access address
  input             cs,    // sram chip select
  input             we,    // write enable
  input  [MW-1:0]   wem,   // write enable(mask)
  output [DW-1:0]   dout   // sram read data
);
  
  // synopsys dc_tcl_script_begin
  //    set xl_ram_cells [get_cells -hier -filter {is_macro_cell == true}]
  //    if {[sizeof_collection $xl_ram_cells] > 0} {
  //        foreach_in_collection xl_ram_macro $xl_ram_cells {
  //            set xl_ram_macro_name [get_attribute [current_design] full_name]/[get_attribute [get_cells $xl_ram_macro] full_name]
  //            puts "XL_INFO: setting cell_is_ram attribute on ram macro cell $xl_ram_macro_name."
  //            set_attribute [get_cells $xl_ram_macro] cell_is_ram true
  //        }
  //    }
  // synopsys dc_tcl_script_end

 // below code should be replaced by tech ram for synthesis

`ifdef TECH_NUCLEI_DUMMY_RAM
    
`ifdef TECH_NUCLEI_DUMMY_RAM_SPLIT
  `include "spram_macros_wrapper_splited.v"
`else
  `include "spram_macros_wrapper.v"
`endif
`else
e603_sim_ram #(
    .FORCE_X2ZERO (FORCE_X2ZERO),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW)
)u_ram (
    .clk   (clk),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);
`endif 

endmodule
