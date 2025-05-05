module sorter #( // 55 cycles
    parameter VALUE_BITS = 8,
    parameter DEPTH = 1,
    parameter DIRECTION = 0,
    parameter SIZE = 1 << DEPTH // Do not override
) (
    input logic clk,

    input logic [SIZE-1:0][VALUE_BITS-1:0] in,
    output logic [SIZE-1:0][VALUE_BITS-1:0] out
);
    if (DEPTH > 1) begin
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
        if (DIRECTION == 0) begin
            always_ff @( posedge clk ) begin
                if (in[0] < in[1]) begin
                    out[0] <= in[0];
                    out[1] <= in[1];
                end else begin
                    out[0] <= in[1];
                    out[1] <= in[0];
                end
            end
        end else begin
            always_ff @( posedge clk ) begin
                if (in[0] < in[1]) begin
                    out[0] <= in[1];
                    out[1] <= in[0];
                end else begin
                    out[0] <= in[0];
                    out[1] <= in[1];
                end
            end
        end
    end
    
endmodule