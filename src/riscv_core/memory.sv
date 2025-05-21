module memory #(
    parameter SIZE = 1024
) (
    input logic clk,

    input logic [31:0] rd_addr,
    output logic [31:0] rd_data,

    input logic [1:0] wr,
    input logic [31:0] wr_addr,
    input logic [31:0] wr_data
);
    localparam ADDR_BITS = $clog2(SIZE);
    
    logic [7:0] mem [SIZE-1:0];

    logic [ADDR_BITS-1:0] _rd_addr;
    logic [ADDR_BITS-1:0] _wr_addr;
    assign _rd_addr = rd_addr[ADDR_BITS-1:0];
    assign _wr_addr = wr_addr[ADDR_BITS-1:0];

    always_ff @( posedge clk ) begin
        rd_data[7:0] <= mem[_rd_addr];
        rd_data[15:8] <= mem[_rd_addr + 1];
        rd_data[23:16] <= mem[_rd_addr + 2];
        rd_data[31:24] <= mem[_rd_addr + 3];

        if (wr > 0) mem[_wr_addr] <= wr_data[7:0];
        if (wr > 1) mem[_wr_addr + 1] <= wr_data[15:8];
        if (wr > 2) begin
            mem[_wr_addr + 2] <= wr_data[23:16];
            mem[_wr_addr + 3] <= wr_data[31:24];
        end
    end

    logic [7:0] mem_probe0;
    logic [7:0] mem_probe1;
    logic [7:0] mem_probe2;
    logic [7:0] mem_probe3;
    assign mem_probe0 = mem[0];
    assign mem_probe1 = mem[1];
    assign mem_probe2 = mem[2];
    assign mem_probe3 = mem[3];
endmodule