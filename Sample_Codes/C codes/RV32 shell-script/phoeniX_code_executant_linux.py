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
    input_name[i] = input("Enter input file name (without .c):\n")

print("List of input files:\n")
for i in range (1, input_file_numbers + 1):
    print(input_name[i]+'\n')

# Define input executable file (shell script)
input_file   = os.path.join(os.getcwd(), "rv32im.sh")
output_file  = os.path.join(os.getcwd(), "pheoniX_code_executant.sh")

# Read the contents of the input file (assembly text file)
with open(input_file, "r") as file:
    lines = file.readlines()

with open(output_file, 'w') as file:
    for i in range(1, input_file_numbers + 1):
        file.write('riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o ' + input_name[i] + '.o ' + input_name[i] + '.c\n')
        
    file.write('riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o syscalls.o syscalls.c\n\n')
        
    file.write('riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32im -Wl,--gc-sections -o firmware.elf ')
    for i in range(1, input_file_numbers + 1):
        file.write(input_name[i] + '.o ')
    file.write('syscalls.o -T riscv.ld -lstdc++\n\n')

    file.write('riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32im -nostdlib -o start.elf start.S -T start.ld -lstdc++\n')
    file.write('chmod -x start.elf\n\n')

    file.write('riscv64-unknown-elf-objcopy -O verilog start.elf start.tmp\n')
    file.write('riscv64-unknown-elf-objcopy -O verilog firmware.elf firmware.tmp\n\n')
    
    file.write('cat start.tmp firmware.tmp > firmware.hex\n')
    file.write('python3 hex8tohex32.py firmware.hex > firmware32.hex\n')
    file.write('python3 phoeniX_firmware.py\n')
    file.write('rm -f start.tmp firmware.tmp')