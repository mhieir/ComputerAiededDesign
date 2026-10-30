module DataPathMultiProc #(
    parameter WORD_WIDTH = 34,
    parameter MP = 16,
    parameter ADDR_WIDTH = 7,
    parameter W = 16
)(
    input clk,
    input rst,
    input en_decoder_a,
    input en_decoder_b,
    input en_ans,
    input iz_ans,
    output co_ans_2,
    input en_a,
    input iz_a,
    output co_a,
    input en_b,
    input iz_b,
    output co_b,
    input en_pe,
    input iz_pe,
    output co_pe,
    input [WORD_WIDTH-1:0] r_data,
    input shift_b,
    output [ADDR_WIDTH-1:0] address,
    input write,
    input i_is_lsb,
    input i_is_msb,
    input i_valid,
    output [(MP + W + 1):0] out_multiple
);


    wire [7:0] enable_a_registers, enable_b_registers;
    wire [W-1:0] vec_a_0_0, vec_a_0_1, vec_a_0_2, vec_a_0_3;
    wire [W-1:0] vec_a_1_0, vec_a_1_1, vec_a_1_2, vec_a_1_3;
    wire [3:0] vec_b_0, vec_b_1;
    wire [2:0] out_counter_ans, out_counter_a, out_counter_b ;
    
    wire [3:0] out_counter_pe;
    wire [4:0] pl_in_pe = 5'b10000 - MP;
    wire co_A_2, co_B_2, co_P_2, co_ans;
    Counter #(.WIDTH(3)) my_ans_counter(clk, rst, en_ans, iz_ans, 3'b000, out_counter_ans, co_ans, co_ans_2);
    Counter #(.WIDTH(3)) my_a_counter(clk, rst, en_a, iz_a, 3'b000, out_counter_a, co_a,co_A_2);
    Counter #(.WIDTH(3)) my_b_counter(clk, rst, en_b, iz_b, 3'b000, out_counter_b, co_b, co_B_2);
    Counter #(.WIDTH(4)) my_pe_counter(clk, rst, en_pe, iz_pe, pl_in_pe[3:0], out_counter_pe, co_pe, co_P_2);

    Decoder #(.N(3)) my_decoder_a(out_counter_a, en_decoder_a, enable_a_registers);
    Decoder #(.N(3)) my_decoder_b(out_counter_b, en_decoder_b, enable_b_registers);
    
    Register #(.WIDTH(W)) my_reg_a0(clk, rst, enable_a_registers[0], r_data[W-1:0], vec_a_0_0);
    Register #(.WIDTH(W)) my_reg_a1(clk, rst, enable_a_registers[1], r_data[W-1:0], vec_a_0_1);
    Register #(.WIDTH(W)) my_reg_a2(clk, rst, enable_a_registers[2], r_data[W-1:0], vec_a_0_2);
    Register #(.WIDTH(W)) my_reg_a3(clk, rst, enable_a_registers[3], r_data[W-1:0], vec_a_0_3);
    Register #(.WIDTH(W)) my_reg_a4(clk, rst, enable_a_registers[4], r_data[W-1:0], vec_a_1_0);
    Register #(.WIDTH(W)) my_reg_a5(clk, rst, enable_a_registers[5], r_data[W-1:0], vec_a_1_1);
    Register #(.WIDTH(W)) my_reg_a6(clk, rst, enable_a_registers[6], r_data[W-1:0], vec_a_1_2);
    Register #(.WIDTH(W)) my_reg_a7(clk, rst, enable_a_registers[7], r_data[W-1:0], vec_a_1_3);

    ShiftRegister #(.WIDTH(MP)) my_shift_reg_b0(clk, rst, shift_b, enable_b_registers[0], r_data[MP-1:0], vec_b_0[3]);
    ShiftRegister #(.WIDTH(MP)) my_shift_reg_b1(clk, rst, shift_b, enable_b_registers[1], r_data[MP-1:0], vec_b_0[2]);
    ShiftRegister #(.WIDTH(MP)) my_shift_reg_b2(clk, rst, shift_b, enable_b_registers[2], r_data[MP-1:0], vec_b_0[1]);
    ShiftRegister #(.WIDTH(MP)) my_shift_reg_b3(clk, rst, shift_b, enable_b_registers[3], r_data[MP-1:0], vec_b_0[0]);
    ShiftRegister #(.WIDTH(MP)) my_shift_reg_b4(clk, rst, shift_b, enable_b_registers[4], r_data[MP-1:0], vec_b_1[3]);
    ShiftRegister #(.WIDTH(MP)) my_shift_reg_b5(clk, rst, shift_b, enable_b_registers[5], r_data[MP-1:0], vec_b_1[2]);
    ShiftRegister #(.WIDTH(MP)) my_shift_reg_b6(clk, rst, shift_b, enable_b_registers[6], r_data[MP-1:0], vec_b_1[1]);
    ShiftRegister #(.WIDTH(MP)) my_shift_reg_b7(clk, rst, shift_b, enable_b_registers[7], r_data[MP-1:0], vec_b_1[0]);

    wire [ADDR_WIDTH-1:0] address_0, address_1;
    Adder2Inp #(.WIDTH(ADDR_WIDTH)) my_adder_address_0({4'b0000, out_counter_ans}, 7'b1001000, address_0);
    Adder2Inp #(.WIDTH(ADDR_WIDTH)) my_adder_address_1({1'b0, {out_counter_ans, out_counter_b}}, 7'b0001000, address_1);
    MUX_3sel_3to1 #(.WIDTH(ADDR_WIDTH)) my_mux_address(address_0, {4'b0000, out_counter_a}, address_1, write, en_a, en_b, address);

    wire [MP + W + 1:0] o_dot_product_0, o_dot_product_1;
    StripsPE #(.MP(MP), .N(4), .W(W)) my_pe_0(clk, rst, i_is_msb, i_is_lsb, i_valid, {vec_a_0_0, vec_a_0_1, vec_a_0_2, vec_a_0_3}, vec_b_0, {(MP+W+2){1'b0}}, o_dot_product_0);
    StripsPE #(.MP(MP), .N(4), .W(W)) my_pe_1(clk, rst, i_is_msb, i_is_lsb, i_valid, {vec_a_1_0, vec_a_1_1, vec_a_1_2, vec_a_1_3}, vec_b_1, {(MP+W+2){1'b0}}, o_dot_product_1);
    assign out_multiple = o_dot_product_0 + o_dot_product_1;

endmodule