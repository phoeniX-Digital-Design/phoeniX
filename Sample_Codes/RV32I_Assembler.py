# RV32I Assembler
# Arvin Delavari - August 2023
# Iran University of Science and Technology
# -----------------------------------------

import re

# Input '.s' or '.asm' RISC-V assembly code name
input_file = input('Assembly code name: ')

# Instruction encoding dictionary
RTYPE_encoding = {
    # R-type instructions
    "add":  {"opcode": "0110011", "funct3": "000", "funct7": "0000000"},
    "sub":  {"opcode": "0110011", "funct3": "000", "funct7": "0100000"},
    "and":  {"opcode": "0110011", "funct3": "111", "funct7": "0000000"},
    "or":   {"opcode": "0110011", "funct3": "110", "funct7": "0000000"},
    "xor":  {"opcode": "0110011", "funct3": "100", "funct7": "0000000"},
    "sll":  {"opcode": "0110011", "funct3": "001", "funct7": "0000000"},
    "srl":  {"opcode": "0110011", "funct3": "101", "funct7": "0000000"},
    "slt":  {"opcode": "0110011", "funct3": "010", "funct7": "0000000"},
    "sltu": {"opcode": "0110011", "funct3": "011", "funct7": "0000000"},
}
ITYPE_encoding = {
    # I-type instructions
    "addi": {"opcode": "0010011", "funct3": "000"},
    "andi": {"opcode": "0010011", "funct3": "111"},
    "ori":  {"opcode": "0010011", "funct3": "110"},
    "xori": {"opcode": "0010011", "funct3": "100"},
    "lw":   {"opcode": "0000011", "funct3": "010"},
    "sw":   {"opcode": "0100011", "funct3": "010"},
    }
UTYPE_encoding = {
    # U-type instructions
    "lui":  {"opcode": "0110111"},
}
BTYPE_encoding = {
    # B-type instructions
    "beq": {"opcode": "1100011", "funct3": "000"},
    "bne": {"opcode": "1100011", "funct3": "001"},
    "blt": {"opcode": "1100011", "funct3": "100"},
    "bge": {"opcode": "1100011", "funct3": "101"},
}
JTYPE_encoding = {
    # J-type instructions
    "jal": {"opcode": "1101111"},
    }

# Register encoding dictionary
register_encoding = {
    "zero":"00000",
    "ra":  "00001",
    "sp":  "00010",
    "gp":  "00011",
    "tp":  "00100",
    "t0":  "00101",
    "t1":  "00110",
    "t2":  "00111",
    "s0":  "01000",
    "s1":  "01001",
    "a0":  "01010",
    "a1":  "01011",
    "a2":  "01100",
    "a3":  "01101",
    "a4":  "01110",
    "a5":  "01111",
    "a6":  "10000",
    "a7":  "10001",
    "s2":  "10010",
    "s3":  "10011",
    "s4":  "10100",
    "s5":  "10101",
    "s6":  "10110",
    "s7":  "10111",
    "s8":  "11000",
    "s9":  "11001",
    "s10": "11010",
    "s11": "11011",
    "t3":  "11100",
    "t4":  "11101",
    "t5":  "11110",
    "t6":  "11111",
}

def assembler(input_file):
    hex_instructions = []

    # Read the input file
    with open(input_file, "r") as f:
        lines = f.readlines()

    # Process each line
    for line in lines:
        line = line.strip()

        # Skip empty lines and comments
        if not line or line.startswith("#"):
            continue

        # Skip metadata lines
        if line.startswith(".text") or line.startswith(".globl") or line.startswith("main") or line.startswith("."):
            continue

        # Split arguments and instructions
        tokens = line.split()
        instruction = tokens[0] # Store instructions as a list
        args = tokens[1:]       # Store arguments as a list
        arguments = re.findall(r'\b\w+\b|-?\d+|\w+', args[0].replace('(', ' ').replace(')', ' '))
        print(instruction)
        print(arguments)

    return hex_instructions

def encode_immediate(imm, inst_type):
    if inst_type == 'I':
        # I-type: imm[11:0]
        encoded_imm = (imm & 0xfff) << 20
    elif inst_type == 'S':
        # S-type: imm[11:5|4:0]
        encoded_imm = ((imm & 0xfe0) << 20) | ((imm & 0x1f) << 7)
    elif inst_type == 'B':
        # B-type: imm[12|10:5|4:1|11]
        encoded_imm = ((imm & 0x800) << 20) | ((imm & 0x3f0) << 21) | ((imm & 0x00e) << 7) | ((imm & 0x001) << 11)
    elif inst_type == 'U':
        # U-type: imm[31:12]
        encoded_imm = imm & 0xfffff000
    elif inst_type == 'J':
        # J-type: imm[20|10:1|11|19:12]
        encoded_imm = ((imm & 0xff000) << 12) | ((imm & 0x800) << 9) | ((imm & 0x3ff) << 21) | ((imm & 0x400) << 11)
    else:
        raise ValueError(f"Invalid instruction type: {inst_type}")

    return f"{encoded_imm:032b}"  # Convert the encoded immediate to a binary string

# Example usage:
print(f"Encoding for I-type instruction: {encode_immediate(12, 'I')}")
print(f"Encoding for S-type instruction: {encode_immediate(12, 'S')}")
print(f"Encoding for B-type instruction: {encode_immediate(12, 'B')}")
print(f"Encoding for U-type instruction: {encode_immediate(12, 'U')}")
print(f"Encoding for J-type instruction: {encode_immediate(12, 'J')}")

# Usage example
hex_instructions = assembler(input_file)
for instruction in hex_instructions:
    print(instruction)