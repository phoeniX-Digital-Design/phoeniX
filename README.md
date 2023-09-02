phoeniX CORE
======================================

**phoeniX** RISC-V processor was designed in Verilog HDL based on I extension of [RISC-V Instruction Set Architecture](http://riscv.org/) and can execute `RV32I` instructions. Other extensions will be covered in the upcoming updates. 

You can find a list of full RISC-V assembly instructions in the [ISA Specifications Documents](https://riscv.org/technical/specifications/).

The core can be implemented as a softcore CPU on Xilinx 7 Ultrscale/Ultrascale+ series FPGA boards using logic synthesis. This allows for flexible integration of the core's functionality within the FPGA fabric. The Xilinx 7 series FPGA boards provide a versatile platform for hosting the softcore CPU implementation, offering configurable features and adaptability.

The core has undergone a complete design flow, including synthesis, routing, and post layout process, to become an Integrated Circuit using open-source tools and the [QFlow](http://opencircuitdesign.com/qflow/) and [Magic VLSI](http://opencircuitdesign.com/magic/) projects. The ASIC implementation was specifically carried out utilizing the `osu018 (TSMC 180nm)` Process Design Kit (PDK).

This repository contains an open source CPU under the [GNU V3.0 license](https://en.wikipedia.org/wiki/GNU_General_Public_License) and is free to use.

- Designed By : [Arvin Delavari](https://github.com/ArvinDelavari) and [Faraz Ghoreishy](https://github.com/FarazGhoreishy)
- Contact us : arvin7807@gmail.com - farazghoreishy@gmail.com
- Iran University of Science and Technology - Summer 2023

## phoeniX core structure
The repository contains a collection of Verilog modules that build up the phoeniX RISC-V processor. These building block modules are included in `\Modules` directory in main branch of the repository:

| Module                        | Description                                                                                   |
| ----------------------------- | --------------------------------------------------------------------------------------------- |
| `Register_File`               | Parametrized register file suitable for GP registers and CSRs (2 read & 1 write ports)        |
| `Arithmetic_Logic_Unit`       | ALU with all `I_TYPE` and `R_TYPE` RISC-V instructions support                                |
| `Instruction_Decoder`         | Decoding instructions and extracting `opcode`, `funct` and `imm` fields                       |
| `Immediate_Generator`         | Generating immediate values according to instructions type                                    |
| `Fetch_Unit`                  | Instruction Fetch logic and program counter addressing                                        | 
| `Load_Store_Unit`             | Load and Store operations for aligned addresses and wordsize management                       |
| `Branch_Unit`                 | Condition checking for all branch instructions                                                |
| `Address_Generator`           | Generating address for BRANCH, JUMP and LOAD/STORE instrcutions                               |
| `Hazard_Forward_Unit`         | Hazard detection and data forwarding logic in pipelined processor                             |

Main phoeniX RISC-V core file is in the main branch of this repository:
| Module                        | Description                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------- |
| `phoeniX`                     | phoeniX 32 bit RISC-V core (RV32I) main Verilog module                       |

## Sample codes

There's a set of sample RISC-V assembly codes in the `\Sample_Codes` directory. These codes were written and simulated using [Venus Simulator](https://marketplace.visualstudio.com/items?itemName=hm.riscv-venus) using its Visual Studio Code extension. Venus can also create the HEX output file of the assembly code which will be needed to be given to the core, in the instruction memory. There are also some C codes included in [C codes](https://github.com/ArvinDelavari/PHOENIX-CORE/tree/main/Sample_Codes/C%20codes) directory. These codes are executed by [RISC-V compiler toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) in Linux. In the end, outputs are turned into HEX format named `firmware.hex` and `firmware32.hex` and in order to be given to the CPU for simulations inside the testbench.

## phoeniX Code Executant

In the directory [phoeniX_Code_Executant](https://github.com/ArvinDelavari/PHOENIX-CORE/tree/main/phoeniX_Code_Executant) there are two subdirectories included for automation of simulation process on phoeniX core. One is designed for both Linux and Windows systems using [Venus Simulator](https://marketplace.visualstudio.com/items?itemName=hm.riscv-venus) extension on VS-Code and the other is only for Linux systems using [RISC-V compiler toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain). Both of these two systems are implemented using a Python script which you can execute and check out output of the simulations on the phoeniX core by following some simple steps. Further descriptions are included in the directory.