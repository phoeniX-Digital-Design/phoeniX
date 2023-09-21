phoeniX Processor Modules
==========================

## Address Genrator
Responsible for generating target address of BRANCH, JUMP and LOAD/STORE instructions
|   Signal  |   Width  | Direction |           Description          |
|:---------:|:--------:|:---------:|:------------------------------:|
|   opcode  |  [6 : 0] |   input   |   Opcode field of instruction  |
|    rs1    | [31 : 0] |   input   |        Source register 1       |
|     PC    | [31 : 0] |   input   |  Instruction's Program Counter |
| immediate | [31 : 0] |   input   | Immediate field of instruction |
|  address  | [31 : 0] |   output  |  Target Address of instruction |

## Arithmetic_Logic_Unit
Arithemtic logic unit with support for `I_TYPE` and `R_TYPE` instructions plus `U_TYPE` and return address calculations for `J-TYPE`
|   Signal   |   Width  | Direction |                  Description                  |
|:----------:|:--------:|:---------:|:---------------------------------------------:|
|   opcode   |  [6 : 0] |   input   |          Opcode field of instruction          |
|   funct3   |  [2 : 0] |   input   |      Instruction family's first function      |
|   funct7   |  [6 : 0] |   input   |      Instruction family's second function     |
|     PC     | [31 : 0] |   input   |         Instruction's Program Counter         |
|     rs1    | [31 : 0] |   input   |               Source register 1               |
|     rs2    | [31 : 0] |   input   |               Source register 2               |
|  immediate | [31 : 0] |   input   |         Immediate field of instruction        |
| alu_output | [31 : 0] |   output  | Result of alu operations on selected operands |

## Fetch_Unit
Logic required for fetching instructions from memory and setting value of the program counter
|  Signal |   Width  | Direction |                 Description                |
|:-------:|:--------:|:---------:|:------------------------------------------:|
|  enable |     1    |   input   |    Enable signal to control fetch action   |
|    PC   | [31 : 0] |   input   |        Instruction's Program Counter       |
| address | [31 : 0] |   input   | PC target address caused by jump or branch |
| next_PC | [31 : 0] |   output  |        Value to latch on PC register       |

## Hazard_Forward_Unit
Module responsible for detecting true data dependency detection and forwarding logic to reduce stalls 
|        Signal       |   Width  | Direction |                    Description                    |
|:-------------------:|:--------:|:---------:|:-------------------------------------------------:|
|     source_index    |  [4 : 0] |   input   |     Index of data source requiring forwarding     |
| destination_index_1 |  [4 : 0] |   input   |   Index of the first data option for forwarding   |
| destination_index_2 |  [4 : 0] |   input   |   Index of the second data option for forwarding  |
| destination_index_3 |  [4 : 0] |   input   |   Index of the third data option for forwarding   |
|        data_1       | [31 : 0] |   input   |   Value of the first data option for forwarding   |
|        data_2       | [31 : 0] |   input   |   Value of the second data option for forwarding  |
|        data_3       | [31 : 0] |   input   |   Value of the third data option for forwarding   |
|       enable_1      |     1    |   input   |  Validity of the first data option for forwarding |
|       enable_2      |     1    |   input   | Validity of the second data option for forwarding |
|       enable_3      |     1    |   input   |  Validity of the third data option for forwarding |
|    forward_enable   |     1    |   output  |  Enable signal for controlling forwarding action  |
|     forward_data    | [31 : 0] |   output  |         Data to be forwarded to the source        |

## Immediate Generator
Parser of a fetched instruction for generating immediate values according to the instruction's type 
|      Signal      |  Width   | Direction |                          Description                          |
|:----------------:|:--------:|:---------:|:-------------------------------------------------------------:|
|    instruction   | [31 : 0] |   input   |       Instruction to be parsed for immediate generation       |
| instruction_type |  [2 : 0] |   input   | Type of the instruction used for different immediate variants |
|     immediate    | [31 : 0] |   output  |         Immediate value generated from the instruction        |

