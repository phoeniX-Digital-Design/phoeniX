#  AssembleX V3.0
#  RISC-V Assembly Software Assistant for the phoeniX project (https://github.com/phoeniX-Digital-Design/phoeniX)

#  Description: AssembleX main code
#  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.

import  sys
import  os
import  glob

from    Software.AssembleX.variables          import   *
from    Software.AssembleX.assembler          import   assembler
from    Software.AssembleX.address_mapping    import   address_mapping
from    Software.AssembleX.address_mapping    import   label_mapping
from    Software.AssembleX.address_mapping    import   define_reset_address
from    Software.AssembleX.data_conversion    import   binary_to_hex
from    Software.AssembleX.data_conversion    import   ascii_to_hex

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

print("\nAssembleX V3.0 - RV32IM Assembly Code Executant Software")
print("Iran University of Science and Technology - Summer 2024")
print("--------------------------------------------------------")

try:
    source_path  = list(glob.iglob(os.path.join("Software", directory, project_name, '*' + ".s")))[0]
    firmware_hex_path = os.path.join("Software", directory, project_name, output_name)
    print(source_path)
    print(firmware_hex_path)
    #source_path = sys.argv[1]
    #firmware_hex_path = sys.argv[1].rstrip('.s') + '_firmware.hex'
except:
    print('INFO: No arguments/unsupported arguments\n')

try:
    source_file = open(source_path, "r")
    source_code_unformatted = source_file.read().splitlines()
    print("INFO: Source file opened successfully\n")
except:
    print("FATAL ERROR:  Unable to open source file\n")
    exit(1)

print('Assembly code pre-processing')
print('----------------------------')
source_code = []
for line in source_code_unformatted:
    instruction_format_space = " ".join(line.split())
    instruction_format_comments = " #".join(instruction_format_space.split('#', 2))
    instruction_format_leadspace = instruction_format_comments.lstrip()
    source_code.append(instruction_format_leadspace)

# Re-format immediate expressions
processed_code_1 = []
for line in source_code:
    arguments = line.split(',')
    try:
        if arguments[0][0] == '#':
            processed_code_1.append(line)
            continue
        elif arguments[0] == '.RESET_ADDRESS':
            processed_code_1.append(line)
            continue
    except:
        processed_code_1.append(line)
        continue
    # Check for 2 argument immediate expressions: 'x(y)' -> parse: 'y x'
    # Check for ASCII: char -> hex
    parse_ascii = [False]
    try:
        arguement_2_wc = arguments[1]
        arguement_2_wc = arguement_2_wc.split('#', 2)
        len_arguement_2_wc = len(arguement_2_wc)
        arguement_2 = [arguement_2_wc[0]]
        ascii_to_hex(arguement_2)
        arguement_2_pp = arguement_2[0].replace(')', '(')
        arguement_2_pp = "".join(arguement_2_pp.split())
        arguement_2_list = arguement_2_pp.split('(')
        if len_arguement_2_wc == 2:
            arguments[1] = ' ' + arguement_2_list[1] + ', ' + arguement_2_list[0] + ' ' + '#' + arguement_2_wc[1]  # Modified expression
        else:  # No inline comment
            arguments[1] = ' ' + arguement_2_list[1] + ', ' + arguement_2_list[0]  # Modified expression
        processed_code_1.append(",".join(arguments))
    except:
        if parse_ascii[0]:
            if len_arguement_2_wc == 2:
                arguments[1] = arguement_2[0] + ' ' + '#' + arguement_2_wc[1]  # Modified expression
            else:
                arguments[1] = arguement_2[0]  # Modified expression
            processed_code_1.append(",".join(arguments))
        else:
            processed_code_1.append(line)
        continue

# Remove "," change "," -> " "
processed_code_2 = []
for line in processed_code_1:
    line = line.replace(',', ' ')
    processed_code_2.append(" ".join(line.split()))

lines_of_code = len(processed_code_2)
print('Lines of code =', lines_of_code, '\n')

start_address = define_reset_address(processed_code_2[0])

for line in source_code:
    label_state = label_mapping(start_address, line, instruction_counter, 
                                expected_instructions_count, lable_counter, 
                                label_list, label_address_list)
address_mapping(lable_counter, label_list, label_address_list)

# Parser
print('')
print('Parser')
print('------')
pc[0] = start_address
for line in processed_code_2:
    instruction_sts = assembler(pc, line, line_number, error_flag, error_counter, bin_instruction)
    line_number = line_number + 1

# Summary
print('\nSummary')
print('-------')
if error_flag[0] == 0:
    print('- Lines of code (source)   = ', lines_of_code)
    print('- Assembled instructions   = ', instruction_counter[0])
    print('- Instructions with ERRORS = ', error_counter[0])
    binary_to_hex(bin_instruction, hex_instruction)
    try:
        # HEX firmware file write
        file = open(firmware_hex_path, "w")
        for line in hex_instruction:
            file.write(line + '\n')
        print('\nDONE: Successfully created FIRMWARE file\n')
        file.close()
    except:
        print('\nFATAL ERROR: Unable to create FIRMWARE file\n')
else:
    print('- Lines of code (source)   = ', lines_of_code)
    print('- Assembled instructions   = ', instruction_counter[0])
    print('- Instructions with ERRORS = ', error_counter[0])
    print('\nFAIL:Failed to parse the assembly code due to errors')

# Change firmware in the testbench file
with open(testbench_file, 'r') as file:
    lines = file.readlines()
# Edit source files of testbench names
with open(testbench_file, 'w') as file:
    for line in lines:
        # Change instruction memory source file
        if line.startswith("    `define FIRMWARE "):
            print("Line found!")
            # Modify the input file name
            firmware_hex_path = firmware_hex_path.replace("\\", "\\\\")
            print(firmware_hex_path)
            modified_line = line.replace(line,'    `define FIRMWARE '+ '"' + firmware_hex_path + '"' +'\n' )
            print(modified_line)
            file.write(modified_line)
        else:
            file.write(line)

# OS: cmd commands to execute Verilog simulations:
os.system("iverilog -IModules -o phoeniX.vvp phoeniX_Testbench.v") 
os.system("vvp phoeniX.vvp") 
os.system("gtkwave phoeniX.gtkw") 