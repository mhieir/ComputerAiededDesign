module Left_shift_register
#(parameter N = 6)
(
    input clk, rst,
    input iz,
    input en_shift,
    input shift_input, 
    input [N-1:0] pl,  
    input load_val,
    output [N-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_sh_reg
            
            s2 my_s2 (
                .D00 (out[i]),                     
                .D01 ( (i==0) ? shift_input : out[i-1] ),
                .D10 (pl[i]),                        
                .D11 (pl[i]),                      
                .A1  (load_val),                     
                .B1  (1'b0),
                .A0  (en_shift),                     
                .B0  (1'b1),
                .clr (rst),
                .clk (clk),
                .out (out[i])
            );
        end
    endgenerate
endmodule