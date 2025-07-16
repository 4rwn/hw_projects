SRC = $(abspath src)
TST = $(abspath tst)
SIM = $(abspath sim)

PROGRAM_FILE ?= $(TST)/test.s

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
	riscv32-unknown-elf-as -o $(SIM)/tmp.o $(PROGRAM_FILE)
	riscv32-unknown-elf-ld -Ttext=0x0 --no-relax -o $(SIM)/tmp.elf $(SIM)/tmp.o
	riscv32-unknown-elf-objcopy -O binary $(SIM)/tmp.elf $(SIM)/tmp.bin
	hexdump -v -e '1/1 "%02x\n"' $(SIM)/tmp.bin > $(SIM)/tmp.hex
	iverilog -g2012 -I$(SRC)/riscv_core/include -o $(SIM)/out $(SRC)/riscv_core/* $(TST)/riscv_core_tb.sv
	vvp sim/out +PROGRAM_FILE=$(SIM)/tmp.hex $(if $(DATA_FILE),+DATA_FILE=$(DATA_FILE)) $(if $(EXPECTED),+EXPECTED=$(EXPECTED))
	@echo "Done."

core_ts:
	@for program in $(shell cd $(TST)/riscv_programs && ls); do \
		echo "Running $$program"; \
		for test in $$(cd $(TST)/riscv_programs/$$program && ls -d t*); do \
			output=$$( \
				if [ -f $(TST)/riscv_programs/$$program/$$test/data.hex ]; then \
					make core PROGRAM_FILE=$(TST)/riscv_programs/$$program/code.s DATA_FILE=$(TST)/riscv_programs/$$program/$$test/data.hex EXPECTED=$(TST)/riscv_programs/$$program/$$test/expected.hex 2>&1; \
				else \
					make core PROGRAM_FILE=$(TST)/riscv_programs/$$program/code.s EXPECTED=$(TST)/riscv_programs/$$program/$$test/expected.hex 2>&1; \
				fi \
			); \
			errors=$$(echo "$$output" | grep -i "error"); \
			if [ -n "$$errors" ]; then \
				echo "\033[0;31m[$$test] FAILED\033[0m"; \
				echo "$$errors"; \
			else \
				echo "\033[0;32m[$$test] OK\033[0m"; \
			fi; \
		done; \
		echo; \
	done

view:
	gtkwave $(SIM)/waveform.vcd $(TST)/view.gtkw

clean:
	rm -rf $(SIM)/*