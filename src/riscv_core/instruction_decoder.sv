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

    input logic stall
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

    always_ff @( posedge clk ) begin
        if (!stall) begin
            out_noop <= in_noop || instr_format == NO_TYPE;
            out_opcode <= opcode;
            out_instr_format <= instr_format;
            out_funct3 <= funct3;
            out_funct7 <= funct7;

            // Source register 1
            case (instr_format)
                R, I, S, B: out_rs1 = in_instr[19:15];
                default: out_rs1 = 5'b0;
            endcase

            // Source register 2
            case (instr_format)
                R, S, B: out_rs2 = in_instr[24:20];
                default: out_rs2 = 5'b0;
            endcase

            // Destination register
            case (instr_format)
                R, I, U, J: out_rd <= in_instr[11:7];
                default: out_rd <= 5'b0;
            endcase

            // Immediate
            case (instr_format)
                default: begin
                    out_imm[11:0] <= in_instr[31:20];
                    out_imm[31:12] <= {20{in_instr[31]}};
                end
                S: begin
                    out_imm[4:0] <= in_instr[11:7];
                    out_imm[11:5] <= in_instr[31:25];
                    out_imm[31:12] <= {20{in_instr[31]}};
                end
                B: begin
                    out_imm[0] <= 1'b0;
                    out_imm[4:1] <= in_instr[11:8];
                    out_imm[10:5] <= in_instr[30:25];
                    out_imm[11] <= in_instr[7];
                    out_imm[12] <= in_instr[31];
                    out_imm[31:13] <= {19{in_instr[31]}};
                end
                U: begin
                    out_imm[11:0] <= 12'h0;
                    out_imm[31:12] <= in_instr[31:12];
                end
                J: begin
                    out_imm[0] <= 1'b0;
                    out_imm[10:1] <= in_instr[30:21];
                    out_imm[11] <= in_instr[20];
                    out_imm[19:12] <= in_instr[19:12];
                    out_imm[20] <= in_instr[31];
                    out_imm[31:21] <= {11{in_instr[31]}};
                end
            endcase
        end
    end
endmodule