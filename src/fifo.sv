/*
    Queue (First-In-First-Out) datastructure with configurable data bit width and size.

    Concurrent reads and writes are supported.
    Reads [Writes] on empty [full] are possible iff there is a concurrent write [read].
*/
module fifo #(
    parameter WIDTH = 8,
    parameter SIZE = 8
) (
    input logic clk,
    input logic rst_n,

    input logic [WIDTH-1:0] in_data,
    input logic in_valid,
    output logic in_ready,

    output logic [WIDTH-1:0] out_data,
    output logic out_valid,
    input logic out_ready
);
    localparam PTR_WIDTH = $clog2(SIZE);

    logic [SIZE-1:0][WIDTH-1:0] data;
    logic [PTR_WIDTH-1:0] first_ptr;
    logic [PTR_WIDTH-1:0] last_ptr;
    logic [PTR_WIDTH:0] cnt;
    
    logic empty;
    logic full;

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (in_ready && in_valid) begin
                data[last_ptr] <= in_data;
                last_ptr <= last_ptr + 1;
                if (out_valid && out_ready) begin
                    first_ptr <= first_ptr + 1;
                end else begin
                    cnt <= cnt + 1;
                end
            end else if (out_valid && out_ready) begin
                first_ptr <= first_ptr + 1;
                cnt <= cnt - 1;
            end
        end else begin
            first_ptr <= 0;
            last_ptr <= 0;
            cnt <= 0;
        end
    end

    assign empty = cnt == 0;
    assign full = cnt == SIZE;

    assign out_data = empty ? in_data : data[first_ptr];

    assign in_ready = !full || (out_ready && out_valid);
    assign out_valid = !empty || (in_ready && in_valid);
endmodule