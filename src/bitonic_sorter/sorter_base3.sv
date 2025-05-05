module sorter #(
    parameter VALUE_BITS = 8,
    parameter DEPTH = 3,
    parameter DIRECTION = 0,
    parameter SIZE = 1 << DEPTH // Do not override
) (
    input logic clk,

    input logic [SIZE-1:0][VALUE_BITS-1:0] in,
    output logic [SIZE-1:0][VALUE_BITS-1:0] out
);
    genvar i;
    generate
        if (DEPTH > 3) begin
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
            logic [7:0][VALUE_BITS-1:0] t0;
            logic [7:0][VALUE_BITS-1:0] t1;
            logic [7:0][VALUE_BITS-1:0] t2;
            logic [7:0][VALUE_BITS-1:0] t3;
            logic [7:0][VALUE_BITS-1:0] t4;
            logic [7:0][VALUE_BITS-1:0] t5;
            assign {t0[0], t0[1]} = (in[0] > in[1]) ? {in[1], in[0]} : {in[0], in[1]};
            assign {t0[2], t0[3]} = (in[2] > in[3]) ? {in[3], in[2]} : {in[2], in[3]};
            assign {t0[4], t0[5]} = (in[4] > in[5]) ? {in[5], in[4]} : {in[4], in[5]};
            assign {t0[6], t0[7]} = (in[6] > in[7]) ? {in[7], in[6]} : {in[6], in[7]};
            assign {t1[0], t1[2]} = (t0[0] > t0[2]) ? {t0[2], t0[0]} : {t0[0], t0[2]};
            assign {t1[1], t1[3]} = (t0[1] > t0[3]) ? {t0[3], t0[1]} : {t0[1], t0[3]};
            assign {t1[4], t1[6]} = (t0[4] > t0[6]) ? {t0[6], t0[4]} : {t0[4], t0[6]};
            assign {t1[5], t1[7]} = (t0[5] > t0[7]) ? {t0[7], t0[5]} : {t0[5], t0[7]};
            assign {t2[0], t2[4]} = (t1[0] > t1[4]) ? {t1[4], t1[0]} : {t1[0], t1[4]};
            assign {t2[1], t2[5]} = (t1[1] > t1[5]) ? {t1[5], t1[1]} : {t1[1], t1[5]};
            assign {t2[2], t2[6]} = (t1[2] > t1[6]) ? {t1[6], t1[2]} : {t1[2], t1[6]};
            assign {t2[3], t2[7]} = (t1[3] > t1[7]) ? {t1[7], t1[3]} : {t1[3], t1[7]};
            assign t3[0] = t2[0];
            assign {t3[1], t3[2]} = (t2[1] > t2[2]) ? {t2[2], t2[1]} : {t2[1], t2[2]};
            assign {t3[3], t3[4]} = (t2[3] > t2[4]) ? {t2[4], t2[3]} : {t2[3], t2[4]};
            assign {t3[5], t3[6]} = (t2[5] > t2[6]) ? {t2[6], t2[5]} : {t2[5], t2[6]};
            assign t3[7] = t2[7];
            assign {t4[0], t4[1]} = (t3[0] > t3[1]) ? {t3[1], t3[0]} : {t3[0], t3[1]};
            assign {t4[2], t4[3]} = (t3[2] > t3[3]) ? {t3[3], t3[2]} : {t3[2], t3[3]};
            assign {t4[4], t4[5]} = (t3[4] > t3[5]) ? {t3[5], t3[4]} : {t3[4], t3[5]};
            assign {t4[6], t4[7]} = (t3[6] > t3[7]) ? {t3[7], t3[6]} : {t3[6], t3[7]};
            assign t5[0] = t4[0];
            assign {t5[1], t5[2]} = (t4[1] > t4[2]) ? {t4[2], t4[1]} : {t4[1], t4[2]};
            assign {t5[3], t5[4]} = (t4[3] > t4[4]) ? {t4[4], t4[3]} : {t4[3], t4[4]};
            assign {t5[5], t5[6]} = (t4[5] > t4[6]) ? {t4[6], t4[5]} : {t4[5], t4[6]};
            assign t5[7] = t4[7];
            
            if (DIRECTION == 0) begin
                always_ff @( posedge clk ) begin
                    out <= t5;
                end 
            end else begin
                for (i = 0; i < SIZE; i++) begin
                    always_ff @ ( posedge clk ) begin
                        out[i] <= t5[SIZE-i-1];
                    end
                end
            end
        end
    endgenerate
    
endmodule