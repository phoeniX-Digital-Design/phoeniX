`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif

`ifndef INSTRUCTION_TYPES
    `define R_TYPE 0
    `define I_TYPE 1
    `define S_TYPE 2
    `define B_TYPE 3
    `define U_TYPE 4
    `define J_TYPE 5
`endif

module Instruction_Decoder 
(
    input [31 : 0] instruction,

    output [2 : 0] instruction_type,

    output [6 : 0] opcode,
    output [2 : 0] funct3,
    output [6 : 0] funct7,

    output [4 : 0] read_index_1,
    output [4 : 0] read_index_2,
    output [4 : 0] write_index,

    output reg read_enable_1,
    output reg read_enable_2,
    output reg write_enable
);

    assign opcode = instruction [6 : 0];

    assign instruction_type_i = opcode == `LOAD         ||
                                opcode == `LOAD_FP      ||
                                opcode == `OP_IMM       ||
                                opcode == `OP_IMM_32    ||
                                opcode == `JALR;
        
    assign instruction_type_b = opcode == `BRANCH;

    assign instruction_type_r = opcode == `OP ||
                                opcode == `OP_FP;

    assign instruction_type_s = opcode == `STORE ||
                                opcode == `STORE_FP;

    assign instruction_type_u = opcode == `AUIPC ||
                                opcode == `LUI;

    assign instruction_type_j = opcode == `JAL;

    assign instruction_type =   (instruction_type_r) ? `R_TYPE :
                                (instruction_type_i) ? `I_TYPE : 
                                (instruction_type_s) ? `S_TYPE :
                                (instruction_type_b) ? `B_TYPE :
                                (instruction_type_u) ? `U_TYPE : 
                                (instruction_type_j) ? `J_TYPE :
                                1'bz; // Default value

    assign funct7 = instruction[31 : 25];
    assign funct3 = instruction[14 : 12];
    
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