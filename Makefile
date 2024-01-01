# phoeniX Makefile
# This makefile is used in order to automate the simulation process
# of a C code on phoeniX core using RISC-V GCC toolchain.
# Summer 2023 - Iran University of Science and Technology

CORE_NAME = phoeniX
CORE_TESTBENCH = $(CORE_NAME)_Testbench.v

TOOLCHAIN_PREFIX = riscv64-unknown-elf-

MABI = ilp32
MARCH = rv32im

CFLAGS = -mabi=$(MABI) -march=$(MARCH)
CFLAG_LINKING = -Wl,--gc-sections

command := $(firstword $(MAKECMDGOALS))
project := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

ifeq ($(command),sample)
    PROJECT_DIR = $(SOFTWARE_DIR)/$(SAMPLE_C_DIR)/$(project)
else ifeq ($(command),code)
	PROJECT_DIR = $(SOFTWARE_DIR)/$(USER_CODE_DIR)/$(project)
endif

FIRMWARE_DIR = Firmware
SOFTWARE_DIR = Software
SAMPLE_C_DIR = Sample_C_Codes
USER_CODE_DIR = User_Codes

SOURCE_C := $(wildcard $(PROJECT_DIR)/*.c)
OBJECT_C := $(basename $(SOURCE_C)).o

SOURCE_S := $(wildcard $(PROJECT_DIR)/*.s $(PROJECT_DIR)/*.S)
OBJECT_S := $(addsuffix .o, $(basename $(SOURCE_S)))

$(command): firmware.hex
	@echo "Running project "$(project)"\n"
	@rm -rf $(PROJECT_DIR)/*.tmp $(PROJECT_DIR)/*.mem $(PROJECT_DIR)/*.o $(PROJECT_DIR)/*.elf
	@iverilog -IModules -DFIRMWARE=\"$(PROJECT_DIR)/$(project)_firmware.hex\" -o $(CORE_NAME).vvp $(CORE_TESTBENCH)
	@vvp $(CORE_NAME).vvp 
#	gtkwave $(CORE_NAME).gtkw

firmware.hex: start.elf firmware.elf
	@echo "Creating firmware hex file\n"
	@cat $(PROJECT_DIR)/start.tmp $(PROJECT_DIR)/firmware.tmp > $(PROJECT_DIR)/firmware.mem
	@python3 $(FIRMWARE_DIR)/hex_converter.py $(PROJECT_DIR)/firmware.mem > $(PROJECT_DIR)/$(project)_firmware.hex

firmware.elf: $(OBJECT_C) $(OBJECT_S)
	@echo "Creating firmware elf file\n"
	@$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) -o $(PROJECT_DIR)/syscalls.o $(FIRMWARE_DIR)/syscalls.c
	@$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) $(CFLAG_LINKING) -o $(PROJECT_DIR)/$(project)_firmware.elf $^ $(PROJECT_DIR)/syscalls.o -T $(FIRMWARE_DIR)/riscv.ld -lstdc++
	@$(TOOLCHAIN_PREFIX)objdump -d $(PROJECT_DIR)/$(project)_firmware.elf > $(PROJECT_DIR)/$(project)_firmware.txt
	@$(TOOLCHAIN_PREFIX)objcopy -O verilog $(PROJECT_DIR)/$(project)_firmware.elf $(PROJECT_DIR)/firmware.tmp

start.elf:
	@echo "Creating start program elf file\n"
	@$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -nostdlib -o $(PROJECT_DIR)/$(project)_start.elf $(FIRMWARE_DIR)/start.s -T $(FIRMWARE_DIR)/start.ld -lstdc++
	@$(TOOLCHAIN_PREFIX)objcopy -O verilog $(PROJECT_DIR)/$(project)_start.elf $(PROJECT_DIR)/start.tmp

$(OBJECT_C): $(SOURCE_C)
	@echo "Compiling C files\n"
	@$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) -o $@ $<

$(OBJECT_S): $(SOURCE_S)
	@echo "Compiling ASM files\n"
	@$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) -o $@ $<

%::
	@true