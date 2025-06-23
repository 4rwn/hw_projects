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

    string program_file, data_file;
    integer fd;
    initial begin
        if (!$value$plusargs("PROGRAM_FILE=%s", program_file)) begin
            $fatal(1, "Missing +PROGRAM_FILE=<program_file>");
        end
        $readmemh(program_file, instr_mem.mem);

        if ($value$plusargs("DATA_FILE=%s", data_file)) begin
            $readmemh(data_file, data_mem.mem);
        end

        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, riscv_core_tb);
        
        rst_n = 0;
        #50 rst_n = 1;

        #1000;
        if (dut.regs.regs[1] != 32'h00000001 ||
            dut.regs.regs[2] != 32'h00000000 ||
            dut.regs.regs[3] != 32'h000003e8 ||
            dut.regs.regs[4] != 32'hfffffc18) $error("Test failed.");

        // fd = $fopen("sim/memory_dump.txt", "w");
        // for (int i = 0; i < DATA_MEM_SIZE; i++) begin
        //     $fwrite(fd, "%02x\n", data_mem.mem[i]);
        // end
        // $fclose(fd);
        $finish;
    end
endmodule