module memory_access (
    input logic clk,

    input logic in_noop,
    input logic [6:0] in_opcode,
    input logic [2:0] in_funct3,
    input logic signed [31:0] in_rs2_data,
    input logic signed [31:0] in_res,

    output logic [31:0] out_mem_rd,

    // Memory interface
    output logic [31:0] data_rd_addr,
    input logic [31:0] data_rd_data,

    output logic [1:0] data_wr,
    output logic [31:0] data_wr_addr,
    output logic [31:0] data_wr_data
);
    always_comb begin
        data_rd_addr = in_res;
        out_mem_rd = data_rd_data;

        data_wr_addr = in_res;
        data_wr_data = in_rs2_data;

        data_wr = 2'h0;
        if (!in_noop && in_opcode == 7'b0100011) begin
            case (in_funct3)
                3'h0: data_wr = 2'h1;
                3'h1: data_wr = 2'h2;
                3'h2: data_wr = 2'h3;
            endcase
        end
    end
endmodule