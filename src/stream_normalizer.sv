module stream_normalizer #(
    parameter DATA_BYTES;
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
    output logic in_last,
    output logic out_valid,
    input logic out_ready
);
    localparam DATA_BITS = DATA_BYTES * 8;
    localparam CNT_BITS = $clog2(DATA_BYTES);

    logic [DATA_BITS-1:0] overflow;
    logic [CNT_BITS-1:0] overflow_cnt; // implicit MSB
    logic [CNT_BITS:0] total_cnt;
    logic last;

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (in_ready && in_valid) begin
                overflow_cnt <= total_cnt[CNT_BITS-1:0];
                last <= in_last;
                if (total_cnt >= DATA_BYTES) begin
                    overflow <= in_data[DATA_BITS-total_cnt[CNT_BITS-1:0]*8+:DATA_BITS];
                end else begin
                    overflow[overflow_cnt*8+:DATA_BITS] <= in_data;
                end
            end else if (out_ready && out_valid && out_last) begin
                overflow_cnt <= 0;
                last <= 0; 
            end
        end else begin
            overflow_cnt <= 0;
            last <= 0;
        end
    end

    always_comb begin
        total_cnt = overflow_cnt;
        if (in_valid) begin
            total_cnt = total_cnt + (in_cnt == 0 ? DATA_BYTES : in_cnt);
        end
    end

    assign in_ready = out_ready || total_cnt < DATA_BYTES;

    always_comb begin
        out_data = overflow;
        out_data[overflow_cnt*8+:DATA_BITS] = in_data;

        out_cnt = out_last ? total_cnt[CNT_BITS-1:0] : 0;

        out_valid = total_cnt >= DATA_BYTES || in_last || last;
        out_last = (in_last && total_cnt <= DATA_BYTES) || last;
    end
endmodule