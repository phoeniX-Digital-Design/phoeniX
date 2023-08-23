import os
text = """
phoeniX core RISC-V C code executant for Linux
Version : 0.1
This script is designed to execute C code compiled by RISC-V GCC compiler toolchain in linux.
By : Arvin Delavari - Faraz Ghoreishy
Iran University of Science and Technology - August 2023
To execute this program, please follow these steps:
1) Write a C code to be executed on phoeniX core.
2) Enter number of input files.
3) Enter the C code file name.
4) TBD.
Note: Following files must be included in the repository. please don't remove any of these files:
- firmware.elf - hex8to32.py - riscv.ld 
- rv32im.sh    - start.elf   - start.ld
- start.S      - syscall.c 
"""
print(text)
input_file_numbers = int(input("Enter number of input files:\n"))
input_name = [""] * (input_file_numbers + 1)

for i in range (1, input_file_numbers + 1):
    input_name[i] = input("Enter input file name:\n")

print("List of input files:\n")
for i in range (1, input_file_numbers + 1):
    print(input_name[i]+'\n')

