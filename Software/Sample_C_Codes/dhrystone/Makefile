USE_MYSTDLIB = 0
OBJS = dhry_1.o dhry_2.o stdlib.o start.o
CFLAGS = -MD -O3 -mabi=ilp32 -march=rv32im -DTIME -DRISCV
TOOLCHAIN_PREFIX = riscv64-unknown-elf-

ifeq ($(USE_MYSTDLIB),1)
CFLAGS += -DUSE_MYSTDLIB -ffreestanding -nostdlib
OBJS += start.o
else
OBJS += syscalls.o
endif

test: testbench.vvp dhry.hex
	vvp -N testbench.vvp

testbench.vvp: testbench.v ../picorv32.v
	iverilog -o testbench.vvp testbench.v ../picorv32.v
	chmod -x testbench.vvp

dhry.hex: dhry.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $< $@

ifeq ($(USE_MYSTDLIB),1)
dhry.elf: $(OBJS) sections.lds
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -Wl,-Bstatic,-T,sections.lds,-Map,dhry.map,--strip-debug -o $@ $(OBJS) -lgcc
	chmod -x $@
else
dhry.elf: $(OBJS)
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -Wl,-Bstatic,-T,riscv.ld,-Map,dhry.map,--strip-debug -o $@ $(OBJS) -lgcc -lc
	chmod -x $@
endif

%.o: %.c
	@echo "Compiling C files\n"
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) -o $@ $<

%.o: %.S
	@echo "Compiling ASM files\n"
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) -o $@ $<

dhry_1.o dhry_2.o: CFLAGS += -Wno-implicit-int -Wno-implicit-function-declaration

clean:
	rm -rf *.o *.d dhry.elf dhry.map dhry.bin dhry.hex testbench.vvp testbench.vcd timing.vvp timing.txt testbench_nola.vvp

.PHONY: test clean

-include *.d

