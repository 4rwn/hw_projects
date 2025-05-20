`include "defs.sv"

module alu (
    input logic clk,

    input op_t op,
    input logic signed [31:0] a,
    input logic signed [31:0] b,
    output logic signed [31:0] res
);
    always_ff @( posedge clk ) begin
        case (op)
            ADD: res <= a + b;
            SUB: res <= a - b;
            XOR: res <= a ^ b;
            OR: res <= a | b;
            AND: res <= a & b;
            SLL: res <= a << b;
            SRL: res <= a >> b;
            SRA: res <= a >>> b;
            LT: res <= a < b ? 32'h1 : 32'h0;
            LTU: res <= $unsigned(a) < $unsigned(b) ? 32'h1 : 32'h0;
            EQ: res <= a == b ? 32'h1 : 32'h0;
            NEQ: res <= a != b ? 32'h1 : 32'h0;
            GE: res <= a >= b ? 32'h1 : 32'h0;
            GEU: res <= $unsigned(a) >= $unsigned(b) ? 32'h1 : 32'h0;
        endcase        
    end
endmodule