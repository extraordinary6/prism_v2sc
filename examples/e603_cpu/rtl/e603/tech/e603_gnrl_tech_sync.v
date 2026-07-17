//=====================================================================
//
//--  #     # #     #  #####  #       #######   ###
//--  ##    # #     # #     # #       #          #
//--  # #   # #     # #       #       #          #
//--  #  #  # #     # #       #       #####      #
//--  #   # # #     # #       #       #          #
//--  #    ## #     # #     # #       #          #
//--  #     #  #####   #####  ####### #######   ###
//
//=====================================================================
//
// Designer: CP
//
// Description:
//  The gnrl tech sync
//
//====================================================================
`include "global.v"

module e603_gnrl_tech_sync # (
  parameter DP = 2,
  parameter DW = 32,
  parameter RST_VAL = {DW{1'b0}}
) (
  input  [DW-1:0] din_a,
  output [DW-1:0] dout,

  input           rst_n,
  input           clk
);
`ifdef TECH_SMIC14SFP_9T
    // Generate tech specific sync
  wire [DW-1:0] sync_dat [DP-1:0];

  genvar i;

  generate
    for(i=0;i<DP;i=i+1) begin:gen_sync
      if(i==0) begin:gen_i_is_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(din_a,         sync_dat[0], clk, rst_n);
      end
      else begin:gen_i_is_not_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(sync_dat[i-1], sync_dat[i], clk, rst_n);
      end
    end
  endgenerate

  assign dout = sync_dat[DP-1];

`endif
`ifdef TECH_SMIC55NLL
    // Generate tech specific sync
  wire [DW-1:0] sync_dat [DP-1:0];
    
  genvar i;

  generate 
    for(i=0;i<DP;i=i+1) begin:gen_sync
      if(i==0) begin:gen_i_is_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(din_a,         sync_dat[0], clk, rst_n);
      end
      else begin:gen_i_is_not_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(sync_dat[i-1], sync_dat[i], clk, rst_n);
      end
    end
  endgenerate

  assign dout = sync_dat[DP-1];

`endif
`ifdef TECH_SMIC40NLL_8T
    // Generate tech specific sync
  wire [DW-1:0] sync_dat [DP-1:0];

  genvar i;

  generate
    for(i=0;i<DP;i=i+1) begin:gen_sync
      if(i==0) begin:gen_i_is_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(din_a,         sync_dat[0], clk, rst_n);
      end
      else begin:gen_i_is_not_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(sync_dat[i-1], sync_dat[i], clk, rst_n);
      end
    end
  endgenerate

  assign dout = sync_dat[DP-1];

`endif
`ifdef TECH_SMIC40NLL_12T
    // Generate tech specific sync
  wire [DW-1:0] sync_dat [DP-1:0];

  genvar i;

  generate
    for(i=0;i<DP;i=i+1) begin:gen_sync
      if(i==0) begin:gen_i_is_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(din_a,         sync_dat[0], clk, rst_n);
      end
      else begin:gen_i_is_not_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(sync_dat[i-1], sync_dat[i], clk, rst_n);
      end
    end
  endgenerate

  assign dout = sync_dat[DP-1];

`endif
`ifdef TECH_SMIC40NLL_12T_3V3
    // Generate tech specific sync
  wire [DW-1:0] sync_dat [DP-1:0];

  genvar i;

  generate
    for(i=0;i<DP;i=i+1) begin:gen_sync
      if(i==0) begin:gen_i_is_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(din_a,         sync_dat[0], clk, rst_n);
      end
      else begin:gen_i_is_not_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(sync_dat[i-1], sync_dat[i], clk, rst_n);
      end
    end
  endgenerate

  assign dout = sync_dat[DP-1];

`endif
`ifdef TECH_SMIC40NLL_SNPS
    // Generate tech specific sync
  wire [DW-1:0] sync_dat [DP-1:0];

  genvar i;

  generate
    for(i=0;i<DP;i=i+1) begin:gen_sync
      if(i==0) begin:gen_i_is_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(din_a,         sync_dat[0], clk, rst_n);
      end
      else begin:gen_i_is_not_0
        e603_gnrl_dffrs #(DW, RST_VAL) sync_dffr(sync_dat[i-1], sync_dat[i], clk, rst_n);
      end
    end
  endgenerate

  assign dout = sync_dat[DP-1];

`endif

`ifndef TECH_SMIC14SFP_9T // {
`ifndef TECH_SMIC55NLL // {
`ifndef TECH_SMIC40NLL_8T // {
`ifndef TECH_SMIC40NLL_12T // {
`ifndef TECH_SMIC40NLL_12T_3V3 // {
`ifndef TECH_SMIC40NLL_SNPS // {
// This is the Sim-model
//
  wire [DW-1:0] sync_dat [DP-1:0];

  genvar i;

  // NOTE: with update RST_VAL, some gnrl_dffr actually gnrl_dffrs. Cautions required when
  //       replace them
  generate
  for(i=0;i<DP;i=i+1) begin:gen_sync
    if(i==0) begin:gen_i_is_0
      e603_gnrl_dffrs #(DW, RST_VAL) sync_dffrs(din_a,         sync_dat[0], clk, rst_n);
    end
    else begin:gen_i_is_not_0
      e603_gnrl_dffrs #(DW, RST_VAL) sync_dffrs(sync_dat[i-1], sync_dat[i], clk, rst_n);
    end
  end
  endgenerate

  assign dout = sync_dat[DP-1];
`endif // }
`endif // }
`endif // }
`endif // }
`endif // }
`endif // }

endmodule
