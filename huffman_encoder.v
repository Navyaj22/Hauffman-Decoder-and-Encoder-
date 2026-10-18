// huffman_encoder.v
`timescale 1ns/1ps
module huffman_encoder #(
    parameter SYMBOLS = 256,
    parameter MAX_CODE_LEN = 16
)(
    input wire clk,
    input wire rst,

    // input byte stream (blocking handshake)
    input  wire in_valid,
    input  wire [7:0] in_byte,
    output reg  in_ready,

    // output byte stream (encoded bytes)
    output reg  out_valid,
    output reg  [7:0] out_byte,
    input  wire out_ready
);

    // instantiate code ROM
    wire [MAX_CODE_LEN-1:0] code;
    wire [3:0] code_len;
    code_rom #(.SYMBOLS(SYMBOLS), .MAX_CODE_LEN(MAX_CODE_LEN)) rom (
        .addr(in_byte),
        .code(code),
        .code_len(code_len)
    );

    reg [63:0] bitbuf; // buffer for bits (LSB-first)
    reg [6:0] bitcnt;  // number of bits currently in bitbuf

    // simple input handshake state
    always @(posedge clk) begin
        if (rst) begin
            bitbuf <= 0;
            bitcnt <= 0;
            in_ready <= 1;
            out_valid <= 0;
            out_byte <= 0;
        end else begin
            // accept input when in_valid and there's room (always room here)
            if (in_valid && in_ready) begin
                // append code bits into bitbuf at bitcnt LSB position
                // we assume code is MSB-first; but here we store LSB-first: we must align consistently.
                // We'll treat code[code_len-1:0] as a right-aligned bit sequence,
                // and append it to LSB side (least significant) of the buffer.
                bitbuf <= bitbuf | ( {48'b0, code} << bitcnt );
                bitcnt <= bitcnt + code_len;
            end

            // output bytes whenever there are >=8 bits and out_ready
            if (bitcnt >= 8 && out_ready) begin
                out_byte <= bitbuf[7:0];
                out_valid <= 1;
                // shift out
                bitbuf <= bitbuf >> 8;
                bitcnt <= bitcnt - 8;
            end else begin
                // lower out_valid when consumer not ready or not enough bits
                if (!(bitcnt >= 8 && out_ready))
                    out_valid <= 0;
            end
        end
    end

endmodule
