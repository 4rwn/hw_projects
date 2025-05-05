module sorter #(
    parameter VALUE_BITS = 8,
    parameter DEPTH = 4,
    parameter DIRECTION = 0,
    parameter SIZE = 1 << DEPTH // Do not override
) (
    input logic clk,

    input logic [SIZE-1:0][VALUE_BITS-1:0] in,
    output logic [SIZE-1:0][VALUE_BITS-1:0] out
);
    genvar i;
    generate
        if (DEPTH > 4) begin
            logic [SIZE-1:0][VALUE_BITS-1:0] intermediate;

            sorter #(
                .VALUE_BITS(VALUE_BITS),
                .DEPTH(DEPTH - 1),
                .DIRECTION(DIRECTION)
            ) first_sorter (
                .clk(clk),

                .in(in[SIZE/2-1:0]),
                .out(intermediate[SIZE/2-1:0])
            );

            sorter #(
                .VALUE_BITS(VALUE_BITS),
                .DEPTH(DEPTH - 1),
                .DIRECTION(1 - DIRECTION)
            ) second_sorter (
                .clk(clk),
                
                .in(in[SIZE-1:SIZE/2]),
                .out(intermediate[SIZE-1:SIZE/2])
            );

            merger #(
                .VALUE_BITS(VALUE_BITS),
                .DEPTH(DEPTH),
                .DIRECTION(DIRECTION)
            ) merger (
                .clk(clk),

                .in(intermediate),
                .out(out)
            );
        end else begin
            logic [15:0][VALUE_BITS-1:0] t0;
            logic [15:0][VALUE_BITS-1:0] t1;
            logic [15:0][VALUE_BITS-1:0] t2;
            logic [15:0][VALUE_BITS-1:0] t3;
            logic [15:0][VALUE_BITS-1:0] t4;
            logic [15:0][VALUE_BITS-1:0] t5;
            logic [15:0][VALUE_BITS-1:0] t6;
            logic [15:0][VALUE_BITS-1:0] t7;
            logic [15:0][VALUE_BITS-1:0] t8;
            assign {t0[0], t0[5]} = (in[0] > in[5]) ? {in[5], in[0]} : {in[0], in[5]};
            assign {t0[1], t0[4]} = (in[1] > in[4]) ? {in[4], in[1]} : {in[1], in[4]};
            assign {t0[2], t0[12]} = (in[2] > in[12]) ? {in[12], in[2]} : {in[2], in[12]};
            assign {t0[3], t0[13]} = (in[3] > in[13]) ? {in[13], in[3]} : {in[3], in[13]};
            assign {t0[6], t0[7]} = (in[6] > in[7]) ? {in[7], in[6]} : {in[6], in[7]};
            assign {t0[8], t0[9]} = (in[8] > in[9]) ? {in[9], in[8]} : {in[8], in[9]};
            assign {t0[10], t0[15]} = (in[10] > in[15]) ? {in[15], in[10]} : {in[10], in[15]};
            assign {t0[11], t0[14]} = (in[11] > in[14]) ? {in[14], in[11]} : {in[11], in[14]};
            assign {t1[0], t1[2]} = (t0[0] > t0[2]) ? {t0[2], t0[0]} : {t0[0], t0[2]};
            assign {t1[1], t1[10]} = (t0[1] > t0[10]) ? {t0[10], t0[1]} : {t0[1], t0[10]};
            assign {t1[3], t1[6]} = (t0[3] > t0[6]) ? {t0[6], t0[3]} : {t0[3], t0[6]};
            assign {t1[4], t1[7]} = (t0[4] > t0[7]) ? {t0[7], t0[4]} : {t0[4], t0[7]};
            assign {t1[5], t1[14]} = (t0[5] > t0[14]) ? {t0[14], t0[5]} : {t0[5], t0[14]};
            assign {t1[8], t1[11]} = (t0[8] > t0[11]) ? {t0[11], t0[8]} : {t0[8], t0[11]};
            assign {t1[9], t1[12]} = (t0[9] > t0[12]) ? {t0[12], t0[9]} : {t0[9], t0[12]};
            assign {t1[13], t1[15]} = (t0[13] > t0[15]) ? {t0[15], t0[13]} : {t0[13], t0[15]};
            assign {t2[0], t2[8]} = (t1[0] > t1[8]) ? {t1[8], t1[0]} : {t1[0], t1[8]};
            assign {t2[1], t2[3]} = (t1[1] > t1[3]) ? {t1[3], t1[1]} : {t1[1], t1[3]};
            assign {t2[2], t2[11]} = (t1[2] > t1[11]) ? {t1[11], t1[2]} : {t1[2], t1[11]};
            assign {t2[4], t2[13]} = (t1[4] > t1[13]) ? {t1[13], t1[4]} : {t1[4], t1[13]};
            assign {t2[5], t2[9]} = (t1[5] > t1[9]) ? {t1[9], t1[5]} : {t1[5], t1[9]};
            assign {t2[6], t2[10]} = (t1[6] > t1[10]) ? {t1[10], t1[6]} : {t1[6], t1[10]};
            assign {t2[7], t2[15]} = (t1[7] > t1[15]) ? {t1[15], t1[7]} : {t1[7], t1[15]};
            assign {t2[12], t2[14]} = (t1[12] > t1[14]) ? {t1[14], t1[12]} : {t1[12], t1[14]};
            assign {t3[0], t3[1]} = (t2[0] > t2[1]) ? {t2[1], t2[0]} : {t2[0], t2[1]};
            assign {t3[2], t3[4]} = (t2[2] > t2[4]) ? {t2[4], t2[2]} : {t2[2], t2[4]};
            assign {t3[3], t3[8]} = (t2[3] > t2[8]) ? {t2[8], t2[3]} : {t2[3], t2[8]};
            assign {t3[5], t3[6]} = (t2[5] > t2[6]) ? {t2[6], t2[5]} : {t2[5], t2[6]};
            assign {t3[7], t3[12]} = (t2[7] > t2[12]) ? {t2[12], t2[7]} : {t2[7], t2[12]};
            assign {t3[9], t3[10]} = (t2[9] > t2[10]) ? {t2[10], t2[9]} : {t2[9], t2[10]};
            assign {t3[11], t3[13]} = (t2[11] > t2[13]) ? {t2[13], t2[11]} : {t2[11], t2[13]};
            assign {t3[14], t3[15]} = (t2[14] > t2[15]) ? {t2[15], t2[14]} : {t2[14], t2[15]};
            assign {t4[1], t4[3]} = (t3[1] > t3[3]) ? {t3[3], t3[1]} : {t3[1], t3[3]};
            assign {t4[2], t4[5]} = (t3[2] > t3[5]) ? {t3[5], t3[2]} : {t3[2], t3[5]};
            assign {t4[4], t4[8]} = (t3[4] > t3[8]) ? {t3[8], t3[4]} : {t3[4], t3[8]};
            assign {t4[6], t4[9]} = (t3[6] > t3[9]) ? {t3[9], t3[6]} : {t3[6], t3[9]};
            assign {t4[7], t4[11]} = (t3[7] > t3[11]) ? {t3[11], t3[7]} : {t3[7], t3[11]};
            assign {t4[10], t4[13]} = (t3[10] > t3[13]) ? {t3[13], t3[10]} : {t3[10], t3[13]};
            assign {t4[12], t4[14]} = (t3[12] > t3[14]) ? {t3[14], t3[12]} : {t3[12], t3[14]};
            assign t4[0] = t3[0];
            assign t4[15] = t3[15];
            assign {t5[1], t5[2]} = (t4[1] > t4[2]) ? {t4[2], t4[1]} : {t4[1], t4[2]};
            assign {t5[3], t5[5]} = (t4[3] > t4[5]) ? {t4[5], t4[3]} : {t4[3], t4[5]};
            assign {t5[4], t5[11]} = (t4[4] > t4[11]) ? {t4[11], t4[4]} : {t4[4], t4[11]};
            assign {t5[6], t5[8]} = (t4[6] > t4[8]) ? {t4[8], t4[6]} : {t4[6], t4[8]};
            assign {t5[7], t5[9]} = (t4[7] > t4[9]) ? {t4[9], t4[7]} : {t4[7], t4[9]};
            assign {t5[10], t5[12]} = (t4[10] > t4[12]) ? {t4[12], t4[10]} : {t4[10], t4[12]};
            assign {t5[13], t5[14]} = (t4[13] > t4[14]) ? {t4[14], t4[13]} : {t4[13], t4[14]};
            assign t5[0] = t4[0];
            assign t5[15] = t4[15];
            assign {t6[2], t6[3]} = (t5[2] > t5[3]) ? {t5[3], t5[2]} : {t5[2], t5[3]};
            assign {t6[4], t6[5]} = (t5[4] > t5[5]) ? {t5[5], t5[4]} : {t5[4], t5[5]};
            assign {t6[6], t6[7]} = (t5[6] > t5[7]) ? {t5[7], t5[6]} : {t5[6], t5[7]};
            assign {t6[8], t6[9]} = (t5[8] > t5[9]) ? {t5[9], t5[8]} : {t5[8], t5[9]};
            assign {t6[10], t6[11]} = (t5[10] > t5[11]) ? {t5[11], t5[10]} : {t5[10], t5[11]};
            assign {t6[12], t6[13]} = (t5[12] > t5[13]) ? {t5[13], t5[12]} : {t5[12], t5[13]};
            assign t6[0] = t5[0];
            assign t6[1] = t5[1];
            assign t6[14] = t5[14];
            assign t6[15] = t5[15];
            assign {t7[4], t7[6]} = (t6[4] > t6[6]) ? {t6[6], t6[4]} : {t6[4], t6[6]};
            assign {t7[5], t7[7]} = (t6[5] > t6[7]) ? {t6[7], t6[5]} : {t6[5], t6[7]};
            assign {t7[8], t7[10]} = (t6[8] > t6[10]) ? {t6[10], t6[8]} : {t6[8], t6[10]};
            assign {t7[9], t7[11]} = (t6[9] > t6[11]) ? {t6[11], t6[9]} : {t6[9], t6[11]};
            assign t7[0] = t6[0];
            assign t7[1] = t6[1];
            assign t7[2] = t6[2];
            assign t7[3] = t6[3];
            assign t7[12] = t6[12];
            assign t7[13] = t6[13];
            assign t7[14] = t6[14];
            assign t7[15] = t6[15];
            assign {t8[3], t8[4]} = (t7[3] > t7[4]) ? {t7[4], t7[3]} : {t7[3], t7[4]};
            assign {t8[5], t8[6]} = (t7[5] > t7[6]) ? {t7[6], t7[5]} : {t7[5], t7[6]};
            assign {t8[7], t8[8]} = (t7[7] > t7[8]) ? {t7[8], t7[7]} : {t7[7], t7[8]};
            assign {t8[9], t8[10]} = (t7[9] > t7[10]) ? {t7[10], t7[9]} : {t7[9], t7[10]};
            assign {t8[11], t8[12]} = (t7[11] > t7[12]) ? {t7[12], t7[11]} : {t7[11], t7[12]};
            assign t8[0] = t7[0];
            assign t8[1] = t7[1];
            assign t8[2] = t7[2];
            assign t8[13] = t7[13];
            assign t8[14] = t7[14];
            assign t8[15] = t7[15];

            if (DIRECTION == 0) begin
                always_ff @( posedge clk ) begin
                    out <= t8;
                end 
            end else begin
                for (i = 0; i < SIZE; i++) begin
                    always_ff @ ( posedge clk ) begin
                        out[i] <= t8[SIZE-i-1];
                    end
                end
            end
        end
    endgenerate
endmodule