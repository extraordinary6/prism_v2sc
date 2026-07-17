 /*                                                                      
  *  Copyright (c) 2018-2025 Nuclei System Technology, Inc.       
  *  All rights reserved.                                                
  */                                                                     
module nuclei_udma_top #(
  parameter AW = 32, 
  parameter DW = 64 
) (
  input              reg_icb_cmd_valid             ,
  output             reg_icb_cmd_ready             ,
  input              reg_icb_cmd_sel               ,
  input              reg_icb_cmd_read              ,
  input  [  11:   0] reg_icb_cmd_addr              ,
  input  [  31:   0] reg_icb_cmd_wdata             ,
  input  [   3:   0] reg_icb_cmd_wmask             ,
  input  [   2:   0] reg_icb_cmd_size              ,
  input              reg_icb_cmd_lock              ,
  input              reg_icb_cmd_excl              ,
  input  [   7:   0] reg_icb_cmd_xlen              ,
  input  [   1:   0] reg_icb_cmd_xburst            ,
  input  [   1:   0] reg_icb_cmd_modes             ,
  input              reg_icb_cmd_dmode             ,
  input  [   2:   0] reg_icb_cmd_attri             ,
  input  [   1:   0] reg_icb_cmd_beat              ,
  input              reg_icb_cmd_usr               ,
  input              reg_icb_rsp_ready             ,
  output             reg_icb_rsp_valid             ,
  output             reg_icb_rsp_err               ,
  output             reg_icb_rsp_excl_ok           ,
  output [  31:   0] reg_icb_rsp_rdata             ,
  output             reg_icb_rsp_usr               ,
  output             w_icb_cmd_valid               ,
  input              w_icb_cmd_ready               ,
  output             w_icb_cmd_sel                 ,
  output             w_icb_cmd_read                ,
  output [  31:   0] w_icb_cmd_addr                ,
  output [  63:   0] w_icb_cmd_wdata               ,
  output [   7:   0] w_icb_cmd_wmask               ,
  output [   2:   0] w_icb_cmd_size                ,
  output             w_icb_cmd_lock                ,
  output             w_icb_cmd_excl                ,
  output [   7:   0] w_icb_cmd_xlen                ,
  output [   1:   0] w_icb_cmd_xburst              ,
  output [   1:   0] w_icb_cmd_modes               ,
  output             w_icb_cmd_dmode               ,
  output [   2:   0] w_icb_cmd_attri               ,
  output [   1:   0] w_icb_cmd_beat                ,
  output             w_icb_cmd_usr                 ,
  output             w_icb_rsp_ready               ,
  input              w_icb_rsp_valid               ,
  input              w_icb_rsp_err                 ,
  input              w_icb_rsp_excl_ok             ,
  input  [  63:   0] w_icb_rsp_rdata               ,
  input              w_icb_rsp_usr                 ,
  output             r_icb_cmd_valid               ,
  input              r_icb_cmd_ready               ,
  output             r_icb_cmd_sel                 ,
  output             r_icb_cmd_read                ,
  output [  31:   0] r_icb_cmd_addr                ,
  output [  63:   0] r_icb_cmd_wdata               ,
  output [   7:   0] r_icb_cmd_wmask               ,
  output [   2:   0] r_icb_cmd_size                ,
  output             r_icb_cmd_lock                ,
  output             r_icb_cmd_excl                ,
  output [   7:   0] r_icb_cmd_xlen                ,
  output [   1:   0] r_icb_cmd_xburst              ,
  output [   1:   0] r_icb_cmd_modes               ,
  output             r_icb_cmd_dmode               ,
  output [   2:   0] r_icb_cmd_attri               ,
  output [   1:   0] r_icb_cmd_beat                ,
  output             r_icb_cmd_usr                 ,
  output             r_icb_rsp_ready               ,
  input              r_icb_rsp_valid               ,
  input              r_icb_rsp_err                 ,
  input              r_icb_rsp_excl_ok             ,
  input  [  63:   0] r_icb_rsp_rdata               ,
  input              r_icb_rsp_usr                 ,
  output             udma_irq                      ,
  output             udma_dbg0_o_oval              ,
  output             udma_dbg1_o_oval              ,
  input              clk                           ,
  input              rst_n                         
);
  wire    [  31:   0] sseyj1vlfxllhjbzjyvt6mh3x0t        ;
  wire    [  31:   0] vy5vt74acy5u9xh0mky84kw        ;
  wire                ix233l9nk65au4z_tftc5r        ;
  wire    [   1:   0] ks5busqx5jpm9tuemwtxkx79rllq      ;
  wire    [   1:   0] k8zcggu8t0kqqjgtjpeyfk_ogk339  ;
  wire                cf3vendhrtpe312ww2            ;
  wire                vyn1sw3fz3lpvwa20xvvf            ;
  wire    [   2:   0] kwgxtrq8ml_dexxfg8n5w         ;
  wire    [   2:   0] i3osrajgql928how6rnre6pvf         ;
  wire    [   3:   0] o1xjzuqr573mbe9yhzwkkzj3         ;
  wire    [   3:   0] msocmsnyo1b9sluq4fc9syb         ;
  wire    [  11:   0] ph9g5_826rroi0g_65wkc             ;
  wire                bnjs2wg98206g19zgvzpcrz7p98      ;
  wire    [  19:   0] njn3p0hec7sv780u3yvb_xvvn      ;
  wire    [  31:   0] wgjpytr3lt5b2gyg6lw5            ;
  wire    [  31:   0] kc067bbbb3qscm3ueb1ewho            ;
  wire                v06dahdzo3dg8e2i9qr            ;
  wire    [   1:   0] xq4xkxuxnvv5nleuy0teinye_          ;
  wire    [   1:   0] taysaoqqcdfvfk09npf1xit8vwxw      ;
  wire                a4cipiqt8vfgl23w2q                ;
  wire                btzht_emu_epsjij                ;
  wire    [   2:   0] gmsj1y4nj42tmw1bfvq9             ;
  wire    [   2:   0] dwu6qm_482h1nkka3c2m             ;
  wire    [   3:   0] forh4q06zyp8v652ufg             ;
  wire    [   3:   0] d0rg3ea6xrzmipv9khqt             ;
  wire    [  11:   0] o__w7pqa1kuig71j                 ;
  wire                c7d6yxol3op5wnbzajx5          ;
  wire    [  19:   0] ysk8e25dg23pwtzrqpptze          ;
