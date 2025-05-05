`timescale 1ns / 1ps

module bitonic_sorter_tb;
    localparam DEPTH = 10;
    localparam SIZE = 1 << DEPTH;

    logic clk = 0;
    always #10 clk = ~clk;

    logic [SIZE-1:0][7:0] in;
    logic [SIZE-1:0][7:0] out;

    sorter #(
        .VALUE_BITS(8),
        .DEPTH(DEPTH),
        .DIRECTION(0)
    ) dut ( 
        .clk(clk),

        .in(in),
        .out(out)
    );

    logic [31:0] clk_cnt;
    always_ff @( posedge clk ) begin
        if (out[0] === 8'hxx) begin
            clk_cnt <= clk_cnt + 1;
        end
    end

    initial begin
        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, bitonic_sorter_tb);
        
        clk_cnt = 0;

        for (int i = 0; i < SIZE; i++) begin
            in[i] = $urandom_range(0, 255);
        end

        // in[0]  = 8'hD3;
        // in[1]  = 8'h7A;
        // in[2]  = 8'h42;
        // in[3]  = 8'hBE;
        // in[4]  = 8'h11;
        // in[5]  = 8'hC4;
        // in[6]  = 8'h6F;
        // in[7]  = 8'h95;
        // in[8]  = 8'hE2;
        // in[9]  = 8'h09;
        // in[10] = 8'h3C;
        // in[11] = 8'hF7;
        // in[12] = 8'h20;
        // in[13] = 8'hB9;
        // in[14] = 8'h88;
        // in[15] = 8'h0A;
        // in[16] = 8'hAE;
        // in[17] = 8'h5E;
        // in[18] = 8'h77;
        // in[19] = 8'h4B;
        // in[20] = 8'hC9;
        // in[21] = 8'h1D;
        // in[22] = 8'h60;
        // in[23] = 8'h02;
        // in[24] = 8'hFE;
        // in[25] = 8'hA3;
        // in[26] = 8'h34;
        // in[27] = 8'h1F;
        // in[28] = 8'h81;
        // in[29] = 8'h9C;
        // in[30] = 8'h6A;
        // in[31] = 8'h53;

        #10000;

        for (int i = 0; i < 10; i++) begin
            $display("%02h", out[SIZE-i-1]);
        end
        $display("...");
        for (int i = 10; i >= 0; i--) begin
            $display("%02h", out[i]);
        end

        $display("%d", clk_cnt);

        // assert(out == 256'hFEF7E2D3C9C4BEB9AEA39C9588817A776F6A605E534B423C34201F1D110A0902);
        $finish;
    end
endmodule