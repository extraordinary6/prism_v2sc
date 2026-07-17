 /*                                                                      
  *  Copyright (c) 2018-2023 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */ 
`include "global.v"
module e603_icache_data_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [11-1:0] addr, 
  input              we,
  input  [8-1:0] wem,
  input  [64-1:0] din,          
  output [64-1:0] dout,
  input              rst_n,
  input              clk
);
  e603_gnrl_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(2048),
    .DW(64),
    .MW(8),
    .AW(11) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule
module e603_icache_tag_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [8-1:0] addr, 
  input              we,
  input  [3-1:0] wem,
  input  [22-1:0] din,          
  output [22-1:0] dout,
  input              rst_n,
  input              clk
);
  e603_gnrl_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(256),
    .DW(22),
    .MW(3),
    .AW(8) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule
module e603_data_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [10-1:0] addr, 
  input              we,
  input  [4-1:0] wem,
  input  [32-1:0] din,          
  output [32-1:0] dout,
  input              rst_n,
  input              clk
);
  e603_gnrl_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(1024),
    .DW(32),
    .MW(4),
    .AW(10) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule
module e603_dtag_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [8-1:0] addr, 
  input              we,
  input  [3-1:0] wem,
  input  [21-1:0] din,          
  output [21-1:0] dout,
  input              rst_n,
  input              clk
);
  e603_gnrl_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(256),
    .DW(21),
    .MW(3),
    .AW(8) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule
module e603_subsys_iram_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [13-1:0] addr, 
  input              we,
  input  [8-1:0] wem,
  input  [64-1:0] din,          
  output [64-1:0] dout,
  input              rst_n,
  input              clk
);
   e603_gnrl_sim_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(8192),
    .DW(64),
    .MW(8),
    .AW(13) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule
module e603_ilm_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [13-1:0] addr, 
  input              we,
  input  [8-1:0] wem,
  input  [64-1:0] din,          
  output [64-1:0] dout,
  input              rst_n,
  input              clk
);
  e603_gnrl_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(8192),
    .DW(64),
    .MW(8),
    .AW(13) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule
module e603_subsys_dram_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [13-1:0] addr, 
  input              we,
  input  [8-1:0] wem,
  input  [64-1:0] din,          
  output [64-1:0] dout,
  input              rst_n,
  input              clk
);
   e603_gnrl_sim_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(8192),
    .DW(64),
    .MW(8),
    .AW(13) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule
module e603_dlm_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [13-1:0] addr, 
  input              we,
  input  [4-1:0] wem,
  input  [32-1:0] din,          
  output [32-1:0] dout,
  input              rst_n,
  input              clk
);
  e603_gnrl_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(8192),
    .DW(32),
    .MW(4),
    .AW(13) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule
module e603_tlb_tag_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [7-1:0] addr, 
  input              we,
  input  [5-1:0] wem,
  input  [40-1:0] din,          
  output [40-1:0] dout,
  input              rst_n,
  input              clk
);
  e603_gnrl_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(128),
    .DW(40),
    .MW(5),
    .AW(7) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule
module e603_tlb_data_ram(
  input              sd,
  input              ds,
  input              ls,
  input              cs,  
  input  [7-1:0] addr, 
  input              we,
  input  [4-1:0] wem,
  input  [27-1:0] din,          
  output [27-1:0] dout,
  input              rst_n,
  input              clk
);
  e603_gnrl_ram
  #(
    .FORCE_X2ZERO(0),
    .GATE_CLK(0),
    .DP(128),
    .DW(27),
    .MW(4),
    .AW(7) 
  ) u_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),
  .clkgate_bypass  (1'b0         ),
  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .we  (we),
  .dout(dout)
  );
endmodule

module e603_gnrl_ram
#(parameter DP = 32,
  parameter DW = 32,
  parameter FORCE_X2ZERO = 0,
  parameter GATE_CLK = 1,
  parameter MW = 4,
  parameter AW = 15
  ) (
  input            sd,
  input            ds,
  input            ls,

  input            rst_n,
  input            clk,
  input            clkgate_bypass,
  input            cs,
  input            we,
  input [AW-1:0]   addr,
  input [DW-1:0]   din,
  input [MW-1:0]   wem,
  output[DW-1:0]   dout
);

  wire clk_cg;
  generate
  if (GATE_CLK == 1)
  begin : gen_cg
  e603_clkgate u_clk_clkgate(
    .clk_in   (clk),
    .clkgate_bypass(clkgate_bypass  ),
    .clock_en (cs),
    .clk_out  (clk_cg )
  );
  end else begin : gen_non_cg
    assign clk_cg = clk;
  end
  endgenerate

`ifdef FPGA_SOURCE
// This is the Sim-model

