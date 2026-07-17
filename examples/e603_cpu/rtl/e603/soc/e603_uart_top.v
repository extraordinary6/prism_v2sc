 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module e603_uart_top(
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
  output  io_interrupts_0_0,                
  output  io_port_txd,
  input   io_port_rxd
);
`ifndef FPGA_SOURCE
`ifndef EMULATOR
   `define UART_USE_SIM_MODEL
`endif
`endif
`ifdef UART_USE_SIM_MODEL
    assign i_icb_cmd_ready = 1'b1;
    assign i_icb_rsp_valid = i_icb_cmd_valid;
    assign i_icb_rsp_rdata = 32'b0;
    assign io_interrupts_0_0 = 1'b0;
    assign io_port_txd = 1'b0;
    wire write_en = i_icb_cmd_valid & i_icb_cmd_ready & ~i_icb_cmd_read;
    wire write_tx_en = write_en && (i_icb_cmd_addr[11:0]  == 12'b0);
    wire[7:0] aqikf5g = i_icb_cmd_wdata[7:0];
    always@(posedge clk) begin
        if (write_tx_en) begin
            if (aqikf5g != 8'h0d && aqikf5g != 8'h00 && aqikf5g != 8'h04) begin
                $fwrite(32'h80000001,"%c", aqikf5g); 
            end
        end
    end
`else
 tvrvwt9da9u62y2_d  p76p6rd43zha_1rh5_r
 (
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
   .uwe2r1dssimbrh1z2wb        (io_port_rxd)             ,
   .zlictx_xuaeg          ()             ,
   .dq1rx39ishcm9o3        (io_port_txd)             ,
   .bgu0ydisudcy          ()             ,
   .ri2ziyy                   (clk)             ,
   .r46kf                 (rst_n)             ,
   .e6s4deuofl15pxu5      (io_interrupts_0_0)             
);
`endif
endmodule
module  tvrvwt9da9u62y2_d 
 (
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
  input              uwe2r1dssimbrh1z2wb                ,
  output             zlictx_xuaeg                  ,
  output             dq1rx39ishcm9o3                ,
  output             bgu0ydisudcy                  ,
  input              ri2ziyy                           ,
  input              r46kf                         ,
  output             e6s4deuofl15pxu5              
);
assign nhup3xqrnngwbqsg_e = 1'b0;
wire   pwu8db84yy;
wire   k9oytbmyowl4;
assign pwu8db84yy        = uwe2r1dssimbrh1z2wb;
assign zlictx_xuaeg     = 1'b0;
assign dq1rx39ishcm9o3   = k9oytbmyowl4;
assign bgu0ydisudcy     = 1'b1;
wire        almqjz9j2n80p;
wire [15:0] wu7ue1av6qpm10g;
wire [3:0]  gbg490stgq6rkw;
wire [8:0]  hjxsnzvv_i7jffuit7;
wire        ng_bmu2kpuoem1wzgn3o2_;
wire        b3cclc1d_pvb;
wire [3:0]  lek36b7g86;
wire        i987q_vdp1fyi61v;
wire        isvffnc_f5j0199i;
wire        miwi80b4ublfzjtp_;
wire        upxpjkqnqg0m5_l;
wire        aqhqw1aehd77gnhyvqf;
wire        popvbu7xbcb5_kic;
wire        tgkukl0a8x114u8;
wire [8:0]  ly618fcx37w;
wire [8:0]  lw8ywt68hkd;
wire        q85dmrg58io;
wire        yqcsss1n3wxr60zt;
wire        q1rbyv8l8h96nnku7;
wire        bxtuyyty5g3g0f;
wire [8:0]  evs8w60syazz;
wire        mz7b9nw8fmgdbv30ad;
wire        sqxwn3sej76lnke;
wire        ukfdf2xncqpecr;
wire        r2eh4_fl_e62zr1z;
wire        ydhk9z3b0nq8mhcn62;
wire        iq83cu3j21bx63a1grb4qve;
wire        j_yyga52swzyhx7pswmdc;
wire        pho4mwx721swopcr1z6p7tx;
wire        hnr6p618vvd51sws6gd;
wire        o7h_f8j0z45pz9q030q840;
wire        ejm_t4j5ynjvw98zisq; 
assign pho4mwx721swopcr1z6p7tx  = ydhk9z3b0nq8mhcn62       & aqhqw1aehd77gnhyvqf;
assign hnr6p618vvd51sws6gd  = r2eh4_fl_e62zr1z       & popvbu7xbcb5_kic;
assign e6s4deuofl15pxu5   = pho4mwx721swopcr1z6p7tx | hnr6p618vvd51sws6gd; 
ckuci_kp508c26xi ob3sbfaq5bqxt5_dka(
   .ri2ziyy                 (ri2ziyy),
   .r46kf               (r46kf),
   .mxwg8lfgv4pge1       (mxwg8lfgv4pge1),
   .t3lk20ui52aqc6        (t3lk20ui52aqc6[11:0]),
   .cuu3goyrnwc9hf        (cuu3goyrnwc9hf),
   .rs8qfdkpko8pq       (rs8qfdkpko8pq),
   .qi_euczbjhgo1za       (qi_euczbjhgo1za),
   .ptdklfwbs2d13       (ptdklfwbs2d13),
   .l_geblczxuwi5x4e       (l_geblczxuwi5x4e),
   .nuvz1doibyin1uaa       (nuvz1doibyin1uaa),
   .r1ukfidrb_5kvibw         (r1ukfidrb_5kvibw),
   .sqxwn3sej76lnke        (sqxwn3sej76lnke),
   .yqcsss1n3wxr60zt       (yqcsss1n3wxr60zt),
   .aqhqw1aehd77gnhyvqf    (aqhqw1aehd77gnhyvqf),
   .popvbu7xbcb5_kic    (popvbu7xbcb5_kic),
   .k901765kzi4h         (lw8ywt68hkd),
   .q85dmrg58io          (q85dmrg58io),
   .ng_bmu2kpuoem1wzgn3o2_   (ng_bmu2kpuoem1wzgn3o2_),
   .hjxsnzvv_i7jffuit7    (hjxsnzvv_i7jffuit7),
   .b3cclc1d_pvb           (b3cclc1d_pvb),
   .lek36b7g86          (lek36b7g86),
   .almqjz9j2n80p           (almqjz9j2n80p),
   .gbg490stgq6rkw          (gbg490stgq6rkw),
   .r2eh4_fl_e62zr1z       (r2eh4_fl_e62zr1z),
   .ydhk9z3b0nq8mhcn62       (ydhk9z3b0nq8mhcn62),
   .wu7ue1av6qpm10g        (wu7ue1av6qpm10g)
);
d0bk6go_83mrrfvdw a_ehhig4yxta6c27h(
      .ri2ziyy             (ri2ziyy),
      .r46kf           (r46kf),
      .lm7z39v            (pwu8db84yy),
      .hxqzu4xws6          (),
      .rjt0ux8mrd        (almqjz9j2n80p),
      .s2rufeqvxafo       (wu7ue1av6qpm10g),
      .aobfwp364t3__m    (isvffnc_f5j0199i),
      .ai88e56_u13pnrs  (upxpjkqnqg0m5_l),
      .l3fjqqkqtkj4xv0v0    ( ),
      .lw8ywt68hkd       (ly618fcx37w),
      .zgfubjrnvl8dfd      (tgkukl0a8x114u8),
      .zkpu5gcjssjij2p      (~q1rbyv8l8h96nnku7)
);
aszqvvvgstkfwvcs7ttusx c6i6llzl_9_7nz4c1yv_b(
   .ri2ziyy              (ri2ziyy),
   .r46kf            (r46kf),
   .yhbv3et05qi8e7        (1'b0),
   .pxdlrpyubv4n          (tgkukl0a8x114u8),
   .ygli0hkz           (ly618fcx37w),
   .c85n             (q1rbyv8l8h96nnku7),
   .v1yo02r            (yqcsss1n3wxr60zt),
   .al_bfsrdm          ( ),
   .aqikf5g           (lw8ywt68hkd),
   .gbg490stgq6rkw       (gbg490stgq6rkw),
   .ys4ua9ifsvx_t    (q85dmrg58io),
   .aqhqw1aehd77gnhyvqf (aqhqw1aehd77gnhyvqf)
);
o1ucmiw_2begy9u2jr z82b9rzpp419r92prkmpv(
   .ri2ziyy               (ri2ziyy),
   .r46kf             (r46kf),
   .pxdlrpyubv4n           (ng_bmu2kpuoem1wzgn3o2_),
   .ygli0hkz            (hjxsnzvv_i7jffuit7),
   .lek36b7g86        (lek36b7g86),
   .mz7b9nw8fmgdbv30ad     (mz7b9nw8fmgdbv30ad),
   .c85n              (sqxwn3sej76lnke),
   .v1yo02r             (ukfdf2xncqpecr),
   .al_bfsrdm           (bxtuyyty5g3g0f),
   .aqikf5g            (evs8w60syazz),
   .popvbu7xbcb5_kic  (popvbu7xbcb5_kic)
);
n9hz4uolh6cl4h uuxwm6sdqkgy3brgao(
   .lczv3cn             (ri2ziyy),
   .r38027_km3            (r46kf),
   .rjt0ux8mrd          (b3cclc1d_pvb),
   .s2rufeqvxafo         (wu7ue1av6qpm10g),
   .f8pm5_tdgp5         (evs8w60syazz),
   .iwaoyygo616xxoo        (bxtuyyty5g3g0f),
   .ukfdf2xncqpecr     (ukfdf2xncqpecr),
   .n6oqzkx9              (k9oytbmyowl4),
   .hxqzu4xws6            (),
   .q_yk0xx4_hid0x        (mz7b9nw8fmgdbv30ad)
);
endmodule 
module ckuci_kp508c26xi(
input          ri2ziyy,
input          r46kf,
input          mxwg8lfgv4pge1,
input  [11:0]  t3lk20ui52aqc6,
input          cuu3goyrnwc9hf,
input  [31:0]  rs8qfdkpko8pq,
output         qi_euczbjhgo1za,
input          ptdklfwbs2d13,
output         l_geblczxuwi5x4e,
output  [31:0] nuvz1doibyin1uaa,
output         r1ukfidrb_5kvibw,
input          sqxwn3sej76lnke,
input          yqcsss1n3wxr60zt,
input          aqhqw1aehd77gnhyvqf,
input          popvbu7xbcb5_kic,
input  [8:0]   k901765kzi4h,
output         q85dmrg58io,
output         ng_bmu2kpuoem1wzgn3o2_,  
output [8:0]   hjxsnzvv_i7jffuit7,   
output         b3cclc1d_pvb,          
output [3:0]   lek36b7g86,         
output         almqjz9j2n80p,          
output [3:0]   gbg490stgq6rkw,         
output         r2eh4_fl_e62zr1z,      
output         ydhk9z3b0nq8mhcn62,      
output [15:0]  wu7ue1av6qpm10g        
); 
localparam obcjm9j6wtx2kpx2 = 12'h00;
localparam ir77_jujg5woh2o1pgo = 12'h04;
localparam op_ckhl16o0hg2y3c8f7t = 12'h08;
localparam bhbjec5iyyi_jg3ckqm5 = 12'h0c;
localparam ulzyzbwserykh6     = 12'h10;
localparam lcfoa1a_7zp7e     = 12'h14;
localparam pdgfedejllx1xh    = 12'h18;
localparam pu5jo9f6vlab14hcs4  = 12'h20;
wire nbj8groass8140sae12 = (t3lk20ui52aqc6[11:0] == obcjm9j6wtx2kpx2);
wire pmp2j9h021a4p48wzl50jkhk = (t3lk20ui52aqc6[11:0] == ir77_jujg5woh2o1pgo);
wire haityqvubkualhkp0zoaziy = (t3lk20ui52aqc6[11:0] == op_ckhl16o0hg2y3c8f7t);
wire bjlm2lomj9bq45pokl_1 = (t3lk20ui52aqc6[11:0] == bhbjec5iyyi_jg3ckqm5);
wire hfe9i_t3enw1otrl4     = (t3lk20ui52aqc6[11:0] == ulzyzbwserykh6)    ;
wire plbej4rej0dv73u     = (t3lk20ui52aqc6[11:0] == lcfoa1a_7zp7e)    ;
wire lkiejp9lnl_xer48hjig    = (t3lk20ui52aqc6[11:0] == pdgfedejllx1xh)   ;
wire [31:0] r1kj3bs19cs;
wire h9v5e_bsrlv6bm    = mxwg8lfgv4pge1 & qi_euczbjhgo1za  ;
wire mdsb_grohsjsamcosr = h9v5e_bsrlv6bm & (~cuu3goyrnwc9hf);
wire wck3318sgmg36n4jx3yr = h9v5e_bsrlv6bm & cuu3goyrnwc9hf   ;
assign l_geblczxuwi5x4e  = mxwg8lfgv4pge1;
assign qi_euczbjhgo1za  = ptdklfwbs2d13;
assign nuvz1doibyin1uaa  = r1kj3bs19cs;
assign r1ukfidrb_5kvibw    = 1'b0;
wire [8:0] zf7c74otodak7evq5u;
wire       awn81qniw1o02krv;
wire [8:0] vx0er1lsib3aa42   = rs8qfdkpko8pq[8:0];
wire       jlpc2zj9l9fsiq0090z = mdsb_grohsjsamcosr & nbj8groass8140sae12;
wire       rw87006tinfygzcnm0h6w  = jlpc2zj9l9fsiq0090z;
e603_gnrl_dfflr #(9) r1968k5viojawx1ry_jc (jlpc2zj9l9fsiq0090z, vx0er1lsib3aa42, zf7c74otodak7evq5u, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dffr  #(1) nwvpaq3orq7at9yn7 (rw87006tinfygzcnm0h6w, awn81qniw1o02krv, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
wire       o9nx7uy_k2egx12q;
wire [3:0] z30s5zgiws6u1pa0trx9f;
wire [2:0] pbnyffb1v16zrbi17dv       = rs8qfdkpko8pq[2:0];
wire [3:0] s644xv_on3n0p6yo846wc = rs8qfdkpko8pq[19:16];
wire       vkogcs9vq_t002vrky     = mdsb_grohsjsamcosr & haityqvubkualhkp0zoaziy;
e603_gnrl_dfflr #(1) b9_gj0i__8cvemr2w (vkogcs9vq_t002vrky, pbnyffb1v16zrbi17dv[0], o9nx7uy_k2egx12q, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(4) c3wfoeift92wfbgjy0ko2xjk6xm (vkogcs9vq_t002vrky, s644xv_on3n0p6yo846wc, z30s5zgiws6u1pa0trx9f, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
wire       nwfnto5maik3;
wire [3:0] toqpk6fit9_oga10123sd;
wire       u_bswabt9ccfk1z55y        = rs8qfdkpko8pq[0];
wire [3:0] rcg_gdqkys47eo2jrdfyiqol = rs8qfdkpko8pq[19:16];
wire       va5kq6bftugc_e8bnkr     = mdsb_grohsjsamcosr & bjlm2lomj9bq45pokl_1;
e603_gnrl_dfflr #(1) wfjmek80q22g9g0ydujw (va5kq6bftugc_e8bnkr, u_bswabt9ccfk1z55y, nwfnto5maik3, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
e603_gnrl_dfflr #(4) uhfcaug0lxb6cfc01dsz6t0i9rl (va5kq6bftugc_e8bnkr, rcg_gdqkys47eo2jrdfyiqol, toqpk6fit9_oga10123sd, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
wire [1:0] xw8j589l1lex4;
wire [1:0] nsy0fbc0sp9w0l   = rs8qfdkpko8pq[1:0];
wire       cgprvwj6_v2pc8nn9m = mdsb_grohsjsamcosr & hfe9i_t3enw1otrl4; 
e603_gnrl_dfflr #(2) wzx02zd4l397oq (cgprvwj6_v2pc8nn9m, nsy0fbc0sp9w0l, xw8j589l1lex4, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
wire [15:0] xeq26kbdqq13;
wire [15:0] k4mkm46fie_0ignp   = rs8qfdkpko8pq[15:0];
wire        r34q7fdmn3xs9t4am = mdsb_grohsjsamcosr & lkiejp9lnl_xer48hjig;
e603_gnrl_dfflrs #(16,16'h021e) cygs7ou8qbg8ybgtno(r34q7fdmn3xs9t4am, k4mkm46fie_0ignp, xeq26kbdqq13, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
assign q85dmrg58io          = wck3318sgmg36n4jx3yr & pmp2j9h021a4p48wzl50jkhk ;
assign hjxsnzvv_i7jffuit7    = zf7c74otodak7evq5u;
assign ng_bmu2kpuoem1wzgn3o2_   = awn81qniw1o02krv;
assign b3cclc1d_pvb           = o9nx7uy_k2egx12q;    
assign lek36b7g86          = z30s5zgiws6u1pa0trx9f;
assign almqjz9j2n80p           = nwfnto5maik3;
assign gbg490stgq6rkw          = toqpk6fit9_oga10123sd;
assign r2eh4_fl_e62zr1z       = xw8j589l1lex4[0];
assign ydhk9z3b0nq8mhcn62       = xw8j589l1lex4[1];
assign wu7ue1av6qpm10g        = xeq26kbdqq13;
assign r1kj3bs19cs[31:0] = ({32{nbj8groass8140sae12}} & {sqxwn3sej76lnke,22'h0,zf7c74otodak7evq5u                                                 }) 
                       | ({32{pmp2j9h021a4p48wzl50jkhk}} & {yqcsss1n3wxr60zt,22'h0,k901765kzi4h                                                  })
                       | ({32{haityqvubkualhkp0zoaziy}} & {12'h0,z30s5zgiws6u1pa0trx9f,15'h0,o9nx7uy_k2egx12q                                    })
                       | ({32{bjlm2lomj9bq45pokl_1}} & {12'h0,toqpk6fit9_oga10123sd,15'h0,nwfnto5maik3                                     })
                       | ({32{hfe9i_t3enw1otrl4    }} & {30'h0,xw8j589l1lex4                                                                  })
                       | ({32{plbej4rej0dv73u    }} & {30'h0,aqhqw1aehd77gnhyvqf,popvbu7xbcb5_kic                                          })
                       | ({32{lkiejp9lnl_xer48hjig   }} & {16'h0,xeq26kbdqq13                                                                 })
                       ;
endmodule
module aszqvvvgstkfwvcs7ttusx #(
    parameter ra2aj3fukykd9j    = 9,
    parameter fmv57175hz8809  = 8,
    parameter s98tpn17rr94n0_fnf = 4
) (
    input                    ri2ziyy,
    input                    r46kf,
    input                    yhbv3et05qi8e7,
    input                    pxdlrpyubv4n,
    input   [ra2aj3fukykd9j-1:0] ygli0hkz,
    input   [3:0]            gbg490stgq6rkw,  
    input                    ys4ua9ifsvx_t, 
    output                   c85n, 
    output                   v1yo02r,    
    output                   al_bfsrdm,
    output  [ra2aj3fukykd9j-1:0] aqikf5g,
    output                   aqhqw1aehd77gnhyvqf
    );
wire                     zgasz6;
wire                     qecflw9;
wire [ra2aj3fukykd9j-1:0]    jqyt_;
wire [fmv57175hz8809-1:0]  i7f8c3jp;
wire [s98tpn17rr94n0_fnf-1:0] oca_86z1qgvhggybhdud;
e603_gnrl_fifo_wflg #(
   .CUT_READY (1),
   .MSKO      (0),
   .REG_OUT   (0),
   .DP        (fmv57175hz8809),
   .DW        (ra2aj3fukykd9j),
   .DP_PTR_W  (s98tpn17rr94n0_fnf)
) tdrc0uwx769q (
  .clk             (ri2ziyy),
  .rst_n           (r46kf),
  .cleanfifo       (yhbv3et05qi8e7),
  .i_vld           (pxdlrpyubv4n),
  .i_rdy           (zgasz6),
  .i_dat           (ygli0hkz),
  .o_vld           (qecflw9),
  .o_rdy           (ys4ua9ifsvx_t),
  .o_dat           (jqyt_),
  .intl_vec        (i7f8c3jp),
  .intl_vec_encode (oca_86z1qgvhggybhdud)
);
assign c85n             = ~zgasz6;
assign v1yo02r            = ~qecflw9;
assign al_bfsrdm          = qecflw9;
assign aqikf5g           = jqyt_;
assign aqhqw1aehd77gnhyvqf = (oca_86z1qgvhggybhdud > gbg490stgq6rkw);  
endmodule
module d0bk6go_83mrrfvdw (
  input                ri2ziyy,
  input                r46kf,
  input                lm7z39v,
  input      [15:0]    s2rufeqvxafo,
  input                rjt0ux8mrd,
  output               hxqzu4xws6,
  output reg           aobfwp364t3__m,
  output reg           ai88e56_u13pnrs,
  output reg           l3fjqqkqtkj4xv0v0,
  output     [8:0]     lw8ywt68hkd,
  output reg           zgfubjrnvl8dfd,
  input                zkpu5gcjssjij2p
		);
    localparam dy9vxr0      = 3'b000;
    localparam mv65zqzka1o28 = 3'b001;
    localparam o0zah      = 3'b010;
    localparam qapoavhl    = 3'b011;
    localparam pljo08d3q2mqg  = 3'b100;
	reg [2:0] q6_;
	reg [2:0] ycic9;
	reg [8:0] l9dcst2expp60;
	reg [8:0] wpmrp8jvs1db7ln8wl;
    reg [2:0] su0w__0vaxmd1avc;
	reg [3:0] rqorjgzx1uxcweo;
	reg [3:0] ra5q8jlnotvez_ke25x;
	wire [3:0] e49aygp8wi4m_zpt;
	reg       yv86k6jpzo2oq7;
	reg       ipfzw0w14rulrst;
	reg       bres9qgbu3c1k7wd;
	reg         i5jh579p6bxi;
	reg  [15:0] knesjj9dj;
	reg         upsaj7z6b21j1oj;
    reg         pmqdwpr3uopz6r;
    reg         odmbxao2_li1jdinfg;
    reg         ibhcfhbuhw3sri4fc3c;
    reg         o0kcs6erd223lnxj;
    wire        tm3mv_yxb2mscfkir = (q6_ == pljo08d3q2mqg) & (~su0w__0vaxmd1avc[1] & su0w__0vaxmd1avc[2]);
    wire        ybqrn1ho1c;
    wire [14:0] d1sqnnwox9x7a9wor;
    wire [14:0] nrwx636dwsudu;
    wire [15:0] ahe4xdcy9j46vjm;
    wire        dd80yhlus0td1r5iy7y;
    wire        lzy6gzdk16yqnwt6zj8;
    wire        iqabnvjgtt5eq4x71;
    wire        pavkz75232vev0_;
    wire        ntrtoq57iaejp38;
    wire        llhvjwp2hasju9qlh;
    wire        ustzbd_2leerv9c;
    reg         ss8nmg_ecjtkhzwd;
    reg         jfnlknk4nej2wf5s;
    reg         s4b9hl183z6idbs;
    reg         jemz6zqgk7tzspag26jkbho;
    wire        k762edyl1g5kb3t16mbk2ni9z = ^l9dcst2expp60 ^ 1'b1;
    wire        j7_cbzgf83aty88 = ~k762edyl1g5kb3t16mbk2ni9z;
    assign hxqzu4xws6 = (q6_ != dy9vxr0);
    assign e49aygp8wi4m_zpt = 4'h7;
	always @*
	begin
		ycic9 = q6_;
		bres9qgbu3c1k7wd = 1'b0;
		ra5q8jlnotvez_ke25x  = rqorjgzx1uxcweo;
		wpmrp8jvs1db7ln8wl = l9dcst2expp60;
		zgfubjrnvl8dfd = 1'b0;
		upsaj7z6b21j1oj = 1'b0;
        pmqdwpr3uopz6r  = 1'b0;
		ipfzw0w14rulrst = yv86k6jpzo2oq7;
        aobfwp364t3__m    = 1'b0;
        ai88e56_u13pnrs  = 1'b0;
        l3fjqqkqtkj4xv0v0    = 1'b0;
        odmbxao2_li1jdinfg   = 1'b0;
        o0kcs6erd223lnxj          = 1'b0;
		case(q6_)
			dy9vxr0:
            begin
				if (ybqrn1ho1c)
				begin
					ycic9 = mv65zqzka1o28;
    				upsaj7z6b21j1oj = 1'b0;
                    pmqdwpr3uopz6r  = 1'b1;
                    o0kcs6erd223lnxj = 1'b1;
				end
            end
			mv65zqzka1o28:
			begin
				ipfzw0w14rulrst = 1'b0;
				upsaj7z6b21j1oj = 1'b1;
                pmqdwpr3uopz6r  = 1'b1;
				if (i5jh579p6bxi)
					ycic9 = o0zah;
			end
			o0zah:
			begin
				upsaj7z6b21j1oj = 1'b1;
				ipfzw0w14rulrst = (yv86k6jpzo2oq7 ^ jemz6zqgk7tzspag26jkbho);
                        wpmrp8jvs1db7ln8wl = {1'b0,jemz6zqgk7tzspag26jkbho,l9dcst2expp60[7:1]};
				if (i5jh579p6bxi)
				begin
					bres9qgbu3c1k7wd = 1'b1;
					if (rqorjgzx1uxcweo == e49aygp8wi4m_zpt)
					begin
						ra5q8jlnotvez_ke25x = 4'h0;
							ycic9 = pljo08d3q2mqg;
					end
					else
					begin
						ra5q8jlnotvez_ke25x = rqorjgzx1uxcweo + 1'b1;
					end
				end
			end
			qapoavhl:
			begin
				upsaj7z6b21j1oj = 1'b1;
				if (i5jh579p6bxi)
                begin
                    if(j7_cbzgf83aty88 != jemz6zqgk7tzspag26jkbho)
                        odmbxao2_li1jdinfg = 1'b1;
				    ycic9 = pljo08d3q2mqg;
                end
			end
			pljo08d3q2mqg:
			begin
				upsaj7z6b21j1oj = 1'b1;
				if (i5jh579p6bxi | tm3mv_yxb2mscfkir)
				begin
					ycic9 = tm3mv_yxb2mscfkir ? mv65zqzka1o28 : dy9vxr0;
                    o0kcs6erd223lnxj = tm3mv_yxb2mscfkir ? 1'b1 : 1'b0;
					if(!ibhcfhbuhw3sri4fc3c)
					begin
						zgfubjrnvl8dfd = 1'b1;
						if(!zkpu5gcjssjij2p)
							ai88e56_u13pnrs = 1'b1;
						else
							l3fjqqkqtkj4xv0v0 = 1'b1;
					end
					else
						aobfwp364t3__m = 1'b1;
				end
			end
            default:
                ycic9 = dy9vxr0;
		endcase		
	end
	always @(posedge ri2ziyy or negedge r46kf)
	begin
		if (r46kf == 1'b0)
		begin
			q6_             <= dy9vxr0;
			l9dcst2expp60       <= 9'h1FF;
			rqorjgzx1uxcweo  <= 4'h0;
			yv86k6jpzo2oq7     <= 1'b0;
		end
		else
		begin
            if(i5jh579p6bxi)
                yv86k6jpzo2oq7 <= ipfzw0w14rulrst;
			if(bres9qgbu3c1k7wd)
				l9dcst2expp60 <= wpmrp8jvs1db7ln8wl;
			rqorjgzx1uxcweo  <= ra5q8jlnotvez_ke25x;
            if(rjt0ux8mrd)
	           q6_ <= ycic9;
            else
                q6_ <= dy9vxr0;
		end
	end
    assign ybqrn1ho1c = ~su0w__0vaxmd1avc[1] & su0w__0vaxmd1avc[2];
	always @(posedge ri2ziyy or negedge r46kf)
	begin
		if (r46kf == 1'b0)
            su0w__0vaxmd1avc <= 3'b111;
		else
        begin
            if (rjt0ux8mrd)
                su0w__0vaxmd1avc <= {su0w__0vaxmd1avc[1:0],lm7z39v};
            else
                su0w__0vaxmd1avc <= 3'b111;
        end
    end
always @(posedge ri2ziyy or negedge r46kf) 
   begin
        if(r46kf == 1'b0) 
           begin
              knesjj9dj <= 16'h0;
              i5jh579p6bxi <= 1'b0; 
           end
        else 
           begin
             if(upsaj7z6b21j1oj) 
               begin
                  if(tm3mv_yxb2mscfkir)
                    begin
                       knesjj9dj <= 16'h0;
                       i5jh579p6bxi <= 1'b0;  
                    end 
                  else if(knesjj9dj==s2rufeqvxafo)
                    begin   
                       knesjj9dj <= 16'h0;
                       i5jh579p6bxi <= 1'b1;  
                    end 
                  else
                    begin
                       knesjj9dj <= knesjj9dj + 1'b1; 
                       i5jh579p6bxi <= 1'b0; 
                    end
                end
            else 
                  begin
                     knesjj9dj <= 16'h0; 
                     i5jh579p6bxi <= 1'b0; 
                  end
            end
    end
    assign d1sqnnwox9x7a9wor = {1'b0,s2rufeqvxafo[15:2]};
    assign nrwx636dwsudu = s2rufeqvxafo[15:1];
    assign ahe4xdcy9j46vjm = d1sqnnwox9x7a9wor + nrwx636dwsudu + 1'b1;
    assign ntrtoq57iaejp38 = (knesjj9dj == {1'b0,d1sqnnwox9x7a9wor}) ? 1'b1 : 1'b0;
    assign llhvjwp2hasju9qlh = (knesjj9dj == {1'b0,nrwx636dwsudu}) ? 1'b1 : 1'b0;
    assign ustzbd_2leerv9c = (knesjj9dj == ahe4xdcy9j46vjm) ? 1'b1 : 1'b0;
    assign pavkz75232vev0_     = ustzbd_2leerv9c;
	always @(posedge ri2ziyy or negedge r46kf) begin 
        if (r46kf == 1'b0) 
                 ss8nmg_ecjtkhzwd <= 1'b0;
        else if (ntrtoq57iaejp38)
                 ss8nmg_ecjtkhzwd <= su0w__0vaxmd1avc[2];  end
	always @(posedge ri2ziyy or negedge r46kf) begin 
        if (r46kf == 1'b0) 
                 jfnlknk4nej2wf5s <= 1'b0;
        else if (llhvjwp2hasju9qlh)
                 jfnlknk4nej2wf5s <= su0w__0vaxmd1avc[2];  end
	always @(posedge ri2ziyy or negedge r46kf) begin 
        if (r46kf == 1'b0) 
                 s4b9hl183z6idbs <= 1'b0;
        else if (ustzbd_2leerv9c)
                 s4b9hl183z6idbs <= su0w__0vaxmd1avc[2];  end
    always @* begin
        case({s4b9hl183z6idbs,jfnlknk4nej2wf5s,ss8nmg_ecjtkhzwd})
        3'b000  : jemz6zqgk7tzspag26jkbho = 1'b0;
        3'b001  : jemz6zqgk7tzspag26jkbho = 1'b0;
        3'b010  : jemz6zqgk7tzspag26jkbho = 1'b0;
        3'b011  : jemz6zqgk7tzspag26jkbho = 1'b1;
        3'b100  : jemz6zqgk7tzspag26jkbho = 1'b0;
        3'b101  : jemz6zqgk7tzspag26jkbho = 1'b1;
        3'b110  : jemz6zqgk7tzspag26jkbho = 1'b1;
        3'b111  : jemz6zqgk7tzspag26jkbho = 1'b1;
        default : jemz6zqgk7tzspag26jkbho = 1'b0;
     endcase
end
	always @(posedge ri2ziyy or negedge r46kf)
	begin
		if (r46kf == 1'b0)
		begin
			ibhcfhbuhw3sri4fc3c   <= 1'b0;
		end
		else
		begin
			if(o0kcs6erd223lnxj)
			begin
				ibhcfhbuhw3sri4fc3c   <= 1'b0;
			end
			else
			begin
                if(odmbxao2_li1jdinfg)
    			    ibhcfhbuhw3sri4fc3c <= 1'b1;
			end
		end
	end
    assign lw8ywt68hkd = l9dcst2expp60;
endmodule
module o1ucmiw_2begy9u2jr #(
    parameter ra2aj3fukykd9j    = 9,
    parameter fmv57175hz8809  = 8,
    parameter s98tpn17rr94n0_fnf = 4
)(
input                     ri2ziyy,
input                     r46kf,
input                     pxdlrpyubv4n,
input  [ra2aj3fukykd9j-1:0]   ygli0hkz,
input  [3:0]              lek36b7g86,    
input                     mz7b9nw8fmgdbv30ad, 
output                    c85n,
output                    v1yo02r,
output                    al_bfsrdm,
output [ra2aj3fukykd9j-1:0]   aqikf5g,
output                    popvbu7xbcb5_kic
);
wire                     fq5153jr;
wire                     zgasz6;
wire                     qecflw9;
wire [ra2aj3fukykd9j-1:0]    jqyt_;
wire [fmv57175hz8809-1:0]  i7f8c3jp;
wire [s98tpn17rr94n0_fnf-1:0] oca_86z1qgvhggybhdud;
e603_gnrl_fifo_wflg #(
   .CUT_READY (1),
   .MSKO      (0),
   .REG_OUT   (0),
   .DP        (fmv57175hz8809),
   .DW        (ra2aj3fukykd9j),
   .DP_PTR_W  (s98tpn17rr94n0_fnf)
) vc21qvjkfaa (
  .clk             (ri2ziyy),
  .rst_n           (r46kf),
  .cleanfifo       (1'b0 ),
  .i_vld           (pxdlrpyubv4n),
  .i_rdy           (zgasz6),
  .i_dat           (ygli0hkz),
  .o_vld           (qecflw9),
  .o_rdy           (fq5153jr),
  .o_dat           (jqyt_),
  .intl_vec        (i7f8c3jp),
  .intl_vec_encode (oca_86z1qgvhggybhdud)
);
wire fmqc1xoe7kl05kdtf_3 = mz7b9nw8fmgdbv30ad;
wire a6nywgvlmawic8dqnjg;
e603_gnrl_dffr  #(1) mw_nsndbndrweb42ag_i(fmqc1xoe7kl05kdtf_3, a6nywgvlmawic8dqnjg, ri2ziyy, r46kf);// VPP_NO_REG_PARSE
assign fq5153jr            = ~a6nywgvlmawic8dqnjg & fmqc1xoe7kl05kdtf_3;
assign c85n             = ~zgasz6;
assign v1yo02r            = ~qecflw9;
assign al_bfsrdm          = qecflw9;
assign aqikf5g           = jqyt_;
assign popvbu7xbcb5_kic = (oca_86z1qgvhggybhdud < lek36b7g86);
`ifndef FPGA_SOURCE
`ifndef SYNTHESIS
always @(posedge ri2ziyy or negedge r46kf) begin
    if(fq5153jr & (r46kf == 1'b1))
        if (aqikf5g != 9'h0d && aqikf5g != 9'h00 && aqikf5g != 9'h04) begin 
            $fwrite(32'h80000001,"%c", aqikf5g); 
        end end
`endif
`endif
endmodule
module n9hz4uolh6cl4h (
		input              lczv3cn,
		input              r38027_km3,
		input              rjt0ux8mrd,
		input   [15:0]     s2rufeqvxafo,
		input    [8:0]     f8pm5_tdgp5,
		input              iwaoyygo616xxoo,
        input              ukfdf2xncqpecr,
		output   reg       n6oqzkx9,
        output             hxqzu4xws6,
		output   reg       q_yk0xx4_hid0x
		);
    localparam dy9vxr0               = 3'b000;
    localparam mv65zqzka1o28          = 3'b001;
    localparam o0zah               = 3'b010;
    localparam qapoavhl             = 3'b011;
    localparam m5zg1sol_01rl1qemb     = 3'b100;
    localparam vxsjty35ybv2g      = 3'b101;
    localparam dfca5dr0crxk3mno0l = 3'b110;
    localparam ov8m83ew1443go1vlr = 3'b111;
    parameter aw1vsej = 1'b1;	
   	reg [2:0] q6_;
	reg [2:0] ycic9;
	reg [8:0]  l9dcst2expp60;
	reg [8:0]  wpmrp8jvs1db7ln8wl;
	reg [3:0]  rqorjgzx1uxcweo;
	reg [3:0]  ra5q8jlnotvez_ke25x;
	wire [3:0] e49aygp8wi4m_zpt;
	reg        yv86k6jpzo2oq7;
	reg        ipfzw0w14rulrst;
	reg        fxe7kfc59qu;
	reg [15:0] knesjj9dj;
	reg        upsaj7z6b21j1oj;
	reg        i5jh579p6bxi;
    wire         rpazdqjh700vrnwxy71b_ = 1'b0;
    reg [8:0]    ivpr8oy5h1g8e;
    wire         rewxei0ns9cjgmlq0kibd = ^ivpr8oy5h1g8e ^ 1'b1; 
    assign hxqzu4xws6 = (q6_ != dy9vxr0);
    assign e49aygp8wi4m_zpt = 4'h7;
    always @*
	begin
		ycic9 = q6_;
		n6oqzkx9 = 1'b1;
		fxe7kfc59qu = 1'b0;
		ra5q8jlnotvez_ke25x  = rqorjgzx1uxcweo;
		wpmrp8jvs1db7ln8wl = {1'b1,l9dcst2expp60[8:1]};
		q_yk0xx4_hid0x = 1'b0;
		upsaj7z6b21j1oj = 1'b0;
		ipfzw0w14rulrst = yv86k6jpzo2oq7;
		case(q6_)
			dy9vxr0:
            begin
            	if (rjt0ux8mrd & ~ukfdf2xncqpecr)
            		q_yk0xx4_hid0x = 1'b1;
				if (iwaoyygo616xxoo)
				begin
					ycic9 = mv65zqzka1o28;
					fxe7kfc59qu = 1'b1;
					wpmrp8jvs1db7ln8wl = f8pm5_tdgp5;
				end
            end
			mv65zqzka1o28:
			begin
				n6oqzkx9 = (~i5jh579p6bxi && (knesjj9dj==16'h0)) ? 1'b1 : 1'b0;
				ipfzw0w14rulrst = 1'b0;
				upsaj7z6b21j1oj = 1'b1;
				if (i5jh579p6bxi)
					ycic9 = o0zah;
			end
			o0zah:
			begin
				n6oqzkx9 = l9dcst2expp60[0];
				upsaj7z6b21j1oj = 1'b1;
				ipfzw0w14rulrst = (yv86k6jpzo2oq7 ^ l9dcst2expp60[0]);
				if (i5jh579p6bxi)
				begin
					if (rqorjgzx1uxcweo == e49aygp8wi4m_zpt)
					begin
						ra5q8jlnotvez_ke25x = 4'h0;
							ycic9 = m5zg1sol_01rl1qemb;
					end
					else
					begin
						ra5q8jlnotvez_ke25x = rqorjgzx1uxcweo + 1'b1;
						fxe7kfc59qu = 1'b1;
					end
				end
			end
			qapoavhl:
			begin
				n6oqzkx9 = ~rewxei0ns9cjgmlq0kibd;
				upsaj7z6b21j1oj = 1'b1;
				if (i5jh579p6bxi)
    			    ycic9 = m5zg1sol_01rl1qemb;
			end
			m5zg1sol_01rl1qemb:
			begin
				n6oqzkx9 = 1'b1;
				upsaj7z6b21j1oj = 1'b1;
			    if (i5jh579p6bxi)
                begin
    			  ycic9 = dy9vxr0;
                end
			end
			vxsjty35ybv2g:
			begin
				n6oqzkx9 = 1'b1;
				upsaj7z6b21j1oj = 1'b1;
				if (rpazdqjh700vrnwxy71b_)
				begin
					ycic9 = dy9vxr0;
				end
			end
            default:
                ycic9 = dy9vxr0;
		endcase		
	end
	always @(posedge lczv3cn or negedge r38027_km3)
	begin
		if (r38027_km3 == 1'b0)
		begin
			q6_             <= #aw1vsej dy9vxr0;
			l9dcst2expp60       <= #aw1vsej 9'h1FF;
			rqorjgzx1uxcweo  <= #aw1vsej 4'h0;
			yv86k6jpzo2oq7     <= #aw1vsej 1'b0;
			ivpr8oy5h1g8e      <= #aw1vsej 9'b0;
		end
		else
		begin
            if (iwaoyygo616xxoo & (q6_==dy9vxr0)) begin
               ivpr8oy5h1g8e <= f8pm5_tdgp5;
            end
            if(i5jh579p6bxi)
            begin
	            yv86k6jpzo2oq7 <= #aw1vsej ipfzw0w14rulrst;
            end
	        if(fxe7kfc59qu)
			begin
				l9dcst2expp60 <= #aw1vsej wpmrp8jvs1db7ln8wl;
			end
			rqorjgzx1uxcweo  <= #aw1vsej ra5q8jlnotvez_ke25x;
            if(rjt0ux8mrd)
	           q6_ <= #aw1vsej ycic9;
            else
               q6_ <= #aw1vsej dy9vxr0;
		end
	end
	always @(posedge lczv3cn or negedge r38027_km3)
	begin
		if (r38027_km3 == 1'b0)
		begin
			knesjj9dj <= #aw1vsej 16'h0;
			i5jh579p6bxi <= #aw1vsej 1'b0;
		end
		else
		begin
			if(upsaj7z6b21j1oj)
			begin
				if(knesjj9dj == s2rufeqvxafo)
				begin
					knesjj9dj <= #aw1vsej 16'h0;
					i5jh579p6bxi <= #aw1vsej 1'b1;
				end
				else
				begin
					knesjj9dj <= #aw1vsej knesjj9dj + 1'b1;
					i5jh579p6bxi <= #aw1vsej 1'b0;
				end
			end
			else
			begin
				knesjj9dj <= #aw1vsej 16'h0;
				i5jh579p6bxi <= #aw1vsej 1'b0;
			end
		end
	end
endmodule
