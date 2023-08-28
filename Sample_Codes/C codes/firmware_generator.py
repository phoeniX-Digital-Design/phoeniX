import re
import os

text = """
RISC-V GCC Firmware Generator V0.1
- This Python script creates a HEX firmware file suitable for phoeniX core.
- Object dumpfiles created by GCC compiler toolchain are saved in text format and given to the script.
- Text dumpfile and firmware file names must be given to the scripts as inputs.
- After execution created firmware.hex file is ready to be given to testbench file of phoeniX core. """
print(text)

input_name  = input("Enter input file name:\n")
output_name = input("Enter firmware file name:\n")

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
# Save the result to a file
with open(output_name, 'w') as file:
    file.write(result + '\n')

# Specify the file path
file_path = 'temp.txt'
# Delete the file
os.remove(file_path)