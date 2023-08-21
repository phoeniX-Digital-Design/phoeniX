phoeniX CORE
======================================

**phoeniX** RISC-V processor was designed in Verilog HDL based on I-M-F extensions of [RISC-V Instruction Set Architecture](http://riscv.org/) and can execute `RV32I`, `RV32M` and `RV32F` instructions. 

You can find a list of full RISC-V assembly instructions in the [ISA documents](https://msyksphinz-self.github.io/riscv-isadoc/html/).

The core can be implemented as a softcore CPU on Xilinx 7 series FPGA boards using logic synthesis. This allows for flexible integration of the core's functionality within the FPGA fabric. The Xilinx 7 series FPGA boards provide a versatile platform for hosting the softcore CPU implementation, offering configurable features and adaptability.

The core has undergone a complete design flow, including synthesis, routing, and post layout process, to become an Integrated Circuit using open-source tools and the [QFlow](http://opencircuitdesign.com/qflow/) & [Siliconcompiler](https://github.com/siliconcompiler/siliconcompiler) projects. The ASIC implementation was specifically carried out utilizing the `NANGate45nm` Process Design Kit (PDK).

This repository contains an open source CPU under the [GNU V3.0 license](https://en.wikipedia.org/wiki/GNU_General_Public_License) and is free to use.

- Designed By : [Arvin Delavari](https://github.com/ArvinDelavari) and [Faraz Ghoreishy](https://github.com/FarazGhoreishy)
- Contact us : arvin7807@gmail.com - farazghoreishy@gmail.com
- Iran University of Science and Technology - August 2023

## phoeniX core structure

The repository contains a collection of Verilog modules that build up the phoeniX RISC-V processor. These building block modules are included in `\Modules` directory in main branch of the repository:

| Module                        | Description                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------- |
| `Register_File`               | 32 number of 32-bit general purpose reisters (2 read & 1 write ports)        |
| `Arithmetic_Logic_Unit`       | ALU with all `I_TYPE` and `R_TYPE` RISC-V instructions support               |
| `Instruction_Decoder`         | Decoding instructions and seperating `opcode`, `funct` and `imm` fields      |
| `Immediate_Generator`         | Generating immediate values according to instructions types                  |
| `Memory_Interface`            | Handle CPU interactions with exrenal memories in fetching and LSU operations |
| `Fetch_Unit`                  | Instruction Fetch logic implemented using `Memory_Interface` module          | 
| `Load_Store_Unit`             | Load and Store operations implemented using `Memory_Interface` module        |
| `Branch_Unit`                 | Condition check for all branch instructions of `RV32I` ISA support           |
| `Address_Generator`           | Generates adderess for BRANCH, JUMP and LOAD/STORE instrcutions              |
| `Hazard_Forward_Unit`         | Hazard detection and data forwarding logic in pipelined processor            |

Main phoeniX RISC-V core file is in the main branch of this repository:
| Module                        | Description                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------- |
| `phoeniX`                     | phoeniX 32 bit RISC-V core (RV32IMF) main Verilog module                     |

## Sample codes

There's a set of sample RISC-V assembly codes in the `\Sample_Codes` directory. These codes were written and simulated using [Venus Simulator](https://marketplace.visualstudio.com/items?itemName=hm.riscv-venus) using its Visual Studio Code extension. Venus can also create the HEX output file of the assembly code which will be needed to be given to the core, in the instruction memory.

## Instruction Memory Generator

There's a python script in this directory which is written to create a `.mem`, `.txt` or a `.hex` file as an instruction memory for the phoeniX core, from the output HEX file of the Venus Simulator. The script works with the following steps:

1) Write, simulate and modify your assembly code in Venus simulator.
2) In 'VENUS OPTIONS' select 'Assembly' and save the output file as a text file. (save the output in the python script directory)
3) Enter the created text file name.
4) Enter the output file (instruction memory) name.
5) Output file created is the instruction memory and can be given to testbench. (output is also generated in the same directory)