wire [1-1:0] knu59jelp7r_6mrh8;
wire [1-1:0] tvebe4x5hyf4rq4xao;
wire [1-1:0] ox78nidpe47zivgp0nrpqyt;
wire [1-1:0] kc1xlwd9vchfsw52rhfpx_;
wire [1-1:0] y5tywvjv5eqjp64vh4;
wire [1-1:0] gk815iih0mdbmrmr4ve87m6h8;
wire [19:0]            yxhqzbe7znfwv40hgsm0m8;
wire                   u4nnwvgebl4n;
wire                   ih65br61snoq2ny;
u5x6gcgot_v3i18ti dnccegi4sm9ap39i2if0 (
  .ri2ziyy(clk),
  .r46kf(rst_n),
  .t90_ydzz6w_k_810k1(knu59jelp7r_6mrh8),
  .qz2d9g2owmwtv2(tvebe4x5hyf4rq4xao),
  .lc_2ssam_d14hcf_al9pjx(u4nnwvgebl4n),
  .uasrgpwdame8ufsy43exru(ox78nidpe47zivgp0nrpqyt),
  .p_xbfsuamfm7rmjw5vnnz(kc1xlwd9vchfsw52rhfpx_),
  .vxtf_xksqg5ers7k2xpy(y5tywvjv5eqjp64vh4),
  .orkaan781129v(ih65br61snoq2ny),
  .oaqk4_dq0sifiewt7guwtqh_(gk815iih0mdbmrmr4ve87m6h8),
  .qi3mexr2jq1b3mycs9(yxhqzbe7znfwv40hgsm0m8),
    .fy9k3hvw9j2kciq_hokh1se           (sseyj1vlfxllhjbzjyvt6mh3x0t        [  31:   0]),
  .x3ehgam3t8xbcgg41q6ok9es           (vy5vt74acy5u9xh0mky84kw        [  31:   0]),
  .r_hgcvpe7hb0__mm3duv2           (ix233l9nk65au4z_tftc5r                   ),
  .ddwwphpikm_g4naro99batiag6         (ks5busqx5jpm9tuemwtxkx79rllq      [   1:   0]),
  .sxig0khx0j6mezzzv7go3odsmhxe     (k8zcggu8t0kqqjgtjpeyfk_ogk339  [   1:   0]),
  .o3oobxt0hlloxdxzz               (cf3vendhrtpe312ww2                       ),
  .s0i00yg7rudwmjnw6qgy6               (vyn1sw3fz3lpvwa20xvvf                       ),
  .f0n31ctqfkhjoqcc30_yt94m            (kwgxtrq8ml_dexxfg8n5w         [   2:   0]),
  .fapxy9a3gthhsx_lmbyv            (i3osrajgql928how6rnre6pvf         [   2:   0]),
  .zbvwjg44rpsrfg89ipy3wgsa            (o1xjzuqr573mbe9yhzwkkzj3         [   3:   0]),
  .yd1v7wrnjwnx6e1q1v53uv            (msocmsnyo1b9sluq4fc9syb         [   3:   0]),
  .m5uruhml6olvgyr_n                (ph9g5_826rroi0g_65wkc             [  11:   0]),
  .ha7h094avs7utt4gw6easvi         (bnjs2wg98206g19zgvzpcrz7p98                 ),
  .oh0zafhsm30zwva1sptj2qh6db         (njn3p0hec7sv780u3yvb_xvvn      [  19:   0]),
  .ja9ak7fyyg2tfwl6_hgy5          (reg_icb_cmd_valid                        ),
  .vp900_m_7rprfhce8q5pi568          (reg_icb_cmd_ready                        ),
  .dzxizqqy0rbu3zei3zb9gf0            (reg_icb_cmd_sel                          ),
  .j_x4s5ilt_v5lyv37_ciuof           (reg_icb_cmd_read                         ),
  .ehxcnr11cdzfbht6ma3oepq1x           (reg_icb_cmd_addr              [  11:   0]),
  .zmlm_u9dzbtemqbjtjpc8xkj0          (reg_icb_cmd_wdata             [  31:   0]),
  .rv7fsnney3mld16o__f5rydqf          (reg_icb_cmd_wmask             [   3:   0]),
  .f9y1mnh2uoyo7kpin0it           (reg_icb_cmd_size              [   2:   0]),
  .epqe_6dfa76a3jyi1_4cttuc           (reg_icb_cmd_lock                         ),
  .fo0jxfcjwjztsht4mh5h_1wbd           (reg_icb_cmd_excl                         ),
  .z2g406o75oaub1wjw2907r6_           (reg_icb_cmd_xlen              [   7:   0]),
  .wtemp15ccsjv6ibcisteaqehr         (reg_icb_cmd_xburst            [   1:   0]),
  .p4uiqew43rhmn4ekhgo6f3          (reg_icb_cmd_modes             [   1:   0]),
  .kppo97u8cpxhru_thlw0k          (reg_icb_cmd_dmode                        ),
  .r5wjevrqno2b5xyy10yluoui2          (reg_icb_cmd_attri             [   2:   0]),
  .c1v8jz0dl11fzqe3y2bijn           (reg_icb_cmd_beat              [   1:   0]),
  .kwo00s6g_hjrbwgo43eib            (reg_icb_cmd_usr                          ),
  .siz0qp40uft869er5w85lw0u          (reg_icb_rsp_ready                        ),
  .hl4s82j47qcocdtd0f5l1          (reg_icb_rsp_valid                        ),
  .vnuvw3ym5_h10nvhmuwc_i            (reg_icb_rsp_err                          ),
  .owdu_hbe9row3ro6y6f2nbngi        (reg_icb_rsp_excl_ok                      ),
  .uuz4jzqdcev5s89r_2ckj6il          (reg_icb_rsp_rdata             [  31:   0]),
  .dvp1yi5mx24rqoqxerisih5            (reg_icb_rsp_usr                          ),
  .y9kex8e7h(udma_irq)
);
wire ukwgcam5ttjrtq; 
hwishx8cewrzkxcaaanvw_lmqe do_59hifi794yhxr8mvjq2srxyvn (
  .ri2ziyy(clk),
  .r46kf(rst_n),
  .mkqjduogell(ukwgcam5ttjrtq),
  .j6furxzlr7mgpe(tvebe4x5hyf4rq4xao),
  .ublor4qyxq5ex_0(ih65br61snoq2ny),
  .fy9k3hvw9j2kciq_hokh1se           (sseyj1vlfxllhjbzjyvt6mh3x0t        [  31:   0]),
  .x3ehgam3t8xbcgg41q6ok9es           (vy5vt74acy5u9xh0mky84kw        [  31:   0]),
  .r_hgcvpe7hb0__mm3duv2           (ix233l9nk65au4z_tftc5r                   ),
  .ddwwphpikm_g4naro99batiag6         (ks5busqx5jpm9tuemwtxkx79rllq      [   1:   0]),
  .sxig0khx0j6mezzzv7go3odsmhxe     (k8zcggu8t0kqqjgtjpeyfk_ogk339  [   1:   0]),
  .o3oobxt0hlloxdxzz               (cf3vendhrtpe312ww2                       ),
  .s0i00yg7rudwmjnw6qgy6               (vyn1sw3fz3lpvwa20xvvf                       ),
  .f0n31ctqfkhjoqcc30_yt94m            (kwgxtrq8ml_dexxfg8n5w         [   2:   0]),
  .fapxy9a3gthhsx_lmbyv            (i3osrajgql928how6rnre6pvf         [   2:   0]),
  .zbvwjg44rpsrfg89ipy3wgsa            (o1xjzuqr573mbe9yhzwkkzj3         [   3:   0]),
  .yd1v7wrnjwnx6e1q1v53uv            (msocmsnyo1b9sluq4fc9syb         [   3:   0]),
  .m5uruhml6olvgyr_n                (ph9g5_826rroi0g_65wkc             [  11:   0]),
  .ha7h094avs7utt4gw6easvi         (bnjs2wg98206g19zgvzpcrz7p98                 ),
  .oh0zafhsm30zwva1sptj2qh6db         (njn3p0hec7sv780u3yvb_xvvn      [  19:   0]),
  .ya7naquyfxmwjad06d               (wgjpytr3lt5b2gyg6lw5            [  31:   0]),
  .snodaq6t4x3gctm2               (kc067bbbb3qscm3ueb1ewho            [  31:   0]),
  .ewphlfid8m3pl8igg               (v06dahdzo3dg8e2i9qr                       ),
  .cqycg73b4lphg0tkorfyh             (xq4xkxuxnvv5nleuy0teinye_          [   1:   0]),
  .qh_ngonv0kt64n                   (a4cipiqt8vfgl23w2q                           ),
  .ash7_ox639dio6                   (btzht_emu_epsjij                           ),
  .xzmdyzqyrja0vtbg2                (gmsj1y4nj42tmw1bfvq9             [   2:   0]),
  .ydx90dsfkk0d1z7                (dwu6qm_482h1nkka3c2m             [   2:   0]),
  .dqjbuqsw06fprxnifh                (forh4q06zyp8v652ufg             [   3:   0]),
  .bayhz_in9eupl_gcydqh                (d0rg3ea6xrzmipv9khqt             [   3:   0]),
  .nq52a9vl8nd7zna                    (o__w7pqa1kuig71j                 [  11:   0]),
  .fmp05ivxtl15lotxxvko0k9             (c7d6yxol3op5wnbzajx5                     ),
  .lg8mo7pemejac1jt_hyim             (ysk8e25dg23pwtzrqpptze          [  19:   0])
);
wire        liw1m5s_4g45i       = v06dahdzo3dg8e2i9qr;
wire [19:0] urkvx_pzj5     = ysk8e25dg23pwtzrqpptze;
wire [19:0] rolfo3k4cctz5wq = urkvx_pzj5;
wire [2:0]  b89blt2973j_r5  = dwu6qm_482h1nkka3c2m;
wire [32-1:0] mxbtg_dwkbvj7bg   = wgjpytr3lt5b2gyg6lw5;
wire [1:0]  ykbgh96za0a65  = {1'b0, ~btzht_emu_epsjij};
wire [7:0]  wvkqhp3vpskd48 = {4'b0, d0rg3ea6xrzmipv9khqt};
wire [19:0] sw3w8sjqy25xms = urkvx_pzj5;
wire [2:0]  lo4u9vrsiiuwaw_i  = gmsj1y4nj42tmw1bfvq9;
wire [32-1:0] lrayxp22g_5b0evm   = kc067bbbb3qscm3ueb1ewho;
wire [1:0]  mav2b956n9upxhd  = {1'b0, ~a4cipiqt8vfgl23w2q};
wire [7:0]  b8eeylku8bbcr098qv = {4'b0, forh4q06zyp8v652ufg};
wire [7:0]  evjxuijiuvdxutls0;
wire        f3315t6qgqbmrxigde43kl1nii;
wire        sb13lli5sb800r6fb;
wire        z6hh4dvj46bpyfc1ywl;
wire        apkp_9vj9gtlwyy67l;
wire [19:0] pr22v57d4fm9kpz7npik0n74;
wire        akv6g0puitdnykf       = r_icb_rsp_valid & r_icb_rsp_ready;
wire        fauedl_4uv4owrf       = r_icb_cmd_valid & r_icb_cmd_ready;
wire        x3uvaw_0dh4rc0x4qe_z71 = akv6g0puitdnykf   & r_icb_rsp_err;
wire        tn0ilkv6790qs3km5x6;
wire [3:0]              vey88ed7r8s7tq3;
wire                    j8rw6jsbhvnuut6fo = |vey88ed7r8s7tq3;
wire                    dz9adtbr5uu2dkllocr  = ~j8rw6jsbhvnuut6fo;
wire [8-1:0] gvpf3raa6n_9lof;
wire                    vty77pcldxho4hltxr = fauedl_4uv4owrf ^ akv6g0puitdnykf;
wire [8-1:0] mlqpmhvqlyebbrfizlf2 = fauedl_4uv4owrf ? gvpf3raa6n_9lof + {{8-1{1'b0}}, 1'b1} : gvpf3raa6n_9lof - {{8-1{1'b0}}, 1'b1};
ns_gnrl_dfflr #(8) y420lfv91q4xdx113wtew6ej(vty77pcldxho4hltxr, mlqpmhvqlyebbrfizlf2, gvpf3raa6n_9lof, clk, rst_n);
wire                    i7y2cwirttlkx4ma   = (gvpf3raa6n_9lof == 8'b0);
wire                   p_syzz8a7r07vx_jeaeq7p;
wire                   hhqoikezeni9_0;
wire                   dpj7aams0bftr8_gt;
wire                   eqewosindfku94gszs5;
wire                   of93dwnkm1ll2e0iryo4;
wire                   v5fo0zsl_i7lqrrav5skb = ~eqewosindfku94gszs5 & (x3uvaw_0dh4rc0x4qe_z71 | (tn0ilkv6790qs3km5x6 & ~dpj7aams0bftr8_gt & (apkp_9vj9gtlwyy67l | hhqoikezeni9_0)));
wire                   z255upf925_mhfxsftdpfh = eqewosindfku94gszs5 & (i7y2cwirttlkx4ma) & dz9adtbr5uu2dkllocr & ~p_syzz8a7r07vx_jeaeq7p & ~r_icb_cmd_valid;
wire                   k27p6mkvlpev4hoaicsc = v5fo0zsl_i7lqrrav5skb | z255upf925_mhfxsftdpfh;
wire                   q59nbax8db98fu33qq = v5fo0zsl_i7lqrrav5skb;
ns_gnrl_dfflr #(1) h0xs6saa519lbj3ajajni8eo(k27p6mkvlpev4hoaicsc, q59nbax8db98fu33qq, eqewosindfku94gszs5, clk, rst_n);
ns_gnrl_dffr #(1) slyn0bh1lxqw18s611q(eqewosindfku94gszs5, of93dwnkm1ll2e0iryo4, clk, rst_n);
wire                   k19xt5k0cxmajl6y  = ~eqewosindfku94gszs5 & of93dwnkm1ll2e0iryo4; 
wire                   ja7en2qmi559dx1u;
wire                   ocdbgbm3lvpl6lq1b29_m  = (k19xt5k0cxmajl6y & (~dpj7aams0bftr8_gt)) | (ja7en2qmi559dx1u & (~eqewosindfku94gszs5));
wire        duep4816kxnrfb;
wire        h0pyzzgeg2wz9q;
wire        eg1331_dojedv    = liw1m5s_4g45i; 
wire        a5y5ks12503jc23p7 = (eg1331_dojedv & (~h0pyzzgeg2wz9q) & duep4816kxnrfb) | f3315t6qgqbmrxigde43kl1nii; 
ns_gnrl_dffr #(1) pwu23tseypxp0fyq (eg1331_dojedv, h0pyzzgeg2wz9q, clk, rst_n);
wire        zp61wmwb   = (b89blt2973j_r5  == 3'b000); 
wire        ogomr3w0_ykr   = (b89blt2973j_r5  == 3'b001); 
wire        f3r1qkaibua7m   = (b89blt2973j_r5  == 3'b010); 
wire        aaeyy54_4an1xj  = (b89blt2973j_r5  == 3'b011);
wire        qe05_79p8i  = (b89blt2973j_r5  == 3'b100);
wire        y3lyzof8dlgu9bff11x     = (ogomr3w0_ykr  & mxbtg_dwkbvj7bg[0]) 
                               | (f3r1qkaibua7m  & |mxbtg_dwkbvj7bg[1:0])
                               | (aaeyy54_4an1xj & |mxbtg_dwkbvj7bg[2:0])
                               | (qe05_79p8i & |mxbtg_dwkbvj7bg[3:0]);
wire        x0w2nn45wtwnu        = |wvkqhp3vpskd48;
wire [7:0]  k9t5khpstj05s2t_f6u = wvkqhp3vpskd48-8'b1;
wire        skpgekbb_ztqsz2s7tpfm = (b8eeylku8bbcr098qv >= wvkqhp3vpskd48);
assign      evjxuijiuvdxutls0     = (y3lyzof8dlgu9bff11x & x0w2nn45wtwnu & skpgekbb_ztqsz2s7tpfm) ? k9t5khpstj05s2t_f6u : b8eeylku8bbcr098qv; 
wire [1:0]       xm85mmg2p4tj3413c4az;
wire [32-1:0]   o21yf_gouiq5wzl2bh8;
wire [32-1:0]   diw1rvnaq4mp52ersrf20l =  zp61wmwb  ? o21yf_gouiq5wzl2bh8 + {{32-1{1'b0}}, 1'b1} : 
                                           ogomr3w0_ykr  ? {o21yf_gouiq5wzl2bh8[32-1:1], 1'b0} + {{32-2{1'b0}}, 2'b10} :
                                           f3r1qkaibua7m  ? {o21yf_gouiq5wzl2bh8[32-1:2], 2'b0} + {{32-3{1'b0}}, 3'b100} :
                                           aaeyy54_4an1xj ? {o21yf_gouiq5wzl2bh8[32-1:3], 3'b0} + {{32-4{1'b0}}, 4'b1000} :
                                           qe05_79p8i ? {o21yf_gouiq5wzl2bh8[32-1:4], 4'b0} + {{32-5{1'b0}}, 5'b10000} : o21yf_gouiq5wzl2bh8;
wire vqmisjdnmn7fzlek = a5y5ks12503jc23p7 | fauedl_4uv4owrf;
wire wmsaqqmetntf9 = a5y5ks12503jc23p7;
wire [3:0]       koo9aaqbalg39wef = {4{zp61wmwb}} & 4'hf
                             | {4{ogomr3w0_ykr}} & 4'he
                             | {4{f3r1qkaibua7m}} & 4'hc
                             | {4{aaeyy54_4an1xj}} & 4'h8
                             | {4{qe05_79p8i}} & 4'h0
                             ;
wire [32-1:0]   osugdue08_x47uocd7w4qopk17kv  = {{32-4{1'b1}},koo9aaqbalg39wef} & mxbtg_dwkbvj7bg;
wire [32-1:0]   selfg_0aal7z55oyjn4db8no44 = wmsaqqmetntf9  ? mxbtg_dwkbvj7bg : diw1rvnaq4mp52ersrf20l;
wire [32-1:0]   evnl_a0gbfvix9sv5fba0i       = btzht_emu_epsjij ? osugdue08_x47uocd7w4qopk17kv       : selfg_0aal7z55oyjn4db8no44;
ns_gnrl_dfflr #(32) u4y5qzpe3bi1yxga46xxk45(vqmisjdnmn7fzlek, evnl_a0gbfvix9sv5fba0i, o21yf_gouiq5wzl2bh8, clk, rst_n);
assign  duep4816kxnrfb = zp61wmwb | ogomr3w0_ykr | f3r1qkaibua7m | aaeyy54_4an1xj | qe05_79p8i;
wire [2:0]       ywnlyx3242h5    = zp61wmwb ? 3'b0   :
                                   ogomr3w0_ykr ? 3'b001 :
                                   f3r1qkaibua7m ? 3'b010 :
                                   aaeyy54_4an1xj ? 3'b011 :            
                                   qe05_79p8i ? 3'b100 : 3'b0;           
wire [8:0]       qw1yuqjgyuzjtt84xk  = (({1'b0,wvkqhp3vpskd48} + 5'b1) << ywnlyx3242h5);
wire [10:0] k70slv91iobticrk50f = o21yf_gouiq5wzl2bh8[9:0] + {1'b0,qw1yuqjgyuzjtt84xk};
wire        oqisuiceyughh      = k70slv91iobticrk50f <= 11'h400;
wire             z1pjt9ky7lwlgca9www43k  = (pr22v57d4fm9kpz7npik0n74 >= {{20-9{1'b0}},qw1yuqjgyuzjtt84xk});
wire             fc_kdzqwd0mqsz        = ( (z1pjt9ky7lwlgca9www43k & oqisuiceyughh & dz9adtbr5uu2dkllocr)
                                          | j8rw6jsbhvnuut6fo
                                         ) & fauedl_4uv4owrf;
wire [3:0]       b7fdw5lexu0km84yx6 = (vey88ed7r8s7tq3 == wvkqhp3vpskd48[3:0]) ? 4'b0 : (vey88ed7r8s7tq3 + 4'b1);
ns_gnrl_dfflr #(4) d5pwx2jq4wr36riff(fc_kdzqwd0mqsz, b7fdw5lexu0km84yx6, vey88ed7r8s7tq3, clk, rst_n);
wire [1:0]       x4is0knduo_6ylb    = (wvkqhp3vpskd48[3:0] == 4'b0) ? 2'b0 :
                                   (   ((apkp_9vj9gtlwyy67l & ~eqewosindfku94gszs5) | p_syzz8a7r07vx_jeaeq7p) 
                                     & (vey88ed7r8s7tq3 == 4'b0) 
                                     & z1pjt9ky7lwlgca9www43k & oqisuiceyughh
                                   )                             ? 2'b01 :
                                   (
                                    (apkp_9vj9gtlwyy67l | p_syzz8a7r07vx_jeaeq7p) 
                                    & 
                                    (vey88ed7r8s7tq3 == wvkqhp3vpskd48[3:0])
                                   )                             ? 2'b10 : 2'b0;
wire             m25lct6ojgnx63a = dz9adtbr5uu2dkllocr & ((~z1pjt9ky7lwlgca9www43k) | (~oqisuiceyughh));  
wire [7:0]       s__nhdp8cj5yy00z   = m25lct6ojgnx63a ? 8'b0 : wvkqhp3vpskd48;
wire [4:0]      wsdf9_i1j633yx5xws = zp61wmwb ? 5'b1  :
                                   ogomr3w0_ykr ? 5'b10 :   
                                   f3r1qkaibua7m ? 5'b100 :   
                                   aaeyy54_4an1xj ? 5'b1000 :  
                                   qe05_79p8i ? 5'b10000 : 5'b0;
wire [4:0] gsvtyoi792vgckzdoy  = 5'b10  - {4'b0, o21yf_gouiq5wzl2bh8[0]};
wire [4:0] c9w4z4wjlgpzegcerb2b  = 5'b100 - {3'b0, o21yf_gouiq5wzl2bh8[1:0]};
wire [4:0] ooog3w24zm67pq8k21rog = 5'b1000 - {2'b0, o21yf_gouiq5wzl2bh8[2:0]};
wire [4:0] zkvtllwf7_1_1rb9 = 5'b10000 - {1'b0, o21yf_gouiq5wzl2bh8[3:0]};
wire [4:0] csfbz0aapz7me6mnhxz =  zp61wmwb ? 5'b1 : 
                              ogomr3w0_ykr ? gsvtyoi792vgckzdoy :
                              f3r1qkaibua7m ? c9w4z4wjlgpzegcerb2b :
                              aaeyy54_4an1xj ? ooog3w24zm67pq8k21rog :
                              zkvtllwf7_1_1rb9;
wire        yo1o4t9lastpgz         = (rolfo3k4cctz5wq <= {{20-5{1'b0}},csfbz0aapz7me6mnhxz});
wire        k01a2ermapctly6uii8n = (pr22v57d4fm9kpz7npik0n74 <= {{20-5{1'b0}},csfbz0aapz7me6mnhxz});
wire        y9ywgfxkaftpfv8884          = k01a2ermapctly6uii8n | yo1o4t9lastpgz;
wire        kya6vvqspninyt5xzmfmf5epogp  = a5y5ks12503jc23p7 | (fauedl_4uv4owrf & (~k01a2ermapctly6uii8n));
wire [19:0] i4y5vy9d0_v2fin9ui9sm9njq6 = a5y5ks12503jc23p7 ? rolfo3k4cctz5wq : (pr22v57d4fm9kpz7npik0n74 - {{20-5{1'b0}},csfbz0aapz7me6mnhxz});
ns_gnrl_dfflr #(20) y01yqymzzyru9c2jrrcjwtc2_oi(kya6vvqspninyt5xzmfmf5epogp, i4y5vy9d0_v2fin9ui9sm9njq6, pr22v57d4fm9kpz7npik0n74, clk, rst_n);
wire        rx4o8j_3vd80cx4vp2_;
assign      sb13lli5sb800r6fb = y9ywgfxkaftpfv8884 & eg1331_dojedv & fauedl_4uv4owrf;
wire        jgamyuf4bwnb_8peby = rx4o8j_3vd80cx4vp2_;
wire        kgodccbqbe4h52txw7j88f = sb13lli5sb800r6fb | jgamyuf4bwnb_8peby;
wire        gh11ymw_xw_heios99yy = sb13lli5sb800r6fb | ~jgamyuf4bwnb_8peby;
ns_gnrl_dfflr #(1) dp9sujanau7y9qcigbhej35h(kgodccbqbe4h52txw7j88f, gh11ymw_xw_heios99yy, rx4o8j_3vd80cx4vp2_, clk, rst_n);
wire        u5iyylsr6hllloz0;
wire        wphq5blkqsgww2 = ~u5iyylsr6hllloz0 & fauedl_4uv4owrf;
wire        jsvmal3z3e157 = rx4o8j_3vd80cx4vp2_ | ocdbgbm3lvpl6lq1b29_m;
wire        ffh932xjo0vl0jvdm1 = wphq5blkqsgww2 | jsvmal3z3e157;
wire        d4ds5kmxert0d4hj = wphq5blkqsgww2 | ~jsvmal3z3e157;
ns_gnrl_dfflr #(1) wmkyddigkvi5pmiydr6(ffh932xjo0vl0jvdm1, d4ds5kmxert0d4hj, u5iyylsr6hllloz0, clk, rst_n);
wire        lfnp42hlopuljfrkw7_t_un = eg1331_dojedv & fauedl_4uv4owrf & ~u5iyylsr6hllloz0;
wire [19:0] wjgch9e9ob5jgpwpnq9ni;
wire        c0gpd75lrzn_keg_342          = (wjgch9e9ob5jgpwpnq9ni < {{20-5{1'b0}},csfbz0aapz7me6mnhxz}) | yo1o4t9lastpgz;
wire        u1r1kmvk1bldpftq1kjduf5wwwy  = (wjgch9e9ob5jgpwpnq9ni == {{20-5{1'b0}},csfbz0aapz7me6mnhxz});
wire [4:0]  q4oo23_4tmjzk3z1g0        = c0gpd75lrzn_keg_342 ? wjgch9e9ob5jgpwpnq9ni[4:0] : csfbz0aapz7me6mnhxz;
wire [4:0]  vkfk9nnm2xgshvrb6ae10a; 
ns_gnrl_dfflr #(5) dkbaf_gc8v8lz4f9wooww2h2r(sb13lli5sb800r6fb, pr22v57d4fm9kpz7npik0n74[4:0], vkfk9nnm2xgshvrb6ae10a, clk, rst_n);
wire [4:0]  z_ufu6i85c41yfubx1g3rp8; 
ns_gnrl_dfflr #(5) gkrxotf8enmcrt380d6v563y3l(lfnp42hlopuljfrkw7_t_un, q4oo23_4tmjzk3z1g0, z_ufu6i85c41yfubx1g3rp8, clk, rst_n);
wire        tzd6gqevob4v8wb89eb         = ~hhqoikezeni9_0;
wire        rmnziojtk_7z1bpw09ejyo  = (a5y5ks12503jc23p7 | akv6g0puitdnykf) ;
wire [19:0] w90vg8cl_qcpmcyrtjtxhg7 = a5y5ks12503jc23p7                ?  rolfo3k4cctz5wq :
                                      tzd6gqevob4v8wb89eb             ?  wjgch9e9ob5jgpwpnq9ni - {{20-5{1'b0}},z_ufu6i85c41yfubx1g3rp8} :
                                      c0gpd75lrzn_keg_342  | yo1o4t9lastpgz ?  20'b0          : 
                                      wjgch9e9ob5jgpwpnq9ni - {{20-5{1'b0}},csfbz0aapz7me6mnhxz};
ns_gnrl_dfflr #(20) za17xcjiomyl5p8cj_4dx80kyzy(rmnziojtk_7z1bpw09ejyo, w90vg8cl_qcpmcyrtjtxhg7, wjgch9e9ob5jgpwpnq9ni, clk, rst_n);
wire        gn180c_5sqxd;
wire        d3appybw8vj3h2w4n9      = c0gpd75lrzn_keg_342 & eg1331_dojedv & akv6g0puitdnykf;
wire        c8vf_5ed40fqyx2uq_sap_e = (
                                       (c0gpd75lrzn_keg_342 | u1r1kmvk1bldpftq1kjduf5wwwy) 
                                     & 
                                       ~(tzd6gqevob4v8wb89eb & (~gn180c_5sqxd))
                                     )
                                   & eg1331_dojedv & akv6g0puitdnykf;
wire        bs0dzx7_fapgigp8c2hom = a5y5ks12503jc23p7;
wire        h197z09nyq81lwe0tr = sb13lli5sb800r6fb | (eqewosindfku94gszs5 & dz9adtbr5uu2dkllocr);
wire        daankcnpoh3q0ajpcv = bs0dzx7_fapgigp8c2hom  |  h197z09nyq81lwe0tr;
wire        lbf7u4n3oqcn97jvg_g = bs0dzx7_fapgigp8c2hom  | ~h197z09nyq81lwe0tr;
ns_gnrl_dfflr #(1) wcdpduby12gtljh3kuc5lt(daankcnpoh3q0ajpcv, lbf7u4n3oqcn97jvg_g, apkp_9vj9gtlwyy67l, clk, rst_n);
wire        ukqe4433lp2g2w288fly = akv6g0puitdnykf     & ~hhqoikezeni9_0;
wire        sk7hjeyumgseh7w5jd = c8vf_5ed40fqyx2uq_sap_e 
                             | (eqewosindfku94gszs5 & dz9adtbr5uu2dkllocr)  
                             | (hhqoikezeni9_0  & (~(|wjgch9e9ob5jgpwpnq9ni))); 
wire        at624qahi834x_ryex = ukqe4433lp2g2w288fly  | sk7hjeyumgseh7w5jd;
wire        lsu_j0xdd9_9sxev7e = ukqe4433lp2g2w288fly;
ns_gnrl_dfflr #(1) y2hrapjiikbnnpppzzqd5d8u(at624qahi834x_ryex, lsu_j0xdd9_9sxev7e, hhqoikezeni9_0, clk, rst_n);
wire       ak9ozzxzcncg2gawzxq    = (x4is0knduo_6ylb == 2'b01);
wire       pw_szlqm1r_esywdyiw25c6;
wire       j7p8whbzfobzsshf52_6ypv = r_icb_cmd_valid & (~ak9ozzxzcncg2gawzxq) & (~r_icb_cmd_ready) & (~pw_szlqm1r_esywdyiw25c6);
wire       j9oyo_7hlob1w6n0qvaoormz4 = pw_szlqm1r_esywdyiw25c6 & fauedl_4uv4owrf;
wire       mrevbmpgkx5cmmgipcd_zhcnyb = j7p8whbzfobzsshf52_6ypv | j9oyo_7hlob1w6n0qvaoormz4;
wire       hwo7gmdr3u5td8fra69mt = j7p8whbzfobzsshf52_6ypv;
ns_gnrl_dfflr #(1) ya7kthsxb967998d2fdlaap1dpk(mrevbmpgkx5cmmgipcd_zhcnyb, hwo7gmdr3u5td8fra69mt, pw_szlqm1r_esywdyiw25c6, clk, rst_n);
wire       rbqpqwwmjr4ag8rouaq = (r_icb_cmd_valid   & ak9ozzxzcncg2gawzxq) & (~p_syzz8a7r07vx_jeaeq7p);
wire       b84kqtqev83_w61t5k7ok = (p_syzz8a7r07vx_jeaeq7p & (x4is0knduo_6ylb == 2'b10) & fauedl_4uv4owrf); 
wire       vygh611iz0qvmtkr5hcgwrpc = rbqpqwwmjr4ag8rouaq | b84kqtqev83_w61t5k7ok;
wire       hvr85anc4h6e6ksdsq8 = rbqpqwwmjr4ag8rouaq;
ns_gnrl_dfflr #(1) papzosh09yzbx_l3oyzae1hpqt(vygh611iz0qvmtkr5hcgwrpc, hvr85anc4h6e6ksdsq8, p_syzz8a7r07vx_jeaeq7p, clk, rst_n);
wire [5:0]  nm6rs6q3r2xyzhyyr1hi90ne = {lfnp42hlopuljfrkw7_t_un, sb13lli5sb800r6fb, o21yf_gouiq5wzl2bh8[3:0]}; 
wire [5:0]  q14ycu1j8ek3ck0u_8cpxfp;
wire        xgf6dyetq_1vgiqjowxas3fruy3;
wire        x3crvl9x92k8_2yeoph;
wire xp5xvl2g49adsv8496ph = fauedl_4uv4owrf & (~(akv6g0puitdnykf & (~xgf6dyetq_1vgiqjowxas3fruy3))); 
wire xao_shndulmtjz   = fauedl_4uv4owrf & akv6g0puitdnykf & (~xgf6dyetq_1vgiqjowxas3fruy3);
  ns_gnrl_fifo # (
    .CUT_READY (0),
    .MSKO      (0),
    .DP  (32),
    .DW  (6)
  ) hrgemlo6g1ajmqukvme (
    .i_vld  (xp5xvl2g49adsv8496ph),
    .i_rdy  (x3crvl9x92k8_2yeoph),
    .i_dat  (nm6rs6q3r2xyzhyyr1hi90ne),
    .o_vld  (xgf6dyetq_1vgiqjowxas3fruy3),
    .o_rdy  (akv6g0puitdnykf),  
    .o_dat  (q14ycu1j8ek3ck0u_8cpxfp),  
    .clk    (clk),
    .rst_n  (rst_n)
  );
wire [6:0] hyi_y04px3n3jh57e = xao_shndulmtjz ? {3'b0,nm6rs6q3r2xyzhyyr1hi90ne[3:0]}: {3'b0, q14ycu1j8ek3ck0u_8cpxfp[3:0]};
wire [64-1:0] lb5un8nxpzi972k = (r_icb_rsp_rdata >> {hyi_y04px3n3jh57e[3-1:0],3'b0});
wire pdt3x84b51x = ukqe4433lp2g2w288fly;
wire o15n7rdj1a5zqkv5zbyz;
wire [4:0] ryn6o45rimbt3c56qf;
wire f4aqvxm27_rv66owb1d;
wire           xr8519la238ihsbxeio0_uei1wd1;
wire [64-1:0] p44fhita3ir9mw5x5t1;
wire           s6ecvs_o_i40iexs8ho9h  = akv6g0puitdnykf;
wire [64-1:0] m_uemt_q0h6k30tnvs37542 = lb5un8nxpzi972k; 
ns_gnrl_dfflr #(64) e5gvc0gkzbwenm5jo4vqjbg(s6ecvs_o_i40iexs8ho9h, m_uemt_q0h6k30tnvs37542, p44fhita3ir9mw5x5t1, clk, rst_n);
wire         r_57uxst8h04je7uobnw; 
wire         g2hsxil_6zsv4bzkaxsn3eh8_ = c8vf_5ed40fqyx2uq_sap_e;
wire         jb3jiwhuxxz4imccx1ymkrva7 = xr8519la238ihsbxeio0_uei1wd1;
wire         u6xutz4_l98kpmkyu0vp_s090e = g2hsxil_6zsv4bzkaxsn3eh8_ | jb3jiwhuxxz4imccx1ymkrva7;
wire         rfgta2mjqap1wbf_7vnnhfl2h = g2hsxil_6zsv4bzkaxsn3eh8_;
ns_gnrl_dfflr #(1) stwcx8o3_clx4pynq28zym6e8(u6xutz4_l98kpmkyu0vp_s090e,rfgta2mjqap1wbf_7vnnhfl2h , r_57uxst8h04je7uobnw, clk, rst_n);
wire          iwzg5d2b6p8gx7p6zvkq4fh5u7 = (z_ufu6i85c41yfubx1g3rp8 == wsdf9_i1j633yx5xws);
wire          k585j30g251txa3rt      = (({1'b0, ryn6o45rimbt3c56qf} + {1'b0, vkfk9nnm2xgshvrb6ae10a}) > {1'b0, wsdf9_i1j633yx5xws});
wire          lxa8ontxoora38brwgwmcz0 = akv6g0puitdnykf | (r_57uxst8h04je7uobnw & xr8519la238ihsbxeio0_uei1wd1 & |ryn6o45rimbt3c56qf) | ocdbgbm3lvpl6lq1b29_m;
wire [4:0]    a8ai8qz63jrvkc2dlqfdo7w = (akv6g0puitdnykf     & ~hhqoikezeni9_0 & (iwzg5d2b6p8gx7p6zvkq4fh5u7 | c8vf_5ed40fqyx2uq_sap_e)) | ocdbgbm3lvpl6lq1b29_m ? 5'b0 :
                                    akv6g0puitdnykf     & ~hhqoikezeni9_0 & ~iwzg5d2b6p8gx7p6zvkq4fh5u7                    ? z_ufu6i85c41yfubx1g3rp8 : 
                                    d3appybw8vj3h2w4n9 & k585j30g251txa3rt                                            ? ryn6o45rimbt3c56qf + vkfk9nnm2xgshvrb6ae10a - wsdf9_i1j633yx5xws  :
                                    d3appybw8vj3h2w4n9 & ~k585j30g251txa3rt                                           ? 5'b0 :
                                   (xr8519la238ihsbxeio0_uei1wd1 & |ryn6o45rimbt3c56qf) &  r_57uxst8h04je7uobnw ? 5'b0 : 
                                    ryn6o45rimbt3c56qf;
ns_gnrl_dfflr #(5) cfh020ajigl3hko5oo58s(lxa8ontxoora38brwgwmcz0, a8ai8qz63jrvkc2dlqfdo7w, ryn6o45rimbt3c56qf, clk, rst_n);
assign     gn180c_5sqxd             = (rolfo3k4cctz5wq <= {{20-5{1'b0}},z_ufu6i85c41yfubx1g3rp8});
wire       lv3317e_xf6x3_s5dufygw2;  
wire       bas7f5b_ot1lcogro5bxr94iul = ( 
                                       ((((~hhqoikezeni9_0 & iwzg5d2b6p8gx7p6zvkq4fh5u7) | hhqoikezeni9_0) | gn180c_5sqxd) &  akv6g0puitdnykf) 
                                      |
                                       (   r_57uxst8h04je7uobnw & xr8519la238ihsbxeio0_uei1wd1 & |ryn6o45rimbt3c56qf)
                                      ) 
                                      ;
assign     xr8519la238ihsbxeio0_uei1wd1 = (lv3317e_xf6x3_s5dufygw2 & f4aqvxm27_rv66owb1d) | ocdbgbm3lvpl6lq1b29_m;
wire       jc59uy6cmnjec8tta34h3um5u =  bas7f5b_ot1lcogro5bxr94iul | xr8519la238ihsbxeio0_uei1wd1;
wire       qh2b90gcpao2prv84kug88dxy2asu = bas7f5b_ot1lcogro5bxr94iul & (~ocdbgbm3lvpl6lq1b29_m);
ns_gnrl_dfflr #(1) l_60ftwk9b6l7_iy0s8d9lygx40(jc59uy6cmnjec8tta34h3um5u, qh2b90gcpao2prv84kug88dxy2asu, lv3317e_xf6x3_s5dufygw2, clk, rst_n);
wire cigv1rl2b_eduo647sstn6qw = ja7en2qmi559dx1u | dpj7aams0bftr8_gt;
wire xmi11z1hfkd0dekfgabkv = (
                              (c8vf_5ed40fqyx2uq_sap_e & ~k585j30g251txa3rt)  
                              |
                              ((xr8519la238ihsbxeio0_uei1wd1 & |ryn6o45rimbt3c56qf) &  r_57uxst8h04je7uobnw) 
                             )  & (~cigv1rl2b_eduo647sstn6qw);
wire dzbuixohdeihetmgz7pdc = xr8519la238ihsbxeio0_uei1wd1 | cigv1rl2b_eduo647sstn6qw;
wire mw3q50635e6pwivvkw229qgg = (xmi11z1hfkd0dekfgabkv | dzbuixohdeihetmgz7pdc);
wire it0wf62qi7v_y5ms9784k = xmi11z1hfkd0dekfgabkv & (~cigv1rl2b_eduo647sstn6qw); 
ns_gnrl_dfflr #(1) gf057fumsa7qtfnocmrztmm7kboz(mw3q50635e6pwivvkw229qgg, it0wf62qi7v_y5ms9784k, o15n7rdj1a5zqkv5zbyz, clk, rst_n);
wire [4:0] mqdyuztcttw2vmwzjwx0f8mh4;
wire       blc3ulwuz1f5x1a28v0waqy_  = xmi11z1hfkd0dekfgabkv;
wire [4:0] ehsvlmbyc_0blmrlne2fdfsgjdz = r_icb_rsp_valid ? ryn6o45rimbt3c56qf + vkfk9nnm2xgshvrb6ae10a : ryn6o45rimbt3c56qf;
ns_gnrl_dfflr #(5) hvked7bbt4x6n7akjgaaz5vhwc_zn0kjul(blc3ulwuz1f5x1a28v0waqy_, ehsvlmbyc_0blmrlne2fdfsgjdz, mqdyuztcttw2vmwzjwx0f8mh4, clk, rst_n);
wire [7:0]        s1ybvfudz9q_jkda_shs2lpqrppz = {csfbz0aapz7me6mnhxz - z_ufu6i85c41yfubx1g3rp8, 3'b0};
wire [64-1:0]    wl8xhqdu0higwlibst2mv214ww87_r1 = {p44fhita3ir9mw5x5t1 >> s1ybvfudz9q_jkda_shs2lpqrppz};
wire [8-1:0] qvcg_rwh_4p_lq4d1qpqkxn7fpe2;
wire [64-1:0]   axhx5w0vhsv88ttxy9pal;
   assign qvcg_rwh_4p_lq4d1qpqkxn7fpe2[0] = (ryn6o45rimbt3c56qf > 5'd0);
   assign axhx5w0vhsv88ttxy9pal[0*8 +: 8] = {8{qvcg_rwh_4p_lq4d1qpqkxn7fpe2[0]}} & wl8xhqdu0higwlibst2mv214ww87_r1[0*8 +: 8];
   assign qvcg_rwh_4p_lq4d1qpqkxn7fpe2[1] = (ryn6o45rimbt3c56qf > 5'd1);
   assign axhx5w0vhsv88ttxy9pal[1*8 +: 8] = {8{qvcg_rwh_4p_lq4d1qpqkxn7fpe2[1]}} & wl8xhqdu0higwlibst2mv214ww87_r1[1*8 +: 8];
   assign qvcg_rwh_4p_lq4d1qpqkxn7fpe2[2] = (ryn6o45rimbt3c56qf > 5'd2);
   assign axhx5w0vhsv88ttxy9pal[2*8 +: 8] = {8{qvcg_rwh_4p_lq4d1qpqkxn7fpe2[2]}} & wl8xhqdu0higwlibst2mv214ww87_r1[2*8 +: 8];
   assign qvcg_rwh_4p_lq4d1qpqkxn7fpe2[3] = (ryn6o45rimbt3c56qf > 5'd3);
   assign axhx5w0vhsv88ttxy9pal[3*8 +: 8] = {8{qvcg_rwh_4p_lq4d1qpqkxn7fpe2[3]}} & wl8xhqdu0higwlibst2mv214ww87_r1[3*8 +: 8];
   assign qvcg_rwh_4p_lq4d1qpqkxn7fpe2[4] = (ryn6o45rimbt3c56qf > 5'd4);
   assign axhx5w0vhsv88ttxy9pal[4*8 +: 8] = {8{qvcg_rwh_4p_lq4d1qpqkxn7fpe2[4]}} & wl8xhqdu0higwlibst2mv214ww87_r1[4*8 +: 8];
   assign qvcg_rwh_4p_lq4d1qpqkxn7fpe2[5] = (ryn6o45rimbt3c56qf > 5'd5);
   assign axhx5w0vhsv88ttxy9pal[5*8 +: 8] = {8{qvcg_rwh_4p_lq4d1qpqkxn7fpe2[5]}} & wl8xhqdu0higwlibst2mv214ww87_r1[5*8 +: 8];
   assign qvcg_rwh_4p_lq4d1qpqkxn7fpe2[6] = (ryn6o45rimbt3c56qf > 5'd6);
   assign axhx5w0vhsv88ttxy9pal[6*8 +: 8] = {8{qvcg_rwh_4p_lq4d1qpqkxn7fpe2[6]}} & wl8xhqdu0higwlibst2mv214ww87_r1[6*8 +: 8];
   assign qvcg_rwh_4p_lq4d1qpqkxn7fpe2[7] = (ryn6o45rimbt3c56qf > 5'd7);
   assign axhx5w0vhsv88ttxy9pal[7*8 +: 8] = {8{qvcg_rwh_4p_lq4d1qpqkxn7fpe2[7]}} & wl8xhqdu0higwlibst2mv214ww87_r1[7*8 +: 8];
wire             em79o71ozbishg01g;
wire             mzp2bwh9_t0jl1rqz;
wire             t25ctq0jozva7ded8cfpmre  = bas7f5b_ot1lcogro5bxr94iul & ~mzp2bwh9_t0jl1rqz;
wire             o05u366rs_mds8s2_w__mr  = (em79o71ozbishg01g  & mzp2bwh9_t0jl1rqz) | ocdbgbm3lvpl6lq1b29_m; 
wire             lb50z9a5iar2xdo4fp3f8sy  = t25ctq0jozva7ded8cfpmre      | o05u366rs_mds8s2_w__mr;
wire             spbms3ef_ran847cyex  = t25ctq0jozva7ded8cfpmre;
ns_gnrl_dfflr #(1) k5ia6mt5ttfr5si7_7_38ved(lb50z9a5iar2xdo4fp3f8sy, spbms3ef_ran847cyex, mzp2bwh9_t0jl1rqz, clk, rst_n);
wire [4:0]       evyvp8yvczfr10xg7u443ja0 = (~mzp2bwh9_t0jl1rqz & (~iwzg5d2b6p8gx7p6zvkq4fh5u7)) ? 5'b0 :wsdf9_i1j633yx5xws-ryn6o45rimbt3c56qf; 
wire [7:0]       kd5fuu0kyzxc_v5mdk2_fy59_d32 = evyvp8yvczfr10xg7u443ja0 << 3; 
wire [7:0]       lqyf10mr6303u4rq_9melkz907 = ryn6o45rimbt3c56qf << 3;
wire [8-1:0] pgxioke9kr3vizasz8480jldpm0p;
wire [64-1:0]   bpp4axg8grv0xaxb6hmn8p2a5 = ({64{|ryn6o45rimbt3c56qf}} & (p44fhita3ir9mw5x5t1 >> kd5fuu0kyzxc_v5mdk2_fy59_d32 )) | (lb5un8nxpzi972k << lqyf10mr6303u4rq_9melkz907);
wire [64-1:0]   mcw6993vg7u1415dg1hsed;
wire             rt49jj21dypmoohhgg4dufaede = r_icb_rsp_valid & d3appybw8vj3h2w4n9;
   assign pgxioke9kr3vizasz8480jldpm0p[0] = rt49jj21dypmoohhgg4dufaede ? (wjgch9e9ob5jgpwpnq9ni[4:0] > 5'd0) : 1'b1;
   assign mcw6993vg7u1415dg1hsed[0*8 +: 8] = {8{pgxioke9kr3vizasz8480jldpm0p[0]}} & bpp4axg8grv0xaxb6hmn8p2a5[0*8 +: 8];
   assign pgxioke9kr3vizasz8480jldpm0p[1] = rt49jj21dypmoohhgg4dufaede ? (wjgch9e9ob5jgpwpnq9ni[4:0] > 5'd1) : 1'b1;
   assign mcw6993vg7u1415dg1hsed[1*8 +: 8] = {8{pgxioke9kr3vizasz8480jldpm0p[1]}} & bpp4axg8grv0xaxb6hmn8p2a5[1*8 +: 8];
   assign pgxioke9kr3vizasz8480jldpm0p[2] = rt49jj21dypmoohhgg4dufaede ? (wjgch9e9ob5jgpwpnq9ni[4:0] > 5'd2) : 1'b1;
   assign mcw6993vg7u1415dg1hsed[2*8 +: 8] = {8{pgxioke9kr3vizasz8480jldpm0p[2]}} & bpp4axg8grv0xaxb6hmn8p2a5[2*8 +: 8];
   assign pgxioke9kr3vizasz8480jldpm0p[3] = rt49jj21dypmoohhgg4dufaede ? (wjgch9e9ob5jgpwpnq9ni[4:0] > 5'd3) : 1'b1;
   assign mcw6993vg7u1415dg1hsed[3*8 +: 8] = {8{pgxioke9kr3vizasz8480jldpm0p[3]}} & bpp4axg8grv0xaxb6hmn8p2a5[3*8 +: 8];
   assign pgxioke9kr3vizasz8480jldpm0p[4] = rt49jj21dypmoohhgg4dufaede ? (wjgch9e9ob5jgpwpnq9ni[4:0] > 5'd4) : 1'b1;
   assign mcw6993vg7u1415dg1hsed[4*8 +: 8] = {8{pgxioke9kr3vizasz8480jldpm0p[4]}} & bpp4axg8grv0xaxb6hmn8p2a5[4*8 +: 8];
   assign pgxioke9kr3vizasz8480jldpm0p[5] = rt49jj21dypmoohhgg4dufaede ? (wjgch9e9ob5jgpwpnq9ni[4:0] > 5'd5) : 1'b1;
   assign mcw6993vg7u1415dg1hsed[5*8 +: 8] = {8{pgxioke9kr3vizasz8480jldpm0p[5]}} & bpp4axg8grv0xaxb6hmn8p2a5[5*8 +: 8];
   assign pgxioke9kr3vizasz8480jldpm0p[6] = rt49jj21dypmoohhgg4dufaede ? (wjgch9e9ob5jgpwpnq9ni[4:0] > 5'd6) : 1'b1;
   assign mcw6993vg7u1415dg1hsed[6*8 +: 8] = {8{pgxioke9kr3vizasz8480jldpm0p[6]}} & bpp4axg8grv0xaxb6hmn8p2a5[6*8 +: 8];
   assign pgxioke9kr3vizasz8480jldpm0p[7] = rt49jj21dypmoohhgg4dufaede ? (wjgch9e9ob5jgpwpnq9ni[4:0] > 5'd7) : 1'b1;
   assign mcw6993vg7u1415dg1hsed[7*8 +: 8] = {8{pgxioke9kr3vizasz8480jldpm0p[7]}} & bpp4axg8grv0xaxb6hmn8p2a5[7*8 +: 8];
wire [64-1:0]   q3pi0ub3wnzy70cbpq;
wire             lbmd7012sxzkf2uzlnk7l6vgl = bas7f5b_ot1lcogro5bxr94iul;
wire [64-1:0]   dfo_95cky8yjtueabimodjx3ic7 = r_icb_rsp_valid ? bpp4axg8grv0xaxb6hmn8p2a5 : axhx5w0vhsv88ttxy9pal;
ns_gnrl_dfflr #(64) hjqokb7izb6g2gb8d5epml4gek_(lbmd7012sxzkf2uzlnk7l6vgl, dfo_95cky8yjtueabimodjx3ic7, q3pi0ub3wnzy70cbpq, clk, rst_n);
assign      r_icb_rsp_ready = (~hhqoikezeni9_0 | f4aqvxm27_rv66owb1d);
wire           gj_cq51nfvlp24v7t8;
wire           g_3edn0acaqnnxnw_ky2h4; 
wire [4:0]     bt7cx61oex1hbopgj;
wire           a8t58pxsxfzav0af     = lv3317e_xf6x3_s5dufygw2 & f4aqvxm27_rv66owb1d;
wire           al5_bwq4pe8r4x5tu      = g_3edn0acaqnnxnw_ky2h4 & gj_cq51nfvlp24v7t8;
wire           gnsg0wju22oavyo77y  = a8t58pxsxfzav0af | al5_bwq4pe8r4x5tu | ocdbgbm3lvpl6lq1b29_m;
wire [4:0]     esgs3hglyhrxwhxd_0af8  = ocdbgbm3lvpl6lq1b29_m                                                     ? 5'b0 :
                                    a8t58pxsxfzav0af & ((bt7cx61oex1hbopgj == 5'd8) & o15n7rdj1a5zqkv5zbyz) ? mqdyuztcttw2vmwzjwx0f8mh4 :
                                    a8t58pxsxfzav0af & (bt7cx61oex1hbopgj == 5'd8)                       ? wsdf9_i1j633yx5xws : 
                                    a8t58pxsxfzav0af & o15n7rdj1a5zqkv5zbyz                                   ? bt7cx61oex1hbopgj + mqdyuztcttw2vmwzjwx0f8mh4 :
                                    a8t58pxsxfzav0af                                                       ? bt7cx61oex1hbopgj + wsdf9_i1j633yx5xws :
                                                                                                         5'b0; 
ns_gnrl_dfflr #(5) te5azkvi6x1lnkn2yfjlg(gnsg0wju22oavyo77y, esgs3hglyhrxwhxd_0af8, bt7cx61oex1hbopgj, clk, rst_n);
wire mt6ogs__efx2fnaktanc8wl = a8t58pxsxfzav0af & (esgs3hglyhrxwhxd_0af8 == 5'd8) | o15n7rdj1a5zqkv5zbyz;
wire qxjvfqgqfrp2ojg2fefyz = (gj_cq51nfvlp24v7t8 & g_3edn0acaqnnxnw_ky2h4) | ocdbgbm3lvpl6lq1b29_m;
wire u0twapbhzj3xws9bdp_5 = mt6ogs__efx2fnaktanc8wl | qxjvfqgqfrp2ojg2fefyz;
wire atadoqzslyhqtctpeup1mqi6 = mt6ogs__efx2fnaktanc8wl & (~ocdbgbm3lvpl6lq1b29_m);
ns_gnrl_dfflr #(1) m68k1_4v9bnv0j88twfqhtv(u0twapbhzj3xws9bdp_5, atadoqzslyhqtctpeup1mqi6, g_3edn0acaqnnxnw_ky2h4, clk, rst_n);
assign f4aqvxm27_rv66owb1d   = ~g_3edn0acaqnnxnw_ky2h4 | qxjvfqgqfrp2ojg2fefyz;
wire [64-1:0] a1q7tykt3_5o9jtl_t8w;
wire [8-1:0] d9ubsj1kwy47dq;
wire [64-1:0]   hiwetgfch3uzco6om7;
genvar t;
generate 
 for (t=0;t<8;t=t+1) begin: vxynwq3vlyht9e_5hdu
   assign d9ubsj1kwy47dq[t] = (bt7cx61oex1hbopgj > t[4:0]);
   assign hiwetgfch3uzco6om7[(t+1)*8-1:t*8] = {8{d9ubsj1kwy47dq[t]}} & a1q7tykt3_5o9jtl_t8w[(t+1)*8-1:t*8];
 end
endgenerate 
wire           ardrq2zq52y096q4ce24  = gnsg0wju22oavyo77y;
wire [64-1:0] qr830rjuydzjw311vrsu6dl = (bt7cx61oex1hbopgj == 5'd8) ? q3pi0ub3wnzy70cbpq : (hiwetgfch3uzco6om7 | (q3pi0ub3wnzy70cbpq << {(bt7cx61oex1hbopgj),3'b0}));
ns_gnrl_dfflr #(64) jg4wjb_i86v9buambkav(ardrq2zq52y096q4ce24, qr830rjuydzjw311vrsu6dl, a1q7tykt3_5o9jtl_t8w, clk, rst_n);
wire [64-1:0] ggdo8ad314gcy5aydvgt = a1q7tykt3_5o9jtl_t8w;
wire [64-1:0] af3jecg32ui6j99wlq5p84if;
wire lkhqwv6_ybu4c1uwvzhknje5;
  ns_gnrl_fifo_wflg # (
    .CUT_READY (0),
    .MSKO      (0),
    .DP  (32),
    .DW  (64)
  ) idspufin83ufnsa (
    .i_vld  (g_3edn0acaqnnxnw_ky2h4),
    .i_rdy  (gj_cq51nfvlp24v7t8),
    .i_dat  (ggdo8ad314gcy5aydvgt),
    .o_vld  (lkhqwv6_ybu4c1uwvzhknje5),
    .o_rdy  (z6hh4dvj46bpyfc1ywl),  
    .o_dat  (af3jecg32ui6j99wlq5p84if),  
    .intl_vec(),
    .intl_vec_encode(),
    .cleanfifo(ocdbgbm3lvpl6lq1b29_m),
    .clk  (clk),
    .rst_n(rst_n)
  );
wire [4:0] z__g41rkbvp_qk75tt54       = 5'd8 >> b89blt2973j_r5; 
wire [4:0] v0xv4_387sn9qr934myqcu2hqh7grc = z__g41rkbvp_qk75tt54 - 5'b1;
wire [4:0] rj4fs08c9ei;
wire       wvqj4nucriy = (rj4fs08c9ei == v0xv4_387sn9qr934myqcu2hqh7grc);
wire       jzovl2a2t_5js = fauedl_4uv4owrf | a5y5ks12503jc23p7;
wire [4:0] h94122425nqf1 = (wvqj4nucriy | a5y5ks12503jc23p7) ? 5'b0 : (rj4fs08c9ei + 5'b1);
ns_gnrl_dfflr #(5) fguupsz0hh285(jzovl2a2t_5js, h94122425nqf1, rj4fs08c9ei, clk, rst_n);
wire [5-1:0] m7tdi1nlvyr3u0t8;
wire kxy7kxe1w3obs2oa      = fauedl_4uv4owrf & wvqj4nucriy;
wire itf3osb9s25rh5fr9x =  z6hh4dvj46bpyfc1ywl   & lkhqwv6_ybu4c1uwvzhknje5;
wire av7ih1gi478l8h      =  itf3osb9s25rh5fr9x & (|m7tdi1nlvyr3u0t8);
wire bvkzcf_0ft0n06      = (kxy7kxe1w3obs2oa ^ av7ih1gi478l8h) | ocdbgbm3lvpl6lq1b29_m | a5y5ks12503jc23p7;
wire [5-1:0] naf69hwtyfkur = (ocdbgbm3lvpl6lq1b29_m | a5y5ks12503jc23p7 ) ? 5'b0 : 
                                        kxy7kxe1w3obs2oa                      ?  m7tdi1nlvyr3u0t8 + {{5-1{1'b0}}, 1'b1} : m7tdi1nlvyr3u0t8 - {{5-1{1'b0}}, 1'b1};
ns_gnrl_dfflr #(5) dyux_tea4jvffgh56_mb(bvkzcf_0ft0n06, naf69hwtyfkur, m7tdi1nlvyr3u0t8, clk, rst_n);
localparam RSP_FIFO_DP_T = 32 - 1;
wire kvomvxyhty8fcdefj = ~(m7tdi1nlvyr3u0t8 == RSP_FIFO_DP_T[5-1:0]) & x3crvl9x92k8_2yeoph;
localparam FIFO_TOTAL_SIZE = 32 << 3;
localparam FIFO_OFFSET     = 1 << 3;
wire [9-1:0] obm7uz835tgq1qtlafenm4ow;
wire [9-1:0] xv2s59rhv3ozflrjow_prlcxrw = obm7uz835tgq1qtlafenm4ow + 9'd8;
wire                          xv1r7fwxjrupf49sexk13wnrtlb_ =   fauedl_4uv4owrf | itf3osb9s25rh5fr9x | a5y5ks12503jc23p7 | ocdbgbm3lvpl6lq1b29_m;
wire [9-1:0] mgw0mremhqo673om77m39ob9_p9z = ( a5y5ks12503jc23p7  | ocdbgbm3lvpl6lq1b29_m   ) ? FIFO_TOTAL_SIZE[9-1:0] :
                                                        ( fauedl_4uv4owrf & ~itf3osb9s25rh5fr9x) ? obm7uz835tgq1qtlafenm4ow - {{9-5{1'b0}},wsdf9_i1j633yx5xws} :
                                                        (~fauedl_4uv4owrf & itf3osb9s25rh5fr9x ) ? xv2s59rhv3ozflrjow_prlcxrw :
                                                        ( fauedl_4uv4owrf & itf3osb9s25rh5fr9x ) ? xv2s59rhv3ozflrjow_prlcxrw - {{9-5{1'b0}},wsdf9_i1j633yx5xws} :
                                                        obm7uz835tgq1qtlafenm4ow;
ns_gnrl_dfflr #(9) xvpb4h2dy2x3q98ci9wny46eze5i28(xv1r7fwxjrupf49sexk13wnrtlb_, mgw0mremhqo673om77m39ob9_p9z, obm7uz835tgq1qtlafenm4ow, clk, rst_n);
wire   nqpuvmhcc6uv7u8x0sxegx0 = ~((x4is0knduo_6ylb == 2'b01) & ((qw1yuqjgyuzjtt84xk + FIFO_OFFSET[8:0]) > {obm7uz835tgq1qtlafenm4ow}));
assign r_icb_cmd_valid  = (apkp_9vj9gtlwyy67l & kvomvxyhty8fcdefj & nqpuvmhcc6uv7u8x0sxegx0 & (~(eqewosindfku94gszs5 & dz9adtbr5uu2dkllocr))) 
                        | ((pw_szlqm1r_esywdyiw25c6 | p_syzz8a7r07vx_jeaeq7p) & eqewosindfku94gszs5);
assign r_icb_cmd_addr   = o21yf_gouiq5wzl2bh8;
assign r_icb_cmd_sel    = r_icb_cmd_valid;
assign r_icb_cmd_read   = 1'b1;
assign r_icb_cmd_size   = b89blt2973j_r5;
assign r_icb_cmd_xburst = ykbgh96za0a65;
assign r_icb_cmd_xlen   = s__nhdp8cj5yy00z;
assign r_icb_cmd_beat   = x4is0knduo_6ylb;
assign r_icb_cmd_lock   = 1'b0;
assign r_icb_cmd_excl   = 1'b0;
assign r_icb_cmd_modes  = 2'b0;
assign r_icb_cmd_dmode  = 1'b0;
assign r_icb_cmd_attri  = 3'b0;
assign r_icb_cmd_usr    = 1'b0;
assign r_icb_cmd_wdata  = 64'b0;
assign r_icb_cmd_wmask  = 8'b0;
wire w1ge3ohjyfudfv2_;
wire jqj_4y15c8th73ly4z4ow33hwkrvhd;
wire u6bpkokyxyaf;
wire n47ik_iqattz1b4i53z;
wire lrk1fa9jkcod1lg = w_icb_rsp_valid & w_icb_rsp_ready;
wire qh16un8cl0ntd0 = w_icb_cmd_valid & w_icb_cmd_ready;
wire             kv660knc56u4zk;
wire             ns3sh4kzvdsgj;
wire [32-1:0]   k3ohqo8g1lru0ngjmtbe;
wire  uhe8fzg6xhb   = (lo4u9vrsiiuwaw_i == 3'b000);
wire  uif9tvt9   = (lo4u9vrsiiuwaw_i == 3'b001);
wire  s842spfixad85   = (lo4u9vrsiiuwaw_i == 3'b010);
wire  ruram35_f  = (lo4u9vrsiiuwaw_i == 3'b011);
wire  deimztb9o  = (lo4u9vrsiiuwaw_i == 3'b100);
wire [2:0]    gkqezq5jman31r340e    =  uhe8fzg6xhb  ? 3'b0   :
                                   uif9tvt9  ? 3'b001 :
                                   s842spfixad85  ? 3'b010 :
                                   ruram35_f ? 3'b011 :            
                                   deimztb9o ? 3'b100 : 3'b0;    
wire [8:0]    hslqspjcm8xef7mtf    = (({1'b0, evjxuijiuvdxutls0} + 5'b1) << gkqezq5jman31r340e);
wire          mb9curi45rd49barqtd6df = (hslqspjcm8xef7mtf > qw1yuqjgyuzjtt84xk);
wire [4:0] xp_b0fz4rk1u_wq3  = 5'b10    - {4'b0, k3ohqo8g1lru0ngjmtbe[0]};
wire [4:0] egiq99vs2wqr7bpipd  = 5'b100   - {3'b0, k3ohqo8g1lru0ngjmtbe[1:0]};
wire [4:0] ridm4koebxiz6ei1b = 5'b1000  - {2'b0, k3ohqo8g1lru0ngjmtbe[2:0]};
wire [4:0] bkss51fn0ym2g_nyh_ = 5'b10000 - {1'b0, k3ohqo8g1lru0ngjmtbe[3:0]};
wire       domkn5hwkgwfd;
wire [19:0] epwtph3n5jakhcpm2mis;
wire [4:0] pc6692mzv7if0z_sy9u5m =  uhe8fzg6xhb  ? 5'b1 : 
                                uif9tvt9  ? xp_b0fz4rk1u_wq3 :
                                s842spfixad85  ? egiq99vs2wqr7bpipd :
                                ruram35_f ? ridm4koebxiz6ei1b :
                                bkss51fn0ym2g_nyh_;
wire [4:0] yo3rkipy_kp2i_cn7ddvb =  domkn5hwkgwfd ? epwtph3n5jakhcpm2mis[4:0] : pc6692mzv7if0z_sy9u5m;
wire [4:0] ixe2qvm1ubihy__x2zwadpqnb  = 5'b10    - {4'b0, lrayxp22g_5b0evm[0]};
wire [4:0] ustka7j6dpp1xhe_jle7n  = 5'b100   - {3'b0, lrayxp22g_5b0evm[1:0]};
wire [4:0] whm_4o451r603jd931tdbovwin = 5'b1000  - {2'b0, lrayxp22g_5b0evm[2:0]};
wire [4:0] emgmq9go3323pp49_1hms9tc_ = 5'b10000 - {1'b0, lrayxp22g_5b0evm[3:0]};
wire [4:0] h86dzpldi85lh2xumn8 =  uhe8fzg6xhb  ? 5'b1 : 
                                uif9tvt9  ? ixe2qvm1ubihy__x2zwadpqnb :
                                s842spfixad85  ? ustka7j6dpp1xhe_jle7n :
                                ruram35_f ? whm_4o451r603jd931tdbovwin :
                                emgmq9go3323pp49_1hms9tc_;
wire      b2dsljte9t0lypelz4n66ygff =   uif9tvt9 & lrayxp22g_5b0evm[0] 
                                 | s842spfixad85 & (|lrayxp22g_5b0evm[1:0])
                                 | ruram35_f & (|lrayxp22g_5b0evm[2:0])
                                 | deimztb9o & (|lrayxp22g_5b0evm[3:0]);
assign                 tn0ilkv6790qs3km5x6 = lrk1fa9jkcod1lg & w_icb_rsp_err;
wire                   hwl5q1ebwnv4gbp219xu;
wire [3:0]             xjkyktv8vtzyi6;
wire                   fmu1bp3up9g9dhk0wv_2e = |xjkyktv8vtzyi6;
wire                   ci3gikjsv1qfmyplarv14  = ~fmu1bp3up9g9dhk0wv_2e;
wire                   ixa_01souzdvfh75v;
wire                   ktrj8favmr_45z6xrrj07;
wire                   pi0f5tfxy4p4dv30wmch = ~dpj7aams0bftr8_gt & (tn0ilkv6790qs3km5x6 | (x3uvaw_0dh4rc0x4qe_z71 & ~eqewosindfku94gszs5 & u6bpkokyxyaf));
wire                   g2qw_5_obu4xmdjz6 = dpj7aams0bftr8_gt & ixa_01souzdvfh75v & ci3gikjsv1qfmyplarv14 & ~hwl5q1ebwnv4gbp219xu & ~w_icb_cmd_valid;
wire                   ae5jcg8eo7bf6w4igp9y = pi0f5tfxy4p4dv30wmch | g2qw_5_obu4xmdjz6;
wire                   vyeb5vacbdvvar0s3m = pi0f5tfxy4p4dv30wmch;
ns_gnrl_dfflr #(1) bcqyt1pkidzdqc4rxil(ae5jcg8eo7bf6w4igp9y, vyeb5vacbdvvar0s3m, dpj7aams0bftr8_gt, clk, rst_n);
ns_gnrl_dffr #(1) ef9pa7tmzw6fi775fqy225(dpj7aams0bftr8_gt, ktrj8favmr_45z6xrrj07, clk, rst_n);
assign                 ja7en2qmi559dx1u  = ~dpj7aams0bftr8_gt & ktrj8favmr_45z6xrrj07; 
wire kvbpetpw40fpnl_ = lkhqwv6_ybu4c1uwvzhknje5 & ~jqj_4y15c8th73ly4z4ow33hwkrvhd & ~u6bpkokyxyaf  
                   & (~(x3uvaw_0dh4rc0x4qe_z71 | eqewosindfku94gszs5 | k19xt5k0cxmajl6y))
                   & (~(tn0ilkv6790qs3km5x6 | dpj7aams0bftr8_gt | ja7en2qmi559dx1u));
wire nqlojsn28dzrw = kvbpetpw40fpnl_ & ~u6bpkokyxyaf;
wire tsn0vmlqk5u3_ny = em79o71ozbishg01g | (dpj7aams0bftr8_gt & ns3sh4kzvdsgj);
wire ti04x6j3um2507 = nqlojsn28dzrw | tsn0vmlqk5u3_ny;
wire vvnvfnidx4q7thy = nqlojsn28dzrw;
ns_gnrl_dfflr #(1) e_gh4jmia04xwltq42x(ti04x6j3um2507, vvnvfnidx4q7thy, u6bpkokyxyaf, clk, rst_n);
ns_gnrl_dffr #(1) fawfyxeyzaywr37dvtw_ (lkhqwv6_ybu4c1uwvzhknje5, jqj_4y15c8th73ly4z4ow33hwkrvhd, clk, rst_n);
wire            j309n1fnsz7gngbi3jzkl;
wire            dapbgj_9x7f239c3p061c9;
wire            trm34ergncmjunhjwr;
wire [19:0]     a6y3a37gzkxijr164r_sf9bhw;
wire            ykiox83ovw2qic9       = kvbpetpw40fpnl_ |  qh16un8cl0ntd0 ;
wire [64-1:0]  ao0ei0f9frltf_ny8;
wire zrjslo8bfzkfnssxpa0wrt             = kvbpetpw40fpnl_ | (lkhqwv6_ybu4c1uwvzhknje5 & j309n1fnsz7gngbi3jzkl & qh16un8cl0ntd0);
wire [64-1:0]  e9lsjbpa9vexfhg5i6s = af3jecg32ui6j99wlq5p84if;
ns_gnrl_dfflr #(64) hqsbhwmemotkr56xqz6k(zrjslo8bfzkfnssxpa0wrt, e9lsjbpa9vexfhg5i6s, ao0ei0f9frltf_ny8, clk, rst_n);
assign z6hh4dvj46bpyfc1ywl = zrjslo8bfzkfnssxpa0wrt;
wire [4:0]     tk566734mv56fxklbn6lr;
wire           hhb1nsyevd4qd3tb707y3     = (sw3w8sjqy25xms <= 20'd8);
assign         j309n1fnsz7gngbi3jzkl   = (tk566734mv56fxklbn6lr <= pc6692mzv7if0z_sy9u5m) & ~dapbgj_9x7f239c3p061c9;
wire           oyr_qaw_a8d3fv36rp12v2ht36na = (tk566734mv56fxklbn6lr <= pc6692mzv7if0z_sy9u5m) & dapbgj_9x7f239c3p061c9;
wire           c5h0w48dyjzzii5j2xg4oe  = (tk566734mv56fxklbn6lr >= pc6692mzv7if0z_sy9u5m);
wire           pp392nuyx4vk0feewuc      = (({1'b0, a6y3a37gzkxijr164r_sf9bhw[4:0]} +  {1'b0, tk566734mv56fxklbn6lr}) <= {1'b0, pc6692mzv7if0z_sy9u5m});
wire           vu9v8ugmjiplax0fjt2m290lrf = ykiox83ovw2qic9;
wire [4:0]     kwjgwapmmvhg20b20g7fjrlm1 = kvbpetpw40fpnl_ & hhb1nsyevd4qd3tb707y3                                                    ? a6y3a37gzkxijr164r_sf9bhw[4:0] :  
                                        kvbpetpw40fpnl_                                                                          ? 5'd8 :
                                        j309n1fnsz7gngbi3jzkl & trm34ergncmjunhjwr & pp392nuyx4vk0feewuc  & lkhqwv6_ybu4c1uwvzhknje5 ? 5'b0 :
                                        j309n1fnsz7gngbi3jzkl & trm34ergncmjunhjwr & ~pp392nuyx4vk0feewuc & lkhqwv6_ybu4c1uwvzhknje5 ? a6y3a37gzkxijr164r_sf9bhw[4:0] + tk566734mv56fxklbn6lr - pc6692mzv7if0z_sy9u5m :
                                        j309n1fnsz7gngbi3jzkl & lkhqwv6_ybu4c1uwvzhknje5                                        ? 5'd8 + tk566734mv56fxklbn6lr - pc6692mzv7if0z_sy9u5m : 
                                        oyr_qaw_a8d3fv36rp12v2ht36na                                                                ? 5'b0 :
                                        c5h0w48dyjzzii5j2xg4oe                                                                 ? tk566734mv56fxklbn6lr - pc6692mzv7if0z_sy9u5m : tk566734mv56fxklbn6lr;
ns_gnrl_dfflr #(5) ooji09mou5eqo6pqpne73h__bvu5(vu9v8ugmjiplax0fjt2m290lrf, kwjgwapmmvhg20b20g7fjrlm1, tk566734mv56fxklbn6lr, clk, rst_n);
wire           z2pmgp1nil56tw2          = gj_cq51nfvlp24v7t8 & g_3edn0acaqnnxnw_ky2h4;
wire           k4y3wmotuqbll58x_w           = z6hh4dvj46bpyfc1ywl & lkhqwv6_ybu4c1uwvzhknje5;
wire           bmj4ijsmzs4enj_xg25u6r4uu5 = a5y5ks12503jc23p7 | k4y3wmotuqbll58x_w;
wire [19:0]    amu_r6at9hyzob5oefziebhk = a5y5ks12503jc23p7 ? sw3w8sjqy25xms : a6y3a37gzkxijr164r_sf9bhw - 20'd8;
ns_gnrl_dfflr #(20) wvjjnxodpgrvem4d1a6buai2l57547(bmj4ijsmzs4enj_xg25u6r4uu5, amu_r6at9hyzob5oefziebhk, a6y3a37gzkxijr164r_sf9bhw, clk, rst_n);
wire [5:0]       n2e7kbjldmu5u5p3lc5z9hdm;
wire                        j4qqem5li5yfrn15lvq99_kuzfj = (z2pmgp1nil56tw2 ^ k4y3wmotuqbll58x_w) | ocdbgbm3lvpl6lq1b29_m;
wire [5:0]       cft5v_uz2hbf47ltjxtaiu3w1wd1m = ocdbgbm3lvpl6lq1b29_m ? {5+1{1'b0}} : 
                                                         z2pmgp1nil56tw2   ? n2e7kbjldmu5u5p3lc5z9hdm + {{5-1{1'b0}},1'b1} : n2e7kbjldmu5u5p3lc5z9hdm - {{5-1{1'b0}},1'b1};
ns_gnrl_dfflr #(5+1) d2qk6zy9o7opb0mdy56c6uelbm68(j4qqem5li5yfrn15lvq99_kuzfj, cft5v_uz2hbf47ltjxtaiu3w1wd1m, n2e7kbjldmu5u5p3lc5z9hdm, clk, rst_n);
wire [5+3:0]      fjiqaqxu0u4nlxsrv = n2e7kbjldmu5u5p3lc5z9hdm << 3;
wire [9:0]                  lp0o14o3basiuaz_l5bsm           = {{10-5-3-1{1'b0}},fjiqaqxu0u4nlxsrv} + {{10-5{1'b0}},tk566734mv56fxklbn6lr}; 
assign         trm34ergncmjunhjwr     = (a6y3a37gzkxijr164r_sf9bhw <= 20'd8);
wire           pfi33rgl93esh7r_zhxco = (trm34ergncmjunhjwr & (z6hh4dvj46bpyfc1ywl & lkhqwv6_ybu4c1uwvzhknje5)) 
                                   | ocdbgbm3lvpl6lq1b29_m; 
wire           lxm7zkh8mjg2ymxmals3g = (dapbgj_9x7f239c3p061c9 & em79o71ozbishg01g) | a5y5ks12503jc23p7;
wire           t0hrmle4eeapom7w8cc5_ = pfi33rgl93esh7r_zhxco | lxm7zkh8mjg2ymxmals3g;
wire           te16vmpgfgdwj_5prfjz6dat = pfi33rgl93esh7r_zhxco;
ns_gnrl_dfflrs #(1) vd9w4m9n16obrzf18ysb07pa_xmzk1y(t0hrmle4eeapom7w8cc5_, te16vmpgfgdwj_5prfjz6dat, dapbgj_9x7f239c3p061c9, clk, rst_n);
wire           gqvshfeju05t1mdw  = (~dapbgj_9x7f239c3p061c9 & lkhqwv6_ybu4c1uwvzhknje5) | c5h0w48dyjzzii5j2xg4oe | (dapbgj_9x7f239c3p061c9 & |tk566734mv56fxklbn6lr);
wire [8-1:0] qcany_6wgbpz;
genvar zyod33;
generate 
 for (zyod33=0;zyod33<8;zyod33=zyod33+1) begin: erskt8vdd87w7f3n
   assign qcany_6wgbpz[zyod33] = (yo3rkipy_kp2i_cn7ddvb > zyod33[4:0]);
 end
endgenerate 
wire [8-1:0]  kz3r8fqtqu5t9liuqo9hgk =   qcany_6wgbpz << k3ohqo8g1lru0ngjmtbe[3-1:0];
wire [4:0]     et3stlv317am5_n3um_jmed5e119;
wire           m5uhk1t1jdldau86ln968jjv5znn43c45  = pfi33rgl93esh7r_zhxco;
wire [4:0]     nstffu93im06457xkfgqlm6mus2lbvo = a6y3a37gzkxijr164r_sf9bhw[4:0];
ns_gnrl_dfflr #(5) bigim7jaf_uuqosd6r9c_nifnn7uy5s(m5uhk1t1jdldau86ln968jjv5znn43c45, nstffu93im06457xkfgqlm6mus2lbvo, et3stlv317am5_n3um_jmed5e119, clk, rst_n);
wire [7:0]     rfwowqkn4wj_a8i_gbvb2gmpvmdcsnywv = {(et3stlv317am5_n3um_jmed5e119-tk566734mv56fxklbn6lr), 3'b0};
wire [64-1:0] uj9ih900kfr9zcn0                     = (ao0ei0f9frltf_ny8 >> rfwowqkn4wj_a8i_gbvb2gmpvmdcsnywv) << {k3ohqo8g1lru0ngjmtbe[3-1:0],3'b0};
wire           explf6l5v532p6ou70s_bis  = (~c5h0w48dyjzzii5j2xg4oe & dapbgj_9x7f239c3p061c9) 
                                      | ((et3stlv317am5_n3um_jmed5e119>=tk566734mv56fxklbn6lr) & dapbgj_9x7f239c3p061c9); 
wire [64-1:0] w29wh9pfufdahrx7yo9wbo261 = (ao0ei0f9frltf_ny8 >> {{5'd8-tk566734mv56fxklbn6lr},3'b0}) << {k3ohqo8g1lru0ngjmtbe[3-1:0],3'b0};
wire [64-1:0] ailusnbg9s8zoex428ggm  = af3jecg32ui6j99wlq5p84if << {(k3ohqo8g1lru0ngjmtbe[3-1:0] + tk566734mv56fxklbn6lr), 3'b0};
wire [64-1:0] viyh0m67eiuw8m48            = explf6l5v532p6ou70s_bis   ? uj9ih900kfr9zcn0  :
                                        c5h0w48dyjzzii5j2xg4oe  ? w29wh9pfufdahrx7yo9wbo261 : (w29wh9pfufdahrx7yo9wbo261 | ailusnbg9s8zoex428ggm);
wire [3:0]     t9lqdic7wcrk = {4{uhe8fzg6xhb}} & 4'hf
                           | {4{uif9tvt9}} & 4'he
                           | {4{s842spfixad85}} & 4'hc
                           | {4{ruram35_f}} & 4'h8
                           | {4{deimztb9o}} & 4'h0
                           ;
wire           vjlfejl362cdcipxl      = ykiox83ovw2qic9;
wire           bgw7atq7vef4xdya7q_v83      = kvbpetpw40fpnl_;
wire [32-1:0] uxkhpp2wjb32_634dsr9_tdt7xa = uhe8fzg6xhb  ?  k3ohqo8g1lru0ngjmtbe + {{32-1{1'b0}}, 1'b1} : 
                                        uif9tvt9  ? {k3ohqo8g1lru0ngjmtbe[32-1:1], 1'b0} + {{32-2{1'b0}}, 2'b10} :
                                        s842spfixad85  ? {k3ohqo8g1lru0ngjmtbe[32-1:2], 2'b0} + {{32-3{1'b0}}, 3'b100} :
                                        ruram35_f ? {k3ohqo8g1lru0ngjmtbe[32-1:3], 3'b0} + {{32-4{1'b0}}, 4'b1000} :
                                        deimztb9o ? {k3ohqo8g1lru0ngjmtbe[32-1:4], 4'b0} + {{32-5{1'b0}}, 5'b10000} : k3ohqo8g1lru0ngjmtbe;
wire [32-1:0] ie1u0uwxvqy15infzrhi8ffivwd  = {{32-4{1'b1}},t9lqdic7wcrk} & lrayxp22g_5b0evm; 
wire [32-1:0] ebvl9ia0qts0lpo6u5_uu4tv1xy = bgw7atq7vef4xdya7q_v83 ? lrayxp22g_5b0evm : uxkhpp2wjb32_634dsr9_tdt7xa; 
wire [32-1:0] sd3w7z5iwdehr44hghvv       = a4cipiqt8vfgl23w2q ? ie1u0uwxvqy15infzrhi8ffivwd : ebvl9ia0qts0lpo6u5_uu4tv1xy;
ns_gnrl_dfflr #(32) wiatclk1li0uid02z__1(vjlfejl362cdcipxl, sd3w7z5iwdehr44hghvv, k3ohqo8g1lru0ngjmtbe, clk, rst_n);
wire [8-1:0] kq5sr4oxxrwo;
wire lfnp93h2efbjwexp    = qh16un8cl0ntd0;
wire zqev4tcq94llt8vbk    = lrk1fa9jkcod1lg;
wire fpd997d_7lans    = lfnp93h2efbjwexp ^ zqev4tcq94llt8vbk;
wire [8-1:0] ofi0dgxaozd2pp = lfnp93h2efbjwexp ? kq5sr4oxxrwo + {{8-1{1'b0}}, 1'b1} : kq5sr4oxxrwo - {{8-1{1'b0}}, 1'b1};
ns_gnrl_dfflr #(8) l8a84fpwze3inp5iqyl1(fpd997d_7lans, ofi0dgxaozd2pp, kq5sr4oxxrwo, clk, rst_n);
assign     ixa_01souzdvfh75v   = (kq5sr4oxxrwo == 8'b0);
wire        u0qmvvbmtt4l8sxjhshps = kvbpetpw40fpnl_  | qh16un8cl0ntd0;
wire [19:0] hjplqr2gmctppfxt_1b071u7 = kvbpetpw40fpnl_  ? sw3w8sjqy25xms :
                                  em79o71ozbishg01g ? 20'b0          : epwtph3n5jakhcpm2mis - {{20-5{1'b0}}, pc6692mzv7if0z_sy9u5m}; 
ns_gnrl_dfflr #(20) kq1tpk20i6_j6hjr01r3scrv(u0qmvvbmtt4l8sxjhshps, hjplqr2gmctppfxt_1b071u7, epwtph3n5jakhcpm2mis, clk, rst_n);
assign domkn5hwkgwfd     = (epwtph3n5jakhcpm2mis <= {{20-5{1'b0}}, pc6692mzv7if0z_sy9u5m});
assign em79o71ozbishg01g = qh16un8cl0ntd0 & domkn5hwkgwfd;
wire mtas_chhj24ue0h8q22   = n47ik_iqattz1b4i53z;
wire shx462rwy3b50h   = em79o71ozbishg01g | mtas_chhj24ue0h8q22;
wire sixi6s6o72ke9t8rd   = em79o71ozbishg01g;
ns_gnrl_dfflr #(1) wn7ramm1xv_nf2olb6ox(shx462rwy3b50h, sixi6s6o72ke9t8rd, w1ge3ohjyfudfv2_, clk, rst_n);
wire r665vyj5bauw6753b21n = w1ge3ohjyfudfv2_ & ixa_01souzdvfh75v & ~n47ik_iqattz1b4i53z & (~eqewosindfku94gszs5);
wire mqj7r95u0p4pqt0gi652x = n47ik_iqattz1b4i53z;
wire odea2tx9kkjhoxxmje6w = r665vyj5bauw6753b21n | mqj7r95u0p4pqt0gi652x;
wire dy5n0ei2fit9v7n1d4cv4 = r665vyj5bauw6753b21n;
ns_gnrl_dfflr #(1) zd04v9yy3hbc199o8asu9h5_mz(odea2tx9kkjhoxxmje6w, dy5n0ei2fit9v7n1d4cv4, n47ik_iqattz1b4i53z, clk, rst_n);
wire u1qqmojr69jnl48cujj    = (epwtph3n5jakhcpm2mis >= {{20-9{1'b0}},hslqspjcm8xef7mtf}); 
wire [10:0] p42zk06xve2ankj4bo_4zho = k3ohqo8g1lru0ngjmtbe[9:0] + {1'b0,hslqspjcm8xef7mtf};
wire        l5_4uabcuoobapb      = p42zk06xve2ankj4bo_4zho <= 11'h400;
wire       fu78uph2jx7mvz2knlup   = (fmu1bp3up9g9dhk0wv_2e | (u1qqmojr69jnl48cujj & l5_4uabcuoobapb & ci3gikjsv1qfmyplarv14 & ~mb9curi45rd49barqtd6df)) & qh16un8cl0ntd0;
wire [3:0] jtfwqxp3fz87iskeb   = (xjkyktv8vtzyi6 == evjxuijiuvdxutls0[3:0]) ? 4'b0 : (xjkyktv8vtzyi6 + 4'b1);
ns_gnrl_dfflr #(4) fbxlnjtzqwo2hl9oo5jzb(fu78uph2jx7mvz2knlup, jtfwqxp3fz87iskeb, xjkyktv8vtzyi6, clk, rst_n);
assign     kv660knc56u4zk       = |xjkyktv8vtzyi6;
assign     ns3sh4kzvdsgj      = ~kv660knc56u4zk;
wire       tr9wz0ke8w82i0d12si  = ((~(|xjkyktv8vtzyi6)) & ((~u1qqmojr69jnl48cujj) | (~l5_4uabcuoobapb))) | mb9curi45rd49barqtd6df;
wire [7:0] jc47627j9od2dg    = tr9wz0ke8w82i0d12si ? 8'b0 : evjxuijiuvdxutls0;
wire [1:0] o7acg6gzrx6sx    = ((evjxuijiuvdxutls0[3:0] == 4'b0) | mb9curi45rd49barqtd6df) ? 2'b0 : 
                             (   ((u6bpkokyxyaf & ~dpj7aams0bftr8_gt) | hwl5q1ebwnv4gbp219xu)  
                               & (xjkyktv8vtzyi6 == 4'b0) 
                               & u1qqmojr69jnl48cujj & l5_4uabcuoobapb  
                             )                                                      ? 2'b01 :
                             ((u6bpkokyxyaf | hwl5q1ebwnv4gbp219xu) & (xjkyktv8vtzyi6 == evjxuijiuvdxutls0[3:0])) ? 2'b10 : 2'b0;
wire       aut5tsm4q__dit_dnlp    = (o7acg6gzrx6sx == 2'b01);
wire       kywhllwaxw2xvsok519kmggq;
wire       o73n_anl6id4h5vg0iirwh6o = w_icb_cmd_valid & (~aut5tsm4q__dit_dnlp) & (~w_icb_cmd_ready) & (~kywhllwaxw2xvsok519kmggq);
wire       ffewv6mdish0zi20qonlnlvrk = kywhllwaxw2xvsok519kmggq & qh16un8cl0ntd0;
wire       n_65l9u32y7vjjc39urn5qr = o73n_anl6id4h5vg0iirwh6o | ffewv6mdish0zi20qonlnlvrk;
wire       sruyyi7f3cp_tjfelpj_o3iv4n = o73n_anl6id4h5vg0iirwh6o;
ns_gnrl_dfflr #(1) pa_9v9r0bgyjam36favsimb(n_65l9u32y7vjjc39urn5qr, sruyyi7f3cp_tjfelpj_o3iv4n, kywhllwaxw2xvsok519kmggq, clk, rst_n);
wire       p246v4l3_kk_zgp6s6zg = (w_icb_cmd_valid   & aut5tsm4q__dit_dnlp) & (~hwl5q1ebwnv4gbp219xu);
wire       h6r0_4q5qu0syfoqjam = (hwl5q1ebwnv4gbp219xu & (o7acg6gzrx6sx == 2'b10) & qh16un8cl0ntd0); 
wire       ijdvfelntfjrh7fvjqj8 = p246v4l3_kk_zgp6s6zg | h6r0_4q5qu0syfoqjam;
wire       guwpg6uu0fk6lz8d9wjjl6qm = p246v4l3_kk_zgp6s6zg;
ns_gnrl_dfflr #(1) dkpinujte_6n4zvk2bgwmtsq(ijdvfelntfjrh7fvjqj8, guwpg6uu0fk6lz8d9wjjl6qm, hwl5q1ebwnv4gbp219xu, clk, rst_n);
wire   zbnv5q73w1ncpdxfkrm7ij;
wire   y00scshch882z_r541u7ug = w_icb_cmd_valid & ~w_icb_cmd_ready & domkn5hwkgwfd; 
wire   pc4x6iezwa2xvosoa65vg9 = zbnv5q73w1ncpdxfkrm7ij & w_icb_cmd_ready; 
wire   lf5kt1cl9mc3pih9pni23bc = y00scshch882z_r541u7ug | pc4x6iezwa2xvosoa65vg9;
wire   u7_qe13n8yf71b18ftpri5j = y00scshch882z_r541u7ug;
ns_gnrl_dfflr #(1) x4_zi4_isnxnb5sidl3qtsx3ukpl(lf5kt1cl9mc3pih9pni23bc, u7_qe13n8yf71b18ftpri5j, zbnv5q73w1ncpdxfkrm7ij, clk, rst_n);
wire   t04rfmdbr201je2295g7y3ta = ~((o7acg6gzrx6sx == 2'b01) & ({{10-9{1'b0}},hslqspjcm8xef7mtf} > lp0o14o3basiuaz_l5bsm));
assign w_icb_cmd_valid  = (u6bpkokyxyaf & gqvshfeju05t1mdw & (t04rfmdbr201je2295g7y3ta | hwl5q1ebwnv4gbp219xu) & (~(dpj7aams0bftr8_gt & ns3sh4kzvdsgj))) 
                          | zbnv5q73w1ncpdxfkrm7ij
                          | (dpj7aams0bftr8_gt & (hwl5q1ebwnv4gbp219xu | kywhllwaxw2xvsok519kmggq));
assign w_icb_cmd_sel    = w_icb_cmd_valid;
assign w_icb_cmd_beat   = o7acg6gzrx6sx;
assign w_icb_cmd_wdata  = viyh0m67eiuw8m48;
assign w_icb_cmd_addr   = k3ohqo8g1lru0ngjmtbe;
assign w_icb_cmd_wmask  = kz3r8fqtqu5t9liuqo9hgk;
assign w_icb_cmd_size   = lo4u9vrsiiuwaw_i;
assign w_icb_cmd_xburst = mav2b956n9upxhd;
assign w_icb_cmd_xlen   = jc47627j9od2dg;
assign w_icb_cmd_read   = 1'b0;
assign w_icb_rsp_ready  = 1'b1;
assign w_icb_cmd_lock   = 1'b0;
assign w_icb_cmd_excl   = 1'b0;
assign w_icb_cmd_dmode  = 1'b0;
assign w_icb_cmd_modes  = 1'b0; 
assign w_icb_cmd_attri  = 3'b0;
assign w_icb_cmd_usr    = 1'b0;
wire          pfj8oj43rmov2487      = (xq4xkxuxnvv5nleuy0teinye_ == 2'b0);
wire          fv1r4vsd9g398r5u      = (xq4xkxuxnvv5nleuy0teinye_ == 2'b10);
wire          tmh9bwiydgqqfwqfhvu0fd  = (xq4xkxuxnvv5nleuy0teinye_ == 2'b01);
wire          cgg7s4cvzp2a2h;
wire [11:0]   b93lafel_49s4fefh; 
wire          w8d_mg5m5a2s90pqxih;
wire          p45chow_2jn_ojtoch    = (b93lafel_49s4fefh == 12'b1);
wire          nocj10sdhq3cnm1h    = a5y5ks12503jc23p7 & fv1r4vsd9g398r5u & (~w8d_mg5m5a2s90pqxih);
wire          k3tf7o8mq4ulubtocqtesto = nocj10sdhq3cnm1h;
wire          c5vwhzk3t5tt1ibp16v = w8d_mg5m5a2s90pqxih  & ((r665vyj5bauw6753b21n & p45chow_2jn_ojtoch) | cgg7s4cvzp2a2h);
wire          qdhzovpo61hqjhvzn0bqth0 = k3tf7o8mq4ulubtocqtesto | c5vwhzk3t5tt1ibp16v;
wire          c8g7u0qvb708urfdk53 = k3tf7o8mq4ulubtocqtesto;
ns_gnrl_dfflr #(1) sm37t3ae1bzd8_of28t0z4d(qdhzovpo61hqjhvzn0bqth0, c8g7u0qvb708urfdk53, w8d_mg5m5a2s90pqxih, clk, rst_n);
wire          mlhftv6rgx5kissa     = (nocj10sdhq3cnm1h | (fv1r4vsd9g398r5u & r665vyj5bauw6753b21n)); 
wire [11:0]   d4jh6wj85y4itt1     =  nocj10sdhq3cnm1h ? o__w7pqa1kuig71j[11:0] : (b93lafel_49s4fefh - 12'b1);
ns_gnrl_dfflr #(12) ug2q2m0xak4ltdz79oy31(mlhftv6rgx5kissa,d4jh6wj85y4itt1 , b93lafel_49s4fefh, clk, rst_n);
wire        nlj_pvipgh2maezjl1icwut = fv1r4vsd9g398r5u & p45chow_2jn_ojtoch;
wire          up61zabox8wk         = ~w8d_mg5m5a2s90pqxih | (w8d_mg5m5a2s90pqxih & (nlj_pvipgh2maezjl1icwut | ~c7d6yxol3op5wnbzajx5));
wire                   fj2u9ia08xr2e63c2d = (pfj8oj43rmov2487 | nlj_pvipgh2maezjl1icwut | u4nnwvgebl4n) & r665vyj5bauw6753b21n;
wire [1-1:0] fhmtmjma0ipdb5vc392x = tvebe4x5hyf4rq4xao & {1{fj2u9ia08xr2e63c2d}};
assign knu59jelp7r_6mrh8   = fhmtmjma0ipdb5vc392x | y5tywvjv5eqjp64vh4;
assign cgg7s4cvzp2a2h      = |knu59jelp7r_6mrh8;
wire  zr1o8u6w50nnnxr40tdghp9py;                                             
wire  aqgu51naf0wt_7dk7mwfx4_6 = (fv1r4vsd9g398r5u | tmh9bwiydgqqfwqfhvu0fd )     
                                 & (r665vyj5bauw6753b21n & ~dpj7aams0bftr8_gt)  
                                 & (~nlj_pvipgh2maezjl1icwut | ~u4nnwvgebl4n) 
                                 & (~cgg7s4cvzp2a2h)                       
                                 ;
wire o7p4r13yl9_jv6g4_mw16hipsrzi8 = zr1o8u6w50nnnxr40tdghp9py;
wire sssts6cvdzlqty7ocxyr2fryd = aqgu51naf0wt_7dk7mwfx4_6 | o7p4r13yl9_jv6g4_mw16hipsrzi8;
wire lmgztlmhziot59ve93f3jm3twia78 = aqgu51naf0wt_7dk7mwfx4_6;
ns_gnrl_dfflr #(1) u86os6ksgz95b0g4ab6gu40i0iaiop(sssts6cvdzlqty7ocxyr2fryd, lmgztlmhziot59ve93f3jm3twia78, zr1o8u6w50nnnxr40tdghp9py, clk, rst_n);
assign f3315t6qgqbmrxigde43kl1nii = zr1o8u6w50nnnxr40tdghp9py;
wire p9s7d19ld0twbw3yelq;
wire ciw8t4g0jhh_g06t5atgw  = cgg7s4cvzp2a2h | p9s7d19ld0twbw3yelq;
wire t_c50y_87x2x02fy0fe = cgg7s4cvzp2a2h;
ns_gnrl_dfflr #(1) mew2drdmq11_3dtsdizd9(ciw8t4g0jhh_g06t5atgw, t_c50y_87x2x02fy0fe, p9s7d19ld0twbw3yelq, clk, rst_n);
assign ukwgcam5ttjrtq   = p9s7d19ld0twbw3yelq;
assign      kc1xlwd9vchfsw52rhfpx_  = tvebe4x5hyf4rq4xao & {1{r665vyj5bauw6753b21n & up61zabox8wk}};
wire [19:0] vh89klvq_8tpfiij0f2       = {1'b0,sw3w8sjqy25xms[19:1]};
wire        uaiu1dfic1km3_u5s         = (epwtph3n5jakhcpm2mis <= vh89klvq_8tpfiij0f2);
wire        soetntfwrwcsy0_qzn1zx2; 
wire        denopy1y65ap__dwrhi8kt3gnis4 = uaiu1dfic1km3_u5s & u6bpkokyxyaf;
wire        bd3zqlfx9hqoc9ex15skch7v6 = em79o71ozbishg01g | cgg7s4cvzp2a2h;
wire        l0csgdw7pj7h39cvrmyzw2wu1c54 = denopy1y65ap__dwrhi8kt3gnis4 | bd3zqlfx9hqoc9ex15skch7v6;
wire        qf6mojhtoj_sim2shylc621 = denopy1y65ap__dwrhi8kt3gnis4 & (~bd3zqlfx9hqoc9ex15skch7v6);
ns_gnrl_dfflr #(1) ho1ur7o1fm1nn1gj4oi3f0hbtc7ps(l0csgdw7pj7h39cvrmyzw2wu1c54, qf6mojhtoj_sim2shylc621, soetntfwrwcsy0_qzn1zx2, clk, rst_n);
wire        y6zfcuece2uu6y1i61cw      = (u6bpkokyxyaf & uaiu1dfic1km3_u5s & (~soetntfwrwcsy0_qzn1zx2)) | (em79o71ozbishg01g & ~soetntfwrwcsy0_qzn1zx2);
wire        pvdiw9li83vs5vf8dpd51_;
wire        u1eeneg337vivoykk7_4kp406dd = ~pvdiw9li83vs5vf8dpd51_ & y6zfcuece2uu6y1i61cw; 
wire        qs1hzbhkbr4gv6sxeaemxqm = pvdiw9li83vs5vf8dpd51_;
wire        hmroknzfqbu8plvml0hjgcge = u1eeneg337vivoykk7_4kp406dd | qs1hzbhkbr4gv6sxeaemxqm;
wire        yyyw9g2fbn6eovwlpv1rmrk9d = u1eeneg337vivoykk7_4kp406dd;
ns_gnrl_dfflr #(1) mzhnfpjr_k1l6kn6lb44oy_v(hmroknzfqbu8plvml0hjgcge, yyyw9g2fbn6eovwlpv1rmrk9d, pvdiw9li83vs5vf8dpd51_, clk, rst_n);
assign     ox78nidpe47zivgp0nrpqyt    = tvebe4x5hyf4rq4xao & {1{pvdiw9li83vs5vf8dpd51_ & up61zabox8wk}};
assign     y5tywvjv5eqjp64vh4       = tvebe4x5hyf4rq4xao & {1{ocdbgbm3lvpl6lq1b29_m}};
assign      gk815iih0mdbmrmr4ve87m6h8 = tvebe4x5hyf4rq4xao & {1{qh16un8cl0ntd0}};
assign      yxhqzbe7znfwv40hgsm0m8        = hjplqr2gmctppfxt_1b071u7; 
assign      {udma_dbg0_o_oval, udma_dbg1_o_oval} = {apkp_9vj9gtlwyy67l, u6bpkokyxyaf};
endmodule
module hwishx8cewrzkxcaaanvw_lmqe (
  input              ri2ziyy, 
  input              r46kf,
  input              mkqjduogell,
  output [1-1:0]      j6furxzlr7mgpe,      
  output             ublor4qyxq5ex_0,
    input  [  31:   0] fy9k3hvw9j2kciq_hokh1se          ,
  input  [  31:   0] x3ehgam3t8xbcgg41q6ok9es          ,
  input              r_hgcvpe7hb0__mm3duv2          ,
  input  [   1:   0] ddwwphpikm_g4naro99batiag6        ,
  input  [   1:   0] sxig0khx0j6mezzzv7go3odsmhxe    ,
  input              o3oobxt0hlloxdxzz              ,
  input              s0i00yg7rudwmjnw6qgy6              ,
  input  [   2:   0] f0n31ctqfkhjoqcc30_yt94m           ,
  input  [   2:   0] fapxy9a3gthhsx_lmbyv           ,
  input  [   3:   0] zbvwjg44rpsrfg89ipy3wgsa           ,
  input  [   3:   0] yd1v7wrnjwnx6e1q1v53uv           ,
  input  [  11:   0] m5uruhml6olvgyr_n               ,
  input              ha7h094avs7utt4gw6easvi        ,
  input  [  19:   0] oh0zafhsm30zwva1sptj2qh6db        ,
  output [  31:   0] ya7naquyfxmwjad06d              ,
  output [  31:   0] snodaq6t4x3gctm2              ,
  output             ewphlfid8m3pl8igg              ,
  output [   1:   0] cqycg73b4lphg0tkorfyh            ,
  output             qh_ngonv0kt64n                  ,
  output             ash7_ox639dio6                  ,
  output [   2:   0] xzmdyzqyrja0vtbg2               ,
  output [   2:   0] ydx90dsfkk0d1z7               ,
  output [   3:   0] dqjbuqsw06fprxnifh               ,
  output [   3:   0] bayhz_in9eupl_gcydqh               ,
  output [  11:   0] nq52a9vl8nd7zna                   ,
  output             fmp05ivxtl15lotxxvko0k9            ,
  output [  19:   0] lg8mo7pemejac1jt_hyim            
);
wire [8-1:0]           uv9bq8hqbp63vjqmh_ad;
wire                   jt04lhgnbs5f28w = |uv9bq8hqbp63vjqmh_ad;
wire [1:0]             y40jrulr7ghgbjtk [8-1:0];
wire [32-1:0]         j8f4mj4kqfayinuox[1-1:0];
wire [32-1:0]         eqpqpdiii7w3o9d[1-1:0];
wire [1:0]             wai2azm9_svoaiiu0rx_x[1-1:0];
wire [1-1:0] ikzvc_cf4ciiyclxk;
wire [1-1:0] c6zu5xw2100b4hyeysx;
wire [2:0]             i4hvyc5t7q927g5v7ly1crq9[1-1:0];
wire [2:0]             fcje0iyo2892bk_aiwbz4m[1-1:0];
wire [3:0]             us00vqf36r82orfdgyyypnuj[1-1:0];
wire [3:0]             no5balobpb2u6tvcrqfi0wxy[1-1:0];
wire [11:0]            u2gjfvkp3jc79g74[1-1:0];
wire [1-1:0] mdxpcxgi9937jqqh4qq3xspp6y;
wire [19:0]            hzcozoob0wm2jzwy4[1-1:0];
wire [2:0]             xe9uvytyr033mb9rq1;
wire [2:0]             y_0ghi8vntnux1wk3;
wire [2:0]             b43kjww0a37ghn2nbpzer;
wire [2:0]             cuj58hk9x00j_zr75ums4;
wire [2:0]             llb6aiqao2_939mv4v;
wire [2:0]             ctrdi36732niw9v6ug;
wire [2:0]             a4wbtksj0j5iad61nh;
wire [1:0]             hhox92yhqxztb5l9u;
     assign y40jrulr7ghgbjtk[0]      = sxig0khx0j6mezzzv7go3odsmhxe; 
     assign uv9bq8hqbp63vjqmh_ad[0]    = r_hgcvpe7hb0__mm3duv2;
     assign j8f4mj4kqfayinuox[0]      = fy9k3hvw9j2kciq_hokh1se;
     assign eqpqpdiii7w3o9d[0]      = x3ehgam3t8xbcgg41q6ok9es;
     assign wai2azm9_svoaiiu0rx_x[0]    = ddwwphpikm_g4naro99batiag6;
     assign ikzvc_cf4ciiyclxk[0]    = o3oobxt0hlloxdxzz;
     assign c6zu5xw2100b4hyeysx[0]    = s0i00yg7rudwmjnw6qgy6;
     assign i4hvyc5t7q927g5v7ly1crq9[0] = f0n31ctqfkhjoqcc30_yt94m;
     assign fcje0iyo2892bk_aiwbz4m[0] = fapxy9a3gthhsx_lmbyv;
     assign us00vqf36r82orfdgyyypnuj[0] = zbvwjg44rpsrfg89ipy3wgsa;
     assign no5balobpb2u6tvcrqfi0wxy[0] = yd1v7wrnjwnx6e1q1v53uv;
     assign u2gjfvkp3jc79g74[0]     = m5uruhml6olvgyr_n;
     assign mdxpcxgi9937jqqh4qq3xspp6y[0] = ha7h094avs7utt4gw6easvi;
     assign hzcozoob0wm2jzwy4[0]    = oh0zafhsm30zwva1sptj2qh6db;
genvar t;
generate
   for(t=1;t<8;t=t+1) begin: qitgziwdhadnq
     assign y40jrulr7ghgbjtk[t] = 2'b0;
     assign uv9bq8hqbp63vjqmh_ad[t] = 1'b0;
   end
endgenerate 
      assign xe9uvytyr033mb9rq1 = 3'b000;
wire   ym8j9hu3mje0bbuyb4168n847esft;
wire   f25lzykoxoi8la2f_aecn6fubdpgja = ~ym8j9hu3mje0bbuyb4168n847esft & (~jt04lhgnbs5f28w);
wire   osehlds9rxq1rkl5saokpxxan878wk = jt04lhgnbs5f28w;
wire   kljryu79n4gj5u0nk5cz7_z5daax0l = f25lzykoxoi8la2f_aecn6fubdpgja | osehlds9rxq1rkl5saokpxxan878wk;
wire   auujno98f3z1_s8vsafvngo3mxk4h = f25lzykoxoi8la2f_aecn6fubdpgja;
ns_gnrl_dfflr #(1) vd0o07h4bgk4_lb1l1duqoepk5b66w(kljryu79n4gj5u0nk5cz7_z5daax0l, auujno98f3z1_s8vsafvngo3mxk4h, ym8j9hu3mje0bbuyb4168n847esft, ri2ziyy, r46kf);
wire [2:0] t6sluo7x6jrmvul20;
wire       m9ty3ci9ans4gdsc = mkqjduogell | (ym8j9hu3mje0bbuyb4168n847esft & jt04lhgnbs5f28w);
ns_gnrl_dfflr #(3) iacg0q4za73ukhl7y74ed3(m9ty3ci9ans4gdsc, xe9uvytyr033mb9rq1, t6sluo7x6jrmvul20, ri2ziyy, r46kf);
  reg    [ 32-1: 0] h43yi37qktccb6x2rf3jg6p          ;
  reg    [ 32-1: 0] w_f097vmwtf9hv0wua8lp6b1          ;
  reg                qk1p83shjaf464jkro6mpla9          ;
  reg    [   1:   0] pjopxyq__n251jedueiktdb3ua        ;
  reg                r9lxnh6_njr6owsb4cc              ;
  reg                gxbar8nrf1krtv797gj              ;
  reg    [   2:   0] qwf2ebk4p8labrykfpb           ;
  reg    [   2:   0] styxey4ed40cd4rs5o7wyro           ;
  reg    [   3:   0] fto4jlv1iqonsejzyan           ;
  reg    [   3:   0] tout64y2h3dvghj3ad_om           ;
  reg    [  11:   0] rena_satrlup40xt               ;
  reg                z29jiqg73hja5af89qlwls55xl        ;
  reg    [  19:   0] vh9sja6raa5_4765g350cyfox5r        ;
  assign ya7naquyfxmwjad06d              [  31:   0] = h43yi37qktccb6x2rf3jg6p          [  31:   0];
  assign snodaq6t4x3gctm2              [  31:   0] = w_f097vmwtf9hv0wua8lp6b1          [  31:   0];
  assign ewphlfid8m3pl8igg                          = qk1p83shjaf464jkro6mpla9                     ;
  assign cqycg73b4lphg0tkorfyh            [   1:   0] = pjopxyq__n251jedueiktdb3ua        [   1:   0];
  assign qh_ngonv0kt64n                              = r9lxnh6_njr6owsb4cc                         ;
  assign ash7_ox639dio6                              = gxbar8nrf1krtv797gj                         ;
  assign xzmdyzqyrja0vtbg2               [   2:   0] = qwf2ebk4p8labrykfpb           [   2:   0];
  assign ydx90dsfkk0d1z7               [   2:   0] = styxey4ed40cd4rs5o7wyro           [   2:   0];
  assign dqjbuqsw06fprxnifh               [   3:   0] = fto4jlv1iqonsejzyan           [   3:   0];
  assign bayhz_in9eupl_gcydqh               [   3:   0] = tout64y2h3dvghj3ad_om           [   3:   0];
  assign nq52a9vl8nd7zna                   [  11:   0] = rena_satrlup40xt               [  11:   0];
  assign fmp05ivxtl15lotxxvko0k9                        = z29jiqg73hja5af89qlwls55xl                   ;
  assign lg8mo7pemejac1jt_hyim            [  19:   0] = vh9sja6raa5_4765g350cyfox5r        [  19:   0];
reg [1-1:0] vf036rb31r1;
integer zyod33;
always @ * begin: a603r5bof6t
    h43yi37qktccb6x2rf3jg6p   = 32'b0;
    w_f097vmwtf9hv0wua8lp6b1   = 32'b0;
    qk1p83shjaf464jkro6mpla9   = 1'b0;
    pjopxyq__n251jedueiktdb3ua = 2'b0;
    r9lxnh6_njr6owsb4cc       = 1'b0;
    gxbar8nrf1krtv797gj       = 1'b0;
    qwf2ebk4p8labrykfpb    = 3'b0;
    styxey4ed40cd4rs5o7wyro    = 3'b0;
    fto4jlv1iqonsejzyan    = 4'b0;
    tout64y2h3dvghj3ad_om    = 4'b0;
    rena_satrlup40xt        = 12'b0;
    z29jiqg73hja5af89qlwls55xl = 1'b0;
    vh9sja6raa5_4765g350cyfox5r = 20'b0;
  for (zyod33=0;zyod33<1;zyod33=zyod33+1) begin: g5tihb_kgipyu
    vf036rb31r1[zyod33]             = (t6sluo7x6jrmvul20 == zyod33[2:0]);
    h43yi37qktccb6x2rf3jg6p   = h43yi37qktccb6x2rf3jg6p   | ({32{vf036rb31r1[zyod33]}} & j8f4mj4kqfayinuox[zyod33]);
    w_f097vmwtf9hv0wua8lp6b1   = w_f097vmwtf9hv0wua8lp6b1   | ({32{vf036rb31r1[zyod33]}} & eqpqpdiii7w3o9d[zyod33]);
    qk1p83shjaf464jkro6mpla9   = qk1p83shjaf464jkro6mpla9   | ({1{vf036rb31r1[zyod33]}}  & uv9bq8hqbp63vjqmh_ad[zyod33]);
    pjopxyq__n251jedueiktdb3ua = pjopxyq__n251jedueiktdb3ua | ({2{vf036rb31r1[zyod33]}}  & wai2azm9_svoaiiu0rx_x[zyod33]);
    r9lxnh6_njr6owsb4cc       = r9lxnh6_njr6owsb4cc       | (vf036rb31r1[zyod33]       & ikzvc_cf4ciiyclxk[zyod33]);
    gxbar8nrf1krtv797gj       = gxbar8nrf1krtv797gj       | (vf036rb31r1[zyod33]       & c6zu5xw2100b4hyeysx[zyod33]);
    qwf2ebk4p8labrykfpb    = qwf2ebk4p8labrykfpb    | ({3{vf036rb31r1[zyod33]}}  & i4hvyc5t7q927g5v7ly1crq9[zyod33]);
    styxey4ed40cd4rs5o7wyro    = styxey4ed40cd4rs5o7wyro    | ({3{vf036rb31r1[zyod33]}}  & fcje0iyo2892bk_aiwbz4m[zyod33]);
    fto4jlv1iqonsejzyan    = fto4jlv1iqonsejzyan    | ({4{vf036rb31r1[zyod33]}}  & us00vqf36r82orfdgyyypnuj[zyod33]);
    tout64y2h3dvghj3ad_om    = tout64y2h3dvghj3ad_om    | ({4{vf036rb31r1[zyod33]}}  & no5balobpb2u6tvcrqfi0wxy[zyod33]);
    rena_satrlup40xt        = rena_satrlup40xt        | ({12{vf036rb31r1[zyod33]}} & u2gjfvkp3jc79g74[zyod33]);
    z29jiqg73hja5af89qlwls55xl = z29jiqg73hja5af89qlwls55xl | (vf036rb31r1[zyod33]       & mdxpcxgi9937jqqh4qq3xspp6y[zyod33]);
    vh9sja6raa5_4765g350cyfox5r = vh9sja6raa5_4765g350cyfox5r | ({20{vf036rb31r1[zyod33]}} & hzcozoob0wm2jzwy4[zyod33]);
  end
end
assign ublor4qyxq5ex_0  = m9ty3ci9ans4gdsc;
assign j6furxzlr7mgpe = vf036rb31r1;
endmodule
module u5x6gcgot_v3i18ti (
input                    ri2ziyy, 
input                    r46kf,
input  [1-1:0] t90_ydzz6w_k_810k1,
input  [1-1:0] qz2d9g2owmwtv2,
output                   lc_2ssam_d14hcf_al9pjx,
input  [1-1:0] uasrgpwdame8ufsy43exru,
input  [1-1:0] p_xbfsuamfm7rmjw5vnnz,
input  [1-1:0] vxtf_xksqg5ers7k2xpy,
input                    orkaan781129v,
input  [1-1:0] oaqk4_dq0sifiewt7guwtqh_,
input  [19:0]            qi3mexr2jq1b3mycs9,
  output [  31:   0] fy9k3hvw9j2kciq_hokh1se          ,
  output [  31:   0] x3ehgam3t8xbcgg41q6ok9es          ,
  output             r_hgcvpe7hb0__mm3duv2          ,
  output [   1:   0] ddwwphpikm_g4naro99batiag6        ,
  output [   1:   0] sxig0khx0j6mezzzv7go3odsmhxe    ,
  output             o3oobxt0hlloxdxzz              ,
  output             s0i00yg7rudwmjnw6qgy6              ,
  output [   2:   0] f0n31ctqfkhjoqcc30_yt94m           ,
  output [   2:   0] fapxy9a3gthhsx_lmbyv           ,
  output [   3:   0] zbvwjg44rpsrfg89ipy3wgsa           ,
  output [   3:   0] yd1v7wrnjwnx6e1q1v53uv           ,
  output [  11:   0] m5uruhml6olvgyr_n               ,
  output             ha7h094avs7utt4gw6easvi        ,
  output [  19:   0] oh0zafhsm30zwva1sptj2qh6db        ,
  input              ja9ak7fyyg2tfwl6_hgy5         ,
  output             vp900_m_7rprfhce8q5pi568         ,
  input              dzxizqqy0rbu3zei3zb9gf0           ,
  input              j_x4s5ilt_v5lyv37_ciuof          ,
  input  [  11:   0] ehxcnr11cdzfbht6ma3oepq1x          ,
  input  [  31:   0] zmlm_u9dzbtemqbjtjpc8xkj0         ,
  input  [   3:   0] rv7fsnney3mld16o__f5rydqf         ,
  input  [   2:   0] f9y1mnh2uoyo7kpin0it          ,
  input              epqe_6dfa76a3jyi1_4cttuc          ,
  input              fo0jxfcjwjztsht4mh5h_1wbd          ,
  input  [   7:   0] z2g406o75oaub1wjw2907r6_          ,
  input  [   1:   0] wtemp15ccsjv6ibcisteaqehr        ,
  input  [   1:   0] p4uiqew43rhmn4ekhgo6f3         ,
  input              kppo97u8cpxhru_thlw0k         ,
  input  [   2:   0] r5wjevrqno2b5xyy10yluoui2         ,
  input  [   1:   0] c1v8jz0dl11fzqe3y2bijn          ,
  input              kwo00s6g_hjrbwgo43eib           ,
  input              siz0qp40uft869er5w85lw0u         ,
  output             hl4s82j47qcocdtd0f5l1         ,
  output             vnuvw3ym5_h10nvhmuwc_i           ,
  output             owdu_hbe9row3ro6y6f2nbngi       ,
  output [  31:   0] uuz4jzqdcev5s89r_2ckj6il         ,
  output             dvp1yi5mx24rqoqxerisih5           ,
output                   y9kex8e7h
);
  localparam x0qf5959shqi0asx         = 12'h000;
  localparam nwrb96y83nx1ca_g0      = 12'h004;
  localparam vrpuum4w6osqt738w6qzzw5uo   = 12'h008+12'h1C*12'h0;
  localparam amagexpqvz7pvezp6aw7h7fi7zare   = 12'h00c+12'h1C*12'h0;
  localparam n9wbqbc0ytgatehquyj0az53yk      = 12'h010+12'h1C*12'h0;
  localparam vzsb3ee8s8preqx2vzygbuew       = 12'h014+12'h1C*12'h0;
  localparam u8t5un7fbpserufcvr59ih3ycm      = 12'h018+12'h1C*12'h0;
  localparam p25stxpl5uhyfeshievqyfapzm     = 12'h800+12'hC*12'h0; 
  localparam f7ckw4amqegdy6c5_gngodc3tnt9   = 12'h804+12'hC*12'h0;
  localparam oh4rby6ddu0fn468re719bi_n    = 12'h808+12'hC*12'h0; 
  localparam khlk2_lealmde4bum_0b              = 12'hFFC;
wire [1-1:0] dmv_03c8fv7tt8f0tbgu;
wire [1-1:0] w89c0khhmksfop_3leo2;
wire [1-1:0] qclmkyp66ew3efp44fno96et;
wire [1-1:0] q7apaqpkyw7n8ayvx8mv4k;
assign                 lc_2ssam_d14hcf_al9pjx = |w89c0khhmksfop_3leo2;
wire [1-1:0] vvscvzdaoj508aqm; 
wire [1-1:0] z8d3i03sn2rx58h84trxm;
wire i1_c4od_d33ixg_adnonz08xuu    = ja9ak7fyyg2tfwl6_hgy5 & vp900_m_7rprfhce8q5pi568;
wire lc9vtuewgc8q4768eizyg_iz = i1_c4od_d33ixg_adnonz08xuu & ~j_x4s5ilt_v5lyv37_ciuof;
wire kfkuzmazn4ap96y5dugcstc9g8020 = i1_c4od_d33ixg_adnonz08xuu & j_x4s5ilt_v5lyv37_ciuof;
wire [11:0] zqj6ak_3ap6tngnbb4nr23r;
wire [11:0] aaur79tqm_ejs5bo9f6;  
assign aaur79tqm_ejs5bo9f6          = i1_c4od_d33ixg_adnonz08xuu ? ehxcnr11cdzfbht6ma3oepq1x : zqj6ak_3ap6tngnbb4nr23r;
ns_gnrl_dfflr #(12) hisep3ybmtucd159d11nt(i1_c4od_d33ixg_adnonz08xuu, ehxcnr11cdzfbht6ma3oepq1x, zqj6ak_3ap6tngnbb4nr23r , ri2ziyy, r46kf);
 wire xazntbhg3u_s6ucdt65jo      = (aaur79tqm_ejs5bo9f6[11:0] == vrpuum4w6osqt738w6qzzw5uo);
 wire ydwf9ikc_j__caud9rifgqxr      = (aaur79tqm_ejs5bo9f6[11:0] == amagexpqvz7pvezp6aw7h7fi7zare);
 wire e4l41htv533ofk_qfw_         = (aaur79tqm_ejs5bo9f6[11:0] == n9wbqbc0ytgatehquyj0az53yk);
 wire t5ky3a3d73e_amwh1vx          = (aaur79tqm_ejs5bo9f6[11:0] == vzsb3ee8s8preqx2vzygbuew);
 wire hian9149yjyuuhw9sm         = (aaur79tqm_ejs5bo9f6[11:0] == u8t5un7fbpserufcvr59ih3ycm);
 wire ot1ruiegldibj3xv1ine91        = (aaur79tqm_ejs5bo9f6[11:0] == p25stxpl5uhyfeshievqyfapzm);
 wire jdf66012hq64_gbjt986q      = (aaur79tqm_ejs5bo9f6[11:0] == f7ckw4amqegdy6c5_gngodc3tnt9);
 wire lqj99hdcd_rn9rnzmaixsp       = (aaur79tqm_ejs5bo9f6[11:0] == oh4rby6ddu0fn468re719bi_n);
 wire gojh_c47cfdos862fkr              = (aaur79tqm_ejs5bo9f6[11:0] == khlk2_lealmde4bum_0b);
wire [31:0]  r59xdejqywoajx9h2jro89d69;
wire         quieb3j5k1q049qwk3io6ea = lc9vtuewgc8q4768eizyg_iz & xazntbhg3u_s6ucdt65jo & vvscvzdaoj508aqm[0];
wire [31:0]  r4e8fdqjjqeyo3xjt8ie28dtq6m8a = zmlm_u9dzbtemqbjtjpc8xkj0;
ns_gnrl_dfflr #(32) zfubj1bwc9924njao9fp6m(quieb3j5k1q049qwk3io6ea, r4e8fdqjjqeyo3xjt8ie28dtq6m8a, r59xdejqywoajx9h2jro89d69, ri2ziyy, r46kf);
assign       fy9k3hvw9j2kciq_hokh1se = r59xdejqywoajx9h2jro89d69;
wire [31:0]  zh1kc47z_yd1sr9tq8og3c4et03;
wire         nurqhf2owsafnnypczl652b = lc9vtuewgc8q4768eizyg_iz & ydwf9ikc_j__caud9rifgqxr & vvscvzdaoj508aqm[0];
wire [31:0]  xi0qqzb8op9c4l5tri19letf1 = zmlm_u9dzbtemqbjtjpc8xkj0;
ns_gnrl_dfflr #(32) onvexquysgxavjdxi93g12xu(nurqhf2owsafnnypczl652b, xi0qqzb8op9c4l5tri19letf1, zh1kc47z_yd1sr9tq8og3c4et03, ri2ziyy, r46kf);
assign       x3ehgam3t8xbcgg41q6ok9es    = zh1kc47z_yd1sr9tq8og3c4et03;
assign       z8d3i03sn2rx58h84trxm[0]          = qz2d9g2owmwtv2[0] & r_hgcvpe7hb0__mm3duv2;
wire [31:0]  r58us9fywirgan3e0nycl;
wire [31:0]  ovwi5t8gi13c8n_c8zex09411_;
wire         j9sa7_h64gbv72wxklpv01y          =  lc9vtuewgc8q4768eizyg_iz  & e4l41htv533ofk_qfw_;
wire         i7eskuepdm7swdpljp50h4          =  j9sa7_h64gbv72wxklpv01y   & vvscvzdaoj508aqm[0];
wire         otpwh7b6_wb2brmjo00oj46h7xcrc1 =  j9sa7_h64gbv72wxklpv01y   | t90_ydzz6w_k_810k1[0];
assign       ovwi5t8gi13c8n_c8zex09411_[31:1]   =  zmlm_u9dzbtemqbjtjpc8xkj0[31:1];
assign       ovwi5t8gi13c8n_c8zex09411_[0]      = ((r58us9fywirgan3e0nycl[0] & (~vvscvzdaoj508aqm[0])) | (zmlm_u9dzbtemqbjtjpc8xkj0[0] & vvscvzdaoj508aqm[0])) & ~t90_ydzz6w_k_810k1[0];
ns_gnrl_dfflr #(4) z4k47cuczboo0muoh8oshbdc757(i7eskuepdm7swdpljp50h4, ovwi5t8gi13c8n_c8zex09411_[9:6], r58us9fywirgan3e0nycl[9:6], ri2ziyy, r46kf);
ns_gnrl_dfflr #(2) kfz96rxvgkn5fmt56816f8yrd3(i7eskuepdm7swdpljp50h4, ovwi5t8gi13c8n_c8zex09411_[13:12], r58us9fywirgan3e0nycl[13:12], ri2ziyy, r46kf);
ns_gnrl_dfflr #(3) zouf8h_f60dam6q66egy3b7009i9z(i7eskuepdm7swdpljp50h4, ovwi5t8gi13c8n_c8zex09411_[18:16], r58us9fywirgan3e0nycl[18:16], ri2ziyy, r46kf);
ns_gnrl_dfflr #(11) gi_w2ymjbx3t2ec328dcyqg2hc8i(i7eskuepdm7swdpljp50h4, ovwi5t8gi13c8n_c8zex09411_[31:21], r58us9fywirgan3e0nycl[31:21], ri2ziyy, r46kf);
ns_gnrl_dfflr #(1)  pbmuu0g9krq183ae4khrjiyh(otpwh7b6_wb2brmjo00oj46h7xcrc1, ovwi5t8gi13c8n_c8zex09411_[0], r58us9fywirgan3e0nycl[0], ri2ziyy, r46kf);
wire         hv8hy_wme0u97ate217mtmgql      = z8d3i03sn2rx58h84trxm[0];
assign       r_hgcvpe7hb0__mm3duv2        = r58us9fywirgan3e0nycl[0];
assign       ddwwphpikm_g4naro99batiag6      = r58us9fywirgan3e0nycl[7:6];
assign       sxig0khx0j6mezzzv7go3odsmhxe  = r58us9fywirgan3e0nycl[9:8];
assign       o3oobxt0hlloxdxzz            = r58us9fywirgan3e0nycl[12];
assign       s0i00yg7rudwmjnw6qgy6            = r58us9fywirgan3e0nycl[13];
assign       f0n31ctqfkhjoqcc30_yt94m         = r58us9fywirgan3e0nycl[18:16];
assign       fapxy9a3gthhsx_lmbyv         = r58us9fywirgan3e0nycl[23:21];
assign       zbvwjg44rpsrfg89ipy3wgsa         = r58us9fywirgan3e0nycl[27:24];
assign       r58us9fywirgan3e0nycl[1]      = hv8hy_wme0u97ate217mtmgql;
assign       yd1v7wrnjwnx6e1q1v53uv         = r58us9fywirgan3e0nycl[31:28];
assign       vvscvzdaoj508aqm[0]  = ~z8d3i03sn2rx58h84trxm[0];
assign      dmv_03c8fv7tt8f0tbgu[0] = ((ddwwphpikm_g4naro99batiag6 == 2'b10) | (ddwwphpikm_g4naro99batiag6 == 2'b01)) 
                                       & j9sa7_h64gbv72wxklpv01y
                                       & (~zmlm_u9dzbtemqbjtjpc8xkj0[0] & r_hgcvpe7hb0__mm3duv2)
                                       & qz2d9g2owmwtv2[0];
assign      qclmkyp66ew3efp44fno96et[0]  = dmv_03c8fv7tt8f0tbgu[0] | t90_ydzz6w_k_810k1[0];
assign      q7apaqpkyw7n8ayvx8mv4k[0] = dmv_03c8fv7tt8f0tbgu[0] & (~t90_ydzz6w_k_810k1[0]);
ns_gnrl_dfflr #(1) ma0k9q9xkrehp1pw1i(qclmkyp66ew3efp44fno96et[0], q7apaqpkyw7n8ayvx8mv4k[0], w89c0khhmksfop_3leo2[0], ri2ziyy, r46kf);
wire [11:0]  p0vs6lifdgy5a4zizievr88;
wire         k97srz6dukyuq0rrrraya_jjf1_u;
wire         wzkeshrwd_qeqxpw9ed   = lc9vtuewgc8q4768eizyg_iz & t5ky3a3d73e_amwh1vx & vvscvzdaoj508aqm[0];
wire [11:0]  x9clens575xva3hl0jral  = zmlm_u9dzbtemqbjtjpc8xkj0[11:0];
wire         u3czkxjyykheqm_ac7tuo24b1fh0  = zmlm_u9dzbtemqbjtjpc8xkj0[12];
ns_gnrl_dfflr #(12) v8os4bf29nmamdncxwyuh50(wzkeshrwd_qeqxpw9ed, x9clens575xva3hl0jral, p0vs6lifdgy5a4zizievr88, ri2ziyy, r46kf);
ns_gnrl_dfflr #(1) as2iy2ayk5jrreboiwc_0vfc1zc(wzkeshrwd_qeqxpw9ed, u3czkxjyykheqm_ac7tuo24b1fh0, k97srz6dukyuq0rrrraya_jjf1_u, ri2ziyy, r46kf);
assign       m5uruhml6olvgyr_n        = p0vs6lifdgy5a4zizievr88;
assign       ha7h094avs7utt4gw6easvi = k97srz6dukyuq0rrrraya_jjf1_u;
wire [19:0]  cu97shlu1r0njx7j7nvfiow;
wire [19:0]  izgm530b0bzvzxfnc6_ld2;
wire         cfs5ba3tj03mo1v2e7ddhh1b  = (lc9vtuewgc8q4768eizyg_iz & hian9149yjyuuhw9sm & vvscvzdaoj508aqm[0]);
wire         q0cwmg6y0rfiwtoz6xd05g5v     = cfs5ba3tj03mo1v2e7ddhh1b | oaqk4_dq0sifiewt7guwtqh_[0];
wire [19:0]  f2n8_yne2syr5sximqpjvnek = zmlm_u9dzbtemqbjtjpc8xkj0[19:0];
wire [19:0]  wtxk5d5yzdud2hviw5j5_    = oaqk4_dq0sifiewt7guwtqh_[0] ? qi3mexr2jq1b3mycs9 : zmlm_u9dzbtemqbjtjpc8xkj0[19:0];
ns_gnrl_dfflr #(20) bfs2a_z4n_hjlq4ukpinpv6(q0cwmg6y0rfiwtoz6xd05g5v, wtxk5d5yzdud2hviw5j5_, cu97shlu1r0njx7j7nvfiow, ri2ziyy, r46kf);
ns_gnrl_dfflr #(20) lkf3ux8i4p0fie92h9uty_xlkt(cfs5ba3tj03mo1v2e7ddhh1b, f2n8_yne2syr5sximqpjvnek, izgm530b0bzvzxfnc6_ld2, ri2ziyy, r46kf);
assign       oh0zafhsm30zwva1sptj2qh6db   = izgm530b0bzvzxfnc6_ld2;
wire [2:0]  tfn7f0hylwvjp4gwkp8db965m;
wire        gl2yzgus6wcnzs5e58cjl_h   = lc9vtuewgc8q4768eizyg_iz & ot1ruiegldibj3xv1ine91;
wire [2:0]  i5ivj7ymvj7ntjn5b9ipq0z  = zmlm_u9dzbtemqbjtjpc8xkj0[2:0];
ns_gnrl_dfflr #(3) in4vmponw3dtl4mdjqzrrrf8a(gl2yzgus6wcnzs5e58cjl_h, i5ivj7ymvj7ntjn5b9ipq0z, tfn7f0hylwvjp4gwkp8db965m, ri2ziyy, r46kf);
wire [2:0]  iy7vcrx7cx4gtqxkpx8mjo5i1;
assign      iy7vcrx7cx4gtqxkpx8mjo5i1[0] = lc9vtuewgc8q4768eizyg_iz & lqj99hdcd_rn9rnzmaixsp & zmlm_u9dzbtemqbjtjpc8xkj0[0];
assign      iy7vcrx7cx4gtqxkpx8mjo5i1[1] = lc9vtuewgc8q4768eizyg_iz & lqj99hdcd_rn9rnzmaixsp & zmlm_u9dzbtemqbjtjpc8xkj0[1];
assign      iy7vcrx7cx4gtqxkpx8mjo5i1[2] = lc9vtuewgc8q4768eizyg_iz & lqj99hdcd_rn9rnzmaixsp & zmlm_u9dzbtemqbjtjpc8xkj0[2];
wire [2:0]  f08xy5j__hf5r28og1yr36u;
wire        euwztkhd8b9ox1oj83b70q1k8j   = p_xbfsuamfm7rmjw5vnnz[0] | iy7vcrx7cx4gtqxkpx8mjo5i1[0];
wire        za1vwfiwg2fs9v5r_ek2gc_tqwvo   = uasrgpwdame8ufsy43exru[0] | iy7vcrx7cx4gtqxkpx8mjo5i1[1];
wire        k51q4v39wbn1jirf8j2wh7ioqcc   = vxtf_xksqg5ers7k2xpy[0]    | iy7vcrx7cx4gtqxkpx8mjo5i1[2];
wire [2:0]  rnxxuk6lnvz_kuahcur4du2zxpm0;
assign      rnxxuk6lnvz_kuahcur4du2zxpm0[0] = p_xbfsuamfm7rmjw5vnnz[0] & tfn7f0hylwvjp4gwkp8db965m[0]  & (~iy7vcrx7cx4gtqxkpx8mjo5i1[0]);
assign      rnxxuk6lnvz_kuahcur4du2zxpm0[1] = uasrgpwdame8ufsy43exru[0] & tfn7f0hylwvjp4gwkp8db965m[1]  & (~iy7vcrx7cx4gtqxkpx8mjo5i1[1]);
assign      rnxxuk6lnvz_kuahcur4du2zxpm0[2] = vxtf_xksqg5ers7k2xpy[0]    & tfn7f0hylwvjp4gwkp8db965m[2]  & (~iy7vcrx7cx4gtqxkpx8mjo5i1[2]);
ns_gnrl_dfflr #(1) mzqdvtk8srkfdx3dcn199msggxkul(euwztkhd8b9ox1oj83b70q1k8j, rnxxuk6lnvz_kuahcur4du2zxpm0[0], f08xy5j__hf5r28og1yr36u[0], ri2ziyy, r46kf);
ns_gnrl_dfflr #(1) wmcjsotk84axnlme9e79cfez4p4z7(za1vwfiwg2fs9v5r_ek2gc_tqwvo, rnxxuk6lnvz_kuahcur4du2zxpm0[1], f08xy5j__hf5r28og1yr36u[1], ri2ziyy, r46kf);
ns_gnrl_dfflr #(1) mh0dw4fg8wuy11uhhz_s23g26r(k51q4v39wbn1jirf8j2wh7ioqcc, rnxxuk6lnvz_kuahcur4du2zxpm0[2], f08xy5j__hf5r28og1yr36u[2], ri2ziyy, r46kf);
wire bj7medg09t3l = 1'b0
               | (|f08xy5j__hf5r28og1yr36u)
               ;
wire agjds2vrgb = 1'b0  
               ;
assign y9kex8e7h = 1'b0
               | bj7medg09t3l 
               ;
wire z6gmpm1ty14r9qv2m_2pbmtma5;
wire e7pynsm63ae47xw_1v1v619hitdrdl = i1_c4od_d33ixg_adnonz08xuu;
wire p8b_d171c8luvomw63az8vufwap = z6gmpm1ty14r9qv2m_2pbmtma5 & siz0qp40uft869er5w85lw0u;
wire p82n_myvtk1qxnir78r36ubh8eq0lm = e7pynsm63ae47xw_1v1v619hitdrdl | p8b_d171c8luvomw63az8vufwap;
wire p9lm2smrtmel_ntceibnir9u3bm = e7pynsm63ae47xw_1v1v619hitdrdl;
ns_gnrl_dfflr #(1) yehmbzsth_nxtvuhdsf5gzahfnh(p82n_myvtk1qxnir78r36ubh8eq0lm, p9lm2smrtmel_ntceibnir9u3bm, z6gmpm1ty14r9qv2m_2pbmtma5, ri2ziyy, r46kf);
assign hl4s82j47qcocdtd0f5l1   = z6gmpm1ty14r9qv2m_2pbmtma5;
assign uuz4jzqdcev5s89r_2ckj6il   = {32{1'b0}}
                               | {32{xazntbhg3u_s6ucdt65jo}} & r59xdejqywoajx9h2jro89d69
                               | {32{ydwf9ikc_j__caud9rifgqxr}} & zh1kc47z_yd1sr9tq8og3c4et03
                               | {32{e4l41htv533ofk_qfw_}} & {r58us9fywirgan3e0nycl[31:21],2'b0,r58us9fywirgan3e0nycl[18:16],2'b0,r58us9fywirgan3e0nycl[13:12],2'b0,r58us9fywirgan3e0nycl[9:6],4'b0,r58us9fywirgan3e0nycl[1:0]}
                               | {32{t5ky3a3d73e_amwh1vx}} & {19'b0,k97srz6dukyuq0rrrraya_jjf1_u, p0vs6lifdgy5a4zizievr88}
                               | {32{hian9149yjyuuhw9sm}} & {12'b0,cu97shlu1r0njx7j7nvfiow}
                               | {32{ot1ruiegldibj3xv1ine91}} & {29'b0,tfn7f0hylwvjp4gwkp8db965m}
                               | {32{jdf66012hq64_gbjt986q}} & {29'b0, f08xy5j__hf5r28og1yr36u}
                               | ({32{gojh_c47cfdos862fkr}} & 32'h0001_0303)
                               ;
assign owdu_hbe9row3ro6y6f2nbngi = 1'b0;
assign vnuvw3ym5_h10nvhmuwc_i     = 1'b0;
assign dvp1yi5mx24rqoqxerisih5     = 1'b0;
assign vp900_m_7rprfhce8q5pi568   = ~z6gmpm1ty14r9qv2m_2pbmtma5;
endmodule
module ns_gnrl_dfflrs # (
  parameter DW   = 32
, parameter [DW-1:0]  RST  = {DW{1'b1}}
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= RST;
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
endmodule
module ns_gnrl_dffl # (
  parameter DW   = 32
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
endmodule
module ns_gnrl_dfflr # (
  parameter DW   = 32
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else if (lden == 1'b1)
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
endmodule
module ns_gnrl_dffr # (
  parameter DW   = 32
) (
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input               clk,
  input               rst_n
);
reg [DW-1:0] mu8spjb6;
always @(posedge clk or negedge rst_n)
begin : y7qw238vym
  if (rst_n == 1'b0)
    mu8spjb6 <= {DW{1'b0}};
  else
    mu8spjb6 <= dnxt;
end
assign qout = mu8spjb6[DW-1:0];
endmodule
module ns_gnrl_fifo # (
  parameter CUT_READY = 0,
  parameter MSKO = 0,
  parameter REG_OUT = 0,
  parameter DP   = 8,
  parameter DW   = 32
) (
  input           i_vld, 
  output          i_rdy, 
  input  [DW-1:0] i_dat,
  output          o_vld, 
  input           o_rdy, 
  output [DW-1:0] o_dat,
  input           clk,
  input           rst_n
);
genvar zyod33;
generate 
  if(DP == 0) begin: qmqs20k9uyma
     assign o_vld = i_vld;
     assign i_rdy = o_rdy;
     assign o_dat = i_dat;
  end
  else begin: kfuzu1wzm87
    wire [DW-1:0] jyb_xrvmlkepac [DP-1:0];
    wire [DW-1:0] niyrz4zsknv [DP-1:0];
    wire [DP-1:0] rreodx8nr3a;
    wire xmzf = i_vld & i_rdy;
    wire u6lh = o_vld & o_rdy;
    wire [DP-1:0] b9mzd4qdyk38db; 
    wire [DP-1:0] jgpriggtm2y_fwywc; 
    wire [DP-1:0] ot40c525e9q7lz;
    wire [DP-1:0] ll6f8tv1_r2d1h; 
    wire [DP-1:0] rgpkcprjgc_w9a;
    if(DP == 1) begin:phzw717paedi9
      assign jgpriggtm2y_fwywc = 1'b1; 
    end
    else begin:oq0bb8qqlg1ftq9082tp
      assign jgpriggtm2y_fwywc = 
          ot40c525e9q7lz[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                          (ot40c525e9q7lz << 1);
   end
    if(DP == 1) begin:szvd_uo_t1rphsu
      assign ll6f8tv1_r2d1h = 1'b1; 
    end
    else begin:tvq5s2c1hmu7vnkviz0nn0
      assign ll6f8tv1_r2d1h =
          rgpkcprjgc_w9a[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                          (rgpkcprjgc_w9a << 1);
    end
ns_gnrl_dfflrs #(1)    ykwyawz_btbqa9homx3  (u6lh, jgpriggtm2y_fwywc[0]     , ot40c525e9q7lz[0]     , clk, rst_n);
ns_gnrl_dfflrs #(1)    c7pydzj7ovdygd4aj1  (xmzf, ll6f8tv1_r2d1h[0]     , rgpkcprjgc_w9a[0]     , clk, rst_n);
    if(DP > 1) begin:clkm1t5c1xs
ns_gnrl_dfflr  #(DP-1) a9egrdivdf59anpv72p4iu  (u6lh, jgpriggtm2y_fwywc[DP-1:1], ot40c525e9q7lz[DP-1:1], clk, rst_n);
ns_gnrl_dfflr  #(DP-1) lvg4hw2b7ocga7kwrt  (xmzf, ll6f8tv1_r2d1h[DP-1:1], rgpkcprjgc_w9a[DP-1:1], clk, rst_n);
    end
    assign b9mzd4qdyk38db = u6lh ? jgpriggtm2y_fwywc : ot40c525e9q7lz;
    wire [DP-1:0] oj7d_c;
    wire [DP-1:0] ygfrhv2;
    wire [DP-1:0] jtq949j67; 
    wire [DP-1:0] j5rme6;
    wire bb7bhv = (u6lh ^ xmzf );
ns_gnrl_dfflr  #(DP) hn3ax05gtnm     (bb7bhv, jtq949j67, j5rme6,     clk, rst_n);
    assign oj7d_c = j5rme6;
    assign ygfrhv2 = j5rme6;
    if(DP == 1) begin:foak_f95t2olcq
        assign jtq949j67 = xmzf ? 1'b1 : (j5rme6 >> 1);  
        if(CUT_READY == 1) begin:zx3zppx4bdss_l
          assign i_rdy = (~oj7d_c[DP-1]);
        end
        else begin:bnzuc64my8yotquyxmz
          assign i_rdy = (~oj7d_c[DP-1]) | u6lh;
        end
    end
    else begin : zyyv__9aqcfn__s
      assign jtq949j67 = xmzf ? {j5rme6[DP-2:0], 1'b1} : (j5rme6 >> 1);  
      assign i_rdy = (~oj7d_c[DP-1]);
    end
    for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:oe5rsotr0ghvfl
      assign rreodx8nr3a[zyod33] = xmzf & rgpkcprjgc_w9a[zyod33];
ns_gnrl_dffl  #(DW) dwpadh5cajhr0s (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
      assign jyb_xrvmlkepac[zyod33] = rreodx8nr3a[zyod33] ? i_dat : niyrz4zsknv[zyod33];
    end
    integer t;
    wire [DW-1:0] j45yhs2ojom0i;
    if(REG_OUT == 0) begin:ryi755vbqjpdrspl
    reg [DW-1:0] rvekbwm94_2g1;
        always @*
        begin : sosqjh1rrq34
          rvekbwm94_2g1 = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            rvekbwm94_2g1 = rvekbwm94_2g1 | ({DW{ot40c525e9q7lz[t]}} & niyrz4zsknv[t]);
          end
        end
    assign j45yhs2ojom0i = rvekbwm94_2g1;
    end
    else begin:hr23f8vxpi5ab_7q5yidy1
        reg [DW-1:0] md1jj1lh30i77nmk;
        always @*
        begin : sosqjh1rrq34
          md1jj1lh30i77nmk = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            md1jj1lh30i77nmk = md1jj1lh30i77nmk | ({DW{b9mzd4qdyk38db[t]}} & jyb_xrvmlkepac[t]);
          end
        end
        wire q_eosgs901ch = 
                     (~o_vld) ? xmzf :
                     (jtq949j67[0] & u6lh);
ns_gnrl_dfflr #(DW) mbjepxkxu4_ce92d7  (q_eosgs901ch, md1jj1lh30i77nmk, j45yhs2ojom0i, clk, rst_n);
    end
    if(MSKO == 1) begin:y_u3oxptq26c7xuc
        assign o_dat = {DW{o_vld}} & j45yhs2ojom0i;
    end
    else begin:obqti4sc53op0kcl0qe4
        assign o_dat = j45yhs2ojom0i;
    end
    assign o_vld = (ygfrhv2[0]);
  end
endgenerate
endmodule 
module ns_gnrl_fifo_wflg # (
  parameter CUT_READY = 0,
  parameter MSKO = 0,
  parameter REG_OUT = 0,
  parameter DP   = 8,
  parameter DP_PTR_W = 4,
  parameter DW   = 32
) (
  input           i_vld, 
  output          i_rdy, 
  input  [DW-1:0] i_dat,
  output          o_vld, 
  input           o_rdy, 
  output [DW-1:0] o_dat,
  output [DP-1:0]   intl_vec, 
  output reg [DP_PTR_W-1:0]   intl_vec_encode,
  input             cleanfifo, 
  input           clk,
  input           rst_n
);
genvar zyod33;
generate 
  if(DP == 0) begin: qmqs20k9uyma
     assign o_vld = i_vld;
     assign i_rdy = o_rdy;
     assign o_dat = i_dat;
  end
  else begin: kfuzu1wzm87
    wire [DW-1:0] jyb_xrvmlkepac [DP-1:0];
    wire [DW-1:0] niyrz4zsknv [DP-1:0];
    wire [DP-1:0] rreodx8nr3a;
    wire xmzf = i_vld & i_rdy | cleanfifo;
    wire u6lh = o_vld & o_rdy | cleanfifo;
    wire [DP-1:0] b9mzd4qdyk38db; 
    wire [DP-1:0] jgpriggtm2y_fwywc; 
    wire [DP-1:0] ot40c525e9q7lz;
    wire [DP-1:0] ll6f8tv1_r2d1h; 
    wire [DP-1:0] rgpkcprjgc_w9a;
    if(DP == 1) begin:phzw717paedi9
      assign jgpriggtm2y_fwywc = cleanfifo ? 1'b0 : 1'b1; 
    end
    else begin:oq0bb8qqlg1ftq9082tp
      assign jgpriggtm2y_fwywc = cleanfifo        ? {{DP-1{1'b0}}, 1'b1} :
                            ot40c525e9q7lz[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                                               (ot40c525e9q7lz << 1);
   end
    if(DP == 1) begin:szvd_uo_t1rphsu
      assign ll6f8tv1_r2d1h = cleanfifo ? 1'b0 : 1'b1; 
    end
    else begin:tvq5s2c1hmu7vnkviz0nn0
      assign ll6f8tv1_r2d1h = cleanfifo        ? {{DP-1{1'b0}}, 1'b1} :
                            rgpkcprjgc_w9a[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                                               (rgpkcprjgc_w9a << 1);
    end
ns_gnrl_dfflrs #(1)    ykwyawz_btbqa9homx3  (u6lh, jgpriggtm2y_fwywc[0]     , ot40c525e9q7lz[0]     , clk, rst_n);
ns_gnrl_dfflrs #(1)    c7pydzj7ovdygd4aj1  (xmzf, ll6f8tv1_r2d1h[0]     , rgpkcprjgc_w9a[0]     , clk, rst_n);
    if(DP > 1) begin:clkm1t5c1xs
ns_gnrl_dfflr  #(DP-1) a9egrdivdf59anpv72p4iu  (u6lh, jgpriggtm2y_fwywc[DP-1:1], ot40c525e9q7lz[DP-1:1], clk, rst_n);
ns_gnrl_dfflr  #(DP-1) lvg4hw2b7ocga7kwrt  (xmzf, ll6f8tv1_r2d1h[DP-1:1], rgpkcprjgc_w9a[DP-1:1], clk, rst_n);
    end
    assign b9mzd4qdyk38db = u6lh ? jgpriggtm2y_fwywc : ot40c525e9q7lz;
    wire [DP-1:0] oj7d_c;
    wire [DP-1:0] ygfrhv2;
    wire [DP-1:0] jtq949j67; 
    wire [DP-1:0] j5rme6;
    wire bb7bhv = (u6lh ^ xmzf ) | cleanfifo;
ns_gnrl_dfflr  #(DP) hn3ax05gtnm     (bb7bhv, jtq949j67, j5rme6,     clk, rst_n);
  wire [DP:0] xtkegwiuyp1327sqdyad = {j5rme6,1'b0};
  assign intl_vec = j5rme6;
  integer x;
  always @ (*) begin
    intl_vec_encode = {DP_PTR_W{1'b0}};
    for(x=1 ; x<=DP ; x=x+1) begin
      if(xtkegwiuyp1327sqdyad[x] == 1'b1)
        intl_vec_encode = x[DP_PTR_W-1:0];
      end
    end
    assign oj7d_c = j5rme6;
    assign ygfrhv2 = j5rme6;
    if(DP == 1) begin:foak_f95t2olcq
        assign jtq949j67 = cleanfifo ? 1'b0 : xmzf ? 1'b1 : (j5rme6 >> 1);  
        if(CUT_READY == 1) begin:zx3zppx4bdss_l
          assign i_rdy = (~oj7d_c[DP-1]);
        end
        else begin:bnzuc64my8yotquyxmz
          assign i_rdy = (~oj7d_c[DP-1]) | (u6lh & ~cleanfifo);
        end
    end
    else begin : zyyv__9aqcfn__s
      assign jtq949j67 = cleanfifo ? {DP{1'b0}} : xmzf ? {j5rme6[DP-2:0], 1'b1} : (j5rme6 >> 1);  
      assign i_rdy = (~oj7d_c[DP-1]);
    end
    for (zyod33=0; zyod33<DP; zyod33=zyod33+1) begin:oe5rsotr0ghvfl
      assign rreodx8nr3a[zyod33] = xmzf & rgpkcprjgc_w9a[zyod33];
ns_gnrl_dffl  #(DW) dwpadh5cajhr0s (rreodx8nr3a[zyod33], i_dat, niyrz4zsknv[zyod33], clk, rst_n);
      assign jyb_xrvmlkepac[zyod33] = rreodx8nr3a[zyod33] ? i_dat : niyrz4zsknv[zyod33];
    end
    integer t;
    wire [DW-1:0] j45yhs2ojom0i;
    if(REG_OUT == 0) begin:ryi755vbqjpdrspl
    reg [DW-1:0] rvekbwm94_2g1;
        always @*
        begin : sosqjh1rrq34
          rvekbwm94_2g1 = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            rvekbwm94_2g1 = rvekbwm94_2g1 | ({DW{ot40c525e9q7lz[t]}} & niyrz4zsknv[t]);
          end
        end
    assign j45yhs2ojom0i = rvekbwm94_2g1;
    end
    else begin:hr23f8vxpi5ab_7q5yidy1
        reg [DW-1:0] md1jj1lh30i77nmk;
        always @*
        begin : sosqjh1rrq34
          md1jj1lh30i77nmk = {DW{1'b0}};
          for(t=0; t<DP; t=t+1) begin
            md1jj1lh30i77nmk = md1jj1lh30i77nmk | ({DW{b9mzd4qdyk38db[t]}} & jyb_xrvmlkepac[t]);
          end
        end
        wire q_eosgs901ch = 
                     (~o_vld) ? xmzf :
                     (jtq949j67[0] & u6lh);
ns_gnrl_dfflr #(DW) mbjepxkxu4_ce92d7  (q_eosgs901ch, md1jj1lh30i77nmk, j45yhs2ojom0i, clk, rst_n);
    end
    if(MSKO == 1) begin:y_u3oxptq26c7xuc
        assign o_dat = {DW{o_vld}} & j45yhs2ojom0i;
    end
    else begin:obqti4sc53op0kcl0qe4
        assign o_dat = j45yhs2ojom0i;
    end
    assign o_vld = (ygfrhv2[0]);
  end
endgenerate
endmodule 
