`timescale 1ns/1ps
module encoder_tb;
    reg clk = 0;
    reg rst = 1;
    always #5 clk = ~clk;

    reg in_valid = 0;
    reg [7:0] in_byte;
    wire in_ready;

    wire out_valid;
    wire [7:0] out_byte;
    reg out_ready = 1;

    huffman_encoder #(.SYMBOLS(256), .MAX_CODE_LEN(16)) encoder(
        .clk(clk), .rst(rst),
        .in_valid(in_valid), .in_byte(in_byte), .in_ready(in_ready),
        .out_valid(out_valid), .out_byte(out_byte), .out_ready(out_ready)
    );

    initial begin
        rst = 1;
        #20;
        rst = 0;

        // send bytes for "ABRACADABRA" (example)
        // set in_byte, pulse valid
        @(posedge clk);
        in_byte = "A"; in_valid = 1;
        @(posedge clk); in_valid = 0;

        repeat(2) @(posedge clk);
        in_byte = "B"; in_valid = 1;
        @(posedge clk); in_valid = 0;

        // more sends...
        #2000;
        $finish;
    end

    // monitor outputs
    always @(posedge clk) begin
        if (out_valid) $display("%0t: out_byte=0x%02h", $time, out_byte);
    end
endmodule
