module uart_tx #(
    parameter BAUD_RATE = 115200
) (
    input logic clk,
    input logic rst_n,
    
    input logic [7:0] in_data,
    input logic in_valid,
    output logic in_ready,

    output logic out
);
    typedef enum {
        RESET,
        IDLE, // Wait for input data
        START, // Send start bit
        DATA, // Send data
        STOP // Send stop bit
    } state_t;

    localparam CLK_FREQ_HZ = 50_000_000;
    localparam BAUD_CYCLES = CLK_FREQ_HZ / BAUD_RATE;
    localparam CYCLE_CNT_WIDTH = $clog2(BAUD_CYCLES);

    logic [7:0] fifo_out_data;
    logic fifo_out_valid;
    logic fifo_out_ready;

    fifo in_buffer ( 
        .clk(clk),
        .rst_n(rst_n),

        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),

        .out_data(fifo_out_data),
        .out_valid(fifo_out_valid),
        .out_ready(fifo_out_ready)
    );

    state_t state;
    logic [2:0] idx;
    logic [7:0] data;
    logic [CYCLE_CNT_WIDTH:0] cycle_cnt;

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            case (state)
                RESET: begin
                    state <= IDLE;
                end

                IDLE: begin
                    if (fifo_out_ready && fifo_out_valid) begin
                        data <= fifo_out_data;
                        idx <= 0;
                        cycle_cnt <= 0;
                        state <= START;
                    end
                end

                START: begin
                    if (cycle_cnt >= BAUD_CYCLES) begin
                        state <= DATA;
                        cycle_cnt <= 0;
                    end else begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                end

                DATA: begin
                    if (cycle_cnt >= BAUD_CYCLES) begin
                        if (idx == 3'b111) begin
                            state <= STOP;
                        end
                        idx <= idx + 1;
                        cycle_cnt <= 0;
                    end else begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                end

                STOP: begin
                    if (cycle_cnt >= BAUD_CYCLES) begin
                        state <= IDLE;
                    end else begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                end
            endcase
        end else begin
            state <= RESET;
        end
    end

    assign fifo_out_ready = state == IDLE;

    always_comb begin
        if (state == START) begin
            out = 0;
        end else if (state == DATA) begin
            out = data[idx];
        end else begin
            out = 1;
        end
    end
endmodule