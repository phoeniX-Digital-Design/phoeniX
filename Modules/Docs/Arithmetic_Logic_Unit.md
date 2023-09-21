Arithmetic_Logic_Unit
=====================
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