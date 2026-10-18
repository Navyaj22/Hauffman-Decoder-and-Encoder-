`timescale 1ns/1ps
module code_rom #(
    parameter SYMBOLS = 256,
    parameter MAX_CODE_LEN = 16
)(
    input  wire [clog2(SYMBOLS)-1:0] addr,
    output reg  [MAX_CODE_LEN-1:0] code,
    output reg  [3:0] code_len
);
    // Verilog-2001 compatible clog2
    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = value - 1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    reg [MAX_CODE_LEN+3:0] mem [0:SYMBOLS-1];

    initial begin
        $readmemh("codes.mem", mem);
    end

    always @(*) begin
        {code, code_len} = mem[addr];
    end
endmodule
