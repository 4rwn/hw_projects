`timescale 1ns / 1ps

module riscv_core_tb;
    localparam DEPTH = 10;
    localparam SIZE = 1 << DEPTH;

    logic clk = 0;
    always #10 clk = ~clk;

    logic rst_n;

    riscv_core dut ( 
        .clk(clk),
        .rst_n(rst_n)
    );


    initial begin
        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, riscv_core_tb);
        
        $readmemh("sim/test.hex", dut.instr_mem.mem);

        rst_n = 0;
        #50 rst_n = 1;

        #1000;
        $finish;
    end
endmodule