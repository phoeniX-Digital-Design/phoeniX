#  AssembleX V3.0
#  RISC-V Assembly Software Assistant for the phoeniX project (https://github.com/phoeniX-Digital-Design/phoeniX)

#  Description: Registers + Index mapping
#  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.

registers_rv32i = [ 'x0',   'x1',   'x2',   'x3',   'x4',   'x5',   'x6',   'x7',   
                    'x8',   'x9',   'x10',  'x11',  'x12',  'x13',  'x14',  'x15',  
                    'x16',  'x17',  'x18',  'x19',  'x20',  'x21',  'x22',  'x23',  
                    'x24',  'x25',  'x26',  'x27',  'x28',  'x29',  'x30',  'x31',
                    'X0',   'X1',   'X2',   'X3',   'X4',   'X5',   'X6',   'X7',
                    'X8',   'X9',   'X10',  'X11',  'X12',  'X13',  'X14',  'X15',
                    'X16',  'X17',  'X18',  'X19',  'X20',  'X21',  'X22',  'X23',  
                    'X24',  'X25',  'X26',  'X27',  'X28',  'X29',  'X30',  'X31',
                    'zero', 'ZERO', 'ra',   'RA',   'sp',   'SP',   'gp',   'GP',   'tp',   'TP',
                    't0',   'T0',   't1',   'T1',   't2',   'T2',   's0',   'S0',
                    's1',   'S1',   'a0',   'A0',   'a1',   'A1',   'a2',   'A2',
                    'a3',   'A3',   'a4',   'A4',   'a5',   'A5',   'a6',   'A6',
                    'a7',   'A7',   's2',   'S2',   's3',   'S3',   's4',   'S4',
                    's5',   'S5',   's6',   'S6',   's7',   'S7',   's8',   'S8',
                    's9',   'S9',   's10',  'S10',  's11',  'S11',  't3',   'T3',
                    't4',   'T4',   't5',   'T5',   't6',   'T6'  ]

def register_index_mapping(register):
    if register == 'x0' or register == 'X0' or register == 'zero' or register == 'ZERO':
        return '00000'
    elif register == 'x1' or register == 'X1' or register == 'ra' or register == 'RA':
        return '00001'
    elif register == 'x2' or register == 'X2' or register == 'sp' or register == 'SP':
        return '00010'
    elif register == 'x3' or register == 'X3' or register == 'gp' or register == 'GP':
        return '00011'
    elif register == 'x4' or register == 'X4' or register == 'tp' or register == 'TP':
        return '00100'
    elif register == 'x5' or register == 'X5' or register == 't0' or register == 'T0':
        return '00101'
    elif register == 'x6' or register == 'X6' or register == 't1' or register == 'T1':
        return '00110'
    elif register == 'x7' or register == 'X7' or register == 't2' or register == 'T2':
        return '00111'
    elif register == 'x8' or register == 'X8' or register == 'fp' or register == 'FP' or register == 's0' or register == 'S0':
        return '01000'
    elif register == 'x9' or register == 'X9' or register == 's1' or register == 'S1':
        return '01001'
    elif register == 'x10' or register == 'X10' or register == 'a0' or register == 'A0':
        return '01010'
    elif register == 'x11' or register == 'X11' or register == 'a1' or register == 'A1':
        return '01011'
    elif register == 'x12' or register == 'X12' or register == 'a2' or register == 'A2':
        return '01100'
    elif register == 'x13' or register == 'X13' or register == 'a3' or register == 'A3':
        return '01101'
    elif register == 'x14' or register == 'X14' or register == 'a4' or register == 'A4':
        return '01110'
    elif register == 'x15' or register == 'X15' or register == 'a5' or register == 'A5':
        return '01111'
    elif register == 'x16' or register == 'X16' or register == 'a6' or register == 'A6':
        return '10000'
    elif register == 'x17' or register == 'X17' or register == 'a7' or register == 'A7':
        return '10001'
    elif register == 'x18' or register == 'X18' or register == 's2' or register == 'S2':
        return '10010'
    elif register == 'x19' or register == 'X19' or register == 's3' or register == 'S3':
        return '10011'
    elif register == 'x20' or register == 'X20' or register == 's4' or register == 'S4':
        return '10100'
    elif register == 'x21' or register == 'X21' or register == 's5' or register == 'S5':
        return '10101'
    elif register == 'x22' or register == 'X22' or register == 's6' or register == 'S6':
        return '10110'
    elif register == 'x23' or register == 'X23' or register == 's7' or register == 'S7':
        return '10111'
    elif register == 'x24' or register == 'X24' or register == 's8' or register == 'S8':
        return '11000'
    elif register == 'x25' or register == 'X25' or register == 's9' or register == 'S9':
        return '11001'
    elif register == 'x26' or register == 'X26' or register == 's10' or register == 'S10':
        return '11010'
    elif register == 'x27' or register == 'X27' or register == 's11' or register == 'S11':
        return '11011'
    elif register == 'x28' or register == 'X28' or register == 't3' or register == 'T3':
        return '11100'
    elif register == 'x29' or register == 'X29' or register == 't4' or register == 'T4':
        return '11101'
    elif register == 'x30' or register == 'X30' or register == 't5' or register == 'T5':
        return '11110'
    else:
        return '11111'