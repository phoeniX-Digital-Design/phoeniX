`timescale 1ns/1ns

`include "Memory_Interface.v"
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

    reg  reset = 1'b1; 

    reg  enable_fetch;
    reg  [31 : 0] PC;

    reg  jump_branch_enable;
    wire [31 : 0] next_PC;
    wire [31 : 0] fetched_instruction_reg;
    wire fetch_done;

    Fetch_Unit fetch_unit
    (
        .CLK(CLK),
        .enable(enable_fetch),
        .PC(PC),
        .address(address),
        .jump_branch_enable(jump_branch_enable),
        .next_PC(next_PC),
        .fetched_instruction_reg(fetched_instruction_reg),
        .fetch_done(fetch_done)
    );

    reg [31 : 0] instruction;
    // Instrution Register Behaviour
    always @(posedge CLK)
    begin
        instruction <= fetched_instruction_reg;    
    end

    // PC Register Behaviour
    always @(posedge CLK) 
    begin
        if (reset)
            PC <= 32'hFFFFFFFC;
        else
            PC <= next_PC; 
    end

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
        .instruction(instruction),
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

    wire [31 : 0] immediate;

    Immediate_Generator immediate_generator
    (
        .instruction(instruction),
        .instruction_type(instruction_type),
        .immediate(immediate)
    );

    wire address_type;
    wire mux1_select;
    wire [1 : 0] mux2_select;
    wire fetch_enable;
    wire lsu_enable;
    wire read_enable_1;
    wire read_enable_2;
    wire write_enable;
    wire [1 : 0] writeback_output_select;

    Control_Unit control_unit
    (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .instruction_type(instruction_type),
        .address_type(address_type),
        .mux1_select(mux1_select),
        .mux2_select(mux2_select),
        .fetch_enable(fetch_enable),
        .lsu_enable(lsu_enable),
        .read_enable_1(read_enable_1),
        .read_enable_2(read_enable_2),
        .write_enable(write_enable),
        .writeback_output_select(writeback_output_select)
    );

    reg  [31 : 0] bus_rs1;
    reg  [31 : 0] bus_rs2;
    wire [31 : 0] address;

    Address_Generator address_generator
    (
        .address_type(address_type),
        .bus_rs1(bus_rs1),
        .PC(PC),
        .immediate(immediate),
        .address(address)
    );
    
    reg  [31 : 0] write_data;
    wire [31 : 0] read_data_1;
    wire [31 : 0] read_data_2;

    Register_File reg_file
    (
        .CLK(CLK),
        .read_enable_1(read_enable_1),
        .read_enable_2(read_enable_2),
        .write_enable(write_enable),
        .read_index_1(read_index_1),
        .read_index_2(read_index_2),
        .write_index(write_index),
        .write_data(write_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    wire [31 : 0] alu_output;

    Arithmetic_Logic_Unit ALU
    (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .mux1_select(mux1_select),
        .mux2_select(mux2_select),
        .PC(PC),
        .rs1(bus_rs1),
        .rs2(bus_rs2),
        .immediate(immediate),
        .alu_output(alu_output)
    );

    wire [31 : 0] load_data;

    Load_Store_Unit LSU
    (
        .CLK(CLK),
        .enable(lsu_enable),
        .opcode(opcode),
        .funct3(funct3),
        .address(address),
        .store_data(alu_output),
        .load_data(load_data)
    );

    wire [31 : 0] writeback_output;

    Writeback_Mux wb_mux
    (
        .writeback_output_select(writeback_output_select),
        .immediate(immediate),
        .load_data(load_data),
        .execution_output(alu_output),
        .writeback_output(writeback_output)
    );

    initial begin

        $dumpfile("Core_Sequential.vcd");
        $dumpvars(0, Core_Sequential);
        $readmemh("..\\Instruction_Memory.txt", fetch_unit.instruction_memory.Memory);

        reset = 1'b1;

        // Reset for first time
        #14
        reset = 1'b0;
        enable_fetch = 1'b1;

        // Wait for a few clock cycles
        #12;
        reset  = 1'b0;
        #10;
        enable_fetch = 1'b1;
        #36
        address = 32'h0;
        jump_branch_enable = 1'b1;
        #12
        jump_branch_enable = 1'b0;
        #100;

        $finish;

    end

endmodule