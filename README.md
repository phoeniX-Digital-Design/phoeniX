![License](https://img.shields.io/github/license/phoeniX-Digital-Design/AssembleX?color=dark-green)
![GCC Test](https://img.shields.io/badge/GCC_tests-passed-dark_green)
![Version](https://img.shields.io/badge/Version-0.4.1-blue)
![ISA](https://img.shields.io/badge/RV32-IEM_extension-blue)

<picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Documents/Images/phoenix_full_logotype_bb.png" width="530" height="150" style="vertical-align:middle">
    <img alt="logo in light mode and dark mode" src="https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Documents/Images/phoenix_full_logotype.png" width="530" height="150" style="vertical-align:middle"> 
</picture> 

<div align="justify">
 
The **phoeniX** RISC-V HW/SW platform inludes an `RV32IEM` core designed in Verilog HDL based on the 32-bit Base Instrcution Set of [RISC-V Instruction Set Architecture](http://riscv.org/) V2.2, with specialized features supported for **approximate computing** techniques.The **phoeniX** is a novel modular and extensive RISC-V processor for approximate computing.

The platform enables integration of approximate arithmetic circuits at the core level, with different structures, accuracies, timings and etc. without any need for modification in rest of the core, especially in the control logic. This allows configurable trade-offs between speed, accuracy and power consumption based on application requirements.

</div>

<div align="justify">

This repository contains an open source RISC-V embedded core, including RTL codes and assistant software, under the [GNU V3.0 license](https://en.wikipedia.org/wiki/GNU_General_Public_License) and is free to use. The platform's technical specifications are published under supervision of [IUST Electronics Research Center](http://idea.iust.ac.ir/content/76317/phoeniX-POINTS--A-RISC-V-Platform-for-Approximate-Computing-Version-0.1-Technical-Specifications).


Publications:

- A. Delavari, F. Ghoreishy, H. S. Shahhoseini and S. Mirzakuchaki, “Evaluation of Run-Time Energy Efficiency using Controlled Approximation in a RISC-V Core,” 2024 6th Iranian International Conference on Microelectronics (IICM), Tabriz, Iran, 2024.

- A. Delavari, F. Ghoreishy, H. S. Shahhoseini and S. Mirzakuchaki, “A Reconfigurable Approximate Computing RISC-V Platform for Fault-Tolerant Applications,” 2024 27th Euromicro Conference on Digital System Design (DSD), Paris, France, 2024, pp. 81-89.

- A. Delavari, F. Ghoreishy, H. S. Shahhoseini and S. Mirzakuchaki (2023), “PhoeniX: A RISC-V Platform for Approximate Computing Technical Specifications,” [Online]. Available: http://www.iust.ac.ir/content/76158/phoeniX-POINTS--A-RISC-V-Platform-for-Approximate-Computing

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

</div>

- Designed By: [Arvin Delavari](https://github.com/ArvinDelavari) and [Faraz Ghoreishy](https://github.com/FarazGhoreishy)
- Contact us: arvin_delavari@elec.iust.ac.ir - faraz_ghoreishy@elec.iust.ac.ir
- Iran University of Science and Technology, Summer 2023 - Present


<a href="https://next.ossinsight.io/widgets/official/analyze-repo-stars-map?activity=stars&repo_id=677643796" target="_blank" style="display: block" align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://next.ossinsight.io/widgets/official/analyze-repo-stars-map/thumbnail.png?activity=stars&repo_id=677643796&image_size=auto&color_scheme=dark" width="721" height="auto">
    <img alt="Star Geographical Distribution of phoeniX project" src="https://next.ossinsight.io/widgets/official/analyze-repo-stars-map/thumbnail.png?activity=stars&repo_id=677643796&image_size=auto&color_scheme=light" width="721" height="auto">
  </picture>
</a>

## Table of Contents

- [Features](#Features)
- [Directory Map](#Directory-Map)
- [Core's Structure](#Core-Structure)
- [Memory Interface](#Memory-Interface)
- [Building RISC-V Toolchain](#Building-RISC-V-Toolchain)
- [Execution Flow](#Execution-Flow)
- [Synthesis Result](#Synthesis-Result)


## Features
<div align="justify">

 - **Optimized 3 stage pipeline**

 The 3-stage pipeline in a processor improves instruction throughput by dividing execution into sequential stages with minimal internal fragmentation. By incorporating data forwarding and bypassing options (forwarding data from execution, memory or writeback stage) the pipeline minimizes stalls caused by data hazards.

 - **Modularity and Extensiveness**

Modularity in design promotes flexibility, reusability, scalability, simpler testing, and system reliability by breaking down the design into smaller, independent modules that form the building blocks. Each of these blocks can be designed, optimized, and tested separately. This approach offers several benefits. 

First, modularity increases flexibility, as individual modules can be easily interchanged without requiring modifications to the main core. This enables customization and adaptation to different application requirements (e.g. adding an execution unit module to the design would cause changes to a centralized control unit, but in this methodolgy, designing `self-controlled execution units` would lead to a much simple integration of the module to the main core).

Secondly, modularity aids in design verification and testing, as individual modules can be tested in isolated testbenches, simplifying the debugging process and reducing the overall development time. 

Additionally, modular designs can lead to improved overall system reliability, as faults and failures in one module are less likely to affect the functionality of the entire processor.

- **A Novel Platform for Approximate Computing**

The phoeniX RISC-V core introduces novel features that will help the emerging field of approximate computing. With its extensive architecture, phoeniX presents a reconfigurable platform for exploring and implementing hardware approximation methodologies for HW/SW co-design. 

This platform enables researchers and developers to delve into the field realm of approximate computing, where trade-offs between *accuracy* and *computational efficiency* can be carefully balanced. By offering a range of specialized instructions, optimized datapaths, and adaptable precision controls, phoeniX empowers users to use the help of approximation in diverse `fualt-tolerant application` domains, opening the way for advancements in energy-efficient computing, ML, DL, Neural Networks, image processing, and etc.

</div>

## Directory Map

The tree below provides a map to all directories and sub-directories of the repository. Detailed descriptions on contents of these directories are provided in the following sections and each specific `README.md`.
<pre style="font-size:16px">
repository/
    ├── Setup/
    │   └── setup.sh
    ├── Documents/
    │   ├── Images/
    │   ├── phoeniX_Documentation/   
    │   └── RISCV_Original_Documents/
    ├── Dhrystone/
    |   ├── dhry.h
    │   ├── dhry_1.c
    │   ├── dhry_2.c
    │   ├── dhrytone.log 
    │   ├── dhrytone_firmware.hex 
    │   └── dhrytone_firmware.txt
    ├── Features/
    │   ├── AXI4-Lite/
    │   ├── Branch_Prediction/
    │   ├── Clock_Genrator/
    │   └── ...
    ├── Synthesis/
    │   ├── TSMC_018um/
    │   │   ├── layout/
    │   │   ├── synthesis/
    │   │   ├── log/
    │   │   └── ...
    │   ├── DC_45nm
    │   └── Vivado_2022
    ├── Modules/
    │   ├── Address_Generator.v
    │   ├── Arithmetic_Logic_Unit.v
    │   └── ...
    ├── Firmware/
    │   ├── hex_converter -> hex_converter.py
    │   ├── start_procedure -> start.s
    │   ├── start_linker -> start.ld
    │   ├── riscv_linker -> riscv.ld
    │   ├── standard_library -> stdlib.c
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
    ├── AssembleX_V1.0.py
    └── Makefile
</pre>

## Core Structure
<div align="justify">

The repository contains a collection of Verilog modules that build up the phoeniX RISC-V processor. These building block modules are included in `\Modules` directory.
Each modules was designed with concepts of modularity and distributed-control in mind. This deliberate approach allows for effortless replacement and configuration of individual building blocks, resulting in a simplified process. This will help designers with integrating new modules (especially arithmetic and execution units) within the processor.

The proposed platform enables integration of approximate arithmetic units at the core level, with different structures, accuracies, timings and etc. without any need for editing rest of the core, especially in control logic. This platform is allowing configurable trade-offs between speed, accuracy and energy consumption based on specific application requirements. 

This repository includes detailed documentation, user manual, and developer guidelines for future works and updates. These resources make it extremely easy for users to execute `C/C++` and `ASM` code using the standard `RISC-V GCC toolchain` on the processor, and helps developers to understand its structure and architecture, in order to update and validate new designs using the base processor, or adding and testing approximate arithmetic circuits on the core, without any need of changes in other parts of the processor such as control logics and etc.

</div>

![Alt text](https://github.com/phoeniX-Digital-Design/phoeniX/blob/phoeniX-V0.3/Documents/Images/phoeniX_Block_Diagram_V03.PNG "phoeniX V0.3 Block Diagram")

| Module                        | Description                                                                                   |
| ----------------------------- | --------------------------------------------------------------------------------------------- |
| `Address_Generator`           | Generating address for BRANCH, JUMP and LOAD/STORE instructions                               |
| `Arithmetic_Logic_Unit`       | ALU with support for `I_TYPE` and `R_TYPE` RISC-V instructions                                |
| `Control_Status_Unit`         | CSR instructions and custom CSRs for approximate computing acceleration of the phoeniX        |
| `Divider_unit`                | Divider unit with a modular design (Default module: Error configrable non-restoring divider)  |
| `Fetch_Unit`                  | Instruction Fetch logic and program counter addressing                                        | 
| `Hazard_Forward_Unit`         | Hazard detection and data forwarding logic in pipelined processor                             |
| `Immediate_Generator`         | Generating immediate values according to instructions type                                    |
| `Instruction_Decoder`         | Decoding instructions and extracting `opcode`, `funct` and `imm` fields                       |
| `Jump_Branch_Unit`            | Condition checking for all branch instructions                                                |
| `Load_Store_Unit`             | Load and Store operations for aligned addresses and wordsize management                       |
| `Multiplier_Unit`             | Multiplier unit with a modular design (Default module: Fast, low-power approximate multiplier)|
| `Register_File`               | Parametrized register file suitable for GP registers and CSRs (2 read & 1 write ports)        |


The `phoeniX.v` contains the main phoeniX RISC-V core and is included in the top directory of this repo:
| Module                        | Description                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------- |
| `phoeniX`                     | phoeniX 32 bit RISC-V core (RV32IEM) top module                              |
| `phoeniX_Testbench`           | Testbench module including main core, memory and interface logic             |


## Memory Interface
<div align="justify">

The processor currently supports 32-bit word memories with synchronized access time. The core always addresses memory by a word aligned address and access a four byte frame from memory which is then operated on based on a `frame_mask` for half-word and byte operations. 

![Alt text](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Documents/Images/frame_mask_table.png "Frame Mask Values on different aligned memory accesses")

Designed with the influence of Harvard architecture, the native memory interface ensures the elimination of structural hazard occurrences while accessing memory. It incorporates two distinctive address and data buses, specifically dedicated to instructions and data. As can be seen from the top module's port instantiations, both these memory interfaces have a data, address and control bus.

</div>

> [!WARNING]\
> Unaligned Memory Accesses: phoeniX Load Store Unit does not support misaligned accesses. At the moment we are working to add support accesses that are not aligned on word boundaries by implementing the procedure with multiple separate aligned accesses requiring  additional clock cycles.

## Building RISC-V Toolchain
<div align="justify">
 
In order to be able to compile your source files and run on the core, you need to install `RISC-V GNU Compiler Toolchain`. You can follow the installation process from the [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) repository or use the scripts provided in the original RISC-V repositories and [riscv-tools](https://github.com/riscv/riscv-tools). The default settings in the original repos build scripts will build a compiler, assembler and linker that can target any RISC-V ISA.

You can also use the provided shell script in `/Setup` directory. All shell scripts and Makefiles provided in this repository target `Ubuntu 20.04` unless otherwise specified. Simply run the `setup.sh` from your terminal, and it will automatically install all required prequistes.

</div>

```console
user@Ubuntu:~$ git clone https://github.com/phoeniX-Digital-Design/phoeniX.git
user@Ubuntu:~$ cd phoeniX
user@Ubuntu:~$ cd Setup
user@Ubuntu:~$ chmod +x setup.sh
user@Ubuntu:~$ ./setup.sh
```
<div align="justify">

Using your favorite editor open `.bashrc` file from the `home` directory of your ubuntu. Replace `{user}` with your own user name and add the following lines to the end of file. This will change your path environment variable and is required to run `RISC-V GNU Compiler` automatically without exporting `PATH` variable each time.

</div>

> [!NOTE]\
> The script provided `setup.sh` and the following lines are set configure the toolchain based on `8.3.0` version of the compiler and toolchain for a `x86_64` machine. If you wish to install a different version please beware and change the required lines in `setup.sh` and the following lines.

```sh
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$PATH
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/riscv64-unknown-elf/bin:$PATH
```

## Execution Flow

### Linux

#### Running Sample Codes
<div align="justify">

The directory `/Software` contains sample codes for some conventional programs and algorithms in both Assembly and C which can be found in `/Sample_Assembly_Codes` and `/Sample_C_Codes` sub-directories respectively. 

phoeniX convention for naming projects is as follows; The main source file of the project is named as `{project.c}` or `{project.s}`. This file along other required source files are kept in one directory which has the same name as the project itself, i.e. `/project`.

Sample projects provided at this time are `bubble_sort`, `fibonacci`, `find_max_array`, `sum1ton`.
To run any of these sample projects simply run `make sample` followed by the name of the project passed as a variable named project to the Makefile.

```shell
make sample project={project}
```
For example:
```shell
make sample project=fibonacci
```

Provided that the RISC-V toolchain is set up correctly, the Makefile will compile the source codes separately, then using the linker script `riscv.ld` provided in `/Firmware` it links all the object files necessary together and creates `firmware.elf`. It then creates `start.elf` which is built from `start.s` and `start.ld` and concatenate these together and finally forms the `{project}_firmware.hex`. This final file can be directly fed to our verilog testbench. Makefile automatically runs the testbench and calls upon `gtkwave` to display the selected signals in the waveform viewer.

</div>

#### Running Your Own Code
<div align="justify">

In order to run your own code on phoeniX, create a directory named to your project such as `/my_project` in `/Software/User_Codes/`. Put all your `.c` and `.s` files in `/my_project` and run the following `make` command from the main directory:
```shell
make code project=my_project
```
Provided that you name your project sub-directory correctly and the RISC-V Toolchain is configured without any troubles on your machine, the Makefile will compile all your source files separately, then using the linker script `riscv.ld` provided in `/Firmware` it links all the object files necessary together and creates `firmware.elf`. It then creates `start.elf` which is built from `start.s` and `start.ld` and concatenate these together and finally forms the `my_project_firmware.hex`. After that, `iverilog` and `gtkwave` are used to compile the design and view the selected waveforms.

> Further Configurations: The default testbench provided as `phoeniX_Testbench.v` is currently set to support up to 4MBytes of memory and the stack pointer register `sp` is configured accordingly. If you wish to change this, you need configure both the testbench and the initial value the `sp` is set to in `/Firmware/start.s`. If you wish to use other specific libraries and header files not provided in `/Firmware` please beware you may need to change linker scripts `riscv.ld` and `start.ld`.

</div>

### Windows

#### Running Sample Codes
<div align="justify">

We have meticulously developed a lightweight and user-friendly software solution with the help of Python. Our execution assistant software, `AssembleX`, has been crafted to cater to the specific needs of Windows systems, enabling seamless execution of assembly code on the phoeniX processor. 

This tool  enhances the efficiency of the code execution process, offering a streamlined experience for users seeking to enter the realm of assembly programming on pheoniX processor in a very simple and user-friendly way.

To run any of these sample projects simply run python `AssembleX.py sample` followed by the name of the project passed as a variable named project to the Python script.
The input command format for the terminal follows the structure illustrated below:
```shell
python AssembleX.py sample {project_name}
```
For example:
```shell
python AssembleX.py sample fibonacci
```
After execution of this script, firmware file will be generated and this final file can be directly fed to our Verilog testbench. AssembleX automatically runs the testbench and calls upon gtkwave to display the selected signals in the waveform viewer application, gtkwave.
</div>

#### Running Your Own Code
<div align="justify">

In order to run your own code on phoeniX, create a directory named to your project such as `/my_project` in `/Software/User_Codes`. Put all your `user_code.s` files in my_project and run the following command from the main directory:

```shell
python AssembleX.py code my_project
```

Provided that you name your project sub-directory correctly the AssembleX software will create `my_project_firmware.hex` and fed it directly to the testbench of phoeniX processor. After that, iverilog and GTKWave are used to compile the design and view the selected waveforms.

</div>

## Results
<div align="justify">

The RTL has been crafted to enable the utilization of the processor as an implementable soft-core on Xilinx FPGA devices. The synthesis and implementation of the phoeniX processor was done using Synopsys Design Compiler, by the `NanGate 45nm` CMOS. By adhering the timing requirements, the processor can achieve a performance level of **500 - 620MHz**, enabling efficient execution of instructions and supporting the desired operational specifications in embedded processors.

![phoeniX_45nm_Layout](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/DesignCompiler_NanGate45/layout_image/phoeniX_RV32IEM_layout_45nm.png)

</div>

| Dhyrstone Parameters         | phoeniX (RV32I) | phoeniX (RV32IM) |
| ---------------------------- | --------------- | ---------------- |
| CPI                          | 1.119           | 1.137            |
| Dhrystones per Second per MHz| 3044            | 3324             |
| DMIPS/MHz                    | 1.732           | 1.891            |

<div align="justify">

It is important to note that phoeniX is an embedded processor which is modular, and execution units are replaceable; This means that the following reported results of phoeniX core is extracted from the platform using its default (demo) execution engine, *including both accurate and approximate arithmetic hardware*.

</div>

| Processor                    | Max Frequency (MHz) | Technology Node (nm) | Architecture | Pipeline         |
| ---------------------------- | ------------------- | -------------------- | ------------ | ---------------- |
| phoeniX V0.4                 | 620                 | 45                   | RV32IEM      | 3-stage in order |
| phoeniX V0.3                 | 500                 | 45                   | RV32IEM      | 3-stage in order |
| phoeniX V0.2                 | 500                 | 45                   | RV32I        | 3-stage in order |
| phoeniX V0.1                 | 220                 | 180                  | RV32I        | 5-stage in order |
| phoeniXS6                    | > 100 (on FPGA)     | XC6SLX9              | RV32I        | 3-stage in order |
