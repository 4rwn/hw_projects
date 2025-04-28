`timescale 1ns / 1ps

module fifo_tb;
    logic clk = 0;
    always #10 clk = ~clk;

    logic rst_n;
    
    logic [63:0] in_data;
    logic [2:0] in_cnt;
    logic in_last;
    logic in_valid;
    logic in_ready;
    logic [63:0] out_data;
    logic [2:0] out_cnt;
    logic out_last;
    logic out_valid;
    logic out_ready;

    stream_normalizer #(
        .DATA_BYTES(8)
    ) dut ( 
        .clk(clk),
        .rst_n(rst_n),

        .in_data(in_data),
        .in_cnt(in_cnt),
        .in_last(in_last),
        .in_valid(in_valid),
        .in_ready(in_ready),

        .out_data(out_data),
        .out_cnt(out_cnt),
        .out_last(out_last),
        .out_valid(out_valid),
        .out_ready(out_ready)
    );

    logic [63:0] actual_data;
    logic [2:0] actual_cnt;
    logic actual_last;

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (out_valid && out_ready) begin
                actual_data <= out_data;
                actual_cnt <= out_cnt;
                actual_last <= out_last;
            end
        end
    end

    task put(logic [63:0] new_data, logic[2:0] new_cnt, logic new_last);
        in_data = new_data;
        in_cnt = new_cnt;
        in_last = new_last;
        in_valid = 1;
        cycle_start();
        while(in_ready != 1'b1) begin cycle_wait(); cycle_start(); end
        cycle_wait();
        in_valid = 0;
    endtask

    task check(logic [63:0] expected_data, logic[2:0] expected_cnt, logic expected_last);
        assert (out_data == expected_data);
        assert (out_cnt == expected_cnt);
        assert (out_last == expected_last);
    endtask
    
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, fifo_tb);

        in_valid = 0;
        out_ready = 0;
        rst_n = 0;
        repeat (2) @( posedge clk );
        rst_n = 1;

        assert (out_valid == 0);
        assert (in_ready == 1);

        

        $finish;
    end

    // Cycle start
    task cycle_start;
        #2ns;
    endtask

    // Cycle wait
    task cycle_wait;
        @(posedge clk);
    endtask
endmodule