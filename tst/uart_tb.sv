`timescale 1ns / 1ps

module uart_tb;
    logic clk = 0;
    always #10 clk = ~clk;

    logic rst_n;
    logic [7:0] in_data;
    logic in_valid;
    logic in_ready;
    logic ch;

    uart_tx tx (
        .clk(clk),
        .rst_n(rst_n),

        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),

        .out(ch)
    );

    logic [7:0] out_data;
    logic out_valid;
    logic out_ready;

    uart_rx rx (
        .clk(clk),
        .rst_n(rst_n),

        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready),

        .in(ch)
    );

    task send(logic [7:0] d);
        in_data = d;
        in_valid = 1;
        cycle_start();
        while(in_ready != 1'b1) begin cycle_wait(); cycle_start(); end
        cycle_wait();
        in_valid = 0;
    endtask 

    task receive(logic [7:0] expected);
        out_ready = 1;
        cycle_start();
        while(out_valid != 1'b1) begin cycle_wait(); cycle_start(); end
        cycle_wait();
        assert (out_data == expected);
        out_ready = 0;
    endtask

    initial begin
        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, uart_tb);
        
        in_valid = 0;
        out_ready = 0;
        rst_n = 0;
        repeat (2) @( posedge clk );
        rst_n = 1;
        @( posedge clk );

        assert (out_valid == 0);
        assert (in_ready == 1);

        send(8'hfe);
        send(8'hed);
        send(8'hdc);
        send(8'hcb);
        send(8'hba);
        send(8'ha9);
        send(8'h98);
        send(8'h87);

        receive(8'hfe);
        receive(8'hed);
        receive(8'hdc);
        receive(8'hcb);
        receive(8'hba);
        receive(8'ha9);
        receive(8'h98);
        receive(8'h87);
        @( posedge clk );

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