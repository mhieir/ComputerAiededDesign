`timescale 1ns/1ps

module tb_Hash_Generator;

    reg clk;
    reg rst;
    reg start;
    reg [127:0] message;

    wire [127:0] digest;
    wire done;

    // DUT
    Hash_Generator uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .message(message),
        .digest(digest),
        .done(done)
    );

    // Clock: 100 MHz
    always #5 clk = ~clk;

    // integer i;

    // // Print the trace of each iteration (inside the hash datapath)
    // task print_iteration_trace;
    //     begin
    //         $display("\nHash Iteration Trace:");
    //         $display(" i  a_reg      b_reg      c_reg      d_reg      k          f          rnd   word       s    rot");
    //         $display("---------------------------------------------------------------------------------------------------------------");
    //         for (i = 0; i < 64; i = i + 1) begin
    //             $display("%2d  %08x   %08x   %08x   %08x   %08x   %08x   %1d     %08x   %2d   %08x",
    //                      i,
    //                      uut.my_hash.my_datapath_hash.A,
    //                      uut.my_hash.my_datapath_hash.B,
    //                      uut.my_hash.my_datapath_hash.C,
    //                      uut.my_hash.my_datapath_hash.D,
    //                      uut.my_hash.my_datapath_hash.constant_i,
    //                      uut.my_hash.my_datapath_hash.F,
    //                      uut.my_rnd_gen.rnd,
    //                      uut.my_hash.my_datapath_hash.M_rnd,
    //                      uut.my_hash.my_datapath_hash.my_left_rotate.step,
    //                      uut.my_hash.my_datapath_hash.left_rotate
    //             );
    //             @(posedge clk);
    //         end
    //     end
    // endtask

    initial begin
        clk = 0;
        rst = 1;
        start = 0;

        // Sample message
        message = 128'h41a801a8e81df62b14a661b85c97bf45;
        message = 128'h00000000000000000000000000000000;
        message = 128'haaaaaaaabbbbbbbbccccccccdddddddd;
        message = 128'h1109200100face009119110088cafe88;

        // Reset
        #20;
        rst = 0;

        // Start hash generation
        #10;
        start = 1;
        #10;
        start = 0;
	#50;
        start = 1;
        #10;
        start = 0;

        // Wait until hashing is done
        wait (done == 1);

        // Display message
        $display("\nMessage Value: %032x", message);

        // Print all 64 rounds of the hash iteration trace

        // Final digest
        $display("\nDigest: %032x\n", digest);

        #50;
        $finish;
    end

endmodule