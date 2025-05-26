module register_file (
    input logic clk,

    input logic [4:0] rd1,
    input logic [4:0] rd2,
    output logic [31:0] rd1_data,
    output logic [31:0] rd2_data,

    input logic [4:0] wr,
    input logic [31:0] wr_data
);
    logic [31:0] regs [31:0];

    assign rd1_data = rd1 == 5'b0 ? 32'b0 : regs[rd1];
    assign rd2_data = rd2 == 5'b0 ? 32'b0 : regs[rd2];

    always_ff @( posedge clk ) begin
        if (wr != 5'b0) begin
            regs[wr] <= wr_data;
        end
    end
endmodule