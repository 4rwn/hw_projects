`include "defs.sv"

module instruction_decoder (
    input logic clk,

    input logic [31:0] in_instr,
    input logic in_noop,

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
    input logic [6:0] id_opcode,
    input logic [4:0] id_rd,
    input logic signed [31:0] id_imm,
    input logic [6:0] ex_opcode,
    input logic [4:0] ex_rd,
    input logic signed [31:0] ex_imm,
    input logic signed [31:0] ex_res,
    input logic [6:0] mem_opcode,
    input logic [4:0] mem_rd,
    input logic signed [31:0] mem_imm,
    input logic signed [31:0] mem_res,
    input logic signed [31:0] mem_mem_rd,
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
    logic [4:0] rs1, rs2;
    assign rs1 = in_instr[19:15];
    assign rs2 = in_instr[24:20];
    always_comb begin
        case (instr_format)
            R,
            S,
            B: begin
                reg_rd0 = rs1;
                reg_rd1 = rs2;
            end
            I: begin
                reg_rd0 = rs1;
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
        out_rs1_data <= rs1_data;
        out_rs2_data <= rs2_data;

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

    // Data hazard handling for source register 1.
    // Forward data from a later pipeline stage if applicable, otherwise stall.
    logic rs1_stall;
    logic signed [31:0] rs1_data;
    always_comb begin
        rs1_stall = 1'b0;
        rs1_data = reg_rd0_data;
        if (!in_noop && reg_rd0 != 5'h0) begin
            if (reg_rd0 == id_rd) begin
                case (id_opcode)
                    // Forwarding works only from a lui instruction.
                    7'b0110111: rs1_data = id_imm;
                    default: rs1_stall = 1'b1;
                endcase
            end else if (reg_rd0 == ex_rd) begin
                case (ex_opcode)
                    // Forwarding works from all instructions except loads.
                    7'b0110111: rs1_data = ex_imm;
                    7'b0110011,
                    7'b0010011,
                    7'b1101111,
                    7'b1100111, 
                    7'b0010111: rs1_data = ex_res;
                    default: rs1_stall = 1'b1;
                endcase
            end else if (reg_rd0 == mem_rd) begin
                case (mem_opcode)
                    // Forwarding works from all instructions.
                    7'b0110111: rs1_data = mem_imm;
                    7'b0110011,
                    7'b0010011,
                    7'b1101111,
                    7'b1100111, 
                    7'b0010111: rs1_data = mem_res;
                    7'b0000011: rs1_data = mem_mem_rd;
                    default: rs1_stall = 1'b1;
                endcase
            end
        end
    end

    // Data hazard handling for source register 2.
    // Forward data from a later pipeline stage if applicable, otherwise stall.
    logic rs2_stall;
    logic signed [31:0] rs2_data;
    always_comb begin
        rs2_stall = 1'b0;
        rs2_data = reg_rd1_data;
        if (!in_noop && reg_rd1 != 5'h0) begin
            if (reg_rd1 == id_rd) begin
                case (id_opcode)
                    // Forwarding works only from lui instructions.
                    7'b0110111: rs2_data = id_imm;
                    default: rs2_stall = 1'b1;
                endcase
            end else if (reg_rd1 == ex_rd) begin
                case (ex_opcode)
                    // Forwarding works from all instructions except loads.
                    7'b0110111: rs2_data = ex_imm;
                    7'b0110011,
                    7'b0010011,
                    7'b1101111,
                    7'b1100111, 
                    7'b0010111: rs2_data = ex_res;
                    default: rs2_stall = 1'b1;
                endcase
            end else if (reg_rd1 == mem_rd) begin
                case (mem_opcode)
                    // Forwarding works from all instructions.
                    7'b0110111: rs2_data = mem_imm;
                    7'b0110011,
                    7'b0010011,
                    7'b1101111,
                    7'b1100111, 
                    7'b0010111: rs2_data = mem_res;
                    7'b0000011: rs2_data = mem_mem_rd;
                    default: rs2_stall = 1'b1;
                endcase
            end
        end
    end

    assign stall = rs1_stall || rs2_stall;
endmodule