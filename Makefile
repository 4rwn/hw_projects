SRC = $(abspath src)
TST = $(abspath tst)
SIM = $(abspath sim)

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

compile:
	@if echo "$(PROGRAM_FILE)" | grep -qE '\.c$$'; then \
		riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -O3 -S $(PROGRAM_FILE) -o $(SIM)/tmp.s; \
	else \
		cp $(PROGRAM_FILE) $(SIM)/tmp.s; \
	fi
	riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -o $(SIM)/tmp.o $(SIM)/tmp.s
	riscv32-unknown-elf-ld -T $(TST)/link.ld -o $(SIM)/tmp.elf $(SIM)/tmp.o
	riscv32-unknown-elf-objcopy -O binary -j .text $(SIM)/tmp.elf $(SIM)/tmp.bin
	hexdump -v -e '1/1 "%02x\n"' $(SIM)/tmp.bin > $(SIM)/tmp.hex

core: $(if $(strip $(PROGRAM_FILE)), compile)
	@echo "Running RISCV core."
	iverilog -g2012 -I$(SRC)/riscv_core/include -o $(SIM)/out $(SRC)/riscv_core/* $(TST)/riscv_core_tb.sv
	vvp sim/out +PROGRAM_FILE=$(SIM)/tmp.hex $(if $(DATA_FILE),+DATA_FILE=$(DATA_FILE)) $(if $(EXPECTED),+EXPECTED=$(EXPECTED))
	@echo "Done."

core_ts:
	@for program in $(shell cd $(TST)/riscv_programs && ls); do \
		echo "Running $$program"; \
		program_file=$$(ls $(TST)/riscv_programs/$$program/main.*); \
		for test in $$(cd $(TST)/riscv_programs/$$program && ls -d t*); do \
			if [ -f $(TST)/riscv_programs/$$program/$$test/data.hex ]; then \
				output=$$(make core PROGRAM_FILE="$$program_file" DATA_FILE=$(TST)/riscv_programs/$$program/$$test/data.hex EXPECTED=$(TST)/riscv_programs/$$program/$$test/expected.hex 2>&1); \
			else \
				output=$$(make core PROGRAM_FILE="$$program_file" EXPECTED=$(TST)/riscv_programs/$$program/$$test/expected.hex 2>&1); \
			fi; \
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

core_vhdl: $(if $(strip $(PROGRAM_FILE)), compile)
	@echo "Running RISCV core (VHDL)."
	ghdl -a --workdir=$(SIM) --std=08 $(SRC)/riscv_core_vhdl/memory.vhd \
					 				  $(SRC)/riscv_core_vhdl/instruction_fetcher.vhd \
					 				  $(SRC)/riscv_core_vhdl/top.vhd \
					 				  $(SRC)/riscv_core_vhdl/riscv_core_tb.vhd
	ghdl -r --workdir=$(SIM) --std=08 riscv_core_tb --stop-time=1us --vcd=$(SIM)/waveform.vcd

view:
	gtkwave $(SIM)/waveform.vcd $(TST)/view.gtkw

clean:
	rm -rf $(SIM)/*