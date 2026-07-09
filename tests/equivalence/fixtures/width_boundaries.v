// Equivalence fixture: narrow and wide packed-vector expression boundaries.
module width_boundaries (
  input  wire        a1,
  input  wire [1:0]  a2,
  input  wire [30:0] a31,
  input  wire [31:0] a32,
  input  wire [32:0] a33,
  input  wire [62:0] a63,
  input  wire [63:0] a64,
  input  wire [64:0] a65,
  input  wire [5:0]  sh,
  output wire        y1,
  output wire [1:0]  y2,
  output wire [30:0] y31,
  output wire [31:0] y32,
  output wire [32:0] y33,
  output wire [62:0] y63,
  output wire [63:0] y64,
  output wire [64:0] y65,
  output wire        cmp65
);
  assign y1 = a1 ^ a2[1] ^ a31[30] ^ a65[64];
  assign y2 = {a1, a2[0]};
  assign y31 = a31 + a32[30:0] + {{30{1'b0}}, a1};
  assign y32 = {a1, a31};
  assign y33 = a33 ^ {1'b0, a32};
  assign y63 = {a31, a32};
  assign y64 = ({a1, a63} + a64) ^ {a32, a32};
  assign y65 = (a65 + {1'b0, a64}) ^ ({a1, a64} >> sh);
  assign cmp65 = a65 >= {1'b0, a64};
endmodule
