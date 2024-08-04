#  AssembleX V3.0
#  RISC-V Assembly Software Assistant for the phoeniX project (https://github.com/phoeniX-Digital-Design/phoeniX)

#  Description: Data conversion functions
#  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.

def binary_to_hex(bin_instruction, hex_instruction):
    for line in bin_instruction:
        hex_instruction.append("{:08x}".format(int(line, 2)))  # 32-bit hex from binary string

def int_to_binary(value):
    temp = value
    if value < 0:
        temp = 0xffffffff + 1 + value  # 2'string complement taken if -ve number
    binary = '{:032b}'.format(int(temp))  # Signed 32-bit binary
    return binary

parse_ascii = [False]
def ascii_to_hex(arguement):
    if arguement:
        string = arguement[0]
        x = string.split("'")
        if ((len(x) == 3 and len(x[1]) == 1) or
            ((len(x) == 3 and len(x[1]) == 2) and (x[1] == '\\n' or x[1] == '\\r'))):
            arguement_hex = character_to_hex(x[1])
            parse_ascii[0] = True
            if arguement_hex != "#ERR":
                modified_line = x[0] + arguement_hex + x[2]
                arguement[0] = modified_line
            else:
                arguement[0] = arguement

def character_to_hex(character):
    if character == ' ':
        return '0x20'
    elif character == '!':
        return '0x21'
    elif character == '"':
        return '0x22'
    elif character == '#':
        return '0x23'
    elif character == '$':
        return '0x24'
    elif character == '%':
        return '0x25'
    elif character == '&':
        return '0x26'
    elif character == "'":
        return '0x27'
    elif character == '(':
        return '0x28'
    elif character == ')':
        return '0x29'
    elif character == '*':
        return '0x2A'
    elif character == '+':
        return '0x2B'
    elif character == ',':
        return '0x2C'
    elif character == '-':
        return '0x2D'
    elif character == '.':
        return '0x2E'
    elif character == '/':
        return '0x2F'
    elif character == '0':
        return '0x30'
    elif character == '1':
        return '0x31'
    elif character == '2':
        return '0x32'
    elif character == '3':
        return '0x33'
    elif character == '4':
        return '0x34'
    elif character == '5':
        return '0x35'
    elif character == '6':
        return '0x36'
    elif character == '7':
        return '0x37'
    elif character == '8':
        return '0x38'
    elif character == '9':
        return '0x39'
    elif character == ':':
        return '0x3A'
    elif character == ';':
        return '0x3B'
    elif character == '<':
        return '0x3C'
    elif character == '=':
        return '0x3D'
    elif character == '>':
        return '0x3E'
    elif character == '?':
        return '0x3F'
    elif character == '@':
        return '0x40'
    elif character == 'A':
        return '0x41'
    elif character == 'B':
        return '0x42'
    elif character == 'C':
        return '0x43'
    elif character == 'D':
        return '0x44'
    elif character == 'E':
        return '0x45'
    elif character == 'F':
        return '0x46'
    elif character == 'G':
        return '0x47'
    elif character == 'H':
        return '0x48'
    elif character == 'I':
        return '0x49'
    elif character == 'J':
        return '0x4A'
    elif character == 'K':
        return '0x4B'
    elif character == 'L':
        return '0x4C'
    elif character == 'M':
        return '0x4D'
    elif character == 'N':
        return '0x4E'
    elif character == 'O':
        return '0x4F'
    elif character == 'P':
        return '0x50'
    elif character == 'Q':
        return '0x51'
    elif character == 'R':
        return '0x52'
    elif character == 'S':
        return '0x53'
    elif character == 'T':
        return '0x54'
    elif character == 'U':
        return '0x55'
    elif character == 'V':
        return '0x56'
    elif character == 'W':
        return '0x57'
    elif character == 'X':
        return '0x58'
    elif character == 'Y':
        return '0x59'
    elif character == 'Z':
        return '0x5A'
    elif character == '[':
        return '0x5B'
    elif character == '\\':
        return '0x5C'
    elif character == ']':
        return '0x5D'
    elif character == '^':
        return '0x5E'
    elif character == '_':
        return '0x5F'
    elif character == '`':
        return '0x60'
    elif character == 'a':
        return '0x61'
    elif character == 'b':
        return '0x62'
    elif character == 'c':
        return '0x63'
    elif character == 'd':
        return '0x64'
    elif character == 'e':
        return '0x65'
    elif character == 'f':
        return '0x66'
    elif character == 'g':
        return '0x67'
    elif character == 'h':
        return '0x68'
    elif character == 'i':
        return '0x69'
    elif character == 'j':
        return '0x6A'
    elif character == 'k':
        return '0x6B'
    elif character == 'l':
        return '0x6C'
    elif character == 'm':
        return '0x6D'
    elif character == 'n':
        return '0x6E'
    elif character == 'o':
        return '0x6F'
    elif character == 'p':
        return '0x70'
    elif character == 'q':
        return '0x71'
    elif character == 'r':
        return '0x72'
    elif character == 'string':
        return '0x73'
    elif character == 't':
        return '0x74'
    elif character == 'u':
        return '0x75'
    elif character == 'v':
        return '0x76'
    elif character == 'w':
        return '0x77'
    elif character == 'x':
        return '0x78'
    elif character == 'y':
        return '0x79'
    elif character == 'z':
        return '0x7A'
    elif character == '{':
        return '0x7B'
    elif character == '|':
        return '0x7C'
    elif character == '}':
        return '0x7D'
    elif character == '~':
        return '0x7E'
    elif character == '\\n':
        return '0x0A'
    elif character == '\\r':
        return '0x0D'
    else:
        return '#ERR'