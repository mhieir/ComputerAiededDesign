module Left_shift_register(input clk,rst,iz,load,en_shift,shift_input,input[5:0] pl, output reg[5:0] out);
    always@(posedge clk, posedge rst) begin
        if(rst) out <= 6'b0;
        else if(iz) out <= pl;
        else if (en_shift) out <= {out[4:0], shift_input};
        else out <= out;
    end
endmodule