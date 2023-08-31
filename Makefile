# Makefile

C_SRC  = code.c
OBJECT = code.o

# RISC-V toolchain directives
TOOLCHAIN_PREFIX = riscv64-unknown-elf-
CFLAGS = -c -mabi=ilp32 -march=rv32i

VERILOG_TB = phoeniX_Testbench.v
VERILOG_CORE = phoeniX.v
CORE_NAME = phoeniX

test: phoeniX.vvp firmware.hex
	  vvp -N phoeniX.vvp

phoeniX.vvp: $(VERILOG_TB) $(VERILOG_CORE)
	iverilog -o $(CORE_NAME).vvp $(VERILOG_TB) $(VERILOG_CORE)
	chmod -x $(CORE_NAME).vvp

firmware.hex: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $< $@
