`timescale 1ns / 1ps
`include "../Arithmetic_Logic_Unit.v"

module Arithmetic_Logic_Unit_TB;

    reg  [6  : 0] opcode;
    reg  [2  : 0] funct3;
    reg  [6  : 0] funct7;
    reg  [31 : 0] accuracy_control;
    reg  [31 : 0] PC;
    reg  [31 : 0] rs1;
    reg  [31 : 0] rs2;
    reg  [31 : 0] immediate;
    wire [31 : 0] alu_output;

    Arithmetic_Logic_Unit ALU
    (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .accuracy_control(accuracy_control),
        .PC(PC),
        .rs1(rs1),
        .rs2(rs2),
        .immediate(immediate),
        .alu_output(alu_output)
    );

    initial begin

        $dumpfile("Arithmetic_Logic_Unit.vcd");
        $dumpvars(0, Arithmetic_Logic_Unit_TB);

        // ADD Test:
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        accuracy_control = 32'b0;
        rs1 = 32'd24970;
        rs2 = 32'd45889;
        #5
        $display("ALU ADD output: %d \n", alu_output);
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        accuracy_control = 32'b00000011_001;
        rs1 = 32'd2033215986;
        rs2 = 32'd1206705039;
        #5
        $display("ALU APX ADD output: %d \n", alu_output);
        #10;

        // ADDI Test:
        #10;
        opcode = 7'b0010011;
        funct3 = 3'b000;
        accuracy_control = 32'b0;
        rs1 = 32'd24970;
        rs2 = 32'h00000005;
        immediate = 32'd45889;
        #5
        $display("ALU ADDI output: %d \n", alu_output);
        #10;
        opcode = 7'b0010011;
        funct3 = 3'b000;
        accuracy_control = 32'b00000011_001;
        rs1 = 32'd29391;
        rs2 = 32'h00000005;
        immediate = 32'd18723;
        #5
        $display("ALU APX ADDI output: %d \n", alu_output);

        // SUB Test:
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        accuracy_control = 32'b0;
        rs1 = 32'h00000007;
        rs2 = 32'h00000003;
        #5
        $display("ALU SUB output: %d \n", alu_output);
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        accuracy_control = 32'b11111100_001;
        rs1 = 32'd5000;
        rs2 = 32'd2000;
        #5
        $display("ALU SUB output: %d \n", alu_output);
        #10
        $finish;

    end

endmodule