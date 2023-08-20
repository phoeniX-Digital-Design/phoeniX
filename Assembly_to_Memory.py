input_file  = "assembly.txt"
output_file = "imem_code.txt"

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
