module sorter #(
    parameter VALUE_BITS = 8,
    parameter DEPTH = 2,
    parameter DIRECTION = 0,
    parameter SIZE = 1 << DEPTH // Do not override
) (
    input logic clk,

    input logic [SIZE-1:0][VALUE_BITS-1:0] in,
    output logic [SIZE-1:0][VALUE_BITS-1:0] out
);
    genvar i;
    generate
        if (DEPTH > 2) begin
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
            logic [3:0][VALUE_BITS-1:0] t0;
            logic [3:0][VALUE_BITS-1:0] t1;
            logic [3:0][VALUE_BITS-1:0] t2;
            assign {t0[0], t0[1]} = (in[0] > in[1]) ? {in[1], in[0]} : {in[0], in[1]};
            assign {t0[2], t0[3]} = (in[2] > in[3]) ? {in[3], in[2]} : {in[2], in[3]};
            assign {t1[0], t1[2]} = (t0[0] > t0[2]) ? {t0[2], t0[0]} : {t0[0], t0[2]};
            assign {t1[1], t1[3]} = (t0[1] > t0[3]) ? {t0[3], t0[1]} : {t0[1], t0[3]};
            assign t2[0] = t1[0];
            assign {t2[1], t2[2]} = (t1[1] > t1[2]) ? {t1[2], t1[1]} : {t1[1], t1[2]};
            assign t2[3] = t1[3];
            
            if (DIRECTION == 0) begin
                always_ff @( posedge clk ) begin
                    out <= t2;
                end 
            end else begin
                for (i = 0; i < SIZE; i++) begin
                    always_ff @ ( posedge clk ) begin
                        out[i] <= t2[SIZE-i-1];
                    end
                end
            end
        end
    endgenerate
endmodule