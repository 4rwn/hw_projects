module register_file (
    input logic clk,

    input logic [4:0] rd0,
    input logic [4:0] rd1,
    output logic [31:0] rd0_data,
    output logic [31:0] rd1_data,

    input logic [4:0] wr,
    input logic [31:0] wr_data
);
    logic [31:0] regs [31:0];

    assign rd0_data = rd0 == 5'b0 ? 32'b0 : regs[rd0];
    assign rd1_data = rd1 == 5'b0 ? 32'b0 : regs[rd1];

    always_ff @( posedge clk ) begin
        if (wr != 5'b0) begin
            regs[wr] <= wr_data;
        end
    end
endmodule