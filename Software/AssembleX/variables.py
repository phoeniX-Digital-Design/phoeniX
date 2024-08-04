#  AssembleX V3.0
#  RISC-V Assembly Software Assistant for the phoeniX project (https://github.com/phoeniX-Digital-Design/phoeniX)

#  Description: Global variables
#  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.

pc = [0]
line_number = 1

# BIN/HEX assembled instructions
bin_instruction = []
hex_instruction = []

# Error detection varibales intial values
error_flag      = [0]
error_counter   = [0]
instruction_sts = 0

# Address mapping varibales intial values
label_list                  = []
label_address_list          = []
instruction_counter         = [0]
expected_instructions_count = [0]
lable_counter               = [0]