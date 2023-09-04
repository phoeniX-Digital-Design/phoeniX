# phoeniX Makefile
# This make file is written in order to automate simulation process
# of a C code on phoeniX core using RISC-V GCC toolchain.
# Summer 2023 - Iran University of Science and Technology

# C source and object files
# Variable to store the detected C input file
SOURCE := $(wildcard *.c)
OBJECT := $(SOURCE).o

# RISC-V toolchain directives
TOOLCHAIN_PREFIX = riscv64-unknown-elf-

MABI = ilp32
MARCH = rv32i
OPT = -O3
CFLAGS = -mabi=$(MABI) -march=$(MARCH) $(OPT)

# Verilog files decleration
CORE_NAME    = phoeniX
VERILOG_CORE = phoeniX.v
VERILOG_TB   = phoeniX_Testbench.v

# Exection process
test: $(CORE_NAME).vvp firmware32.hex
	  vvp -N $(CORE_NAME).vvp

$(CORE_NAME).vvp: $(VERILOG_TB) $(VERILOG_CORE)
	iverilog -o $(CORE_NAME).vvp $(VERILOG_TB) $(VERILOG_CORE)
	chmod -x $(CORE_NAME).vvp

# Makefile location must be in Sample Codes in order to use this function
#-------------------------------
#copy_file:
#	cp ./firmware32.hex ../../  

firmware32.hex: firmware.hex
	python3 hex8tohex32.py $< > $@

firmware.hex: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $< $@

firmware.elf: $(OBJECT)
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -Wl,--gc-sections -o $@ $< -T riscv.ld -lstdc++
	chmod -x $@

$(OBJECT): $(SOURCE)
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) -o $@ $<  

%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) $<

%.o: %.S
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) $<