Fetch_Unit
==========
|  Signal |   Width  | Direction |                 Description                |
|:-------:|:--------:|:---------:|:------------------------------------------:|
|  enable |     1    |   input   |    Enable signal to control fetch action   |
|    PC   | [31 : 0] |   input   |        Instruction's Program Counter       |
| address | [31 : 0] |   input   | PC target address caused by jump or branch |
| next_PC | [31 : 0] |   output  |        Value to latch on PC register       |