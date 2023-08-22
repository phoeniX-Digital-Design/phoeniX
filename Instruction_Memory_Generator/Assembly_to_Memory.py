import os
text = """
RISC-V assembly code to phoeniX instruction memory
1) Write, simulate and modify your assembly code in Venus simulator.
2) In 'VENUS OPTIONS' select 'Assembly' and save the output file as a text file (.txt).
3) Enter the created text file name.
4) Enter the instruction memory file name.
5) Enter the data memory file name.
6) Output files are created and are given to testbench."""
print(text)

# Name files (input from user)
input_name = input("Enter input file name:\n")
output_name = input("Enter instruction memory file name:\n")
data_mem_name = input("Enter data memory file name:\n")

input_file  = os.path.join(os.getcwd(), input_name)
output_file = os.path.join(os.getcwd(), output_name)

# Read the contents of the file
with open(input_file, "r") as file:
    lines = file.readlines()

# Remove the first and third columns from each line
modified_lines = [line.split()[1] +'\n' for line in lines]

# Remove the "0x" prefix from each line
modified_lines = [line[2:] for line in modified_lines]

# Split each line into separate lines with two digits
split_lines = [line[i : i + 2] + '\n' for line in modified_lines for i in range(0, len(line), 2)]
print(split_lines)

# Remove '\n\n' elements from the array
final_hex_code = [elem for elem in split_lines if elem != '\n\n']
print(final_hex_code)

# Write the modified contents back to the output file
with open(output_file, "w") as file:
    file.writelines(final_hex_code)


# Open and edit testbench file
testbench_file = "phoeniX_Testbench.v"

with open(testbench_file, 'r') as file:
    lines = file.readlines()

# Edit source files of testbench names
with open(testbench_file, 'w') as file:
    for line in lines:
        # Change instruction memory source file
        if line.startswith("\t\t$readmemh("):
            print("Line found!")
            # Modify the input file name
            modified_line = line.replace(line,'\t\t$readmemh("Sample_Codes'+ "\\\\" + output_name +'"' + ', uut.fetch_unit.instruction_memory.Memory);\n' )
            file.write(modified_line)
        # Change data memory source file
        elif line.startswith("\t\tdata_memory_file = $fopen("):
            print("Line found!")
            # Modify the input file name
            modified_line = line.replace(line,'\t\tdata_memory_file = $fopen("Sample_Codes' + "\\\\" + data_mem_name + '"' + ', "w");\n')
            file.write(modified_line)
        else:
            file.write(line)

os.system('cmd /c "iverilog -o phoeniX.vvp phoeniX_Testbench.v"') 
os.system('cmd /c "vvp phoeniX.vvp"') 
os.system('cmd /c "gtkwave phoeniX.vcd"') 