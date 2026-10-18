// top.v - example top connecting encoder -> decoder (loopback) for test/demo.
// For real hardware, connect encoder input to your source (UART, camera, DMA) and output to sink.
`timescale 1ns/1ps
module top(
    input wire clk,
    input wire rst,

    // Input stream for encoder (e.g., from UART RX)
    input  wire in_valid,
    input  wire [7:0] in_byte,
    output wire in_ready,

    // Output stream from decoder
    output wire out_valid,
    output wire [7:0] out_byte,
    input  wire out_ready
);

    wire enc_out_valid;
    wire [7:0] enc_out_byte;
    reg enc_out_ready = 1; // allow encoder to output

    huffman_encoder encoder (
        .clk(clk), .rst(rst),
        .in_valid(in_valid), .in_byte(in_byte), .in_ready(in_ready),
        .out_valid(enc_out_valid), .out_byte(enc_out_byte), .out_ready(enc_out_ready)
    );

    // Connect encoder output into decoder input
    // For a streaming setup you might need FIFOs to cross clock domains, etc.
    wire dec_in_valid = enc_out_valid;
    wire [7:0] dec_in_byte = enc_out_byte;

    huffman_decoder decoder (
        .clk(clk), .rst(rst),
        .in_valid(dec_in_valid), .in_byte(dec_in_byte), .in_ready(),
        .out_valid(out_valid), .out_byte(out_byte), .out_ready(out_ready)
    );

endmodule
