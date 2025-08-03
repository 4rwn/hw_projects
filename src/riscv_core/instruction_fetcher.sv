`include "defs.sv"

module instruction_fetcher (
    input logic clk,
    input logic rst_n,

    // Pipeline inputs
    input logic stall,
    input logic jmp,
    input logic [31:0] jmp_addr,

    // Pipeline outputs
    output logic [31:0] out_addr,
    output logic [31:0] out_instr,
    output instr_type_t out_instr_type,

    // Instruction memory read interface
    output logic [31:0] instr_rd_addr,
    input logic [31:0] instr_rd_data
);
    logic [31:0] pc;

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (jmp) begin
                pc <= jmp_addr;
                out_instr_type <= NONE;
            end else if (!stall) begin
                pc <= pc + 4;
                
                out_addr <= pc;
                out_instr_type <= UNKNOWN;
            end
        end else begin
            pc <= 32'h0;
            out_instr_type <= NONE;
        end
    end

    assign instr_rd_addr = stall ? out_addr : pc;
    assign out_instr = instr_rd_data;
endmodule