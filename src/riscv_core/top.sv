`include "defs.sv"

module riscv_core (
    input logic clk,
    input logic rst_n,

    // Instruction memory interface
    output logic [31:0] instr_rd_addr,
    input logic [31:0] instr_rd_data,

    // Data memory interface
    output logic [31:0] data_rd_addr,
    input logic [31:0] data_rd_data,

    output logic [1:0] data_wr,
    output logic [31:0] data_wr_addr,
    output logic [31:0] data_wr_data
);
    // Control flow
    logic [31:0] pc;
    logic stall;
    logic jmp;
    logic [31:0] jmp_addr;
    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (jmp) begin
                pc <= jmp_addr;
            end else if (!stall) begin
                pc <= pc + 4;
            end
        end else begin
            pc <= 32'b0;
        end
    end

    assign instr_rd_addr = stall ? if_addr : pc;

    // Register file
    logic [4:0] reg_rd0, reg_rd1, reg_wr;
    logic [31:0] reg_rd0_data, reg_rd1_data, reg_wr_data;
    register_file regs (
        .clk(clk),

        .rd0(reg_rd0),
        .rd1(reg_rd1),
        .rd0_data(reg_rd0_data),
        .rd1_data(reg_rd1_data),

        .wr(reg_wr),
        .wr_data(reg_wr_data)
    );



    /*
        Stage 1: Instruction fetch (IF)
    */
    logic [31:0] if_addr;
    logic if_noop;
    always_ff @( posedge clk ) begin
        if (!stall) begin
            if_addr <= pc;
        end
        if_noop <= jmp;
    end

    logic [31:0] if_instr;
    assign if_instr = rst_n ? instr_rd_data : 32'h0;

    

    /*
        Stage 2: Instruction decode (ID)
    */
    logic [31:0] id_addr;
    logic [31:0] id_instr;
    logic id_noop;
    always_ff @( posedge clk ) begin
        if (!stall) begin
            id_addr <= if_addr;
            id_instr <= if_instr;
        end
    end

    logic [6:0] id_opcode;
    instr_format_t id_instr_format;
    logic [2:0] id_funct3;
    logic [6:0] id_funct7;
    logic [4:0] id_rs1, id_rs2, id_rd;
    logic signed [31:0] id_imm;
    instruction_decoder decoder (
        .clk(clk),

        .in_instr(if_instr),
        .in_noop(if_noop || jmp),

        .out_noop(id_noop),
        .out_opcode(id_opcode),
        .out_instr_format(id_instr_format),
        .out_funct3(id_funct3),
        .out_funct7(id_funct7),
        .out_rs1(id_rs1),
        .out_rs2(id_rs2),
        .out_rd(id_rd),
        .out_imm(id_imm),

        .stall(stall)
    );
    


    /*
        Stage 3: Register read (RR)
    */
    logic [31:0] rr_addr;
    logic [31:0] rr_instr;
    logic rr_noop;
    logic [6:0] rr_opcode;
    instr_format_t rr_instr_format;
    logic [2:0] rr_funct3;
    logic [6:0] rr_funct7;
    logic [4:0] rr_rs1, rr_rs2, rr_rd;
    logic signed [31:0] rr_imm;
    always_ff @( posedge clk ) begin
        rr_addr <= id_addr;
        rr_instr <= id_instr;
        rr_opcode <= id_opcode;
        rr_instr_format <= id_instr_format;
        rr_funct3 <= id_funct3;
        rr_funct7 <= id_funct7;
        rr_rs1 <= id_rs1;
        rr_rs2 <= id_rs2;
        rr_rd <= id_rd;
        rr_imm <= id_imm;
    end

    assign reg_rd0 = id_rs1;
    assign reg_rd1 = id_rs2;

    logic signed [31:0] rr_rs1_data, rr_rs2_data;
    register_reader reg_read (
        .clk(clk),

        .in_noop(id_noop || jmp),
        .in_rs1(id_rs1),
        .in_rs2(id_rs2),

        .reg_rd0_data(reg_rd0_data),
        .reg_rd1_data(reg_rd1_data),

        .out_noop(rr_noop),
        .out_rs1_data(rr_rs1_data),
        .out_rs2_data(rr_rs2_data),

        .rr_opcode(rr_opcode),
        .rr_rd(rr_noop ? 5'b0 : rr_rd),
        .rr_imm(rr_imm),
        .ex_opcode(ex_opcode),
        .ex_rd(ex_noop ? 5'b0 : ex_rd),
        .ex_imm(ex_imm),
        .ex_res(ex_res),
        .mem_opcode(mem_opcode),
        .mem_rd(mem_noop ? 5'b0 : mem_rd),
        .mem_imm(mem_imm),
        .mem_res(mem_res),
        .mem_mem_rd(mem_mem_rd),

        .stall(stall)
    );



    /*
        Stage 4: Execution (EX)
    */
    logic [31:0] ex_addr;
    logic [31:0] ex_instr;
    logic ex_noop;
    logic [6:0] ex_opcode;
    instr_format_t ex_instr_format;
    logic [2:0] ex_funct3;
    logic [6:0] ex_funct7;
    logic [4:0] ex_rs1, ex_rs2, ex_rd;
    logic signed [31:0] ex_imm, ex_rs1_data, ex_rs2_data;
    always_ff @( posedge clk ) begin
        ex_addr <= rr_addr;
        ex_instr <= rr_instr;
        ex_opcode <= rr_opcode;
        ex_instr_format <= rr_instr_format;
        ex_funct3 <= rr_funct3;
        ex_funct7 <= rr_funct7;
        ex_rs1 <= rr_rs1;
        ex_rs2 <= rr_rs2;
        ex_rd <= rr_rd;
        ex_imm <= rr_imm;
        ex_rs1_data <= rr_rs1_data;
        ex_rs2_data <= rr_rs2_data;
    end

    logic signed [31:0] ex_res;
    executor executor (
        .clk(clk),

        .in_addr(rr_addr),
        .in_noop(rr_noop || jmp),
        .in_opcode(rr_opcode),
        .in_funct3(rr_funct3),
        .in_funct7(rr_funct7),
        .in_rs1_data(rr_rs1_data),
        .in_rs2_data(rr_rs2_data),
        .in_imm(rr_imm),

        .out_noop(ex_noop),
        .out_res(ex_res)
    );

    // Branches and jumps
    logic ex_res0; // iverilog workaround
    assign ex_res0 = ex_res[0];
    always_comb begin
        jmp = 1'b0;
        jmp_addr = ex_addr + ex_imm;
        if (!ex_noop) begin
            case (ex_opcode)
                7'b1100011: jmp = ex_res0;
                7'b1101111: jmp = 1'b1;
                7'b1100111: begin
                    jmp = 1'b1;
                    jmp_addr = ex_rs1_data + ex_imm;
                end
            endcase
        end
    end



    /*
        Stage 5: Memory Access (MEM)
    */
    logic [31:0] mem_addr;
    logic [31:0] mem_instr;
    logic mem_noop;
    logic [6:0] mem_opcode;
    instr_format_t mem_instr_format;
    logic [2:0] mem_funct3;
    logic [6:0] mem_funct7;
    logic [4:0] mem_rs1, mem_rs2, mem_rd;
    logic signed [31:0] mem_imm, mem_rs1_data, mem_rs2_data, mem_res;
    always_ff @( posedge clk ) begin
        mem_addr <= ex_addr;
        mem_instr <= ex_instr;
        mem_noop <= ex_noop;
        mem_opcode <= ex_opcode;
        mem_instr_format <= ex_instr_format;
        mem_funct3 <= ex_funct3;
        mem_funct7 <= ex_funct7;
        mem_rs1 <= ex_rs1;
        mem_rs2 <= ex_rs2;
        mem_rd <= ex_rd;
        mem_imm <= ex_imm;
        mem_rs1_data <= ex_rs1_data;
        mem_rs2_data <= ex_rs2_data;
        mem_res <= ex_res;
    end

    logic signed [31:0] mem_mem_rd;
    memory_access memory_access (
        .clk(clk),

        .in_noop(ex_noop),
        .in_opcode(ex_opcode),
        .in_funct3(ex_funct3),
        .in_rs2_data(ex_rs2_data),
        .in_res(ex_res),

        .out_mem_rd(mem_mem_rd),

        .data_rd_addr(data_rd_addr),
        .data_rd_data(data_rd_data),
        .data_wr(data_wr),
        .data_wr_addr(data_wr_addr),
        .data_wr_data(data_wr_data)
    );



    /*
        Stage 6: Register write-back (WB) 
    */
    register_writeback reg_wb (
        .clk(clk),

        .in_noop(mem_noop),
        .in_opcode(mem_opcode),
        .in_funct3(mem_funct3),
        .in_rd(mem_rd),
        .in_imm(mem_imm),
        .in_mem_rd(mem_mem_rd),
        .in_res(mem_res),
        
        .reg_wr(reg_wr),
        .reg_wr_data(reg_wr_data)
    );
endmodule