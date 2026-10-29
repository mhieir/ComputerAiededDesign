module tb_StripsPE;

    parameter MP = 16;
    parameter N  = 4;    
    parameter W  = 16;

    reg clk;
    reg rst;
    reg i_is_msb;
    reg i_is_lsb;
    reg i_valid;
    reg signed [N*W-1:0] i_vec_b;
    reg [N-1:0] i_vec_a_bits;
    reg signed [(MP + W + $clog2(N))-1:0] initial_sum;

    wire signed[(MP + W + $clog2(N))-1:0] o_dot_product;

    StripsPE #(.MP(MP), .N(N), .W(W)) dut ((clk), (rst), (i_is_msb), (i_is_lsb), (i_valid), (i_vec_b), (i_vec_a_bits), (initial_sum), (o_dot_product));

    initial clk = 0;
    always #5 clk = ~clk;

    integer bit_index;


    reg [15:0] A0 = 16'd1;
    reg [15:0] A1 = -16'd4;
    reg [15:0] A2 = 16'd6;
    reg [15:0] A3 = 16'd3;

    reg signed[15:0] B0 = 16'd2;
    reg signed[15:0] B1 = 16'd6;
    reg signed[15:0] B2 = -16'd1;
    reg signed[15:0] B3 = 16'd7;

    initial begin
        i_vec_b = {B0, B1, B2, B3};

        rst = 1;
        i_valid = 0;
        i_is_msb = 0;
        i_is_lsb = 0;
        i_vec_a_bits = 0;
        initial_sum = 0;

        #20 rst = 0;

        for (bit_index = MP-1; bit_index >= 0; bit_index = bit_index - 1) begin
            @(posedge clk);
            i_valid <= 1;
            i_is_msb <= (bit_index == MP-1);
            i_is_lsb <= (bit_index == 0);

            i_vec_a_bits[0] <= A3[bit_index];
            i_vec_a_bits[1] <= A2[bit_index];
            i_vec_a_bits[2] <= A1[bit_index];
            i_vec_a_bits[3] <= A0[bit_index];
        end

        @(posedge clk);
        i_valid <= 0;
        i_is_msb <= 0;
        i_is_lsb <= 0;
        i_vec_a_bits <= 0;

        #50;
        $display("Expected Dot Product = -7");
        $display("Computed Dot Product = %d", o_dot_product);
        if (o_dot_product == -7)
            $display("Test PASSED");
        else
            $display("Test FAILED");
        $finish;
    end

endmodule