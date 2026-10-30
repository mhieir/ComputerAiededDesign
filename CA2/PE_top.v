module StripsPE #(
    parameter MP = 16,   
    parameter N  = 4,    
    parameter W  = 16 
)(
    input  clk,
    input  rst,
    input  i_is_msb,
    input  i_is_lsb,
    input  i_valid,
    input  signed [N*W-1:0] i_vec_b,
    input  [N-1:0] i_vec_a_bits,
    input  signed [(MP + W + $clog2(N))-1:0] initial_sum,
    output signed [(MP + W + $clog2(N))-1:0] o_dot_product
);

    localparam SUM_WIDTH  = W + $clog2(N);           
    localparam ACC_WIDTH  = MP + W + $clog2(N); 
    localparam SIGN_EXT_W = ACC_WIDTH - SUM_WIDTH;

    wire signed [W-1:0] mux_out [0:N-1];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : GEN_MUX
            MUX_2sel_3to1 #(.WIDTH(W)) mux_inst ((-i_vec_b[(N-1-i)*W +: W]), (i_vec_b[(N-1-i)*W +: W]), ({W{1'b0}}), (i_vec_a_bits[N-1-i]), (i_is_msb), (mux_out[i]));
        end
    endgenerate

    localparam LEVELS = $clog2(N);

    wire signed [W + 0:0] stage_0 [0:N-1];
    generate
        for (i = 0; i < N; i = i + 1)
            assign stage_0[i] = mux_out[i];
    endgenerate

    genvar lvl, j;
    generate
        for (lvl = 0; lvl < LEVELS; lvl = lvl + 1) begin : ADD_STAGE
            localparam CUR_W = W + lvl;
            localparam NUM_ELEM = N >> lvl;
            wire signed [CUR_W:0] stage [0:(NUM_ELEM>>1)-1];

            for (j = 0; j < (NUM_ELEM>>1); j = j + 1) begin : SUM_PAIR
                if (lvl == 0)
                    assign stage[j] = $signed(stage_0[2*j]) + $signed(stage_0[2*j+1]);
                else
                    assign stage[j] = $signed(ADD_STAGE[lvl-1].stage[2*j]) +
                                      $signed(ADD_STAGE[lvl-1].stage[2*j+1]);
            end
        end
    endgenerate

    wire signed [SUM_WIDTH-1:0] out_sum;
    assign out_sum = ADD_STAGE[LEVELS-1].stage[0];

    wire sign = out_sum[SUM_WIDTH-1];
    wire signed [ACC_WIDTH-1:0] out_acc, mux_out_acc;
    wire signed [ACC_WIDTH-1:0] out_final_sum;
    wire signed [ACC_WIDTH-1:0] out_init;

    MUX2to1 #(.WIDTH(ACC_WIDTH)) mux_lsb (({ACC_WIDTH{1'b0}}), (initial_sum), (i_is_lsb), (out_init));

    assign mux_out_acc = (i_is_msb ? {(ACC_WIDTH-1){1'b0}} : (out_acc <<< 1));

    Adder3Inp #(.WIDTH(ACC_WIDTH)) adder_acc ((mux_out_acc), ({{SIGN_EXT_W{sign}}, out_sum}), (out_init), (out_final_sum));

    Register #(.WIDTH(ACC_WIDTH)) acc_reg ((clk), (rst), (i_valid), (out_final_sum), (out_acc));

    assign o_dot_product = out_acc;

endmodule

