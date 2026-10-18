// huffman_decoder.v
`timescale 1ns/1ps
module huffman_decoder #(
    parameter LOOKAHEAD = 12,
    parameter TABLE_SIZE = (1<<LOOKAHEAD)
)(
    input wire clk,
    input wire rst,

    // input encoded byte stream
    input  wire in_valid,
    input  wire [7:0] in_byte,
    output reg  in_ready,

    // output decoded bytes
    output reg  out_valid,
    output reg  [7:0] out_byte,
    input  wire out_ready
);

    // instantiate decoder table
    wire valid;
    wire [7:0] symbol;
    wire [3:0] symbol_len;
    reg [LOOKAHEAD-1:0] look_idx;
    dec_table #(.TABLE_SIZE(TABLE_SIZE), .LOOKAHEAD(LOOKAHEAD)) dtable (
        .idx(look_idx),
        .valid(valid),
        .symbol(symbol),
        .symbol_len(symbol_len)
    );

    reg [63:0] bitbuf; // bits buffered (LSB-first)
    reg [6:0] bitcnt;

    always @(posedge clk) begin
        if (rst) begin
            bitbuf <= 0;
            bitcnt <= 0;
            out_valid <= 0;
            in_ready <= 1;
            out_byte <= 0;
            look_idx <= 0;
        end else begin
            // Accept incoming bytes when in_valid
            if (in_valid && in_ready) begin
                // append incoming byte to MSB-free side as LSB-first stream
                bitbuf <= bitbuf | ( {48'b0, in_byte} << bitcnt );
                bitcnt <= bitcnt + 8;
            end

            // prepare lookup index: use min(bitcnt, LOOKAHEAD) bits
            if (bitcnt >= LOOKAHEAD)
                look_idx <= bitbuf[LOOKAHEAD-1:0];
            else
                look_idx <= bitbuf[bitcnt-1:0]; // smaller index, table must handle padded zero

            // if table says valid and enough bits present
            if (valid && (bitcnt >= symbol_len)) begin
                // output symbol when downstream ready
                if (out_ready) begin
                    out_byte <= symbol;
                    out_valid <= 1;
                    // consume bits
                    bitbuf <= bitbuf >> symbol_len;
                    bitcnt <= bitcnt - symbol_len;
                end else begin
                    out_valid <= 0;
                end
            end else begin
                out_valid <= 0;
            end
        end
    end

endmodule
