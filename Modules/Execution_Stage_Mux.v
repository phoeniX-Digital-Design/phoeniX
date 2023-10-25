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

`define MUL     3'b000
`define MULH    3'b001
`define MULHSU  3'b010
`define MULHU   3'b011 

`define DIV     3'b100
`define DIVU    3'b101
`define REM     3'b110
`define REMU    3'b111

`define MULDIV  7'b0000001

`ifndef EXECUTION_MUX_STATES
    `define SELECT_ALU 2'b00
    `define SELECT_MUL 2'b01
    `define SELECT_DIV 2'b10
    `define SELECT_FPU 2'b11
`endif

module Execution_Stage_Mux_Control 
(
    input [6 : 0] opcode,
    input [2 : 0] funct3,
    input [6 : 0] funct7,

    input [31 : 0] alu_output,
    input [31 : 0] mul_output,
    input [31 : 0] div_output,

    output reg [31 : 0] result_execute
);

    reg [1  : 0] execution_mux_select;

    always @(*) 
    begin
        case ({funct7, funct3, opcode})
            {7'bx_xxx_xxx, 3'bxxx, `OP_IMM} : execution_mux_select = `SELECT_ALU;
            {7'b0_000_000, 3'bxxx, `OP}     : execution_mux_select = `SELECT_ALU;
            {7'b0_100_000, 3'b101, `OP}     : execution_mux_select = `SELECT_ALU;
            {7'bx_xxx_xxx, 3'bxxx, `JAL}    : execution_mux_select = `SELECT_ALU;
            {7'bx_xxx_xxx, 3'b000, `JALR}   : execution_mux_select = `SELECT_ALU;
            {7'bx_xxx_xxx, 3'bxxx, `AUIPC}  : execution_mux_select = `SELECT_ALU;

            {`MULDIV, `MUL,    `OP} : execution_mux_select = `SELECT_MUL;
            {`MULDIV, `MULH,   `OP} : execution_mux_select = `SELECT_MUL;
            {`MULDIV, `MULHSU, `OP} : execution_mux_select = `SELECT_MUL;
            {`MULDIV, `MULHU,  `OP} : execution_mux_select = `SELECT_MUL;

            {`MULDIV, `DIV,    `OP} : execution_mux_select = `SELECT_DIV;
            {`MULDIV, `DIVU,   `OP} : execution_mux_select = `SELECT_DIV;
            {`MULDIV, `REM,    `OP} : execution_mux_select = `SELECT_DIV;
            {`MULDIV, `REMU,   `OP} : execution_mux_select = `SELECT_DIV;
            default: execution_mux_select = `SELECT_ALU;    
        endcase 
    end

    always @(*) 
    begin
        case (execution_mux_select)
            `SELECT_ALU:   assign result_execute = alu_output;
            `SELECT_MUL:   assign result_execute = mul_output;
            `SELECT_DIV:   assign result_execute = div_output;
            default:       assign result_execute = alu_output;
        endcase
    end
    
endmodule