Assembler Script
=================

<div align="justify">

AssembleX is currently working with the assistance of [riscv-assembler](https://github.com/celebi-pkg/riscv-assembler) written by Kaya Çelebi, which is indcluded in this directory. Though the key inspiration of the script was from the mentioned project, there has been some  changes in the original script in order to make a new code executant assistant software for RISC-V processors and instruction memory generation. The AssembleX software is originally designed for [phoeniX RISC-V processor](https://github.com/phoeniX-Digital-Design/phoeniX), but can also be used for any other processor written in Verilog, SystemVerilog and any other similar Hardware Description Languages.

The original package contains tools and functions that can convert RISC-V Assembly code to machine code. The whole process is implemented using Python purely for understandability, less so for efficiency in computation. These tools can be used to convert given lines of code or whole files to machine code. For conversion, output file types are binary, text files, and printing to console. The supported instruction types are R, I, S, SB, U, and UJ. Almost all standard instructions are supported, most pseudo instructions are also supported.

</div>

- RISC-V Assembly code assembler package: https://www.riscvassembler.org/
- RISC-V Assembler original script: https://github.com/celebi-pkg/riscv-assembler