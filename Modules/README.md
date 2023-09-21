# Address Genrator

|   Signal  |   Width  | Direction |           Description          |
|:---------:|:--------:|:---------:|:------------------------------:|
|   opcode  |  [6 : 0] |   input   |   Opcode field of instruction  |
|    rs1    | [31 : 0] |   input   |        Source register 1       |
|     PC    | [31 : 0] |   input   |  Instruction's Program Counter |
| immediate | [31 : 0] |   input   | Immediate field of instruction |
|  address  | [31 : 0] |   output  |  Target Address of instruction |

# Arithmetic_Logic_Unit

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

# Fetch_Unit

|  Signal |   Width  | Direction |                 Description                |
|:-------:|:--------:|:---------:|:------------------------------------------:|
|  enable |     1    |   input   |    Enable signal to control fetch action   |
|    PC   | [31 : 0] |   input   |        Instruction's Program Counter       |
| address | [31 : 0] |   input   | PC target address caused by jump or branch |
| next_PC | [31 : 0] |   output  |        Value to latch on PC register       |

# Hazard_Forward_Unit

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
