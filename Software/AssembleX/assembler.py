#  AssembleX V3.0
#  RISC-V Assembly Software Assistant for the phoeniX project (https://github.com/phoeniX-Digital-Design/phoeniX)

#  Description: The main assembler function
#  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.

from    Software.AssembleX.variables          import *
from    Software.AssembleX.registers_rv32i    import   registers_rv32i
from    Software.AssembleX.registers_rv32i    import   register_index_mapping
from    Software.AssembleX.data_conversion    import   int_to_binary

# Return address of a label in code
def parse_address_label(input_value):
    for i in range(lable_counter[0]):
        if input_value == label_list[i]:
            return label_address_list[i]
    return input_value
# Check validity of operand registers
def validity_registers(register):
    if register not in registers_rv32i:
        return 1
    else:
        return 0
# Check validity of labels
def validity_label(label):
    if label in label_list:
        return 1
    else:
        return 0

def immediate_generator(immediate_value, line_number, error_status, jbflag, laflag):
    try:
        # Integer literal
        if int(immediate_value) < 0:
            immediate_value = 0xffffffff + 1 + int(immediate_value)  # 2's complement taken if -ve number
        immediate_value_binary = '{:032b}'.format(int(immediate_value))
        return immediate_value_binary
    except:
        try:
            # Hexadecimal literal
            if immediate_value[0:2] == '0x' or immediate_value[0:2] == '0X':
                if int(immediate_value, base=16) < 0:
                    immediate_value = 0xffffffff + 1 + int(immediate_value, base=16)  # 2's complement taken if -ve number
                    immediate_value_binary = '{:032b}'.format(int(immediate_value))  # 2's complement 32-bit binary
                else:
                    immediate_value_binary = '{:032b}'.format(int(immediate_value, base=16))
                return immediate_value_binary
            # Address Translation ->  Relative address for j/b-type instructions
            elif jbflag == 1 and validity_label(immediate_value.rstrip(':')):
                address_label = parse_address_label(immediate_value)
                pc_relative_address = address_label - pc[0]
                if pc_relative_address < 0:
                    pc_relative_address = 0xffffffff + 1 + pc_relative_address  # pc relative addr 2's complement
                immediate_value_binary = '{:032b}'.format(pc_relative_address, base = 16)
                return immediate_value_binary
            # Address Translation -> Absolute address for 'la' instruction
            elif laflag == 1 and validity_label(immediate_value.rstrip(':')):
                address_label = parse_address_label(immediate_value)
                abs_address = address_label
                immediate_value_binary = '{:032b}'.format(abs_address, base = 16)  # pc relative addr signed 32-bit
                return immediate_value_binary
            else:
                print("ERROR: Invalid immediate/offset value or label at line no: ", line_number)
                error_status[0] = 1
                return 0
        except:
            print("ERROR: Invalid immediate/offset value or label at line no: ", line_number)
            error_status[0] = 1
            return 0

