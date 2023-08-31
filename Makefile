# Makefile

SOURCE = code.c
OBJECT = code.o

# RISC-V toolchain directives
TOOLCHAIN_PREFIX = riscv64-unknown-elf-
CFLAGS = -c -mabi=ilp32 -march=rv32i

CORE_NAME    = phoeniX
VERILOG_CORE = phoeniX.v
VERILOG_TB   = phoeniX_Testbench.v

test: phoeniX.vvp firmware32.hex
	  vvp -N phoeniX.vvp

phoeniX.vvp: $(VERILOG_TB) $(VERILOG_CORE)
	iverilog -o $(CORE_NAME).vvp $(VERILOG_TB) $(VERILOG_CORE)
	chmod -x $(CORE_NAME).vvp

firmware32.hex: firmware.hex
	python3 hex8tohex32.py firmware.hex > $< $@ 

firmware.hex: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $< $@
