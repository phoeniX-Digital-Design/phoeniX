import re
import os

text = """
RISC-V GCC Firmware Generator V0.1
- This Python script creates a HEX firmware file suitable for phoeniX core.
- Object dumpfiles created by GCC compiler toolchain are saved in text format and given to the script.
- Text dumpfile and firmware file names must be given to the scripts as inputs.
- After execution created firmware.hex file is ready to be given to testbench file of phoeniX core. """
print(text)

input_name    = input("Enter input file name:\n")
output_name   = input("Enter firmware file name:\n")
data_mem_name = input("Enter data memory file name:\n")

# Open the text file
with open(input_name, 'r') as file:
    contents = file.readlines()

# Remove lines with the specified format
filtered_lines = [line for line in contents if not re.match(r'\b[0-9a-fA-F]{8}\s*<\w+>\s*:', line)]
# Save the modified contents to the file
with open('temp.txt', 'w') as file:
    file.writelines(filtered_lines)

with open('temp.txt', 'r') as file:
    temp_contents = file.read()
# Extract 8-digit hexadecimal numbers using regular expression
eight_digit_hex_numbers = re.findall(r'\b[0-9a-fA-F]{8}\b', temp_contents)
# Join the filtered numbers into a single string
result = '\n'.join(eight_digit_hex_numbers)
split_lines = "".join([line[i : i + 2] + '\n' for line in result for i in range(0, len(line), 2)])

# Save the result to a file
with open(output_name, 'w') as file:
    file.write(split_lines)

# Specify the file path
file_path = 'temp.txt'
# Delete the file
os.remove(file_path)

# # Open and edit testbench file
# testbench_file = r"C:\Users\ASUS\OneDrive\Desktop\RV32-Core\phoeniX_Testbench.v"
# with open(testbench_file, 'r') as file:
#     lines = file.readlines()
# # Edit source files of testbench names
# with open(testbench_file, 'w') as file:
#     for line in lines:
#         # Change instruction memory source file
#         if line.startswith("\t\t$readmemh("):
#             print("Line found!")
#             # Modify the input file name
#             modified_line = line.replace(line,'\t\t$readmemh("Sample_Codes\\C codes'+ "\\\\" + output_name +'"' + ', uut.fetch_unit.instruction_memory.Memory);\n' )
#             file.write(modified_line)
#         # Change data memory source file
#         elif line.startswith("\t\tdata_memory_file = $fopen("):
#             print("Line found!")
#             # Modify the input file name
#             modified_line = line.replace(line,'\t\tdata_memory_file = $fopen("Sample_Codes\\C codes' + "\\\\" + data_mem_name + '"' + ', "w");\n')
#             file.write(modified_line)
#         else:
#             file.write(line)

# # OS : cmd commands to execute Verilog simulations:
# # 1 - Create VVP file form testbench
# # 2 - Execute VVP file and create VCD file
# # 3 - Open VCD file in GTKWave
# # Output wavforms will be automatically opened in GTKWave

# os.system('cmd /c "iverilog -o phoeniX.vvp phoeniX_Testbench.v"') 
# os.system('cmd /c "vvp phoeniX.vvp"') 
# os.system('cmd /c "gtkwave phoeniX.vcd"') 