Address Genrator
============

|   Signal  |   Width  | Direction |           Description          |
|:---------:|:--------:|:---------:|:------------------------------:|
|   opcode  |  [6 : 0] |   input   |   Opcode field of instruction  |
|    rs1    | [31 : 0] |   input   |        Source register 1       |
|     PC    | [31 : 0] |   input   |  Instruction's Program Counter |
| immediate | [31 : 0] |   input   | Immediate field of instruction |
|  address  | [31 : 0] |   output  |  Target Address of instruction |