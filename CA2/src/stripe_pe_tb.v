`timescale 1ns/1ps

module tb_StripsPE;

    // Parameters
    parameter MP = 16;

    // Inputs
    reg clk;
    reg rst;
    reg i_is_msb;
    reg i_is_lsb;
    reg i_valid;
    reg signed[63:0] i_vec_b;
    reg [3:0] i_vec_a_bits;
    reg signed[MP + 17:0] initial_sum;

    // Output
    wire signed[MP + 17:0] o_dot_product;

    // Instantiate DUT
    StripsPE #(.MP(MP)) dut (
        .clk(clk),
        .rst(rst),
        .i_is_msb(i_is_msb),
        .i_is_lsb(i_is_lsb),
        .i_valid(i_valid),
        .i_vec_b(i_vec_b),
        .i_vec_a_bits(i_vec_a_bits),
        .initial_sum(initial_sum),
        .o_dot_product(o_dot_product)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10 ns period

    // Local variables
    integer bit_index;

    // === Vector definitions (as in image) ===
    // A = (1, 3, 6, 2)
    reg [15:0] A0 = 16'd1;
    reg [15:0] A1 = 16'd3;
    reg [15:0] A2 = 16'd6;
    reg [15:0] A3 = 16'd2;

    // B = (3, 5, 5, 1)
    reg signed[15:0] B0 = 16'd3;
    reg signed[15:0] B1 = 16'd5;
    reg signed[15:0] B2 = 16'd5;
    reg signed[15:0] B3 = 16'd1;

    initial begin
        // Combine B into 64-bit parallel input
        // Order matches your module's expectation: {b0, b1, b2, b3}
        i_vec_b = {B0, B1, B2, B3};

        // Initialize
        rst = 1;
        i_valid = 0;
        i_is_msb = 0;
        i_is_lsb = 0;
        i_vec_a_bits = 0;
        initial_sum = 0;

        // Reset pulse
        #20 rst = 0;

        // === Feed A serially, MSB first ===
        for (bit_index = MP-1; bit_index >= 0; bit_index = bit_index - 1) begin
            @(posedge clk);
            i_valid <= 1;
            i_is_msb <= (bit_index == MP-1);
            i_is_lsb <= (bit_index == 0);

            // Extract one bit from each element of A at the same bit position
            i_vec_a_bits[0] <= A3[bit_index];
            i_vec_a_bits[1] <= A2[bit_index];
            i_vec_a_bits[2] <= A1[bit_index];
            i_vec_a_bits[3] <= A0[bit_index];
        end

        // === End of sequence ===
        @(posedge clk);
        i_valid <= 0;
        i_is_msb <= 0;
        i_is_lsb <= 0;
        i_vec_a_bits <= 0;

        // Wait a bit for final accumulation
        #50;
        $display("------------------------------------------------");
        $display("Expected Dot Product = 50");
        $display("Computed Dot Product = %d", o_dot_product);
        if (o_dot_product == 50)
            $display("✅ Test PASSED");
        else
            $display("❌ Test FAILED");
        $display("------------------------------------------------");
        $finish;
    end

endmodule