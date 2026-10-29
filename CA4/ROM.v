// module Rom_file #(
//     parameter ADDR_WIDTH = 6,
//     parameter DATA_WIDTH = 32,
//     parameter ROM_FILE   = "constant.mem"
// )(
//     input [ADDR_WIDTH-1:0] addr,
//     output reg  [DATA_WIDTH-1:0] data
// );

//     reg [DATA_WIDTH-1:0] rom_mem [0:(1<<ADDR_WIDTH)-1];

//     initial begin
//         $readmemh(ROM_FILE, rom_mem);
//     end

//     always @(*) begin
//         data = rom_mem[addr];
//     end

// endmodule

module Rom_file #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 32
)(
    input [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] data
);
    reg [DATA_WIDTH-1:0] rom_mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
        rom_mem[0]  = 'h78;
        rom_mem[1]  = 'h56;
        rom_mem[2]  = 'hdb;
        rom_mem[3]  = 'hee;
        rom_mem[4]  = 'haf;
        rom_mem[5]  = 'h2a;
        rom_mem[6]  = 'h13;
        rom_mem[7]  = 'h01;
        rom_mem[8]  = 'hd8;
        rom_mem[9]  = 'haf;
        rom_mem[10] = 'hb1;
        rom_mem[11] = 'hbe;
        rom_mem[12] = 'h22;
        rom_mem[13] = 'h93;
        rom_mem[14] = 'h8e;
        rom_mem[15] = 'h21;
        rom_mem[16] = 'h62;
        rom_mem[17] = 'h40;
        rom_mem[18] = 'h51;
        rom_mem[19] = 'haa;
        rom_mem[20] = 'h5d;
        rom_mem[21] = 'h53;
        rom_mem[22] = 'h81;
        rom_mem[23] = 'hc8;
        rom_mem[24] = 'he6;
        rom_mem[25] = 'hd6;
        rom_mem[26] = 'h87;
        rom_mem[27] = 'hed;
        rom_mem[28] = 'h05;
        rom_mem[29] = 'hf8;
        rom_mem[30] = 'hd9;
        rom_mem[31] = 'h8a;
        rom_mem[32] = 'h42;
        rom_mem[33] = 'h81;
        rom_mem[34] = 'h22;
        rom_mem[35] = 'h0c;
        rom_mem[36] = 'h44;
        rom_mem[37] = 'ha9;
        rom_mem[38] = 'h60;
        rom_mem[39] = 'h70;
        rom_mem[40] = 'hc6;
        rom_mem[41] = 'hfa;
        rom_mem[42] = 'h85;
        rom_mem[43] = 'h05;
        rom_mem[44] = 'h39;
        rom_mem[45] = 'he5;
        rom_mem[46] = 'hf8;
        rom_mem[47] = 'h65;
        rom_mem[48] = 'h44;
        rom_mem[49] = 'h97;
        rom_mem[50] = 'ha7;
        rom_mem[51] = 'h39;
        rom_mem[52] = 'hc3;
        rom_mem[53] = 'h92;
        rom_mem[54] = 'h7d;
        rom_mem[55] = 'hd1;
        rom_mem[56] = 'h4f;
        rom_mem[57] = 'he0;
        rom_mem[58] = 'h14;
        rom_mem[59] = 'ha1;
        rom_mem[60] = 'h82;
        rom_mem[61] = 'h35;
        rom_mem[62] = 'hbb;
        rom_mem[63] = 'h91;
    end

    always @(*) begin
        data = rom_mem[addr];
    end

endmodule