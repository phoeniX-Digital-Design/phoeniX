# Specify the input file name
input_file = "firmware32.hex"

# Specify the output file name
output_file = "phoeniX_firmware.hex"

# Open the input file in read mode and output file in write mode
with open(input_file, "r") as file_in, open(output_file, "w") as file_out:
    # Iterate over each line in the input file
    for line in file_in:
        # Check if the line starts with "@"
        if not line.startswith("@"):
            # Remove leading and trailing whitespaces from the line
            line = line.strip()
            
            # Split the line into chunks of 8 characters
            chunks = [line[i : i + 8] for i in range(0, len(line), 8)]
            
            # Iterate over each chunk and write two digits per line
            for chunk in chunks:
                # Split the chunk into two digits
                digits = [chunk[i:i+2] for i in range(0, len(chunk), 2)]
                
                # Write the two digits as a line in the output file
                file_out.write('\n'.join(digits) + '\n')


    