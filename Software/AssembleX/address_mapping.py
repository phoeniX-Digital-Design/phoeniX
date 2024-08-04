#  AssembleX V3.0
#  RISC-V Assembly Software Assistant for the phoeniX project (https://github.com/phoeniX-Digital-Design/phoeniX)

#  Description: Address mapping and translation functions
#  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.

def define_reset_address(first_line):
    start_address = first_line.split()
    try:
        if start_address[0] == '.RESET_ADDRESS':
            address_pre = start_address[1]
            if address_pre[0:2] == '0x' or address_pre[0:2] == '0X':
                address = (int(address_pre, base=16) >> 2) * 4
            else:
                address = (int(address_pre) >> 2) * 4
            print('INFO: .RESET_ADDRESS set to', "0x{:08x}".format(address))
            return address
        else:
            print('WARNING: .RESET_ADDRESS not defined. -> .RESET_ADDRESS overridden to 0x00000000\n')
            return 0
    except:
        print('WARNING: .RESET_ADDRESS not defined. -> .RESET_ADDRESS overridden to 0x00000000\n')
        return 0
    
def label_mapping(base_address, line, instrcnt, expected_instructions_count, label_counter, label_list, label_address_list):
    words = line.split()
    # Check if blank line or comment or start_address
    try:
        if words[0][0] == '#':
            # Ignore comment and move on
            return 0
        elif words[0] == '.RESET_ADDRESS':
            # Ignore start_address
            return 0
    except:
        # Ignore blank line and move on
        return 0

    if len(words) == 1 and line[-1] == ':':
        label = line.split(':')[0]
        label_counter[0] = label_counter[0] + 1
        label_list.append(label)
        label_address_list.append(base_address + int(expected_instructions_count[0]) * 4)
    elif len(words) > 1 and words[0][-1] == ':' and words[1][0] == '#':  # Decodes labels with comments
        label = line.split(':')[0]
        label_counter[0] = label_counter[0] + 1
        label_list.append(label)
        label_address_list.append(base_address + int(expected_instructions_count[0]) * 4)
    else:
        # It is an instruction
        instrcnt[0] = instrcnt[0] + 1
        if words[0] == 'LI' or words[0] == 'li' or words[0] == 'LA' or words[0] == 'la':
            offset = 2  # Because LI = expands to two instructions
        else:
            offset = 1
        expected_instructions_count[0] = expected_instructions_count[0] + offset

def address_mapping(label_counter, label_list, label_address_list):
    print('Address Mapping')
    print('---------------')
    for i in range(label_counter[0]):
        print('%+-8s' % label_list[i], ": 0x{:08x}".format(label_address_list[i]))