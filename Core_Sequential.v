`timescale 1ns/1ns

`include "Fetch_Unit.v"

`include "Instruction_Decoder.v"
`include "Immediate_Generator.v"

`include "Bypass_Mux.v"

`include "Arithmetic_Logic_Unit.v"
`include "Jump_Branch_Unit.v"
`include "Address_Generator.v"

`include "Load_Store_Unit.v"
`include "Writeback_Mux.v"

`include "Control_Unit.v"
`include "Register_File.v"

module Core_Sequential;

    reg CLK = 1;
    always #1 CLK = ~CLK;

    reg  enable_fetch;
    reg  [31 : 0] PC_fetch;
    reg  jump_branch_enable;
    wire [31 : 0] next_PC;
    reg  [31 : 0] fetched_instruction_reg;
    wire fetch_done;

    Fetch_Unit fetch_unit
    (
        .CLK(CLK),
        .enable(enable_fetch),
        .PC(PC_fetch),
        .jump_branch_enable(jump_branch_enable),
        .next_PC(next_PC),
        .fetched_instruction_reg(fetched_instruction_reg),
        .fetch_done(fetch_done)
    );

    wire [2 : 0] instruction_type;
    wire [6 : 0] opcode;
    wire [2 : 0] funct3;
    wire [6 : 0] funct7;
    wire funct3_valid;
    wire funct7_valid;
    wire [4 : 0] read_index_1;
    wire [4 : 0] read_index_2;
    wire [4 : 0] write_index;

    Instruction_Decoder instruction_decoder
    (
        .instruction(fetched_instruction_reg),
        .instruction_type(instruction_type),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .funct3_valid(funct3_valid),
        .funct7_valid(funct7_valid),
        .read_index_1(read_index_1),
        .read_index_2(read_index_2),
        .write_index(write_index)
    );

    reg [31 : 0] immediate;

    Immediate_Generator immediate_generator
    (
        .instruction(fetched_instruction_reg),
        .instruction_type(instruction_type),
        .immediate(immediate)
    );

    

endmodule