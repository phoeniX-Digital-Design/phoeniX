# ----------------------------------------------------------------
# |                          AssembleX                           |
# | ------------------------------------------------------------ |
# | Custom-built RISC-V assembly code executant for phoeniX core |
# |          By : Arvin Delavari - Faraz Ghoreishy               |
# |   Iran University of Science and Technology - Summer 2023    |
# ----------------------------------------------------------------
import os
import sys
import glob

testbench_file = "phoeniX_Testbench.v"
option = sys.argv[1]
project_name = sys.argv[2]
output_name = project_name + "_firmware" + ".hex"

if option == 'sample':
    directory = "Sample_Assembly_Codes"
elif option == 'code':
    directory = "User_Codes"
else:
    raise ValueError("Options are: sample, code")

input_file  = list(glob.iglob(os.path.join("Software", directory, project_name, '*' + ".txt")))[0]
output_file = os.path.join("Software", directory, project_name, output_name)

# Read the contents of the input file (assembly text file)
with open(input_file, "r") as file:
    lines = file.readlines()

# Remove the first and third columns from each line (PC and Code)
modified_lines = [line.split()[1] +'\n' for line in lines]

# Remove the "0x" prefix from each line
modified_lines = [line[2:] for line in modified_lines]

# Remove '\n\n' elements from the array
final_hex_code = [elem for elem in modified_lines if elem != '\n\n']
# print(final_hex_code)

# Write the modified contents to the output file
with open(output_file, "w") as file:
    file.writelines(final_hex_code)

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