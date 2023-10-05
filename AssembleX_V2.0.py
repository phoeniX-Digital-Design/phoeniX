'''
AssembleX V2.0

AssembleX a free open-source software designed to automate the execution process of an assembly code on
a RISC-V processor. Fisrt Version used to work the help of Venus simulator which was a VS code extension.
AssembleX Version 2.0 has an integrated assembler inside which eliminates the interference of Venus Simulator.
User manual is included in the README.md inside AssembleX repository. AssembleX is designed in order to run and
execute assembly codes on phoeniX RISC-V processor of IUST-ERC; but can also be used on other projects as an
instruction memory generator (for Verilog ans SystemVerilog CPU targets).
phoeniX project : https://github.com/phoeniX-Digital-Design/phoeniX
Assembler source : https://github.com/celebi-pkg/riscv-assembler

Arvin Delavari - Iran Universisty of Science and Technology, Electronics Research Center
Digital Design Research Lab, SCaN (SuperComputing and Networking) Research Lab - Fall 2023

''' 

from assembler_src.convert import converter as assembly_converter
import os
import sys
import glob

testbench_file = "phoeniX_Testbench.v"
option = sys.argv[1]
project_name = sys.argv[2]
output_name = project_name + "_firmware"

if option == 'sample':
    directory = "Sample_Assembly_Codes"
elif option == 'code':
    directory = "User_Codes"
else:
    raise ValueError("Options are: sample, code")

file_path = "Software" + "/" + directory,directory + "/" + project_name + "/" + output_name + ".txt"
hex_file_path = "Software" + "/" + directory + "/" + project_name + "/" + output_name + ".hex"
print ("file path = " + file_path)

def delete_file(hex_file_path):
    if os.path.exists(hex_file_path):
        os.remove(hex_file_path)
        print(f">> File deleted: {hex_file_path}")
    else:
        print(f">> File not found: {hex_file_path}")
delete_file(hex_file_path)

# instantiate object, by default outputs to a file in nibbles, not in hexademicals
convert = assembly_converter(output_mode = 'f', nibble_mode = True, hex_mode = False)
input_file  = list(glob.iglob(os.path.join("Software", directory, project_name, '*' + ".s")))[0]
output_file = os.path.join("Software", directory, project_name, output_name)

def comment_ebreak(input_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()
    modified_lines = [line.replace('ebreak', '#ebreak') if 'ebreak' in line else line for line in lines]
    with open(input_file, 'w') as file:
        file.writelines(modified_lines)
    print(">> ebreak commented")
comment_ebreak(input_file)

# Convert a whole .s file to text file
convert(input_file, file_path)
def remove_spaces_in_lines(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
    lines = [line.replace('\t', '') for line in lines]
    with open(file_path, 'w') as file:
        file.writelines(lines)
remove_spaces_in_lines(file_path)

def binary_to_hex(binary_string):
    decimal_value = int(binary_string, 2)
    hex_string = hex(decimal_value)[2:].zfill(8)
    return hex_string

def convert_lines_to_hex(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
    hex_lines = [binary_to_hex(line.strip()) for line in lines]
    with open(file_path, 'w') as file:
        file.write('\n'.join(hex_lines))
convert_lines_to_hex(file_path)

ebreak = '00100073'
with open(file_path, 'a') as file:
    file.write('\n' + ebreak)
    print(">> ebreak 00100073 added to hex file")

def change_file_format(file_path, new_format):
    directory, base_name = os.path.split(file_path)
    name, old_format = os.path.splitext(base_name)
    new_file_path = os.path.join(directory, name + new_format)
    os.rename(file_path, new_file_path)
    print(f"File renamed: {new_file_path}")

new_format = '.hex'
change_file_format(file_path, new_format)

def uncomment_ebreak(input_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()
    modified_lines = [line.replace('#ebreak', 'ebreak') if '#ebreak' in line else line for line in lines]
    with open(input_file, 'w') as file:
        file.writelines(modified_lines)
    print(">> ebreak uncommented")
uncomment_ebreak(input_file)
print(">> HEX firmware generated successfully")

# Change firmware in the testbench file
with open(testbench_file, 'r') as file:
    lines = file.readlines()
# Edit source files of testbench names
with open(testbench_file, 'w') as file:
    for line in lines:
        # Change instruction memory source file
        if line.startswith("\t`define FIRMWARE"):
            print("Line found!")
            # Modify the input file name
            output_file = output_file.replace("\\", "\\\\")
            modified_line = line.replace(line,'\t`define FIRMWARE '+ '"' + output_file + '"' +'\n' )
            file.write(modified_line)
        else:
            file.write(line)

# OS : cmd commands to execute Verilog simulations:
os.system("iverilog -IModules -o phoeniX.vvp phoeniX_Testbench.v") 
os.system("vvp phoeniX.vvp") 
with open(testbench_file, 'w') as file:
    for line in lines:
        # Change testbench file
        if line.startswith("\t`define FIRMWARE"):
            print("Line found!")
            # Remove firmware file address
            modified_line = line.replace(line,'\t`define FIRMWARE\n')
            file.write(modified_line)
        else:
            file.write(line)
os.system("gtkwave phoeniX.gtkw") 