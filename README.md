PhoeniX CORE
======================================

**PhoeniX** RISC-V processor was designed in Verilog HDL based on I-M-F extensions of [RISC-V Instruction Set Architecture](http://riscv.org/) and can execute `RV32I`, `RV32M` and `RV32F` instructions. 

You can find a list of full RISC-V assembly instructions in the [ISA documents](https://msyksphinz-self.github.io/riscv-isadoc/html/).

The core can be implemented as a softcore CPU on Xilinx 7 series FPGA boards using logic synthesis. This allows for flexible integration of the core's functionality within the FPGA fabric. The Xilinx 7 series FPGA boards provide a versatile platform for hosting the softcore CPU implementation, offering configurable features and adaptability.

The core has undergone a complete design flow, including synthesis, routing, and post layout process, to become an Integrated Circuit using open-source tools and the [QFlow](http://opencircuitdesign.com/qflow/) & [Siliconcompiler](https://github.com/siliconcompiler/siliconcompiler) projects. The ASIC implementation was specifically carried out utilizing the NANGate45nm Process Design Kit (PDK).

This repository contains an open source CPU under the [GNU V3.0 license](https://en.wikipedia.org/wiki/GNU_General_Public_License) and is free to use.



- Designed By : [Arvin Delavari](https://github.com/ArvinDelavari) and [Faraz Ghoreishy](https://github.com/FarazGhoreishy)
- Contact us : arvin7807@gmail.com - farazghoreishy@gmail.com
- Iran University of Science and Technology - August 2023
