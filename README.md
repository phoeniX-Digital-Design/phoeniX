![image](https://github.com/phoeniX-Digital-Design/phoeniX/blob/%F0%9F%94%A7-execution-flow/Documents/Images/phoenix_logotype_bb_transparent.png#gh-dark-mode-only)

=============== 

<div align="justify">
 
**phoeniX** RISC-V processor is designed in Verilog HDL based on the 32-bit Base Instrcution Set of [RISC-V Instruction Set Architecture](http://riscv.org/) and can execute `RV32I` instructions. Support for other extensions will be covered in the upcoming updates. 

You can find a full list of RISC-V assembly instructions in the [ISA Specifications Documents](https://riscv.org/technical/specifications/).

The core can be implemented as a softcore CPU on Xilinx 7 Ultrascale/Ultrascale+ series FPGA boards using logic synthesis. This allows flexible integration of the core's functionality within the FPGA fabric. The Xilinx 7 series FPGA boards provide a versatile platform for hosting the softcore CPU implementation, offering configurable features and adaptability.

The core has undergone a complete design flow, including synthesis, routing, and post layout process, to become an Integrated Circuit using open-source tools, the [QFlow](http://opencircuitdesign.com/qflow/) and [Magic VLSI](http://opencircuitdesign.com/magic/) projects. The ASIC implementation was specifically carried out utilizing the `osu018 (TSMC 180nm)` Process Design Kit (PDK).
</div>

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
<div align="justify">

 - **Classic 5-stage pipline**

 The classic 5-stage pipeline in a processor improves instruction throughput by dividing execution into sequential stages. By incorporating data forwarding and bypassing options (such as forwarding data from execution, memory or writeback stage) the pipeline minimizes stalls caused by data hazards. As a result, the pipeline achieves higher performance, reduced stalls, and improved instruction-level parallelism, enabling concurrent processing of independent instructions.

 - **Distributed Control**

Distributed control logic refers to a design approach in which the control signals required for instruction execution are generated within the individual blocks the processor core, eliminating the need for a centralized control unit. In this approach, each building block is responsible for generating and managing its own control signals based on the current instruction being processed. There are several benefits to this decentralized control mechanism.

Firstly, it simplifies the overall processor architecture by removing the need for a separate control unit, reducing complexity and potentially improving the overall performance. 

Secondly, distributed control logic can facilitate better pipelining, as each block can independently generate control signals based on its own requirements, potentially reducing dependencies and increasing instruction-level parallelism. 

Additionally, distributed control logic can enhance modularity and scalability as will be discussed in the next part. Since individual blocks can be designed and optimized independently, it allows for easier customization and future upgrades. Overall, this approach can contribute to a more flexible processor design.

 - **Modularity**

Modularity in processor design promotes flexibility, reusability, scalability, simpler testing, and increased system reliability by breaking down the procesor into smaller, independent modules that form the building blocks. Each one of these building blocks can be designed, optimized, and tested separately. This approach offers several benefits. 

First, modularity increases flexibility and reusability, as individual modules can be easily interchanged or upgraded without requiring significant changes to the main core. This enables efficient customization and adaptation to different application requirements (e.g. adding a multiplier/divider module to the design would cause significant changes to a centralized control unit, but in this methodolgy, designing self-controlled execution units would lead to a much simple integration of the module to the main core).

Secondly, modularity aids in design verification and testing, as individual modules can be tested in isolated testbenches, simplifying the debugging process and reducing the overall development time. 

Additionally, modular designs can lead to improved overall system reliability, as faults and failures in one module are less likely to affect the functionality of the entire processor.
</div>

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
<div align="justify">

The repository contains a collection of Verilog modules that build up the phoeniX RISC-V processor. These building block modules are included in `\Modules`.
Each modules was designed with concepts of modularity and distributed-control in mind. This deliberate approach allows for effortless replacement and configuration of individual building blocks, resulting in a simplified process.

</div>

![Alt text](https://github.com/phoeniX-Digital-Design/phoeniX/blob/%F0%9F%94%A7-execution-flow/Documents/Images/phoeniX_Block_Diagram.png "phoeniX Block Diagram")

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
<div align="justify">

phoeniX currently supports 32-bit word memories with synchronized access time. The core always addresses memory by a word aligned address and access a four byte frame from memory which is then operated on based on a `frame_mask` for half-word and byte operations. 

![Alt text](https://github.com/phoeniX-Digital-Design/phoeniX/blob/%F0%9F%94%A7-execution-flow/Documents/Images/frame_mask_table.png "Frame Mask Values on different aligned memory accesses")

Designed with the influence of Harvard architecture, the phoeniX native memory interface ensures the elimination of structural hazard occurrences while accessing memory. It incorporates two distinctive address and data buses, specifically dedicated to instructions and data. As can be seen from the top module's port instantiations, both these memory interfaces have a data, address and control bus. Data bus related to data memory interface is bi-directional and therefore defined as `inout` net type while the data bus for instruction memory interface is uni-directional and is considered as an `input` from the processor's point of view. 

*Unaligned Memory Accesses:* phoeniX Load Store Unit does not support misaligned accesses. At the moment we are working to add support accesses that are not aligned on word boundaries by implementing the procedure with multiple separate aligned accesses requiring  additional clock cycles.

</div>

## Building RISC-V Toolchain
<div align="justify">
 
In order to be able to compile your source files and run or simulate with RISC-V, you need to install `RISC-V GNU Compiler Toolchain`. You can follow the installation process from the [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) repository or use the scripts provided in the original RISC-V repositories and [riscv-tools](https://github.com/riscv/riscv-tools). The default settings in the original repos build scripts will build a compiler, assembler and linker that can target any RISC-V ISA.

You can also use the provided shell script in `/Setup` directory. All shell scripts and Makefiles provided in this repository target Ubuntu 20.04 unless otherwise specified. Simply run the `setup.sh` from your terminal, it will automatically install the required prequistes, iVerilog version 12 and gtkwave.

</div>

```console
user@Ubuntu:~$ git clone https://github.com/phoeniX-Digital-Design/phoeniX.git
user@Ubuntu:~$ cd phoeniX-RV32
user@Ubuntu:~$ cd Setup
user@Ubuntu:~$ chmod +x setup.sh
user@Ubuntu:~$ ./setup.sh
```
<div align="justify">

Using your favorite editor open `.bashrc` file from the `home` directory of your ubuntu. Replace `{user}` with your own user name and add the following lines to the end of file. This will change your path environment variable and is required to run `RISC-V GNU Compiler` automatically without exporting `PATH` variable each time.

Note
: The script provided `setup.sh` and the following lines are set configure the toolchain based on `8.3.0` version of the compiler and toolchain for a `x86_64` machine. If you wish to install a different version please beware and change the required lines in `setup.sh` and the following lines.

</div>

```sh
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$PATH
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/riscv64-unknown-elf/bin:$PATH
```

## phoeniX Execution Flow

### Linux

#### Running Sample Codes
<div align="justify">

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

</div>

#### Running Your Own Code
<div align="justify">

In order to run your own code on phoeniX, create a directory named to your project such as `/my_project` in `/Software/User_Codes/`. Put all your `.c` and `.s` files in `/my_project` and run the following `make` command from the main directory:
```
make code project=my_project
```
Provided that you name your project sub-directory correctly and the RISC-V Toolchain is configured without any troubles on your machine, the Makefile will compile all your source files separately, then using the linker script `riscv.ld` provided in `/Firmware` it links all the object files necessary together and creates `firmware.elf`. It then creates `start.elf` which is built from `start.s` and `start.ld` and concatenate these together and finally forms the `my_project_firmware.hex`. After that, `iverilog` and `gtkwave` are used to compile the design and view the selected waveforms.
> Further Configurations
: The default testbench provided as `phoeniX_Testbench.v` is currently set to support up to 4MBytes of memory and the stack pointer register `sp` is configured accordingly. If you wish to change this, you need configure both the testbench and the initial value the `sp` is set to in `/Firmware/start.s`. If you wish to use other specific libraries and header files not provided in `/Firmware` please beware you may need to change linker scripts `riscv.ld` and `start.ld`.
</div>

### Windows

#### Running Sample Codes
<div align="justify">

The directory `/Software/Sample_Assembly_Codes` contains assembly codes for some conventional programs and algorithms. Sample projects provided at this time are `bubble_sort`, `fibonacci`, `find_max_array`, `sum1ton`.
To run any of these sample projects simply run `python AssembleX.py sample` followed by the name of the sample project you want.
```
python AssembleX.py sample {project}
```
For example:
```
python AssembleX.py sample fibonacci
```
</div>

#### Running Your Own Code
<div align="justify">

Currently you can simulate the execution of your assembly codes on phoeniX with the help of Visual Studio Code extension [`RISC-V Venus Simulator`](https://marketplace.visualstudio.com/items?itemName=hm.riscv-venus) and `AssembleX` software. This lightweight execution assistant software is developed with Python, and has been crafted to the execution flow on Windows systems more comprehensive.

In order to run your own assembly codes on phoeniX, create a directory named to your project such as `/my_project` in `/Software/User_Codes/`. Put all your `.s` files in `/my_project`. First simulate your code with `Venus` and then from the VS-code debug panel, select `VENUS OPTIONS` > `Views` > `Assembly`. A new tab will pop up in the Visual Studio Code editor that includes full instructions along with their addresses and their hex format.
Save this new tab as a `.txt` file in `/my_project`.\
Note
: that the assembly output of the Venus Simulator for the code must be also saved in the project directory.\
To run your projects from the main directory simply run `python AssembleX.py code` followed by the name of the project which will be passed as a variable to the Python script:
```
python AssembleX.py code my_project
```

After execution of this script, a firmware file will be generated which can be directly fed to the Verilog testbench. AssembleX modifies the testbench file to include this new firmware file and automatically runs the testbench and calls upon gtkwave to display the selected signals. It also reverts the changes made in testbench file for next simulations.
</div>

## Synthesis Result
<div align="justify">

phoeniX core design is capable of synthesis for both FPGA targets and ASIC design. The code has been carefully crafted to enable the utilization of the processor as a soft-core on Xilinx FPGA devices. 
While the core is entirely synthesizable, it is important to note that implementation is limited to Xilinx Ultrascale and Ultrascale+ series of [AMD Xilinx FPGA devices](https://www.amd.com/en/products/xilinx), owing to the processor's pipline structle requiring many logic cells. The phoeniX core can be implemented as a softcore CPU on Xilinx 7 Ultrascale/Ultrascale+ series FPGA boards using logic synthesis.

The physical design and layout of phoeniX was done using [Qflow](http://opencircuitdesign.com/qflow/), a popular open-source VLSI (Very Large Scale Integration) design tool. Qflow is a complete design flow that encompasses various stages of the VLSI design process, including synthesis, placement, routing, and verification.

The OSU018 technology, also known as the [TSMC 0.18 micron](https://www.tsmc.com/english/dedicatedFoundry/technology/logic/l_018micron) process technology, which was used for phoeniX layout design, is a widely adopted semiconductor fabrication process developed by Oklahoma State University. It belongs to the 180nm technology node, which refers to the minimum feature size produced using this process.
The OSU018 technology offers several key characteristics and capabilities that make it suitable for a range of digital integrated circuit designs. 
</div>

Here is a picture of final layout result of the phoeniX core using Qflow:

![IMG_6971](https://github.com/phoeniX-Digital-Design/phoeniX/assets/86099054/1f605f7b-3548-4740-af99-e05e437f641e)

![IMG_6972](https://github.com/phoeniX-Digital-Design/phoeniX/assets/86099054/8ac48aaa-0ae1-45ec-a979-e9d0693151ea)

<div align="justify">

The Static Time Analysis (STA) results indicate that the maximum delay observed in the core modules, and consequently in the pipeline stages, is approximately 4 nanoseconds. Setting the **clock cycle time at 4 nanoseconds** allows for sufficient margin to account for the maximum delay across the modules plus register setup time and hold time, ensuring that data propagates through the pipeline within the specified time frame. 
By adhering to this timing requirement, the processor can achieve a performance level of approximately **250 MHz**, enabling efficient execution of instructions and supporting the desired operational specifications.

</div>
