
module register_writeback (
    input logic clk,

    input logic in_noop,
    input logic [6:0] in_opcode,
    input logic [2:0] in_funct3,
    input logic [4:0] in_rd,
    input logic signed [31:0] in_imm,
    input logic signed [31:0] in_res,
    input logic [31:0] in_mem_rd,

    output logic [4:0] reg_wr,
    output logic [31:0] reg_wr_data
);
    logic [7:0] _byte;
    logic [15:0] _half;
    assign _byte = in_mem_rd[7:0];
    assign _half = in_mem_rd[15:0];

    logic signed [31:0] in_mem_rd_ext;
    always_comb begin
        reg_wr = in_rd;
        case (in_opcode)
            7'b0110011,
            7'b0010011,
            7'b1101111,
            7'b1100111, 
            7'b0010111: reg_wr_data = in_res;
            7'b0000011: begin
                case (in_funct3)
                    3'h0: in_mem_rd_ext = $signed(_byte);
                    3'h1: in_mem_rd_ext = $signed(_half);
                    3'h2: in_mem_rd_ext = in_mem_rd;
                    3'h4: in_mem_rd_ext = $unsigned(_byte);
                    3'h5: in_mem_rd_ext = $unsigned(_half);
                    default: reg_wr = 5'h0;
                endcase
                reg_wr_data = in_mem_rd_ext;
            end
            7'b0110111: reg_wr_data = in_imm;
            default: reg_wr = 5'h0;
        endcase
        if (in_noop) begin
            reg_wr = 5'h0;
        end
    end
endmodule