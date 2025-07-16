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

    logic halt;
    riscv_core dut (
        .clk(clk),
        .rst_n(rst_n),

        .instr_rd_addr(instr_rd_addr),
        .instr_rd_data(instr_rd_data),

        .data_rd_addr(data_rd_addr),
        .data_rd_data(data_rd_data),
        .data_wr(data_wr),
        .data_wr_addr(data_wr_addr),
        .data_wr_data(data_wr_data),

        .halt(halt)
    );

    string program_file, data_file, expected_file;
    integer fd;
    integer passed;
    initial begin
        // Read instruction machine code
        if (!$value$plusargs("PROGRAM_FILE=%s", program_file)) begin
            $fatal(1, "Missing +PROGRAM_FILE=<program_file>");
        end
        $readmemh(program_file, instr_mem.mem);

        // Read initial data memory content, if present
        if ($value$plusargs("DATA_FILE=%s", data_file)) begin
            $readmemh(data_file, data_mem.mem);
        end

        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, riscv_core_tb);
        
        // Reset
        rst_n = 0;
        #50 rst_n = 1;

        // Control transfer signals termination
        passed = 0;
        while (!halt && passed++ < 1000000) #1;
        if (passed >= 1000000) $error("Execution timed out.");

        // Compare register and data memory state to expected, if given
        if ($value$plusargs("EXPECTED=%s", expected_file)) begin
            logic [7:0] expected_data [DATA_MEM_SIZE+32*4-1:0];
            $readmemh(expected_file, expected_data);

            // Compare registers
            for (int i = 0; i < 32; i++) begin
                logic [31:0] expected_reg;
                expected_reg[7:0] = expected_data[i*4];
                expected_reg[15:8] = expected_data[i*4+1];
                expected_reg[23:16] = expected_data[i*4+2];
                expected_reg[31:24] = expected_data[i*4+3];

                if (^expected_reg !== 1'bx && dut.regs.regs[i] !== expected_reg) begin
                    $error("Register[%0d] mismatch: expected 0x%08h, got 0x%08h",
                        i, expected_reg, dut.regs.regs[i]);
                end
            end

            // Compare data memory
            for (int i = 0; i < DATA_MEM_SIZE; i++) begin
                if (^expected_data[i+32*4] !== 1'bx && data_mem.mem[i] !== expected_data[i+32*4]) begin
                    $error("Memory[0x%08h] mismatch: expected 0x%02h, got 0x%02h",
                        i, expected_data[i+32*4], data_mem.mem[i]);
                end
            end
        end

        // Dump data memory
        // fd = $fopen("sim/memory_dump.txt", "w");
        // for (int i = 0; i < DATA_MEM_SIZE; i++) begin
        //     $fwrite(fd, "%02x\n", data_mem.mem[i]);
        // end
        // $fclose(fd);
        $finish;
    end
endmodule