SRC = $(abspath src)
TST = $(abspath tst)
SIM = $(abspath sim)

all : fifo uart normalizer

fifo:
	iverilog -g2012 -o $(SIM)/out $(SRC)/* $(TST)/fifo_tb.sv
	vvp sim/out

uart:
	iverilog -g2012 -o $(SIM)/out $(SRC)/* $(TST)/uart_tb.sv
	vvp sim/out

normalizer:
	iverilog -g2012 -o $(SIM)/out $(SRC)/* $(TST)/stream_normalizer_tb.sv
	vvp sim/out

view:
	gtkwave $(SIM)/waveform.vcd

clean:
	rm -rf $(SIM)/*