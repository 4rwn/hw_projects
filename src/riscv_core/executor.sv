`include "defs.sv"

module executor (
    input logic clk,
    input logic rst_n,

    // Pipeline inputs
    input logic [31:0] in_addr,
    input instr_type_t in_instr_type,
    input mem_type_t in_mem_type,
    input alu_op_t in_op,
    input logic [4:0] in_dest,
    input logic [31:0] in_src1,
    input logic [31:0] in_src2,
    input logic [31:0] in_rs1_data,
    input logic [31:0] in_rs2_data,
    input logic [31:0] in_imm,
    
    // Pipeline outputs
    output instr_type_t out_instr_type,
    output mem_type_t out_mem_type,
    output logic [4:0] out_dest,
    output logic [31:0] out_rs2_data,
    output logic [31:0] out_imm,

    output logic [31:0] out_res,

    output logic jmp,
    output logic [31:0] jmp_addr
);
    arithmetic_logic_unit alu (
        .clk(clk),
        .rst_n(rst_n),

        .op(in_op),
        .src1(in_src1),
        .src2(in_src2),

        .res(out_res)
    );

    logic [31:0] _addr;
    logic [31:0] _rs1_data;
    always_ff @( posedge clk ) begin
        if (rst_n) begin
            out_instr_type  <= jmp ? NONE : in_instr_type;
            out_mem_type    <= in_mem_type;
            out_dest        <= in_dest;
            out_rs2_data    <= in_rs2_data;
            out_imm         <= in_imm;

            _addr <= in_addr;
            _rs1_data <= in_rs1_data;

        end
    end

    logic _res0; // iverilog workaround
    assign _res0 = out_res[0];
    always_comb begin
        jmp = 1'b0;
        jmp_addr = _addr + out_imm;
        case (out_instr_type)
            BRANCH: jmp = _res0;
            JAL:    jmp = 1'b1;
            JALR: begin
                jmp = 1'b1;
                jmp_addr = _rs1_data + out_imm;
            end
        endcase
    end
endmodule