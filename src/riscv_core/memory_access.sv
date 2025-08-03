module memory_access #(
    parameter SIZE = 1024
) (
    input logic clk,
    input logic rst_n,

    // Pipeline inputs
    input instr_type_t in_instr_type,
    input mem_type_t in_mem_type,
    input logic [4:0] in_dest,
    input logic [31:0] in_rs2_data,
    input logic [31:0] in_imm,
    input logic [31:0] in_res,

    // Pipeline outputs
    output instr_type_t out_instr_type,
    output mem_type_t out_mem_type,
    output logic [4:0] out_dest,
    output logic [31:0] out_imm,
    output logic [31:0] out_res,

    output logic [31:0] out_mem_rd,

    output logic halt,

    // Memory interface
    output logic [31:0] data_rd_addr,
    input logic [31:0] data_rd_data,

    output logic [1:0] data_wr,
    output logic [31:0] data_wr_addr,
    output logic [31:0] data_wr_data
);
    always_comb begin
        // Read
        data_rd_addr = in_res;
        out_mem_rd = data_rd_data;

        // Write
        data_wr_addr = in_res;
        data_wr_data = in_rs2_data;

        data_wr = 2'h0;
        if (in_instr_type == STORE) begin
            case (in_mem_type)
                BYTE: data_wr = 2'h1;
                HALF: data_wr = 2'h2;
                WORD: data_wr = 2'h3;
            endcase
        end
    end

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            out_instr_type  <= in_instr_type;
            out_mem_type    <= in_mem_type;
            out_dest        <= in_dest;
            out_imm         <= in_imm;
            out_res         <= in_res;

            // Check invalid address
            if ((in_instr_type == LOAD || in_instr_type == STORE) && in_res >= SIZE) begin
                halt <= 1'b1;        
            end
        end else begin
            halt <= 1'b0;
        end
    end
endmodule