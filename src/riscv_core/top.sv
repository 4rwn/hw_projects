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
    always_ff @( posedge clk ) begin
        if (!stall) begin
            if_addr <= pc;
        end
    end

    logic [31:0] if_instr;
    assign if_instr = rst_n ? instr_rd_data : 32'h0;

    

    /*
        Stage 2: Instruction decode (ID)
    */
    logic [31:0] id_addr;
    logic [31:0] id_instr;
    always_ff @( posedge clk ) begin
        id_addr <= if_addr;
        id_instr <= if_instr;
    end

    logic id_noop;
    logic [6:0] id_opcode;
    instr_format_t id_instr_format;
    logic [2:0] id_funct3;
    logic [6:0] id_funct7;
    logic [4:0] id_rs1, id_rs2, id_rd;
    logic signed [31:0] id_imm, id_rs1_data, id_rs2_data;
    instruction_decoder decoder (
        .clk(clk),

        .in_instr(if_instr),
        .in_noop(flush_cnt > 2'h1),

        .out_noop(id_noop),
        .out_opcode(id_opcode),
        .out_instr_format(id_instr_format),
        .out_funct3(id_funct3),
        .out_funct7(id_funct7),
        .out_rs1(id_rs1),
        .out_rs2(id_rs2),
        .out_rd(id_rd),
        .out_imm(id_imm),
        .out_rs1_data(id_rs1_data),
        .out_rs2_data(id_rs2_data),

        .id_rd(id_noop ? 5'b0 : id_rd),
        .ex_rd(ex_noop ? 5'b0 : ex_rd),
        .mem_rd(mem_noop ? 5'b0 : mem_rd),
        .stall(stall),

        .reg_rd0(reg_rd0),
        .reg_rd1(reg_rd1),
        .reg_rd0_data(reg_rd0_data),
        .reg_rd1_data(reg_rd1_data)
    );
    


    /*
        Stage 3: Execution (EX)
    */
    logic [31:0] ex_addr;
    logic [31:0] ex_instr;
    logic _ex_noop, ex_noop;
    logic [6:0] ex_opcode;
    instr_format_t ex_instr_format;
    logic [2:0] ex_funct3;
    logic [6:0] ex_funct7;
    logic [4:0] ex_rs1, ex_rs2, ex_rd;
    logic signed [31:0] ex_imm, ex_rs1_data, ex_rs2_data;
    always_ff @( posedge clk ) begin
        ex_addr <= id_addr;
        ex_instr <= id_instr;
        ex_opcode <= id_opcode;
        ex_instr_format <= id_instr_format;
        ex_funct3 <= id_funct3;
        ex_funct7 <= id_funct7;
        ex_rs1 <= id_rs1;
        ex_rs2 <= id_rs2;
        ex_rd <= id_rd;
        ex_imm <= id_imm;
        ex_rs1_data <= id_rs1_data;
        ex_rs2_data <= id_rs2_data;
    end

    logic signed [31:0] ex_res;
    executor executor (
        .clk(clk),

        .in_addr(id_addr),
        .in_noop(id_noop),
        .in_opcode(id_opcode),
        .in_funct3(id_funct3),
        .in_funct7(id_funct7),
        .in_rs1_data(id_rs1_data),
        .in_rs2_data(id_rs2_data),
        .in_imm(id_imm),

        .out_noop(_ex_noop),
        .out_res(ex_res)
    );

    // Branches and jumps
    logic ex_res0;
    assign ex_res0 = ex_res[0];
    always_comb begin
        jmp = 1'b0;
        jmp_addr = ex_addr + ex_imm;
        if (!ex_noop) begin
            case (ex_opcode)
                7'b1100011: begin
                    jmp = ex_res0;
                end
                7'b1101111: begin
                    jmp = 1'b1;
                end
                7'b1100111: begin
                    jmp = 1'b1;
                    jmp_addr = ex_rs1_data + ex_imm;
                end
            endcase
        end
    end

    // Flush instructions already on the pipeline on jump
    // by simply flagging the next 3 instructions as noop.
    logic [1:0] flush_cnt;
    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (jmp) begin
                flush_cnt <= 2'h3;
            end else if (flush_cnt > 0) begin
                flush_cnt <= flush_cnt - 1;
            end
        end else begin
            flush_cnt <= 2'h0;
        end
    end

    assign ex_noop = _ex_noop || flush_cnt > 0;



    /*
        Stage 4: Memory Access (MEM)
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
        Stage 5: Register write-back (WB) 
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