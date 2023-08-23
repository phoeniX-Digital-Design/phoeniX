`define R_TYPE 0
`define I_TYPE 1
`define S_TYPE 2
`define B_TYPE 3
`define U_TYPE 4
`define J_TYPE 5


module Instruction_Decoder 
(
    input [31 : 0] instruction,

    output [2 : 0] instruction_type,

    output [6 : 0] opcode,
    output [2 : 0] funct3,
    output [6 : 0] funct7,
    // output funct3_valid,
    // output funct7_valid,

    output [4 : 0] read_index_1,
    output [4 : 0] read_index_2,
    output [4 : 0] write_index,

    output reg read_enable_1,
    output reg read_enable_2,
    output reg write_enable
);

    assign opcode = instruction [6 : 0];

    assign instruction_type_i = instruction[6 : 2] == 5'b00000 ||
                                instruction[6 : 2] == 5'b00001 ||
                                instruction[6 : 2] == 5'b00100 ||
                                instruction[6 : 2] == 5'b00110 ||
                                instruction[6 : 2] == 5'b11001;
        
    assign instruction_type_b = instruction[6 : 2] == 5'b11000;

    assign instruction_type_r = instruction[6 : 2] == 5'b01100 ||
                                instruction[6 : 2] == 5'b10100;

    assign instruction_type_s = instruction[6 : 2] == 5'b01000 ||
                                instruction[6 : 2] == 5'b01001;

    assign instruction_type_u = instruction[6 : 2] == 5'b00101 ||
                                instruction[6 : 2] == 5'b01101;

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
    // assign funct7_valid = instruction_type_r;
    // assign funct3_valid = instruction_type_r || instruction_type_i || instruction_type_b || instruction_type_s;

    assign read_index_1 = instruction[19 : 15];
    assign read_index_2 = instruction[24 : 20];
    assign write_index  = instruction[11 :  7];

    always @(*) 
    begin
        // Register File read/write enable signals evaluation
        case (instruction_type)
            `I_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b0; write_enable = 1'b1; end
            `B_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b0; end
            `S_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b0; end
            `U_TYPE : begin read_enable_1 = 1'b0; read_enable_2 = 1'b0; write_enable = 1'b1; end
            `J_TYPE : begin read_enable_1 = 1'b0; read_enable_2 = 1'b0; write_enable = 1'b1; end 
            `R_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b1; end
            default : begin end // Raise Exception
        endcase    

        // Disable Write Signal when destination is x0
        if (write_index == 5'b00000)
            write_enable <= 1'b0;
    end
endmodule