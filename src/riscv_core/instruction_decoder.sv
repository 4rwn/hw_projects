`include "defs.sv"

module instruction_decoder (
    input logic clk,
    input logic rst_n,

    // Pipeline inputs
    input logic jmp,
    input logic [31:0] in_addr,
    input logic [31:0] in_instr,
    input instr_type_t in_instr_type,

    input instr_type_t id_instr_type,
    input logic [4:0] id_dest,
    input instr_type_t ex_instr_type,
    input logic [4:0] ex_dest,
    input instr_type_t mem_instr_type,
    input logic [4:0] mem_dest,

    // Pipeline outputs
    output logic [31:0] out_addr,
    output instr_type_t out_instr_type,
    output mem_type_t out_mem_type,
    output alu_op_t out_op,
    output logic [4:0] out_dest,
    output logic [31:0] out_src1,
    output logic [31:0] out_src2,
    output logic [31:0] out_rs1_data,
    output logic [31:0] out_rs2_data,
    output logic [31:0] out_imm,

    output logic stall,
    output logic halt,

    // Register file read interface
    output logic [4:0] reg_rd1_reg,
    output logic [4:0] reg_rd2_reg,
    input logic [31:0] reg_rd1_data,
    input logic [31:0] reg_rd2_data
);
    logic [6:0] opcode;
    instr_format_t instr_format;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [4:0] rd, rs1, rs2;
    logic [31:0] imm;

    assign opcode = in_instr[6:0];
    assign funct3 = in_instr[14:12];
    assign funct7 = in_instr[31:25];
    assign rd = in_instr[11:7];

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
            default:    instr_format = NO_TYPE;
        endcase
    end

    logic [4:0] _rs1;
    assign _rs1 = in_instr[19:15];
    always_comb begin
        case (instr_format)
            R, I, S, B: rs1 = _rs1;
            default:    rs1 = 5'b0;
        endcase
    end

    logic [4:0] _rs2;
    assign _rs2 = in_instr[24:20];
    always_comb begin
        case (instr_format)
            R, S, B: rs2 = _rs2;
            default: rs2 = 5'b0;
        endcase
    end

    logic [11:0] _instr_31_20;
    logic  _instr_31;
    logic [4:0] _instr_11_7;
    logic [6:0] _instr_31_25;
    logic [3:0] _instr_11_8;
    logic [5:0] _instr_30_25;
    logic  _instr_7;
    logic [19:0] _instr_31_12;
    logic [9:0] _instr_30_21;
    logic  _instr_20;
    logic [7:0] _instr_19_12;
    assign _instr_31_20 = in_instr[31:20];
    assign _instr_31 = in_instr[31];
    assign _instr_11_7 = in_instr[11:7];
    assign _instr_31_25 = in_instr[31:25];
    assign _instr_11_8 = in_instr[11:8];
    assign _instr_30_25 = in_instr[30:25];
    assign _instr_7 = in_instr[7];
    assign _instr_31_12 = in_instr[31:12];
    assign _instr_30_21 = in_instr[30:21];
    assign _instr_20 = in_instr[20];
    assign _instr_19_12 = in_instr[19:12];
    always_comb begin
        case (instr_format)
            default: begin
                imm[11:0]   = _instr_31_20;
                imm[31:12]  = {20{_instr_31}};
            end
            S: begin
                imm[4:0]    = _instr_11_7;
                imm[11:5]   = _instr_31_25;
                imm[31:12]  = {20{_instr_31}};
            end
            B: begin
                imm[0]      = 1'b0;
                imm[4:1]    = _instr_11_8;
                imm[10:5]   = _instr_30_25;
                imm[11]     = _instr_7;
                imm[31:12]  = {20{_instr_31}};
            end
            U: begin
                imm[11:0]   = 12'h0;
                imm[31:12]  = _instr_31_12;
            end
            J: begin
                imm[0]      = 1'b0;
                imm[10:1]   = _instr_30_21;
                imm[11]     = _instr_20;
                imm[19:12]  = _instr_19_12;
                imm[31:20]  = {12{_instr_31}};
            end
        endcase  
    end

    assign reg_rd1_reg = rs1;
    assign reg_rd2_reg = rs2;

    instr_type_t instr_type;
    mem_type_t mem_type;
    alu_op_t op;
    logic [31:0] src1, src2;

    logic [6:0] imm_high; // iverilog workaround
    assign imm_high = imm[11:5];
    always_comb begin
        instr_type = MATH;
        op = NO_OP;
        src1 = reg_rd1_data;
        src2 = reg_rd2_data;
        case (opcode)
            7'b0110011: begin // Register operations
                case (funct3)
                    3'h0: if (funct7 == 7'h00) op = ADD;
                        else if (funct7 == 7'h20) op = SUB;
                    3'h1: if (funct7 == 7'h00) op = SLL;
                    3'h2: if (funct7 == 7'h00) op = LT;
                    3'h3: if (funct7 == 7'h00) op = LTU;
                    3'h4: if (funct7 == 7'h00) op = XOR;
                    3'h5: if (funct7 == 7'h00) op = SRL;
                        else if (funct7 == 7'h20) op = SRA;
                    3'h6: if (funct7 == 7'h00) op = OR;
                    3'h7: if (funct7 == 7'h00) op = AND;
                endcase
            end 
            7'b0010011: begin // Immediate operations
                case (funct3)
                    3'h0: op = ADD;
                    3'h1: if (imm_high == 7'h00) op = SLL;
                    3'h2: op = LT;
                    3'h3: op = LTU;
                    3'h4: op = XOR;
                    3'h5: if (imm_high == 7'h00) op = SRL;
                        else if (imm_high == 7'h20) op = SRA;
                    3'h6: op = OR;
                    3'h7: op = AND;
                endcase

                src2 = imm;
                if (op == SLL || op == SRL || op == SRA) begin
                    src2[31:5] = {27{1'b0}};
                end
            end
            7'b0000011: begin // Loads
                instr_type = LOAD;
                src2 = imm;

                op = ADD;
                case (funct3)
                    3'h0: mem_type = BYTE;
                    3'h1: mem_type = HALF;
                    3'h2: mem_type = WORD;
                    3'h4: mem_type = BYTE_UNSIGNED;
                    3'h5: mem_type = HALF_UNSIGNED;
                    default: op = NO_OP;
                endcase
            end
            7'b0100011: begin // Stores
                instr_type = STORE;
                src2 = imm;

                op = ADD;
                case (funct3)
                    3'h0: mem_type = BYTE;
                    3'h1: mem_type = HALF;
                    3'h2: mem_type = WORD;
                    default: op = NO_OP;
                endcase
            end
            7'b1100011: begin // Branches
                instr_type = BRANCH;
                case (funct3)
                    3'h0: op = EQ;
                    3'h1: op = NEQ;
                    3'h4: op = LT;
                    3'h5: op = GE;
                    3'h6: op = LTU;
                    3'h7: op = GEU;
                endcase
            end
            7'b1101111: begin // Jump and link
                instr_type = JAL;
                op = ADD;
                src1 = in_addr;
                src2 = 32'h4;
            end
            7'b1100111: begin // Jump and link reg
                instr_type = JALR;
                if (funct3 == 3'h0) op = ADD;
                src1 = in_addr;
                src2 = 32'h4;
            end
            7'b0110111: begin // Load upper immediate
                instr_type = LUI;
                op = ADD;
            end
            7'b0010111: begin // Add upper immediate to PC
                op = ADD;
                src1 = in_addr;
                src2 = imm;
            end
            7'b1110011: begin // Control transfer
                instr_type = ENV;
                if (funct3 == 3'h0 && imm < 32'h2) op = ADD;
            end
        endcase
    end

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            out_addr        <= in_addr;
            out_instr_type  <= jmp || stall || in_instr_type == NONE ? NONE : instr_type;
            out_mem_type    <= mem_type;
            out_op          <= op;
            out_src1        <= src1;
            out_src2        <= src2;
            out_rs1_data    <= reg_rd1_data;
            out_rs2_data    <= reg_rd2_data;
            out_imm         <= imm;

            case (instr_format)
                R, I, U, J: out_dest <= rd;
                default:    out_dest <= 5'b0;
            endcase

            if (op == NO_OP) begin
                halt <= 1'b1;
            end
        end else begin
            halt <= 1'b0;
        end
    end

    assign stall_rs1 = rs1 != 5'h0 && ((id_instr_type != NONE && rs1 == id_dest)
        || (ex_instr_type != NONE && rs1 == ex_dest)
        || (mem_instr_type != NONE && rs1 == mem_dest));
    assign stall_rs2 = rs2 != 5'h0 && ((id_instr_type != NONE && rs2 == id_dest)
        || (ex_instr_type != NONE && rs2 == ex_dest)
        || (mem_instr_type != NONE && rs2 == mem_dest));
    assign stall = stall_rs1 || stall_rs2;
endmodule