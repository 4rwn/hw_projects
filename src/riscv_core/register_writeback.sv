`include "defs.sv"

module register_writeback (
    input logic clk,
    input logic rst_n,

    // Pipeline inputs
    input instr_type_t in_instr_type,
    input mem_type_t in_mem_type,
    input logic [4:0] in_dest,
    input logic [31:0] in_imm,
    input logic [31:0] in_res,
    input logic [31:0] in_mem_rd,

    output logic halt,

    // Register file write interface
    output logic reg_wr_en,
    output logic [4:0] reg_wr_reg,
    output logic [31:0] reg_wr_data
);
    logic [7:0] _byte; // iverilog workaround
    logic [15:0] _half;
    assign _byte = in_mem_rd[7:0];
    assign _half = in_mem_rd[15:0];

    logic signed [31:0] _mem_rd;
    always_comb begin
        case (in_mem_type)
            BYTE:           _mem_rd = $signed(_byte);
            HALF:           _mem_rd = $signed(_half);
            WORD:           _mem_rd = in_mem_rd;
            BYTE_UNSIGNED:  _mem_rd = $unsigned(_byte);
            HALF_UNSIGNED:  _mem_rd = $unsigned(_half);
            default:        _mem_rd = 32'h0;
        endcase
    end

    always_comb begin
        reg_wr_en = 1'b1;
        reg_wr_reg = in_dest;
        case (in_instr_type)
            MATH,
            JAL,
            JALR: reg_wr_data = in_res;
            LOAD: reg_wr_data = _mem_rd;
            LUI:  reg_wr_data = in_imm;
            default: begin
                reg_wr_en   = 1'b0;
                reg_wr_data = 32'h0;
            end
        endcase
    end

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (in_instr_type == ENV) begin
                halt <= 1'b1;
            end
        end else begin
            halt <= 1'b0;
        end
    end
endmodule