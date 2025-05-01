module uart_rx #(
    parameter BAUD_RATE = 115200
) (
    input logic clk,
    input logic rst_n,
    
    output logic [7:0] out_data,
    output logic out_valid,
    input logic out_ready,

    input logic in
);
    typedef enum {
        IDLE, // Wait for start bit
        START, // Wait for data
        DATA, // Receive data
        STOP // Receive stop bit
    } state_t;

    localparam CLK_FREQ_HZ = 50_000_000;
    localparam BAUD_CYCLES = CLK_FREQ_HZ / BAUD_RATE;
    localparam CYCLE_CNT_WIDTH = $clog2(BAUD_CYCLES);
    
    logic [7:0] fifo_in_data;
    logic fifo_in_valid;
    logic fifo_in_ready;

    fifo out_buffer ( 
        .clk(clk),
        .rst_n(rst_n),

        .in_data(fifo_in_data),
        .in_valid(fifo_in_valid),
        .in_ready(fifo_in_ready),

        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready)
    );

    state_t state;
    logic [2:0] idx;
    logic [CYCLE_CNT_WIDTH:0] cycle_cnt;

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            case (state)
                IDLE: begin
                    if (in == 0) begin
                        idx <= 0;
                        cycle_cnt <= 0;
                        state <= START;
                    end
                end

                START: begin
                    if (cycle_cnt == BAUD_CYCLES/2) begin
                        if (in == 1) begin
                            state <= IDLE;
                        end else begin
                            cycle_cnt <= cycle_cnt + 1;
                        end
                    end else if (cycle_cnt >= BAUD_CYCLES) begin
                        state <= DATA;
                        cycle_cnt <= 0;
                    end else begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                end

                DATA: begin
                    if (cycle_cnt == BAUD_CYCLES/2) begin
                        fifo_in_data[idx] <= in;
                        idx <= idx + 1;
                        cycle_cnt <= cycle_cnt + 1;
                    end else if (cycle_cnt >= BAUD_CYCLES) begin
                        if (idx == 0) begin
                            state <= STOP;
                            if (!fifo_in_valid) begin
                                fifo_in_valid <= 1;
                            end
                        end
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
            state <= IDLE;
            fifo_in_valid <= 0;
        end
    end

    always_ff @( posedge clk ) begin
        if (fifo_in_ready && fifo_in_valid) begin
            fifo_in_valid <= 0;
        end        
    end
endmodule