/*
    RV32IMF Core - Fixed Point Unit
    - This unit executes 'F' estension instructions
    - Inputs rs1, rs2 comes from Register_File (Fixed Point Register File)
    - Input immediate comes from Immediate_Generator
    - Inputs forward_rs1, forward_rs2 comes from the execution-unit output (bypassed)
    - Input signals opcode, funct3, funct7, comes from Instruction_Decoder
    - Input signals mux1_select, mux2_select comes from Control_Unit
    - Supported Instructions :

        F-TYPE : TBD                        
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

module Fixed_Point_Unit #(parameter FLEN = 10)
(
    input [6 : 0] opcode,               // FPU Operation
    input [2 : 0] funct3,               // FPU Operation
    input [6 : 0] funct7,               // FPU Operation

    input [4 : 0] read_index_1,         // Register Address 1
    input [4 : 0] read_index_2,         // Register Address 2
    
    input         mux1_select,          // Bypass Mux for operand_1
    input         mux2_select,          // Bypass Mux for operand_2

    input [31 : 0] rs1,                 // Register Source 1
    input [31 : 0] rs2,                 // Register Source 2

    output reg [31 : 0] fpu_output      // FPU Result
);

    reg [31 : 0] operand_1;
    reg [31 : 0] operand_2;

    // Bypassing multiplexer for FPU will be added in the core
    // There are no immediate values or PC in FPU instructions
    // Source registers are assigned to operands of FPU directly
    always @(*)
    begin
        operand_1 <= rs1;
        operand_2 <= rs2;
        casex ({funct7, funct3, opcode})
            // funct3 can be eliminated from the case (need to be checked later)
            // F-Extension Intructions
            {7'b0000000, 3'bxxx, `OP_FP} : fpu_output = operand_1 + operand_2;      // FADD.S
            {7'b0000100, 3'bxxx, `OP_FP} : fpu_output = operand_1 - operand_2;      // FSUB.S
            {7'b1101000, 3'bxxx, `OP_FP} : begin
                if (read_index_2 == 5'b00000)
                    fpu_output = $signed(operand_1) << FLEN;                        // FCVT.S.W
            end
            {7'b1101000_, 3'bxxx, `OP_FP} : begin 
                if (read_index_2 == 5'b00001) 
                    fpu_output = operand_1 << FLEN;                                 // FCVT.S.WU
            end
            {7'b1100000, 3'bxxx, `OP_FP} : begin
                if (read_index_2 == 5'b00000)
                    fpu_output = $signed(operand_1 >> FLEN);                        // FCVT.W.S
            end
            {7'b1100000, 3'bxxx, `OP_FP} : begin 
                if (read_index_2 == 5'b00001) 
                    fpu_output = operand_1 >> FLEN;                                 // FCVT.WU.S
            end    
            default: fpu_output = 32'bz; 
        endcase
    end

endmodule