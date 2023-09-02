import os
text = """

phoeniX core RISC-V C code executant for Linux
Version : 0.1

This script is designed to execute C code compiled by RISC-V GCC compiler toolchain in linux.
By : Arvin Delavari - Faraz Ghoreishy
Iran University of Science and Technology - August 2023

To execute this program, please follow these steps:
1) Write a C or Assembly code to be executed on phoeniX core.
2) Enter number of input files.
3) Enter the source files names (.s and .c).

Note: Following files must be included in the repository. please don't remove any of these files:
- hex8to32.py  - riscv.ld   - start.ld
- start.S      - syscall.c 

"""
print(text)
input_file_numbers = int(input("Enter number of input files:\n"))
input_name = [""] * (input_file_numbers + 1)

name_input = [""] * (input_file_numbers + 1)
type_input = [""] * (input_file_numbers + 1)

for i in range (1, input_file_numbers + 1):
    input_name[i] = input("Enter input file name (with suffix .c or .s):\n")

print("List of input files:\n")
for i in range (1, input_file_numbers + 1):
    print(input_name[i]+'\n')

    split_type = input_name[i].split(".")
    name_input[i] = split_type[0]
    type_input[i] = split_type[1]
    print("name: ", name_input[i])
    print("type: ", type_input[i])

# Define output executable file (shell script)
output_file  = os.path.join(os.getcwd(), "pheoniX_code_executant.sh")

# Generating shell script file:
with open(output_file, 'w') as file:

    for i in range(1, input_file_numbers + 1):
        file.write('riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32i -o ' + name_input[i] + '.o ' + name_input[i] +'.'+ type_input[i] +'\n')
        
    file.write('riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32i -o syscalls.o syscalls.c\n\n')
        
    file.write('riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32i -Wl,--gc-sections -o firmware.elf ')
    for i in range(1, input_file_numbers + 1):
        file.write(name_input[i] + '.o ')
    file.write('syscalls.o -T riscv.ld -lstdc++\n\n')

    file.write('riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32i -nostdlib -o start.elf start.S -T start.ld -lstdc++\n')
    file.write('chmod -x start.elf\n\n')

    file.write('riscv64-unknown-elf-objcopy -O verilog start.elf start.tmp\n')
    file.write('riscv64-unknown-elf-objcopy -O verilog firmware.elf firmware.tmp\n\n')
    
    file.write('cat start.tmp firmware.tmp > firmware.hex\n')
    file.write('python3 hex8tohex32.py firmware.hex > firmware32.hex\n')
    file.write('rm -f start.tmp firmware.tmp\n\n')

    file.write('iverilog -o phoeniX.vvp phoeniX_Testbench.v\n')
    file.write('chmod -x phoeniX.vvp\n')
    file.write('vvp -N phoeniX.vvp\n')
    file.write('gtkwave phoeniX.vcd')
# End of shell script generation

# OS task to execute created shell script file
os.system('sh pheoniX_code_executant.sh ') 