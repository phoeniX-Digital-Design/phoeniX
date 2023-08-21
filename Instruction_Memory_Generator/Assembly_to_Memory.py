import os
text = """
RISC-V code to phoeniX instruction memory
1) Write, simulate and modify your assembly code in Venus simulator.
2) In 'VENUS OPTIONS' select 'Assembly' and save the output file as a text file.
3) Enter the created text file name.
4) Enter the output file (instruction memory) name.
5) Output file created is the instruction memory and can be given to testbench."""
print(text)

print('Input file is the assembly code filed in Venus RISC-V simulator save in a text (.txt) format.')
input_name = input("Enter input file name:\n")
print('Output file is the transformed code to be used as the instruction memory of the core.')
output_name = input("Enter output file name:\n")

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
