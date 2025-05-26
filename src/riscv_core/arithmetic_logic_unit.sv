`include "defs.sv"

module arithmetic_logic_unit (
    input logic clk,

    input op_t in_op,
    input logic signed [31:0] in_src1,
    input logic signed [31:0] in_src2,

    output logic signed [31:0] out_res
);
    logic signed [63:0] res;
    always_comb begin
        case (in_op)
            ADD: res = in_src1 + in_src2;
            SUB: res = in_src1 - in_src2;
            MUL, MULH: res = in_src1 * in_src2;
            MULHSU: res = $signed({{32{in_src1[31]}}, in_src1}) * {32'b0, in_src2};
            MULHU: res = $unsigned(in_src1) * $unsigned(in_src2);
            DIV: res = in_src1 / in_src2;
            DIVU: res = $unsigned(in_src1) / $unsigned(in_src2);
            REM: res = in_src1 % in_src2;
            REMU: res = $unsigned(in_src1) % $unsigned(in_src2);
            XOR: res = in_src1 ^ in_src2;
            OR: res = in_src1 | in_src2;
            AND: res = in_src1 & in_src2;
            SLL: res = in_src1 << in_src2;
            SRL: res = in_src1 >> in_src2;
            SRA: res = in_src1 >>> in_src2;
            LT: res = in_src1 < in_src2 ? 32'h1 : 32'h0;
            LTU: res = $unsigned(in_src1) < $unsigned(in_src2) ? 32'h1 : 32'h0;
            EQ: res = in_src1 == in_src2 ? 32'h1 : 32'h0;
            NEQ: res = in_src1 != in_src2 ? 32'h1 : 32'h0;
            GE: res = in_src1 >= in_src2 ? 32'h1 : 32'h0;
            GEU: res = $unsigned(in_src1) >= $unsigned(in_src2) ? 32'h1 : 32'h0;
            default: res = 64'h0;
        endcase
    end

    always_ff @( posedge clk ) begin
        case (in_op)
            MULH, MULHSU, MULHU: out_res <= res[63:32];
            default: out_res <= res[31:0];
        endcase
    end
endmodule