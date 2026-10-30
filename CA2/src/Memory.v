module Memory #(
    parameter WORD_WIDTH = 34,
    parameter DEPTH = 128,
    parameter ADDR_WIDTH = 7,
    parameter MEM_FILE = "memory_pos.txt"
)(
    input  clk,
    input  rst,
    input  write,
    input  [ADDR_WIDTH-1:0] address,
    input  [WORD_WIDTH-1:0] write_data,
    output reg [WORD_WIDTH-1:0] r_data
);

    reg [WORD_WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        $readmemh(MEM_FILE, mem);
    end

    integer i;
    always @(posedge rst) begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] <= {WORD_WIDTH{1'b0}};
    end

    always @(posedge clk) begin
        if (write)
            mem[address] <= write_data;
    end

    assign r_data = mem[address];

endmodule
