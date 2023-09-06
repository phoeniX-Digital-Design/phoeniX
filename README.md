phoeniX RISC-V CPU
==================
<div style="text-align: justify"> 

**phoeniX** RISC-V processor is designed in Verilog HDL based on the 32-bit Base Instrcution Set of [RISC-V Instruction Set Architecture](http://riscv.org/) and can execute `RV32I` instructions. Support for other extensions will be covered in the upcoming updates. 

You can find a list of full RISC-V assembly instructions in the [ISA Specifications Documents](https://riscv.org/technical/specifications/).

The core can be implemented as a softcore CPU on Xilinx 7 Ultrscale/Ultrascale+ series FPGA boards using logic synthesis. This allows for flexible integration of the core's functionality within the FPGA fabric. The Xilinx 7 series FPGA boards provide a versatile platform for hosting the softcore CPU implementation, offering configurable features and adaptability.

The core has undergone a complete design flow, including synthesis, routing, and post layout process, to become an Integrated Circuit using open-source tools and the [QFlow](http://opencircuitdesign.com/qflow/) and [Magic VLSI](http://opencircuitdesign.com/magic/) projects. The ASIC implementation was specifically carried out utilizing the `osu018 (TSMC 180nm)` Process Design Kit (PDK).

This repository contains an open source CPU under the [GNU V3.0 license](https://en.wikipedia.org/wiki/GNU_General_Public_License) and is free to use.

- Designed By : [Arvin Delavari](https://github.com/ArvinDelavari) and [Faraz Ghoreishy](https://github.com/FarazGhoreishy)
- Contact us : arvin7807@gmail.com - farazghoreishy@gmail.com
- Iran University of Science and Technology - Summer 2023

## Table of Contents

- [Features](#Features)
- [Directory Map](#Directory-Map)
- [phoeniX Core Structure](#phoeniX-Core-Structure)
- [phoeniX Memory Interface](#phoeniX-Memory-Interface)
- [Building RISC-V Toolchain](#Building-RISC-V-Toolchain)
- [phoeniX Execution Flow](#phoeniX-Execution-Flow)
- [Synthesis Result](#Synthesis-Result)


## Features

 - Classic 5-stage pipline
 - Distributed Control
 - Modularity

## Directory Map

The tree below provides a map to all directories and sub-directories of the repository. Detailed descriptions on contents of these directories are provided in the following sections and each specific `README.md`.
<pre style="font-size:16px">
repository/
    ├── Setup/
    │   └── setup.sh
    ├── Documents/
    │   ├── Images/
    │   └── Pdfs/
    ├── Features/
    │   ├── AXI4-Lite/
    │   ├── Branch_Prediction/
    │   ├── Clock_Genrator/
    │   └── ...
    ├── Synthesis/
    │   └── Qflow_TSMC_180nm/
    │       ├── images/
    │       ├── gds/
    │       └── ...
    ├── Modules/
    │   ├── Address_Generator.v
    │   ├── Arithmetic_Logic_Unit.v
    │   └── ...
    ├── Firmware/
    │   ├── hex_converter -> hex_converter.py
    │   ├── start_procedure -> start.s
    │   ├── start_linker -> start.ld
    │   ├── riscv_linker -> riscv.ld
    │   └── syscalls -> syscalls.c
    ├── Software/
    │   ├── Sample_Assembly_Codes/
    │   │   └── Program_directory/
    │   │       ├── Program.S
    │   │       ├── Program.txt
    │   │       └── Program_firmware.hex
    │   ├── Sample_C_Codes/
    │   │   └── Program_directory/
    │   │       ├── Program.c
    │   │       ├── Program.o
    │   │       └── Program_firmware.hex        
    │   └── User_Codes/
    │       └── Program_directory/
    │           ├── Program.c
    │           ├── Program.o
    │           └── Program_firmware.hex 
    ├── phoeniX.v
    ├── phoeniX_Testbench.v
    ├── phoeniX.vvp
    ├── phoeniX.vcd
    ├── phoeniX.gtkw
    └── Makefile
</pre>

## phoeniX Core Structure


The repository contains a collection of Verilog modules that build up the phoeniX RISC-V processor. These building block modules are included in `\Modules`.
Each modules was designed with concepts of modularity and distributed-control in mind. This deliberate approach allows for effortless replacement and configuration of individual building blocks, resulting in a simplified process.

| Module                        | Description                                                                                   |
| ----------------------------- | --------------------------------------------------------------------------------------------- |
| `Address_Generator`           | Generating address for BRANCH, JUMP and LOAD/STORE instructions                               |
| `Arithmetic_Logic_Unit`       | ALU with support for `I_TYPE` and `R_TYPE` RISC-V instructions                                |
| `Fetch_Unit`                  | Instruction Fetch logic and program counter addressing                                        | 
| `Hazard_Forward_Unit`         | Hazard detection and data forwarding logic in pipelined processor                             |
| `Immediate_Generator`         | Generating immediate values according to instructions type                                    |
| `Instruction_Decoder`         | Decoding instructions and extracting `opcode`, `funct` and `imm` fields                       |
| `Jump_Branch_Unit`            | Condition checking for all branch instructions                                                |
| `Load_Store_Unit`             | Load and Store operations for aligned addresses and wordsize management                       |
| `Register_File`               | Parametrized register file suitable for GP registers and CSRs (2 read & 1 write ports)        |


The `phoeniX.v` contains the main phoeniX RISC-V core and is included in the top directory of this repo:
| Module                        | Description                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------- |
| `phoeniX`                     | phoeniX 32 bit RISC-V core (RV32I) top Verilog module                        |
| `phoeniX_Testbench`           | phoeniX testbench module including main core, memory and interface logic     |

## phoeniX Memory Interface

phoeniX currently supports 32-bit word memories with synchronized access time. The core always addresses memory by a word aligned address and access a four byte frame from memory which is then operated on based on a `frame_mask` for half-word and byte operations.

*Unaligned Memory Accesses:* phoeniX Load Store Unit does not support misaligned accesses. At the moment we are working to add support accesses that are not aligned on word boundaries by implementing the procedure with multiple separate aligned accesses requring additional clock cycles.

## Building RISC-V Toolchain
You can use the scripts provided in the original RISC-v repositories and [riscv-tools](https://github.com/riscv/riscv-tools). The default settings in the original repos build scripts will build a compiler, assembler and linker that can target any RISC-V ISA.
You can also use the provided shell script in `/Setup`. All shell scripts and Makefiles provided in this repository target Ubuntu 20.04 unless otherwise specified. Simply run the `setup.sh` from your terminal, it will automatically install the required prequistes, iVerilog version 12 and gtkwave.

```console
user@Ubuntu:~$ git clone https://github.com/ArvinDelavari/phoeniX-RV32.git
user@Ubuntu:~$ cd Setup
user@Ubuntu:~$ chmod +x setup.sh
user@Ubuntu:~$ ./setup.sh
```
Using your favorite editor open `.bashrc` file from the `home` directory of your ubuntu. Replace `{user}` with your own user name and add the following lines to the end of file. This will your PATH environment variable and is required to run `RISC-V GNU Compiler` automatically without exporting `PATH` variable each time.

Note
: The script provided `setup.sh` and the following lines are set configure the toolchain based on `8.3.0` version of the compiler and toolchain. If you wish to install a different version please beware and change the requied lines in `setup.sh` and the following lines.

```sh
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$PATH
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/riscv64-unknown-elf/bin:$PATH
```

## phoeniX Execution Flow

### Linux

In the directory [phoeniX_Code_Executant](https://github.com/ArvinDelavari/PHOENIX-CORE/tree/main/phoeniX_Code_Executant) there are two subdirectories included for automation of simulation process on phoeniX core. One is designed for both Linux and Windows systems using [Venus Simulator](https://marketplace.visualstudio.com/items?itemName=hm.riscv-venus) extension on VS-Code and the other is only for Linux systems using [RISC-V compiler toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain). Both of these two systems are implemented using a Python script which you can execute and check out output of the simulations on the phoeniX core by following some simple steps. Further descriptions are included in the directory.

### Windows
There's a set of sample RISC-V assembly codes in the `/Sample_Codes` directory. These codes were written and simulated using [Venus Simulator](https://marketplace.visualstudio.com/items?itemName=hm.riscv-venus) using its Visual Studio Code extension. Venus can also create the HEX output file of the assembly code which will be needed to be given to the core, in the instruction memory. There are also some C codes included in [C codes](https://github.com/ArvinDelavari/PHOENIX-CORE/tree/main/Sample_Codes/C%20codes) directory. These codes are executed by [RISC-V compiler toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) in Linux. In the end, outputs are turned into HEX format named `firmware.hex` and `firmware32.hex` and in order to be given to the CPU for simulations inside the testbench.


## Synthesis Result

```
```
</div>
