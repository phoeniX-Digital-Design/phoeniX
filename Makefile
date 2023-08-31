# Makefile

C_SRC  = code.c
OBJECT = code.o

# RISC-V toolchain directives
TOOLCHAIN_PREFIX = riscv64-unknown-elf-
CFLAGS = -c -mabi=ilp32 -march=rv32i

VERILOG_TB = phoeniX_Testbench.v
VERILOG_CORE = phoeniX.v

HEX_FILE = firmware.hex



