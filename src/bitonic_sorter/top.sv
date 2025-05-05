/*
    To get a timing analysis, we need to place&route the design for a device.
    The devices available with open-source software are constrained in
    logic blocks but also input/output ports. So we use dummy ports in a
    way that the synthesizer does not optimize away any logic.
*/
module top (
    input logic clk,
    input logic rst_n,

    input logic [VALUE_BITS-1:0] in_dummy,
    output logic out_dummy
);
    localparam VALUE_BITS = 32;
    localparam DEPTH = 8;
    localparam DIRECTION = 0;
    localparam SIZE = 1 << DEPTH;
  
    logic [SIZE-1:0][VALUE_BITS-1:0] in;
    logic [SIZE-1:0][VALUE_BITS-1:0] out;

    genvar i;
    generate
        for (i = 0; i < SIZE; i++) begin
            always_ff @( posedge clk ) begin
                if (rst_n) begin
                    in[i] <= {in[i][VALUE_BITS-2:0], ^in[i][VALUE_BITS-1:VALUE_BITS-4]};
                end else begin
                    in[i] <= in_dummy + i;
                end
            end
        end
    endgenerate

    sorter #(
        .VALUE_BITS(VALUE_BITS),
        .DEPTH(DEPTH),
        .DIRECTION(DIRECTION),
    ) sorter (
        .clk(clk),

        .in(in),
        .out(out)
    );

    assign out_dummy = out[0][0];
endmodule