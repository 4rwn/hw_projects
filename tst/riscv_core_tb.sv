`timescale 1ns / 1ps

module riscv_core_tb;
    localparam INSTR_MEM_SIZE = 256;
    localparam DATA_MEM_SIZE = 1024;

    logic clk = 0;
    always #10 clk = ~clk;

    logic rst_n;

    // Read-only instruction memory
    logic [31:0] instr_rd_addr;
    logic [31:0] instr_rd_data;
    memory #(
        .SIZE(INSTR_MEM_SIZE)
    ) instr_mem (
        .clk(clk),

        .rd_addr(instr_rd_addr),
        .rd_data(instr_rd_data),

        .wr(2'b00),
        .wr_addr(0),
        .wr_data(0)
    );

    // Data memory
    logic [31:0] data_rd_addr;
    logic [31:0] data_rd_data;
    logic [1:0] data_wr;
    logic [31:0] data_wr_addr;
    logic [31:0] data_wr_data;
    memory #(
        .SIZE(DATA_MEM_SIZE)
    ) data_mem (
        .clk(clk),

        .rd_addr(data_rd_addr),
        .rd_data(data_rd_data),

        .wr(data_wr),
        .wr_addr(data_wr_addr),
        .wr_data(data_wr_data)
    );

    riscv_core dut ( 
        .clk(clk),
        .rst_n(rst_n),

        .instr_rd_addr(instr_rd_addr),
        .instr_rd_data(instr_rd_data),

        .data_rd_addr(data_rd_addr),
        .data_rd_data(data_rd_data),
        .data_wr(data_wr),
        .data_wr_addr(data_wr_addr),
        .data_wr_data(data_wr_data)
    );


    initial begin
        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, riscv_core_tb);
        
        $readmemh("sim/test.hex", instr_mem.mem);

        rst_n = 0;
        #50 rst_n = 1;

        #10000;
        $finish;
    end
endmodule