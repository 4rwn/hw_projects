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
    logic [CNT_BITS-1:0] overflow_cnt; // implicit MSB
    logic [CNT_BITS:0] total_cnt;
    logic extra;

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (in_ready && in_valid) begin
                if (total_cnt > DATA_BYTES) begin
                    overflow <= in_data[((in_cnt == 0 ? DATA_BYTES : in_cnt)-total_cnt[CNT_BITS-1:0])*8+:DATA_BITS];
                    overflow_cnt <= total_cnt[CNT_BITS-1:0];
                    extra <= in_last;
                end else begin
                    overflow[overflow_cnt*8+:DATA_BITS] <= in_data;
                    if (in_last) begin
                        overflow_cnt <= 0;
                    end else begin
                        overflow_cnt <= total_cnt[CNT_BITS-1:0];
                    end
                end
            end else if (out_ready && out_valid && out_last) begin
                overflow_cnt <= 0;
                extra <= 0; 
            end
        end else begin
            overflow_cnt <= 0;
            extra <= 0;
        end
    end

    always_comb begin
        total_cnt = overflow_cnt;
        if (in_valid) begin
            total_cnt = total_cnt + (in_cnt == 0 ? DATA_BYTES : in_cnt);
        end
    end

    assign in_ready = !extra && (out_ready || total_cnt < DATA_BYTES);

    assign out_cnt = out_last ? (extra ? overflow_cnt : total_cnt[CNT_BITS-1:0]) : 0;
    assign out_valid = total_cnt >= DATA_BYTES || (in_valid && in_ready && in_last) || extra;
    assign out_last = (in_last && total_cnt <= DATA_BYTES) || extra;

    // This is not supported by Yosys, so use workaround.
    // out_data = overflow;
    // out_data[overflow_cnt*8+:DATA_BITS] = in_data;
    genvar i;
    generate
        for (i = 0; i < DATA_BYTES; i++) begin
            assign out_data[i*8+:8] = i < overflow_cnt ? overflow[i*8+:8] : in_data[(i-overflow_cnt)*8+:8];
        end
    endgenerate
endmodule