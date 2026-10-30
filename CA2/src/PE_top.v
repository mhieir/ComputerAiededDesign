module StripsPE #(
    parameter MP = 16
)(
    input clk,
    input rst,
    input i_is_msb,
    input i_is_lsb,
    input i_valid,
    input signed[63:0] i_vec_b,
    input [3:0] i_vec_a_bits,
    input signed[MP + 17:0] initial_sum,
    output signed[MP + 17:0] o_dot_product
);

    wire signed[15:0] out_mux_0, out_mux_1, out_mux_2, out_mux_3;
    wire signed[17:0] out_sum;
    wire signed[MP + 17:0] out_acc, out_final_sum, out_init;
    MUX_2sel_3to1#(.WIDTH(16)) my_mux_0(-i_vec_b[63:48], i_vec_b[63:48], 16'b0, i_vec_a_bits[3], i_is_msb, out_mux_0);
    MUX_2sel_3to1#(.WIDTH(16)) my_mux_1(-i_vec_b[47:32], i_vec_b[47:32], 16'b0, i_vec_a_bits[2], i_is_msb, out_mux_1);
    MUX_2sel_3to1#(.WIDTH(16)) my_mux_2(-i_vec_b[31:16], i_vec_b[31:16], 16'b0, i_vec_a_bits[1], i_is_msb, out_mux_2);
    MUX_2sel_3to1#(.WIDTH(16)) my_mux_3(-i_vec_b[15:00], i_vec_b[15:0], 16'b0, i_vec_a_bits[0], i_is_msb, out_mux_3);
    Adder4Inp #(.WIDTH(16)) my_adder_1(out_mux_0, out_mux_1, out_mux_2, out_mux_3, out_sum);
    wire sign = out_sum[17];
    Adder3Inp #(.WIDTH(MP + 18)) my_adder_0(out_acc << 1, {{MP{sign}}, out_sum}, out_init, out_final_sum);
    MUX2to1 #(.WIDTH(MP + 18)) my_mux_lsb(34'b0, initial_sum, i_is_lsb, out_init);
    Register #(.WIDTH(MP + 18)) my_register(clk, rst, i_valid, out_final_sum, out_acc);
    assign o_dot_product = out_acc;

endmodule