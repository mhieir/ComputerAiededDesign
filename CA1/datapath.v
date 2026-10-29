module Datapath_hash(input clk,rst,
                iz_i,en_i,
                sel_A,sel_B,sel_C,sel_D,
                load_A,load_B,load_C,load_D,
                sel_F,load_F,
                load_M,
                start_rnd,
                input[1:0] sel_sum0,sel_sum1,
                input load_sum,
                input[1:0] rnd,
                input[127:0] message,
                output co_i,
                output reg [127:0] digest,
                output [5:0] i);

        wire[31:0] inp_A, inp_B, inp_C, inp_D;
        wire[31:0] A, B, C, D;
        wire[31:0] out_sum;
        wire[31:0] inp_f0, inp_f1, inp_f2, inp_f3;
        wire[31:0] out_or_1, out_not_1, out_not_2, out_xor_3, out_and_1, out_and_2, out_and_3, out_and_4;
        wire[1:0] sel_i;
        wire[31:0] out_i;
        wire[31:0] constant_i;
        wire[31:0] left_rotate;
        wire[31:0] F;
        wire[31:0] inp_F;
        wire[127:0] M;
        wire[31:0] M_rnd;
        wire[31:0] inp_sum_0, inp_sum_1, inp_sum;

        localparam [31:0] a0 = 32'h67452301;
        localparam [31:0] b0 = 32'hefcdab89;
        localparam [31:0] c0 = 32'h98badcfe;
        localparam [31:0] d0 = 32'h10325476;

        Register #(.WIDTH(32)) my_reg_A(clk, rst, load_A, inp_A, A);
        Register #(.WIDTH(32)) my_reg_B(clk, rst, load_B, inp_B, B);
        Register #(.WIDTH(32)) my_reg_C(clk, rst, load_C, inp_C, C);
        Register #(.WIDTH(32)) my_reg_D(clk, rst, load_D, inp_D, D);

        MUX2to1 my_mux_A(a0, D, sel_A, inp_A);
        MUX2to1 my_mux_B(b0, out_sum, sel_B, inp_B);
        MUX2to1 my_mux_C(c0, B, sel_C, inp_C);
        MUX2to1 my_mux_D(d0, C, sel_D, inp_D);

        Xor #(.WIDTH(32)) my_xor_1(C, out_or_1, inp_f3);
        Not my_not_1(D, out_not_1);
        Or my_or_1(B, out_not_1, out_or_1);
        Xor #(.WIDTH(32)) my_xor_2(B, out_xor_3, inp_f2);
        Xor #(.WIDTH(32)) my_xor_3(C, D, out_xor_3);
        Or my_or_2(out_and_1, out_and_2, inp_f1);
        And my_and_1(out_not_1, C, out_and_1);
        And my_and_2(B, D, out_and_2);
        Not my_not_2(B, out_not_2);
        And my_and_3(C, B, out_and_3);
        And my_and_4(D, out_not_2, out_and_4);
        Or my_or_3(out_and_3, out_and_4, inp_f0);



        MUX4to1 my_mux_i(inp_f0, inp_f1, inp_f2, inp_f3, sel_i, out_i);
        wire co_i_s;
        Counter#(.WIDTH(6)) my_counter_i(clk, rst, en_i, iz_i, 6'd0, i, co_i_s,co_i);
        assign sel_i = i[5:4];
        Rom_file #(.ADDR_WIDTH(6), .DATA_WIDTH(32) , .ROM_FILE ("constant.mem")) my_constant_rom(i, constant_i);

        Left_rotate my_left_rotate(F, i, left_rotate);

        MUX2to1 my_mux_F(out_i, out_sum, sel_F, inp_F);

        Register#(.WIDTH(32)) my_reg_F(clk, rst, load_F, inp_F, F);

        Register#(.WIDTH(128)) my_reg_M(clk, rst, load_M, message, M);

        MUX4to1 my_mux_M(M[127:96], M[95:64], M[63:32], M[31:0], rnd, M_rnd);

        MUX4to1 my_mux_sum0(constant_i, M_rnd, B, A, sel_sum0, inp_sum_0);
        MUX3to1 my_mux_sum1(left_rotate, F, out_sum, sel_sum1, inp_sum_1);

        Adder my_adder(inp_sum_0, inp_sum_1, inp_sum);

        Register#(.WIDTH(32)) my_reg_Sum(clk, rst, load_sum, inp_sum, out_sum);

        assign digest = {A, B, C, D};


endmodule

module Datapath_rnd_gen(input clk,rst,
                        iz_c,en_c,
                        load_shift,en_shift,iz_shift,load_rnd,
                        input[5:0] inp_shift,
                        output co,
                        output[2:0] out_counter,
                        output[5:0] out_shift,
                        output [1:0] out_rnd);
        wire shift_input,out_xor_1bit_0;
        wire carry;
        Xor #(.WIDTH(1)) my_1bit_xor0(out_shift[5],out_shift[3],out_xor_1bit_0);
        Xor #(.WIDTH(1)) my_1bit_xor1(out_shift[1],out_xor_1bit_0,shift_input);

        Left_shift_register my_sh_reg(clk,rst,iz_shift,load_shift, en_shift, shift_input,inp_shift,out_shift);
        Register#(.WIDTH(2)) my_reg_rnd(clk, rst, load_rnd,out_shift[5:4] , out_rnd);
        Counter#(.WIDTH(3)) my_counter(clk,rst,en_c,iz_c,3'd2,out_counter,co,carry);
endmodule