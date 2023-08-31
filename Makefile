# Makefile

# C source and object files
SOURCE = code.c
OBJECT = code.o

# RISC-V toolchain directives
TOOLCHAIN_PREFIX = riscv64-unknown-elf-
CFLAGS = -mabi=ilp32 -march=rv32i

# Verilog files decleration
CORE_NAME    = phoeniX
VERILOG_CORE = phoeniX.v
VERILOG_TB   = phoeniX_Testbench.v

# Exection process
test: phoeniX.vvp firmware32.hex
	  vvp -N phoeniX.vvp

phoeniX.vvp: $(VERILOG_TB) $(VERILOG_CORE)
	iverilog -o $(CORE_NAME).vvp $(VERILOG_TB) $(VERILOG_CORE)
	chmod -x $(CORE_NAME).vvp

firmware32.hex: firmware.hex
	python3 hex8tohex32.py $< > $@

firmware.hex: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $< $@

firmware.elf: $(OBJECT)
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -Wl,--gc-sections -o $< $@ -T riscv.ld -lstdc++
	chmod -x $@

$(OBJECT): $(SOURCE)
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) -o $@ $<  

%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) $<

%.o: %.S
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) $<