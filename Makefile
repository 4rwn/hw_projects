SRC = $(abspath src)
TST = $(abspath tst)
SIM = $(abspath sim)

all : fifo uart

fifo:
	iverilog -g2012 -o $(SIM)/out $(SRC)/fifo.sv $(TST)/fifo_tb.sv
	cd $(SIM) && vvp ./out
	gtkwave $(SIM)/waveform.vcd

uart:
	iverilog -g2012 -o $(SIM)/out $(SRC)/* $(TST)/uart_tb.sv
	cd $(SIM) && vvp ./out
	gtkwave $(SIM)/waveform.vcd

clean:
	rm -rf $(SIM)/*