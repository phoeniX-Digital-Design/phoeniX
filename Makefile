# phoeniX Makefile
# This makefile is used in order to automate the simulation process
# of a C code on phoeniX core using RISC-V GCC toolchain.
# Winter 2024 - Iran University of Science and Technology

CORE_NAME := phoeniX
CORE_TESTBENCH := $(CORE_NAME)_Testbench.v

TOOLCHAIN_PREFIX := riscv64-unknown-elf-

MABI := ilp32
MARCH := rv32i

DHRYSTONE_FLAGS := -O3 -DTIME -DRISCV

CFLAGS := -mabi=$(MABI) -march=$(MARCH)
CFLAG_LINKING := -Wl,--gc-sections

command := $(firstword $(MAKECMDGOALS))
project := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

FIRMWARE_DIR := Firmware
SOFTWARE_DIR := Software
SAMPLE_C_DIR := Sample_C_Codes
USER_CODE_DIR := User_Codes
DHRYSTONE_DIR := Dhrystone

################################
#   Code Execution Make Flow   #
################################

ifeq ($(command), sample)	
    PROJECT_DIR := $(SOFTWARE_DIR)/$(SAMPLE_C_DIR)/$(project)
else ifeq ($(command), code)
	PROJECT_DIR := $(SOFTWARE_DIR)/$(USER_CODE_DIR)/$(project)
endif

SOURCE_C := $(wildcard $(PROJECT_DIR)/*.c)
OBJECT_C := $(basename $(SOURCE_C)).o

SOURCE_S := $(wildcard $(PROJECT_DIR)/*.s $(PROJECT_DIR)/*.S)
OBJECT_S := $(addsuffix .o, $(basename $(SOURCE_S)))

sample code: firmware.hex
	@echo "Running project "$(project)"\n"
	@rm -rf $(PROJECT_DIR)/*.tmp $(PROJECT_DIR)/*.mem $(PROJECT_DIR)/*.o $(PROJECT_DIR)/*.elf
	@iverilog -IModules -DFIRMWARE=\"$(PROJECT_DIR)/$(project)_firmware.hex\" -o $(CORE_NAME).vvp $(CORE_TESTBENCH)
	@vvp $(CORE_NAME).vvp 

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
	@$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) -o $@ $<

$(OBJECT_S): $(SOURCE_S)
	@$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) -o $@ $<

view:
	@gtkwave $(CORE_NAME).gtkw

###########################
#	Dhrystone Make Flow	  #
###########################

DHRYSTONE_SOURCE := $(DHRYSTONE_DIR)/dhry_1.c $(DHRYSTONE_DIR)/dhry_2.c
DHRYSTONE_OBJECTS := $(DHRYSTONE_DIR)/dhry_1.o $(DHRYSTONE_DIR)/dhry_2.o

dhrystone: dhrystone_firmware.hex	
	@echo "Running Dhrystone benchmark ..."
	@rm -rf $(DHRYSTONE_DIR)/*.tmp $(DHRYSTONE_DIR)/*.mem $(DHRYSTONE_DIR)/*.o $(DHRYSTONE_DIR)/*.elf $(FIRMWARE_DIR)/*.o
	@iverilog -IModules -DFIRMWARE=\"$(DHRYSTONE_DIR)/dhrystone_firmware.hex\" -DDHRYSTONE_LOG -o $(CORE_NAME).vvp $(CORE_TESTBENCH)
	@vvp $(CORE_NAME).vvp
	

dhrystone_firmware.hex: dhrystone_start.elf dhrystone_firmware.elf
	@cat $(DHRYSTONE_DIR)/dhrystone_start.tmp $(DHRYSTONE_DIR)/dhrystone_firmware.tmp > $(DHRYSTONE_DIR)/dhrystone_firmware.mem
	@python3 $(FIRMWARE_DIR)/hex_converter.py $(DHRYSTONE_DIR)/dhrystone_firmware.mem > $(DHRYSTONE_DIR)/dhrystone_firmware.hex

dhrystone_firmware.elf: 
	@$(TOOLCHAIN_PREFIX)gcc -c $(DHRYSTONE_FLAGS) $(CFLAGS) -Wno-implicit-int -Wno-implicit-function-declaration -o $(DHRYSTONE_DIR)/dhry_1.o $(DHRYSTONE_DIR)/dhry_1.c
	@$(TOOLCHAIN_PREFIX)gcc -c $(DHRYSTONE_FLAGS) $(CFLAGS) -Wno-implicit-int -Wno-implicit-function-declaration -o $(DHRYSTONE_DIR)/dhry_2.o $(DHRYSTONE_DIR)/dhry_2.c

	@$(TOOLCHAIN_PREFIX)gcc -c $(DHRYSTONE_FLAGS) $(CFLAGS) -o $(FIRMWARE_DIR)/syscalls.o $(FIRMWARE_DIR)/syscalls.c
	@$(TOOLCHAIN_PREFIX)gcc -c $(DHRYSTONE_FLAGS) $(CFLAGS) -o $(FIRMWARE_DIR)/stdlib.o $(FIRMWARE_DIR)/stdlib.c

	@$(TOOLCHAIN_PREFIX)gcc $(DHRYSTONE_FLAGS) $(CFLAGS) -Wl,-Bstatic,-T,$(FIRMWARE_DIR)/riscv.ld,--strip-debug -o $(DHRYSTONE_DIR)/dhrystone_firmware.elf $(DHRYSTONE_OBJECTS) $(FIRMWARE_DIR)/stdlib.o $(FIRMWARE_DIR)/syscalls.o -lgcc -lc
	@$(TOOLCHAIN_PREFIX)objcopy -O verilog $(DHRYSTONE_DIR)/dhrystone_firmware.elf $(DHRYSTONE_DIR)/dhrystone_firmware.tmp
	@$(TOOLCHAIN_PREFIX)objdump -d $(DHRYSTONE_DIR)/dhrystone_firmware.elf > $(DHRYSTONE_DIR)/dhrystone_firmware.txt

dhrystone_start.elf:
	@$(TOOLCHAIN_PREFIX)gcc $(DHRYSTONE_FLAGS) $(CFLAGS) -nostdlib -o $(DHRYSTONE_DIR)/dhrystone_start.elf $(FIRMWARE_DIR)/start.s -T $(FIRMWARE_DIR)/start.ld -lstdc++
	@$(TOOLCHAIN_PREFIX)objcopy -O verilog $(DHRYSTONE_DIR)/dhrystone_start.elf $(DHRYSTONE_DIR)/dhrystone_start.tmp

.PHONY: dhrystone

-include *.d

%::
	@true