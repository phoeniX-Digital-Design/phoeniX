`define I_TYPE 0
`define B_TYPE 1
`define S_TYPE 2
`define U_TYPE 3
`define J_TYPE 4
`define R_TYPE 5

module Instruction_Decoder 
(
    input [31 : 0] instruction,

    output branch_signal,
    output [2 : 0] instruction_type,

    output [6 : 0] opcode,
    output [2 : 0] funct3,
    output [6 : 0] funct7,
    output funct3_valid,
    output funct7_valid,

    output [4 : 0] read_index_1,
    output [4 : 0] read_index_2,
    output [4 : 0] write_index
);

    assign opcode = instruction [6 : 0];

    assign instruction_type_i = instruction[6 : 2] == 5'b0000x ||
                                instruction[6 : 2] == 5'b001x0 ||
                                instruction[6 : 2] == 5'b11001;
        
    assign instruction_type_b = instruction[6 : 2] == 5'b11000;

    assign instruction_type_r = instruction[6 : 2] == 5'b01100 ||
                                instruction[6 : 2] == 5'b10100;

    assign instruction_type_s = instruction[6 : 2] == 5'b1000x;

    assign instruction_type_u = instruction[6 : 2] == 5'b0x101;

    assign instruction_type_j = instruction[6 : 2] == 5'b11011;

    assign instruction_type =   (instruction_type_i) ? `I_TYPE : 
                                (instruction_type_b) ? `B_TYPE :
                                (instruction_type_s) ? `S_TYPE :
                                (instruction_type_u) ? `U_TYPE : 
                                (instruction_type_j) ? `J_TYPE :
                                (instruction_type_r) ? `R_TYPE :
                                1'bz; // Default value

    assign branch_signal = instruction_type_b;

    assign funct7 = instruction[31 : 25];
    assign funct3 = instruction[14 : 12];
    assign funct7_valid = instruction_type_r;
    assign funct3_valid = instruction_type_r || instruction_type_i || instruction_type_b || instruction_type_s;

    assign read_index_1 = instruction[19 : 15];
    assign read_index_2 = instruction[24 : 20];
    assign write_index  = instruction[11 :  7];

endmodule