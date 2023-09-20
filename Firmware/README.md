Firmware
============

<div align="justify">

We have developed an automated software process and simulation for the phoeniX processor, specifically designed to be user-friendly and easily accessible on Linux systems. To simplify the simulation process, we have included a Makefile in the main repository directory, which eliminates the need for a complex RISC-V GCC Toolchain flow and terminal commands. 
Our Makefile offers enhanced functionality, allowing both C and assembly codes to be executed using the original RISC-V compiler and assembler. This flexibility provides developers with greater options when working with the phoeniX processor.

The Makefile relies on essential scripts located in the `Firmware` directory, which should not be removed. Firmware dicrectory contains:
- `start.s` : Assembly code for registers initialization and stack setup
- `start.ld` : Linker script for `start.s` file
- `riscv.ld` : Linker script for RISC-V 32-bit architecture responsible for organizing the different sections of an executable in memory
- `syscall.c` : C code implementing a minimalistic set of system calls and related functions
- `hex_converter.py` : Python script to generate a Verilog standard hex file representing the instruction memory

However, users can customize these scripts to suit their specific application requirements if needed, while still ensuring the Makefile's integrity and functionality. Detailed descriptions of each script in the Firmware directory are provided below.
</div>