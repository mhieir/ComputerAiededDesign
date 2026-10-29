module Rom_file #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 32,
    parameter ROM_FILE   = "constant.mem"
)(
    input [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] data
);

    reg [DATA_WIDTH-1:0] rom_mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
        $readmemh(ROM_FILE, rom_mem);
    end

    always @(*) begin
        data = rom_mem[addr];
    end

endmodule

