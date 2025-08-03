`include "defs.sv"

module riscv_core #(
    parameter DATA_MEM_SIZE = 1024
) (
    input logic clk,
    input logic rst_n,

    // Instruction memory read interface
    output logic [31:0] instr_rd_addr,
    input logic [31:0] instr_rd_data,

    // Data memory interface
    output logic [31:0] data_rd_addr,
    input logic [31:0] data_rd_data,

    output logic [1:0] data_wr,
    output logic [31:0] data_wr_addr,
    output logic [31:0] data_wr_data,

    output logic [2:0] halt
);    
    logic reg_wr_en;
    logic [4:0] reg_rd1_reg, reg_rd2_reg, reg_wr_reg;
    logic [31:0] reg_rd1_data, reg_rd2_data, reg_wr_data;
    register_file registers (
        .clk(clk),
        .rst_n(rst_n),

        .rd1_reg(reg_rd1_reg),
        .rd2_reg(reg_rd2_reg),
        .rd1_data(reg_rd1_data),
        .rd2_data(reg_rd2_data),
        
        .wr_en(reg_wr_en),
        .wr_reg(reg_wr_reg),
        .wr_data(reg_wr_data)
    );



    /*
        Stage 1: Instruction Fetch (IF)
    */
    logic [31:0] if_addr;
    logic [31:0] if_instr;
    instr_type_t if_instr_type;
    instruction_fetcher instr_fetch (
        .clk(clk),
        .rst_n(rst_n),

        .stall(stall),
        .jmp(jmp),
        .jmp_addr(jmp_addr),

        .out_addr(if_addr),
        .out_instr(if_instr),
        .out_instr_type(if_instr_type),

        .instr_rd_addr(instr_rd_addr),
        .instr_rd_data(instr_rd_data)
    );



    /*
        Stage 2: Instruction Decode (ID)
    */
    logic [31:0] id_addr;
    instr_type_t id_instr_type;
    mem_type_t id_mem_type;
    alu_op_t id_op;
    logic [4:0] id_dest;
    logic [31:0] id_src1, id_src2, id_rs1_data, id_rs2_data, id_imm;
    logic id_halt;
    instruction_decoder id (
        .clk(clk),
        .rst_n(rst_n),

        .jmp(jmp),
        .in_addr(if_addr),
        .in_instr(if_instr),
        .in_instr_type(if_instr_type),

        .id_instr_type(id_instr_type),
        .id_dest(id_dest),
        .ex_instr_type(ex_instr_type),
        .ex_dest(ex_dest),
        .mem_instr_type(mem_instr_type),
        .mem_dest(mem_dest),

        .out_addr(id_addr),
        .out_instr_type(id_instr_type),
        .out_mem_type(id_mem_type),
        .out_op(id_op),
        .out_dest(id_dest),
        .out_src1(id_src1),
        .out_src2(id_src2),
        .out_rs1_data(id_rs1_data),
        .out_rs2_data(id_rs2_data),
        .out_imm(id_imm),
        
        .stall(stall),
        .halt(id_halt),

        .reg_rd1_reg(reg_rd1_reg),
        .reg_rd2_reg(reg_rd2_reg),
        .reg_rd1_data(reg_rd1_data),
        .reg_rd2_data(reg_rd2_data)
    );



    /*
        Stage 3: Execution (EX)
    */
    instr_type_t ex_instr_type;
    mem_type_t ex_mem_type;
    logic [4:0] ex_dest;
    logic [31:0] ex_rs2_data, ex_imm, ex_res;
    logic jmp;
    logic [31:0] jmp_addr;
    executor ex (
        .clk(clk),
        .rst_n(rst_n),
        
        .in_addr(id_addr),
        .in_instr_type(id_instr_type),
        .in_mem_type(id_mem_type),
        .in_op(id_op),
        .in_dest(id_dest),
        .in_src1(id_src1),
        .in_src2(id_src2),
        .in_rs1_data(id_rs1_data),
        .in_rs2_data(id_rs2_data),
        .in_imm(id_imm),

        .out_instr_type(ex_instr_type),
        .out_mem_type(ex_mem_type),
        .out_dest(ex_dest),
        .out_rs2_data(ex_rs2_data),
        .out_imm(ex_imm),

        .out_res(ex_res),

        .jmp(jmp),
        .jmp_addr(jmp_addr)
    );



    /*
        Stage 4: Memory Read/Write (MEM)
    */
    instr_type_t mem_instr_type;
    mem_type_t mem_mem_type;
    logic [4:0] mem_dest;
    logic [31:0] mem_imm, mem_res, mem_mem_rd;
    logic mem_halt;
    memory_access #(
        .SIZE(DATA_MEM_SIZE)
    ) mem (
        .clk(clk),
        .rst_n(rst_n),
        
        .in_instr_type(ex_instr_type),
        .in_mem_type(ex_mem_type),
        .in_dest(ex_dest),
        .in_rs2_data(ex_rs2_data),
        .in_imm(ex_imm),
        .in_res(ex_res),

        .out_instr_type(mem_instr_type),
        .out_mem_type(mem_mem_type),
        .out_dest(mem_dest),
        .out_imm(mem_imm),
        .out_res(mem_res),

        .out_mem_rd(mem_mem_rd),

        .halt(mem_halt),

        .data_rd_addr(data_rd_addr),
        .data_rd_data(data_rd_data),

        .data_wr(data_wr),
        .data_wr_addr(data_wr_addr),
        .data_wr_data(data_wr_data)
    );



    /*
        Stage 5: Register Write-Back (WB)
    */
    logic wb_halt;
    register_writeback wb (
        .clk(clk),
        .rst_n(rst_n),
        
        .in_instr_type(mem_instr_type),
        .in_mem_type(mem_mem_type),
        .in_dest(mem_dest),
        .in_imm(mem_imm),
        .in_res(mem_res),
        .in_mem_rd(mem_mem_rd),
        
        .halt(wb_halt),

        .reg_wr_en(reg_wr_en),
        .reg_wr_reg(reg_wr_reg),
        .reg_wr_data(reg_wr_data)
    );



    always_comb begin
        halt[0] = id_halt;
        halt[1] = mem_halt;
        halt[2] = wb_halt;
    end
endmodule