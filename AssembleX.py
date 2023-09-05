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

# OS : cmd commands to execute Verilog simulations:
# 1 - Create VVP file form testbench
# 2 - Execute VVP file and create VCD file
# 3 - Open VCD file in GTKWave
# Output wavforms will be automatically opened in GTKWave

print(output_file, type(output_file))
command = f"iverilog -IModules -DFIRMWARE=\"{output_file}\" -o phoeniX.vvp phoeniX_Testbench.v"
print(command)
#os.system(command) 
#os.system("vvp phoeniX.vvp") 
#os.system("gtkwave phoeniX.gtkw") 