e603_sim_ram #(
    .FORCE_X2ZERO (FORCE_X2ZERO),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW)
)u_ram (
    .clk   (clk_cg),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);

`else

  `ifdef SYNTHESIS
// Tech Specific rams

e603_gnrl_tech_ram #(
    .FORCE_X2ZERO (FORCE_X2ZERO),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW)
)u_ram (
    .rst_n (rst_n),
    .sd    (sd),
    .ds    (ds),
    .ls    (ls),
    .clk   (clk_cg),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);

  `else

// This is the Sim-model

e603_sim_ram #(
    .FORCE_X2ZERO (FORCE_X2ZERO),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW)
)u_ram (
    .clk   (clk_cg),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);

  `endif
`endif

    `ifndef FPGA_SOURCE
    `ifdef ASSERT_ON
    //synopsys translate_off
    CHECKER_THE_X_CLK_RST_N_CS :
    assert property(@(posedge clk) disable iff (rst_n !== 1'b1)
                (!$isunknown({cs}))
                )
    else $fatal ("Error: Oops, detected a X value for cs signal!!! This should never happen.");
    //synopsys translate_on
    `endif
    `endif
    
// din can't check because partial write, some bit will x 

    `ifndef FPGA_SOURCE
    `ifdef ASSERT_ON
    //synopsys translate_off
    CHECKER_THE_ASSERT_CLK_RST_N_CSISUNKNOWNWEWEMADDR :
    assert property(@(posedge clk) disable iff (rst_n !== 1'b1)
                (cs |-> !$isunknown({we,wem,addr}))
                )
    else $fatal ("Error: Oops, detected a non-match for cs |-> !$isunknown({we,wem,addr}) signal!!! This should never happen.");
    //synopsys translate_on
    `endif
    `endif
    
endmodule


module e603_gnrl_sim_ram
#(parameter DP = 32,
  parameter DW = 32,
  parameter FORCE_X2ZERO = 0,
  parameter GATE_CLK = 1,
  parameter MW = 4,
  parameter AW = 15
  ) (
  input            sd,
  input            ds,
  input            ls,

  input            rst_n,
  input            clk,
  input            clkgate_bypass,
  input            cs,
  input            we,
  input [AW-1:0]   addr,
  input [DW-1:0]   din,
  input [MW-1:0]   wem,
  output[DW-1:0]   dout
);

  wire clk_cg;
  generate
  if (GATE_CLK == 1)
  begin : gen_cg
  e603_clkgate u_clk_clkgate(
    .clk_in   (clk),
    .clkgate_bypass(clkgate_bypass  ),
    .clock_en (cs),
    .clk_out  (clk_cg )
  );
  end else begin : gen_non_cg
    assign clk_cg = clk;
  end
  endgenerate

// This is the Sim-model

e603_sim_ram #(
    .FORCE_X2ZERO (FORCE_X2ZERO),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW)
)u_ram (
    .clk   (clk_cg),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);
endmodule



module e603_gnrl_ram_bit_en
#(parameter DP = 32,
  parameter DW = 32,
  parameter FORCE_X2ZERO = 1,
  parameter MW = 32,
  parameter AW = 15 
  ) (
  input            sd,
  input            ds,
  input            ls,

  input            rst_n,
  input            clk,
  input            cs,
  input [AW-1:0]   addr,
  input [DW-1:0]   din,
  input            wem,
  output[DW-1:0]   dout
);

  wire[DW-1:0]   dout_pre;

e603_sim_ram_bit_en #(
    .FORCE_X2ZERO (FORCE_X2ZERO),
    .DP (DP),
    .AW (AW),
    .DW (DW) 
)u_sim_ram_bit_en (
    .clk   (clk),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .wem   (wem),
    .dout  (dout_pre)
);

    `ifndef FPGA_SOURCE
      // randomize the dout, let one bit turn over, that can trigger ecc to error recovery
      integer random_1;
      reg [DW-1:0] dout_mask1;
      initial begin
        dout_mask1 = {DW{1'b0}};
      end
      always @(posedge clk) begin
          random_1 = $urandom_range(0,1);
          if(cs) begin
              dout_mask1 <= ( {{DW-1{1'b0}}, random_1[0] } << $urandom_range(1,DW-1) );
          end
      end
    `else
      wire [DW-1:0] dout_mask1 = {DW{1'h0}};
    `endif
    
    assign dout = dout_pre;
endmodule

module e603_sim_ram
#(parameter DP = 512,
  parameter FORCE_X2ZERO = 0,
  parameter DW = 32,
  parameter MW = 4,
  parameter AW = 32
)
(
  input             clk,
  input  [DW-1  :0] din,
  input  [AW-1  :0] addr,
  input             cs,
  input             we,
  input  [MW-1:0]   wem,
  output [DW-1:0]   dout
);
  localparam WBITS = (MW == ((DW-1) / 8) + 1) ? 8 :
                     (MW == DW) ? 1 :
                     (MW == 1) ? DW : 0;
    reg [MW*WBITS-1:0] mem_r [0:DP-1];
    reg [AW-1:0] addr_r;
    wire [MW-1:0] wen;
    wire ren;
    assign ren = cs & (~we);
    assign wen = ({MW{cs & we}} & wem);
    wire [MW*WBITS-1:0] i_din;
    generate
      if(DW == (MW*WBITS)) begin:dw_eq_mw
          assign i_din = din;
      end
      else begin: dw_ne_mw
          assign i_din = {{(MW*WBITS-DW){1'b0}},din};
      end
    endgenerate
    genvar i;
    always @(posedge clk)
    begin
        if (ren) begin
            addr_r <= addr;
        end
        else if((|wen)) begin
        `ifndef SYNTHESIS
          `ifdef SRAM_WRITE_OUTX
            addr_r <= {AW{1'bx}}; 
          `else
            addr_r <= (~addr >= DP[AW-1 :0]) ? (DP[AW-1 :0] - addr - 1'b1)  : ~addr; 
          `endif
        `else
            addr_r <= (~addr >= DP[AW-1 :0]) ? (DP[AW-1 :0] - addr - 1'b1)  : ~addr; 
        `endif
        end
    end
    generate
      for (i = 0; i < MW; i = i+1) begin :mem
          always @(posedge clk) begin
            if (wen[i]) begin
               mem_r[addr][WBITS*i+WBITS-1:WBITS*i] <= i_din[WBITS*i+WBITS-1:WBITS*i];
            end
          end
      end
    endgenerate
  wire [MW*WBITS-1:0] dout_pre;
  assign dout_pre = mem_r[addr_r];
  generate
   if(FORCE_X2ZERO == 1) begin: force_x_to_zero
      for (i = 0; i < DW; i = i+1) begin:force_x_gen
          `ifndef SYNTHESIS
         assign dout[i] = (dout_pre[i] === 1'bx) ? 1'b0 : dout_pre[i];
          `else
         assign dout[i] = dout_pre[i];
          `endif
      end
   end
   else begin:no_force_x_to_zero
     assign dout = dout_pre[DW-1:0];
   end
  endgenerate
endmodule

module e603_sim_dpram
#(parameter DP = 512,
  parameter FORCE_X2ZERO = 0,
  parameter DW = 32,
  parameter MW = DW,
  parameter AW = 32
)
(
  input           wclk,
  input           wcs,
  input  [MW-1:0] wmask,
  input  [DW-1:0] wdin,
  input  [AW-1:0] waddr,
  input           rclk,
  input           rcs,
  output [DW-1:0] rdout,
  input  [AW-1:0] raddr
);
  localparam FORCE_X2ZERO_REAL = FORCE_X2ZERO;
  localparam WBITS = (MW == ((DW-1) / 8) + 1) ? 8 :
                     (MW == DW) ? 1 :
                     (MW == 1) ? DW : 0;
    reg [MW*WBITS-1:0] mem_r [0:DP-1];
    reg [AW-1:0] addr_r;
    wire [MW-1:0] wen;
    wire ren;
    assign ren = rcs;
    assign wen = ({MW{wcs}} & wmask);
    wire [MW*WBITS-1:0] i_din;
    generate
      if(DW == (MW*WBITS)) begin:dw_eq_mw
          assign i_din = wdin;
      end
      else begin: dw_ne_mw
          assign i_din = {{(MW*WBITS-DW){1'b0}},wdin};
      end
    endgenerate
    genvar i;
    always @(posedge rclk)
    begin
        if (ren) begin
            addr_r <= raddr;
        end
    end
    generate
      for (i = 0; i < MW; i = i+1) begin :mem
          always @(posedge wclk) begin
            if (wen[i]) begin
               mem_r[waddr][WBITS*i+WBITS-1:WBITS*i] <= i_din[WBITS*i+WBITS-1:WBITS*i];
            end
          end
      end
    endgenerate
  wire [MW*WBITS-1:0] dout_pre;
  assign dout_pre = mem_r[addr_r];
  generate
   if(FORCE_X2ZERO_REAL == 1) begin: force_x_to_zero
      for (i = 0; i < DW; i = i+1) begin:force_x_gen
          `ifndef SYNTHESIS
         assign rdout[i] = (dout_pre[i] === 1'bx) ? 1'b0 : dout_pre[i];
          `else
         assign rdout[i] = dout_pre[i];
          `endif
      end
   end
   else begin:no_force_x_to_zero
     assign rdout = dout_pre[DW-1:0];
   end
  endgenerate
endmodule
module e603_nice2lsu_wconv_wconv_x2y_rspid_fifo (
  input           i_vld, 
  output          i_rdy, 
  input  [1-1:0] i_dat,
  output          o_vld, 
  input           o_rdy, 
  output [1-1:0] o_dat,
  input           clk,
  input           rst_n
);
    wire [1-1:0] fifo_rf_din [9-1:0];
    wire [1-1:0] fifo_rf_r [9-1:0];
    wire [9-1:0] fifo_rf_en;
    wire wen = i_vld & i_rdy;
    wire ren = o_vld & o_rdy;
    wire [9-1:0] rptr_vec_din; 
    wire [9-1:0] rptr_vec_nxt; 
    wire [9-1:0] rptr_vec_r;
    wire [9-1:0] wptr_vec_nxt; 
    wire [9-1:0] wptr_vec_r;
      assign rptr_vec_nxt = 
          rptr_vec_r[9-1] ? {{9-1{1'b0}}, 1'b1} :
                          (rptr_vec_r << 1);
      assign wptr_vec_nxt =
          wptr_vec_r[9-1] ? {{9-1{1'b0}}, 1'b1} :
                          (wptr_vec_r << 1);
e603_gnrl_dfflrs #(1)    rptr_vec_0_dfflrs  (ren, rptr_vec_nxt[0]     , rptr_vec_r[0]     , clk, rst_n);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1)    wptr_vec_0_dfflrs  (wen, wptr_vec_nxt[0]     , wptr_vec_r[0]     , clk, rst_n);// VPP_NO_REG_PARSE
e603_gnrl_dfflr  #(8) rptr_vec_31_dfflr  (ren, rptr_vec_nxt[8:1], rptr_vec_r[8:1], clk, rst_n);// VPP_NO_REG_PARSE
e603_gnrl_dfflr  #(8) wptr_vec_31_dfflr  (wen, wptr_vec_nxt[8:1], wptr_vec_r[8:1], clk, rst_n);// VPP_NO_REG_PARSE
    assign rptr_vec_din = ren ? rptr_vec_nxt : rptr_vec_r;
    wire [9-1:0] i_vec;
    wire [9-1:0] o_vec;
    wire [9-1:0] vec_nxt; 
    wire [9-1:0] vec_r;
    wire vec_en = (ren ^ wen );
e603_gnrl_dfflr  #(9) vec_dfflr     (vec_en, vec_nxt, vec_r,     clk, rst_n);// VPP_NO_REG_PARSE
    assign i_vec = vec_r;
    assign o_vec = vec_r;
      assign vec_nxt = wen ? {vec_r[9-2:0], 1'b1} : (vec_r >> 1);  
      assign i_rdy = (~i_vec[9-1]);
      assign fifo_rf_en[0] = wen & wptr_vec_r[0];
e603_gnrl_dffl  #(1) fifo_rf_0_dffl (fifo_rf_en[0], i_dat, fifo_rf_r[0], clk, rst_n);// VPP_NO_REG_PARSE
      assign fifo_rf_din[0] = fifo_rf_en[0] ? i_dat : fifo_rf_r[0];
      assign fifo_rf_en[1] = wen & wptr_vec_r[1];
e603_gnrl_dffl  #(1) fifo_rf_1_dffl (fifo_rf_en[1], i_dat, fifo_rf_r[1], clk, rst_n);// VPP_NO_REG_PARSE
      assign fifo_rf_din[1] = fifo_rf_en[1] ? i_dat : fifo_rf_r[1];
      assign fifo_rf_en[2] = wen & wptr_vec_r[2];
e603_gnrl_dffl  #(1) fifo_rf_2_dffl (fifo_rf_en[2], i_dat, fifo_rf_r[2], clk, rst_n);// VPP_NO_REG_PARSE
      assign fifo_rf_din[2] = fifo_rf_en[2] ? i_dat : fifo_rf_r[2];
      assign fifo_rf_en[3] = wen & wptr_vec_r[3];
e603_gnrl_dffl  #(1) fifo_rf_3_dffl (fifo_rf_en[3], i_dat, fifo_rf_r[3], clk, rst_n);// VPP_NO_REG_PARSE
      assign fifo_rf_din[3] = fifo_rf_en[3] ? i_dat : fifo_rf_r[3];
      assign fifo_rf_en[4] = wen & wptr_vec_r[4];
e603_gnrl_dffl  #(1) fifo_rf_4_dffl (fifo_rf_en[4], i_dat, fifo_rf_r[4], clk, rst_n);// VPP_NO_REG_PARSE
      assign fifo_rf_din[4] = fifo_rf_en[4] ? i_dat : fifo_rf_r[4];
      assign fifo_rf_en[5] = wen & wptr_vec_r[5];
e603_gnrl_dffl  #(1) fifo_rf_5_dffl (fifo_rf_en[5], i_dat, fifo_rf_r[5], clk, rst_n);// VPP_NO_REG_PARSE
      assign fifo_rf_din[5] = fifo_rf_en[5] ? i_dat : fifo_rf_r[5];
      assign fifo_rf_en[6] = wen & wptr_vec_r[6];
e603_gnrl_dffl  #(1) fifo_rf_6_dffl (fifo_rf_en[6], i_dat, fifo_rf_r[6], clk, rst_n);// VPP_NO_REG_PARSE
      assign fifo_rf_din[6] = fifo_rf_en[6] ? i_dat : fifo_rf_r[6];
      assign fifo_rf_en[7] = wen & wptr_vec_r[7];
e603_gnrl_dffl  #(1) fifo_rf_7_dffl (fifo_rf_en[7], i_dat, fifo_rf_r[7], clk, rst_n);// VPP_NO_REG_PARSE
      assign fifo_rf_din[7] = fifo_rf_en[7] ? i_dat : fifo_rf_r[7];
      assign fifo_rf_en[8] = wen & wptr_vec_r[8];
e603_gnrl_dffl  #(1) fifo_rf_8_dffl (fifo_rf_en[8], i_dat, fifo_rf_r[8], clk, rst_n);// VPP_NO_REG_PARSE
      assign fifo_rf_din[8] = fifo_rf_en[8] ? i_dat : fifo_rf_r[8];
    integer j;
    wire [1-1:0] mux_rdat;
        reg [1-1:0] mux_rdat_din;
        always @*
        begin : rd_port_PROC
          mux_rdat_din = {1{1'b0}};
          for(j=0; j<9; j=j+1) begin
            mux_rdat_din = mux_rdat_din | ({1{rptr_vec_din[j]}} & fifo_rf_din[j]);
          end
        end
        wire mux_rdat_ena = 
                     (~o_vld) ? wen :
                     (vec_nxt[0] & ren);
e603_gnrl_dfflr #(1) mux_rdat_dfflr  (mux_rdat_ena, mux_rdat_din, mux_rdat, clk, rst_n);// VPP_NO_REG_PARSE
        assign o_dat = mux_rdat;
    assign o_vld = (o_vec[0]);
endmodule
module e603_nice2lsu_wconv_wconv_x2y
(
  input              i_icb_cmd_sel,
  input              i_icb_cmd_valid,
  output             i_icb_cmd_ready,
  input              i_icb_cmd_read,
  input  [32-1:0]    i_icb_cmd_addr,
  input  [64-1:0]   i_icb_cmd_wdata,
  input  [(64/8-1):0] i_icb_cmd_wmask,
  input              i_icb_cmd_lock,
  input              i_icb_cmd_excl,
  input  [2:0]       i_icb_cmd_size,
  input  [1:0]       i_icb_cmd_beat,
  input  [2-1:0] i_icb_cmd_usr,
  input  [7:0]       i_icb_cmd_xlen,
  input  [1:0]       i_icb_cmd_xburst,
  input  [1:0]       i_icb_cmd_modes,
  input              i_icb_cmd_dmode,
  input  [2:0]       i_icb_cmd_attri,
  output             i_icb_rsp_valid,
  input              i_icb_rsp_ready,
  output             i_icb_rsp_err,
  output             i_icb_rsp_excl_ok,
  output [64-1:0]   i_icb_rsp_rdata,
  output [1-1:0] i_icb_rsp_usr,
  output             o_icb_cmd_sel,
  output             o_icb_cmd_valid,
  input              o_icb_cmd_ready,
  output             o_icb_cmd_read,
  output [32-1:0]    o_icb_cmd_addr,
  output [64-1:0]   o_icb_cmd_wdata,
  output [(64/8-1):0] o_icb_cmd_wmask,
  output             o_icb_cmd_lock,
  output             o_icb_cmd_excl,
  output [2:0]       o_icb_cmd_size,
  output [1:0]       o_icb_cmd_beat,
  output [2-1:0] o_icb_cmd_usr,
  output [7:0]       o_icb_cmd_xlen,
  output [1:0]       o_icb_cmd_xburst,
  output [1:0]       o_icb_cmd_modes,
  output             o_icb_cmd_dmode,
  output [2:0]       o_icb_cmd_attri,
  input              o_icb_rsp_valid,
  output             o_icb_rsp_ready,
  input              o_icb_rsp_err,
  input              o_icb_rsp_excl_ok,
  input  [64-1:0]   o_icb_rsp_rdata,
  input  [1-1:0] o_icb_rsp_usr,
  input  clk,
  input  rst_n
  );
    wire rspid_fifo_i_ready;
    wire rspid_fifo_o_valid;
    assign rspid_fifo_i_ready = 1'b1;
    assign rspid_fifo_o_valid = 1'b1;
        assign o_icb_cmd_sel   = i_icb_cmd_sel;
        assign i_icb_cmd_ready = rspid_fifo_i_ready & o_icb_cmd_ready;
        assign o_icb_cmd_valid = rspid_fifo_i_ready & i_icb_cmd_valid;
        assign o_icb_cmd_read  = i_icb_cmd_read ;
        assign o_icb_cmd_addr  = i_icb_cmd_addr ;
        assign o_icb_cmd_wdata = i_icb_cmd_wdata;
        assign o_icb_cmd_wmask = i_icb_cmd_wmask;
        assign o_icb_cmd_beat  = i_icb_cmd_beat ;
        assign o_icb_cmd_lock  = i_icb_cmd_lock ;
        assign o_icb_cmd_excl  = i_icb_cmd_excl ;
        assign o_icb_cmd_size  = i_icb_cmd_size ;
        assign o_icb_cmd_usr   = i_icb_cmd_usr  ;
        assign o_icb_cmd_xlen  = i_icb_cmd_xlen  ;
        assign o_icb_cmd_xburst= i_icb_cmd_xburst;
        assign o_icb_cmd_modes = i_icb_cmd_modes ;
        assign o_icb_cmd_dmode = i_icb_cmd_dmode ;
        assign o_icb_cmd_attri = i_icb_cmd_attri ;
        assign o_icb_rsp_ready     = rspid_fifo_o_valid & i_icb_rsp_ready;
        assign i_icb_rsp_valid     = rspid_fifo_o_valid & o_icb_rsp_valid;
        assign i_icb_rsp_err       = o_icb_rsp_err  ;
        assign i_icb_rsp_excl_ok   = o_icb_rsp_excl_ok  ;
        assign i_icb_rsp_rdata     = o_icb_rsp_rdata;
        assign i_icb_rsp_usr       = o_icb_rsp_usr;
endmodule
module e603_nice2lsu_wconv
(
  input              i_icb_cmd_sel,
  input              i_icb_cmd_valid,
  output             i_icb_cmd_ready,
  input              i_icb_cmd_read,
  input  [32-1:0]    i_icb_cmd_addr,
  input  [64-1:0]   i_icb_cmd_wdata,
  input  [(64/8-1):0] i_icb_cmd_wmask,
  input              i_icb_cmd_lock,
  input              i_icb_cmd_excl,
  input  [2:0]       i_icb_cmd_size,
  input  [1:0]       i_icb_cmd_beat,
  input  [2-1:0] i_icb_cmd_usr,
  input  [7:0]       i_icb_cmd_xlen,
  input  [1:0]       i_icb_cmd_xburst,
  input  [1:0]       i_icb_cmd_modes,
  input              i_icb_cmd_dmode,
  input  [2:0]       i_icb_cmd_attri,
  output             i_icb_rsp_valid,
  input              i_icb_rsp_ready,
  output             i_icb_rsp_err,
  output             i_icb_rsp_excl_ok,
  output [64-1:0]   i_icb_rsp_rdata,
  output [1-1:0] i_icb_rsp_usr,
  output             o_icb_cmd_sel,
  output             o_icb_cmd_valid,
  input              o_icb_cmd_ready,
  output             o_icb_cmd_read,
  output [32-1:0]    o_icb_cmd_addr,
  output [64-1:0]   o_icb_cmd_wdata,
  output [(64/8-1):0] o_icb_cmd_wmask,
  output             o_icb_cmd_lock,
  output             o_icb_cmd_excl,
  output [2:0]       o_icb_cmd_size,
  output [1:0]       o_icb_cmd_beat,
  output [2-1:0] o_icb_cmd_usr,
  output [7:0]       o_icb_cmd_xlen,
  output [1:0]       o_icb_cmd_xburst,
  output [1:0]       o_icb_cmd_modes,
  output             o_icb_cmd_dmode,
  output [2:0]       o_icb_cmd_attri,
  input              o_icb_rsp_valid,
  output             o_icb_rsp_ready,
  input              o_icb_rsp_err,
  input              o_icb_rsp_excl_ok,
  input  [64-1:0]   o_icb_rsp_rdata,
  input  [1-1:0] o_icb_rsp_usr,
  input  clk,
  input  rst_n
  );
  wire i_icb_rsp_eccerr_pre;
  e603_nice2lsu_wconv_wconv_x2y
u_wconv_x2y (
    .clk                    (clk  ),
    .rst_n                  (rst_n),
    .i_icb_cmd_valid        (i_icb_cmd_valid   ),
    .i_icb_cmd_ready        (i_icb_cmd_ready   ),
    .i_icb_cmd_sel          (i_icb_cmd_sel     ),
    .i_icb_cmd_read         (i_icb_cmd_read    ),
    .i_icb_cmd_addr         (i_icb_cmd_addr    ),
    .i_icb_cmd_wdata        (i_icb_cmd_wdata   ),
    .i_icb_cmd_wmask        (i_icb_cmd_wmask   ),
    .i_icb_cmd_lock         (i_icb_cmd_lock    ),
    .i_icb_cmd_excl         (i_icb_cmd_excl    ),
    .i_icb_cmd_size         (i_icb_cmd_size    ),
    .i_icb_cmd_beat         (i_icb_cmd_beat    ),
    .i_icb_cmd_usr          (i_icb_cmd_usr     ),
    .i_icb_cmd_xburst       (i_icb_cmd_xburst  ),
    .i_icb_cmd_xlen         (i_icb_cmd_xlen    ),
    .i_icb_cmd_modes        (i_icb_cmd_modes   ),
    .i_icb_cmd_dmode        (i_icb_cmd_dmode   ),
    .i_icb_cmd_attri        (i_icb_cmd_attri   ),
    .i_icb_rsp_valid        (i_icb_rsp_valid   ),
    .i_icb_rsp_ready        (i_icb_rsp_ready   ),
    .i_icb_rsp_err          (i_icb_rsp_err     ),
    .i_icb_rsp_excl_ok      (i_icb_rsp_excl_ok ),
    .i_icb_rsp_rdata        (i_icb_rsp_rdata   ),
    .i_icb_rsp_usr          (i_icb_rsp_usr     ),
    .o_icb_cmd_sel          (o_icb_cmd_sel     ),
    .o_icb_cmd_valid        (o_icb_cmd_valid   ),
    .o_icb_cmd_ready        (o_icb_cmd_ready   ),
    .o_icb_cmd_read         (o_icb_cmd_read    ),
    .o_icb_cmd_addr         (o_icb_cmd_addr    ),
    .o_icb_cmd_wdata        (o_icb_cmd_wdata   ),
    .o_icb_cmd_wmask        (o_icb_cmd_wmask   ),
    .o_icb_cmd_lock         (o_icb_cmd_lock    ),
    .o_icb_cmd_excl         (o_icb_cmd_excl    ),
    .o_icb_cmd_size         (o_icb_cmd_size    ),
    .o_icb_cmd_beat         (o_icb_cmd_beat    ),
    .o_icb_cmd_usr          (o_icb_cmd_usr     ),
    .o_icb_cmd_xburst       (o_icb_cmd_xburst  ),
    .o_icb_cmd_xlen         (o_icb_cmd_xlen    ),
    .o_icb_cmd_modes        (o_icb_cmd_modes   ),
    .o_icb_cmd_dmode        (o_icb_cmd_dmode   ),
    .o_icb_cmd_attri        (o_icb_cmd_attri   ),
    .o_icb_rsp_valid        (o_icb_rsp_valid   ),
    .o_icb_rsp_ready        (o_icb_rsp_ready   ),
    .o_icb_rsp_err          (o_icb_rsp_err     ),
    .o_icb_rsp_excl_ok      (o_icb_rsp_excl_ok ),
    .o_icb_rsp_rdata        (o_icb_rsp_rdata   ),
    .o_icb_rsp_usr          (o_icb_rsp_usr     )
  );
endmodule
