/*
    phoeniX RV32I core - Arithmetic Logic Unit
    - This unit executes R-Type, I-Type and J-Type instructions
    - Inputs bus_rs1, bus_rs2 comes from Register_File
    - Input immediate comes from Immediate_Generator
    - Input signals opcode, funct3, funct7, comes from Instruction_Decoder
    - Supported Instructions :

        I-TYPE : ADDI - SLTI - SLTIU            R-TYPE : ADD  - SUB  - SLL           
                 XORI - ORI  - ANDI                      SLT  - SLTU - XOR                         
                 SLLI - SRLI - SRAI                      SRL  - SRA  - OR  - AND
        
        J-TYPE : JAL  - JALR                    U-TYPE : AUIPC         
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

module Arithmetic_Logic_Unit 
(
    input [6 : 0] opcode,               // ALU Operation
    input [2 : 0] funct3,               // ALU Operation
    input [6 : 0] funct7,               // ALU Operation

    input [31 : 0] PC,                  // Program Counter Register
    input [31 : 0] rs1,                 // Register Source 1
    input [31 : 0] rs2,                 // Register Source 2
    input [31 : 0] immediate,           // Immediate Source

    output reg [31 : 0] alu_output      // ALU Result
);

    reg [31 : 0] operand_1;
    reg [31 : 0] operand_2;
    
    reg         mux1_select;
    reg [1 : 0] mux2_select;

    // ALU multiplexers signals evaluation
    always @(*) 
    begin
        case (opcode)
        `OP     : begin mux1_select = 1'b0; mux2_select = 2'b00; end // R-TYPE 
        `OP_IMM : begin mux1_select = 1'b0; mux2_select = 2'b01; end // I-TYPE 
        `JALR   : begin mux1_select = 1'b1; mux2_select = 2'b10; end // JALR   
        `JAL    : begin mux1_select = 1'b1; mux2_select = 2'b10; end // JAL    
        `AUIPC  : begin mux1_select = 1'b1; mux2_select = 2'b01; end // AUIPC
        endcase        
    end

    // ALU Multiplexer 1
    always @(*) 
    begin
        case (mux1_select)
            1'b0 : operand_1 = rs1;
            1'b1 : operand_1 = PC;
        endcase
    end

    // ALU Multiplexer 2
    always @(*) 
    begin
        case (mux2_select)
            2'b00 : operand_2 = rs2;
            2'b01 : operand_2 = immediate;
            2'b10 : operand_2 = 4;
        endcase
    end

    always @(*)
    begin
        casex ({funct7, funct3, opcode})
            // I-TYPE Intructions
            {7'bx_xxx_xxx, 3'b000, `OP_IMM} : alu_output = operand_1 + operand_2;                               // ADDI
            {7'b0_000_000, 3'b001, `OP_IMM} : alu_output = operand_1 << operand_2 [4 : 0];                      // SLLI
            {7'bx_xxx_xxx, 3'b010, `OP_IMM} : alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;     // SLTI
            {7'bx_xxx_xxx, 3'b011, `OP_IMM} : alu_output = operand_1 < operand_2 ? 1 : 0;                       // SLTIU
            {7'bx_xxx_xxx, 3'b100, `OP_IMM} : alu_output = operand_1 ^ operand_2;                               // XORI
            {7'b0_000_000, 3'b101, `OP_IMM} : alu_output = operand_1 >> operand_2 [4 : 0];                      // SRLI
            {7'b0_100_000, 3'b101, `OP_IMM} : alu_output = operand_1 >> $signed(operand_2 [4 : 0]);             // SRAI
            {7'bx_xxx_xxx, 3'b110, `OP_IMM} : alu_output = operand_1 | operand_2;                               // ORI
            {7'bx_xxx_xxx, 3'b111, `OP_IMM} : alu_output = operand_1 & operand_2;                               // ANDI
            
            // R-TYPE Instructions
            {7'b0_000_000, 3'b000, `OP}     : alu_output = operand_1 + operand_2;                               // ADD
            {7'b0_100_000, 3'b000, `OP}     : alu_output = operand_1 - operand_2;                               // SUB
            {7'b0_000_000, 3'b001, `OP}     : alu_output = operand_1 << operand_2;                              // SLL
            {7'b0_000_000, 3'b010, `OP}     : alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;     // SLT
            {7'b0_000_000, 3'b011, `OP}     : alu_output = operand_1 < operand_2 ? 1 : 0;                       // SLTU
            {7'b0_000_000, 3'b100, `OP}     : alu_output = operand_1 ^ operand_2;                               // XOR
            {7'b0_000_000, 3'b101, `OP}     : alu_output = operand_1 >> operand_2;                              // SRL
            {7'b0_100_000, 3'b101, `OP}     : alu_output = operand_1 >> $signed(operand_2);                     // SRA
            {7'b0_000_000, 3'b110, `OP}     : alu_output = operand_1 | operand_2;                               // OR
            {7'b0_000_000, 3'b111, `OP}     : alu_output = operand_1 & operand_2;                               // AND

            // JAL and JALR Instructions
            {7'bx_xxx_xxx, 3'bxxx, `JAL}    : alu_output = operand_1 + operand_2;                               // JAL
            {7'bx_xxx_xxx, 3'b000, `JALR}   : alu_output = operand_1 + operand_2;                               // JALR
            
            // AUIPC Instruction
            {7'bx_xxx_xxx, 3'bxxx, `AUIPC}  : alu_output = operand_1 + operand_2;                               // AUIPC

            default: alu_output = 32'bz; 
        endcase
    end
endmodule