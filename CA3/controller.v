module Controller_hash (
    input clk, rst, start, co_i, done_rnd,
    output iz_i, sel_A, sel_B, sel_C, sel_D,
    output load_A, load_B, load_C, load_D, load_M,
    output sel_F, load_F, start_rnd, load_sum, en_i, done,
    output [1:0] sel_sum0, sel_sum1
);

    wire [11:0] ps;
    wire not_start, not_co_i, not_done_rnd;
   
    NOT_1bit inv1 (.a(start), .out(not_start));
    NOT_1bit inv2 (.a(co_i), .out(not_co_i));
    NOT_1bit inv3 (.a(done_rnd), .out(not_done_rnd));

    wire ps_0_bar;
    NOT_1bit fix_idle (.a(ps_0_bar), .out(ps[0]));

    s2 ff_idle_inv (
        .D00(ps_0_bar),
        .D01(1'b1),    
        .D10(1'b0),    
        .D11(1'b0),     
        .A1(ps[11]), .B1(1'b0),
        .A0(start),  .B0(1'b1),
        .clr(rst), .clk(clk), .out(ps_0_bar)
    );

    s2 ff_init (
        .D00(1'b0), .D01(1'b1), .D10(1'b0), .D11(1'b0),
        .A1(1'b0), .B1(1'b0),
        .A0(ps[0]), .B0(start), 
        .clr(rst), .clk(clk), .out(ps[1])
    );

    s2 ff_start_for (
        .D00(1'b0), .D01(1'b0), .D10(1'b1), .D11(1'b1),
        .A1(ps[1]), .B1(ps[10]), 
        .A0(1'b0), .B0(1'b0),
        .clr(rst), .clk(clk), .out(ps[2])
    );

    s2 ff_start_rnd (
        .D00(1'b0), .D01(1'b1), .D10(1'b0), .D11(1'b0),
        .A1(1'b0), .B1(1'b0),
        .A0(ps[2]), .B0(not_co_i), 
        .clr(rst), .clk(clk), .out(ps[3])
    );

    s2 ff_wait_rnd (
        .D00(1'b0), .D01(1'b1), .D10(1'b1), .D11(1'b1),
        .A1(ps[3]), .B1(1'b0),
        .A0(ps[4]), .B0(not_done_rnd),
        .clr(rst), .clk(clk), .out(ps[4])
    );

    s2 ff_sum0 (
        .D00(1'b0), .D01(1'b1), .D10(1'b0), .D11(1'b0),
        .A1(1'b0), .B1(1'b0),
        .A0(ps[4]), .B0(done_rnd),
        .clr(rst), .clk(clk), .out(ps[5])
    );

    s2 ff_sum1   (.D00(1'b0), .D01(1'b0), .D10(1'b1), .D11(1'b1), .A1(ps[5]), .B1(1'b0), .A0(1'b0), .B0(1'b0), .clr(rst), .clk(clk), .out(ps[6]));
    s2 ff_sum2   (.D00(1'b0), .D01(1'b0), .D10(1'b1), .D11(1'b1), .A1(ps[6]), .B1(1'b0), .A0(1'b0), .B0(1'b0), .clr(rst), .clk(clk), .out(ps[7]));
    s2 ff_sum3   (.D00(1'b0), .D01(1'b0), .D10(1'b1), .D11(1'b1), .A1(ps[7]), .B1(1'b0), .A0(1'b0), .B0(1'b0), .clr(rst), .clk(clk), .out(ps[8]));
    s2 ff_sum4   (.D00(1'b0), .D01(1'b0), .D10(1'b1), .D11(1'b1), .A1(ps[8]), .B1(1'b0), .A0(1'b0), .B0(1'b0), .clr(rst), .clk(clk), .out(ps[9]));
    s2 ff_end_for(.D00(1'b0), .D01(1'b0), .D10(1'b1), .D11(1'b1), .A1(ps[9]), .B1(1'b0), .A0(1'b0), .B0(1'b0), .clr(rst), .clk(clk), .out(ps[10]));

    s2 ff_done (
        .D00(1'b0), .D01(1'b1), .D10(1'b0), .D11(1'b0),
        .A1(1'b0), .B1(1'b0),
        .A0(ps[2]), .B0(co_i),
        .clr(rst), .clk(clk), .out(ps[11])
    );


    assign iz_i      = ps[1];
    assign load_M    = ps[1];
    assign sel_A     = ps[10];
    assign sel_B     = ps[10];
    assign sel_C     = ps[10];
    assign sel_D     = ps[10];
    assign en_i      = ps[10];
    assign start_rnd = ps[3];
    assign sel_F     = ps[8];
    assign done      = ps[11];
    assign sel_sum1[0] = ps[5];

    OR_2input or_loadA (.a(ps[1]), .b(ps[10]), .out(load_A));
    assign load_B = load_A;
    assign load_C = load_A;
    assign load_D = load_A;

    OR_2input or_loadF (.a(ps[3]), .b(ps[8]), .out(load_F));
    OR_4input or_loadSum (.a(ps[5]), .b(ps[6]), .c(ps[7]), .d(ps[9]), .out(load_sum));
    OR_2input or_sel0_1 (.a(ps[5]), .b(ps[9]), .out(sel_sum0[1]));
    OR_2input or_sel0_0 (.a(ps[5]), .b(ps[7]), .out(sel_sum0[0]));
    OR_2input or_sel1_1 (.a(ps[6]), .b(ps[7]), .out(sel_sum1[1]));

endmodule

module Controller_rnd_gen (
    input clk, rst, start_rnd, co,
    output iz_shift, load_shift, iz_c, en_c, en_shift, done_rnd, load_rnd
);

    wire [3:0] ps;
    wire not_start, not_co;

    NOT_1bit inv_start (.a(start_rnd), .out(not_start));
    NOT_1bit inv_co    (.a(co), .out(not_co));

    wire ps_0_bar;
    NOT_1bit fix_idle (.a(ps_0_bar), .out(ps[0]));

    s2 ff_idle_inv (
        .D00(ps_0_bar),
        .D01(1'b1),     
        .D10(1'b0),     
        .D11(1'b0),     
        .A1(ps[3]), .B1(1'b0),
        .A0(start_rnd), .B0(1'b1),
        .clr(rst), .clk(clk), .out(ps_0_bar)
    );

    s2 ff_init (
        .D00(1'b0), .D01(1'b1), .D10(1'b0), .D11(1'b0),
        .A1(1'b0), .B1(1'b0),
        .A0(ps[0]), .B0(start_rnd),
        .clr(rst), .clk(clk), .out(ps[1])
    );

    s2 ff_shifting (
        .D00(1'b0), .D01(1'b1), .D10(1'b1), .D11(1'b1),
        .A1(ps[1]), .B1(1'b0),      
        .A0(ps[2]), .B0(not_co),    
        .clr(rst), .clk(clk), .out(ps[2])
    );

    s2 ff_done (
        .D00(1'b0), .D01(1'b1), .D10(1'b0), .D11(1'b0),
        .A1(1'b0), .B1(1'b0),
        .A0(ps[2]), .B0(co),        
        .clr(rst), .clk(clk), .out(ps[3])
    );

    assign iz_shift   = ps[0];
    assign load_shift = ps[1];
    assign iz_c       = ps[1];
    assign en_c       = ps[2];
    assign en_shift   = ps[2];
    assign done_rnd   = ps[3];
    assign load_rnd   = ps[3];

endmodule
