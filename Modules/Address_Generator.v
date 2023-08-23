/*
    Address Generator:
    There are 3 types of addresses generated in this module:
    1. Branch Address
    2. Jump and Link Address
    3. Load/Store Address
    Immediate values are determined in Immediate_Generator module.
    So no determination (Mux) will be needed here.(I-J-B immediate)
*/

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

module Address_Generator
(
    input [6 : 0] opcode, 
    input [31 : 0] rs1,            // to be connected to bus_rs1
    input [31 : 0] PC,
    input [31 : 0] immediate,

    output reg [31 : 0] address
);
    reg  [31 : 0] value;
    
    always @(*) 
    begin
        // Address Type evaluation (for Address Generator module)
        case (opcode)
            `STORE   : value = rs1;    //  Store  -> bus_rs1 + immediate
            `LOAD    : value = rs1;    //  Load   -> bus_rs1 + immediate
            `JAL     : value = PC;     //  JAL    ->    PC   + immediate
            `JALR    : value = PC;     //  JALR   ->    PC   + immediate
            `BRANCH  : value = PC;     //  Branch ->    PC   + immediate
            default  : value = 1'bz;
        endcase 
        
        address = value + immediate;
    end
endmodule