def assembler(pc, line, line_number, error_flag, error_counter, bin_instruction):
    opcode_array = []
    # Instruction fields - initialization
    rs1 = 'x0'
    rs2 = 'x0'
    rd  = 'x0'
    immediate =  0
    # Instruction type flags
    r_type_flag = 0
    i_type_flag = 0
    s_type_flag = 0
    b_type_flag = 0
    u_type_flag = 0
    j_type_flag = 0
    # Pseudo instruction flags
    pseudo_instruction_mv_type_flag   = 0
    pseudo_instruction_mvi_type_flag  = 0
    pseudo_instruction_nop_type_flag  = 0
    pseudo_instruction_j_type_flag    = 0
    pseudo_instruction_not_type_flag  = 0
    pseudo_instruction_inv_type_flag  = 0
    pseudo_instruction_seqz_type_flag = 0
    pseudo_instruction_snez_type_flag = 0
    pseudo_instruction_beqz_type_flag = 0
    pseudo_instruction_bnez_type_flag = 0
    pseudo_instruction_li_type_flag   = 0
    pseudo_instruction_la_type_flag   = 0
    pseudo_instruction_jr_type_flag   = 0

    instruction_error_flag = 0
    arguement = line.split()
    try:
        if arguement[0][0] == '#':
            # Ignore comment
            return 0
        elif arguement[0] == '.RESET_ADDRESS':
            # Ignore .RESET_ADDRESS
            return 0
        elif validity_label(arguement[0].rstrip(':')):
            return 0
    except:
        return 0
    try:
        opcode = arguement[0]
    except:
        print("FATAL ERROR: Instruction at line no: ", line_number, " - opcode not defined.\n")
        error_counter[0] = error_counter[0] + 1
        return 2

    # opcode decoding
    if      opcode == 'LUI'     or opcode == 'lui':
        u_type_flag = 1
        opcode_bin = '0110111'
    elif    opcode == 'AUIPC'   or opcode == 'auipc':
        u_type_flag = 1
        opcode_bin = '0010111'
    elif    opcode == 'JAL'     or opcode == 'jal':
        j_type_flag = 1
        opcode_bin = '1101111'
    elif    opcode == 'JALR'    or opcode == 'jalr':
        i_type_flag = 1
        opcode_bin = '1100111'
    elif    opcode == 'BEQ'     or opcode == 'beq'      or opcode == 'BNE'   or opcode == 'bne'     or \
            opcode == 'BLT'     or opcode == 'blt'      or opcode == 'BGE'   or opcode == 'bge'     or \
            opcode == 'BLTU'    or opcode == 'bltu'     or opcode == 'BGEU'  or opcode == 'bgeu':
        b_type_flag = 1
        opcode_bin = '1100011'
    elif    opcode == 'LB'      or opcode == 'lb'       or opcode == 'LH'    or opcode == 'lh'      or \
            opcode == 'LW'      or opcode == 'lw'       or opcode == 'LBU'   or opcode == 'lbu'     or \
            opcode == 'LHU'     or opcode == 'lhu':
        i_type_flag = 1
        opcode_bin = '0000011'
    elif    opcode == 'SB'      or opcode == 'sb'       or opcode == 'SH'    or opcode == 'sh'      or \
            opcode == 'SW'      or opcode == 'sw':
        s_type_flag = 1
        opcode_bin = '0100011'
    elif    opcode == 'ADDI'    or opcode == 'addi'     or opcode == 'SLTI'  or opcode == 'slti'    or \
            opcode == 'SLTIU'   or opcode == 'sltiu'    or opcode == 'XORI'  or opcode == 'xori'    or \
            opcode == 'ORI'     or opcode == 'ori'      or opcode == 'ANDI'  or opcode == 'andi'    or \
            opcode == 'SLLI'    or opcode == 'slli'     or opcode == 'SRLI'  or opcode == 'srli'    or \
            opcode == 'SRAI'    or opcode == 'srai':
        i_type_flag = 1
        opcode_bin = '0010011'
    elif    opcode == 'ADD'     or opcode == 'add'      or opcode == 'SUB'   or opcode == 'sub'     or \
            opcode == 'SLL'     or opcode == 'sll'      or opcode == 'SLT'   or opcode == 'slt'     or \
            opcode == 'SLTU'    or opcode == 'sltu'     or opcode == 'XOR'   or opcode == 'xor'     or \
            opcode == 'SRL'     or opcode == 'srl'      or opcode == 'SRA'   or opcode == 'sra'     or \
            opcode == 'MUL'     or opcode == 'mul'      or opcode == 'MULH'  or opcode == 'mulh'    or \
            opcode == 'MULHSU'  or opcode == 'mulhsu'   or opcode == 'MULHU' or opcode == 'mulhu'   or \
            opcode == 'DIV'     or opcode == 'div'      or opcode == 'DIVU'  or opcode == 'divu'    or \
            opcode == 'REM'     or opcode == 'rem'      or opcode == 'REMU'  or opcode == 'remu'    or \
            opcode == 'SRL'     or opcode == 'srl'      or opcode == 'SRA'   or opcode == 'sra'     or \
            opcode == 'OR'      or opcode == 'or'       or opcode == 'AND'   or opcode == 'and':
        r_type_flag = 1
        opcode_bin = '0110011'
    elif    opcode == 'EBREAK'  or opcode == 'ebreak'   or opcode == 'ECALL' or opcode == 'ecall'   or \
            opcode == 'CSRRW'   or opcode == 'csrrw'    or opcode == 'CSRRS' or opcode == 'csrrs':
        opcode_bin = '1110011'  # SYSTEM opcode

    # Pseudo instructions decoding    
    elif opcode == 'MV' or opcode == 'mv':
        pseudo_instruction_mv_type_flag = 1
        opcode_bin = '0010011'   # Pseudo instruction - ADDI
    elif opcode == 'MVI' or opcode == 'mvi':
        pseudo_instruction_mvi_type_flag = 1
        opcode_bin = '0010011'  # Pseudo instruction - ADDI
    elif opcode == 'NOP' or opcode == 'nop':
        pseudo_instruction_nop_type_flag = 1
        opcode_bin = '0010011'   # Pseudo instruction - ADDI
    elif opcode == 'J' or opcode == 'j':
        pseudo_instruction_j_type_flag = 1
        opcode_bin = '1101111'   # Pseudo instruction -JAL
    elif opcode == 'NOT' or opcode == 'not':
        pseudo_instruction_not_type_flag = 1
        opcode_bin = '0010011'  # Pseudo instruction - XORI
    elif opcode == 'INV' or opcode == 'inv':
        pseudo_instruction_inv_type_flag = 1
        opcode_bin = '0010011'  # Pseudo instruction - XORI
    elif opcode == 'SEQZ' or opcode == 'seqz':
        pseudo_instruction_seqz_type_flag = 1
        opcode_bin = '0010011'  # Pseudo instruction - SLTIU
    elif opcode == 'SNEZ' or opcode == 'snez':
        pseudo_instruction_snez_type_flag = 1
        opcode_bin = '0110011'  # Pseudo instruction - SLTU
    elif opcode == 'BEQZ' or opcode == 'beqz':
        pseudo_instruction_beqz_type_flag = 1
        opcode_bin = '1100011'  # Pseudo instruction - BEQ
    elif opcode == 'BNEZ' or opcode == 'bnez':
        pseudo_instruction_bnez_type_flag = 1
        opcode_bin = '1100011'  # Pseudo instruction - BNE
    
    # 2-step pseudo instructions
    elif opcode == 'LI' or opcode == 'li':
        pseudo_instruction_li_type_flag = 1
        opcode_array.append('0110111')  # LUI
        opcode_array.append('0010011')  # ADDI
    elif opcode == 'LA' or opcode == 'la':
        pseudo_instruction_la_type_flag = 1
        opcode_array.append('0110111')  # LUI
        opcode_array.append('0010011')  # ADDI
    elif opcode == 'JR' or opcode == 'jr':
        pseudo_instruction_jr_type_flag = 1
        opcode_bin = '1100111'  # Pseudo instruction - JALR
    else:
        print("ERROR: Invalid/unsupported opcode at line no: ", line_number)
        instruction_error_flag = 1
        error_flag[0] = 1

    # R-type instructions
    if r_type_flag == 1:
        try:
            rd  = arguement[1]
            rs1 = arguement[2]
            rs2 = arguement[3]
            if validity_registers(rd) or validity_registers(rs1) or validity_registers(rs2):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 4 and arguement[4][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # I-type instructions
    if i_type_flag == 1:
        try:
            rd  = arguement[1]
            rs1 = arguement[2]
            immediate = arguement[3]
            if validity_registers(rd) or validity_registers(rs1):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 4 and arguement[4][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # S-type instructions
    if s_type_flag == 1:
        try:
            rs2 = arguement[1]
            rs1 = arguement[2]
            immediate = arguement[3]
            if validity_registers(rs2) or validity_registers(rs1):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 4 and arguement[4][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # B-type instructions
    if b_type_flag == 1:
        try:
            rs1 = arguement[1]
            rs2 = arguement[2]
            immediate = arguement[3]
            if validity_registers(rs1) or validity_registers(rs2):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 4 and arguement[4][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # U-type/J-type instructions
    if u_type_flag == 1 or j_type_flag == 1:
        try:
            rd = arguement[1]
            immediate = arguement[2]
            if validity_registers(rd):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 3 and arguement[3][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: MV
    if pseudo_instruction_mv_type_flag == 1:
        try:
            i_type_flag = 1  # Derived from i-type
            rd  = arguement[1]
            rs1 = arguement[2]
            immediate = 0
            if validity_registers(rd) or validity_registers(rs1):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 3 and arguement[3][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: MVI
    if pseudo_instruction_mvi_type_flag == 1:
        try:
            i_type_flag = 1  # Derived from i-type
            rd  = arguement[1]
            rs1 = 'x0'
            immediate = arguement[2]
            if validity_registers(rd):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 3 and arguement[3][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: NOP
    if pseudo_instruction_nop_type_flag == 1:
        i_type_flag = 1  # Derived from i-type
        rd  = 'x0'
        rs1 = 'x0'
        immediate = 0
        if len(arguement) > 1 and arguement[1][0] != '#':  # Integrity check; ignore if inline comment
            print("ERROR: Invalid no. of operands at line no: ", line_number)
            instruction_error_flag = 1
            error_flag[0] = 1

    # Pseudo instruction: J
    if pseudo_instruction_j_type_flag == 1:
        try:
            j_type_flag = 1  # Derived from j-type
            rd = 'x0'
            immediate = arguement[1]
            if len(arguement) > 2 and arguement[2][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: NOT
    if pseudo_instruction_not_type_flag == 1:
        try:
            i_type_flag = 1  # Derived from i-type
            rd  = arguement[1]
            rs1 = arguement[2]
            immediate = -1
            if validity_registers(rd) or validity_registers(rs1):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 3 and arguement[3][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: INV
    if pseudo_instruction_inv_type_flag == 1:
        try:
            i_type_flag = 1  # Derived from i-type
            rd  = arguement[1]
            rs1 = arguement[1]
            immediate = -1
            if validity_registers(rd):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 2 and arguement[2][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: SEQZ
    if pseudo_instruction_seqz_type_flag == 1:
        try:
            i_type_flag = 1  # Derived from i-type
            rd  = arguement[1]
            rs1 = arguement[2]
            immediate = 1
            if validity_registers(rd) or validity_registers(rs1):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 3 and arguement[3][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: SNEZ
    if pseudo_instruction_snez_type_flag == 1:
        try:
            r_type_flag = 1  # Derived from r-type
            rd  = arguement[1]
            rs1 = 'x0'
            rs2 = arguement[2]
            if validity_registers(rd) or validity_registers(rs2):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 3 and arguement[3][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: BEQZ
    if pseudo_instruction_beqz_type_flag == 1:
        try:
            b_type_flag = 1  # Derived from b-type
            rs1 = arguement[1]
            rs2 = 'x0'
            immediate = arguement[2]
            if validity_registers(rs1):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 3 and arguement[3][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: BNEZ
    if pseudo_instruction_bnez_type_flag == 1:
        try:
            b_type_flag = 1  # Derived from b-type
            rs1 = arguement[1]
            rs2 = 'x0'
            immediate = arguement[2]
            if validity_registers(rs1):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 3 and arguement[3][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: LI/LA
    if pseudo_instruction_li_type_flag or pseudo_instruction_la_type_flag:
        try:
            rs1 = arguement[1]  # For ADDI
            rd  = arguement[1]  # For LUI, ADDI
            immediate = arguement[2]
            if validity_registers(rd):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 3 and arguement[3][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    # Pseudo instruction: JR
    if pseudo_instruction_jr_type_flag:
        try:
            i_type_flag = 1  # Derived from i-type
            rd  = 'x0'
            rs1 = arguement[1]
            immediate = 0
            if validity_registers(rs1):
                print("ERROR: Invalid/unsupported register at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
            elif len(arguement) > 2 and arguement[2][0] != '#':  # Integrity check; ignore if inline comment
                print("ERROR: Invalid no. of operands at line no: ", line_number)
                instruction_error_flag = 1
                error_flag[0] = 1
        except:
            print("FATAL ERROR: Instruction at line no: ", line_number, " is missing one or more operands!\n")
            error_counter[0] = error_counter[0] + 1
            return 2

    rs1_bin = register_index_mapping(rs1)
    rs2_bin = register_index_mapping(rs2)
    rd_bin  = register_index_mapping(rd)

    # Decode immediate/offset
    error_status = [0]
    if r_type_flag == 0:
        immediate_bin = immediate_generator(immediate, line_number, error_status, (j_type_flag or b_type_flag), 
                                            pseudo_instruction_la_type_flag)
    if error_status[0] == 1:
        instruction_error_flag = 1
        error_flag[0] = 1

    # Decoding 'funct3' and 'funct7' fields of instruction
    if instruction_error_flag == 0 and (opcode == 'EBREAK' or opcode == 'ebreak'):
        funct3 = '000'
        funct7 = '0000000'
        bin_instruction.append('00000000000100000000000001110011')
    elif instruction_error_flag == 0 and (opcode == 'ECALL' or opcode == 'ecall'):
        funct3 = '000'
        funct7 = '0000000'
        bin_instruction.append('00000000000000000000000001110011')
    elif instruction_error_flag == 0 and (opcode == 'ADD' or opcode == 'add'):
        funct3 = '000'
        funct7 = '0000000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SUB' or opcode == 'sub'):
        funct3 = '000'
        funct7 = '0100000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SLL' or opcode == 'sll'):
        funct3 = '001'
        funct7 = '0000000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SLT' or opcode == 'slt'):
        funct3 = '010'
        funct7 = '0000000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SLTU' or opcode == 'sltu'):
        funct3 = '011'
        funct7 = '0000000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'XOR' or opcode == 'xor'):
        funct3 = '100'
        funct7 = '0000000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SRL' or opcode == 'srl'):
        funct3 = '101'
        funct7 = '0000000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SRA' or opcode == 'sra'):
        funct3 = '101'
        funct7 = '0100000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'OR' or opcode == 'or'):
        funct3 = '110'
        funct7 = '0000000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'AND' or opcode == 'and'):
        funct3 = '111'
        funct7 = '0000000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'MUL' or opcode == 'mul'):
        funct3 = '000'
        funct7 = '0000001'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'MULH' or opcode == 'mulh'):
        funct3 = '001'
        funct7 = '0000001'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'MULHSU' or opcode == 'mulhsu'):
        funct3 = '010'
        funct7 = '0000001'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'MULHU' or opcode == 'mulhu'):
        funct3 = '011'
        funct7 = '0000001'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'DIV' or opcode == 'div'):
        funct3 = '100'
        funct7 = '0000001'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'DIVU' or opcode == 'divu'):
        funct3 = '101'
        funct7 = '0000001'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'REM' or opcode == 'rem'):
        funct3 = '110'
        funct7 = '0000001'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'REMU' or opcode == 'remu'):
        funct3 = '111'
        funct7 = '0000001'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'JALR' or opcode == 'jalr'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '000'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'LB' or opcode == 'lb'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '000'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'LH' or opcode == 'lh'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '001'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'LW' or opcode == 'lw'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '010'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'LBU' or opcode == 'lbu'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '100'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'LHU' or opcode == 'lhu'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '101'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'ADDI' or opcode == 'addi'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '000'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SLTI' or opcode == 'slti'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '010'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SLTIU' or opcode == 'sltiu'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '011'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'XORI' or opcode == 'xori'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '100'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'ORI' or opcode == 'ori'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '110'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'ANDI' or opcode == 'andi'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '111'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SLLI' or opcode == 'slli'):
        shamnt = immediate_bin[27:32]  # immediate[4:0]
        funct3 = '001'
        funct7 = '0000000'
        bin_instruction.append(funct7 + shamnt + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SRLI' or opcode == 'srli'):
        shamnt = immediate_bin[27:32]  # immediate[4:0]
        funct3 = '101'
        funct7 = '0000000'
        bin_instruction.append(funct7 + shamnt + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SRAI' or opcode == 'srai'):
        shamnt = immediate_bin[27:32]  # immediate[4:0]
        funct3 = '101'
        funct7 = '0100000'
        bin_instruction.append(funct7 + shamnt + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SB' or opcode == 'sb'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '000'
        bin_instruction.append(immediate_bin_11_0[0:7] + rs2_bin + rs1_bin + funct3 + immediate_bin_11_0[7:12] + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SH' or opcode == 'sh'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '001'
        bin_instruction.append(immediate_bin_11_0[0:7] + rs2_bin + rs1_bin + funct3 + immediate_bin_11_0[7:12] + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'SW' or opcode == 'sw'):
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '010'
        bin_instruction.append(immediate_bin_11_0[0:7] + rs2_bin + rs1_bin + funct3 + immediate_bin_11_0[7:12] + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'BEQ' or opcode == 'beq'):
        immediate_bin_12_1 = immediate_bin[19:31]  # immediate[12:1]
        funct3 = '000'
        bin_instruction.append(immediate_bin_12_1[0] + immediate_bin_12_1[2:8] + rs2_bin + rs1_bin + funct3 + immediate_bin_12_1[8:12] +
                         immediate_bin_12_1[1] + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'BNE' or opcode == 'bne'):
        immediate_bin_12_1 = immediate_bin[19:31]  # immediate[12:1]
        funct3 = '001'
        bin_instruction.append(immediate_bin_12_1[0] + immediate_bin_12_1[2:8] + rs2_bin + rs1_bin + funct3 + immediate_bin_12_1[8:12] +
                         immediate_bin_12_1[1] + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'BLT' or opcode == 'blt'):
        immediate_bin_12_1 = immediate_bin[19:31]  # immediate[12:1]
        funct3 = '100'
        bin_instruction.append(immediate_bin_12_1[0] + immediate_bin_12_1[2:8] + rs2_bin + rs1_bin + funct3 + immediate_bin_12_1[8:12] +
                         immediate_bin_12_1[1] + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'BGE' or opcode == 'bge'):
        immediate_bin_12_1 = immediate_bin[19:31]  # immediate[12:1]
        funct3 = '101'
        bin_instruction.append(immediate_bin_12_1[0] + immediate_bin_12_1[2:8] + rs2_bin + rs1_bin + funct3 + immediate_bin_12_1[8:12] +
                         immediate_bin_12_1[1] + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'BLTU' or opcode == 'bltu'):
        immediate_bin_12_1 = immediate_bin[19:31]  # immediate[12:1]
        funct3 = '110'
        bin_instruction.append(immediate_bin_12_1[0] + immediate_bin_12_1[2:8] + rs2_bin + rs1_bin + funct3 + immediate_bin_12_1[8:12] +
                         immediate_bin_12_1[1] + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'BGEU' or opcode == 'bgeu'):
        immediate_bin_12_1 = immediate_bin[19:31]  # immediate[12:1]
        funct3 = '111'
        bin_instruction.append(immediate_bin_12_1[0] + immediate_bin_12_1[2:8] + rs2_bin + rs1_bin + funct3 + immediate_bin_12_1[8:12] +
                         immediate_bin_12_1[1] + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'LUI' or opcode == 'lui'):
        immediate_bin_31_12 = immediate_bin[12:32]  # Observed to be immediate[19:0] in all implementations, not immediate[31:12]
        bin_instruction.append(immediate_bin_31_12 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'AUIPC' or opcode == 'auipc'):
        immediate_bin_31_12 = immediate_bin[12:32]  # Observed to be immediate[19:0] in all implementations, not immediate[31:12]
        bin_instruction.append(immediate_bin_31_12 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'JAL' or opcode == 'jal'):
        immediate_bin_20_1 = immediate_bin[11:31]  # immediate[20:1]
        bin_instruction.append(immediate_bin_20_1[0] + immediate_bin_20_1[10:20] + immediate_bin_20_1[9] + immediate_bin_20_1[1:9] +
                         rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (pseudo_instruction_mv_type_flag or pseudo_instruction_mvi_type_flag or pseudo_instruction_nop_type_flag):  # = ADDI
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '000'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and pseudo_instruction_j_type_flag:  # = JAL
        immediate_bin_20_1 = immediate_bin[11:31]  # immediate[20:1]
        bin_instruction.append(immediate_bin_20_1[0] + immediate_bin_20_1[10:20] + immediate_bin_20_1[9] + immediate_bin_20_1[1:9] +
                         rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (pseudo_instruction_not_type_flag or pseudo_instruction_inv_type_flag):  # = XORI
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '100'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and pseudo_instruction_seqz_type_flag:  # = SLTIU
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '011'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and pseudo_instruction_snez_type_flag:  # = SLTU
        funct3 = '011'
        funct7 = '0000000'
        bin_instruction.append(funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and pseudo_instruction_beqz_type_flag:  # = BEQ
        immediate_bin_12_1 = immediate_bin[19:31]  # immediate[12:1]
        funct3 = '000'
        bin_instruction.append(immediate_bin_12_1[0] + immediate_bin_12_1[2:8] + rs2_bin + rs1_bin + funct3 + immediate_bin_12_1[8:12] +
                         immediate_bin_12_1[1] + opcode_bin)
    elif instruction_error_flag == 0 and pseudo_instruction_bnez_type_flag:  # = BNE
        immediate_bin_12_1 = immediate_bin[19:31]  # immediate[12:1]
        funct3 = '001'
        bin_instruction.append(immediate_bin_12_1[0] + immediate_bin_12_1[2:8] + rs2_bin + rs1_bin + funct3 + immediate_bin_12_1[8:12] +
                         immediate_bin_12_1[1] + opcode_bin)
    elif instruction_error_flag == 0 and (pseudo_instruction_li_type_flag or pseudo_instruction_la_type_flag):  # = LUI + ADDI
        # LUI
        if immediate_bin[20] == '0':
            immediate_bin_31_12 = immediate_bin[0:20]  # immediate[31:12]
        else:
            temp = int(immediate_bin[0:20], base=2) + 1
            immediate_bin_lui = int_to_binary(temp)
            immediate_bin_31_12 = immediate_bin_lui[12:32]  # immediate[31:12] + 1
        bin_instruction.append(immediate_bin_31_12 + rd_bin + opcode_array[0])  # Write LUI instruction
        # ADDI
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '000'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_array[1])  # Write ADDI instruction
    elif instruction_error_flag == 0 and (pseudo_instruction_jr_type_flag):  # = JALR
        immediate_bin_11_0 = immediate_bin[20:32]  # immediate[11:0]
        funct3 = '000'
        bin_instruction.append(immediate_bin_11_0 + rs1_bin + funct3 + rd_bin + opcode_bin)
    elif instruction_error_flag == 0 and (opcode == 'CSRRW' or opcode == 'csrrw'):
        # Remove the '0x' prefix if it exists
        if immediate.startswith("0x"):
            immediate = immediate[2:]
        decimal_immediate = int(immediate, 16)
        binary_immediate  = bin(decimal_immediate)[2:]
        # Zero-extend to the specified bit size
        csr_address = binary_immediate.zfill(12)
        csr_address = csr_address[-12:]  # Ensure it's no longer than the bit size    
        bin_instruction.append(csr_address + rs1_bin + "001" + rd_bin + "1110011")
    elif instruction_error_flag == 0 and (opcode == 'CSRRS' or opcode == 'csrrs'):
        # Remove the '0x' prefix if it exists
        if immediate.startswith("0x"):
            immediate = immediate[2:]
        decimal_immediate = int(immediate, 16)
        binary_immediate  = bin(decimal_immediate)[2:]
        # Zero-extend to the specified bit size
        csr_address = binary_immediate.zfill(12)
        csr_address = csr_address[-12:]  # Ensure it's no longer than the bit size
        bin_instruction.append(csr_address + rs1_bin + "010" + rd_bin + "1110011")
    elif instruction_error_flag == 0 and (opcode == 'CSRRC' or opcode == 'csrrc'):
        # Remove the '0x' prefix if it exists
        if immediate.startswith("0x"):
            immediate = immediate[2:]
        decimal_immediate = int(immediate, 16)
        binary_immediate  = bin(decimal_immediate)[2:]
        # Zero-extend to the specified bit size
        csr_address = binary_immediate.zfill(12)
        csr_address = csr_address[-12:]  # Ensure it's no longer than the bit size
        bin_instruction.append(csr_address + rs1_bin + "011" + rd_bin + "1110011")
    else:
        funct3 = 'XXX'

    # Update pc
    if pseudo_instruction_li_type_flag or pseudo_instruction_la_type_flag:
        pc[0] = pc[0] + 8  # LI expands to two instructions
    else:
        pc[0] = pc[0] + 4

    # Check for any errors logged in the instruction
    if instruction_error_flag == 0:
        print("INFO: Processing line", line_number, "- PASSED")
        return 0
    else:
        error_counter[0] = error_counter[0] + 1
        print("ERROR: Processing line", line_number, "- FAILED\n")
        return 1