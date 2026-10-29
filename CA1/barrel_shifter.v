module Barrel_shifter (
    input  [31:0] inp,
    input  [4:0]  shift_number,
    output [31:0] out
);
    assign out = (inp << shift_number) | (inp >> (32 - shift_number));
endmodule

module Step_array(
    input [5:0] i,
    output [4:0] step
);
    localparam [4:0] STEP [0:63] = '{
        // 0..15
        5'd7,  5'd12, 5'd17, 5'd22, 5'd7,  5'd12, 5'd17, 5'd22,
        5'd7,  5'd12, 5'd17, 5'd22, 5'd7,  5'd12, 5'd17, 5'd22,
        // 16..31
        5'd5,  5'd9,  5'd14, 5'd20, 5'd5,  5'd9,  5'd14, 5'd20,
        5'd5,  5'd9,  5'd14, 5'd20, 5'd5,  5'd9,  5'd14, 5'd20,
        // 32..47
        5'd4,  5'd11, 5'd16, 5'd23, 5'd4,  5'd11, 5'd16, 5'd23,
        5'd4,  5'd11, 5'd16, 5'd23, 5'd4,  5'd11, 5'd16, 5'd23,
        // 48..63
        5'd6,  5'd10, 5'd15, 5'd21, 5'd6,  5'd10, 5'd15, 5'd21,
        5'd6,  5'd10, 5'd15, 5'd21, 5'd6,  5'd10, 5'd15, 5'd21
    };

    assign step = STEP[i];
endmodule


module Left_rotate(input[31:0] inp,input[5:0] i, output[31:0] out);
    wire [4:0] step;
    Step_array my_step_array(i, step);
    Barrel_shifter my_barrel_shifter(inp, step, out);
endmodule
