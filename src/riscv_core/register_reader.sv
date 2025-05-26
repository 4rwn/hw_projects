module register_reader (
    input logic clk,

    input logic in_noop,
    input logic [4:0] in_rs1,
    input logic [4:0] in_rs2,
    
    input logic [31:0] reg_rd0_data,
    input logic [31:0] reg_rd1_data,

    output logic out_noop,
    output logic signed [31:0] out_rs1_data,
    output logic signed [31:0] out_rs2_data,

    // Data hazard handling
    input logic [6:0] rr_opcode,
    input logic [4:0] rr_rd,
    input logic signed [31:0] rr_imm,
    input logic [6:0] ex_opcode,
    input logic [4:0] ex_rd,
    input logic signed [31:0] ex_imm,
    input logic signed [31:0] ex_res,
    input logic [6:0] mem_opcode,
    input logic [4:0] mem_rd,
    input logic signed [31:0] mem_imm,
    input logic signed [31:0] mem_res,
    input logic signed [31:0] mem_mem_rd,
    output logic stall
);
    // Data hazard handling for source register 1.
    // Forward data from a later pipeline stage if applicable, otherwise stall.
    logic rs1_stall;
    logic signed [31:0] rs1_data;
    always_comb begin
        rs1_stall = 1'b0;
        rs1_data = reg_rd0_data;
        if (!in_noop && in_rs1 != 5'h0) begin
            if (in_rs1 == rr_rd) begin
                case (rr_opcode)
                    // Forwarding works only from a lui instruction.
                    7'b0110111: rs1_data = rr_imm;
                    default: rs1_stall = 1'b1;
                endcase
            end else if (in_rs1 == ex_rd) begin
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
            end else if (in_rs1 == mem_rd) begin
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
        if (!in_noop && in_rs2 != 5'h0) begin
            if (in_rs2 == rr_rd) begin
                case (rr_opcode)
                    // Forwarding works only from lui instructions.
                    7'b0110111: rs2_data = rr_imm;
                    default: rs2_stall = 1'b1;
                endcase
            end else if (in_rs2 == ex_rd) begin
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
            end else if (in_rs2 == mem_rd) begin
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

    always_ff @( posedge clk ) begin
        out_noop <= in_noop || stall;
        out_rs1_data <= rs1_data;
        out_rs2_data <= rs2_data;
    end

    assign stall = rs1_stall || rs2_stall;
endmodule