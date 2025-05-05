module merger #(
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

        for (i = 0; i < SIZE/2; i++) begin
            if (DIRECTION == 0) begin
                always_ff @( posedge clk ) begin
                    if (in[i] < in[i + SIZE/2]) begin
                        intermediate[i] <= in[i];
                        intermediate[i + SIZE/2] <= in[i + SIZE/2];
                    end else begin
                        intermediate[i] <= in[i + SIZE/2];
                        intermediate[i + SIZE/2] <= in[i];
                    end
                end
            end else begin
                always_ff @( posedge clk ) begin
                    if (in[i] < in[i + SIZE/2]) begin
                        intermediate[i] <= in[i + SIZE/2];
                        intermediate[i + SIZE/2] <= in[i];
                    end else begin
                        intermediate[i] <= in[i];
                        intermediate[i + SIZE/2] <= in[i + SIZE/2];
                    end
                end
            end
        end

        merger #(
            .VALUE_BITS(VALUE_BITS),
            .DEPTH(DEPTH - 1),
            .DIRECTION(DIRECTION)
        ) first_merger (
            .clk(clk),

            .in(intermediate[SIZE/2-1:0]),
            .out(out[SIZE/2-1:0])
        );

        merger #(
            .VALUE_BITS(VALUE_BITS),
            .DEPTH(DEPTH - 1),
            .DIRECTION(DIRECTION)
        ) second_merger (
            .clk(clk),

            .in(intermediate[SIZE-1:SIZE/2]),
            .out(out[SIZE-1:SIZE/2])
        );
    end else begin
        sorter #(
            .VALUE_BITS(VALUE_BITS),
            .DEPTH(DEPTH),
            .DIRECTION(DIRECTION)
        ) base_case (
            .clk(clk),
            
            .in(in),
            .out(out)
        );
    end
    endgenerate
endmodule