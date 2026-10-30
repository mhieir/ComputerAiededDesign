
module FDCP(
input clk , CLR, D, 
output reg Q);

    always @(posedge clk or posedge CLR)
        if(CLR)
        Q <= 0;
        else
        Q <= D;
endmodule


module s1(input D00 , D01 ,D10 , D11 , A1 , B1 , A0 , clr , clk , output out);
    initial begin 
    $system("s2-s1.exe ");
    end
    wire s0 , s1 ,d; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & clr ;
    assign d= ({s1,s0}== 2'd0)? D00: 
            ({s1,s0}==2'd1)? D01: 
            ({s1,s0}==2'd2)? D10: 
            ({s1,s0}==2'd3)? D11 :
                    2'bz;
    FDCP ff(clk , clr , d, out) ;

endmodule


module s2(input D00 , D01 ,D10 , D11 , A1 , B1 , A0,B0 , clr , clk , output out);
initial begin 
    $system("s2-s1.exe ");
    end
    wire s0 , s1 ,d; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & B0;
    assign d= ({s1,s0}== 2'd0)? D00: 
            ({s1,s0}==2'd1)? D01: 
            ({s1,s0}==2'd2)? D10: 
            ({s1,s0}==2'd3)? D11 :
                    2'bz;
    FDCP ff (clk , clr , d, out) ;     
endmodule


module c2 (input D00 , D01 ,D10 , D11 , A1 , B1 , A0 , B0 , output reg out);
    initial begin 
    $system("c2.exe ");
    end
    wire s0 , s1; 
    assign s1 = A1 | B1 ;
    assign s0 = A0 & B0 ;
    always @(*) begin
    case ({s1, s0})
        2'b00: out = D00;
        2'b01: out = D01;
        2'b10: out = D10;
        2'b11: out = D11;
        default: out = 1'b0;
    endcase
end

endmodule

