`include "defs.sv"

module arithmetic_logic_unit (
    input logic clk,
    input logic rst_n,

    input alu_op_t op,
    input logic signed [31:0] src1,
    input logic signed [31:0] src2,

    output logic signed [31:0] res
);
    always_ff @( posedge clk ) begin
        if (rst_n) begin
            case (op)
                ADD: res <= src1 + src2;
                SUB: res <= src1 - src2;
                XOR: res <= src1 ^ src2;
                OR: res <= src1 | src2;
                AND: res <= src1 & src2;
                SLL: res <= src1 << src2[4:0];
                SRL: res <= src1 >> src2[4:0];
                SRA: res <= src1 >>> src2[4:0];
                LT: res <= src1 < src2 ? 32'h1 : 32'h0;
                LTU: res <= $unsigned(src1) < $unsigned(src2) ? 32'h1 : 32'h0;
                EQ: res <= src1 == src2 ? 32'h1 : 32'h0;
                NEQ: res <= src1 != src2 ? 32'h1 : 32'h0;
                GE: res <= src1 >= src2 ? 32'h1 : 32'h0;
                GEU: res <= $unsigned(src1) >= $unsigned(src2) ? 32'h1 : 32'h0;
            endcase
        end
    end
endmodule