`include "defs.sv"

module arithmetic_logic_unit (
    input logic clk,

    input op_t in_op,
    input logic signed [31:0] in_src1,
    input logic signed [31:0] in_src2,

    output logic signed [31:0] out_res
);
    always_ff @( posedge clk ) begin
        case (in_op)
            ADD: out_res <= in_src1 + in_src2;
            SUB: out_res <= in_src1 - in_src2;
            XOR: out_res <= in_src1 ^ in_src2;
            OR: out_res <= in_src1 | in_src2;
            AND: out_res <= in_src1 & in_src2;
            SLL: out_res <= in_src1 << in_src2;
            SRL: out_res <= in_src1 >> in_src2;
            SRA: out_res <= in_src1 >>> in_src2;
            LT: out_res <= in_src1 < in_src2 ? 32'h1 : 32'h0;
            LTU: out_res <= $unsigned(in_src1) < $unsigned(in_src2) ? 32'h1 : 32'h0;
            EQ: out_res <= in_src1 == in_src2 ? 32'h1 : 32'h0;
            NEQ: out_res <= in_src1 != in_src2 ? 32'h1 : 32'h0;
            GE: out_res <= in_src1 >= in_src2 ? 32'h1 : 32'h0;
            GEU: out_res <= $unsigned(in_src1) >= $unsigned(in_src2) ? 32'h1 : 32'h0;
        endcase
    end
endmodule