module Register_1bit (clk, rst, Ld, in, out);

    input clk, rst, Ld;
    input in;
    output out;

    s2 my_register_1bit(.D00(out), .D01(in), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0), .A0(Ld), .B0(1'b1), .clr(rst), .clk(clk), .out(out));
endmodule

module Register
#(parameter WIDTH = 8)
(
    input clk,
    input rst,
    input Ld,
    input  [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_reg
            Register_1bit u_register_1bit (
                .clk (clk),
                .rst (rst),
                .Ld  (Ld),
                .in  (in[i]),
                .out (out[i])
            );
        end
    endgenerate

endmodule

module Register_Merged_MUX #(parameter WIDTH=8) (
    input clk, rst,
    input load,  
    input sel,       
    input [WIDTH-1:0] val_0, 
    input [WIDTH-1:0] val_1, 
    output [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_mg

            s2 s2_inst (
                .D00 (out[i]), 
                .D01 (val_0[i]), 
                .D10 (val_1[i]), 
                .D11 (val_1[i]),
                
                .A1  (sel),   .B1(1'b0),
                .A0  (load),  .B0(1'b1),
                
                .clr (rst),
                .clk (clk),
                .out (out[i])
            );
        end
    endgenerate
endmodule
