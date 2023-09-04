import os

input_file_name = input("Enter C code name:\n")

# Define output executable file (shell script)
output_file_name  = os.path.join(os.getcwd(), "GCC_to_ASM.sh")

# Generating shell script file:
with open(output_file_name, 'w') as file:
    # This command will create .S (assembly) file from the given C code
    file.write('riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32i -S ' + input_file_name + '\n')

split_type = input_file_name.split(".")
name = split_type[0]
type = split_type[1]

# Filter output assembly file in a format which Venus simulator can execute
keywords = ['.size', '.file', '.option', '.attribute', '.align', '.type', '.ident']
with open(name + '.s', 'r') as file:
    lines = file.readlines()
filtered_lines = [line for line in lines if not line.strip().startswith(tuple(keywords))]
with open(name + '.s', 'w') as file:
    file.writelines(filtered_lines)

