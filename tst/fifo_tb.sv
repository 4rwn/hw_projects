`timescale 1ns / 1ps

module fifo_tb;
    logic clk = 0;
    always #10 clk = ~clk;

    logic rst_n;
    
    logic [7:0] in_data;
    logic in_valid;
    logic in_ready;
    logic [7:0] out_data;
    logic out_valid;
    logic out_ready;

    fifo dut ( 
        .clk(clk),
        .rst_n(rst_n),

        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),

        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready)
    );

    task write_fifo(logic [7:0] d);
        in_data = d;
        in_valid = 1;
        cycle_start();
        while(in_ready != 1'b1) begin cycle_wait(); cycle_start(); end
        cycle_wait();
        in_valid = 0;
    endtask

    task read_fifo(logic [7:0] expected);
        out_ready = 1;
        cycle_start();
        while(out_valid != 1'b1) begin cycle_wait(); cycle_start(); end
        cycle_wait();
        assert (out_data == expected);
        out_ready = 0;
    endtask

    task write_and_read(logic [7:0] d, logic [7:0] expected);
        in_data = d;
        out_ready = 1;
        in_valid = 1;
        cycle_start();
        while(out_valid != 1'b1 || in_ready != 1'b1) begin cycle_wait(); cycle_start(); end
        cycle_wait();
        assert (out_data == expected);
        out_ready = 0;
        in_valid = 0;
    endtask
    
    initial begin
        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, fifo_tb);

        in_valid = 0;
        out_ready = 0;
        rst_n = 0;
        repeat (2) @( posedge clk );
        rst_n = 1;

        assert (out_valid == 0);
        assert (in_ready == 1);

        write_fifo(8'hfe);
        @( posedge clk );
        assert (out_valid == 1);

        write_fifo(8'hed);
        write_fifo(8'hdc);
        write_fifo(8'hcb);
        write_fifo(8'hba);
        write_fifo(8'ha9);
        write_fifo(8'h98);
        write_fifo(8'h87);
        @( posedge clk );
        assert (in_ready == 0);

        // Write + read on full
        write_and_read(8'h01, 8'hfe);

        read_fifo(8'hed);
        read_fifo(8'hdc);
        read_fifo(8'hcb);
        read_fifo(8'hba);
        read_fifo(8'ha9);
        read_fifo(8'h98);
        read_fifo(8'h87);
        read_fifo(8'h01);
        @( posedge clk );
        assert (out_valid == 0);

        write_fifo(8'h76);
        write_and_read(8'h65, 8'h76);
        read_fifo(8'h65);
        @( posedge clk );
        assert (out_valid == 0);

        // Write + read on empty
        write_and_read(8'h54, 8'h54);

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