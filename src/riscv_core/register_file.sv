module register_file (
    input logic clk,
    input logic rst_n,

    input logic [4:0] rd1_reg,
    input logic [4:0] rd2_reg,
    output logic [31:0] rd1_data,
    output logic [31:0] rd2_data,

    input logic wr_en,
    input logic [4:0] wr_reg,
    input logic [31:0] wr_data
);
    logic [31:0] regs [31:0];

    assign rd1_data = rd1_reg == 5'b0 ? 32'b0 : regs[rd1_reg];
    assign rd2_data = rd2_reg == 5'b0 ? 32'b0 : regs[rd2_reg];

    always_ff @( posedge clk ) begin
        if (wr_en && wr_reg != 5'b0) begin
            regs[wr_reg] <= wr_data;
        end
    end
endmodule