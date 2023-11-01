`include "../Multiplier_Unit.v"

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
`endif /*OPCODES*/

`ifndef NOP_INSTRUCTION
    `define NOP                     32'h0000_0013
    `define NOP_opcode              `OP_IMM
    `define NOP_funct12             12'h000
    `define NOP_funct7              7'b000_0000
    `define NOP_funct3              3'b000
    `define NOP_immediate           12'h000
    `define NOP_instruction_type   `I_TYPE
    `define NOP_write_index         5'b00000
`endif /*NOP_INSTRUCTION*/

`define MUL     3'b000
`define MULH    3'b001
`define MULHSU  3'b010
`define MULHU   3'b011 

`define MULDIV  7'b0000001

module Multiplier_Unit_Testbench;

    reg [ 6  : 0] opcode;
    reg [ 6  : 0] funct7;
    reg [ 2  : 0] funct3;
    reg [31  : 0] mul_csr;
    reg [31  : 0] rs1;
    reg [31  : 0] rs2;

    wire [31 : 0] mul_output;
    wire mul_unit_busy;

    Multiplier_Unit uut 
    (
        .CLK(CLK),
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .mul_csr(mul_csr),
        .rs1(rs1),
        .rs2(rs2),
        .mul_unit_busy(mul_unit_busy),
        .mul_output(mul_output)
    );

    reg CLK = 1'b1;
    parameter T_CLK = 20;

    always #(T_CLK/2) CLK = ~CLK;

    initial begin
        $dumpfile("Multiplier_Unit.vcd");
        $dumpvars(0, Multiplier_Unit_Testbench);
        
        opcode = `NOP_opcode;
        funct3 = `NOP_funct3;
        funct7 = `NOP_funct7;

        #(3 * T_CLK);
        opcode = `OP;
        funct3 = `MUL;
        funct7 = `MULDIV;

        // Case 1 : MUL
        mul_csr = 32'h0000_0001;
        rs1 = 32'd6458;
        rs2 = 32'd7831;

        #(T_CLK);
        opcode = `NOP_opcode;
        funct3 = `NOP_funct3;
        funct7 = `NOP_funct7;
        
        #(10 * T_CLK);
        $finish;
    end
endmodule