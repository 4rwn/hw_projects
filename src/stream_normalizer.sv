module stream_normalizer #(
    parameter DATA_BYTES = 8
) (
    input logic clk,
    input logic rst_n,

    input logic [DATA_BITS-1:0] in_data,
    input logic [CNT_BITS-1:0] in_cnt,
    input logic in_last,
    input logic in_valid,
    output logic in_ready,

    output logic [DATA_BITS-1:0] out_data,
    output logic [CNT_BITS-1:0] out_cnt,
    output logic out_last,
    output logic out_valid,
    input logic out_ready
);
    localparam DATA_BITS = DATA_BYTES * 8;
    localparam CNT_BITS = $clog2(DATA_BYTES);

    logic [DATA_BITS-1:0] overflow;
    logic [CNT_BITS-1:0] overflow_cnt;
    logic [CNT_BITS:0] in_cnt_ext;
    logic [CNT_BITS:0] total_cnt;
    // Is there leftover data that needs to be transmitted after the last input transmission?
    logic extra;

    // in_cnt extended to explicit MSB
    assign in_cnt_ext = in_cnt == 0 ? DATA_BYTES : in_cnt;

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (in_ready && in_valid) begin // Input handshake
                if (total_cnt > DATA_BYTES) begin // Data overflow
                    // Record overflowing input data
                    overflow <= in_data[(in_cnt_ext-total_cnt[CNT_BITS-1:0])*8+:DATA_BITS];
                    overflow_cnt <= total_cnt[CNT_BITS-1:0];
                    // If its the last transmission, an extra one will be needed for overflow
                    extra <= in_last;
                end else begin // No data overflow
                    // Add input data to overflow
                    overflow[overflow_cnt*8+:DATA_BITS] <= in_data;
                    // Internal reset on last transmission
                    overflow_cnt <= in_last ? 0 : total_cnt[CNT_BITS-1:0];
                end
            end else if (out_ready && out_valid && out_last) begin // Extra overflow transmission at the end
                // Internal reset
                overflow_cnt <= 0;
                extra <= 0; 
            end
        end else begin
            overflow_cnt <= 0;
            extra <= 0;
        end
    end

    // Total available bytes.
    always_comb begin
        total_cnt = overflow_cnt;
        if (in_valid) begin
            total_cnt = total_cnt + in_cnt_ext;
        end
    end

    assign in_ready = !extra && (out_ready || total_cnt < DATA_BYTES);

    // This variable assignment is not supported by Yosys, so use workaround.
    // out_data = overflow;
    // out_data[overflow_cnt*8+:DATA_BITS] = in_data;
    genvar i;
    generate
        for (i = 0; i < DATA_BYTES; i++) begin
            assign out_data[i*8+:8] = i < overflow_cnt ? overflow[i*8+:8] : in_data[(i-overflow_cnt)*8+:8];
        end
    endgenerate

    assign out_cnt = out_last ? (extra ? overflow_cnt : total_cnt[CNT_BITS-1:0]) : 0;
    assign out_last = (in_last && total_cnt <= DATA_BYTES) || extra;
    assign out_valid = total_cnt >= DATA_BYTES || (in_valid && in_ready && in_last) || extra;
endmodule