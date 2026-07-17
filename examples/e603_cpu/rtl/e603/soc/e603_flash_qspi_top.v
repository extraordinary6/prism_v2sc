 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_flash_qspi_top(
  input   clk,
  input   rst_n,
  input                      i_icb_cmd_valid,
  output                     i_icb_cmd_ready,
  input  [31:0]              i_icb_cmd_addr, 
  input                      i_icb_cmd_read, 
  input  [32-1:0]            i_icb_cmd_wdata,
  output                     i_icb_rsp_valid,
  input                      i_icb_rsp_ready,
  output [32-1:0]            i_icb_rsp_rdata,
  input                      f_icb_cmd_valid,
  output                     f_icb_cmd_ready,
  input  [31:0]              f_icb_cmd_addr, 
  input                      f_icb_cmd_read, 
  input  [32-1:0]            f_icb_cmd_wdata,
  output                     f_icb_rsp_valid,
  input                      f_icb_rsp_ready,
  output [32-1:0]            f_icb_rsp_rdata,
  output  io_port_sck,
  input   io_port_dq_0_i,
  output  io_port_dq_0_o,
  output  io_port_dq_0_oe,
  input   io_port_dq_1_i,
  output  io_port_dq_1_o,
  output  io_port_dq_1_oe,
  input   io_port_dq_2_i,
  output  io_port_dq_2_o,
  output  io_port_dq_2_oe,
  input   io_port_dq_3_i,
  output  io_port_dq_3_o,
  output  io_port_dq_3_oe,
  output  io_port_cs_0,
  output  io_tl_i_0_0 
);
`ifndef FLASH_SIM 
 fjq8nc6h1irhemz9rgthx9a49zisy  he_njwx1w09p5onrh1efokyvm7idc(
   .mxwg8lfgv4pge1         (i_icb_cmd_valid)           ,
   .qi_euczbjhgo1za         (i_icb_cmd_ready)           ,
   .mqxw6of2d4b4nr7b           (1'b1)           ,
   .cuu3goyrnwc9hf          (i_icb_cmd_read)           ,
   .t3lk20ui52aqc6          (i_icb_cmd_addr[11:0])           ,
   .rs8qfdkpko8pq         (i_icb_cmd_wdata)           ,
   .swwpvt6gm3cz8         (4'b1111)           ,
   .pccr2d0febxqx          (3'b010)           ,
   .vah0tsdviw4b          (1'b0)           ,
   .u7u7t6iaofiovjc          (1'b0)           ,
   .xwpttmbn8xqi2b0qg          (8'h0)           ,
   .j7onlxu8c84rohjl3        (2'h0)           ,
   .abuhy0_a307fr_734f         (2'h0)           ,
   .xi4mxnyfh8q6pd2         (1'b0)           ,
   .le80uwswd0y0q8         (3'h0)           ,
   .p5nleje0lb8ux          (2'h0)           ,
   .ptdklfwbs2d13         (i_icb_rsp_ready)           ,
   .l_geblczxuwi5x4e         (i_icb_rsp_valid)           ,
   .r1ukfidrb_5kvibw           ()           ,
   .nhup3xqrnngwbqsg_e       ()           ,
   .nuvz1doibyin1uaa         (i_icb_rsp_rdata)           ,
   .sh2b2lwquxmyxxapt       (f_icb_cmd_valid)           ,
   .n3zfnp3kttpvkse4skl4       (f_icb_cmd_ready)           ,
   .xv8ytrg4q97odq9         (1'b1)           ,
   .zlo0z95xdnd31kbge        (f_icb_cmd_read)           ,
   .jcrj9dsl67z40w2y        ({f_icb_cmd_addr[26:2],2'b0})           ,
   .xbef1j4kr1_18aj       (f_icb_cmd_wdata)           ,
   .v1v1zytwvme9yqhfx_g       (4'b1111)           ,
   .v_zpu3v200gvvym        (3'b010)           ,
   .ffvzxhz5wfwy9v        (1'b0)           ,
   .g5i2wkcji_izi8qzn4        (1'b0)           ,
   .mfkz86j_bjio436        (8'h0)           ,
   .genqu4yhgwwpi0_3qs0z      (2'h0)           ,
   .iinbhfl2w9fbd9jue       (2'h0)           ,
   .g_2225gbix9c3ff       (1'b0)           ,
   .txlgxr6zhterdis_       (3'h0)           ,
   .so3b6iwax9zt3vi2qpr        (2'h0)           ,
   .kgrazhctl7rag0rnmhh       (f_icb_rsp_ready)           ,
   .zlpfgr1j7yibszfzeo       (f_icb_rsp_valid)           ,
   .bcni8cvge8lyl         ()           ,
   .cf62leu1ptk969g_e4t     ()           ,
   .frw8p5sm65fg6dejxg       (f_icb_rsp_rdata)           ,
   .dmhkymm6b795q4zkoqach0v     (1'b0)       ,
   .v1041hzw3wb2sukzop_     (io_port_sck)       ,
   .pgqbkj2997h3vojr       ()       ,
   .d_6mygfd2mmf25ggsdm    (1'b0)       ,
   .ju8l4q3iwab8jy6oeqe8    (io_port_cs_0)       ,
   .r7icei2574dhycq3337g      ()       ,
   .ytdh3d3n7ekpzloi8tsx8wk2    (io_port_dq_0_i)       ,
   .q8p9c72msll1_p3amrdry    (io_port_dq_0_o)       ,
   .zi19i11xrx7jd1fuq34khc      (io_port_dq_0_oe)       ,
   .yzd_4xbhvc_ecjar8s0q    (io_port_dq_1_i)       ,
   .eft33k6ztrvp1vhwph0    (io_port_dq_1_o)       ,
   .o0y3rnwh4pgqb_a5qv65m      (io_port_dq_1_oe)       ,
   .ohksno219csx273g9eqa    (io_port_dq_2_i)       ,
   .wbs5z3a85c2l20cabodn_q    (io_port_dq_2_o)       ,
   .lrw06nxux099_s8wpaxi08      (io_port_dq_2_oe)       ,
   .rmc529912l96n9_89hfrzkgi    (io_port_dq_3_i)       ,
   .t7f1uujprai4zx1mytkq    (io_port_dq_3_o)       ,
   .xt6a4d6mhv7d1_nrzgplsy      (io_port_dq_3_oe)     ,
   .tx071b2z1oij56         (1'b0)       ,
   .czz3lmsnukdwivlhf4        (1'b0)       ,
   .rfobz3_ed              (1'b0)       ,
   .xdsh5em7xrg            (io_tl_i_0_0)       ,
   .ri2ziyy                    (clk)       ,
   .r46kf                  (rst_n)       
);
`else 
    localparam AW = 28;
    localparam DW = 32;
    bit [7:0] memory [2**AW-1:0];
    assign i_icb_cmd_ready = 1'b1;
    assign i_icb_rsp_rdata = 32'b0;
    assign io_port_sck = 1'b0;
    assign io_port_dq_0_o = 1'b0;
    assign io_port_dq_0_oe = 1'b0;
    assign io_port_dq_1_o = 1'b0;
    assign io_port_dq_1_oe = 1'b0;
    assign io_port_dq_2_o = 1'b0;
    assign io_port_dq_2_oe = 1'b0;
    assign io_port_dq_3_o = 1'b0;
    assign io_port_dq_3_oe = 1'b0;
    assign io_port_cs_0 = 1'b0;
    assign io_tl_i_0_0  = 1'b0;
    reg rsp_valid;
    always@(posedge clk)
        rsp_valid <= i_icb_cmd_valid;
    assign i_icb_rsp_valid = rsp_valid;
    wire icb_cmd_valid = f_icb_cmd_valid;
    wire icb_cmd_ready = 1'b1;
    assign f_icb_cmd_ready = icb_cmd_ready;
    wire [32-1:0] icb_cmd_addr = f_icb_cmd_addr;
    wire icb_cmd_read = f_icb_cmd_read;
    wire icb_rsp_ready = f_icb_rsp_ready;
    reg icb_rsp_valid = 1'b0;
    reg [DW-1:0] icb_rsp_rdata;
    assign f_icb_rsp_valid = icb_rsp_valid;
    assign f_icb_rsp_rdata = icb_rsp_rdata;
    wire [AW-1:0] addr;
    assign addr = {icb_cmd_addr[AW-1:2], 2'b00};
    wire r_valid = icb_cmd_valid & icb_cmd_ready & icb_cmd_read;
    wire w_valid = icb_cmd_valid & icb_cmd_ready & ~icb_cmd_read;
    always@(posedge clk) begin
        if (icb_cmd_valid & icb_cmd_ready)
            icb_rsp_valid <= 1'b1;
        else
            icb_rsp_valid <= 1'b0;
    end
    always@(posedge clk) begin
        if (w_valid) begin
            memory[addr] <=   f_icb_cmd_wdata[0+:8]; 
            memory[addr+1] <= f_icb_cmd_wdata[8+:8]; 
            memory[addr+2] <= f_icb_cmd_wdata[16+:8]; 
            memory[addr+3] <= f_icb_cmd_wdata[24+:8]; 
        end
    end
    always@(posedge clk) begin
        if (r_valid) begin
            icb_rsp_rdata[0+:8] <= memory[addr+0];
            icb_rsp_rdata[8+:8] <= memory[addr+1];
            icb_rsp_rdata[16+:8] <= memory[addr+2];
            icb_rsp_rdata[24+:8] <= memory[addr+3];
        end
    end
`endif
endmodule
module e603_qspi_1cs_top(
  input   clk,
  input   rst_n,
  input                      i_icb_cmd_valid,
  output                     i_icb_cmd_ready,
  input  [32-1:0]            i_icb_cmd_addr, 
  input                      i_icb_cmd_read, 
  input  [32-1:0]            i_icb_cmd_wdata,
  output                     i_icb_rsp_valid,
  input                      i_icb_rsp_ready,
  output [32-1:0]            i_icb_rsp_rdata,
  output  io_port_sck,
  input   io_port_dq_0_i,
  output  io_port_dq_0_o,
  output  io_port_dq_0_oe,
  input   io_port_dq_1_i,
  output  io_port_dq_1_o,
  output  io_port_dq_1_oe,
  input   io_port_dq_2_i,
  output  io_port_dq_2_o,
  output  io_port_dq_2_oe,
  input   io_port_dq_3_i,
  output  io_port_dq_3_o,
  output  io_port_dq_3_oe,
  output  io_port_cs_0,
  output  io_tl_i_0_0 
);
 o1cie5ltkuujelpoc044qaxzhq9vd  y3c29jkeiym483vo31h2c2fgr8_dq_s2hw(
   .mxwg8lfgv4pge1         (i_icb_cmd_valid)           ,
   .qi_euczbjhgo1za         (i_icb_cmd_ready)           ,
   .mqxw6of2d4b4nr7b           (1'b1)           ,
   .cuu3goyrnwc9hf          (i_icb_cmd_read)           ,
   .t3lk20ui52aqc6          (i_icb_cmd_addr[11:0])           ,
   .rs8qfdkpko8pq         (i_icb_cmd_wdata)           ,
   .swwpvt6gm3cz8         (4'b1111)           ,
   .pccr2d0febxqx          (3'b010)           ,
   .vah0tsdviw4b          (1'b0)           ,
   .u7u7t6iaofiovjc          (1'b0)           ,
   .xwpttmbn8xqi2b0qg          (8'h0)           ,
   .j7onlxu8c84rohjl3        (2'h0)           ,
   .abuhy0_a307fr_734f         (2'h0)           ,
   .xi4mxnyfh8q6pd2         (1'b0)           ,
   .le80uwswd0y0q8         (3'h0)           ,
   .p5nleje0lb8ux          (2'h0)           ,
   .ptdklfwbs2d13         (i_icb_rsp_ready)           ,
   .l_geblczxuwi5x4e         (i_icb_rsp_valid)           ,
   .r1ukfidrb_5kvibw           ()           ,
   .nhup3xqrnngwbqsg_e       ()           ,
   .nuvz1doibyin1uaa         (i_icb_rsp_rdata)           ,
   .dmhkymm6b795q4zkoqach0v     (1'b0)       ,
   .v1041hzw3wb2sukzop_     (io_port_sck)       ,
   .pgqbkj2997h3vojr       ()       ,
   .d_6mygfd2mmf25ggsdm    (1'b0)       ,
   .ju8l4q3iwab8jy6oeqe8    (io_port_cs_0)       ,
   .r7icei2574dhycq3337g      ()       ,
   .c0x_i_5i7bt7yx_zmwu    (1'b0)       ,
   .ol5mlmj67flwh9yyzta    ()       ,
   .t7abag_v4myar4wud4      ()       ,
   .e9ddu7_tizizm7vjcjt_ks    (1'b0)       ,
   .wg4tx17xocuwuboqzadpx    ()       ,
   .oxf7tev15h533lq12axi8      ()       ,
   .x4iy73ny318v7drukjfif11    (1'b0)       ,
   .jdyjh04rnavp5w2sgn5    ()       ,
   .x6fiou3hmk9kjviwjy      ()       ,
   .ytdh3d3n7ekpzloi8tsx8wk2    (io_port_dq_0_i)       ,
   .q8p9c72msll1_p3amrdry    (io_port_dq_0_o)       ,
   .zi19i11xrx7jd1fuq34khc      (io_port_dq_0_oe)       ,
   .yzd_4xbhvc_ecjar8s0q    (io_port_dq_1_i)       ,
   .eft33k6ztrvp1vhwph0    (io_port_dq_1_o)       ,
   .o0y3rnwh4pgqb_a5qv65m      (io_port_dq_1_oe)       ,
   .ohksno219csx273g9eqa    (io_port_dq_2_i)       ,
   .wbs5z3a85c2l20cabodn_q    (io_port_dq_2_o)       ,
   .lrw06nxux099_s8wpaxi08      (io_port_dq_2_oe)       ,
   .rmc529912l96n9_89hfrzkgi    (io_port_dq_3_i)       ,
   .t7f1uujprai4zx1mytkq    (io_port_dq_3_o)       ,
   .xt6a4d6mhv7d1_nrzgplsy      (io_port_dq_3_oe)     ,
   .tx071b2z1oij56         (1'b0)       ,
   .czz3lmsnukdwivlhf4        (1'b0)       ,
   .rfobz3_ed              (1'b0)       ,
   .xdsh5em7xrg            (io_tl_i_0_0)       ,
   .ri2ziyy                    (clk)       ,
   .r46kf                  (rst_n)       
);
endmodule
module e603_qspi_4cs_top(
  input   clk,
  input   rst_n,
  input                      i_icb_cmd_valid,
  output                     i_icb_cmd_ready,
  input  [32-1:0]            i_icb_cmd_addr, 
  input                      i_icb_cmd_read, 
  input  [32-1:0]            i_icb_cmd_wdata,
  output                     i_icb_rsp_valid,
  input                      i_icb_rsp_ready,
  output [32-1:0]            i_icb_rsp_rdata,
  output  io_port_sck,
  input   io_port_dq_0_i,
  output  io_port_dq_0_o,
  output  io_port_dq_0_oe,
  input   io_port_dq_1_i,
  output  io_port_dq_1_o,
  output  io_port_dq_1_oe,
  input   io_port_dq_2_i,
  output  io_port_dq_2_o,
  output  io_port_dq_2_oe,
  input   io_port_dq_3_i,
  output  io_port_dq_3_o,
  output  io_port_dq_3_oe,
  output  io_port_cs_0,
  output  io_port_cs_1,
  output  io_port_cs_2,
  output  io_port_cs_3,
  output  io_tl_i_0_0 
);
 o1cie5ltkuujelpoc044qaxzhq9vd  y3c29jkeiym483vo31h2c2fgr8_dq_s2hw(
   .mxwg8lfgv4pge1         (i_icb_cmd_valid)           ,
   .qi_euczbjhgo1za         (i_icb_cmd_ready)           ,
   .mqxw6of2d4b4nr7b           (1'b1)           ,
   .cuu3goyrnwc9hf          (i_icb_cmd_read)           ,
   .t3lk20ui52aqc6          (i_icb_cmd_addr[11:0])           ,
   .rs8qfdkpko8pq         (i_icb_cmd_wdata)           ,
   .swwpvt6gm3cz8         (4'b1111)           ,
   .pccr2d0febxqx          (3'b010)           ,
   .vah0tsdviw4b          (1'b0)           ,
   .u7u7t6iaofiovjc          (1'b0)           ,
   .xwpttmbn8xqi2b0qg          (8'h0)           ,
   .j7onlxu8c84rohjl3        (2'h0)           ,
   .abuhy0_a307fr_734f         (2'h0)           ,
   .xi4mxnyfh8q6pd2         (1'b0)           ,
   .le80uwswd0y0q8         (3'h0)           ,
   .p5nleje0lb8ux          (2'h0)           ,
   .ptdklfwbs2d13         (i_icb_rsp_ready)           ,
   .l_geblczxuwi5x4e         (i_icb_rsp_valid)           ,
   .r1ukfidrb_5kvibw           ()           ,
   .nhup3xqrnngwbqsg_e       ()           ,
   .nuvz1doibyin1uaa         (i_icb_rsp_rdata)           ,
   .dmhkymm6b795q4zkoqach0v     (1'b0)       ,
   .v1041hzw3wb2sukzop_     (io_port_sck)       ,
   .pgqbkj2997h3vojr       ()       ,
   .d_6mygfd2mmf25ggsdm    (1'b0)       ,
   .ju8l4q3iwab8jy6oeqe8    (io_port_cs_0)       ,
   .r7icei2574dhycq3337g      ()       ,
   .c0x_i_5i7bt7yx_zmwu    (1'b0)       ,
   .ol5mlmj67flwh9yyzta    (io_port_cs_1)       ,
   .t7abag_v4myar4wud4      ()       ,
   .e9ddu7_tizizm7vjcjt_ks    (1'b0)       ,
   .wg4tx17xocuwuboqzadpx    (io_port_cs_2)       ,
   .oxf7tev15h533lq12axi8      ()       ,
   .x4iy73ny318v7drukjfif11    (1'b0)       ,
   .jdyjh04rnavp5w2sgn5    (io_port_cs_3)       ,
   .x6fiou3hmk9kjviwjy      ()       ,
   .ytdh3d3n7ekpzloi8tsx8wk2    (io_port_dq_0_i)       ,
   .q8p9c72msll1_p3amrdry    (io_port_dq_0_o)       ,
   .zi19i11xrx7jd1fuq34khc      (io_port_dq_0_oe)       ,
   .yzd_4xbhvc_ecjar8s0q    (io_port_dq_1_i)       ,
   .eft33k6ztrvp1vhwph0    (io_port_dq_1_o)       ,
   .o0y3rnwh4pgqb_a5qv65m      (io_port_dq_1_oe)       ,
   .ohksno219csx273g9eqa    (io_port_dq_2_i)       ,
   .wbs5z3a85c2l20cabodn_q    (io_port_dq_2_o)       ,
   .lrw06nxux099_s8wpaxi08      (io_port_dq_2_oe)       ,
   .rmc529912l96n9_89hfrzkgi    (io_port_dq_3_i)       ,
   .t7f1uujprai4zx1mytkq    (io_port_dq_3_o)       ,
   .xt6a4d6mhv7d1_nrzgplsy      (io_port_dq_3_oe)     ,
   .tx071b2z1oij56         (1'b0)       ,
   .czz3lmsnukdwivlhf4        (1'b0)       ,
   .rfobz3_ed              (1'b0)       ,
   .xdsh5em7xrg            (io_tl_i_0_0)       ,
   .ri2ziyy                    (clk)       ,
   .r46kf                  (rst_n)       
);
endmodule
module o1cie5ltkuujelpoc044qaxzhq9vd (
  input              mxwg8lfgv4pge1                 ,
  output             qi_euczbjhgo1za                 ,
  input              mqxw6of2d4b4nr7b                   ,
  input              cuu3goyrnwc9hf                  ,
  input  [  11:   0] t3lk20ui52aqc6                  ,
  input  [  31:   0] rs8qfdkpko8pq                 ,
  input  [   3:   0] swwpvt6gm3cz8                 ,
  input  [   2:   0] pccr2d0febxqx                  ,
  input              vah0tsdviw4b                  ,
  input              u7u7t6iaofiovjc                  ,
  input  [   7:   0] xwpttmbn8xqi2b0qg                  ,
  input  [   1:   0] j7onlxu8c84rohjl3                ,
  input  [   1:   0] abuhy0_a307fr_734f                 ,
  input              xi4mxnyfh8q6pd2                 ,
  input  [   2:   0] le80uwswd0y0q8                 ,
  input  [   1:   0] p5nleje0lb8ux                  ,
  input              ptdklfwbs2d13                 ,
  output             l_geblczxuwi5x4e                 ,
  output             r1ukfidrb_5kvibw                   ,
  output             nhup3xqrnngwbqsg_e               ,
  output [  31:   0] nuvz1doibyin1uaa                 ,
  input              dmhkymm6b795q4zkoqach0v            ,
  output             v1041hzw3wb2sukzop_            ,
  output             pgqbkj2997h3vojr              ,
  input              d_6mygfd2mmf25ggsdm           ,
  output             ju8l4q3iwab8jy6oeqe8           ,
  output             r7icei2574dhycq3337g             ,
  input              c0x_i_5i7bt7yx_zmwu           ,
  output             ol5mlmj67flwh9yyzta           ,
  output             t7abag_v4myar4wud4             ,
  input              e9ddu7_tizizm7vjcjt_ks           ,
  output             wg4tx17xocuwuboqzadpx           ,
  output             oxf7tev15h533lq12axi8             ,
  input              x4iy73ny318v7drukjfif11           ,
  output             jdyjh04rnavp5w2sgn5           ,
  output             x6fiou3hmk9kjviwjy             ,
  input              ytdh3d3n7ekpzloi8tsx8wk2           ,
  output             q8p9c72msll1_p3amrdry           ,
  output             zi19i11xrx7jd1fuq34khc             ,
  input              yzd_4xbhvc_ecjar8s0q           ,
  output             eft33k6ztrvp1vhwph0           ,
  output             o0y3rnwh4pgqb_a5qv65m             ,
  input              ohksno219csx273g9eqa           ,
  output             wbs5z3a85c2l20cabodn_q           ,
  output             lrw06nxux099_s8wpaxi08             ,
  input              rmc529912l96n9_89hfrzkgi           ,
  output             t7f1uujprai4zx1mytkq           ,
  output             xt6a4d6mhv7d1_nrzgplsy             ,
  input              tx071b2z1oij56                ,
  input              czz3lmsnukdwivlhf4               ,
  input              rfobz3_ed                     ,
  output             xdsh5em7xrg                   ,
  input              ri2ziyy                           ,
  input              r46kf                         
);
  wire x7kd6gw9z3nq;
  wire h5fyr6xf;
  wire n28ajivzes3;
  wire s5xq485joofuo;
  wire e36er1uj5tr0;
  wire s6akl1c_8vxk;
  wire nwk_ulhgdn;
  wire bgbdwh2mx7n;
  wire r50r4f8sqsa68b;
  wire hby204glk3hbw;
wire [4-1:0] pt7qy;
wire [4-1:0] rgen47ck0hcqyacyce;
wire [7:0] ttz9f;
wire [7:0] pnnvff;
wire [7:0] d1ps_eg;
 wire dlmwxsha8xcd;
e603_gnrl_dffr #(1) drwuiauphh4u2ro79w (1'b1, dlmwxsha8xcd, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
 wire jesyol8j2mzc9p7rg;
 wire n3w802chksaybtkdgd_xl = mxwg8lfgv4pge1 & dlmwxsha8xcd;
 assign qi_euczbjhgo1za = jesyol8j2mzc9p7rg & dlmwxsha8xcd;
egfbmrj0f1a478ryp0hnjebz  eo8040ii_bi3pfikpx0cr6wanu (
    .mxwg8lfgv4pge1    (n3w802chksaybtkdgd_xl),
    .qi_euczbjhgo1za    (jesyol8j2mzc9p7rg),
    .mqxw6of2d4b4nr7b      (mqxw6of2d4b4nr7b),
    .cuu3goyrnwc9hf     (cuu3goyrnwc9hf),
    .t3lk20ui52aqc6     (t3lk20ui52aqc6),
    .rs8qfdkpko8pq    (rs8qfdkpko8pq),
    .swwpvt6gm3cz8    (swwpvt6gm3cz8),
    .pccr2d0febxqx     (pccr2d0febxqx),
    .vah0tsdviw4b     (vah0tsdviw4b),
    .u7u7t6iaofiovjc     (u7u7t6iaofiovjc),
    .xwpttmbn8xqi2b0qg     (xwpttmbn8xqi2b0qg),
    .j7onlxu8c84rohjl3   (j7onlxu8c84rohjl3),
    .abuhy0_a307fr_734f    (abuhy0_a307fr_734f),
    .xi4mxnyfh8q6pd2    (xi4mxnyfh8q6pd2),
    .le80uwswd0y0q8    (le80uwswd0y0q8),
    .p5nleje0lb8ux     (p5nleje0lb8ux),
    .ptdklfwbs2d13    (ptdklfwbs2d13),
    .l_geblczxuwi5x4e    (l_geblczxuwi5x4e),
    .r1ukfidrb_5kvibw      (r1ukfidrb_5kvibw),
    .nhup3xqrnngwbqsg_e  (nhup3xqrnngwbqsg_e),
    .nuvz1doibyin1uaa    (nuvz1doibyin1uaa),
     .r50r4f8sqsa68b         (r50r4f8sqsa68b),
     .hby204glk3hbw         (hby204glk3hbw),
    .pl4w5klaegaid      (rgen47ck0hcqyacyce),
    .s5xq485joofuo      (s5xq485joofuo),
    .n28ajivzes3      (n28ajivzes3),
    .s6akl1c_8vxk      (s6akl1c_8vxk),
    .e36er1uj5tr0      (e36er1uj5tr0),
    .nwk_ulhgdn       (nwk_ulhgdn),
    .pf4_b0e3ymdaf     (bgbdwh2mx7n),
    .tx071b2z1oij56   (tx071b2z1oij56),
    .czz3lmsnukdwivlhf4  (czz3lmsnukdwivlhf4),
    .x7kd6gw9z3nq         (x7kd6gw9z3nq         ),
    .h5fyr6xf         (h5fyr6xf         ),
    .br7a8dw5rndor        (v1041hzw3wb2sukzop_),
    .ct6pxuoq         (pt7qy               ),
    .imb7nq3h         (ttz9f               ),
    .of6bvne9f         (d1ps_eg             ),
    .f2pcwb9mj         (pnnvff             ),
    .ri2ziyy              (ri2ziyy              ),
    .r46kf            (r46kf            ) 
);
assign xdsh5em7xrg = x7kd6gw9z3nq 
                   | h5fyr6xf 
                   | n28ajivzes3 
                   | s5xq485joofuo
                   | e36er1uj5tr0 
                   | s6akl1c_8vxk
                   | nwk_ulhgdn
                   | r50r4f8sqsa68b
                   | hby204glk3hbw
                   ;
assign ju8l4q3iwab8jy6oeqe8 = pt7qy[0];
assign ol5mlmj67flwh9yyzta = pt7qy[1];
assign wg4tx17xocuwuboqzadpx = pt7qy[2];
assign jdyjh04rnavp5w2sgn5 = pt7qy[3];
assign pnnvff = {
               4'h0,
               rmc529912l96n9_89hfrzkgi,
               ohksno219csx273g9eqa,
               yzd_4xbhvc_ecjar8s0q,
               ytdh3d3n7ekpzloi8tsx8wk2
              };
  assign t7f1uujprai4zx1mytkq = d1ps_eg[3];
  assign wbs5z3a85c2l20cabodn_q = d1ps_eg[2];
  assign eft33k6ztrvp1vhwph0 = d1ps_eg[1];
  assign q8p9c72msll1_p3amrdry = d1ps_eg[0];
  assign xt6a4d6mhv7d1_nrzgplsy = ttz9f[3];
  assign lrw06nxux099_s8wpaxi08 = ttz9f[2];
  assign o0y3rnwh4pgqb_a5qv65m = ttz9f[1];
  assign zi19i11xrx7jd1fuq34khc = ttz9f[0];
assign r7icei2574dhycq3337g  = rgen47ck0hcqyacyce[0];
assign t7abag_v4myar4wud4  = rgen47ck0hcqyacyce[1];
assign oxf7tev15h533lq12axi8  = rgen47ck0hcqyacyce[2];
assign x6fiou3hmk9kjviwjy  = rgen47ck0hcqyacyce[3];
assign pgqbkj2997h3vojr  = 1'b1;
endmodule
module egfbmrj0f1a478ryp0hnjebz (
    input              mxwg8lfgv4pge1                 ,
  output             qi_euczbjhgo1za                 ,
  input              mqxw6of2d4b4nr7b                   ,
  input              cuu3goyrnwc9hf                  ,
  input  [  11:   0] t3lk20ui52aqc6                  ,
  input  [  31:   0] rs8qfdkpko8pq                 ,
  input  [   3:   0] swwpvt6gm3cz8                 ,
  input  [   2:   0] pccr2d0febxqx                  ,
  input              vah0tsdviw4b                  ,
  input              u7u7t6iaofiovjc                  ,
  input  [   7:   0] xwpttmbn8xqi2b0qg                  ,
  input  [   1:   0] j7onlxu8c84rohjl3                ,
  input  [   1:   0] abuhy0_a307fr_734f                 ,
  input              xi4mxnyfh8q6pd2                 ,
  input  [   2:   0] le80uwswd0y0q8                 ,
  input  [   1:   0] p5nleje0lb8ux                  ,
  input              ptdklfwbs2d13                 ,
  output             l_geblczxuwi5x4e                 ,
  output             r1ukfidrb_5kvibw                   ,
  output             nhup3xqrnngwbqsg_e               ,
  output [  31:   0] nuvz1doibyin1uaa                 ,
    output                        hby204glk3hbw,
    output                        r50r4f8sqsa68b,
  output                       x7kd6gw9z3nq,
  output                       h5fyr6xf,
  output                       br7a8dw5rndor,
  output [4-1:0] pl4w5klaegaid,
  output                       n28ajivzes3,
  output                       s5xq485joofuo,
  output                       e36er1uj5tr0,
  output                       s6akl1c_8vxk,
  output                       nwk_ulhgdn,
  output                       pf4_b0e3ymdaf,
  output  [4-1:0]ct6pxuoq,
  output  [7:0]                imb7nq3h,
  output  [7:0]                of6bvne9f,
  input   [7:0]                f2pcwb9mj,
  input                        tx071b2z1oij56,
  input                        czz3lmsnukdwivlhf4,
  input                        ri2ziyy,
  input                        r46kf   
);
assign nhup3xqrnngwbqsg_e = 1'b0;
assign r1ukfidrb_5kvibw = 1'b0;
wire [11:0] te79w3m1s;
wire [4-1:0] pt7qy;
wire dgzm3zm3ogvw, lh74zppbcl4;
wire cm3r24ltl2gx, lqhrn87uxvqt;
wire [1:0] wzsi3d;
wire [5:0] fj3di,ujy_7sawj;
wire qeo6nc ;
wire oih5t0l8wy_;
wire ixkn7y8_9x;
wire [31:0] uh0t93udo6,gghz_6zv;
wire j5yfsxwh0xm,llhht8w4fsz;
wire ova0029jyhx98hvd;  
wire h44oj_ibu1z0h;
wire [7:0]    wxyxjhortejmt3;        
wire [7:0]    wcja3zdd0t7j;  
wire [7:0]    rlj4cog5b111mwd;  
wire          b47qcro0nyi; 
wire [2:0]    djkt53av;
wire [4-1:0] l3bywjb87dberrlhon;
wire          qvfdyis4_xxmz;
wire [4-1:0] hvtb90hz3c8v_q = {{4-1{1'b1}},1'b1};
assign pl4w5klaegaid[0]  = hvtb90hz3c8v_q[0];
assign pl4w5klaegaid[1]  = hvtb90hz3c8v_q[1];
assign pl4w5klaegaid[2]  = hvtb90hz3c8v_q[2];
assign pl4w5klaegaid[3]  = hvtb90hz3c8v_q[3];
wire rqos2ss_hld9pn;
wire mx3lsy0gkyfsk;
c7dbsb9r13c71qno837p_rn8l9h  hhl6un88acg367nzu1z_i (
    .mxwg8lfgv4pge1  (mxwg8lfgv4pge1),
    .qi_euczbjhgo1za  (qi_euczbjhgo1za),
    .cuu3goyrnwc9hf   (cuu3goyrnwc9hf ),
    .t3lk20ui52aqc6   (t3lk20ui52aqc6 ),
    .rs8qfdkpko8pq  (rs8qfdkpko8pq),
    .l_geblczxuwi5x4e  (l_geblczxuwi5x4e),
    .ptdklfwbs2d13  (ptdklfwbs2d13),
    .nuvz1doibyin1uaa  (nuvz1doibyin1uaa),
    .x7kd6gw9z3nq       (x7kd6gw9z3nq),
    .h5fyr6xf       (h5fyr6xf),
    .n28ajivzes3    (n28ajivzes3),
    .s5xq485joofuo    (s5xq485joofuo),
    .e36er1uj5tr0    (e36er1uj5tr0),
    .s6akl1c_8vxk    (s6akl1c_8vxk),
    .nwk_ulhgdn     (nwk_ulhgdn),
    .cl_8d3kdihjb9yq (dgzm3zm3ogvw ),
    .vm78tgdkfetjjfd (lh74zppbcl4 ),
    .ncpbeb24mmnc60 (lqhrn87uxvqt ),
    .flk5mvwbvqzxirah (cm3r24ltl2gx ),
    .hrrr6xbwwneddk  (uh0t93udo6  ),
    .o8sv0e253jptbb2s5  (gghz_6zv  ),
    .p7cldie50p2tmud  (j5yfsxwh0xm  ),
    .n316zisfnflxfgps  (llhht8w4fsz  ),
    .wxyxjhortejmt3          (wxyxjhortejmt3          ),        
    .wcja3zdd0t7j          (wcja3zdd0t7j          ),  
    .rlj4cog5b111mwd        (rlj4cog5b111mwd        ),  
    .b47qcro0nyi           (b47qcro0nyi           ),
    .ox3ajqsqp          (qeo6nc      ),
    .skbwq1o6wlc          (te79w3m1s      ),
    .ct6pxuoq           (pt7qy       ),
    .ws03glm08u787psex3fe (ova0029jyhx98hvd),
    .cfn05giriyb8lt3_nh   (h44oj_ibu1z0h),
    .jyf0lghvzzuj2r         (djkt53av  ),
    .l3bywjb87dberrlhon    (l3bywjb87dberrlhon),
    .r50r4f8sqsa68b  (r50r4f8sqsa68b),
    .hby204glk3hbw  (hby204glk3hbw),
    .tx071b2z1oij56   (tx071b2z1oij56),
    .czz3lmsnukdwivlhf4  (czz3lmsnukdwivlhf4),
    .ri2ziyy                   (ri2ziyy  ),
    .r46kf                 (r46kf)
);
wire [4-1:0] xuzjd8d2nx;
assign ct6pxuoq  = xuzjd8d2nx ;  
wire zh9ykzl4qn_, ute24ms4bj6;
wire si_lz03o = zh9ykzl4qn_ | ute24ms4bj6;
wire q9z4xfqd;
wire qdu7w0eullr, p8xp4k82_ar;
assign br7a8dw5rndor = q9z4xfqd;
wire pg4jupxyu56;
wire spx966rqubdp;
wire f9lakbhi2c_3u = zh9ykzl4qn_ ? pg4jupxyu56 : spx966rqubdp;
wire [4-1:0] sw3u97amt6th6v = l3bywjb87dberrlhon;
  wire czjn2klzbfd87v;
  wire ory71ajyzb6iqa;
  wire nyfk9pmqi8dby5egm;
  wire jsadt688a0178q;
  wire fl3gj5l4xbul5a;
  wire aj_1pl44n7l3zrwl;
  wire [31:0] qyf1eg47j4fp;
  wire [31:0] u1yzzzi4sipk;
  wire [5:0] b0zcdbk40ehyx91;
  wire [5:0] l_ytia_njvkzsrg;
  assign czjn2klzbfd87v =  lqhrn87uxvqt;
  assign cm3r24ltl2gx   = ory71ajyzb6iqa;
  assign llhht8w4fsz   =  nyfk9pmqi8dby5egm;
  assign jsadt688a0178q = dgzm3zm3ogvw;
  assign lh74zppbcl4 = fl3gj5l4xbul5a;
  assign j5yfsxwh0xm =  aj_1pl44n7l3zrwl;
  assign qvfdyis4_xxmz =  (
                     qeo6nc);
  assign qyf1eg47j4fp = gghz_6zv;
  assign uh0t93udo6 = u1yzzzi4sipk;
  assign xuzjd8d2nx = pt7qy;
  assign l_ytia_njvkzsrg = 6'd8;
  assign b0zcdbk40ehyx91 = 6'd8;
  wire lr99tu = f2pcwb9mj[0];
  wire wk3but = f2pcwb9mj[1];
  wire u4u_sqx8 = f2pcwb9mj[2];
  wire bmvw = f2pcwb9mj[3];
  wire c2shs5lw6 = f2pcwb9mj[4];
  wire tgvjtr = f2pcwb9mj[5];
  wire mb7xvdsj = f2pcwb9mj[6];
  wire sova = f2pcwb9mj[7];
  wire d6frv2kmhiva;
  wire n0yca91sw9hy2d4i3d67;
  wire nzfgk3gj4 = te79w3m1s[0];
dy1w1n4e1pybfxg8fd6i1ato7z  yoddvff9i1opwlhtjq4opjtut (
    .m06qnpn5a9z03       (si_lz03o  ),
    .mvqrtq7dyd0jl4      (te79w3m1s ),
    .wgc1pcq7e4       (sw3u97amt6th6v  ),
    .qtsnhkdndbh    (zh9ykzl4qn_),
    .d9n3ph7pubth72d7c  (f9lakbhi2c_3u),
    .br7a8dw5rndor      (q9z4xfqd ),
    .b3nk3ml5dggetwx1   (qdu7w0eullr ),
    .fekszkc1bqs8x6b   (p8xp4k82_ar ),
    .ri2ziyy            (ri2ziyy     ),
    .r46kf          (r46kf   )
);
p6devqb4ptpbm5ap_h ec1_ohqsokvi2r491gf4y_
(
    .ssaglb56qjhnl       (jsadt688a0178q),
    .dfi9g_4x75iz3b       (fl3gj5l4xbul5a),
    .sx6i39j26_        (qdu7w0eullr  ),
    .hja3lm6no_t0q        (p8xp4k82_ar  ),
    .h1u9k_           (lr99tu     ),
    .rx9aqne           (wk3but     ),
    .db10mb8xe           (u4u_sqx8     ),
    .zh_xnfrx           (bmvw     ),
    .noqeoiuvnu           (c2shs5lw6     ),
    .h5ub76gz           (tgvjtr     ),
    .gye3x8met           (mb7xvdsj     ),
    .p6tci4w33tx           (sova     ),
    .s_w4zt6mvts         (l_ytia_njvkzsrg),
    .nfv0zewnc        (qvfdyis4_xxmz),
    .ug0f667go        (aj_1pl44n7l3zrwl ),
    .o1a2rfpyxis        (u1yzzzi4sipk ),
    .o79s9jhh3qahq      (zh9ykzl4qn_   ),
    .neq4t0yh_0bn8s74     (pg4jupxyu56   ),
    .ri2ziyy            (ri2ziyy     ),
    .r46kf          (r46kf   )
);
  wire uhgb7m1;
  wire k3ojutwd;
  wire h6gr;
  wire hd3wpzc;
  wire vh518od0;
  wire n_9v;
  wire qauqz;
  wire wkrv7d;
  assign of6bvne9f[0] =                       uhgb7m1;
  assign of6bvne9f[1] =                       k3ojutwd;
  assign of6bvne9f[2] =                     h6gr;
  assign of6bvne9f[3] =                     hd3wpzc;
  assign of6bvne9f[4] =                     vh518od0;
  assign of6bvne9f[5] =                     n_9v;
  assign of6bvne9f[6] =                     qauqz;
  assign of6bvne9f[7] =                     wkrv7d;
  wire bwsa0z3i4jwjoht;
p0qdzag8lrr7d53n89u3cl5p vo9pjspz1uzib0z6w8a5qpbd (
    .zouj6_xexoto9ok        (czjn2klzbfd87v    ),
    .o525acty1z2m        (ory71ajyzb6iqa    ),
    .s4l4bqtrr8c         (qyf1eg47j4fp     ),
    .hja3lm6no_t0q         (p8xp4k82_ar          ),
    .oo4ed1ww3q9          (b0zcdbk40ehyx91      ),
    .xvgqjver            (uhgb7m1             ),
    .ajbsjn0thsh            (k3ojutwd             ),
    .bkivycod            (h6gr             ),
    .fgavjah3            (hd3wpzc             ),
    .d9njukh0            (vh518od0             ),
    .ljres1z5            (n_9v             ),
    .re3z_qh            (qauqz             ),
    .e7kvhs6agh            (wkrv7d             ),
    .n0vgfy8z9a_og         (nyfk9pmqi8dby5egm     ),
    .mntm2jd6ths4ryk       (ute24ms4bj6        ),
    .rektx_amz8m3x      (spx966rqubdp       ),
    .br8ywe_g54b133huyhgdt  (bwsa0z3i4jwjoht     ),
    .ri2ziyy            (ri2ziyy     ),
    .r46kf          (r46kf   )
);
wire xc0a8ba6;
wire bgx;
wire vi4;
wire pnddarj;
wire o_i1zvy;
wire f9w0wnh;
wire e66;
wire lphic2z9;
wire habimqi9i3tkrb55ra_trrr;
wire glge190dw8k45s_h = czjn2klzbfd87v & ory71ajyzb6iqa;
wire kspjxip88yrc77d = jsadt688a0178q & fl3gj5l4xbul5a;
assign habimqi9i3tkrb55ra_trrr = ova0029jyhx98hvd;
wire roks7y80biiuvasqy1urx = h44oj_ibu1z0h;
wire ruqqtcsc = bwsa0z3i4jwjoht | glge190dw8k45s_h | kspjxip88yrc77d | habimqi9i3tkrb55ra_trrr | roks7y80biiuvasqy1urx;
wire h3o1wpjw51daxv = (habimqi9i3tkrb55ra_trrr | bwsa0z3i4jwjoht);
wire ktd2oi4na94 = ruqqtcsc;
wire j8__z7fxq = ruqqtcsc;
wire o4ldu9lijmy = ruqqtcsc;
wire sosazw5 = ruqqtcsc;
wire io1l3n34556 = ruqqtcsc;
wire nfm7vbn_ = ruqqtcsc;
wire rvayq62l = ruqqtcsc;
wire u9of83e = ruqqtcsc;
wire e8haab3bpndw = h3o1wpjw51daxv ? 1'b0 : kspjxip88yrc77d ? 1'b1 : 1'b1;
wire u24f0o6e8r = h3o1wpjw51daxv ? 1'b0 : kspjxip88yrc77d ? 1'b0 : 1'b0; 
wire slzj_rlcp2 = 1'b0 ;
wire z8u_7jb74zry = 1'b0 ;
wire xvi80oq9 = 1'b0 ;
wire bggg451 = 1'b0 ;
wire h3tvm2p68w = 1'b0 ;
wire dtlu1rd = 1'b0 ;
e603_gnrl_dfflr #(1) ue7niijlanipl(ktd2oi4na94, e8haab3bpndw, xc0a8ba6, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) unzn9w7cbt(j8__z7fxq, u24f0o6e8r, bgx, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) dkg6ixtgm(o4ldu9lijmy, slzj_rlcp2, vi4, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) necai71lwi9vf(sosazw5, z8u_7jb74zry, pnddarj, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) qq24r1sr0qtsp(io1l3n34556, xvi80oq9, o_i1zvy, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) njnuvwofl7ehx(nfm7vbn_, bggg451, f9w0wnh, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) y50vzm_jv(rvayq62l, h3tvm2p68w, e66, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) mvhvvu0tk0xvq(u9of83e, dtlu1rd, lphic2z9, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
assign imb7nq3h[0] =                     xc0a8ba6;
assign imb7nq3h[1] =                     bgx;
assign imb7nq3h[2] =                     vi4;
assign imb7nq3h[3] =                     pnddarj;
assign imb7nq3h[4] =                     o_i1zvy;
assign imb7nq3h[5] =                     f9w0wnh;
assign imb7nq3h[6] =                     e66;
assign imb7nq3h[7] =                     lphic2z9;
  assign pf4_b0e3ymdaf = b47qcro0nyi;
endmodule
module c7dbsb9r13c71qno837p_rn8l9h  (
    input           mxwg8lfgv4pge1 ,
    output          qi_euczbjhgo1za ,
    input           cuu3goyrnwc9hf  ,
    input  [12-1:0] t3lk20ui52aqc6  ,
    input  [32-1:0] rs8qfdkpko8pq ,
    output          l_geblczxuwi5x4e ,
    input           ptdklfwbs2d13 ,
    output [32-1:0] nuvz1doibyin1uaa ,
    output          cl_8d3kdihjb9yq,
    input           vm78tgdkfetjjfd,
    output          ncpbeb24mmnc60,
    input           flk5mvwbvqzxirah,
    input  [31:0]   hrrr6xbwwneddk,
    output [31:0]   o8sv0e253jptbb2s5,
    input           p7cldie50p2tmud,
    input           n316zisfnflxfgps,
    output [7:0]    wxyxjhortejmt3        ,        
    output [7:0]    wcja3zdd0t7j        ,  
    output [7:0]    rlj4cog5b111mwd      ,  
    output          b47qcro0nyi         ,
    output [11:0]   skbwq1o6wlc     ,
    output [4-1:0]  ct6pxuoq ,
    output          ox3ajqsqp     ,
    output          ws03glm08u787psex3fe ,
    output          cfn05giriyb8lt3_nh ,
    output [2:0]    jyf0lghvzzuj2r    , 
    output [4-1:0]  l3bywjb87dberrlhon,
    output          x7kd6gw9z3nq,
    output          h5fyr6xf,
    output          n28ajivzes3,
    output          s5xq485joofuo,
    output          e36er1uj5tr0,
    output          s6akl1c_8vxk,
    output          nwk_ulhgdn,
    output         r50r4f8sqsa68b,
    output         hby204glk3hbw,
    input          tx071b2z1oij56,  
    input          czz3lmsnukdwivlhf4,
    input          ri2ziyy,
    input          r46kf   
);
  localparam  uwrgm1oivt1de06hok = 3;
  localparam  iv3x8o35w_812gndmsh8q = 3;
  localparam  xvznr0vq3yntjp    = 8;
  localparam  rscjc_sf9gwn       = 8'h00;  
  localparam  nwp00k898h33p         = 8'h10;
  localparam  n27wkt08d_9qfr        = 8'h14;
  localparam  e2ifwcg7u6s6p       = 8'h18;
  localparam  syj63wcjdkr6      = 8'h1c;
  localparam  eij5homjpm2taa     = 8'h30;
  localparam  r6bj0club        = 8'h34; 
  localparam  c6fgkjll7        = 8'h38; 
  localparam  hmpd8hyy0n1          = 8'h40;
  localparam  tcwtege0uvr       = 8'h48;
  localparam  qpypgcrd9t5sc       = 8'h4C;
  localparam  z6ffjin7kt        = 8'h60;
  localparam  fwt0iomyle26tg       = 8'h7C;
  localparam  d85xfrdlyv3h7o       = 8'h50;  
  localparam  l6acur2nvge       = 8'h54; 
  localparam  ju27uois           = 8'h70;    
  localparam  eb2fddy49           = 8'h74;   
  localparam  vqvmx2htkswx92kunr   = 8'hb8;
  localparam  defo1mslx96b30o4y6y   = 8'hbc;
  localparam rjz3ekdeoph_ikp = 4;
  wire q4n0kbcn24onq;
  wire [rjz3ekdeoph_ikp-1:0] uloh18s35kco3lh3;
  wire [rjz3ekdeoph_ikp-1:0] y6ciiggp4rpi5wb;
  localparam fusofx_uxiq0ovvs0pw   = 4'd0;
  localparam rzo5c5uj93mxj6qgh6  = 4'd1;
  localparam fwi10o6jkxn5uz47     = 4'd2;
  localparam a60aiqgftapr3ju  = 4'd3;
  localparam rcw8ushc9tij1lwcoxhy  = 4'd4;
  localparam bqbrwf_ud5q1h54sqk = 4'd6;
  localparam ndbg5krrqovrvfsy3sip  = 4'd7;
  wire [rjz3ekdeoph_ikp-1:0] ifm4f61h58jxyo;
  wire [rjz3ekdeoph_ikp-1:0] vre5wjf3393nlq9x4n;
  wire [rjz3ekdeoph_ikp-1:0] gbhe559k80avm3;
  wire [rjz3ekdeoph_ikp-1:0] uzw1nk84ivcdjr802gaj;
  wire [rjz3ekdeoph_ikp-1:0] on4t7sdr24yw85y;
  wire [rjz3ekdeoph_ikp-1:0] yn411_oev6qy761oz;
  wire [rjz3ekdeoph_ikp-1:0] bv7_kf4mufxex6re;
  wire [rjz3ekdeoph_ikp-1:0] zvhzy3kk4eudv3ur2w;
  wire  f86884rwtdpj4yjo9ubx;
  wire  xwua0g5cuosyyl7bcq22d;
  wire  v0j5p8vof4vfl6halta1d3;
  wire  qr1ktq99r1r7adt9bykuwf6;
  wire  g4hvb6t2tcpvpmy5ztu06wf;
  wire  owspmqpjt3r98k_9ah43l_y;
  wire  gw9f_lxd_td208e1e4w04m6x;
  wire  jbshcx_02es1e2h_z497s;
  wire  bc15m7x5hle8wug30q5d7q   = (y6ciiggp4rpi5wb == fusofx_uxiq0ovvs0pw);
  wire  ockberyjadrlpqs_37a  = (y6ciiggp4rpi5wb == rzo5c5uj93mxj6qgh6);
  wire  ogg3u1an6aww4bf03m     = (y6ciiggp4rpi5wb == fwi10o6jkxn5uz47);
  wire  kmouutgd0lpig6hyyee14r  = (y6ciiggp4rpi5wb == a60aiqgftapr3ju);
  wire  d83it4age7ju2ig84fmx  = (y6ciiggp4rpi5wb == rcw8ushc9tij1lwcoxhy);
  wire  g_qf_dmlhn3danr0v5kobvo = (y6ciiggp4rpi5wb == bqbrwf_ud5q1h54sqk);
  wire  w2fmoslm8laspgvfaed4k1  = (y6ciiggp4rpi5wb == ndbg5krrqovrvfsy3sip);
  wire h9v5e_bsrlv6bm       = mxwg8lfgv4pge1 & qi_euczbjhgo1za;
  wire ngwewd3qoq98          = h9v5e_bsrlv6bm & (~cuu3goyrnwc9hf);
  wire pwpuryi8mwipv          = h9v5e_bsrlv6bm & cuu3goyrnwc9hf;
  wire epepn2mq9892r3p       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == rscjc_sf9gwn );
  wire wbk40x4jp__55kics     = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == eij5homjpm2taa );
  wire u5znxk77_g1_z         = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == nwp00k898h33p   );
  wire acd10fl3i4hy0_       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == e2ifwcg7u6s6p);
  wire e5rf0cne7hld_23o          = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == hmpd8hyy0n1    );
  wire pgx8we2z8eo85u2zq       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == tcwtege0uvr );
  wire td3c7vmwx85jq6       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == qpypgcrd9t5sc );
  wire yyu5li2ei7vimca5im        = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == z6ffjin7kt  );
  wire zwbdbqumqxivnz3c       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == fwt0iomyle26tg );
  wire co99pyyr16nf8_k6pme       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == l6acur2nvge );
  wire a6yhznotyrv9079       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == d85xfrdlyv3h7o );
  wire r11a7tc59btbe3           = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == ju27uois );
  wire n73uhk7tbh3           = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == eb2fddy49 );
  wire mtq827237iwl6m3nog        = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == n27wkt08d_9qfr) ;
  wire pbd0h88k_1zi0qzx7v      = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == syj63wcjdkr6 );
  wire mbmqixpfu6j3yoj       = zwbdbqumqxivnz3c       & ngwewd3qoq98 ;
  wire bon6u_53hv32sbml2h9    = pwpuryi8mwipv & wbk40x4jp__55kics;
  wire q9nyrn1fnpojnu1nr      = pwpuryi8mwipv & epepn2mq9892r3p ;
  wire nsirysuw9mbl        = pwpuryi8mwipv & u5znxk77_g1_z   ;
  wire qaoxt9ifof7fipzkqp      = pwpuryi8mwipv & acd10fl3i4hy0_ ;
  wire mrijmdd3zudmw         = pwpuryi8mwipv & e5rf0cne7hld_23o    ;
  wire jnobdywjfyhd0y1r1      = pwpuryi8mwipv & zwbdbqumqxivnz3c ;
  wire pa3roly_trneoe626fa      = pwpuryi8mwipv & pgx8we2z8eo85u2zq ;
  wire qloxrv_hblxc99      = pwpuryi8mwipv & td3c7vmwx85jq6 ;
  wire lmrge6nnogakzcj_h       = pwpuryi8mwipv & yyu5li2ei7vimca5im  ;
  wire ab0lk338_y29rvfa      = pwpuryi8mwipv & co99pyyr16nf8_k6pme ;
  wire txy1t8oi9vk39z      = pwpuryi8mwipv & a6yhznotyrv9079 ;
  wire x80g5jbypwd          = pwpuryi8mwipv & r11a7tc59btbe3 ;
  wire diiubqnnoktl98          = pwpuryi8mwipv & n73uhk7tbh3 ;
  wire z1c2sicz7azk92bnu       = pwpuryi8mwipv & mtq827237iwl6m3nog  ;
  wire fxrkjbputadb8hotr     = pwpuryi8mwipv & pbd0h88k_1zi0qzx7v ;
  wire kpn_yg_jaia8ik8psl = epepn2mq9892r3p & ngwewd3qoq98;
  wire [32-1:0] kgp5blooskml6;
  wire [32-1:0] nx8trncbxcmnjsqs;
  wire [32-1:0] gy5_oufo39di;
  assign gy5_oufo39di[32-1:12] = {32-12{1'b0}}; 
  assign nx8trncbxcmnjsqs[32-1:12] = {32-12{1'b0}}; 
  assign nx8trncbxcmnjsqs[11:0] = 
                               rs8qfdkpko8pq[11:0]
                               ;
  wire onxh11t4cdz9pchdb =  
                      kpn_yg_jaia8ik8psl
                      ; 
e603_gnrl_dfflr  #(9) z20addxodsm9ltbgw  (onxh11t4cdz9pchdb, nx8trncbxcmnjsqs[11:3], gy5_oufo39di[11:3], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs  #(1) uj4nkiluquun5__cml  (onxh11t4cdz9pchdb, nx8trncbxcmnjsqs[2], gy5_oufo39di[2], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(2)  wm3nc9v7vu9i3jgxa36eh (onxh11t4cdz9pchdb, nx8trncbxcmnjsqs[1:0] , gy5_oufo39di[1:0] , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign kgp5blooskml6 = gy5_oufo39di; 
  wire [32-1:0] kotpmur20yj = {32{1'b0}} ;
  wire [3:0] gc_4r7kp5ay;
  wire [3:0] mh9gcqb9defvciwsq0 = 
                           rs8qfdkpko8pq[3:0]
                           ;
  wire nfpm5qrwm2qbhwntm_ = mtq827237iwl6m3nog & ngwewd3qoq98;
  wire at8sdjatuu_q0qa2 =  
                      nfpm5qrwm2qbhwntm_
                     ;
e603_gnrl_dfflrs #(4) sflhd4uw7er3iu1_n3h (at8sdjatuu_q0qa2, mh9gcqb9defvciwsq0, gc_4r7kp5ay, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [1:0] feezr3ilynyw_;
  wire [1:0] qb4qrc1w0pfijnk_4 = 
                            rs8qfdkpko8pq[1:0]
                            ;
  wire g8j80_cad8jz6q66blm = acd10fl3i4hy0_ & ngwewd3qoq98;
  wire fknaf4ltv5so0t = g8j80_cad8jz6q66blm
                        ;
e603_gnrl_dfflr #(2) vk2q35gouxdxc5atgs (fknaf4ltv5so0t, qb4qrc1w0pfijnk_4, feezr3ilynyw_, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [uwrgm1oivt1de06hok:0] mofrlxl7m7urtxqr;
  wire [uwrgm1oivt1de06hok:0] xq9b42z9zvnsvbaueu = rs8qfdkpko8pq[uwrgm1oivt1de06hok:0];
  wire duarqge0f5e4e2x = a6yhznotyrv9079 & ngwewd3qoq98;
e603_gnrl_dfflr #(uwrgm1oivt1de06hok+1) p46332x_6tr5_ikok (duarqge0f5e4e2x, xq9b42z9zvnsvbaueu, mofrlxl7m7urtxqr, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [uwrgm1oivt1de06hok:0] e6vwmn86c8xet;
  wire [uwrgm1oivt1de06hok:0] xwxz_nznyxl94zn8 = rs8qfdkpko8pq[uwrgm1oivt1de06hok:0];
  wire vabmw735jqke9dvqcu = co99pyyr16nf8_k6pme & ngwewd3qoq98;
e603_gnrl_dfflr #(uwrgm1oivt1de06hok+1) pubg23g629ijtdcgpvr6l (vabmw735jqke9dvqcu, xwxz_nznyxl94zn8, e6vwmn86c8xet, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [12:0] zeduiili;
  wire [12:0] x5srxysxge1kr = rs8qfdkpko8pq[12:0];
  wire c1vptbt0n3ebql9 = r11a7tc59btbe3 & ngwewd3qoq98;
e603_gnrl_dfflr #(13) bgwnhi7w9e9sqi (c1vptbt0n3ebql9, x5srxysxge1kr, zeduiili, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire zbsctoufec ;
  wire tti5_1lfgdqgg ;
  wire [32-1:0] djkt53av;
  wire [32-1:0] ci8cqow0863foo;
  wire [32-1:0] ayozbds9d7v2;
  assign ayozbds9d7v2[32-1:3] = {32-3{1'b0}};
  assign ci8cqow0863foo[32-1:3] = {32-3{1'b0}};
  assign ci8cqow0863foo[2:0] =
                           rs8qfdkpko8pq[2:0]
                           ;
  wire nni23aobanchjo = u5znxk77_g1_z & ngwewd3qoq98;
  wire wv9nrh6sq4t95p = 
                     nni23aobanchjo
                    ;
e603_gnrl_dfflr  #(2)  j1h1xt7sslwawkx6i7zs  (wv9nrh6sq4t95p, ci8cqow0863foo[2:1], ayozbds9d7v2[2:1], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) uyxntnnuizzn0np3xr (wv9nrh6sq4t95p, ci8cqow0863foo[0]  , ayozbds9d7v2[0]  , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign djkt53av = ayozbds9d7v2; 
  wire w7emkdff095zjadmn ;
  wire [4-1:0] qep0jq76;
  wire [4-1:0] l8eh87f44nszse;
  wire [4-1:0] qw4_vjfxjzwhy1;
  wire [4-1:0] msp69r0yqmgtv_;
 wire vpba27za75ukaza = (bc15m7x5hle8wug30q5d7q | w2fmoslm8laspgvfaed4k1);
 wire l7y3g7yhwpceeg5rslp  = (feezr3ilynyw_ == 2'b11);
 wire y7k_oedq1s8983d6cg3xq = (feezr3ilynyw_ == 2'b00);
 wire zg7rrx2i7beooz = (ayozbds9d7v2[2:0] == 3'h1);
 wire l1ze8_qxjyvnw = (ayozbds9d7v2[2:0] == 3'h2);
 wire jplx9kbbwmxeb = (ayozbds9d7v2[2:0] == 3'h3);
 wire nliipzu0uv09_ = (ayozbds9d7v2[2:0] == 3'h4);
 assign qw4_vjfxjzwhy1 = {4{vpba27za75ukaza}};
 wire [3:0] uyw_zeds4iqsswdu5t;
 assign uyw_zeds4iqsswdu5t[0] = (zg7rrx2i7beooz & f86884rwtdpj4yjo9ubx);
 assign uyw_zeds4iqsswdu5t[1] = (l1ze8_qxjyvnw & f86884rwtdpj4yjo9ubx);
 assign uyw_zeds4iqsswdu5t[2] = (jplx9kbbwmxeb & f86884rwtdpj4yjo9ubx);
 assign uyw_zeds4iqsswdu5t[3] = (nliipzu0uv09_ & f86884rwtdpj4yjo9ubx);
 assign w7emkdff095zjadmn = vpba27za75ukaza;
 assign l3bywjb87dberrlhon = vpba27za75ukaza ? {4{1'b1}} : {4{1'b0}};
    assign msp69r0yqmgtv_[0] = uyw_zeds4iqsswdu5t[0]   ? (l7y3g7yhwpceeg5rslp ? gc_4r7kp5ay[0] : ~gc_4r7kp5ay[0]) : 
                           w7emkdff095zjadmn    ? gc_4r7kp5ay[0] : 
                           qep0jq76[0];
    assign msp69r0yqmgtv_[1] = uyw_zeds4iqsswdu5t[1]   ? (l7y3g7yhwpceeg5rslp ? gc_4r7kp5ay[1] : ~gc_4r7kp5ay[1]) : 
                           w7emkdff095zjadmn    ? gc_4r7kp5ay[1] : 
                           qep0jq76[1];
    assign msp69r0yqmgtv_[2] = uyw_zeds4iqsswdu5t[2]   ? (l7y3g7yhwpceeg5rslp ? gc_4r7kp5ay[2] : ~gc_4r7kp5ay[2]) : 
                           w7emkdff095zjadmn    ? gc_4r7kp5ay[2] : 
                           qep0jq76[2];
    assign msp69r0yqmgtv_[3] = uyw_zeds4iqsswdu5t[3]   ? (l7y3g7yhwpceeg5rslp ? gc_4r7kp5ay[3] : ~gc_4r7kp5ay[3]) : 
                           w7emkdff095zjadmn    ? gc_4r7kp5ay[3] : 
                           qep0jq76[3];
e603_gnrl_dfflrs #(1) jxzj2i53vrsoi7c2kw8 (qw4_vjfxjzwhy1[0], msp69r0yqmgtv_[0], qep0jq76[0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) o6bxdnw_c5a3gky (qw4_vjfxjzwhy1[1], msp69r0yqmgtv_[1], qep0jq76[1], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) s7fgohso6c81fkg85xf (qw4_vjfxjzwhy1[2], msp69r0yqmgtv_[2], qep0jq76[2], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) sb8r5623ls_poynlmh4 (qw4_vjfxjzwhy1[3], msp69r0yqmgtv_[3], qep0jq76[3], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign ws03glm08u787psex3fe = w7emkdff095zjadmn;
  assign jyf0lghvzzuj2r = ayozbds9d7v2[2:0];
  wire [4-1:0] gkgvqvfrk = qw4_vjfxjzwhy1[4-1:0] & ~msp69r0yqmgtv_[4-1:0];
  assign cfn05giriyb8lt3_nh = | gkgvqvfrk;
  assign wcja3zdd0t7j = 8'h1;
  assign wxyxjhortejmt3 = 8'h1;
  assign rlj4cog5b111mwd = 8'h3;
  wire[7:0] a_bgxqheqciovw = 8'h1;
  wire fe42y4i10dewgs = e5rf0cne7hld_23o & ngwewd3qoq98;
  wire xq7qf61273u5y;
  wire rr33mlsfy76373t8 = rs8qfdkpko8pq[3];
e603_gnrl_dfflr #(1) e7jenyhsj (fe42y4i10dewgs, rr33mlsfy76373t8, xq7qf61273u5y, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] qwt1j4hjghsmr = 6'd24;
  wire sl4ttjb9n    = xq7qf61273u5y; 
  wire yjft76clnp2 = 1'b0;
  wire [32-1:0] imbil89a = {28'h0,xq7qf61273u5y,3'b0};
  wire ynbslsmnmrehvg0nose = (pgx8we2z8eo85u2zq & ngwewd3qoq98);
  wire [32-1:0] rn1wjuyhggw7zs5di;
  wire [32-1:0] f3w8nma6ylg1;
  wire [31:0] mayljr44hqkdgz8k9;
  wire pvwox3mme99p9z5sn;
  wire fgxd4644gxcmuttkef21c = 
                           (~ncpbeb24mmnc60 & (
                            (ogg3u1an6aww4bf03m ) | ((~ox3ajqsqp) & p7cldie50p2tmud)
                            ))
                           ;
  wire k5ickrmbar6_1ye9ozzzcwk = 
                              pvwox3mme99p9z5sn & fgxd4644gxcmuttkef21c;
  wire t0keqyysv;
  assign rn1wjuyhggw7zs5di = mayljr44hqkdgz8k9;
e603_gnrl_dfflr #(32) ixt5fjigyr0okem3ovv9 (k5ickrmbar6_1ye9ozzzcwk, rn1wjuyhggw7zs5di, f3w8nma6ylg1, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign o8sv0e253jptbb2s5 = f3w8nma6ylg1; 
  wire jy7s673fglq2u5 = k5ickrmbar6_1ye9ozzzcwk ;
  wire yujscvbq4tk79u = t0keqyysv & ((n316zisfnflxfgps 
                                  ) 
                                  );
  wire mycmowvm46blrhf = jy7s673fglq2u5 | yujscvbq4tk79u;
  wire f8_n22932wmw7 = jy7s673fglq2u5 & (~yujscvbq4tk79u);
e603_gnrl_dfflr #(1) h4grp85znzmd5gvc (mycmowvm46blrhf, f8_n22932wmw7, t0keqyysv, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign ncpbeb24mmnc60 = t0keqyysv
                        ;
  wire m3fnojf8;
  wire owk52e9vhva0t5e =                      pvwox3mme99p9z5sn & ogg3u1an6aww4bf03m  & (~ox3ajqsqp ) 
                    ;
  wire aihepbv5jhuay3 = m3fnojf8 & ((p7cldie50p2tmud 
                                  ) 
                                 );
  wire dhc21evq84sx2 = owk52e9vhva0t5e | aihepbv5jhuay3;
  wire rrxivtwrk0qjosw8 = owk52e9vhva0t5e & (~aihepbv5jhuay3);
e603_gnrl_dfflr #(1) iftoicgsrexio4 (dhc21evq84sx2, rrxivtwrk0qjosw8, m3fnojf8, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign cl_8d3kdihjb9yq = m3fnojf8;
  wire atk5__oo8ry9agn55;
  wire qyi3776887dt1t5lz9qikwb = p7cldie50p2tmud; 
  wire fixmlbbr00mmtj5k1ffvc8s = atk5__oo8ry9agn55;
  wire ix32yvy58qjp2q55g_puwhw = qyi3776887dt1t5lz9qikwb |   fixmlbbr00mmtj5k1ffvc8s;
  wire ri0i9pv4zai44n6obve4 = qyi3776887dt1t5lz9qikwb & (~fixmlbbr00mmtj5k1ffvc8s);
e603_gnrl_dfflr #(1) bbd9inqbyijmo146ah8ufn86 (ix32yvy58qjp2q55g_puwhw, ri0i9pv4zai44n6obve4, atk5__oo8ry9agn55, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire hw2_09ycnst3ssuom = yyu5li2ei7vimca5im & ngwewd3qoq98;
  wire [32-1:0] s_8xu2_w6;
  wire [32-1:0] ruo4nrkybw67lyk2og;
  wire [32-1:0] rgb_qzyt7kwj;
  assign rgb_qzyt7kwj[32-1:1] = {32-1{1'b0}};
  assign ruo4nrkybw67lyk2og[32-1:1] = {32-1{1'b0}};
  assign ruo4nrkybw67lyk2og[0] = rs8qfdkpko8pq[0];
e603_gnrl_dfflrs #(1) c3shm3ufut8ou0qs1xlr(hw2_09ycnst3ssuom, ruo4nrkybw67lyk2og[0], rgb_qzyt7kwj[0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign s_8xu2_w6 = rgb_qzyt7kwj; 
  assign b47qcro0nyi = rgb_qzyt7kwj[0];
  wire [32-1:0] wm09ws0imtmzax_;
  wire [32-1:0] a6sqww5ddu2ippd;
  assign a6sqww5ddu2ippd[32-1:1] = {32-1{1'b0}};
  wire xsp82r3t5we3mic_t;
  wire l0mhmvps9ahqx707_xk;
  wire jiid1w5cr1slni5_ikvqq;
  wire vxo9du3kta26kavbuy3;
  wire qw7478p_rf;
  wire iubdhaguqysp7;
  wire cn9pinb7654u8wxqj;
  wire fzj4a4cx4rzlew;
  wire lqnef62s4hwx;
  wire mf_zs3249h_a4x = 1'b0;
  wire e9jkv1cxs4qd59af = 1'b0;
  wire na5y9d7jv2h;
  wire gahrcz9vaqa6qouy = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[13] ? 1'b0 : na5y9d7jv2h) 
                  : (
                    lqnef62s4hwx
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire xs4o29u5e0iti = mbmqixpfu6j3yoj | lqnef62s4hwx ;
e603_gnrl_dfflr #(1) goa4ktz7y42bht92qd (xs4o29u5e0iti, gahrcz9vaqa6qouy, na5y9d7jv2h, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire n9pppoyv5k5_f9t9;
  wire znce576bxuk43mrhe = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[17] ? 1'b0 : n9pppoyv5k5_f9t9) 
                  : (
                    mf_zs3249h_a4x
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire cxsswxq959aa1p77b = mbmqixpfu6j3yoj | mf_zs3249h_a4x ;
e603_gnrl_dfflr #(1) eoavobqwwr8ww_gw1 (cxsswxq959aa1p77b, znce576bxuk43mrhe, n9pppoyv5k5_f9t9, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire z3ul22jtdz00ut1k7d;
  wire unn1u50brmolz4g = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[18] ? 1'b0 : z3ul22jtdz00ut1k7d) 
                  : (
                    e9jkv1cxs4qd59af
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire o7j8ctdfsiwj5wha = mbmqixpfu6j3yoj | e9jkv1cxs4qd59af ;
e603_gnrl_dfflr #(1) k7ijswfu91vhowdyee1t9 (o7j8ctdfsiwj5wha, unn1u50brmolz4g, z3ul22jtdz00ut1k7d, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire qb16r5rqj221;
  wire nfs3gw983k2ou3lzw = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[2] ? 1'b0 : qb16r5rqj221) 
                  : (
                      cn9pinb7654u8wxqj 
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire p11uo34tf5bz0u = mbmqixpfu6j3yoj
                     | cn9pinb7654u8wxqj
                     ;
e603_gnrl_dfflr #(1) m2yzqef1976ypq0_n5zp (p11uo34tf5bz0u, nfs3gw983k2ou3lzw, qb16r5rqj221, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire s00qfpzglap1i;
  wire oe5pk8ehsypb7 = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[10] ? 1'b0 : s00qfpzglap1i) 
                  : (
                    iubdhaguqysp7
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire jf7prpwpaazy3 = mbmqixpfu6j3yoj | iubdhaguqysp7 ;
e603_gnrl_dfflr #(1) qwltw741eze1dz_m3rfs (jf7prpwpaazy3, oe5pk8ehsypb7, s00qfpzglap1i, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire b5kvjbvx20ih;
  wire pwgn5esxevr02b1tk0 = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[9] ? 1'b0 : b5kvjbvx20ih) 
                  : (
                    qw7478p_rf
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire q6i08fscm9ap30 = mbmqixpfu6j3yoj | qw7478p_rf ;
e603_gnrl_dfflr #(1) wpg3oonmp64c9t3 (q6i08fscm9ap30, pwgn5esxevr02b1tk0, b5kvjbvx20ih, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire k6ip5n_ug6gf;
  wire ytl9e5648sn_rs95q = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[3] ? 1'b0 : k6ip5n_ug6gf) 
                  : (
                     1'b0 
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire au9ddsas5wgi8_ = mbmqixpfu6j3yoj 
                     ;
e603_gnrl_dfflr #(1) y2xqm899418rwf55ih0 (au9ddsas5wgi8_, ytl9e5648sn_rs95q, k6ip5n_ug6gf, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire b23weoeqvbcpi = ((m3fnojf8 | t0keqyysv | pvwox3mme99p9z5sn) 
                 ) 
                ;
  assign lqnef62s4hwx = (~pvwox3mme99p9z5sn) & (p7cldie50p2tmud | n316zisfnflxfgps); 
  wire [1:0] h8umhwypy1r ;
  wire [31:0] b7u0bi5hb1z_vqjux = (rs8qfdkpko8pq << qwt1j4hjghsmr );
  wire g9_4lin46u2wy99gpe = ynbslsmnmrehvg0nose ; 
  wire [uwrgm1oivt1de06hok:0] rennjjy_nc;
  wire [uwrgm1oivt1de06hok:0] je8cka;
  wire gaq8kka6y = (mofrlxl7m7urtxqr > rennjjy_nc) ;
  wire uml7j8 = (e6vwmn86c8xet < je8cka) ;
  assign h8umhwypy1r = {uml7j8,gaq8kka6y};
  assign x7kd6gw9z3nq = gaq8kka6y & zeduiili[0];
  assign h5fyr6xf = uml7j8 & zeduiili[1];
  assign n28ajivzes3 = k6ip5n_ug6gf & zeduiili[2];
  assign s6akl1c_8vxk = qb16r5rqj221 & zeduiili[3];
  assign e36er1uj5tr0 = b5kvjbvx20ih & zeduiili[4];
  assign s5xq485joofuo = s00qfpzglap1i & zeduiili[5];
  assign r50r4f8sqsa68b = n9pppoyv5k5_f9t9 & zeduiili[11];
  assign hby204glk3hbw = z3ul22jtdz00ut1k7d & zeduiili[12];
  assign nwk_ulhgdn = na5y9d7jv2h & zeduiili[7];
  wire [31:0] qtc2ecqw8avvpn3vyd0w =                                 hrrr6xbwwneddk;
  wire fi9mj723yx7orlqv1 =                           atk5__oo8ry9agn55 ;
  wire n60xjqp99fixz2hsxng = qloxrv_hblxc99;
  wire [31:0] mhhnyw4dlr5951adq1;
  wire exacfh;
  wire yup5261m740 = 
                1'b0
                ;
  wire [31:0] zptbumcdjxm;
  wire x16h6ro6uw6m28b;
  wire b_3r1wceva9dnvgcelb =                         fgxd4644gxcmuttkef21c
                         ;
  wire [uwrgm1oivt1de06hok:0] ek75hkocd0n ;
  wire sst4jkigjufnpppy016 =                         g9_4lin46u2wy99gpe 
                         ;
  wire [31:0] s4l4bqtrr8c=                         (
                           {32{g9_4lin46u2wy99gpe}} & b7u0bi5hb1z_vqjux
                         )
                         ;
  wire qe6820s7_06iexqii ;
  assign pvwox3mme99p9z5sn =                             x16h6ro6uw6m28b
                             ;
  assign mayljr44hqkdgz8k9 =                             zptbumcdjxm;
  assign rennjjy_nc = ek75hkocd0n;
  wire [31:0] o1a2rfpyxis;
  wire a38bdhto5nau6l_dz7;
  wire rgiz9sdg5d49hp_ =                         n60xjqp99fixz2hsxng
                         ;
  wire [uwrgm1oivt1de06hok:0] wl0o9oj2zq;
  wire ga6dx697qza1xfad =                         fi9mj723yx7orlqv1;
  wire [31:0] cpoxqahi7 =                         qtc2ecqw8avvpn3vyd0w
                         ;
  wire lyrng9kkt0anbth8k3mb;
  assign mhhnyw4dlr5951adq1 = o1a2rfpyxis;
  assign je8cka = wl0o9oj2zq;
 zdd42ray6lu4u4hhyocrugb
#(
    .ra2aj3fukykd9j   (32),
    .fmv57175hz8809 (8),
    .xi5np3lftgtezged(uwrgm1oivt1de06hok)
)
 dym61hqug_7zg6dfakdbb5jg6z
(
    .lczv3cn     (ri2ziyy),
    .r38027_km3    (r46kf),
    .jm5sdmj     (exacfh),
    .lyg_g62ta     (yup5261m740),
    .ho56_v0li6     (zbsctoufec), 
    .aqikf5g    (zptbumcdjxm),
    .al_bfsrdm   (x16h6ro6uw6m28b),
    .cadqltzy   (b_3r1wceva9dnvgcelb),
    .jov1vyjapbtr(ek75hkocd0n),
    .pxdlrpyubv4n   (sst4jkigjufnpppy016),
    .ygli0hkz    (s4l4bqtrr8c),
    .euwxj8gh   (qe6820s7_06iexqii)
);
 zdd42ray6lu4u4hhyocrugb
#(
    .ra2aj3fukykd9j   (32),
    .fmv57175hz8809 (8),
    .xi5np3lftgtezged(uwrgm1oivt1de06hok)
)
 ro_2mmzlemg3ktni24fpw5xvj
(
    .lczv3cn     (ri2ziyy),
    .r38027_km3    (r46kf),
    .jm5sdmj     (),
    .lyg_g62ta     (1'b0),
    .ho56_v0li6     (tti5_1lfgdqgg), 
    .aqikf5g    (o1a2rfpyxis),
    .al_bfsrdm   (a38bdhto5nau6l_dz7),
    .cadqltzy   (rgiz9sdg5d49hp_),
    .jov1vyjapbtr(wl0o9oj2zq),
    .pxdlrpyubv4n   (ga6dx697qza1xfad),
    .ygli0hkz    (cpoxqahi7),
    .euwxj8gh   (lyrng9kkt0anbth8k3mb)
);
  assign xsp82r3t5we3mic_t = ~qe6820s7_06iexqii;
  assign l0mhmvps9ahqx707_xk = ~x16h6ro6uw6m28b;
  assign vxo9du3kta26kavbuy3 = ~lyrng9kkt0anbth8k3mb;
  assign jiid1w5cr1slni5_ikvqq = ~a38bdhto5nau6l_dz7;
  assign qw7478p_rf = jiid1w5cr1slni5_ikvqq & qloxrv_hblxc99;
  assign iubdhaguqysp7 = xsp82r3t5we3mic_t & ynbslsmnmrehvg0nose; 
  assign cn9pinb7654u8wxqj = (~lyrng9kkt0anbth8k3mb) & ga6dx697qza1xfad;
  assign wm09ws0imtmzax_ = {a6sqww5ddu2ippd[32-1:19]
                      , z3ul22jtdz00ut1k7d
                      , n9pppoyv5k5_f9t9
                      ,3'b0
                      , na5y9d7jv2h
                      , vxo9du3kta26kavbuy3
                      , l0mhmvps9ahqx707_xk
                      , s00qfpzglap1i
                      , b5kvjbvx20ih
                      ,3'b0
                      , jiid1w5cr1slni5_ikvqq 
                      , xsp82r3t5we3mic_t 
                      , k6ip5n_ug6gf 
                      , qb16r5rqj221 
                      , 1'b0 
                      , b23weoeqvbcpi
                      }; 
  assign zbsctoufec   = 
                     1'b0
                    ;
  assign tti5_1lfgdqgg   = 
                     1'b0
                     ;
   wire k9yojkkogtjsxw  = fknaf4ltv5so0t & (qb4qrc1w0pfijnk_4 != feezr3ilynyw_);
   wire e316xxglmnibqx1    = wv9nrh6sq4t95p & (ci8cqow0863foo != ayozbds9d7v2);
   wire xoqno0i3pgtg   = at8sdjatuu_q0qa2 & (mh9gcqb9defvciwsq0 != gc_4r7kp5ay);
   wire kunfd4wlftlgm = k9yojkkogtjsxw 
                 | e316xxglmnibqx1
                 | xoqno0i3pgtg 
                 ;
   wire jxtrp3knsg1l3;
   wire gbg5c5sdmqe99r = kunfd4wlftlgm; 
   wire on317ip1wrjktpvm = bc15m7x5hle8wug30q5d7q;
   wire f_xgrj5an9z1lcnh = gbg5c5sdmqe99r | on317ip1wrjktpvm;
   wire jphhtdx77k3d8n3m = (~on317ip1wrjktpvm);
e603_gnrl_dfflr #(1) cjwd0hux__761d (f_xgrj5an9z1lcnh, jphhtdx77k3d8n3m, jxtrp3knsg1l3, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
   wire [7:0] hxli5ec7iajmat7tw0w;
   wire dhmf_sxidpgdap7jhncn = ockberyjadrlpqs_37a 
                          | kmouutgd0lpig6hyyee14r 
                          | g_qf_dmlhn3danr0v5kobvo 
                          | w2fmoslm8laspgvfaed4k1
                          ;
   wire s37pm1eoafc1j_bcexdj2 = xwua0g5cuosyyl7bcq22d
                          | qr1ktq99r1r7adt9bykuwf6
                          | gw9f_lxd_td208e1e4w04m6x
                          | jbshcx_02es1e2h_z497s
                          ;
   wire ib_7od4i9qlkr6s53 = dhmf_sxidpgdap7jhncn | s37pm1eoafc1j_bcexdj2;
   wire [7:0] gb5q2c3_jm5_b_0p_lno6 = 
                                    s37pm1eoafc1j_bcexdj2 ? 8'b0
                                  : dhmf_sxidpgdap7jhncn ? (hxli5ec7iajmat7tw0w + 8'b1)
                                  : hxli5ec7iajmat7tw0w
                                  ;
e603_gnrl_dfflr #(8) lqvqq4a7ws3n6e990cua1ba1 (ib_7od4i9qlkr6s53, gb5q2c3_jm5_b_0p_lno6, hxli5ec7iajmat7tw0w, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    assign f86884rwtdpj4yjo9ubx = bc15m7x5hle8wug30q5d7q & pvwox3mme99p9z5sn;
    assign ifm4f61h58jxyo = a60aiqgftapr3ju;
    assign xwua0g5cuosyyl7bcq22d = (hxli5ec7iajmat7tw0w == wxyxjhortejmt3 ) & ockberyjadrlpqs_37a;
    assign vre5wjf3393nlq9x4n = ndbg5krrqovrvfsy3sip ;
    assign v0j5p8vof4vfl6halta1d3 =                               n316zisfnflxfgps & ogg3u1an6aww4bf03m
                              ;
    assign gbhe559k80avm3 = bqbrwf_ud5q1h54sqk;
    assign qr1ktq99r1r7adt9bykuwf6 = (hxli5ec7iajmat7tw0w == wcja3zdd0t7j ) & kmouutgd0lpig6hyyee14r; 
    assign uzw1nk84ivcdjr802gaj = fwi10o6jkxn5uz47;
    wire cn7l2sqt9fy = jxtrp3knsg1l3 | (s_8xu2_w6[0] == 1'b1) | y7k_oedq1s8983d6cg3xq;
    assign g4hvb6t2tcpvpmy5ztu06wf = (pvwox3mme99p9z5sn | cn7l2sqt9fy) &  d83it4age7ju2ig84fmx;
    assign on4t7sdr24yw85y = (~pvwox3mme99p9z5sn | cn7l2sqt9fy) ? rzo5c5uj93mxj6qgh6 : fwi10o6jkxn5uz47 ;
    assign gw9f_lxd_td208e1e4w04m6x = ((hxli5ec7iajmat7tw0w == a_bgxqheqciovw) | cn7l2sqt9fy ) & g_qf_dmlhn3danr0v5kobvo;
    assign bv7_kf4mufxex6re = (~pvwox3mme99p9z5sn | cn7l2sqt9fy) ? rcw8ushc9tij1lwcoxhy : fwi10o6jkxn5uz47; 
    assign jbshcx_02es1e2h_z497s = (hxli5ec7iajmat7tw0w == rlj4cog5b111mwd ) & w2fmoslm8laspgvfaed4k1; 
    assign zvhzy3kk4eudv3ur2w = fusofx_uxiq0ovvs0pw;
    assign q4n0kbcn24onq =    f86884rwtdpj4yjo9ubx
                            | xwua0g5cuosyyl7bcq22d
                            | v0j5p8vof4vfl6halta1d3
                            | qr1ktq99r1r7adt9bykuwf6
                            | g4hvb6t2tcpvpmy5ztu06wf
                            | gw9f_lxd_td208e1e4w04m6x
                            | jbshcx_02es1e2h_z497s
                            ;
    assign uloh18s35kco3lh3 =    ({rjz3ekdeoph_ikp{f86884rwtdpj4yjo9ubx  }} ) & ifm4f61h58jxyo    
                            | ({rjz3ekdeoph_ikp{xwua0g5cuosyyl7bcq22d }} ) & vre5wjf3393nlq9x4n   
                            | ({rjz3ekdeoph_ikp{v0j5p8vof4vfl6halta1d3    }} ) & gbhe559k80avm3      
                            | ({rjz3ekdeoph_ikp{qr1ktq99r1r7adt9bykuwf6 }} ) & uzw1nk84ivcdjr802gaj   
                            | ({rjz3ekdeoph_ikp{g4hvb6t2tcpvpmy5ztu06wf }} ) & on4t7sdr24yw85y    
                            | ({rjz3ekdeoph_ikp{gw9f_lxd_td208e1e4w04m6x}} ) & bv7_kf4mufxex6re   
                            | ({rjz3ekdeoph_ikp{jbshcx_02es1e2h_z497s }} ) & zvhzy3kk4eudv3ur2w   
                            ;
e603_gnrl_dfflr #(rjz3ekdeoph_ikp) a39xlwwmub899evw (q4n0kbcn24onq, uloh18s35kco3lh3, y6ciiggp4rpi5wb, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [32-1:0] mq9n48gbif_cl6qzi = 
                         ({32{q9nyrn1fnpojnu1nr }} & kgp5blooskml6  )
                       | ({32{nsirysuw9mbl   }} & djkt53av    )
                       | ({32{mrijmdd3zudmw    }} & imbil89a     )
                       | ({32{jnobdywjfyhd0y1r1 }} & wm09ws0imtmzax_  )
                       | ({32{pa3roly_trneoe626fa }} & 32'h0)
                       | ({32{qloxrv_hblxc99 }} & mhhnyw4dlr5951adq1) 
                       | ({32{lmrge6nnogakzcj_h  }} & s_8xu2_w6   )
                       | ({32{bon6u_53hv32sbml2h9}} & { {{15-uwrgm1oivt1de06hok{1'b0}},wl0o9oj2zq} , {{15-uwrgm1oivt1de06hok{1'b0}},ek75hkocd0n} } )
                       | ({32{txy1t8oi9vk39z }} & {{31-uwrgm1oivt1de06hok{1'b0}} , mofrlxl7m7urtxqr}  )
                       | ({32{ab0lk338_y29rvfa }} & {{31-uwrgm1oivt1de06hok{1'b0}} , e6vwmn86c8xet}  )
                       | ({32{x80g5jbypwd }}     & {19'h0 , zeduiili}  )
                       | ({32{diiubqnnoktl98 }}     & {30'h0, h8umhwypy1r}  )
                       | ({32{qaoxt9ifof7fipzkqp}}  & {30'h0 , feezr3ilynyw_})
                       | ({32{z1c2sicz7azk92bnu}}   & {28'h0 , gc_4r7kp5ay})
                       | ({32{fxrkjbputadb8hotr}} & {32'hee010102})
                       ;
  wire ob8z8livyemha710u ;
  wire kskb11shhtzrtgvpid4sm;
  wire [32-1:0] t3ry9gk2ep_3qyfvsrb9u;
  wire n3w802chksaybtkdgd_xl = mxwg8lfgv4pge1 
                         ;
  wire jesyol8j2mzc9p7rg;
  assign qi_euczbjhgo1za = jesyol8j2mzc9p7rg 
                       ;
  e603_gnrl_pipe_stage # (
    .CUT_READY (0),
    .DP  (1),
    .DW  (32)
  ) wap11wkgzhcg0r14 (
    .i_vld(n3w802chksaybtkdgd_xl),
    .i_rdy(jesyol8j2mzc9p7rg),
    .i_dat(mq9n48gbif_cl6qzi ),
    .o_vld(ob8z8livyemha710u),
    .o_rdy(kskb11shhtzrtgvpid4sm),  
    .o_dat(t3ry9gk2ep_3qyfvsrb9u ),  
    .clk  (ri2ziyy),
    .rst_n(r46kf)
  );
  assign l_geblczxuwi5x4e = ob8z8livyemha710u;
  assign kskb11shhtzrtgvpid4sm = ptdklfwbs2d13;
  assign nuvz1doibyin1uaa = t3ry9gk2ep_3qyfvsrb9u;
  assign skbwq1o6wlc     = kgp5blooskml6[11:0];
  assign ct6pxuoq      = qep0jq76[4-1:0];
  assign ox3ajqsqp     = sl4ttjb9n;
endmodule
module dy1w1n4e1pybfxg8fd6i1ato7z (
    input                         m06qnpn5a9z03 ,
    input [11:0]                  mvqrtq7dyd0jl4,
    input [4-1:0]   wgc1pcq7e4,
    input                         qtsnhkdndbh,
    input                         d9n3ph7pubth72d7c,
    output                        br7a8dw5rndor ,
    output                        b3nk3ml5dggetwx1,
    output                        fekszkc1bqs8x6b ,
    input          ri2ziyy,
    input          r46kf   
);
  wire qep0jq76 = |(~wgc1pcq7e4);
  wire jeofasr36jmwmq;
  wire xc7_xs2vqt4n;
  wire [11:0] wo49jzbbu6fbz;
  wire hhgym7xmgcc = m06qnpn5a9z03;
  wire zceqt5b33i6v5 = (wo49jzbbu6fbz == mvqrtq7dyd0jl4) & m06qnpn5a9z03;
  wire bx1xzn4pq8z9xkym1 = (wo49jzbbu6fbz == (mvqrtq7dyd0jl4 >> 1)) & m06qnpn5a9z03;
  wire [11:0] f40rnvxkoxtnx6 = zceqt5b33i6v5 ? 12'd0 : m06qnpn5a9z03 ? wo49jzbbu6fbz + 12'b1 : 12'd0;
e603_gnrl_dfflr #(12) o7meg9r4kkuqm7r (hhgym7xmgcc, f40rnvxkoxtnx6, wo49jzbbu6fbz, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] sy5ie2qsz3;
  wire by__ur08rbz;
  wire n29o3het1l1nplu24 = qep0jq76 ? ( zceqt5b33i6v5 ? ~by__ur08rbz : by__ur08rbz) : 1'b0 ;
  wire e8203izp0du = 
                    n29o3het1l1nplu24
                    ;
  wire d8mr2tqvctz1xawkasq = qep0jq76 ? (m06qnpn5a9z03 & zceqt5b33i6v5 ) : 1'b1;
  wire t7f5bmyuhos = 
                  d8mr2tqvctz1xawkasq
                  ;
e603_gnrl_dfflr #(1) z6q5exenw6jshhx_j (t7f5bmyuhos, e8203izp0du, by__ur08rbz, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign jeofasr36jmwmq = (1'b0 ^ by__ur08rbz) & zceqt5b33i6v5 ;
  assign xc7_xs2vqt4n = (~(1'b0 ^ by__ur08rbz)) & zceqt5b33i6v5;
  wire lsn15dh7f2_tahg = (xc7_xs2vqt4n
                      )
                      ;
  wire o4okrtw26smjv = 1'b1;
  wire bw6sqxtffq9yh = lsn15dh7f2_tahg | o4okrtw26smjv;
  wire [5:0] y8y5fphthrkirw = o4okrtw26smjv ? 6'h0 : sy5ie2qsz3 + 6'b1;
e603_gnrl_dfflr #(6) dhqonaqzvhwhgx7ei7 (bw6sqxtffq9yh, y8y5fphthrkirw, sy5ie2qsz3, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign br7a8dw5rndor = by__ur08rbz;
  assign b3nk3ml5dggetwx1 = xc7_xs2vqt4n;
  assign fekszkc1bqs8x6b = jeofasr36jmwmq;
endmodule
module skwg8szppsqhzczh4r2_vhd (
    input    [7:0]              i7a27l9f3azj,                        
    input    [7:0]              tu2hl1iupxdfyq0,                        
    input    [7:0]              n1pxkwrf2f11r_im,                      
    input                       u980hc5o9zqn30,                         
    input                       a4d7qtqdpc8mly5p,                         
    input                       ttskpcao4ll8u8,                       
    output                      ftih6yxzg6ola75,                          
    output                      nnntwy35_w_2su3,                          
    output                      phmg_c7gsjot9v8kz,                        
    input                       ri2ziyy, 
    input                       r46kf
);
    wire [7:0] kdctd0bnnkf7f;
    wire uo08js4ilkquvugb44 = u980hc5o9zqn30 | ftih6yxzg6ola75;
    wire [7:0] cz55rl3yoba9eo5 = u980hc5o9zqn30 ? 8'h0 : ftih6yxzg6ola75 ? kdctd0bnnkf7f + 1'b1 : kdctd0bnnkf7f;
e603_gnrl_dfflr #(8) vje6rb5seafao(uo08js4ilkquvugb44, cz55rl3yoba9eo5, kdctd0bnnkf7f, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    assign ftih6yxzg6ola75 = kdctd0bnnkf7f < i7a27l9f3azj;
    wire [7:0] kr5u8bb5dtbgo;
    wire mlkkhsxy4g81ua = a4d7qtqdpc8mly5p | nnntwy35_w_2su3;
    wire [7:0] r8nweatp3dof_vl = a4d7qtqdpc8mly5p ? 8'h0 : nnntwy35_w_2su3 ? kr5u8bb5dtbgo + 1'b1 : kr5u8bb5dtbgo;
e603_gnrl_dfflr #(8) a8aizfiqxuutf(mlkkhsxy4g81ua, r8nweatp3dof_vl, kr5u8bb5dtbgo, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    assign nnntwy35_w_2su3 = kr5u8bb5dtbgo < tu2hl1iupxdfyq0;
    wire [7:0] d1rdhe2n7kjysfno;
    wire z4yqdo4jmt7_kw6qm4o = ttskpcao4ll8u8 | phmg_c7gsjot9v8kz;
    wire [7:0] r15kb00h25xd2982 = ttskpcao4ll8u8 ? 8'h0 : phmg_c7gsjot9v8kz ? d1rdhe2n7kjysfno + 1'b1 : d1rdhe2n7kjysfno;
e603_gnrl_dfflr #(8) qcu4cbcu9k7agti_(z4yqdo4jmt7_kw6qm4o, r15kb00h25xd2982, d1rdhe2n7kjysfno, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    assign phmg_c7gsjot9v8kz = d1rdhe2n7kjysfno < n1pxkwrf2f11r_im;
endmodule
module zdd42ray6lu4u4hhyocrugb
#(
    parameter ra2aj3fukykd9j = 32,
    parameter fmv57175hz8809 = 8,
    parameter xi5np3lftgtezged = 3
)
(
    input                      lczv3cn,
    input                      r38027_km3,
    input                      ho56_v0li6,
    output                     jm5sdmj,
    input                      lyg_g62ta,
    output  [ra2aj3fukykd9j-1 : 0] aqikf5g,
    output                     al_bfsrdm,
    input                      cadqltzy,
    output [xi5np3lftgtezged:0]jov1vyjapbtr,
    input                      pxdlrpyubv4n,
    input   [ra2aj3fukykd9j-1 : 0] ygli0hkz,
    output                     euwxj8gh
);
    wire [xi5np3lftgtezged:0]      nw14yqx3xxb;    
    reg [xi5np3lftgtezged:0]      d6trhxhl6wsh; 
    wire                           i6v52owi3i7mr;   
    e603_gnrl_fifo_wflg #(
       .CUT_READY (1),
       .MSKO      (0),
       .REG_OUT   (1),
       .DP        (fmv57175hz8809),
       .DW        (ra2aj3fukykd9j),
       .DP_PTR_W  (xi5np3lftgtezged+1)
    ) vc21qvjkfaa (
      .clk             (lczv3cn),
      .rst_n           (r38027_km3),
      .cleanfifo       (ho56_v0li6 ),
      .i_vld           (pxdlrpyubv4n),
      .i_rdy           (euwxj8gh),
      .i_dat           (ygli0hkz),
      .o_vld           (al_bfsrdm),
      .o_rdy           (cadqltzy),
      .o_dat           (aqikf5g),
      .intl_vec        (),
      .intl_vec_encode (jov1vyjapbtr)
    );
    assign nw14yqx3xxb = fmv57175hz8809[xi5np3lftgtezged:0] - jov1vyjapbtr;
    assign i6v52owi3i7mr = (nw14yqx3xxb == d6trhxhl6wsh);
    assign jm5sdmj = euwxj8gh & ~i6v52owi3i7mr;
    always @(posedge lczv3cn, negedge r38027_km3)
    begin: y3mmifiutmiji6nvau6
        if (r38027_km3 == 1'b0)
            d6trhxhl6wsh <= {xi5np3lftgtezged+1{1'b0}};
        else
        begin
            if(jm5sdmj && lyg_g62ta)
            begin
                if (~pxdlrpyubv4n || ~euwxj8gh)
                    d6trhxhl6wsh <= d6trhxhl6wsh + {{xi5np3lftgtezged{1'b0}},1'b1};
            end
            else if (pxdlrpyubv4n && euwxj8gh)
                d6trhxhl6wsh <= d6trhxhl6wsh - {{xi5np3lftgtezged{1'b0}},1'b1};
        end
    end
endmodule
module h2y0c5k5byx7eo7zpc9f4i6o # (
  parameter f9nkmw__ys = 0,
  parameter ghe8 = 0,
  parameter rbs3a29   = 8,
  parameter gu9a0q9   = 32,
  parameter suj03uery = 1,
  parameter xi5np3lftgtezged = 3
) (
  input           zt4_1onc, 
  output          zgasz6, 
  input  [gu9a0q9-1:0] jg87d,
  output          qecflw9, 
  input           zv0bnvx, 
  output [gu9a0q9-1:0] jqyt_,
  output [xi5np3lftgtezged:0]    bez2r,
  input           xo32ey7h,
  input           ri2ziyy,
  input           r46kf
);
genvar zyod33;
generate 
  if(rbs3a29 == 0) begin: qmqs20k9uyma
     assign qecflw9 = zt4_1onc;
     assign zgasz6 = zv0bnvx;
     assign jqyt_ = jg87d;
  end
  else begin: kfuzu1wzm87
    wire [gu9a0q9-1:0] jyb_xrvmlkepac [rbs3a29-1:0];
    wire [gu9a0q9-1:0] niyrz4zsknv [rbs3a29-1:0];
    wire [rbs3a29-1:0] rreodx8nr3a;
    wire xmzf = (zt4_1onc & zgasz6) | xo32ey7h;
    wire u6lh = (qecflw9 & zv0bnvx) | xo32ey7h;
    wire [rbs3a29-1:0] jgpriggtm2y_fwywc; 
    wire [rbs3a29-1:0] ot40c525e9q7lz;
    wire [rbs3a29-1:0] ll6f8tv1_r2d1h; 
    wire [rbs3a29-1:0] rgpkcprjgc_w9a;
    if(rbs3a29 == 1) begin:phzw717paedi9
      assign jgpriggtm2y_fwywc = xo32ey7h ? 1'b0 : 1'b1; 
    end
    else begin:oq0bb8qqlg1ftq9082tp
      assign jgpriggtm2y_fwywc = xo32ey7h ?  {{rbs3a29-1{1'b0}}, 1'b1}:
          ot40c525e9q7lz[rbs3a29-1] ? {{rbs3a29-1{1'b0}}, 1'b1} :
                          (ot40c525e9q7lz << 1);
    end
    if(rbs3a29 == 1) begin:szvd_uo_t1rphsu
      assign ll6f8tv1_r2d1h = xo32ey7h ? 1'b0 : 1'b1; 
    end
    else begin:tvq5s2c1hmu7vnkviz0nn0
      assign ll6f8tv1_r2d1h = xo32ey7h ?  {{rbs3a29-1{1'b0}}, 1'b1} :
          rgpkcprjgc_w9a[rbs3a29-1] ? {{rbs3a29-1{1'b0}}, 1'b1} :
                          (rgpkcprjgc_w9a << 1);
    end
e603_gnrl_dfflrs #(1)    ykwyawz_btbqa9homx3  (u6lh, jgpriggtm2y_fwywc[0]     , ot40c525e9q7lz[0]     , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1)    c7pydzj7ovdygd4aj1  (xmzf, ll6f8tv1_r2d1h[0]     , rgpkcprjgc_w9a[0]     , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    if(rbs3a29 > 1) begin:clkm1t5c1xs
e603_gnrl_dfflr  #(rbs3a29-1) a9egrdivdf59anpv72p4iu  (u6lh, jgpriggtm2y_fwywc[rbs3a29-1:1], ot40c525e9q7lz[rbs3a29-1:1], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr  #(rbs3a29-1) lvg4hw2b7ocga7kwrt  (xmzf, ll6f8tv1_r2d1h[rbs3a29-1:1], rgpkcprjgc_w9a[rbs3a29-1:1], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    end
    wire [rbs3a29:0] oj7d_c;
    wire [rbs3a29:0] ygfrhv2;
    wire [rbs3a29:0] jtq949j67; 
    wire [rbs3a29:0] j5rme6;
    reg [xi5np3lftgtezged:0] knmwgmw1pimh9g;
    integer x;
    wire bb7bhv = (u6lh ^ xmzf ) | xo32ey7h;
    assign jtq949j67 = xo32ey7h ? 1'b1 : xmzf ? {j5rme6[rbs3a29-1:0], 1'b1} : (j5rme6 >> 1);  
e603_gnrl_dfflrs #(1)  v9onou3lach3     (bb7bhv, jtq949j67[0]     , j5rme6[0]     ,     ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr  #(rbs3a29) mgngavv5i6kdpvrx     (bb7bhv, jtq949j67[rbs3a29:1], j5rme6[rbs3a29:1],     ri2ziyy, r46kf);// VPP_NO_REG_PARSE
   wire [rbs3a29+1:0] f662dygp2pqb56 = {1'b0,j5rme6} ;
    if(rbs3a29 == 1) begin:va6efdu069hh86465w
      always @(*) begin
        knmwgmw1pimh9g = {xi5np3lftgtezged+1{1'b0}};
      end
    end
    else begin:pdv4afjyfp6wyy5zv_nwqyg
      always @ (*) begin
        knmwgmw1pimh9g = {xi5np3lftgtezged+1{1'b0}};
        for(x=1 ; x<=rbs3a29 ; x=x+1) begin
          if(x<rbs3a29-1)begin
            if(f662dygp2pqb56[x] ^ f662dygp2pqb56[x+1])
              knmwgmw1pimh9g = x[xi5np3lftgtezged:0];
          end
          else if(x== (rbs3a29)) begin
            if(f662dygp2pqb56[x])
              knmwgmw1pimh9g = x[xi5np3lftgtezged:0];
          end
        end
      end
    end
    assign bez2r = knmwgmw1pimh9g;
    assign oj7d_c = {1'b0,j5rme6[rbs3a29:1]};
    assign ygfrhv2 = {1'b0,j5rme6[rbs3a29:1]};
    if(rbs3a29 == 1) begin:foak_f95t2olcq
        if(f9nkmw__ys == 1) begin:zx3zppx4bdss_l
          assign zgasz6 = (~oj7d_c[rbs3a29-1]);
        end
        else begin:bnzuc64my8yotquyxmz
          assign zgasz6 = (~oj7d_c[rbs3a29-1]) | (u6lh & ~xo32ey7h);
        end
    end
    else begin : zyyv__9aqcfn__s
      assign zgasz6 = (~oj7d_c[rbs3a29-1]);
    end
    for (zyod33=0; zyod33<rbs3a29; zyod33=zyod33+1) begin:oe5rsotr0ghvfl
      assign rreodx8nr3a[zyod33] = xmzf & rgpkcprjgc_w9a[zyod33];
e603_gnrl_dffl  #(gu9a0q9) dwpadh5cajhr0s (rreodx8nr3a[zyod33], jg87d, niyrz4zsknv[zyod33], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
      assign jyb_xrvmlkepac[zyod33] = rreodx8nr3a[zyod33] ? jg87d : niyrz4zsknv[zyod33];
    end
    integer t;
    wire [gu9a0q9-1:0] j45yhs2ojom0i;
    wire [rbs3a29-1:0] b9mzd4qdyk38db = u6lh ? jgpriggtm2y_fwywc : ot40c525e9q7lz;
    if(suj03uery == 0) begin:ryi755vbqjpdrspl
        reg [gu9a0q9-1:0] rvekbwm94_2g1;
        always @*
        begin : sosqjh1rrq34
          rvekbwm94_2g1 = {gu9a0q9{1'b0}};
          for(t=0; t<rbs3a29; t=t+1) begin
            rvekbwm94_2g1 = rvekbwm94_2g1 | ({gu9a0q9{ot40c525e9q7lz[t]}} & niyrz4zsknv[t]);
          end
        end
        assign j45yhs2ojom0i = rvekbwm94_2g1;
    end
    else begin:hr23f8vxpi5ab_7q5yidy1
        reg [gu9a0q9-1:0] md1jj1lh30i77nmk;
        always @*
        begin : sosqjh1rrq34
          md1jj1lh30i77nmk = {gu9a0q9{1'b0}};
          for(t=0; t<rbs3a29; t=t+1) begin
            md1jj1lh30i77nmk = md1jj1lh30i77nmk | ({gu9a0q9{b9mzd4qdyk38db[t]}} & jyb_xrvmlkepac[t]);
          end
        end
e603_gnrl_dffr #(gu9a0q9) j50inruuyv7ebtpj7  (md1jj1lh30i77nmk, j45yhs2ojom0i, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    end
    if(ghe8 == 1) begin:y_u3oxptq26c7xuc
        assign jqyt_ = {gu9a0q9{qecflw9}} & j45yhs2ojom0i;
    end
    else begin:obqti4sc53op0kcl0qe4
        assign jqyt_ = j45yhs2ojom0i;
    end
    assign qecflw9 = (ygfrhv2[0]);
  end
endgenerate
endmodule
module ohjjdtin80yczoqofg91n92vyy # (
    parameter   ml0wdobwya9wrawo = 27,
    parameter   xkaaf5c8vmrql9ch = 32
) (
    input   [7:0]                     i7a27l9f3azj,
    input   [7:0]                     tu2hl1iupxdfyq0,
    input   [7:0]                     n1pxkwrf2f11r_im,
    input                             ac9pck1o438e,
    input   [11:0]                    styvvt8p4khvqg,
    input   [7:0]                     p94z0dkvxceics6snl77p,
    input   [7:0]                     h299pga1y47pk9dltr,
    input   [2:0]                     spuogxa2dnoh6g9eub,
    input   [5:0]                     l62rrzbqseu_o4cqbl3g,
    input                             mxwg8lfgv4pge1,
    output                            qi_euczbjhgo1za,
    input                             cuu3goyrnwc9hf,
    input   [ml0wdobwya9wrawo-1:0]    t3lk20ui52aqc6,
    input   [xkaaf5c8vmrql9ch-1:0]    rs8qfdkpko8pq,
    input   [1:0]                     pccr2d0febxqx,
    input  [7:0]                      xwpttmbn8xqi2b0qg    ,
    input  [1:0]                      j7onlxu8c84rohjl3  ,
    input  [1:0]                      p5nleje0lb8ux,
    input  [3:0]                      swwpvt6gm3cz8,
    output                            l_geblczxuwi5x4e,
    input                             ptdklfwbs2d13,
    output  [xkaaf5c8vmrql9ch-1:0]    nuvz1doibyin1uaa,
    output                            w2u2a8j7tq1r4rozh,
    input                             d0ayb3zgcx_763,
    input                             llhht8w4fsz,
    output                            x_9z5321korhcm,
    input                             by76o8v4ied3t88q6y,
    input                             j5yfsxwh0xm,
    output                            eq_14,
    output                            ild_jl_xu,
    output  [5:0]                     jg4_ystzg,
    output  [31:0]                    jgoquohxi26,
    input   [31:0]                    sa5jjxawc07x,
    input   [2:0]                     tntm4hrv1mw26hrf,
    output  [1-1:0]     bym3bd,
    output                            ova0029jyhx98hvd,
    output                            h44oj_ibu1z0h,
    input                             ri2ziyy,
    input                             r46kf
);
    wire                              u980hc5o9zqn30;
    wire                              a4d7qtqdpc8mly5p;
    wire                              ttskpcao4ll8u8;
    wire                              ftih6yxzg6ola75;
    wire                              nnntwy35_w_2su3;
    wire                              phmg_c7gsjot9v8kz;
    wire                              y478rw1x22;
    wire                              hclradeslly;
    wire                              gv9dz4ik0z957;
    wire                              mvzbs5hw0x;
    wire                              cwyevahwg;
    wire                              qindq5s5te;
    wire                              qyvhvdia27a98m7h617;
    wire                              o2orr0tzewzmj9x37gx2;
    wire                              kaz_q8iyy;
    wire                              vf4zbdftqo5qliq;
    wire                              nuig1tnzm6f4_ofm2y7;
    wire                              v6jfmpq5zd;
    wire                              yetfszclz93;
    wire                              h9v5e_bsrlv6bm;
    wire                              oztda874wwmxo;
    wire                              fydtca3;
    wire  [2:0]                       lvpw39aj320yl;
    wire  [2:0]                       xsnc1nhmbigmk;
    wire                              ii54xdng5tof;
    wire  [3:0]                       p7lgkey3y;
    wire                              i33zopxki3rx89;
    wire                              zn8_gkbij;
    wire                              xuxfiprqv8;
    wire  [1:0]                       ilhfkew1ees;   
    wire  [2:0]                       f7n1yvo27ry;
    wire  [7:0]                       vcp29fnsr3g;
    wire  [1:0]                       qsrytak5xulhx;   
    wire  [31:0]                      vn4m5rjmmk;    
    wire  [3:0]                       lqmuv46wkioemr;
    wire  [xkaaf5c8vmrql9ch-1:0]      ebys4m1tyh62w;   
    wire                              o9609lob788n0g1dhd;
    wire                              c1v5l004p5lp3ukwqv;
    wire                              q6euk6ki89jnf6y;
    wire                              hy4glq27lnlfui27;
    wire                              l5oppubupfv8a_a2oyt;
    wire                              xjo35v2cqy9hcaq7i;
    wire                              r229990th25nn083v6b9;
    wire                              fcrevbo85kwto7_8sc;
    wire                              of7ov1u56qv35jmtf;
    wire  [2:0]                       ozv7op8sedo_; 
    wire  [2:0]                       vsrgoshmlijgcs4_; 
    assign y478rw1x22 = (i7a27l9f3azj == 8'h0);  
    assign mvzbs5hw0x = 1'b1;
    assign cwyevahwg = 1'b1;
    assign hclradeslly = 1'b0;
    assign gv9dz4ik0z957 = 1'b1;
    localparam rjz3ekdeoph_ikp = 4;
    wire q4n0kbcn24onq;
    wire [rjz3ekdeoph_ikp-1:0] uloh18s35kco3lh3;
    wire [rjz3ekdeoph_ikp-1:0] y6ciiggp4rpi5wb;
    localparam fusofx_uxiq0ovvs0pw   = 4'd0;
    localparam perkwbvq_b6sk    = 4'd1;
    localparam ndbg5krrqovrvfsy3sip  = 4'd2;
    localparam a60aiqgftapr3ju  = 4'd3;
    localparam mcejlxk9umq4v    = 4'd4;
    localparam dyybc8w03h84m42fi0   = 4'd5;
    localparam ja5vcrah4kgbfyn269   = 4'd6;
    localparam mtgv8bmbfrd4_1d    = 4'd7;
    localparam ahfe2vu2silbj8u8_gdq = 4'd8;
    localparam qdm93lhkedv146mpk   = 4'd9;
    localparam rzo5c5uj93mxj6qgh6  = 4'd10;
    localparam oohso93a1b5zzuy1   = 4'd11;
    localparam ce_kkbh6tdpez957bymj_7lf   = 4'd12;
    wire [rjz3ekdeoph_ikp-1:0] ifm4f61h58jxyo;
    wire [rjz3ekdeoph_ikp-1:0] wczlyjbjkflcg_yl;
    wire [rjz3ekdeoph_ikp-1:0] zvhzy3kk4eudv3ur2w;
    wire [rjz3ekdeoph_ikp-1:0] uzw1nk84ivcdjr802gaj;
    wire [rjz3ekdeoph_ikp-1:0] u7tomfy34wmr54eq;
    wire [rjz3ekdeoph_ikp-1:0] khqw_snmkrhnir8yoq;
    wire [rjz3ekdeoph_ikp-1:0] h6oa94axrjnwbwiw590;
    wire [rjz3ekdeoph_ikp-1:0] un1i8dbwvm8u094;
    wire [rjz3ekdeoph_ikp-1:0] lbzab0b123rtlmdmhor09;
    wire [rjz3ekdeoph_ikp-1:0] nvlbyj2iiw99_bqs5;
    wire [rjz3ekdeoph_ikp-1:0] vre5wjf3393nlq9x4n;
    wire [rjz3ekdeoph_ikp-1:0] fffy3d_svlg91_py0;
    wire [rjz3ekdeoph_ikp-1:0] qhrhibjgj__tu1lyehl3zbyk6;
    wire f86884rwtdpj4yjo9ubx;
    wire f_o50zgw8ecfpo34t3u3cot;
    wire jbshcx_02es1e2h_z497s;
    wire qr1ktq99r1r7adt9bykuwf6;
    wire uln46ild7pjrkrk40163xy;
    wire b7omzs6e1jmsyontf6mn3_;
    wire jmjvcq_mqxj4wfl3vt7g;
    wire dwnpla4769m2tk7sceu0uq;
    wire xp_2kn3s7_ldme_y_2j0y9jj90;
    wire txwf01dbh9kuqsoqufzrvkq;
    wire xwua0g5cuosyyl7bcq22d;
    wire nsdr4lk9fg1wkhennnag;
    wire qg7ep9sao1e1xy687w8mlpesgcezc;
    wire dfo9ydcuevw5_kh = (y6ciiggp4rpi5wb == fusofx_uxiq0ovvs0pw);
    wire vjjvylyfbwx6rwgi  = (y6ciiggp4rpi5wb == perkwbvq_b6sk);
    wire p3xd3d1dix2h7e7pva = (y6ciiggp4rpi5wb == ndbg5krrqovrvfsy3sip);
    wire ku5iohxrpx2w9471 = (y6ciiggp4rpi5wb == a60aiqgftapr3ju);
    wire ua3wuinofojut_3ays = (y6ciiggp4rpi5wb == mcejlxk9umq4v);
    wire xd_av4exfq1kbozofy = (y6ciiggp4rpi5wb == dyybc8w03h84m42fi0);
    wire vy3b1_yoq2ikwkbpn7a = (y6ciiggp4rpi5wb == ja5vcrah4kgbfyn269);
    wire jgjuthrkb_6qx4jq5 = (y6ciiggp4rpi5wb == mtgv8bmbfrd4_1d);
    wire ea_srs418popjyg_hwt9e = (y6ciiggp4rpi5wb == ahfe2vu2silbj8u8_gdq);
    wire c_gysr1w3gcu_ihx = (y6ciiggp4rpi5wb == qdm93lhkedv146mpk);
    wire n8ot75wb3enognwbbj2o = (y6ciiggp4rpi5wb == rzo5c5uj93mxj6qgh6);
    wire m6c_thy4a3_t2khefs87 = (y6ciiggp4rpi5wb == oohso93a1b5zzuy1);
    wire ebeebi5xu5rde4burqivrxwn69b = (y6ciiggp4rpi5wb == ce_kkbh6tdpez957bymj_7lf);
    wire mcmpbadvx8jcd3h = 
                       1'b0;
    assign f86884rwtdpj4yjo9ubx = dfo9ydcuevw5_kh & (
                                                    h9v5e_bsrlv6bm
                                                    );
    wire h2wnt4mqoxlnl = (~ac9pck1o438e | (
                                        1'b1
                                        & ~cuu3goyrnwc9hf) 
                                        | ~yetfszclz93
                                        );
    assign ifm4f61h58jxyo =  h2wnt4mqoxlnl              ? perkwbvq_b6sk :
                             ~y478rw1x22               ? a60aiqgftapr3ju :
                             1'b1                     ? mcejlxk9umq4v :
                             ~hclradeslly                ? dyybc8w03h84m42fi0 :
                             ~gv9dz4ik0z957                ? oohso93a1b5zzuy1 :
                             (xuxfiprqv8 & ~mvzbs5hw0x)   ? mtgv8bmbfrd4_1d :
                             (~xuxfiprqv8 & ~cwyevahwg)  ? mtgv8bmbfrd4_1d :
                                                        ja5vcrah4kgbfyn269;
    assign f_o50zgw8ecfpo34t3u3cot = vjjvylyfbwx6rwgi &  (
                                                  oztda874wwmxo
                                                  );
    assign wczlyjbjkflcg_yl = fusofx_uxiq0ovvs0pw;
    assign qg7ep9sao1e1xy687w8mlpesgcezc = ebeebi5xu5rde4burqivrxwn69b & (
                                                                  oztda874wwmxo);
    assign qhrhibjgj__tu1lyehl3zbyk6 = rzo5c5uj93mxj6qgh6;
    assign jbshcx_02es1e2h_z497s = p3xd3d1dix2h7e7pva & ~phmg_c7gsjot9v8kz;
    assign zvhzy3kk4eudv3ur2w = fusofx_uxiq0ovvs0pw ;
    assign qr1ktq99r1r7adt9bykuwf6 = ku5iohxrpx2w9471 & ~ftih6yxzg6ola75;
    assign uzw1nk84ivcdjr802gaj = 
                             1'b1                     ? mcejlxk9umq4v :
                             ~hclradeslly                ? dyybc8w03h84m42fi0 :
                             ~gv9dz4ik0z957                ? oohso93a1b5zzuy1 :
                             (xuxfiprqv8 & ~mvzbs5hw0x)   ? mtgv8bmbfrd4_1d :
                             (~xuxfiprqv8 & ~cwyevahwg)  ? mtgv8bmbfrd4_1d :
                                                        ja5vcrah4kgbfyn269;
    assign uln46ild7pjrkrk40163xy = ua3wuinofojut_3ays & llhht8w4fsz;
    assign u7tomfy34wmr54eq = ~hclradeslly                  ? dyybc8w03h84m42fi0 :
                           ~gv9dz4ik0z957                  ? oohso93a1b5zzuy1 :
                           (xuxfiprqv8 & ~mvzbs5hw0x)     ? mtgv8bmbfrd4_1d :
                           (~xuxfiprqv8 & ~cwyevahwg)    ? mtgv8bmbfrd4_1d :
                                                        ja5vcrah4kgbfyn269;
    assign nsdr4lk9fg1wkhennnag = m6c_thy4a3_t2khefs87 & llhht8w4fsz ;
    assign fffy3d_svlg91_py0 = 
                            (xuxfiprqv8 & ~mvzbs5hw0x)   ? mtgv8bmbfrd4_1d  : 
                            (~xuxfiprqv8 & ~cwyevahwg)  ? mtgv8bmbfrd4_1d  :
                                                       ja5vcrah4kgbfyn269 ;
    assign b7omzs6e1jmsyontf6mn3_ = xd_av4exfq1kbozofy & llhht8w4fsz ;
    assign khqw_snmkrhnir8yoq = 
                            ~gv9dz4ik0z957                ? oohso93a1b5zzuy1 :
                            (xuxfiprqv8 & ~mvzbs5hw0x)   ? mtgv8bmbfrd4_1d  : 
                            (~xuxfiprqv8 & ~cwyevahwg)  ? mtgv8bmbfrd4_1d  :
                                                       ja5vcrah4kgbfyn269 ;
    assign dwnpla4769m2tk7sceu0uq = jgjuthrkb_6qx4jq5 & j5yfsxwh0xm ; 
    assign un1i8dbwvm8u094 = ja5vcrah4kgbfyn269;
    assign jmjvcq_mqxj4wfl3vt7g = vy3b1_yoq2ikwkbpn7a & ((llhht8w4fsz & ~xuxfiprqv8) | (j5yfsxwh0xm & xuxfiprqv8)); 
    assign h6oa94axrjnwbwiw590 = qdm93lhkedv146mpk;
    assign txwf01dbh9kuqsoqufzrvkq = c_gysr1w3gcu_ihx & (
                                                   oztda874wwmxo
                                                   );
    assign nvlbyj2iiw99_bqs5 = i33zopxki3rx89            ? rzo5c5uj93mxj6qgh6 :
                                                   ahfe2vu2silbj8u8_gdq;
    assign xp_2kn3s7_ldme_y_2j0y9jj90 = ea_srs418popjyg_hwt9e & (
                                                        h9v5e_bsrlv6bm
                                                        );
    assign lbzab0b123rtlmdmhor09 = mcmpbadvx8jcd3h ? ce_kkbh6tdpez957bymj_7lf 
                            : ja5vcrah4kgbfyn269 ;  
    assign xwua0g5cuosyyl7bcq22d = n8ot75wb3enognwbbj2o & ~nnntwy35_w_2su3;
    assign vre5wjf3393nlq9x4n = ndbg5krrqovrvfsy3sip;
    assign q4n0kbcn24onq =   f86884rwtdpj4yjo9ubx
                           | f_o50zgw8ecfpo34t3u3cot
                           | jbshcx_02es1e2h_z497s
                           | qr1ktq99r1r7adt9bykuwf6
                           | uln46ild7pjrkrk40163xy
                           | b7omzs6e1jmsyontf6mn3_
                           | jmjvcq_mqxj4wfl3vt7g
                           | dwnpla4769m2tk7sceu0uq
                           | xp_2kn3s7_ldme_y_2j0y9jj90
                           | txwf01dbh9kuqsoqufzrvkq
                           | xwua0g5cuosyyl7bcq22d
                           | nsdr4lk9fg1wkhennnag
                           | qg7ep9sao1e1xy687w8mlpesgcezc
                           ; 
    assign uloh18s35kco3lh3 =   ({rjz3ekdeoph_ikp{f86884rwtdpj4yjo9ubx  }} & ifm4f61h58jxyo  )
                           | ({rjz3ekdeoph_ikp{f_o50zgw8ecfpo34t3u3cot   }} & wczlyjbjkflcg_yl   )
                           | ({rjz3ekdeoph_ikp{jbshcx_02es1e2h_z497s }} & zvhzy3kk4eudv3ur2w )
                           | ({rjz3ekdeoph_ikp{qr1ktq99r1r7adt9bykuwf6 }} & uzw1nk84ivcdjr802gaj )
                           | ({rjz3ekdeoph_ikp{uln46ild7pjrkrk40163xy   }} & u7tomfy34wmr54eq   )
                           | ({rjz3ekdeoph_ikp{b7omzs6e1jmsyontf6mn3_  }} & khqw_snmkrhnir8yoq  )
                           | ({rjz3ekdeoph_ikp{jmjvcq_mqxj4wfl3vt7g  }} & h6oa94axrjnwbwiw590  )
                           | ({rjz3ekdeoph_ikp{dwnpla4769m2tk7sceu0uq   }} & un1i8dbwvm8u094   )
                           | ({rjz3ekdeoph_ikp{txwf01dbh9kuqsoqufzrvkq  }} & nvlbyj2iiw99_bqs5  )
                           | ({rjz3ekdeoph_ikp{xp_2kn3s7_ldme_y_2j0y9jj90}} & lbzab0b123rtlmdmhor09)
                           | ({rjz3ekdeoph_ikp{xwua0g5cuosyyl7bcq22d }} & vre5wjf3393nlq9x4n )
                           | ({rjz3ekdeoph_ikp{nsdr4lk9fg1wkhennnag }}  & fffy3d_svlg91_py0 )
                           | ({rjz3ekdeoph_ikp{qg7ep9sao1e1xy687w8mlpesgcezc }}  & qhrhibjgj__tu1lyehl3zbyk6 )
                           ;
e603_gnrl_dfflr #(rjz3ekdeoph_ikp) a39xlwwmub899evw (q4n0kbcn24onq, uloh18s35kco3lh3, y6ciiggp4rpi5wb, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    assign i33zopxki3rx89 = 
                     1'b1;
    skwg8szppsqhzczh4r2_vhd e5c4u9536gq3ink3z(
    .i7a27l9f3azj        (i7a27l9f3azj    ),                        
    .tu2hl1iupxdfyq0        (tu2hl1iupxdfyq0    ),                        
    .n1pxkwrf2f11r_im      (n1pxkwrf2f11r_im  ),                        
    .u980hc5o9zqn30         (u980hc5o9zqn30     ),                        
    .a4d7qtqdpc8mly5p         (a4d7qtqdpc8mly5p     ),                        
    .ttskpcao4ll8u8       (ttskpcao4ll8u8   ),                        
    .ftih6yxzg6ola75          (ftih6yxzg6ola75      ),                        
    .nnntwy35_w_2su3          (nnntwy35_w_2su3      ),                        
    .phmg_c7gsjot9v8kz        (phmg_c7gsjot9v8kz    ),                        
    .ri2ziyy                 (ri2ziyy             ), 
    .r46kf               (r46kf           )
    );
    assign u980hc5o9zqn30 = jbshcx_02es1e2h_z497s & (zvhzy3kk4eudv3ur2w == a60aiqgftapr3ju);
    assign a4d7qtqdpc8mly5p =   (txwf01dbh9kuqsoqufzrvkq   & (nvlbyj2iiw99_bqs5 == rzo5c5uj93mxj6qgh6)) ;
    assign ttskpcao4ll8u8 = (xwua0g5cuosyyl7bcq22d & (vre5wjf3393nlq9x4n == ndbg5krrqovrvfsy3sip));
    assign zn8_gkbij = (dfo9ydcuevw5_kh | ea_srs418popjyg_hwt9e) & h9v5e_bsrlv6bm;
e603_gnrl_dfflr #(1) j6hhxvaoa8ea0yuqj (zn8_gkbij, cuu3goyrnwc9hf, xuxfiprqv8, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(2) hh2yrbsbt87p807zt (zn8_gkbij, j7onlxu8c84rohjl3, qsrytak5xulhx, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(2) je1es1xvqzxc57iaowo (zn8_gkbij, p5nleje0lb8ux, ilhfkew1ees, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(3) sumfdcodyrf5ik (zn8_gkbij, {1'b0,pccr2d0febxqx}, f7n1yvo27ry, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(8) nr06zzq32rmwnc2y3 (zn8_gkbij, xwpttmbn8xqi2b0qg, vcp29fnsr3g, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    wire [31:0] jmizolnborfjgyo8di;
    assign jmizolnborfjgyo8di = {{(32-ml0wdobwya9wrawo){1'b0}},t3lk20ui52aqc6} 
                            ;
e603_gnrl_dfflr #(32) yw7xs3l0_ibs3j (zn8_gkbij, jmizolnborfjgyo8di, vn4m5rjmmk, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(4) q3xbwplg4tf84svxcc_ (zn8_gkbij, swwpvt6gm3cz8, lqmuv46wkioemr, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    wire [xkaaf5c8vmrql9ch-1:0] fkufjhcqbl33742767nc47 = rs8qfdkpko8pq ;
e603_gnrl_dfflr #(xkaaf5c8vmrql9ch) qpc4td3qwe5zeujvq6gp (zn8_gkbij, fkufjhcqbl33742767nc47, ebys4m1tyh62w, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    assign qi_euczbjhgo1za = (dfo9ydcuevw5_kh | ea_srs418popjyg_hwt9e) 
                         ;
    assign h9v5e_bsrlv6bm = mxwg8lfgv4pge1 & qi_euczbjhgo1za 
                         ;
    assign l_geblczxuwi5x4e = 
                         (vjjvylyfbwx6rwgi | c_gysr1w3gcu_ihx | ebeebi5xu5rde4burqivrxwn69b);
    assign oztda874wwmxo = l_geblczxuwi5x4e & ptdklfwbs2d13;
   wire hvpka2utsd77zkwb;
   wire jaz5_eu8trcgjjwk;
   wire viqskpu8qqmg_t526fmj; 
   wire orc7am_x4hoagohnrsqrv01; 
    wire kgkel07zelke45b5vt = d0ayb3zgcx_763 
                           ;
    assign w2u2a8j7tq1r4rozh = viqskpu8qqmg_t526fmj 
                          ;
    assign jaz5_eu8trcgjjwk = w2u2a8j7tq1r4rozh & kgkel07zelke45b5vt;    
    wire azkswlpixo70id = jaz5_eu8trcgjjwk;
    wire b1t0zj0o9gckru2d3v81 = dfo9ydcuevw5_kh & ~h2wnt4mqoxlnl & h9v5e_bsrlv6bm &
                            (
                              ~y478rw1x22               ? 1'b0 :
                              1'b1                     ? 1'b1 :
                              ~hclradeslly                ? 1'b1 : 
                              ~gv9dz4ik0z957                ? 1'b1 : 
                              (xuxfiprqv8 & ~mvzbs5hw0x)   ? 1'b0 :
                              (~xuxfiprqv8 & ~cwyevahwg)  ? 1'b0 :
                              xuxfiprqv8                 ? 1'b0 :
                                                         1'b1 
                            );
    wire n69xg6qe7mb85jl4 = ku5iohxrpx2w9471 & ~ftih6yxzg6ola75 &
                            (
                              1'b1                     ? 1'b1 :
                              ~hclradeslly                ? 1'b1 :
                              ~gv9dz4ik0z957                ? 1'b1 : 
                              (xuxfiprqv8 & ~mvzbs5hw0x)   ? 1'b0 :
                              (~xuxfiprqv8 & ~cwyevahwg)  ? 1'b0 :
                              xuxfiprqv8                 ? 1'b0 :
                                                         1'b1 
                            );
    wire dk65ja7ilih0zdxtmsimc = ua3wuinofojut_3ays & llhht8w4fsz &
                            (
                              ~hclradeslly                ? 1'b1 :
                              ~gv9dz4ik0z957                ? 1'b1 : 
                             (xuxfiprqv8 & ~mvzbs5hw0x)    ? 1'b0 :
                             (~xuxfiprqv8 & ~cwyevahwg)   ? 1'b0 :
                              xuxfiprqv8                 ? 1'b0 :
                                                         1'b1 
                            );
    wire b3wq1a3j3r7aah_72h4 = xd_av4exfq1kbozofy & llhht8w4fsz &
                            (
                              ~gv9dz4ik0z957                ? 1'b1 : 
                              (xuxfiprqv8 & ~mvzbs5hw0x)   ? 1'b0 :
                              (~xuxfiprqv8 & ~cwyevahwg)  ? 1'b0 :
                              xuxfiprqv8                 ? 1'b0 :
                                                         1'b1 
                            );
    wire glivxiuivv166_c4tv = m6c_thy4a3_t2khefs87 & llhht8w4fsz &
                            (
                              (xuxfiprqv8 & ~mvzbs5hw0x)   ? 1'b0 :
                              (~xuxfiprqv8 & ~cwyevahwg)  ? 1'b0 :
                              xuxfiprqv8                 ? 1'b0 :
                                                         1'b1 
                            );
    wire iatyn219i7s0uut8f97w = jgjuthrkb_6qx4jq5 & j5yfsxwh0xm &
                            (
                              xuxfiprqv8                 ? 1'b0 :
                                                         1'b1 
                            );
    wire pbsomzibby15cg3ugund0 = ea_srs418popjyg_hwt9e & (h9v5e_bsrlv6bm
                                                ) &
                            (
                              cuu3goyrnwc9hf             ? 1'b0 :
                                                         (~mcmpbadvx8jcd3h) 
                            );
    wire tmxhw1e91i6kya =   b1t0zj0o9gckru2d3v81 | n69xg6qe7mb85jl4 | dk65ja7ilih0zdxtmsimc 
                      | b3wq1a3j3r7aah_72h4 | glivxiuivv166_c4tv | iatyn219i7s0uut8f97w
                      | pbsomzibby15cg3ugund0
                      ;
    wire bukfcxq7op6n = tmxhw1e91i6kya | azkswlpixo70id;
    wire xpf111q6vd = tmxhw1e91i6kya | (~azkswlpixo70id);
e603_gnrl_dfflr #(1) bo9558oxujwu1ynf (bukfcxq7op6n, xpf111q6vd, viqskpu8qqmg_t526fmj, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    wire jawcmoo2525qiyvafi7ff9 = by76o8v4ied3t88q6y 
                            ;
    assign x_9z5321korhcm = orc7am_x4hoagohnrsqrv01 
                          ;
    assign hvpka2utsd77zkwb = x_9z5321korhcm & jawcmoo2525qiyvafi7ff9;    
    wire q_uxzocdis0 = hvpka2utsd77zkwb;
    wire a8euz1otq4zshf8y_oxcl = dfo9ydcuevw5_kh & ~h2wnt4mqoxlnl & h9v5e_bsrlv6bm & 
                            (
                              ~y478rw1x22               ? 1'b0 :
                              1'b1                     ? 1'b0 :
                              ~hclradeslly                ? 1'b0 :
                              ~gv9dz4ik0z957                ? 1'b0 : 
                              (xuxfiprqv8 & ~mvzbs5hw0x)   ? 1'b1 :
                              (~xuxfiprqv8 & ~cwyevahwg)  ? 1'b1 :
                              xuxfiprqv8                 ? 1'b1 :
                                                         1'b0 
                            );
    wire d0cq8kkspo1nh9ao = ku5iohxrpx2w9471 & ~ftih6yxzg6ola75 &
                            (
                              1'b1                     ? 1'b0 :
                              ~hclradeslly                ? 1'b0 :
                              ~gv9dz4ik0z957                ? 1'b0 : 
                              (xuxfiprqv8 & ~mvzbs5hw0x)   ? 1'b1 :
                              (~xuxfiprqv8 & ~cwyevahwg)  ? 1'b1 :
                              xuxfiprqv8                 ? 1'b1 :
                                                         1'b0 
                            );
    wire ztcxf9che6rccycu4pzxx = ua3wuinofojut_3ays & llhht8w4fsz &
                            (
                              ~hclradeslly                ? 1'b0 :
                              ~gv9dz4ik0z957                ? 1'b0 : 
                              (xuxfiprqv8 & ~mvzbs5hw0x)   ? 1'b1 :
                              (~xuxfiprqv8 & ~cwyevahwg)  ? 1'b1 :
                              xuxfiprqv8                 ? 1'b1 :
                                                         1'b0 
                            );
    wire svsp9pxj_pdp32c5go1 = xd_av4exfq1kbozofy & llhht8w4fsz &
                            (
                              ~gv9dz4ik0z957                ? 1'b0 : 
                              (xuxfiprqv8 & ~mvzbs5hw0x)   ? 1'b1 :
                              (~xuxfiprqv8 & ~cwyevahwg)  ? 1'b1 :
                              xuxfiprqv8                 ? 1'b1 :
                                                         1'b0 
                            );
    wire p21_ak0lunvc92hi7q6ah = m6c_thy4a3_t2khefs87 & llhht8w4fsz & 
                            (
                              (xuxfiprqv8 & ~mvzbs5hw0x)   ? 1'b1 :
                              (~xuxfiprqv8 & ~cwyevahwg)  ? 1'b1 :
                              xuxfiprqv8                 ? 1'b1 :
                                                         1'b0 
                            );
    wire qe29kt3wd29iz52gijs = jgjuthrkb_6qx4jq5 & j5yfsxwh0xm & 
                            (
                              xuxfiprqv8                 ? 1'b1 :
                                                         1'b0 
                            );
    wire icv1wfvst1k2pz7rpgf3p = ea_srs418popjyg_hwt9e & h9v5e_bsrlv6bm &
                            (
                              cuu3goyrnwc9hf             ? 1'b1 :
                                                         1'b0 
                            );
    wire z_rj0ddgrrsk74r =   a8euz1otq4zshf8y_oxcl | d0cq8kkspo1nh9ao | ztcxf9che6rccycu4pzxx
                      | svsp9pxj_pdp32c5go1 | p21_ak0lunvc92hi7q6ah | qe29kt3wd29iz52gijs
                      | icv1wfvst1k2pz7rpgf3p 
                      ;
    wire la6kfcrp9_x_1d4 = z_rj0ddgrrsk74r | q_uxzocdis0;
    wire s3s0_v9izmoy = z_rj0ddgrrsk74r | (~q_uxzocdis0);
e603_gnrl_dfflr #(1) vn4te6o_vcrwp3o (la6kfcrp9_x_1d4, s3s0_v9izmoy, orc7am_x4hoagohnrsqrv01, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    assign eq_14 = ua3wuinofojut_3ays  ? 1'b1 
                 : xd_av4exfq1kbozofy ? 1'b1 
                 : m6c_thy4a3_t2khefs87 ? 1'b1 
                 : vy3b1_yoq2ikwkbpn7a ? (xuxfiprqv8 ? 1'b0 : 1'b1) 
                 : 1'b0;
    assign ild_jl_xu = jgjuthrkb_6qx4jq5 ? 1'b1 : 1'b0; 
    wire [5:0] i6ph7dugjr58 = 6'h0;
    wire i3qysurr19ftgex6 = (spuogxa2dnoh6g9eub == 3'b000);
    wire n3hhkoazoj03ain65gnu = (spuogxa2dnoh6g9eub == 3'b001);
    wire epk_kx6bz2piec4o = (spuogxa2dnoh6g9eub == 3'b010);
    wire rjjhr6tvr8ixyimaw292 = (spuogxa2dnoh6g9eub == 3'b011);
    wire l_0nzlfjw112bo8g = (spuogxa2dnoh6g9eub == 3'b100);
    wire [5:0] rrjsjcmt_vu = 
                           i3qysurr19ftgex6 ? 6'd0
                        : n3hhkoazoj03ain65gnu ? 6'd8
                        : epk_kx6bz2piec4o ? 6'd16
                        : rjjhr6tvr8ixyimaw292 ? 6'd24
                        : l_0nzlfjw112bo8g ? 6'd32
                        : 6'h8
                        ;
    wire ij20gf6r_ql = (f7n1yvo27ry == 3'b000); 
    wire nxx6s3u0tqk = (f7n1yvo27ry == 3'b001);
    wire y98tyjwjc93m = (f7n1yvo27ry == 3'b010);
    wire j6e1deip1ue_tj = lqmuv46wkioemr[0];
    wire f37ffaxx_34x = lqmuv46wkioemr[1];
    wire qovgg09jcqygqq = lqmuv46wkioemr[2];
    wire n5dcljox5vzhb6 = (vn4m5rjmmk[1:0] == 2'b00);
    wire fdzk2ipgnuakvtj = (vn4m5rjmmk[1:0] == 2'b01);
    wire daawnuhttm = (vn4m5rjmmk[1:0] == 2'b10);
    wire pzhg3g98xz44 = lqmuv46wkioemr[0] & lqmuv46wkioemr[1] ; 
    wire w007vm6p03yhnq = lqmuv46wkioemr[0] & lqmuv46wkioemr[2] ; 
    wire i4a1kvu2_hbfx23l = lqmuv46wkioemr[0] & lqmuv46wkioemr[3] ; 
    wire hgqt42o_in398zyz = lqmuv46wkioemr[1] & lqmuv46wkioemr[2] ; 
    wire ml_rok61a88at = lqmuv46wkioemr[1] & lqmuv46wkioemr[3] ;
    wire sw6uaap94rtzsp1o = lqmuv46wkioemr[0] & hgqt42o_in398zyz ; 
    wire zebcav5dyu00qo = lqmuv46wkioemr[0] & ml_rok61a88at ; 
    wire k2zbgvh8vznzi = lqmuv46wkioemr[3] & w007vm6p03yhnq ; 
    wire ixqxjfsc7r93x = (vn4m5rjmmk[1] == 1'b0);
    wire [5:0] xwaay_a4wg = 6'b0;
    wire [5:0] am0c48jwlzxynab = ij20gf6r_ql ? 6'd8
                        : nxx6s3u0tqk ? 6'd16
                        : y98tyjwjc93m ? 6'd32
                        : 6'd8
                        ;
    wire [5:0] qmag5nfjd87mxg0 = 6'd8;
    wire [5:0] tlg9rggc8x982 = 
                         am0c48jwlzxynab
                         ;
    assign jg4_ystzg = ua3wuinofojut_3ays  ? 6'h8 
                 : xd_av4exfq1kbozofy ? rrjsjcmt_vu
                 : m6c_thy4a3_t2khefs87 ? xwaay_a4wg 
                 : jgjuthrkb_6qx4jq5  ? i6ph7dugjr58 
                 : vy3b1_yoq2ikwkbpn7a ? tlg9rggc8x982 
                 : 6'h0
                 ;
    wire [31:0] m4ph01df7_eqzzwbes = i3qysurr19ftgex6 ? 32'h0
                             : n3hhkoazoj03ain65gnu ? {vn4m5rjmmk[7:0],24'h0}
                             : epk_kx6bz2piec4o ? {vn4m5rjmmk[15:0],16'h0}
                             : rjjhr6tvr8ixyimaw292 ? {vn4m5rjmmk[23:0],8'h0}
                             : l_0nzlfjw112bo8g ? vn4m5rjmmk
                             : 32'h0
                             ;
    wire [31:0] m5lhac44dei9ri4id = 
                             m4ph01df7_eqzzwbes;
    wire [31:0] n_4p5iv1at44kzyh1 = {8'h0,24'h0}; 
    wire [7:0] l6fho1869ws67 [3:0];
    assign l6fho1869ws67[0] = ebys4m1tyh62w[7:0];
    assign l6fho1869ws67[1] = ebys4m1tyh62w[15:8];
    assign l6fho1869ws67[2] = ebys4m1tyh62w[23:16];
    assign l6fho1869ws67[3] = ebys4m1tyh62w[31:24];
    wire [31:0] y5_4td3ifvypfyss = ij20gf6r_ql ? ( n5dcljox5vzhb6 ? {24'h0,l6fho1869ws67[0]}
                                            : fdzk2ipgnuakvtj ? {24'h0,l6fho1869ws67[1]}
                                            : daawnuhttm ? {24'h0,l6fho1869ws67[2]}
                                            : {24'h0,l6fho1869ws67[3]}
                                            )
                              : nxx6s3u0tqk ? ( ixqxjfsc7r93x ? {16'h0,l6fho1869ws67[1],l6fho1869ws67[0]}
                                            : {16'h0,l6fho1869ws67[3],l6fho1869ws67[2]}
                                            )
                              : {l6fho1869ws67[3],l6fho1869ws67[2],l6fho1869ws67[1],l6fho1869ws67[0]} 
                              ;
    wire [31:0] ovsfghdxh66xq = 
                               y5_4td3ifvypfyss
                               ;
    wire [31:0] r9bql3mt105nnm = {ovsfghdxh66xq[7:0],ovsfghdxh66xq[15:8],ovsfghdxh66xq[23:16],ovsfghdxh66xq[31:24]};
    assign jgoquohxi26 = ua3wuinofojut_3ays  ? (xuxfiprqv8 ? 
                                               {p94z0dkvxceics6snl77p,24'h0}
                                             : {8'h02,24'h0}  
                                        )
                     : xd_av4exfq1kbozofy ? m5lhac44dei9ri4id 
                     : m6c_thy4a3_t2khefs87 ? n_4p5iv1at44kzyh1 
                     : vy3b1_yoq2ikwkbpn7a ? r9bql3mt105nnm
                     : 32'h0
                     ; 
    wire [31:0] b6l4d5gwxwd6d;
    wire [31:0] px491ebqn2k1gvjje;
    wire n3shvegkwpqqq3fe = vy3b1_yoq2ikwkbpn7a & j5yfsxwh0xm;
    wire [7:0] bd7xro47ijckp [3:0];
    assign bd7xro47ijckp[0] = sa5jjxawc07x[7:0];
    assign bd7xro47ijckp[1] = sa5jjxawc07x[15:8];
    assign bd7xro47ijckp[2] = sa5jjxawc07x[23:16];
    assign bd7xro47ijckp[3] = sa5jjxawc07x[31:24];
    wire [31:0] brhfzj6l4iajoo = ij20gf6r_ql ? ( n5dcljox5vzhb6 ? {b6l4d5gwxwd6d[31:8],bd7xro47ijckp[0]}
                                            : fdzk2ipgnuakvtj ? {b6l4d5gwxwd6d[31:16],bd7xro47ijckp[0],b6l4d5gwxwd6d[7:0]}
                                            : daawnuhttm ? {b6l4d5gwxwd6d[31:24],bd7xro47ijckp[0],b6l4d5gwxwd6d[15:0]}
                                            : {bd7xro47ijckp[0],b6l4d5gwxwd6d[23:0]}
                                            )
                              : nxx6s3u0tqk ? ( ixqxjfsc7r93x ? {b6l4d5gwxwd6d[31:16],bd7xro47ijckp[0],bd7xro47ijckp[1]}
                                            : {bd7xro47ijckp[0],bd7xro47ijckp[1],b6l4d5gwxwd6d[15:0]}
                                            )
                              : {bd7xro47ijckp[0],bd7xro47ijckp[1],bd7xro47ijckp[2],bd7xro47ijckp[3]}
                              ;
e603_gnrl_dfflr #(32) flgxchucwws4kt5nsht (n3shvegkwpqqq3fe, brhfzj6l4iajoo, b6l4d5gwxwd6d, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    assign nuvz1doibyin1uaa = vjjvylyfbwx6rwgi ? 32'h0 : b6l4d5gwxwd6d;
    assign h44oj_ibu1z0h = f86884rwtdpj4yjo9ubx & ~h2wnt4mqoxlnl;
    assign ova0029jyhx98hvd = xwua0g5cuosyyl7bcq22d ;
    wire [1-1:0] hyc_koq9n9z;
    wire [1-1:0] mtb6d82vs_;
    wire [1-1:0] et4rgl21;
    wire [1-1:0] atn0fs31aj;
    wire [1-1:0] w6cw55qu0 ;
    generate 
    if(1 == 4) begin: m_45o6ayqpxg2_93e
        assign hyc_koq9n9z[0] = (tntm4hrv1mw26hrf == 3'h1); 
        assign hyc_koq9n9z[1] = (tntm4hrv1mw26hrf == 3'h2); 
        assign hyc_koq9n9z[2] = (tntm4hrv1mw26hrf == 3'h3); 
        assign hyc_koq9n9z[3] = (tntm4hrv1mw26hrf == 3'h4); 
        assign mtb6d82vs_ = hyc_koq9n9z & {4{h44oj_ibu1z0h}};
        assign et4rgl21 = (~bym3bd) & {4{ova0029jyhx98hvd}};
        assign atn0fs31aj = mtb6d82vs_ | et4rgl21;
        assign w6cw55qu0 = (~mtb6d82vs_) | et4rgl21;
e603_gnrl_dfflrs #(1) sanx7v7lhh (atn0fs31aj[0], w6cw55qu0[0], bym3bd[0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) us_piiosi8u (atn0fs31aj[1], w6cw55qu0[1], bym3bd[1], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) os5ukhwb58irj (atn0fs31aj[2], w6cw55qu0[2], bym3bd[2], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) b4ndjr3oe (atn0fs31aj[3], w6cw55qu0[3], bym3bd[3], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    end
    else if (1 == 3) begin: xg2ddj5n2amps0hy
        assign hyc_koq9n9z[0] = (tntm4hrv1mw26hrf == 3'h1); 
        assign hyc_koq9n9z[1] = (tntm4hrv1mw26hrf == 3'h2); 
        assign hyc_koq9n9z[2] = (tntm4hrv1mw26hrf == 3'h3); 
        assign mtb6d82vs_ = hyc_koq9n9z & {3{h44oj_ibu1z0h}};
        assign et4rgl21 = (~bym3bd) & {3{ova0029jyhx98hvd}};
        assign atn0fs31aj = mtb6d82vs_ | et4rgl21;
        assign w6cw55qu0 = (~mtb6d82vs_) | et4rgl21;
e603_gnrl_dfflrs #(1) sanx7v7lhh (atn0fs31aj[0], w6cw55qu0[0], bym3bd[0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) us_piiosi8u (atn0fs31aj[1], w6cw55qu0[1], bym3bd[1], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) os5ukhwb58irj (atn0fs31aj[2], w6cw55qu0[2], bym3bd[2], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    end
    else if(1 == 2) begin: u61e1v3ewmeeqxwp4kr
        assign hyc_koq9n9z[0] = (tntm4hrv1mw26hrf == 3'h1);
        assign hyc_koq9n9z[1] = (tntm4hrv1mw26hrf == 3'h2);
        assign mtb6d82vs_ = hyc_koq9n9z & {2{h44oj_ibu1z0h}};
        assign et4rgl21 = (~bym3bd) & {2{ova0029jyhx98hvd}};
        assign atn0fs31aj = mtb6d82vs_ | et4rgl21;
        assign w6cw55qu0 = (~mtb6d82vs_) | et4rgl21;
e603_gnrl_dfflrs #(1) sanx7v7lhh (atn0fs31aj[0], w6cw55qu0[0], bym3bd[0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) us_piiosi8u (atn0fs31aj[1], w6cw55qu0[1], bym3bd[1], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    end
    else if(1 == 1) begin: mfzt8lgbjpg4ycvz6
        assign hyc_koq9n9z[0] = (tntm4hrv1mw26hrf == 3'h1);
        assign mtb6d82vs_ = hyc_koq9n9z & {1{h44oj_ibu1z0h}};
        assign et4rgl21 = (~bym3bd) & {1{ova0029jyhx98hvd}};
        assign atn0fs31aj = mtb6d82vs_ | et4rgl21;
        assign w6cw55qu0 = (~mtb6d82vs_) | et4rgl21;
e603_gnrl_dfflrs #(1) sanx7v7lhh (atn0fs31aj[0], w6cw55qu0[0], bym3bd[0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    end
    endgenerate
    assign yetfszclz93 = |hyc_koq9n9z;
endmodule
module fjq8nc6h1irhemz9rgthx9a49zisy (
  input              mxwg8lfgv4pge1                 ,
  output             qi_euczbjhgo1za                 ,
  input              mqxw6of2d4b4nr7b                   ,
  input              cuu3goyrnwc9hf                  ,
  input  [  11:   0] t3lk20ui52aqc6                  ,
  input  [  31:   0] rs8qfdkpko8pq                 ,
  input  [   3:   0] swwpvt6gm3cz8                 ,
  input  [   2:   0] pccr2d0febxqx                  ,
  input              vah0tsdviw4b                  ,
  input              u7u7t6iaofiovjc                  ,
  input  [   7:   0] xwpttmbn8xqi2b0qg                  ,
  input  [   1:   0] j7onlxu8c84rohjl3                ,
  input  [   1:   0] abuhy0_a307fr_734f                 ,
  input              xi4mxnyfh8q6pd2                 ,
  input  [   2:   0] le80uwswd0y0q8                 ,
  input  [   1:   0] p5nleje0lb8ux                  ,
  input              ptdklfwbs2d13                 ,
  output             l_geblczxuwi5x4e                 ,
  output             r1ukfidrb_5kvibw                   ,
  output             nhup3xqrnngwbqsg_e               ,
  output [  31:   0] nuvz1doibyin1uaa                 ,
  input              sh2b2lwquxmyxxapt               ,
  output             n3zfnp3kttpvkse4skl4               ,
  input              xv8ytrg4q97odq9                 ,
  input              zlo0z95xdnd31kbge                ,
  input  [  26:   0] jcrj9dsl67z40w2y                ,
  input  [  31:   0] xbef1j4kr1_18aj               ,
  input  [   3:   0] v1v1zytwvme9yqhfx_g               ,
  input  [   2:   0] v_zpu3v200gvvym                ,
  input              ffvzxhz5wfwy9v                ,
  input              g5i2wkcji_izi8qzn4                ,
  input  [   7:   0] mfkz86j_bjio436                ,
  input  [   1:   0] genqu4yhgwwpi0_3qs0z              ,
  input  [   1:   0] iinbhfl2w9fbd9jue               ,
  input              g_2225gbix9c3ff               ,
  input  [   2:   0] txlgxr6zhterdis_               ,
  input  [   1:   0] so3b6iwax9zt3vi2qpr                ,
  input              kgrazhctl7rag0rnmhh               ,
  output             zlpfgr1j7yibszfzeo               ,
  output             bcni8cvge8lyl                 ,
  output             cf62leu1ptk969g_e4t             ,
  output [  31:   0] frw8p5sm65fg6dejxg               ,
  input              dmhkymm6b795q4zkoqach0v            ,
  output             v1041hzw3wb2sukzop_            ,
  output             pgqbkj2997h3vojr              ,
  input              d_6mygfd2mmf25ggsdm           ,
  output             ju8l4q3iwab8jy6oeqe8           ,
  output             r7icei2574dhycq3337g             ,
  input              ytdh3d3n7ekpzloi8tsx8wk2           ,
  output             q8p9c72msll1_p3amrdry           ,
  output             zi19i11xrx7jd1fuq34khc             ,
  input              yzd_4xbhvc_ecjar8s0q           ,
  output             eft33k6ztrvp1vhwph0           ,
  output             o0y3rnwh4pgqb_a5qv65m             ,
  input              ohksno219csx273g9eqa           ,
  output             wbs5z3a85c2l20cabodn_q           ,
  output             lrw06nxux099_s8wpaxi08             ,
  input              rmc529912l96n9_89hfrzkgi           ,
  output             t7f1uujprai4zx1mytkq           ,
  output             xt6a4d6mhv7d1_nrzgplsy             ,
  input              tx071b2z1oij56                ,
  input              czz3lmsnukdwivlhf4               ,
  input              rfobz3_ed                     ,
  output             xdsh5em7xrg                   ,
  input              ri2ziyy                           ,
  input              r46kf                         
);
  wire x7kd6gw9z3nq;
  wire h5fyr6xf;
  wire n28ajivzes3;
  wire s5xq485joofuo;
  wire e36er1uj5tr0;
  wire s6akl1c_8vxk;
  wire nwk_ulhgdn;
  wire bgbdwh2mx7n;
  wire r50r4f8sqsa68b;
  wire hby204glk3hbw;
wire [1-1:0] pt7qy;
wire [1-1:0] rgen47ck0hcqyacyce;
wire [7:0] ttz9f;
wire [7:0] pnnvff;
wire [7:0] d1ps_eg;
 wire dlmwxsha8xcd;
e603_gnrl_dffr #(1) drwuiauphh4u2ro79w (1'b1, dlmwxsha8xcd, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
 wire jesyol8j2mzc9p7rg;
 wire n3w802chksaybtkdgd_xl = mxwg8lfgv4pge1 & dlmwxsha8xcd;
 assign qi_euczbjhgo1za = jesyol8j2mzc9p7rg & dlmwxsha8xcd;
 wire s4v9mp6rnq0x0enukrs25o;
 wire f4f96kk_i6gd57tmnepb = sh2b2lwquxmyxxapt & dlmwxsha8xcd;
 assign n3zfnp3kttpvkse4skl4 = s4v9mp6rnq0x0enukrs25o & dlmwxsha8xcd;
txow53sykntpewgwpwo8  y1y3r9gn8hh102raldumo5c (
    .mxwg8lfgv4pge1    (n3w802chksaybtkdgd_xl),
    .qi_euczbjhgo1za    (jesyol8j2mzc9p7rg),
    .mqxw6of2d4b4nr7b      (mqxw6of2d4b4nr7b),
    .cuu3goyrnwc9hf     (cuu3goyrnwc9hf),
    .t3lk20ui52aqc6     (t3lk20ui52aqc6),
    .rs8qfdkpko8pq    (rs8qfdkpko8pq),
    .swwpvt6gm3cz8    (swwpvt6gm3cz8),
    .pccr2d0febxqx     (pccr2d0febxqx),
    .vah0tsdviw4b     (vah0tsdviw4b),
    .u7u7t6iaofiovjc     (u7u7t6iaofiovjc),
    .xwpttmbn8xqi2b0qg     (xwpttmbn8xqi2b0qg),
    .j7onlxu8c84rohjl3   (j7onlxu8c84rohjl3),
    .abuhy0_a307fr_734f    (abuhy0_a307fr_734f),
    .xi4mxnyfh8q6pd2    (xi4mxnyfh8q6pd2),
    .le80uwswd0y0q8    (le80uwswd0y0q8),
    .p5nleje0lb8ux     (p5nleje0lb8ux),
    .ptdklfwbs2d13    (ptdklfwbs2d13),
    .l_geblczxuwi5x4e    (l_geblczxuwi5x4e),
    .r1ukfidrb_5kvibw      (r1ukfidrb_5kvibw),
    .nhup3xqrnngwbqsg_e  (nhup3xqrnngwbqsg_e),
    .nuvz1doibyin1uaa    (nuvz1doibyin1uaa),
    .ujzzchx86xks6ojj4    (f4f96kk_i6gd57tmnepb),
    .c_ducklzf7stnt49jw9l    (s4v9mp6rnq0x0enukrs25o),
    .hpze4g8rjqif3ytfkp      (xv8ytrg4q97odq9),
    .k0cfi3p05d6up5u0hgt     (zlo0z95xdnd31kbge),
    .wdmd2i689cr0_rw     (jcrj9dsl67z40w2y),
    .m4736s1gtln35fwhcgf    (xbef1j4kr1_18aj),
    .a0j924bfaibur44lh    (v1v1zytwvme9yqhfx_g),
    .z6_ewrinky7fs00q     (v_zpu3v200gvvym[1:0]),
    .pvv6_ib82lavyiv6j     (ffvzxhz5wfwy9v),
    .jw3wwum4qxyy0a4     (g5i2wkcji_izi8qzn4),
    .kg4lvhclqypjleh8     (mfkz86j_bjio436),
    .cu1cklfkj7fvxjhmxblw   (genqu4yhgwwpi0_3qs0z),
    .bj2f3q1d4ygjts0    (iinbhfl2w9fbd9jue),
    .dls8jd8sy72s1l7qiyd    (g_2225gbix9c3ff),
    .k1s5tfm_fgj2ag8zzsh6    (txlgxr6zhterdis_),
    .n6v_zrs4lbtm3w8uv     (so3b6iwax9zt3vi2qpr),
    .ejwzhpac9_9wrtw    (kgrazhctl7rag0rnmhh),
    .xno5aaqma8iyzy6_    (zlpfgr1j7yibszfzeo),
    .if9w49ig48xwip6v      (bcni8cvge8lyl),
    .q3yl8b45qie0ee64f  (cf62leu1ptk969g_e4t),
    .wa9ixo6v81gxlkyk47pm    (frw8p5sm65fg6dejxg),
     .r50r4f8sqsa68b         (r50r4f8sqsa68b),
     .hby204glk3hbw         (hby204glk3hbw),
    .pl4w5klaegaid      (rgen47ck0hcqyacyce),
    .s5xq485joofuo      (s5xq485joofuo),
    .n28ajivzes3      (n28ajivzes3),
    .s6akl1c_8vxk      (s6akl1c_8vxk),
    .e36er1uj5tr0      (e36er1uj5tr0),
    .nwk_ulhgdn       (nwk_ulhgdn),
    .pf4_b0e3ymdaf     (bgbdwh2mx7n),
    .tx071b2z1oij56   (tx071b2z1oij56),
    .czz3lmsnukdwivlhf4  (czz3lmsnukdwivlhf4),
    .x7kd6gw9z3nq         (x7kd6gw9z3nq         ),
    .h5fyr6xf         (h5fyr6xf         ),
    .br7a8dw5rndor        (v1041hzw3wb2sukzop_),
    .ct6pxuoq         (pt7qy               ),
    .imb7nq3h         (ttz9f               ),
    .of6bvne9f         (d1ps_eg             ),
    .f2pcwb9mj         (pnnvff             ),
    .ri2ziyy              (ri2ziyy              ),
    .r46kf            (r46kf            ) 
);
assign xdsh5em7xrg = x7kd6gw9z3nq 
                   | h5fyr6xf 
                   | n28ajivzes3 
                   | s5xq485joofuo
                   | e36er1uj5tr0 
                   | s6akl1c_8vxk
                   | nwk_ulhgdn
                   | r50r4f8sqsa68b
                   | hby204glk3hbw
                   ;
assign ju8l4q3iwab8jy6oeqe8 = pt7qy[0];
assign pnnvff = {
               4'h0,
               rmc529912l96n9_89hfrzkgi,
               ohksno219csx273g9eqa,
               yzd_4xbhvc_ecjar8s0q,
               ytdh3d3n7ekpzloi8tsx8wk2
              };
  assign t7f1uujprai4zx1mytkq = d1ps_eg[3];
  assign wbs5z3a85c2l20cabodn_q = d1ps_eg[2];
  assign eft33k6ztrvp1vhwph0 = d1ps_eg[1];
  assign q8p9c72msll1_p3amrdry = d1ps_eg[0];
  assign xt6a4d6mhv7d1_nrzgplsy = ttz9f[3];
  assign lrw06nxux099_s8wpaxi08 = ttz9f[2];
  assign o0y3rnwh4pgqb_a5qv65m = ttz9f[1];
  assign zi19i11xrx7jd1fuq34khc = ttz9f[0];
assign r7icei2574dhycq3337g  = rgen47ck0hcqyacyce[0];
assign pgqbkj2997h3vojr  = 1'b1;
endmodule
module txow53sykntpewgwpwo8 (
    input              mxwg8lfgv4pge1                 ,
  output             qi_euczbjhgo1za                 ,
  input              mqxw6of2d4b4nr7b                   ,
  input              cuu3goyrnwc9hf                  ,
  input  [  11:   0] t3lk20ui52aqc6                  ,
  input  [  31:   0] rs8qfdkpko8pq                 ,
  input  [   3:   0] swwpvt6gm3cz8                 ,
  input  [   2:   0] pccr2d0febxqx                  ,
  input              vah0tsdviw4b                  ,
  input              u7u7t6iaofiovjc                  ,
  input  [   7:   0] xwpttmbn8xqi2b0qg                  ,
  input  [   1:   0] j7onlxu8c84rohjl3                ,
  input  [   1:   0] abuhy0_a307fr_734f                 ,
  input              xi4mxnyfh8q6pd2                 ,
  input  [   2:   0] le80uwswd0y0q8                 ,
  input  [   1:   0] p5nleje0lb8ux                  ,
  input              ptdklfwbs2d13                 ,
  output             l_geblczxuwi5x4e                 ,
  output             r1ukfidrb_5kvibw                   ,
  output             nhup3xqrnngwbqsg_e               ,
  output [  31:   0] nuvz1doibyin1uaa                 ,
    input                ujzzchx86xks6ojj4   ,
    output               c_ducklzf7stnt49jw9l   ,
    input                hpze4g8rjqif3ytfkp     ,
    input                k0cfi3p05d6up5u0hgt    ,
    input  [27-1:0] wdmd2i689cr0_rw    ,
    input  [32-1:0] m4736s1gtln35fwhcgf   ,
    input  [3:0]         a0j924bfaibur44lh   ,
    input  [1:0]         z6_ewrinky7fs00q    ,
    input                pvv6_ib82lavyiv6j    ,
    input                jw3wwum4qxyy0a4    ,
    input  [7:0]         kg4lvhclqypjleh8    ,
    input  [1:0]         cu1cklfkj7fvxjhmxblw  ,
    input  [1:0]         bj2f3q1d4ygjts0   ,
    input                dls8jd8sy72s1l7qiyd   ,
    input  [2:0]         k1s5tfm_fgj2ag8zzsh6   ,
    input                ejwzhpac9_9wrtw   ,
    output               xno5aaqma8iyzy6_   ,
    output               if9w49ig48xwip6v     ,
    output               q3yl8b45qie0ee64f ,
    output [32-1:0] wa9ixo6v81gxlkyk47pm   ,
    input   [1:0]        n6v_zrs4lbtm3w8uv    , 
    output                        hby204glk3hbw,
    output                        r50r4f8sqsa68b,
  output                       x7kd6gw9z3nq,
  output                       h5fyr6xf,
  output                       br7a8dw5rndor,
  output [1-1:0] pl4w5klaegaid,
  output                       n28ajivzes3,
  output                       s5xq485joofuo,
  output                       e36er1uj5tr0,
  output                       s6akl1c_8vxk,
  output                       nwk_ulhgdn,
  output                       pf4_b0e3ymdaf,
  output  [1-1:0]ct6pxuoq,
  output  [7:0]                imb7nq3h,
  output  [7:0]                of6bvne9f,
  input   [7:0]                f2pcwb9mj,
  input                        tx071b2z1oij56,
  input                        czz3lmsnukdwivlhf4,
  input                        ri2ziyy,
  input                        r46kf   
);
assign if9w49ig48xwip6v = 1'b0;
assign q3yl8b45qie0ee64f = 1'b0;
assign nhup3xqrnngwbqsg_e = 1'b0;
assign r1ukfidrb_5kvibw = 1'b0;
wire [11:0] te79w3m1s;
wire [1-1:0] pt7qy;
wire dgzm3zm3ogvw, lh74zppbcl4;
wire cm3r24ltl2gx, lqhrn87uxvqt;
wire [1:0] wzsi3d;
wire [5:0] fj3di,ujy_7sawj;
wire qeo6nc ;
wire oih5t0l8wy_;
wire ixkn7y8_9x;
wire [31:0] uh0t93udo6,gghz_6zv;
wire j5yfsxwh0xm,llhht8w4fsz;
wire ova0029jyhx98hvd;  
wire h44oj_ibu1z0h;
wire [7:0]    wxyxjhortejmt3;        
wire [7:0]    wcja3zdd0t7j;  
wire [7:0]    rlj4cog5b111mwd;  
wire          b47qcro0nyi; 
wire [2:0]    djkt53av;
wire [1-1:0] l3bywjb87dberrlhon;
wire          qvfdyis4_xxmz;
wire [1-1:0] hvtb90hz3c8v_q = 1'b1;
assign pl4w5klaegaid[0]  = hvtb90hz3c8v_q[0];
wire rqos2ss_hld9pn;
wire mx3lsy0gkyfsk;
wire [7:0]    zq24232ios6r6zp_5z;  
wire [7:0]    alyk6czk2i8x49b4o8qt;  
wire [2:0]    e9_y_d7sb2b0zb5e;  
wire [5:0]    kq4x1wc10nitj;
ca39w4c4lkrx4azh552sn  irve77ss_w7elzvpqdft (
    .mxwg8lfgv4pge1  (mxwg8lfgv4pge1),
    .qi_euczbjhgo1za  (qi_euczbjhgo1za),
    .cuu3goyrnwc9hf   (cuu3goyrnwc9hf ),
    .t3lk20ui52aqc6   (t3lk20ui52aqc6 ),
    .rs8qfdkpko8pq  (rs8qfdkpko8pq),
    .l_geblczxuwi5x4e  (l_geblczxuwi5x4e),
    .ptdklfwbs2d13  (ptdklfwbs2d13),
    .nuvz1doibyin1uaa  (nuvz1doibyin1uaa),
    .x7kd6gw9z3nq       (x7kd6gw9z3nq),
    .h5fyr6xf       (h5fyr6xf),
    .n28ajivzes3    (n28ajivzes3),
    .s5xq485joofuo    (s5xq485joofuo),
    .e36er1uj5tr0    (e36er1uj5tr0),
    .s6akl1c_8vxk    (s6akl1c_8vxk),
    .nwk_ulhgdn     (nwk_ulhgdn),
    .zq24232ios6r6zp_5z     (zq24232ios6r6zp_5z     ),  
    .alyk6czk2i8x49b4o8qt    (alyk6czk2i8x49b4o8qt    ),  
    .e9_y_d7sb2b0zb5e     (e9_y_d7sb2b0zb5e     ),  
    .kq4x1wc10nitj      (kq4x1wc10nitj      ),
    .cl_8d3kdihjb9yq (dgzm3zm3ogvw ),
    .vm78tgdkfetjjfd (lh74zppbcl4 ),
    .ncpbeb24mmnc60 (lqhrn87uxvqt ),
    .flk5mvwbvqzxirah (cm3r24ltl2gx ),
    .hrrr6xbwwneddk  (uh0t93udo6  ),
    .o8sv0e253jptbb2s5  (gghz_6zv  ),
    .p7cldie50p2tmud  (j5yfsxwh0xm  ),
    .n316zisfnflxfgps  (llhht8w4fsz  ),
    .wxyxjhortejmt3          (wxyxjhortejmt3          ),        
    .wcja3zdd0t7j          (wcja3zdd0t7j          ),  
    .rlj4cog5b111mwd        (rlj4cog5b111mwd        ),  
    .b47qcro0nyi           (b47qcro0nyi           ),
    .ox3ajqsqp          (qeo6nc      ),
    .skbwq1o6wlc          (te79w3m1s      ),
    .ct6pxuoq           (pt7qy       ),
    .ws03glm08u787psex3fe (ova0029jyhx98hvd),
    .cfn05giriyb8lt3_nh   (h44oj_ibu1z0h),
    .jyf0lghvzzuj2r         (djkt53av  ),
    .l3bywjb87dberrlhon    (l3bywjb87dberrlhon),
    .r50r4f8sqsa68b  (r50r4f8sqsa68b),
    .hby204glk3hbw  (hby204glk3hbw),
    .tx071b2z1oij56   (tx071b2z1oij56),
    .czz3lmsnukdwivlhf4  (czz3lmsnukdwivlhf4),
    .ri2ziyy                   (ri2ziyy  ),
    .r46kf                 (r46kf)
);
wire [1-1:0] xuzjd8d2nx;
assign ct6pxuoq  = xuzjd8d2nx ;  
wire zh9ykzl4qn_, ute24ms4bj6;
wire si_lz03o = zh9ykzl4qn_ | ute24ms4bj6;
wire q9z4xfqd;
wire qdu7w0eullr, p8xp4k82_ar;
assign br7a8dw5rndor = q9z4xfqd;
wire pg4jupxyu56;
wire spx966rqubdp;
wire f9lakbhi2c_3u = zh9ykzl4qn_ ? pg4jupxyu56 : spx966rqubdp;
wire [1-1:0] bym3bd;
wire [1-1:0] sw3u97amt6th6v = b47qcro0nyi ? bym3bd : l3bywjb87dberrlhon;
  wire u22lf_yqc9xi;
  wire xgxysjrdkxtd;
  wire m989et_avztex8;
  wire psu21gtrpxzsr;
  wire g4detaxasa;
  wire yxvsxa91zb2x;
  wire eq_14;
  wire ild_jl_xu;
  wire [5:0] jg4_ystzg;
  wire [31:0] jgoquohxi26;
  wire uwm34_q1qt;
  wire [31:0] sa5jjxawc07x;
  wire h_8_t8vhr5b_v;
  wire czjn2klzbfd87v;
  wire ory71ajyzb6iqa;
  wire nyfk9pmqi8dby5egm;
  wire jsadt688a0178q;
  wire fl3gj5l4xbul5a;
  wire aj_1pl44n7l3zrwl;
  wire [31:0] qyf1eg47j4fp;
  wire [31:0] u1yzzzi4sipk;
  wire y41_sd8_nl10;
  assign czjn2klzbfd87v = b47qcro0nyi ? u22lf_yqc9xi : lqhrn87uxvqt;
  assign xgxysjrdkxtd = b47qcro0nyi ? ory71ajyzb6iqa : 1'b0;
  assign cm3r24ltl2gx   = b47qcro0nyi ? 1'b0 : ory71ajyzb6iqa;
  assign m989et_avztex8 = b47qcro0nyi ? nyfk9pmqi8dby5egm : 1'b0;
  assign llhht8w4fsz   = b47qcro0nyi ? 1'b0 : nyfk9pmqi8dby5egm;
  wire nmbnl26wyimm7p;
e603_gnrl_dfflr #(1) avipdtrs0ppo9ztxabn06c_9(1'b1, aj_1pl44n7l3zrwl, nmbnl26wyimm7p, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign jsadt688a0178q = b47qcro0nyi ? psu21gtrpxzsr : dgzm3zm3ogvw;
  assign g4detaxasa = b47qcro0nyi ? fl3gj5l4xbul5a : 1'b0;
  assign lh74zppbcl4 = b47qcro0nyi ? 1'b0 : fl3gj5l4xbul5a;
  assign yxvsxa91zb2x = b47qcro0nyi ? (
                                aj_1pl44n7l3zrwl) : 1'b0;
  assign j5yfsxwh0xm = b47qcro0nyi ? 1'b0 : aj_1pl44n7l3zrwl;
  assign qvfdyis4_xxmz = b47qcro0nyi ? eq_14 : (
                                        qeo6nc); 
  assign y41_sd8_nl10 = b47qcro0nyi ? ild_jl_xu : 1'b0;
  assign qyf1eg47j4fp = b47qcro0nyi ? jgoquohxi26 : gghz_6zv;
  assign sa5jjxawc07x = u1yzzzi4sipk;
  assign uh0t93udo6 = u1yzzzi4sipk;
  assign xuzjd8d2nx = b47qcro0nyi ? bym3bd : pt7qy;
  wire [5:0] b0zcdbk40ehyx91 = b47qcro0nyi ? jg4_ystzg : 6'd8;
  wire [5:0] l_ytia_njvkzsrg = b47qcro0nyi ? jg4_ystzg : 6'd8;
  wire lr99tu = f2pcwb9mj[0];
  wire wk3but = f2pcwb9mj[1];
  wire u4u_sqx8 = f2pcwb9mj[2];
  wire bmvw = f2pcwb9mj[3];
  wire c2shs5lw6 = f2pcwb9mj[4];
  wire tgvjtr = f2pcwb9mj[5];
  wire mb7xvdsj = f2pcwb9mj[6];
  wire sova = f2pcwb9mj[7];
  wire d6frv2kmhiva;
  wire n0yca91sw9hy2d4i3d67;
  wire nzfgk3gj4 = te79w3m1s[0];
o2625zzxlldir4mw_qmkmea  w83i0ec44ka1lzwlpf2lvjmz1s (
    .m06qnpn5a9z03       (si_lz03o  ),
    .mvqrtq7dyd0jl4      (te79w3m1s ),
    .wgc1pcq7e4       (sw3u97amt6th6v  ),
    .qtsnhkdndbh    (zh9ykzl4qn_),
    .d9n3ph7pubth72d7c  (f9lakbhi2c_3u),
    .br7a8dw5rndor      (q9z4xfqd ),
    .b3nk3ml5dggetwx1   (qdu7w0eullr ),
    .fekszkc1bqs8x6b   (p8xp4k82_ar ),
    .ri2ziyy            (ri2ziyy     ),
    .r46kf          (r46kf   )
);
p6devqb4ptpbm5ap_h ec1_ohqsokvi2r491gf4y_
(
    .ssaglb56qjhnl       (jsadt688a0178q),
    .dfi9g_4x75iz3b       (fl3gj5l4xbul5a),
    .sx6i39j26_        (qdu7w0eullr  ),
    .hja3lm6no_t0q        (p8xp4k82_ar  ),
    .h1u9k_           (lr99tu     ),
    .rx9aqne           (wk3but     ),
    .db10mb8xe           (u4u_sqx8     ),
    .zh_xnfrx           (bmvw     ),
    .noqeoiuvnu           (c2shs5lw6     ),
    .h5ub76gz           (tgvjtr     ),
    .gye3x8met           (mb7xvdsj     ),
    .p6tci4w33tx           (sova     ),
    .s_w4zt6mvts         (l_ytia_njvkzsrg),
    .nfv0zewnc        (qvfdyis4_xxmz),
    .ug0f667go        (aj_1pl44n7l3zrwl ),
    .o1a2rfpyxis        (u1yzzzi4sipk ),
    .o79s9jhh3qahq      (zh9ykzl4qn_   ),
    .neq4t0yh_0bn8s74     (pg4jupxyu56   ),
    .ri2ziyy            (ri2ziyy     ),
    .r46kf          (r46kf   )
);
  wire uhgb7m1;
  wire k3ojutwd;
  wire h6gr;
  wire hd3wpzc;
  wire vh518od0;
  wire n_9v;
  wire qauqz;
  wire wkrv7d;
  assign of6bvne9f[0] =                       uhgb7m1;
  assign of6bvne9f[1] =                       k3ojutwd;
  assign of6bvne9f[2] =                     h6gr;
  assign of6bvne9f[3] =                     hd3wpzc;
  assign of6bvne9f[4] =                     vh518od0;
  assign of6bvne9f[5] =                     n_9v;
  assign of6bvne9f[6] =                     qauqz;
  assign of6bvne9f[7] =                     wkrv7d;
  wire bwsa0z3i4jwjoht;
vna3s3dz39qbawowo3 vo9pjspz1uzib0z6w8a5qpbd (
    .zouj6_xexoto9ok        (czjn2klzbfd87v    ),
    .o525acty1z2m        (ory71ajyzb6iqa    ),
    .s4l4bqtrr8c         (qyf1eg47j4fp     ),
    .hja3lm6no_t0q         (p8xp4k82_ar          ),
    .oo4ed1ww3q9          (b0zcdbk40ehyx91      ),
    .xvgqjver            (uhgb7m1             ),
    .ajbsjn0thsh            (k3ojutwd             ),
    .bkivycod            (h6gr             ),
    .fgavjah3            (hd3wpzc             ),
    .d9njukh0            (vh518od0             ),
    .ljres1z5            (n_9v             ),
    .re3z_qh            (qauqz             ),
    .e7kvhs6agh            (wkrv7d             ),
    .n0vgfy8z9a_og         (nyfk9pmqi8dby5egm     ),
    .mntm2jd6ths4ryk       (ute24ms4bj6        ),
    .rektx_amz8m3x      (spx966rqubdp       ),
    .br8ywe_g54b133huyhgdt  (bwsa0z3i4jwjoht     ),
    .ri2ziyy            (ri2ziyy     ),
    .r46kf          (r46kf   )
);
wire xc0a8ba6;
wire bgx;
wire vi4;
wire pnddarj;
wire o_i1zvy;
wire f9w0wnh;
wire e66;
wire lphic2z9;
wire habimqi9i3tkrb55ra_trrr;
wire glge190dw8k45s_h = czjn2klzbfd87v & ory71ajyzb6iqa;
wire kspjxip88yrc77d = jsadt688a0178q & fl3gj5l4xbul5a;
wire a7lvlt24e4uw7died;
wire ossq97xuptvuvrr0yp7;
assign habimqi9i3tkrb55ra_trrr = b47qcro0nyi ? a7lvlt24e4uw7died : ova0029jyhx98hvd;
wire roks7y80biiuvasqy1urx = b47qcro0nyi ? ossq97xuptvuvrr0yp7 : h44oj_ibu1z0h;
wire ruqqtcsc = bwsa0z3i4jwjoht | glge190dw8k45s_h | kspjxip88yrc77d | habimqi9i3tkrb55ra_trrr | roks7y80biiuvasqy1urx;
wire h3o1wpjw51daxv = (habimqi9i3tkrb55ra_trrr | bwsa0z3i4jwjoht);
wire ktd2oi4na94 = ruqqtcsc;
wire j8__z7fxq = ruqqtcsc;
wire o4ldu9lijmy = ruqqtcsc;
wire sosazw5 = ruqqtcsc;
wire io1l3n34556 = ruqqtcsc;
wire nfm7vbn_ = ruqqtcsc;
wire rvayq62l = ruqqtcsc;
wire u9of83e = ruqqtcsc;
wire e8haab3bpndw = h3o1wpjw51daxv ? 1'b0 : kspjxip88yrc77d ? 1'b1 : 1'b1;
wire u24f0o6e8r = h3o1wpjw51daxv ? 1'b0 : kspjxip88yrc77d ? 1'b0 : 1'b0; 
wire slzj_rlcp2 = 1'b1 ;
wire z8u_7jb74zry = 1'b1 ;
wire xvi80oq9 = h3o1wpjw51daxv ? 1'b0 : kspjxip88yrc77d ? 1'b0 : 1'b0;
wire bggg451 = h3o1wpjw51daxv ? 1'b0 : kspjxip88yrc77d ? 1'b0 : 1'b0;
wire h3tvm2p68w = h3o1wpjw51daxv ? 1'b0 : kspjxip88yrc77d ? 1'b0 : 1'b0;
wire dtlu1rd = h3o1wpjw51daxv ? 1'b0 : kspjxip88yrc77d ? 1'b0 : 1'b0;
e603_gnrl_dfflr #(1) ue7niijlanipl(ktd2oi4na94, e8haab3bpndw, xc0a8ba6, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) unzn9w7cbt(j8__z7fxq, u24f0o6e8r, bgx, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) dkg6ixtgm(o4ldu9lijmy, slzj_rlcp2, vi4, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) necai71lwi9vf(sosazw5, z8u_7jb74zry, pnddarj, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) qq24r1sr0qtsp(io1l3n34556, xvi80oq9, o_i1zvy, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) njnuvwofl7ehx(nfm7vbn_, bggg451, f9w0wnh, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) y50vzm_jv(rvayq62l, h3tvm2p68w, e66, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) mvhvvu0tk0xvq(u9of83e, dtlu1rd, lphic2z9, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
assign imb7nq3h[0] =                     xc0a8ba6;
assign imb7nq3h[1] =                     bgx;
assign imb7nq3h[2] =                     vi4;
assign imb7nq3h[3] =                     pnddarj;
assign imb7nq3h[4] =                     o_i1zvy;
assign imb7nq3h[5] =                     f9w0wnh;
assign imb7nq3h[6] =                     e66;
assign imb7nq3h[7] =                     lphic2z9;
  assign pf4_b0e3ymdaf = b47qcro0nyi;
  wire [27-1 :0] qwxh9dsc6nyze3xfkzvhu;
  assign qwxh9dsc6nyze3xfkzvhu = wdmd2i689cr0_rw[27-1: 0];
ohjjdtin80yczoqofg91n92vyy # (
    .ml0wdobwya9wrawo (27),
    .xkaaf5c8vmrql9ch (32)
) kdh0tjeqipzm92lz4_9s2ip3jskl(
    .i7a27l9f3azj              (wxyxjhortejmt3        ),
    .tu2hl1iupxdfyq0              (wcja3zdd0t7j        ),
    .n1pxkwrf2f11r_im            (rlj4cog5b111mwd      ),
    .ac9pck1o438e               (b47qcro0nyi         ),
    .styvvt8p4khvqg                (te79w3m1s),
    .mxwg8lfgv4pge1             (ujzzchx86xks6ojj4  ),
    .qi_euczbjhgo1za             (c_ducklzf7stnt49jw9l  ),
    .cuu3goyrnwc9hf              (k0cfi3p05d6up5u0hgt   ),
    .t3lk20ui52aqc6              (qwxh9dsc6nyze3xfkzvhu ),
    .rs8qfdkpko8pq             (m4736s1gtln35fwhcgf  ),
    .pccr2d0febxqx              (z6_ewrinky7fs00q   ),
    .swwpvt6gm3cz8             (a0j924bfaibur44lh  ), 
    .xwpttmbn8xqi2b0qg              (kg4lvhclqypjleh8   ),
    .j7onlxu8c84rohjl3            (cu1cklfkj7fvxjhmxblw ),
    .p5nleje0lb8ux              (n6v_zrs4lbtm3w8uv   ),
    .l_geblczxuwi5x4e             (xno5aaqma8iyzy6_  ),
    .ptdklfwbs2d13             (ejwzhpac9_9wrtw  ),
    .nuvz1doibyin1uaa             (wa9ixo6v81gxlkyk47pm  ),
    .w2u2a8j7tq1r4rozh            (u22lf_yqc9xi       ),
    .d0ayb3zgcx_763            (xgxysjrdkxtd       ),
    .llhht8w4fsz                   (m989et_avztex8        ),
    .x_9z5321korhcm            (psu21gtrpxzsr       ),
    .by76o8v4ied3t88q6y            (g4detaxasa       ),
    .p94z0dkvxceics6snl77p         (zq24232ios6r6zp_5z   ),
    .h299pga1y47pk9dltr        (alyk6czk2i8x49b4o8qt  ),
    .spuogxa2dnoh6g9eub         (e9_y_d7sb2b0zb5e   ),
    .l62rrzbqseu_o4cqbl3g          (kq4x1wc10nitj    ),
    .j5yfsxwh0xm                   (yxvsxa91zb2x        ), 
    .eq_14                     (eq_14            ),
    .ild_jl_xu                     (ild_jl_xu            ),
    .jg4_ystzg                     (jg4_ystzg            ),
    .jgoquohxi26                 (jgoquohxi26        ),
    .sa5jjxawc07x                 (sa5jjxawc07x        ),
    .tntm4hrv1mw26hrf               (djkt53av         ),
    .bym3bd                      (bym3bd             ), 
    .ova0029jyhx98hvd            (a7lvlt24e4uw7died ), 
    .h44oj_ibu1z0h              (ossq97xuptvuvrr0yp7   ), 
    .ri2ziyy                       (ri2ziyy              ),
    .r46kf                     (r46kf            ) 
);
endmodule
module ca39w4c4lkrx4azh552sn  (
    input           mxwg8lfgv4pge1 ,
    output          qi_euczbjhgo1za ,
    input           cuu3goyrnwc9hf  ,
    input  [12-1:0] t3lk20ui52aqc6  ,
    input  [32-1:0] rs8qfdkpko8pq ,
    output          l_geblczxuwi5x4e ,
    input           ptdklfwbs2d13 ,
    output [32-1:0] nuvz1doibyin1uaa ,
    output          cl_8d3kdihjb9yq,
    input           vm78tgdkfetjjfd,
    output          ncpbeb24mmnc60,
    input           flk5mvwbvqzxirah,
    input  [31:0]   hrrr6xbwwneddk,
    output [31:0]   o8sv0e253jptbb2s5,
    input           p7cldie50p2tmud,
    input           n316zisfnflxfgps,
    output [7:0]    wxyxjhortejmt3        ,        
    output [7:0]    wcja3zdd0t7j        ,  
    output [7:0]    rlj4cog5b111mwd      ,  
    output          b47qcro0nyi         ,
    output [11:0]   skbwq1o6wlc     ,
    output [1-1:0]  ct6pxuoq ,
    output          ox3ajqsqp     ,
    output          ws03glm08u787psex3fe ,
    output          cfn05giriyb8lt3_nh ,
    output [2:0]    jyf0lghvzzuj2r    , 
    output [1-1:0]  l3bywjb87dberrlhon,
    output          x7kd6gw9z3nq,
    output          h5fyr6xf,
    output          n28ajivzes3,
    output          s5xq485joofuo,
    output          e36er1uj5tr0,
    output          s6akl1c_8vxk,
    output          nwk_ulhgdn,
    output [2:0]    e9_y_d7sb2b0zb5e,
    output [7:0]    zq24232ios6r6zp_5z,
    output [7:0]    alyk6czk2i8x49b4o8qt,
    output [5:0]    kq4x1wc10nitj,
    output         r50r4f8sqsa68b,
    output         hby204glk3hbw,
    input          tx071b2z1oij56,  
    input          czz3lmsnukdwivlhf4,
    input          ri2ziyy,
    input          r46kf   
);
  localparam  uwrgm1oivt1de06hok = 3;
  localparam  iv3x8o35w_812gndmsh8q = 3;
  localparam  xvznr0vq3yntjp    = 8;
  localparam  rscjc_sf9gwn       = 8'h00;  
  localparam  n27wkt08d_9qfr        = 8'h14;
  localparam  nwp00k898h33p         = 8'h10;
  localparam  e2ifwcg7u6s6p       = 8'h18;
  localparam  syj63wcjdkr6      = 8'h1c;
  localparam  eij5homjpm2taa     = 8'h30;
  localparam  r6bj0club        = 8'h34; 
  localparam  c6fgkjll7        = 8'h38; 
  localparam  v2rnhfq30j0         = 8'h64;
  localparam  w2l7ipi6vzf        = 8'h78;
  localparam  hmpd8hyy0n1          = 8'h40;
  localparam  tcwtege0uvr       = 8'h48;
  localparam  qpypgcrd9t5sc       = 8'h4C;
  localparam  z6ffjin7kt        = 8'h60;
  localparam  fwt0iomyle26tg       = 8'h7C;
  localparam  d85xfrdlyv3h7o       = 8'h50;  
  localparam  l6acur2nvge       = 8'h54; 
  localparam  ju27uois           = 8'h70;    
  localparam  eb2fddy49           = 8'h74;   
  localparam  vqvmx2htkswx92kunr   = 8'hb8;
  localparam  defo1mslx96b30o4y6y   = 8'hbc;
  localparam rjz3ekdeoph_ikp = 4;
  wire q4n0kbcn24onq;
  wire [rjz3ekdeoph_ikp-1:0] uloh18s35kco3lh3;
  wire [rjz3ekdeoph_ikp-1:0] y6ciiggp4rpi5wb;
  localparam fusofx_uxiq0ovvs0pw   = 4'd0;
  localparam rzo5c5uj93mxj6qgh6  = 4'd1;
  localparam fwi10o6jkxn5uz47     = 4'd2;
  localparam a60aiqgftapr3ju  = 4'd3;
  localparam rcw8ushc9tij1lwcoxhy  = 4'd4;
  localparam bqbrwf_ud5q1h54sqk = 4'd6;
  localparam ndbg5krrqovrvfsy3sip  = 4'd7;
  wire [rjz3ekdeoph_ikp-1:0] ifm4f61h58jxyo;
  wire [rjz3ekdeoph_ikp-1:0] vre5wjf3393nlq9x4n;
  wire [rjz3ekdeoph_ikp-1:0] gbhe559k80avm3;
  wire [rjz3ekdeoph_ikp-1:0] uzw1nk84ivcdjr802gaj;
  wire [rjz3ekdeoph_ikp-1:0] on4t7sdr24yw85y;
  wire [rjz3ekdeoph_ikp-1:0] yn411_oev6qy761oz;
  wire [rjz3ekdeoph_ikp-1:0] bv7_kf4mufxex6re;
  wire [rjz3ekdeoph_ikp-1:0] zvhzy3kk4eudv3ur2w;
  wire  f86884rwtdpj4yjo9ubx;
  wire  xwua0g5cuosyyl7bcq22d;
  wire  v0j5p8vof4vfl6halta1d3;
  wire  qr1ktq99r1r7adt9bykuwf6;
  wire  g4hvb6t2tcpvpmy5ztu06wf;
  wire  owspmqpjt3r98k_9ah43l_y;
  wire  gw9f_lxd_td208e1e4w04m6x;
  wire  jbshcx_02es1e2h_z497s;
  wire  bc15m7x5hle8wug30q5d7q   = (y6ciiggp4rpi5wb == fusofx_uxiq0ovvs0pw);
  wire  ockberyjadrlpqs_37a  = (y6ciiggp4rpi5wb == rzo5c5uj93mxj6qgh6);
  wire  ogg3u1an6aww4bf03m     = (y6ciiggp4rpi5wb == fwi10o6jkxn5uz47);
  wire  kmouutgd0lpig6hyyee14r  = (y6ciiggp4rpi5wb == a60aiqgftapr3ju);
  wire  d83it4age7ju2ig84fmx  = (y6ciiggp4rpi5wb == rcw8ushc9tij1lwcoxhy);
  wire  g_qf_dmlhn3danr0v5kobvo = (y6ciiggp4rpi5wb == bqbrwf_ud5q1h54sqk);
  wire  w2fmoslm8laspgvfaed4k1  = (y6ciiggp4rpi5wb == ndbg5krrqovrvfsy3sip);
  wire h9v5e_bsrlv6bm       = mxwg8lfgv4pge1 & qi_euczbjhgo1za;
  wire ngwewd3qoq98          = h9v5e_bsrlv6bm & (~cuu3goyrnwc9hf);
  wire pwpuryi8mwipv          = h9v5e_bsrlv6bm & cuu3goyrnwc9hf;
  wire epepn2mq9892r3p       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == rscjc_sf9gwn );
  wire wbk40x4jp__55kics     = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == eij5homjpm2taa );
  wire u5znxk77_g1_z         = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == nwp00k898h33p   );
  wire acd10fl3i4hy0_       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == e2ifwcg7u6s6p);
  wire e5rf0cne7hld_23o          = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == hmpd8hyy0n1    );
  wire pgx8we2z8eo85u2zq       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == tcwtege0uvr );
  wire td3c7vmwx85jq6       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == qpypgcrd9t5sc );
  wire yyu5li2ei7vimca5im        = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == z6ffjin7kt  );
  wire zwbdbqumqxivnz3c       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == fwt0iomyle26tg );
  wire co99pyyr16nf8_k6pme       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == l6acur2nvge );
  wire a6yhznotyrv9079       = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == d85xfrdlyv3h7o );
  wire r11a7tc59btbe3           = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == ju27uois );
  wire n73uhk7tbh3           = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == eb2fddy49 );
  wire mtq827237iwl6m3nog        = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == n27wkt08d_9qfr) ;
  wire pbd0h88k_1zi0qzx7v      = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == syj63wcjdkr6 );
  wire gqvqu1eburyx0         = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == v2rnhfq30j0   );
  wire peo331psk3qxo        = (t3lk20ui52aqc6[xvznr0vq3yntjp-1:0] == w2l7ipi6vzf  );
  wire mbmqixpfu6j3yoj       = zwbdbqumqxivnz3c       & ngwewd3qoq98 ;
  wire bon6u_53hv32sbml2h9    = pwpuryi8mwipv & wbk40x4jp__55kics;
  wire q9nyrn1fnpojnu1nr      = pwpuryi8mwipv & epepn2mq9892r3p ;
  wire nsirysuw9mbl        = pwpuryi8mwipv & u5znxk77_g1_z   ;
  wire qaoxt9ifof7fipzkqp      = pwpuryi8mwipv & acd10fl3i4hy0_ ;
  wire mrijmdd3zudmw         = pwpuryi8mwipv & e5rf0cne7hld_23o    ;
  wire jnobdywjfyhd0y1r1      = pwpuryi8mwipv & zwbdbqumqxivnz3c ;
  wire pa3roly_trneoe626fa      = pwpuryi8mwipv & pgx8we2z8eo85u2zq ;
  wire qloxrv_hblxc99      = pwpuryi8mwipv & td3c7vmwx85jq6 ;
  wire lmrge6nnogakzcj_h       = pwpuryi8mwipv & yyu5li2ei7vimca5im  ;
  wire ab0lk338_y29rvfa      = pwpuryi8mwipv & co99pyyr16nf8_k6pme ;
  wire txy1t8oi9vk39z      = pwpuryi8mwipv & a6yhznotyrv9079 ;
  wire x80g5jbypwd          = pwpuryi8mwipv & r11a7tc59btbe3 ;
  wire diiubqnnoktl98          = pwpuryi8mwipv & n73uhk7tbh3 ;
  wire z1c2sicz7azk92bnu       = pwpuryi8mwipv & mtq827237iwl6m3nog  ;
  wire fxrkjbputadb8hotr     = pwpuryi8mwipv & pbd0h88k_1zi0qzx7v ;
  wire s3f_6_qkb0pnss59q        = pwpuryi8mwipv & gqvqu1eburyx0   ;
  wire xwng2_40012hor0       = pwpuryi8mwipv & peo331psk3qxo  ;
    wire zifh2a9n4kmw90;
  wire urc40td1nn0syhg = 1'b0;
e603_gnrl_dffrs #(1) b49e565bp0wlp016dt (urc40td1nn0syhg, zifh2a9n4kmw90, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire kh0x2e9c7gl9j1d = gqvqu1eburyx0 & ngwewd3qoq98;
  wire nbl_85d8jrr2y1 = (gqvqu1eburyx0 & ngwewd3qoq98) | zifh2a9n4kmw90;
  wire [32-1:0] mpuwvq33_n;
  wire [32-1:0] wjzqs3er3zzt;
  wire [32-1:0] w97ywtl3jxa8d7;
  assign wjzqs3er3zzt[23:16] = zifh2a9n4kmw90 ? (czz3lmsnukdwivlhf4 ? 8'h48 : 8'h03)
                             : rs8qfdkpko8pq[23:16];
  assign wjzqs3er3zzt[31:24] = rs8qfdkpko8pq[31:24];
e603_gnrl_dfflr #(8) uxt66q9je7i3mdldkfs (kh0x2e9c7gl9j1d, wjzqs3er3zzt[31:24], w97ywtl3jxa8d7[31:24], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(6) inh6w_chk3ildf3x (nbl_85d8jrr2y1, wjzqs3er3zzt[23:18], w97ywtl3jxa8d7[23:18], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs#(2)  bwnlxj3d1vytuho_l (nbl_85d8jrr2y1, wjzqs3er3zzt[17:16], w97ywtl3jxa8d7[17:16], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign w97ywtl3jxa8d7[15] = 1'b0; 
  assign wjzqs3er3zzt[15] = 1'b0; 
  assign wjzqs3er3zzt[14] = rs8qfdkpko8pq[14];
  assign wjzqs3er3zzt[13:12] = (rs8qfdkpko8pq[13:12] == 2'b11) ? w97ywtl3jxa8d7[13:12] : rs8qfdkpko8pq[13:12];
  assign wjzqs3er3zzt[11:10] = (rs8qfdkpko8pq[11:10] == 2'b11) ? w97ywtl3jxa8d7[11:10] : rs8qfdkpko8pq[11:10];
  assign wjzqs3er3zzt[9:8]   = (rs8qfdkpko8pq[9:8]   == 2'b11) ? w97ywtl3jxa8d7[9:8]   : rs8qfdkpko8pq[9:8]  ;
  assign wjzqs3er3zzt[7:0]   = zifh2a9n4kmw90 ? (tx071b2z1oij56 ? {rs8qfdkpko8pq[7:4],3'h4,rs8qfdkpko8pq[0]}
                                                            : {rs8qfdkpko8pq[7:4],3'h3,rs8qfdkpko8pq[0]}
                                             )  
                             : rs8qfdkpko8pq[7:0];
e603_gnrl_dfflr #(11) mrpg2q5blypj4m1d45 (kh0x2e9c7gl9j1d, wjzqs3er3zzt[14:4], w97ywtl3jxa8d7[14:4], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) d52oavpgbbvlg6ua (nbl_85d8jrr2y1, wjzqs3er3zzt[3], w97ywtl3jxa8d7[3], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs#(2)  y46j__tl1fvj_87s02s (nbl_85d8jrr2y1, wjzqs3er3zzt[2:1] , w97ywtl3jxa8d7[2:1] , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs#(1)  dkc6ahy3ntetzk937xdnw (kh0x2e9c7gl9j1d, wjzqs3er3zzt[0] , w97ywtl3jxa8d7[0] , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign mpuwvq33_n = w97ywtl3jxa8d7; 
  assign e9_y_d7sb2b0zb5e = w97ywtl3jxa8d7[3:1];
  assign zq24232ios6r6zp_5z = w97ywtl3jxa8d7[23:16];
  assign kq4x1wc10nitj = {1'b0,1'b0,w97ywtl3jxa8d7[7:4]};
  wire etbh3t57g6u162d = peo331psk3qxo & ngwewd3qoq98;
  wire [32-1:0] z526and9xxtq;
  wire [32-1:0] vdwfvv5c88okh764;
  wire [32-1:0] m31dqxx6_mv;
  assign vdwfvv5c88okh764 = rs8qfdkpko8pq;
e603_gnrl_dfflr #(30) soisnu3agnsc0dtl8bvjx8j (etbh3t57g6u162d, vdwfvv5c88okh764[31:2], m31dqxx6_mv[31:2], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs#(1) hgee9msip3ndog2rveha(etbh3t57g6u162d, vdwfvv5c88okh764[1] , m31dqxx6_mv[1] , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(1) zovnf1wvsgajcr0g2 (etbh3t57g6u162d, vdwfvv5c88okh764[0] , m31dqxx6_mv[0] , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign z526and9xxtq = m31dqxx6_mv; 
  assign alyk6czk2i8x49b4o8qt = m31dqxx6_mv[7:0];
  wire kpn_yg_jaia8ik8psl = epepn2mq9892r3p & ngwewd3qoq98;
  wire [32-1:0] kgp5blooskml6;
  wire [32-1:0] nx8trncbxcmnjsqs;
  wire [32-1:0] gy5_oufo39di;
  assign gy5_oufo39di[32-1:12] = {32-12{1'b0}}; 
  assign nx8trncbxcmnjsqs[32-1:12] = {32-12{1'b0}}; 
  assign nx8trncbxcmnjsqs[11:0] = 
                               rs8qfdkpko8pq[11:0]
                               ;
  wire onxh11t4cdz9pchdb =  
                      kpn_yg_jaia8ik8psl
                      ; 
e603_gnrl_dfflr  #(9) z20addxodsm9ltbgw  (onxh11t4cdz9pchdb, nx8trncbxcmnjsqs[11:3], gy5_oufo39di[11:3], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs  #(1) uj4nkiluquun5__cml  (onxh11t4cdz9pchdb, nx8trncbxcmnjsqs[2], gy5_oufo39di[2], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(2)  wm3nc9v7vu9i3jgxa36eh (onxh11t4cdz9pchdb, nx8trncbxcmnjsqs[1:0] , gy5_oufo39di[1:0] , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign kgp5blooskml6 = gy5_oufo39di; 
  wire [32-1:0] kotpmur20yj = {32{1'b0}} ;
  wire [3:0] gc_4r7kp5ay;
  wire [3:0] mh9gcqb9defvciwsq0 = 
                           rs8qfdkpko8pq[3:0]
                           ;
  wire nfpm5qrwm2qbhwntm_ = mtq827237iwl6m3nog & ngwewd3qoq98;
  wire at8sdjatuu_q0qa2 =  
                      nfpm5qrwm2qbhwntm_
                     ;
e603_gnrl_dfflrs #(4) sflhd4uw7er3iu1_n3h (at8sdjatuu_q0qa2, mh9gcqb9defvciwsq0, gc_4r7kp5ay, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [1:0] feezr3ilynyw_;
  wire [1:0] qb4qrc1w0pfijnk_4 = 
                            rs8qfdkpko8pq[1:0]
                            ;
  wire g8j80_cad8jz6q66blm = acd10fl3i4hy0_ & ngwewd3qoq98;
  wire fknaf4ltv5so0t = g8j80_cad8jz6q66blm
                        ;
e603_gnrl_dfflr #(2) vk2q35gouxdxc5atgs (fknaf4ltv5so0t, qb4qrc1w0pfijnk_4, feezr3ilynyw_, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [uwrgm1oivt1de06hok:0] mofrlxl7m7urtxqr;
  wire [uwrgm1oivt1de06hok:0] xq9b42z9zvnsvbaueu = rs8qfdkpko8pq[uwrgm1oivt1de06hok:0];
  wire duarqge0f5e4e2x = a6yhznotyrv9079 & ngwewd3qoq98;
e603_gnrl_dfflr #(uwrgm1oivt1de06hok+1) p46332x_6tr5_ikok (duarqge0f5e4e2x, xq9b42z9zvnsvbaueu, mofrlxl7m7urtxqr, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [uwrgm1oivt1de06hok:0] e6vwmn86c8xet;
  wire [uwrgm1oivt1de06hok:0] xwxz_nznyxl94zn8 = rs8qfdkpko8pq[uwrgm1oivt1de06hok:0];
  wire vabmw735jqke9dvqcu = co99pyyr16nf8_k6pme & ngwewd3qoq98;
e603_gnrl_dfflr #(uwrgm1oivt1de06hok+1) pubg23g629ijtdcgpvr6l (vabmw735jqke9dvqcu, xwxz_nznyxl94zn8, e6vwmn86c8xet, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [12:0] zeduiili;
  wire [12:0] x5srxysxge1kr = rs8qfdkpko8pq[12:0];
  wire c1vptbt0n3ebql9 = r11a7tc59btbe3 & ngwewd3qoq98;
e603_gnrl_dfflr #(13) bgwnhi7w9e9sqi (c1vptbt0n3ebql9, x5srxysxge1kr, zeduiili, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire zbsctoufec ;
  wire tti5_1lfgdqgg ;
  wire [32-1:0] djkt53av;
  wire [32-1:0] ci8cqow0863foo;
  wire [32-1:0] ayozbds9d7v2;
  assign ayozbds9d7v2[32-1:3] = {32-3{1'b0}};
  assign ci8cqow0863foo[32-1:3] = {32-3{1'b0}};
  assign ci8cqow0863foo[2:0] =
                           rs8qfdkpko8pq[2:0]
                           ;
  wire nni23aobanchjo = u5znxk77_g1_z & ngwewd3qoq98;
  wire wv9nrh6sq4t95p = 
                     nni23aobanchjo
                    ;
e603_gnrl_dfflr  #(2)  j1h1xt7sslwawkx6i7zs  (wv9nrh6sq4t95p, ci8cqow0863foo[2:1], ayozbds9d7v2[2:1], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) uyxntnnuizzn0np3xr (wv9nrh6sq4t95p, ci8cqow0863foo[0]  , ayozbds9d7v2[0]  , ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign djkt53av = ayozbds9d7v2; 
  wire w7emkdff095zjadmn ;
  wire [1-1:0] qep0jq76;
  wire [1-1:0] l8eh87f44nszse;
  wire [1-1:0] qw4_vjfxjzwhy1;
  wire [1-1:0] msp69r0yqmgtv_;
 wire vpba27za75ukaza = (bc15m7x5hle8wug30q5d7q | w2fmoslm8laspgvfaed4k1);
 wire l7y3g7yhwpceeg5rslp  = (feezr3ilynyw_ == 2'b11);
 wire y7k_oedq1s8983d6cg3xq = (feezr3ilynyw_ == 2'b00);
 wire zg7rrx2i7beooz = (ayozbds9d7v2[2:0] == 3'h1);
 wire l1ze8_qxjyvnw = (ayozbds9d7v2[2:0] == 3'h2);
 wire jplx9kbbwmxeb = (ayozbds9d7v2[2:0] == 3'h3);
 wire nliipzu0uv09_ = (ayozbds9d7v2[2:0] == 3'h4);
 assign qw4_vjfxjzwhy1 = {1{vpba27za75ukaza}};
 wire [3:0] uyw_zeds4iqsswdu5t;
 assign uyw_zeds4iqsswdu5t[0] = (zg7rrx2i7beooz & f86884rwtdpj4yjo9ubx);
 assign uyw_zeds4iqsswdu5t[1] = (l1ze8_qxjyvnw & f86884rwtdpj4yjo9ubx);
 assign uyw_zeds4iqsswdu5t[2] = (jplx9kbbwmxeb & f86884rwtdpj4yjo9ubx);
 assign uyw_zeds4iqsswdu5t[3] = (nliipzu0uv09_ & f86884rwtdpj4yjo9ubx);
 assign w7emkdff095zjadmn = vpba27za75ukaza;
 assign l3bywjb87dberrlhon = vpba27za75ukaza ? {1{1'b1}} : {1{1'b0}};
    assign msp69r0yqmgtv_[0] = uyw_zeds4iqsswdu5t[0]   ? (l7y3g7yhwpceeg5rslp ? gc_4r7kp5ay[0] : ~gc_4r7kp5ay[0]) : 
                           w7emkdff095zjadmn    ? gc_4r7kp5ay[0] : 
                           qep0jq76[0];
e603_gnrl_dfflrs #(1) h33eauflfrq9xu0k6l (qw4_vjfxjzwhy1, msp69r0yqmgtv_, qep0jq76, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign ws03glm08u787psex3fe = w7emkdff095zjadmn;
  assign jyf0lghvzzuj2r = ayozbds9d7v2[2:0];
  wire [1-1:0] gkgvqvfrk = qw4_vjfxjzwhy1[1-1:0] & ~msp69r0yqmgtv_[1-1:0];
  assign cfn05giriyb8lt3_nh = | gkgvqvfrk;
  assign wcja3zdd0t7j = 8'h1;
  assign wxyxjhortejmt3 = 8'h1;
  assign rlj4cog5b111mwd = 8'h3;
  wire[7:0] a_bgxqheqciovw = 8'h1;
  wire fe42y4i10dewgs = e5rf0cne7hld_23o & ngwewd3qoq98;
  wire xq7qf61273u5y;
  wire rr33mlsfy76373t8 = rs8qfdkpko8pq[3];
e603_gnrl_dfflr #(1) e7jenyhsj (fe42y4i10dewgs, rr33mlsfy76373t8, xq7qf61273u5y, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] qwt1j4hjghsmr = 6'd24;
  wire sl4ttjb9n    = xq7qf61273u5y; 
  wire yjft76clnp2 = 1'b0;
  wire [32-1:0] imbil89a = {28'h0,xq7qf61273u5y,3'b0};
  wire ynbslsmnmrehvg0nose = (pgx8we2z8eo85u2zq & ngwewd3qoq98);
  wire [32-1:0] rn1wjuyhggw7zs5di;
  wire [32-1:0] f3w8nma6ylg1;
  wire [31:0] mayljr44hqkdgz8k9;
  wire pvwox3mme99p9z5sn;
  wire fgxd4644gxcmuttkef21c = 
                           (~ncpbeb24mmnc60 & (
                            (ogg3u1an6aww4bf03m ) | ((~ox3ajqsqp) & p7cldie50p2tmud)
                            ))
                           ;
  wire k5ickrmbar6_1ye9ozzzcwk = 
                              pvwox3mme99p9z5sn & fgxd4644gxcmuttkef21c;
  wire t0keqyysv;
  assign rn1wjuyhggw7zs5di = mayljr44hqkdgz8k9;
e603_gnrl_dfflr #(32) ixt5fjigyr0okem3ovv9 (k5ickrmbar6_1ye9ozzzcwk, rn1wjuyhggw7zs5di, f3w8nma6ylg1, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign o8sv0e253jptbb2s5 = f3w8nma6ylg1; 
  wire jy7s673fglq2u5 = k5ickrmbar6_1ye9ozzzcwk ;
  wire yujscvbq4tk79u = t0keqyysv & ((n316zisfnflxfgps 
                                  ) 
                                  );
  wire mycmowvm46blrhf = jy7s673fglq2u5 | yujscvbq4tk79u;
  wire f8_n22932wmw7 = jy7s673fglq2u5 & (~yujscvbq4tk79u);
e603_gnrl_dfflr #(1) h4grp85znzmd5gvc (mycmowvm46blrhf, f8_n22932wmw7, t0keqyysv, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign ncpbeb24mmnc60 = t0keqyysv
                        ;
  wire m3fnojf8;
  wire owk52e9vhva0t5e =                      pvwox3mme99p9z5sn & ogg3u1an6aww4bf03m  & (~ox3ajqsqp ) 
                    ;
  wire aihepbv5jhuay3 = m3fnojf8 & ((p7cldie50p2tmud 
                                  ) 
                                 );
  wire dhc21evq84sx2 = owk52e9vhva0t5e | aihepbv5jhuay3;
  wire rrxivtwrk0qjosw8 = owk52e9vhva0t5e & (~aihepbv5jhuay3);
e603_gnrl_dfflr #(1) iftoicgsrexio4 (dhc21evq84sx2, rrxivtwrk0qjosw8, m3fnojf8, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign cl_8d3kdihjb9yq = m3fnojf8;
  wire atk5__oo8ry9agn55;
  wire qyi3776887dt1t5lz9qikwb = p7cldie50p2tmud; 
  wire fixmlbbr00mmtj5k1ffvc8s = atk5__oo8ry9agn55;
  wire ix32yvy58qjp2q55g_puwhw = qyi3776887dt1t5lz9qikwb |   fixmlbbr00mmtj5k1ffvc8s;
  wire ri0i9pv4zai44n6obve4 = qyi3776887dt1t5lz9qikwb & (~fixmlbbr00mmtj5k1ffvc8s);
e603_gnrl_dfflr #(1) bbd9inqbyijmo146ah8ufn86 (ix32yvy58qjp2q55g_puwhw, ri0i9pv4zai44n6obve4, atk5__oo8ry9agn55, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire hw2_09ycnst3ssuom = yyu5li2ei7vimca5im & ngwewd3qoq98;
  wire [32-1:0] s_8xu2_w6;
  wire [32-1:0] ruo4nrkybw67lyk2og;
  wire [32-1:0] rgb_qzyt7kwj;
  assign rgb_qzyt7kwj[32-1:1] = {32-1{1'b0}};
  assign ruo4nrkybw67lyk2og[32-1:1] = {32-1{1'b0}};
  assign ruo4nrkybw67lyk2og[0] = rs8qfdkpko8pq[0];
e603_gnrl_dfflrs #(1) c3shm3ufut8ou0qs1xlr(hw2_09ycnst3ssuom, ruo4nrkybw67lyk2og[0], rgb_qzyt7kwj[0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign s_8xu2_w6 = rgb_qzyt7kwj; 
  assign b47qcro0nyi = rgb_qzyt7kwj[0];
  wire [32-1:0] wm09ws0imtmzax_;
  wire [32-1:0] a6sqww5ddu2ippd;
  assign a6sqww5ddu2ippd[32-1:1] = {32-1{1'b0}};
  wire xsp82r3t5we3mic_t;
  wire l0mhmvps9ahqx707_xk;
  wire jiid1w5cr1slni5_ikvqq;
  wire vxo9du3kta26kavbuy3;
  wire qw7478p_rf;
  wire iubdhaguqysp7;
  wire cn9pinb7654u8wxqj;
  wire fzj4a4cx4rzlew;
  wire lqnef62s4hwx;
  wire mf_zs3249h_a4x = 1'b0;
  wire e9jkv1cxs4qd59af = 1'b0;
  wire na5y9d7jv2h;
  wire gahrcz9vaqa6qouy = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[13] ? 1'b0 : na5y9d7jv2h) 
                  : (
                    lqnef62s4hwx
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire xs4o29u5e0iti = mbmqixpfu6j3yoj | lqnef62s4hwx ;
e603_gnrl_dfflr #(1) goa4ktz7y42bht92qd (xs4o29u5e0iti, gahrcz9vaqa6qouy, na5y9d7jv2h, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire n9pppoyv5k5_f9t9;
  wire znce576bxuk43mrhe = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[17] ? 1'b0 : n9pppoyv5k5_f9t9) 
                  : (
                    mf_zs3249h_a4x
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire cxsswxq959aa1p77b = mbmqixpfu6j3yoj | mf_zs3249h_a4x ;
e603_gnrl_dfflr #(1) eoavobqwwr8ww_gw1 (cxsswxq959aa1p77b, znce576bxuk43mrhe, n9pppoyv5k5_f9t9, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire z3ul22jtdz00ut1k7d;
  wire unn1u50brmolz4g = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[18] ? 1'b0 : z3ul22jtdz00ut1k7d) 
                  : (
                    e9jkv1cxs4qd59af
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire o7j8ctdfsiwj5wha = mbmqixpfu6j3yoj | e9jkv1cxs4qd59af ;
e603_gnrl_dfflr #(1) k7ijswfu91vhowdyee1t9 (o7j8ctdfsiwj5wha, unn1u50brmolz4g, z3ul22jtdz00ut1k7d, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire qb16r5rqj221;
  wire nfs3gw983k2ou3lzw = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[2] ? 1'b0 : qb16r5rqj221) 
                  : (
                      cn9pinb7654u8wxqj 
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire p11uo34tf5bz0u = mbmqixpfu6j3yoj
                     | cn9pinb7654u8wxqj
                     ;
e603_gnrl_dfflr #(1) m2yzqef1976ypq0_n5zp (p11uo34tf5bz0u, nfs3gw983k2ou3lzw, qb16r5rqj221, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire s00qfpzglap1i;
  wire oe5pk8ehsypb7 = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[10] ? 1'b0 : s00qfpzglap1i) 
                  : (
                    iubdhaguqysp7
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire jf7prpwpaazy3 = mbmqixpfu6j3yoj | iubdhaguqysp7 ;
e603_gnrl_dfflr #(1) qwltw741eze1dz_m3rfs (jf7prpwpaazy3, oe5pk8ehsypb7, s00qfpzglap1i, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire b5kvjbvx20ih;
  wire pwgn5esxevr02b1tk0 = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[9] ? 1'b0 : b5kvjbvx20ih) 
                  : (
                    qw7478p_rf
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire q6i08fscm9ap30 = mbmqixpfu6j3yoj | qw7478p_rf ;
e603_gnrl_dfflr #(1) wpg3oonmp64c9t3 (q6i08fscm9ap30, pwgn5esxevr02b1tk0, b5kvjbvx20ih, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire k6ip5n_ug6gf;
  wire ytl9e5648sn_rs95q = mbmqixpfu6j3yoj ? (rs8qfdkpko8pq[3] ? 1'b0 : k6ip5n_ug6gf) 
                  : (
                     1'b0 
                    )  ? 1'b1
                  : 1'b0
                  ;
  wire au9ddsas5wgi8_ = mbmqixpfu6j3yoj 
                     ;
e603_gnrl_dfflr #(1) y2xqm899418rwf55ih0 (au9ddsas5wgi8_, ytl9e5648sn_rs95q, k6ip5n_ug6gf, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire b23weoeqvbcpi = ((m3fnojf8 | t0keqyysv | pvwox3mme99p9z5sn) 
                 ) 
                ;
  assign lqnef62s4hwx = (~pvwox3mme99p9z5sn) & (p7cldie50p2tmud | n316zisfnflxfgps); 
  wire [1:0] h8umhwypy1r ;
  wire [31:0] b7u0bi5hb1z_vqjux = (rs8qfdkpko8pq << qwt1j4hjghsmr );
  wire g9_4lin46u2wy99gpe = ynbslsmnmrehvg0nose ; 
  wire [uwrgm1oivt1de06hok:0] rennjjy_nc;
  wire [uwrgm1oivt1de06hok:0] je8cka;
  wire gaq8kka6y = (mofrlxl7m7urtxqr > rennjjy_nc) ;
  wire uml7j8 = (e6vwmn86c8xet < je8cka) ;
  assign h8umhwypy1r = {uml7j8,gaq8kka6y};
  assign x7kd6gw9z3nq = gaq8kka6y & zeduiili[0];
  assign h5fyr6xf = uml7j8 & zeduiili[1];
  assign n28ajivzes3 = k6ip5n_ug6gf & zeduiili[2];
  assign s6akl1c_8vxk = qb16r5rqj221 & zeduiili[3];
  assign e36er1uj5tr0 = b5kvjbvx20ih & zeduiili[4];
  assign s5xq485joofuo = s00qfpzglap1i & zeduiili[5];
  assign r50r4f8sqsa68b = n9pppoyv5k5_f9t9 & zeduiili[11];
  assign hby204glk3hbw = z3ul22jtdz00ut1k7d & zeduiili[12];
  assign nwk_ulhgdn = na5y9d7jv2h & zeduiili[7];
  wire [31:0] qtc2ecqw8avvpn3vyd0w =                                 hrrr6xbwwneddk;
  wire fi9mj723yx7orlqv1 =                           atk5__oo8ry9agn55 ;
  wire n60xjqp99fixz2hsxng = qloxrv_hblxc99;
  wire [31:0] mhhnyw4dlr5951adq1;
  wire exacfh;
  wire yup5261m740 = 
                1'b0
                ;
  wire [31:0] zptbumcdjxm;
  wire x16h6ro6uw6m28b;
  wire b_3r1wceva9dnvgcelb =                         fgxd4644gxcmuttkef21c
                         ;
  wire [uwrgm1oivt1de06hok:0] ek75hkocd0n ;
  wire sst4jkigjufnpppy016 =                         g9_4lin46u2wy99gpe 
                         ;
  wire [31:0] s4l4bqtrr8c=                         (
                           {32{g9_4lin46u2wy99gpe}} & b7u0bi5hb1z_vqjux
                         )
                         ;
  wire qe6820s7_06iexqii ;
  assign pvwox3mme99p9z5sn =                             x16h6ro6uw6m28b
                             ;
  assign mayljr44hqkdgz8k9 =                             zptbumcdjxm;
  assign rennjjy_nc = ek75hkocd0n;
  wire [31:0] o1a2rfpyxis;
  wire a38bdhto5nau6l_dz7;
  wire rgiz9sdg5d49hp_ =                         n60xjqp99fixz2hsxng
                         ;
  wire [uwrgm1oivt1de06hok:0] wl0o9oj2zq;
  wire ga6dx697qza1xfad =                         fi9mj723yx7orlqv1;
  wire [31:0] cpoxqahi7 =                         qtc2ecqw8avvpn3vyd0w
                         ;
  wire lyrng9kkt0anbth8k3mb;
  assign mhhnyw4dlr5951adq1 = o1a2rfpyxis;
  assign je8cka = wl0o9oj2zq;
 zdd42ray6lu4u4hhyocrugb
#(
    .ra2aj3fukykd9j   (32),
    .fmv57175hz8809 (8),
    .xi5np3lftgtezged(uwrgm1oivt1de06hok)
)
 dym61hqug_7zg6dfakdbb5jg6z
(
    .lczv3cn     (ri2ziyy),
    .r38027_km3    (r46kf),
    .jm5sdmj     (exacfh),
    .lyg_g62ta     (yup5261m740),
    .ho56_v0li6     (zbsctoufec), 
    .aqikf5g    (zptbumcdjxm),
    .al_bfsrdm   (x16h6ro6uw6m28b),
    .cadqltzy   (b_3r1wceva9dnvgcelb),
    .jov1vyjapbtr(ek75hkocd0n),
    .pxdlrpyubv4n   (sst4jkigjufnpppy016),
    .ygli0hkz    (s4l4bqtrr8c),
    .euwxj8gh   (qe6820s7_06iexqii)
);
 zdd42ray6lu4u4hhyocrugb
#(
    .ra2aj3fukykd9j   (32),
    .fmv57175hz8809 (8),
    .xi5np3lftgtezged(uwrgm1oivt1de06hok)
)
 ro_2mmzlemg3ktni24fpw5xvj
(
    .lczv3cn     (ri2ziyy),
    .r38027_km3    (r46kf),
    .jm5sdmj     (),
    .lyg_g62ta     (1'b0),
    .ho56_v0li6     (tti5_1lfgdqgg), 
    .aqikf5g    (o1a2rfpyxis),
    .al_bfsrdm   (a38bdhto5nau6l_dz7),
    .cadqltzy   (rgiz9sdg5d49hp_),
    .jov1vyjapbtr(wl0o9oj2zq),
    .pxdlrpyubv4n   (ga6dx697qza1xfad),
    .ygli0hkz    (cpoxqahi7),
    .euwxj8gh   (lyrng9kkt0anbth8k3mb)
);
  assign xsp82r3t5we3mic_t = ~qe6820s7_06iexqii;
  assign l0mhmvps9ahqx707_xk = ~x16h6ro6uw6m28b;
  assign vxo9du3kta26kavbuy3 = ~lyrng9kkt0anbth8k3mb;
  assign jiid1w5cr1slni5_ikvqq = ~a38bdhto5nau6l_dz7;
  assign qw7478p_rf = jiid1w5cr1slni5_ikvqq & qloxrv_hblxc99;
  assign iubdhaguqysp7 = xsp82r3t5we3mic_t & ynbslsmnmrehvg0nose; 
  assign cn9pinb7654u8wxqj = (~lyrng9kkt0anbth8k3mb) & ga6dx697qza1xfad;
  assign wm09ws0imtmzax_ = {a6sqww5ddu2ippd[32-1:19]
                      , z3ul22jtdz00ut1k7d
                      , n9pppoyv5k5_f9t9
                      ,3'b0
                      , na5y9d7jv2h
                      , vxo9du3kta26kavbuy3
                      , l0mhmvps9ahqx707_xk
                      , s00qfpzglap1i
                      , b5kvjbvx20ih
                      ,3'b0
                      , jiid1w5cr1slni5_ikvqq 
                      , xsp82r3t5we3mic_t 
                      , k6ip5n_ug6gf 
                      , qb16r5rqj221 
                      , 1'b0 
                      , b23weoeqvbcpi
                      }; 
  assign zbsctoufec   = 
                     1'b0
                    ;
  assign tti5_1lfgdqgg   = 
                     1'b0
                     ;
   wire k9yojkkogtjsxw  = fknaf4ltv5so0t & (qb4qrc1w0pfijnk_4 != feezr3ilynyw_);
   wire e316xxglmnibqx1    = wv9nrh6sq4t95p & (ci8cqow0863foo != ayozbds9d7v2);
   wire xoqno0i3pgtg   = at8sdjatuu_q0qa2 & (mh9gcqb9defvciwsq0 != gc_4r7kp5ay);
   wire kunfd4wlftlgm = k9yojkkogtjsxw 
                 | e316xxglmnibqx1
                 | xoqno0i3pgtg 
                 ;
   wire jxtrp3knsg1l3;
   wire gbg5c5sdmqe99r = kunfd4wlftlgm; 
   wire on317ip1wrjktpvm = bc15m7x5hle8wug30q5d7q;
   wire f_xgrj5an9z1lcnh = gbg5c5sdmqe99r | on317ip1wrjktpvm;
   wire jphhtdx77k3d8n3m = (~on317ip1wrjktpvm);
e603_gnrl_dfflr #(1) cjwd0hux__761d (f_xgrj5an9z1lcnh, jphhtdx77k3d8n3m, jxtrp3knsg1l3, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
   wire [7:0] hxli5ec7iajmat7tw0w;
   wire dhmf_sxidpgdap7jhncn = ockberyjadrlpqs_37a 
                          | kmouutgd0lpig6hyyee14r 
                          | g_qf_dmlhn3danr0v5kobvo 
                          | w2fmoslm8laspgvfaed4k1
                          ;
   wire s37pm1eoafc1j_bcexdj2 = xwua0g5cuosyyl7bcq22d
                          | qr1ktq99r1r7adt9bykuwf6
                          | gw9f_lxd_td208e1e4w04m6x
                          | jbshcx_02es1e2h_z497s
                          ;
   wire ib_7od4i9qlkr6s53 = dhmf_sxidpgdap7jhncn | s37pm1eoafc1j_bcexdj2;
   wire [7:0] gb5q2c3_jm5_b_0p_lno6 = 
                                    s37pm1eoafc1j_bcexdj2 ? 8'b0
                                  : dhmf_sxidpgdap7jhncn ? (hxli5ec7iajmat7tw0w + 8'b1)
                                  : hxli5ec7iajmat7tw0w
                                  ;
e603_gnrl_dfflr #(8) lqvqq4a7ws3n6e990cua1ba1 (ib_7od4i9qlkr6s53, gb5q2c3_jm5_b_0p_lno6, hxli5ec7iajmat7tw0w, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
    assign f86884rwtdpj4yjo9ubx = bc15m7x5hle8wug30q5d7q & pvwox3mme99p9z5sn;
    assign ifm4f61h58jxyo = a60aiqgftapr3ju;
    assign xwua0g5cuosyyl7bcq22d = (hxli5ec7iajmat7tw0w == wxyxjhortejmt3 ) & ockberyjadrlpqs_37a;
    assign vre5wjf3393nlq9x4n = ndbg5krrqovrvfsy3sip ;
    assign v0j5p8vof4vfl6halta1d3 =                               n316zisfnflxfgps & ogg3u1an6aww4bf03m
                              ;
    assign gbhe559k80avm3 = bqbrwf_ud5q1h54sqk;
    assign qr1ktq99r1r7adt9bykuwf6 = (hxli5ec7iajmat7tw0w == wcja3zdd0t7j ) & kmouutgd0lpig6hyyee14r; 
    assign uzw1nk84ivcdjr802gaj = fwi10o6jkxn5uz47;
    wire cn7l2sqt9fy = jxtrp3knsg1l3 | (s_8xu2_w6[0] == 1'b1) | y7k_oedq1s8983d6cg3xq;
    assign g4hvb6t2tcpvpmy5ztu06wf = (pvwox3mme99p9z5sn | cn7l2sqt9fy) &  d83it4age7ju2ig84fmx;
    assign on4t7sdr24yw85y = (~pvwox3mme99p9z5sn | cn7l2sqt9fy) ? rzo5c5uj93mxj6qgh6 : fwi10o6jkxn5uz47 ;
    assign gw9f_lxd_td208e1e4w04m6x = ((hxli5ec7iajmat7tw0w == a_bgxqheqciovw) | cn7l2sqt9fy ) & g_qf_dmlhn3danr0v5kobvo;
    assign bv7_kf4mufxex6re = (~pvwox3mme99p9z5sn | cn7l2sqt9fy) ? rcw8ushc9tij1lwcoxhy : fwi10o6jkxn5uz47; 
    assign jbshcx_02es1e2h_z497s = (hxli5ec7iajmat7tw0w == rlj4cog5b111mwd ) & w2fmoslm8laspgvfaed4k1; 
    assign zvhzy3kk4eudv3ur2w = fusofx_uxiq0ovvs0pw;
    assign q4n0kbcn24onq =    f86884rwtdpj4yjo9ubx
                            | xwua0g5cuosyyl7bcq22d
                            | v0j5p8vof4vfl6halta1d3
                            | qr1ktq99r1r7adt9bykuwf6
                            | g4hvb6t2tcpvpmy5ztu06wf
                            | gw9f_lxd_td208e1e4w04m6x
                            | jbshcx_02es1e2h_z497s
                            ;
    assign uloh18s35kco3lh3 =    ({rjz3ekdeoph_ikp{f86884rwtdpj4yjo9ubx  }} ) & ifm4f61h58jxyo    
                            | ({rjz3ekdeoph_ikp{xwua0g5cuosyyl7bcq22d }} ) & vre5wjf3393nlq9x4n   
                            | ({rjz3ekdeoph_ikp{v0j5p8vof4vfl6halta1d3    }} ) & gbhe559k80avm3      
                            | ({rjz3ekdeoph_ikp{qr1ktq99r1r7adt9bykuwf6 }} ) & uzw1nk84ivcdjr802gaj   
                            | ({rjz3ekdeoph_ikp{g4hvb6t2tcpvpmy5ztu06wf }} ) & on4t7sdr24yw85y    
                            | ({rjz3ekdeoph_ikp{gw9f_lxd_td208e1e4w04m6x}} ) & bv7_kf4mufxex6re   
                            | ({rjz3ekdeoph_ikp{jbshcx_02es1e2h_z497s }} ) & zvhzy3kk4eudv3ur2w   
                            ;
e603_gnrl_dfflr #(rjz3ekdeoph_ikp) a39xlwwmub899evw (q4n0kbcn24onq, uloh18s35kco3lh3, y6ciiggp4rpi5wb, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [32-1:0] mq9n48gbif_cl6qzi = 
                         ({32{q9nyrn1fnpojnu1nr }} & kgp5blooskml6  )
                       | ({32{nsirysuw9mbl   }} & djkt53av    )
                       | ({32{mrijmdd3zudmw    }} & imbil89a     )
                       | ({32{jnobdywjfyhd0y1r1 }} & wm09ws0imtmzax_  )
                       | ({32{pa3roly_trneoe626fa }} & 32'h0)
                       | ({32{s3f_6_qkb0pnss59q   }} & mpuwvq33_n    )
                       | ({32{xwng2_40012hor0  }} & z526and9xxtq   )
                       | ({32{qloxrv_hblxc99 }} & mhhnyw4dlr5951adq1) 
                       | ({32{lmrge6nnogakzcj_h  }} & s_8xu2_w6   )
                       | ({32{bon6u_53hv32sbml2h9}} & { {{15-uwrgm1oivt1de06hok{1'b0}},wl0o9oj2zq} , {{15-uwrgm1oivt1de06hok{1'b0}},ek75hkocd0n} } )
                       | ({32{txy1t8oi9vk39z }} & {{31-uwrgm1oivt1de06hok{1'b0}} , mofrlxl7m7urtxqr}  )
                       | ({32{ab0lk338_y29rvfa }} & {{31-uwrgm1oivt1de06hok{1'b0}} , e6vwmn86c8xet}  )
                       | ({32{x80g5jbypwd }}     & {19'h0 , zeduiili}  )
                       | ({32{diiubqnnoktl98 }}     & {30'h0, h8umhwypy1r}  )
                       | ({32{qaoxt9ifof7fipzkqp}}  & {30'h0 , feezr3ilynyw_})
                       | ({32{z1c2sicz7azk92bnu}}   & {28'h0 , gc_4r7kp5ay})
                       | ({32{fxrkjbputadb8hotr}} & {32'hee010102})
                       ;
  wire ob8z8livyemha710u ;
  wire kskb11shhtzrtgvpid4sm;
  wire [32-1:0] t3ry9gk2ep_3qyfvsrb9u;
  wire n3w802chksaybtkdgd_xl = mxwg8lfgv4pge1 
                         ;
  wire jesyol8j2mzc9p7rg;
  assign qi_euczbjhgo1za = jesyol8j2mzc9p7rg 
                       ;
  e603_gnrl_pipe_stage # (
    .CUT_READY (0),
    .DP  (1),
    .DW  (32)
  ) wap11wkgzhcg0r14 (
    .i_vld(n3w802chksaybtkdgd_xl),
    .i_rdy(jesyol8j2mzc9p7rg),
    .i_dat(mq9n48gbif_cl6qzi ),
    .o_vld(ob8z8livyemha710u),
    .o_rdy(kskb11shhtzrtgvpid4sm),  
    .o_dat(t3ry9gk2ep_3qyfvsrb9u ),  
    .clk  (ri2ziyy),
    .rst_n(r46kf)
  );
  assign l_geblczxuwi5x4e = ob8z8livyemha710u;
  assign kskb11shhtzrtgvpid4sm = ptdklfwbs2d13;
  assign nuvz1doibyin1uaa = t3ry9gk2ep_3qyfvsrb9u;
  assign skbwq1o6wlc     = kgp5blooskml6[11:0];
  assign ct6pxuoq      = qep0jq76[1-1:0];
  assign ox3ajqsqp     = sl4ttjb9n;
endmodule
module p6devqb4ptpbm5ap_h
(
    input         ssaglb56qjhnl,
    output        dfi9g_4x75iz3b,
    input         sx6i39j26_,
    input         hja3lm6no_t0q,
    input         h1u9k_,
    input         rx9aqne,
    input         db10mb8xe,
    input         zh_xnfrx,
    input         noqeoiuvnu,
    input         h5ub76gz,
    input         gye3x8met,
    input         p6tci4w33tx,
    input  [5:0]  s_w4zt6mvts   ,
    input         nfv0zewnc,
    output        ug0f667go,
    output [31:0] o1a2rfpyxis,
    output        o79s9jhh3qahq,
    output        neq4t0yh_0bn8s74,
    input         ri2ziyy,
    input         r46kf 
);
  localparam g5y09m0u = 1'b0;
  localparam c2tk6qc7  = 1'b1;
  wire z_1m_y4u = ~ri2ziyy;
  wire ko8uiaaz;
  wire isxaba53_obach92;
  wire j1mpllt46eo1t6 = (ko8uiaaz == g5y09m0u);
  wire owp92pxsb_s  = (ko8uiaaz == c2tk6qc7 );
  wire c2x5ykpd4q2ox3rrdc = j1mpllt46eo1t6 & ssaglb56qjhnl  & dfi9g_4x75iz3b;
  wire yxdgcz0hw7jih__et = c2tk6qc7;
  wire g5z77ms25teupcm8246b = isxaba53_obach92;
  wire i0mexwntygcpv = g5y09m0u;
  wire xb5jyhu0ew9y = c2x5ykpd4q2ox3rrdc | g5z77ms25teupcm8246b;
  wire h_t98ra471lwz = (c2x5ykpd4q2ox3rrdc & yxdgcz0hw7jih__et)
                  | (g5z77ms25teupcm8246b & i0mexwntygcpv)
                  ;
e603_gnrl_dfflr #(1) tgrhp81_0cuv (xb5jyhu0ew9y, h_t98ra471lwz, ko8uiaaz, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] gd3moepdb; 
e603_gnrl_dfflr #(2) k12palz4a5ochy (c2x5ykpd4q2ox3rrdc, s_w4zt6mvts[5:4], gd3moepdb[5:4], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) r11t1le5_9tw8t2r (c2x5ykpd4q2ox3rrdc, s_w4zt6mvts[3], gd3moepdb[3], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(3) x6gqk5a2f83gm98t (c2x5ykpd4q2ox3rrdc, s_w4zt6mvts[2:0], gd3moepdb[2:0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire sqidwanu;
e603_gnrl_dfflr #(1) b7k1hysokbcjv0f (c2x5ykpd4q2ox3rrdc, nfv0zewnc, sqidwanu, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] n2985g4;
  wire pkc2tyulgjl3p = (n2985g4 == gd3moepdb);
  wire [5:0] dwltzbbgl2cy40u =  ~owp92pxsb_s ? 6'h0 
                        : (
                           (
                           sx6i39j26_)) ? ( pkc2tyulgjl3p ? 6'h0 : n2985g4 + 6'h1) 
                        : n2985g4
                        ;
  wire xoryu0vqbz8kn = (~owp92pxsb_s) | (
                                    sx6i39j26_);
e603_gnrl_dfflr #(6) qt8ldl1kdwf9 (xoryu0vqbz8kn, dwltzbbgl2cy40u, n2985g4, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [31:0] uh0t93udo6;
  wire [31:0] mz_7lp3dqk;
  wire bkvw92mogsvm07p = (
                     (sx6i39j26_ & owp92pxsb_s)
                     ) & (
                     (~sqidwanu)
                     )
                     ;
  wire [31:0] d3hz_rxufgsk9 = {uh0t93udo6[30:0], rx9aqne};
e603_gnrl_dfflr #(32) oj0y00951lovolfkn (bkvw92mogsvm07p, d3hz_rxufgsk9, uh0t93udo6, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [31:0] uqbqxbl0g1_ = uh0t93udo6[31:0];
  assign isxaba53_obach92 = (
                       pkc2tyulgjl3p  & hja3lm6no_t0q) 
                     ;
  assign ug0f667go  = 
                    isxaba53_obach92
                    ;
  assign neq4t0yh_0bn8s74 = pkc2tyulgjl3p;
  assign dfi9g_4x75iz3b = 
                    j1mpllt46eo1t6
                    ;
  assign o1a2rfpyxis  = 
                    uqbqxbl0g1_ ;
  assign o79s9jhh3qahq  = owp92pxsb_s;
endmodule
module o2625zzxlldir4mw_qmkmea (
    input                         m06qnpn5a9z03 ,
    input [11:0]                  mvqrtq7dyd0jl4,
    input [1-1:0]   wgc1pcq7e4,
    input                         qtsnhkdndbh,
    input                         d9n3ph7pubth72d7c,
    output                        br7a8dw5rndor ,
    output                        b3nk3ml5dggetwx1,
    output                        fekszkc1bqs8x6b ,
    input          ri2ziyy,
    input          r46kf   
);
  wire qep0jq76 = |(~wgc1pcq7e4);
  wire jeofasr36jmwmq;
  wire xc7_xs2vqt4n;
  wire [11:0] wo49jzbbu6fbz;
  wire hhgym7xmgcc = m06qnpn5a9z03;
  wire zceqt5b33i6v5 = (wo49jzbbu6fbz == mvqrtq7dyd0jl4) & m06qnpn5a9z03;
  wire bx1xzn4pq8z9xkym1 = (wo49jzbbu6fbz == (mvqrtq7dyd0jl4 >> 1)) & m06qnpn5a9z03;
  wire [11:0] f40rnvxkoxtnx6 = zceqt5b33i6v5 ? 12'd0 : m06qnpn5a9z03 ? wo49jzbbu6fbz + 12'b1 : 12'd0;
e603_gnrl_dfflr #(12) o7meg9r4kkuqm7r (hhgym7xmgcc, f40rnvxkoxtnx6, wo49jzbbu6fbz, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] sy5ie2qsz3;
  wire by__ur08rbz;
  wire n29o3het1l1nplu24 = qep0jq76 ? ( zceqt5b33i6v5 ? ~by__ur08rbz : by__ur08rbz) : 1'b0 ;
  wire e8203izp0du = 
                    n29o3het1l1nplu24
                    ;
  wire d8mr2tqvctz1xawkasq = qep0jq76 ? (m06qnpn5a9z03 & zceqt5b33i6v5 ) : 1'b1;
  wire t7f5bmyuhos = 
                  d8mr2tqvctz1xawkasq
                  ;
e603_gnrl_dfflr #(1) z6q5exenw6jshhx_j (t7f5bmyuhos, e8203izp0du, by__ur08rbz, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign jeofasr36jmwmq = (1'b0 ^ by__ur08rbz) & zceqt5b33i6v5 ;
  assign xc7_xs2vqt4n = (~(1'b0 ^ by__ur08rbz)) & zceqt5b33i6v5;
  wire lsn15dh7f2_tahg = (xc7_xs2vqt4n
                      )
                      ;
  wire o4okrtw26smjv = 1'b1;
  wire bw6sqxtffq9yh = lsn15dh7f2_tahg | o4okrtw26smjv;
  wire [5:0] y8y5fphthrkirw = o4okrtw26smjv ? 6'h0 : sy5ie2qsz3 + 6'b1;
e603_gnrl_dfflr #(6) dhqonaqzvhwhgx7ei7 (bw6sqxtffq9yh, y8y5fphthrkirw, sy5ie2qsz3, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign br7a8dw5rndor = by__ur08rbz;
  assign b3nk3ml5dggetwx1 = xc7_xs2vqt4n;
  assign fekszkc1bqs8x6b = jeofasr36jmwmq;
endmodule
module vna3s3dz39qbawowo3
(
    input         hja3lm6no_t0q,
    input         zouj6_xexoto9ok,
    output        o525acty1z2m,
    input  [31:0] s4l4bqtrr8c,
    input  [5:0]  oo4ed1ww3q9,
    output        xvgqjver,
    output        ajbsjn0thsh,
    output        bkivycod,
    output        fgavjah3,
    output        d9njukh0,
    output        ljres1z5,
    output        re3z_qh,
    output        e7kvhs6agh,
    output        n0vgfy8z9a_og,
    output        mntm2jd6ths4ryk,
    output        rektx_amz8m3x,
    output        br8ywe_g54b133huyhgdt,
    input         ri2ziyy,
    input         r46kf   
);
  localparam g5y09m0u = 1'b0;
  localparam kr99uv4u  = 1'b1;
  wire ko8uiaaz;
  wire llhht8w4fsz;
  wire j1mpllt46eo1t6 = (ko8uiaaz == g5y09m0u);
  wire sruvucbntt_edt  = (ko8uiaaz == kr99uv4u );
  wire c2x5ykpd4q2ox3rrdc = j1mpllt46eo1t6 & zouj6_xexoto9ok;
  wire yxdgcz0hw7jih__et = kr99uv4u;
  wire sqq7wlyvd77skxbcs7ckh = llhht8w4fsz & sruvucbntt_edt ;
  wire smquryym7rbwnl = g5y09m0u;
  wire kd3gqdsqhum = c2x5ykpd4q2ox3rrdc | sqq7wlyvd77skxbcs7ckh;
  wire qge4_sqe5g = (c2x5ykpd4q2ox3rrdc & yxdgcz0hw7jih__et)
                  | (sqq7wlyvd77skxbcs7ckh & smquryym7rbwnl)
                  ;
e603_gnrl_dfflr #(1) zf7swuzqwpa4c79c (kd3gqdsqhum, qge4_sqe5g, ko8uiaaz, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] et7_7clnm7; 
e603_gnrl_dfflr #(2) sz4g943w_29kjh663 (c2x5ykpd4q2ox3rrdc, oo4ed1ww3q9[5:4], et7_7clnm7[5:4], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) m4f2nfd_j1ud447v90 (c2x5ykpd4q2ox3rrdc, oo4ed1ww3q9[3], et7_7clnm7[3], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(3) l1w5bsti3u823zp7t9 (c2x5ykpd4q2ox3rrdc, oo4ed1ww3q9[2:0], et7_7clnm7[2:0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] t80bll18qyk;
  wire [5:0] rut73mh0ti = et7_7clnm7-6'h1;
  wire [4:0] arjht_l00ihq = et7_7clnm7[5:1]-5'h1;
  wire [3:0] jv7ehczmud = et7_7clnm7[5:2]-4'h1;
  wire [2:0] uflhqosoi0 = et7_7clnm7[5:3]-3'h1;
  wire a_rfl0onn0e = (t80bll18qyk == (et7_7clnm7-6'h1));
  wire jizetiaec8 = sruvucbntt_edt;
  wire [5:0] y2tbyvy_9g37 = (
                          (
                          hja3lm6no_t0q)
                        ) ? a_rfl0onn0e ? 6'h0 : t80bll18qyk + 6'h1 : t80bll18qyk;
e603_gnrl_dfflr #(6) aiqgef5hjfv2ml (jizetiaec8, y2tbyvy_9g37, t80bll18qyk, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [31:0] gghz_6zv;
  wire jkepa4vzenr96 = c2x5ykpd4q2ox3rrdc | ((
                                         (
                                         hja3lm6no_t0q)) & ~a_rfl0onn0e & sruvucbntt_edt);
  wire [31:0] a49cvoc_79kj = c2x5ykpd4q2ox3rrdc ? s4l4bqtrr8c[31:0] : {gghz_6zv[30:0], 1'b0};
e603_gnrl_dfflr #(32) t1508tv9soxu_ (jkepa4vzenr96, a49cvoc_79kj, gghz_6zv, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign llhht8w4fsz = a_rfl0onn0e & (
                               (
                               hja3lm6no_t0q));
  assign n0vgfy8z9a_og  = llhht8w4fsz;
  assign o525acty1z2m = j1mpllt46eo1t6;
  assign mntm2jd6ths4ryk  = sruvucbntt_edt;
  assign rektx_amz8m3x = a_rfl0onn0e;
  assign e7kvhs6agh = 1'b1;
  assign re3z_qh = 1'b1;
  assign ljres1z5 = 1'b1;
  assign d9njukh0 = 1'b1;
  assign fgavjah3 = 1'b1;
  assign bkivycod = 1'b1;
  assign ajbsjn0thsh = 1'b0;
  assign xvgqjver = gghz_6zv[31];
  assign br8ywe_g54b133huyhgdt = sqq7wlyvd77skxbcs7ckh;
endmodule
module p0qdzag8lrr7d53n89u3cl5p
(
    input         hja3lm6no_t0q,
    input         zouj6_xexoto9ok,
    output        o525acty1z2m,
    input  [31:0] s4l4bqtrr8c,
    input  [5:0]  oo4ed1ww3q9,
    output        xvgqjver,
    output        ajbsjn0thsh,
    output        bkivycod,
    output        fgavjah3,
    output        d9njukh0,
    output        ljres1z5,
    output        re3z_qh,
    output        e7kvhs6agh,
    output        n0vgfy8z9a_og,
    output        mntm2jd6ths4ryk,
    output        rektx_amz8m3x,
    output        br8ywe_g54b133huyhgdt,
    input         ri2ziyy,
    input         r46kf   
);
  localparam g5y09m0u = 1'b0;
  localparam kr99uv4u  = 1'b1;
  wire ko8uiaaz;
  wire llhht8w4fsz;
  wire j1mpllt46eo1t6 = (ko8uiaaz == g5y09m0u);
  wire sruvucbntt_edt  = (ko8uiaaz == kr99uv4u );
  wire c2x5ykpd4q2ox3rrdc = j1mpllt46eo1t6 & zouj6_xexoto9ok;
  wire yxdgcz0hw7jih__et = kr99uv4u;
  wire sqq7wlyvd77skxbcs7ckh = llhht8w4fsz & sruvucbntt_edt ;
  wire smquryym7rbwnl = g5y09m0u;
  wire kd3gqdsqhum = c2x5ykpd4q2ox3rrdc | sqq7wlyvd77skxbcs7ckh;
  wire qge4_sqe5g = (c2x5ykpd4q2ox3rrdc & yxdgcz0hw7jih__et)
                  | (sqq7wlyvd77skxbcs7ckh & smquryym7rbwnl)
                  ;
e603_gnrl_dfflr #(1) zf7swuzqwpa4c79c (kd3gqdsqhum, qge4_sqe5g, ko8uiaaz, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] et7_7clnm7; 
e603_gnrl_dfflr #(2) sz4g943w_29kjh663 (c2x5ykpd4q2ox3rrdc, oo4ed1ww3q9[5:4], et7_7clnm7[5:4], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflrs #(1) m4f2nfd_j1ud447v90 (c2x5ykpd4q2ox3rrdc, oo4ed1ww3q9[3], et7_7clnm7[3], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(3) l1w5bsti3u823zp7t9 (c2x5ykpd4q2ox3rrdc, oo4ed1ww3q9[2:0], et7_7clnm7[2:0], ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [5:0] t80bll18qyk;
  wire [5:0] rut73mh0ti = et7_7clnm7-6'h1;
  wire [4:0] arjht_l00ihq = et7_7clnm7[5:1]-5'h1;
  wire [3:0] jv7ehczmud = et7_7clnm7[5:2]-4'h1;
  wire [2:0] uflhqosoi0 = et7_7clnm7[5:3]-3'h1;
  wire a_rfl0onn0e = (t80bll18qyk == (et7_7clnm7-6'h1));
  wire jizetiaec8 = sruvucbntt_edt;
  wire [5:0] y2tbyvy_9g37 = (
                          (
                          hja3lm6no_t0q)
                        ) ? a_rfl0onn0e ? 6'h0 : t80bll18qyk + 6'h1 : t80bll18qyk;
e603_gnrl_dfflr #(6) aiqgef5hjfv2ml (jizetiaec8, y2tbyvy_9g37, t80bll18qyk, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  wire [31:0] gghz_6zv;
  wire jkepa4vzenr96 = c2x5ykpd4q2ox3rrdc | ((
                                         (
                                         hja3lm6no_t0q)) & ~a_rfl0onn0e & sruvucbntt_edt);
  wire [31:0] a49cvoc_79kj = c2x5ykpd4q2ox3rrdc ? s4l4bqtrr8c[31:0] : {gghz_6zv[30:0], 1'b0};
e603_gnrl_dfflr #(32) t1508tv9soxu_ (jkepa4vzenr96, a49cvoc_79kj, gghz_6zv, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
  assign llhht8w4fsz = a_rfl0onn0e & (
                               (
                               hja3lm6no_t0q));
  assign n0vgfy8z9a_og  = llhht8w4fsz;
  assign o525acty1z2m = j1mpllt46eo1t6;
  assign mntm2jd6ths4ryk  = sruvucbntt_edt;
  assign rektx_amz8m3x = a_rfl0onn0e;
  assign e7kvhs6agh = 1'b0;
  assign re3z_qh = 1'b0;
  assign ljres1z5 = 1'b0;
  assign d9njukh0 = 1'b0;
  assign fgavjah3 = 1'b0;
  assign bkivycod = 1'b0;
  assign ajbsjn0thsh = 1'b0;
  assign xvgqjver = gghz_6zv[31];
  assign br8ywe_g54b133huyhgdt = sqq7wlyvd77skxbcs7ckh;
endmodule
