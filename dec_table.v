// dec_table.v
// index by LOOKAHEAD bits -> {valid, symbol (8 bits), symbol_len (4 bits)}
`timescale 1ns/1ps
module dec_table #(
    parameter TABLE_SIZE = 4096, // 2^LOOKAHEAD
    parameter LOOKAHEAD = 12
)(
    input  wire [LOOKAHEAD-1:0] idx,
    output reg  valid,
    output reg  [7:0] symbol,
    output reg  [3:0] symbol_len
);
    reg [1+8+4-1:0] mem [0:TABLE_SIZE-1]; // {valid, symbol, symbol_len}
    initial begin
        $readmemh("dec_table.mem", mem);
    end

    always @(*) begin
        {valid, symbol, symbol_len} = mem[idx];
    end
endmodule
