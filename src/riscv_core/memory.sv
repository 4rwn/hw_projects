module memory #(
    parameter SIZE = 1024
) (
    input logic clk,

    input logic [31:0] rd_addr,
    output logic [31:0] rd_data,

    // Writes of different byte lengths are supported:
    // wr == 2'h0: No write
    // wr == 2'h1: Write 1 byte
    // wr == 2'h2: Write 2 bytes
    // wr == 2'h3: Write 4 bytes
    input logic [1:0] wr,
    input logic [31:0] wr_addr,
    input logic [31:0] wr_data
);
    localparam ADDR_BITS = $clog2(SIZE);
    
    logic [7:0] mem [SIZE-1:0]; // byte-addressable

    logic [ADDR_BITS-1:0] _rd_addr;
    logic [ADDR_BITS-1:0] _wr_addr;
    assign _rd_addr = rd_addr[ADDR_BITS-1:0];
    assign _wr_addr = wr_addr[ADDR_BITS-1:0];

    always_ff @( posedge clk ) begin
        // Read (always 4 bytes)
        rd_data[7:0] <= mem[_rd_addr];
        rd_data[15:8] <= mem[_rd_addr + 1];
        rd_data[23:16] <= mem[_rd_addr + 2];
        rd_data[31:24] <= mem[_rd_addr + 3];

        // Write (0, 1, 2, or 4 bytes)
        if (wr > 0) mem[_wr_addr] <= wr_data[7:0];
        if (wr > 1) mem[_wr_addr + 1] <= wr_data[15:8];
        if (wr > 2) begin
            mem[_wr_addr + 2] <= wr_data[23:16];
            mem[_wr_addr + 3] <= wr_data[31:24];
        end
    end
endmodule