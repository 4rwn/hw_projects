`include "defs.sv"

module executor (
    input logic clk,

    input logic [31:0] in_addr,
    input logic in_noop,
    input logic [6:0] in_opcode,
    input logic [2:0] in_funct3,
    input logic [6:0] in_funct7,
    input logic signed [31:0] in_rs1_data,
    input logic signed [31:0] in_rs2_data,
    input logic signed [31:0] in_imm,

    output logic out_noop,
    output logic signed [31:0] out_res
);
    op_t op;
    logic signed [31:0] a;
    logic signed [31:0] b;
    alu alu (
        .clk(clk),
        .op(op),
        .a(a),
        .b(b),
        .res(out_res)
    );

    logic [6:0] in_imm_high;
    assign in_imm_high = in_imm[11:5];

    always_comb begin
        op = NO_OP;
        a = in_rs1_data;
        b = in_rs2_data;
        case (in_opcode)
            7'b0110011: begin // Register operations
                case (in_funct3)
                    3'h0: if (in_funct7 == 7'h00) op = ADD;
                        else if (in_funct7 == 7'h20) op = SUB;
                    3'h4: if (in_funct7 == 7'h00) op = XOR;
                    3'h6: if (in_funct7 == 7'h00) op = OR;
                    3'h7: if (in_funct7 == 7'h00) op = AND;
                    3'h1: if (in_funct7 == 7'h00) op = SLL;
                    3'h5: if (in_funct7 == 7'h00) op = SRL;
                        else if (in_funct7 == 7'h20) op = SRA;
                    3'h2: if (in_funct7 == 7'h00) op = LT;
                    3'h3: if (in_funct7 == 7'h00) op = LTU;
                endcase
            end 
            7'b0010011: begin // Immediate operations
                case (in_funct3)
                    3'h0: op = ADD;
                    3'h4: op = XOR;
                    3'h6: op = OR;
                    3'h7: op = AND;
                    3'h1: if (in_imm_high == 7'h00) op = SLL;
                    3'h5: if (in_imm_high == 7'h00) op = SRL;
                        else if (in_imm_high == 7'h20) op = SRA;
                    3'h2: op = LT;
                    3'h3: op = LTU;
                endcase

                b = in_imm;
                if (op == SLL || op == SRL || op == SRA) begin
                    b[31:5] = {27{1'b0}};
                end
            end
            7'b0000011, 7'b0100011: begin // Loads and Stores
                op = ADD;
                b = in_imm;
            end
            7'b1100011: begin // Branches
                case (in_funct3)
                    3'h0: op = EQ;
                    3'h1: op = NEQ;
                    3'h4: op = LT;
                    3'h5: op = GE;
                    3'h6: op = LTU;
                    3'h7: op = GEU;
                endcase
            end
            7'b1101111, 7'b1100111: begin // Jump and link
                op = ADD;
                a = in_addr;
                b = 32'h4;
            end
            7'b0110111, 7'b0010111: begin // Load upper immediate
                op = ADD;
                a = in_addr;
                b = in_imm;
            end
        endcase
    end

    always_ff @( posedge clk ) begin
        out_noop <= in_noop || op == NO_OP;
    end
endmodule