## Instruction Decoder
Responsible for decomposing an instruction to separate fields
|      Signal      |  Width   | Direction |                                 Description                                 |
|:----------------:|:--------:|:---------:|:---------------------------------------------------------------------------:|
|    instruction   | [31 : 0] |   input   |           Instruction to be parsed for generating different fields          |
| instruction_type |  [2 : 0] |   output  |                       Type of the instruction inferred                      |
|      opcode      |  [6 : 0] |   output  |                          Opcode of the instruction                          |
|      funct3      |  [2 : 0] |   output  |   Field of funct3 indicating primary function of the instruction's family   |
|      funct7      |  [6 : 0] |   output  |  Field of funct7 indicating secondary function of the instruction's family  |
|      funct12     | [11 : 0] |   output  |   Field of funct12 indicating tertiary function of special   instructions   |
|   read_index_1   |  [4 : 0] |   output  |                     Address of the first source register                    |
|   read_index_2   |  [4 : 0] |   output  |                    Address of the second source register                    |
|    write_index   |  [4 : 0] |   output  |                     Address of the destination register                     |
|   read_enable_1  |     1    |   output  |       Correctness of reading first source register from register file       |
|   read_enable_2  |     1    |   output  |       Correctness of reading second source register from register file      |
|   write_enable   |     1    |   output  |         Correctness of writing destination register to register file        |

## Jump Branch Unit
Condition checker and decision maker for individual branch types and jump instruction 
|       Signal       |  Width   | Direction |                    Description                   |
|:------------------:|:--------:|:---------:|:------------------------------------------------:|
|       opcode       |  [6 : 0] |   input   |             Opcode of the instruction            |
|       funct3       |  [2 : 0] |   input   |      Instruction family's primary function       |
|  instruction_type  |  [2 : 0] |   input   |      Type of the instruction begin processed     |
|         rs1        | [31 : 0] |   input   |                 Source register 1                |
|         rs2        | [31 : 0] |   input   |                 Source register 2                |
| jump_branch_enable |     1    |   output  | Indicator whether jump or branch should be taken |

## Load Store Unit
Module responsible for Load and Store operations for aligned addresses and wordsize management 
|            Signal           |  Width   | Direction |                                      Description                                     |
|:---------------------------:|:--------:|:---------:|:------------------------------------------------------------------------------------:|
|            opcode           |  [6 : 0] |   input   |                               Opcode of the instruction                              |
|            funct3           |  [2 : 0] |   input   |                        Instruction family's primary function                         |
|           address           | [31 : 0] |   input   |                       Target address for Load/Store operations                       |
|          store_data         | [31 : 0] |   input   |               Value to be written in memory in case of Store operations              |
|          load_data          | [31 : 0] |   output  |                               Value loaded from memory                               |
|   memory_interface_enable   |     1    |   output  |       Signal to enable memory interface for processor and memory   interactions      |
|    memory_interface_state   |     1    |   output  |        Signal to set the direction of the processor and memory   interactions        |
|   memory_interface_address  | [31 : 0] |   output  |                    Address sent to the memory during interactionns                   |
| memory_interface_frame_mask |  [3 : 0] |   output  | Frame mask for selection of relevant bytes of the memory frame   as seen by the core |
|    memory_interface_data    | [31 : 0] |   inout   |         Data bits transferring during the processor and memory   interactions        |

## Register File
A parametrized register file suitable for general purpose and control-status registers benefiting from 2 read ports and 1 write port
|     Signal    |  Width   | Direction |                        Description                        |
|:-------------:|:--------:|:---------:|:---------------------------------------------------------:|
|      CLK      |     1    |   input   | Clock signal for synchronization of register's flip-flops |
|     reset     |     1    |   input   |      Reset signal to set all regsiter values to zero      |
| read_enable_1 |     1    |   input   |       Enable signal for first read port of the file       |
| read_enable_2 |     1    |   input   |       Enable signal for second read port of the file      |
|  write_enable |     1    |   input   |        Enable signal for the write port of the file       |
|  read_index_1 |  [4 : 0] |   input   |        Index passed to first read port of the file        |
|  read_index_2 |  [4 : 0] |   input   |        Index passed to second read port of the file       |
|  write_index  |  [4 : 0] |   input   |         Index passed to the write port of the file        |
|   write_data  | [31 : 0] |   input   |     Data value to be written on a register in the file    |
|  read_data_1  | [31 : 0] |   output  |      Data value read from the first port of the file      |
|  read_data_2  | [31 : 0] |   output  |      Data value read from the second port of the file     |