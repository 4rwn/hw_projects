`include "defs.sv"

module riscv_core (
    input logic clk,
    input logic rst_n
);
    localparam INSTR_MEM_SIZE = 256;
    localparam DATA_MEM_SIZE = 1024;

    // Program counter
    logic [31:0] pc;
    always_ff @( posedge clk ) begin
        if (rst_n) begin
            // pc <= exec.jmp ? exec.jmp_addr : pc+4;
            pc <= pc + 4;
        end else begin
            pc <= 32'b0;
        end
    end

    // Register file
    logic [4:0] reg_rd0;
    logic [4:0] reg_rd1;
    logic [31:0] reg_rd0_data;
    logic [31:0] reg_rd1_data;
    logic [4:0] reg_wr;
    logic [31:0] reg_wr_data;

    register_file regs (
        .clk(clk),

        .rd0(reg_rd0),
        .rd1(reg_rd1),
        .rd0_data(reg_rd0_data),
        .rd1_data(reg_rd1_data),

        .wr(reg_wr),
        .wr_data(reg_wr_data)
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



    /*
        Stage 1: Instruction fetch (IF)
    */
    logic [31:0] if_addr;
    logic [31:0] if_instr;

    memory #(
        .SIZE(INSTR_MEM_SIZE)
    ) instr_mem (
        .clk(clk),

        .rd_addr(pc),
        .rd_data(if_instr),

        .wr(2'b00),
        .wr_addr(0),
        .wr_data(0)
    );

    always_ff @( posedge clk ) begin
        if_addr <= pc;
    end



    /*
        Stage 2: Instruction decode (ID)
    */
    logic [31:0] id_addr;
    logic [31:0] id_instr;

    logic id_noop;
    logic [6:0] id_opcode;
    instr_type_t id_instr_type;
    logic [2:0] id_funct3;
    logic [6:0] id_funct7;
    logic [4:0] id_rs1;
    logic [4:0] id_rs2;
    logic [4:0] id_rd;
    logic signed [31:0] id_imm;
    logic signed [31:0] id_rs1_data;
    logic signed [31:0] id_rs2_data;

    instruction_decoder decoder (
        .clk(clk),

        .in_instr(if_instr),

        .out_noop(id_noop),
        .out_opcode(id_opcode),
        .out_instr_type(id_instr_type),
        .out_funct3(id_funct3),
        .out_funct7(id_funct7),
        .out_rs1(id_rs1),
        .out_rs2(id_rs2),
        .out_rd(id_rd),
        .out_imm(id_imm),
        .out_rs1_data(id_rs1_data),
        .out_rs2_data(id_rs2_data),

        .reg_rd0(reg_rd0),
        .reg_rd1(reg_rd1),
        .reg_rd0_data(reg_rd0_data),
        .reg_rd1_data(reg_rd1_data)
    );

    always_ff @( posedge clk ) begin
        id_addr <= if_addr;
        id_instr <= if_instr;
    end
    


    /*
        Stage 3: Execution (EX)
    */
    logic [31:0] ex_addr;
    logic [31:0] ex_instr;
    logic ex_noop;
    logic [6:0] ex_opcode;
    instr_type_t ex_instr_type;
    logic [2:0] ex_funct3;
    logic [6:0] ex_funct7;
    logic [4:0] ex_rs1;
    logic [4:0] ex_rs2;
    logic [4:0] ex_rd;
    logic signed [31:0] ex_imm;
    logic signed [31:0] ex_rs1_data;
    logic signed [31:0] ex_rs2_data;

    logic signed [31:0] ex_res;
    logic ex_jmp;
    logic [31:0] ex_jmp_addr;

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

        .out_noop(ex_noop),
        .out_res(ex_res)
    );

    always_ff @( posedge clk ) begin
        ex_addr <= id_addr;
        ex_instr <= id_instr;
        ex_opcode <= id_opcode;
        ex_instr_type <= id_instr_type;
        ex_funct3 <= id_funct3;
        ex_funct7 <= id_funct7;
        ex_rs1 <= id_rs1;
        ex_rs2 <= id_rs2;
        ex_rd <= id_rd;
        ex_imm <= id_imm;
        ex_rs1_data <= id_rs1_data;
        ex_rs2_data <= id_rs2_data;
    end

    // TODO control flow transfers and flushing pending instructions
    


    /*
        Stage 4: Memory Access (MEM)
    */
    logic [31:0] mem_addr;
    logic [31:0] mem_instr;
    logic mem_noop;
    logic [6:0] mem_opcode;
    instr_type_t mem_instr_type;
    logic [2:0] mem_funct3;
    logic [6:0] mem_funct7;
    logic [4:0] mem_rs1;
    logic [4:0] mem_rs2;
    logic [4:0] mem_rd;
    logic signed [31:0] mem_imm;
    logic signed [31:0] mem_rs1_data;
    logic signed [31:0] mem_rs2_data;
    logic signed [31:0] mem_res;
    logic mem_jmp;
    logic [31:0] mem_jmp_addr;

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

    always_ff @( posedge clk ) begin
        mem_addr <= ex_addr;
        mem_instr <= ex_instr;
        mem_opcode <= ex_opcode;
        mem_instr_type <= ex_instr_type;
        mem_funct3 <= ex_funct3;
        mem_funct7 <= ex_funct7;
        mem_rs1 <= ex_rs1;
        mem_rs2 <= ex_rs2;
        mem_rd <= ex_rd;
        mem_imm <= ex_imm;
        mem_rs1_data <= ex_rs1_data;
        mem_rs2_data <= ex_rs2_data;
        mem_res <= ex_res;
        mem_jmp <= ex_jmp;
        mem_jmp_addr <= ex_jmp_addr;
    end



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