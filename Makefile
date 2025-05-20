SRC = $(abspath src)
TST = $(abspath tst)
SIM = $(abspath sim)

all : fifo uart normalizer

fifo:
	@echo "Running FIFO test bench."
	iverilog -g2012 -o $(SIM)/out $(SRC)/fifo.sv $(TST)/fifo_tb.sv
	vvp sim/out
	@echo "Done."

uart:
	@echo "Running UART test bench."
	iverilog -g2012 -o $(SIM)/out $(SRC)/fifo.sv $(SRC)/uart/* $(TST)/uart_tb.sv
	vvp sim/out
	@echo "Done."

normalizer:
	@echo "Running stream normalizer test bench."
	iverilog -g2012 -o $(SIM)/out $(SRC)/stream_normalizer.sv $(TST)/stream_normalizer_tb.sv
	vvp sim/out
	@echo "Done."

sorter:
	@echo "Running bitonic sorter test bench."
	iverilog -g2012 -o $(SIM)/out $(SRC)/bitonic_sorter/*_base6.sv $(TST)/bitonic_sorter_tb.sv
	vvp sim/out
	@echo "Done."

core:
	@echo "Running RISC-V core test bench."
	iverilog -g2012 -I$(SRC)/riscv_core/include -o $(SIM)/out $(SRC)/riscv_core/* $(TST)/riscv_core_tb.sv
	vvp sim/out
	@echo "Done."

view:
	gtkwave $(SIM)/waveform.vcd

clean:
	rm -rf $(SIM)/*