`include "defs.sv"

module instruction_decoder (
    input logic clk,

    input logic [31:0] in_instr,

    output logic out_noop,
    output logic [6:0] out_opcode,
    output instr_format_t out_instr_format,
    output logic [2:0] out_funct3,
    output logic [6:0] out_funct7,
    output logic [4:0] out_rs1,
    output logic [4:0] out_rs2,
    output logic [4:0] out_rd,
    output logic signed [31:0] out_imm,
    output logic signed [31:0] out_rs1_data,
    output logic signed [31:0] out_rs2_data,

    // Data hazard handling
    input logic in_noop,
    input logic [4:0] id_rd,
    input logic [4:0] ex_rd,
    input logic [4:0] mem_rd,
    output logic stall,

    // Register file read interface
    output logic [4:0] reg_rd0,
    output logic [4:0] reg_rd1,

    input logic [31:0] reg_rd0_data,
    input logic [31:0] reg_rd1_data
);
    // Instruction
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    assign opcode = in_instr[6:0];
    assign funct3 = in_instr[14:12];
    assign funct7 = in_instr[31:25];

    // Instruction format
    instr_format_t instr_format;
    always_comb begin
        case (opcode)
            7'b0110011: instr_format = R;
            7'b0010011,
            7'b0000011,
            7'b1100111,
            7'b1110011: instr_format = I;
            7'b0100011: instr_format = S;
            7'b1100011: instr_format = B;
            7'b0110111,
            7'b0010111: instr_format = U;
            7'b1101111: instr_format = J;
            default: instr_format = NO_TYPE;
        endcase
    end

    // Source registers
    logic [4:0] _reg_rd0, _reg_rd1; // iverilog workaround
    assign _reg_rd0 = in_instr[19:15];
    assign _reg_rd1 = in_instr[24:20];
    always_comb begin
        case (instr_format)
            R,
            S,
            B: begin
                reg_rd0 = _reg_rd0;
                reg_rd1 = _reg_rd1;
            end
            I: begin
                reg_rd0 = _reg_rd0;
                reg_rd1 = 5'b0;
            end
            default: begin
                reg_rd0 = 5'b0;
                reg_rd1 = 5'b0;
            end
        endcase
    end

    always_ff @( posedge clk ) begin
        out_noop <= instr_format == NO_TYPE || stall;
        out_opcode <= opcode;
        out_instr_format <= instr_format;
        out_funct3 <= funct3;
        out_funct7 <= funct7;
        out_rs1 <= reg_rd0;
        out_rs2 <= reg_rd1;
        out_rs1_data <= reg_rd0_data;
        out_rs2_data <= reg_rd1_data;

        // Immediate and destination register
        case (instr_format)
            R,
            I: begin
                out_rd <= in_instr[11:7];

                out_imm[11:0] <= in_instr[31:20];
                out_imm[31:12] <= {20{in_instr[31]}};
            end
            S: begin
                out_rd <= 5'b0;

                out_imm[4:0] <= in_instr[11:7];
                out_imm[11:5] <= in_instr[31:25];
                out_imm[31:12] <= {20{in_instr[31]}};
            end
            B: begin
                out_rd <= 5'b0;

                out_imm[0] <= 1'b0;
                out_imm[4:1] <= in_instr[11:8];
                out_imm[10:5] <= in_instr[30:25];
                out_imm[11] <= in_instr[7];
                out_imm[12] <= in_instr[31];
                out_imm[31:13] <= {19{in_instr[31]}};
            end
            U: begin
                out_rd <= in_instr[11:7];

                out_imm[11:0] <= 12'h0;
                out_imm[31:12] <= in_instr[31:12];
            end
            J: begin
                out_rd <= in_instr[11:7];

                out_imm[0] <= 1'b0;
                out_imm[10:1] <= in_instr[30:21];
                out_imm[11] <= in_instr[20];
                out_imm[19:12] <= in_instr[19:12];
                out_imm[20] <= in_instr[31];
                out_imm[31:21] <= {11{in_instr[31]}};
            end
        endcase
    end

    // Stall if a register about to be read in ID will be written
    // by an earlier instruction still in the pipeline.
    always_comb begin
        stall = 1'b0;

        if (!in_noop) begin
            if (id_rd != 5'b0 && (id_rd == reg_rd0 || id_rd == reg_rd1))
                stall = 1'b1;

            if (ex_rd != 5'b0 && (ex_rd == reg_rd0 || ex_rd == reg_rd1))
                stall = 1'b1;

            if (mem_rd != 5'b0 && (mem_rd == reg_rd0 || mem_rd == reg_rd1))
                stall = 1'b1;
        end
    end
endmodule