`timescale 1ns / 1ps

module stream_normalizer_tb;
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
    logic [31:0] transmission_cnt;

    always_ff @( posedge clk ) begin
        if (rst_n) begin
            if (out_valid && out_ready) begin
                actual_data <= out_data;
                actual_cnt <= out_cnt;
                actual_last <= out_last;
                transmission_cnt <= transmission_cnt + 1;
            end
        end else begin
            transmission_cnt <= 0;
        end
    end

    task put(logic [63:0] new_data, logic[2:0] new_cnt, logic new_last);
        in_data = new_data;
        in_cnt = new_cnt;
        in_last = new_last;
        in_valid = 1;
        cycle_start();
        while(in_ready != 1) begin cycle_wait(); cycle_start(); end
        cycle_wait();
        in_valid = 0;
    endtask

    task check(logic [63:0] expected_data, logic [2:0] expected_cnt, logic expected_last, logic [31:0] n);
        cycle_start();
        assert (actual_data ==? expected_data) else $error("Assertion error on check %d: Was %x expected %x.", n, actual_data, expected_data);
        assert (actual_cnt == expected_cnt) else $error("Assertion error on check %d: Was %x expected %x.", n, actual_cnt, expected_cnt);
        assert (actual_last == expected_last) else $error("Assertion error on check %d: Was %x expected %x.", n, actual_last, expected_last);
        assert (transmission_cnt == n) else $error("Assertion error on check %d: Was %x expected %x.", n, transmission_cnt, n);
        cycle_wait();
    endtask
    
    initial begin
        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, stream_normalizer_tb);

        in_valid = 0;
        out_ready = 0;
        rst_n = 0;
        repeat (2) cycle_wait();
        rst_n = 1;
        out_ready = 1;
        
        // Full transmission split in two.
        put(64'h0123456789abcdef, 3'd4, 1'b0);
        cycle_start();
        assert (transmission_cnt == 0);
        cycle_wait();
        put(64'h0123456789abcdef, 3'd4, 1'b1);
        check(64'h89abcdef89abcdef, 3'd0, 1'b1, 1);
        cycle_wait();

        // Two partial transmissions exceeding the length of a single one.
        put(64'h0123456789abcdef, 3'd7, 1'b0);
        put(64'h0123456789abcdef, 3'd7, 1'b1);
        out_ready = 0;
        check(64'hef23456789abcdef, 3'd0, 1'b0, 2);
        cycle_start();
        assert (in_ready == 0);
        assert (out_valid == 1 && out_last == 1);
        assert (transmission_cnt == 2);
        cycle_wait();
        out_ready = 1;
        cycle_wait();
        check(64'hxxxx23456789abcd, 3'd6, 1'b1, 3);
        cycle_wait();

        // Single, partial, terminal transmission.
        put(64'h0123456789abcdef, 3'd4, 1'b1);
        check(64'hxxxxxxxx89abcdef, 3'd4, 1'b1, 4);
        cycle_wait();

        // Single, full, terminal transmission.
        put(64'h0123456789abcdef, 3'd0, 1'b1);
        check(64'h0123456789abcdef, 3'd0, 1'b1, 5);
        cycle_wait();

        // Full transmission on top of a partial one.
        put(64'h0123456789abcdef, 3'd7, 1'b0);
        put(64'h0123456789abcdef, 3'd0, 1'b1);
        check(64'hef23456789abcdef, 3'd0, 1'b0, 6);
        check(64'hxx0123456789abcd, 3'd7, 1'b1, 7);
        cycle_wait();

        // Full transmission split in 8 parts.
        out_ready = 0;
        put(64'h0123456789abcdef, 3'd1, 1'b0);
        put(64'h0123456789abcdef, 3'd1, 1'b0);
        put(64'h0123456789abcdef, 3'd1, 1'b0);
        put(64'h0123456789abcdef, 3'd1, 1'b0);
        put(64'h0123456789abcdef, 3'd1, 1'b0);
        put(64'h0123456789abcdef, 3'd1, 1'b0);
        cycle_start();
        assert (in_ready == 1);
        cycle_wait();
        put(64'h0123456789abcdef, 3'd1, 1'b0);
        in_valid = 1;
        cycle_start();
        assert (in_ready == 0);
        assert (transmission_cnt == 7);
        cycle_wait();
        in_valid = 0;
        out_ready = 1;
        put(64'h0123456789abcdef, 3'd1, 1'b1);
        check(64'hefefefefefefefef, 3'd0, 1'b1, 8);
        cycle_wait();

        // Two partial transmission with length less than a single full one.
        put(64'h0123456789abcdef, 3'd3, 1'b0);
        put(64'h0123456789abcdef, 3'd3, 1'b1);
        check(64'hxxxxabcdefabcdef, 3'd6, 1'b1, 9);
        cycle_wait();

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