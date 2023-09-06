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

 The classic 5-stage pipeline in a processor improves instruction throughput by dividing execution into sequential stages. By incorporating data forwarding and bypassing options, such as operand and memory bypassing, the pipeline minimizes stalls caused by data hazards. These enhancements allow for efficient forwarding of data between stages, reducing dependencies on the register file and memory access delays. As a result, the pipeline achieves higher performance, reduced stalls, and improved instruction-level parallelism, enabling concurrent processing of independent instructions.

 - Distributed Control

Distributed control logic refers to a design approach in which the control signals required for instruction execution are generated within the individual blocks or stages of a processor core, eliminating the need for a centralized control unit. In this paradigm, each block or stage is responsible for generating and managing its own control signals based on the current instruction being processed. This decentralized control mechanism offers several benefits. Firstly, it simplifies the overall processor architecture by removing the need for a separate control unit, reducing complexity and potentially improving the overall efficiency and performance. Secondly, distributed control logic can facilitate better pipelining and parallelism, as each block can independently generate control signals based on its own requirements, potentially reducing dependencies and increasing instruction-level parallelism. Additionally, distributed control logic can enhance modularity and scalability, as individual blocks can be designed and optimized independently, allowing for easier customization and future upgrades. Overall, this approach can contribute to more efficient and flexible processor designs, enabling improved performance and adaptability in various computing scenarios.

 - Modularity

Modularity in processor design refers to the practice of breaking down the overall system into smaller, independent modules that can be designed, optimized, and tested separately. This approach offers several benefits. Firstly, modularity increases flexibility and reusability, as individual modules can be easily interchanged or upgraded without requiring significant changes to the entire system. This enables efficient customization and adaptation to different application requirements. Secondly, modularity aids in design verification and testing, as individual modules can be tested in isolation, simplifying the debugging process and reducing the overall development time. Additionally, modularity facilitates scalability, allowing for the addition or removal of modules to meet evolving needs. Moreover, modular designs can lead to improved overall system reliability, as faults or failures in one module are less likely to affect the functionality of the entire system. Overall, modularity in processor design promotes flexibility, reusability, scalability, ease of testing, and increased system reliability, making it a valuable approach in building efficient and adaptable processors.

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

phoeniX currently supports 32-bit word memories with synchronized access time. The core always addresses memory by a word aligned address and access a four byte frame from memory which is then operated on based on a `frame_mask` for half-word and byte operations. Designed with the influence of Harvard architecture, the phoeniX native memory interface ensures the elimination of structural hazard occurrences while accessing memory. It incorporates two distinctive address and data buses, specifically dedicated to instructions and data. As can be seen from the top module's port instantiations, both these memory interfaces for instruction have a data, address and control bus. Data bus related to data memory interface is bi-directional and therefore defined as `inout` net type while the data bus for instruction memory interface is uni-directional and is considered as an `input` from the processor point of view. 

*Unaligned Memory Accesses:* phoeniX Load Store Unit does not support misaligned accesses. At the moment we are working to add support accesses that are not aligned on word boundaries by implementing the procedure with multiple separate aligned accesses requiring  additional clock cycles.

## Building RISC-V Toolchain
You can use the scripts provided in the original RISC-v repositories and [riscv-tools](https://github.com/riscv/riscv-tools). The default settings in the original repos build scripts will build a compiler, assembler and linker that can target any RISC-V ISA.
You can also use the provided shell script in `/Setup`. All shell scripts and Makefiles provided in this repository target Ubuntu 20.04 unless otherwise specified. Simply run the `setup.sh` from your terminal, it will automatically install the required perquisites, iVerilog version 12 and gtkwave.

```console
user@Ubuntu:~$ git clone https://github.com/ArvinDelavari/phoeniX-RV32.git
user@Ubuntu:~$ cd Setup
user@Ubuntu:~$ chmod +x setup.sh
user@Ubuntu:~$ ./setup.sh
```
Using your favorite editor open `.bashrc` file from the `home` directory of your ubuntu. Replace `{user}` with your own user name and add the following lines to the end of file. This will change your path environment variable and is required to run `RISC-V GNU Compiler` automatically without exporting `PATH` variable each time.

Note
: The script provided `setup.sh` and the following lines are set configure the toolchain based on `8.3.0` version of the compiler and toolchain. If you wish to install a different version please beware and change the required lines in `setup.sh` and the following lines.

```sh
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$PATH
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/riscv64-unknown-elf/bin:$PATH
```

## phoeniX Execution Flow

### Linux

#### Running Sample Codes
The directory `/Software` contains sample codes for some conventional programs and algorithms in both Assembly and C which can be found in `/Sample_Assembly_Codes` and `/Sample_C_Codes` sub-directories respectively. 

phoeniX convention for naming projects is as follows; The main source file of the project is named as `{project.c}` or `{project.s}`. This file along other required source files are kept in one directory which has the same name as the project itself, i.e. `/project`.

Sample projects provided at this time are `bubble_sort`, `fibonacci`, `find_max_array`, `sum1ton`.
To run any of these sample projects simply run `make sample` followed by the name of the project passed as a variable named project to the Makefile.
```
make sample project={project}
```
For example:
```
make sample project=fibonacci
```

Provided that the RISC-V toolchain is set up correctly, the Makefile will compile the source codes separately, then using the linker script `riscv.ld` provided in `/Firmware` it links all the object files necessary together and creates `firmware.elf`. It then creates `start.elf` which is built from `start.s` and `start.ld` and concatenate these together and finally forms the `{project}_firmware.hex`. This final file can be directly fed to our verilog testbench. Makefile automatically runs the testbench and calls upon `gtkwave` to display the selected signals in the waveform viewer.

#### Running Your Own Code
In order to run your own code on phoeniX, create a directory named to your project such as `/my_project` in `/Software/User_Codes/`. Put all your `.c` and `.s` files in `/my_project` and run the following `make` command from the main directory:
```
make code project=my_project
```
Provided that you name your project sub-directory correctly and the RISC-V Toolchain is configured without any troubles on your machine, the Makefile will compile all your source files separately, then using the linker script `riscv.ld` provided in `/Firmware` it links all the object files necessary together and creates `firmware.elf`. It then creates `start.elf` which is built from `start.s` and `start.ld` and concatenate these together and finally forms the `my_project_firmware.hex`. After that, `iverilog` and `gtkwave` are used to compile the design and view the selected waveforms.
> Further Configurations
: The default testbench provided as `phoeniX_Testbench.v` is currently set to support up to 4MBytes of memory and the stack pointer register `sp` is configured accordingly. If you wish to change this, you need configure both the testbench and the initial value the `sp` is set to in `/Firmware/start.s`. If you wish to use other specific libraries and header files not provided in `/Firmware` please beware you may need to change linker scripts `riscv.ld` and `start.ld`.

### Windows
There's a set of sample RISC-V assembly codes in the `/Sample_Codes` directory. These codes were written and simulated using [Venus Simulator](https://marketplace.visualstudio.com/items?itemName=hm.riscv-venus) using its Visual Studio Code extension. Venus can also create the HEX output file of the assembly code which will be needed to be given to the core, in the instruction memory. There are also some C codes included in [C codes](https://github.com/ArvinDelavari/PHOENIX-CORE/tree/main/Sample_Codes/C%20codes) directory. These codes are executed by [RISC-V compiler toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) in Linux. In the end, outputs are turned into HEX format named `firmware.hex` and `firmware32.hex` and in order to be given to the CPU for simulations inside the testbench.


## Synthesis Result

```
```
</div>
> blockquote
