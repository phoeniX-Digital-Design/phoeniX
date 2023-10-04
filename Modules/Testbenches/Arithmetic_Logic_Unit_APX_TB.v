`timescale 1ns / 1ps
`include "../Arithmetic_Logic_Unit_APX.v"

module Arithmetic_Logic_Unit_APX_TB;

    reg  [6  : 0] opcode;
    reg  [2  : 0] funct3;
    reg  [6  : 0] funct7;
    reg  [7  : 0] accuracy_level;
    reg  [31 : 0] PC;
    reg  [31 : 0] rs1;
    reg  [31 : 0] rs2;
    reg  [31 : 0] immediate;
    wire [31 : 0] alu_output;

    Arithmetic_Logic_Unit_APX #(.APPROXIMATE(1), .ACCURACY(1)) ALU_APX 
    (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .accuracy_level(accuracy_level),
        .PC(PC),
        .rs1(rs1),
        .rs2(rs2),
        .immediate(immediate),
        .alu_output(alu_output)
    );

    initial begin

        $dumpfile("ALU_APX.vcd");
        $dumpvars(0, Arithmetic_Logic_Unit_APX_TB);

        // ADD Test:
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        accuracy_level = 8'b0000_0000;
        rs1 = 32'h00000004;
        rs2 = 32'h00000005;
        #5
        $display("ALU ADD output: %d", alu_output);
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        accuracy_level = 8'b0000_0001;
        rs1 = 32'h00000004;
        rs2 = 32'h00000005;
        #5
        $display("ALU ADD output: %d", alu_output);
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        accuracy_level = 8'b0000_0010;
        rs1 = 32'h00000004;
        rs2 = 32'h00000005;
        #5
        $display("ALU ADD output: %d", alu_output);
        #10

        // ADDI Test:
        #10;
        opcode = 7'b0010011;
        funct3 = 3'b000;
        accuracy_level = 8'b0000_0000;
        rs1 = 32'h00000004;
        rs2 = 32'h00000005;
        immediate = 32'h00000003;
        #5
        $display("ALU ADDI output: %d", alu_output);
        #10;
        opcode = 7'b0010011;
        funct3 = 3'b000;
        accuracy_level = 8'b0000_0001;
        rs1 = 32'h00000004;
        rs2 = 32'h00000005;
        immediate = 32'h00000003;
        #5
        $display("ALU ADDI output: %d", alu_output);
        #10;
        opcode = 7'b0010011;
        funct3 = 3'b000;
        accuracy_level = 8'b0000_0010;
        rs1 = 32'h00000004;
        rs2 = 32'h00000005;
        immediate = 32'h00000003;
        #5
        $display("ALU ADDI output: %d", alu_output);
        #10

        // SUB Test:
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        accuracy_level = 8'b0000_0000;
        rs1 = 32'h00000006;
        rs2 = 32'h00000003;
        #5
        $display("ALU SUB output: %d", alu_output);
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        accuracy_level = 8'b0000_0001;
        rs1 = 32'h00000006;
        rs2 = 32'h00000003;
        #5
        $display("ALU SUB output: %d", alu_output);
        #10;
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        accuracy_level = 8'b0000_0010;
        rs1 = 32'h00000006;
        rs2 = 32'h00000003;
        #5
        $display("ALU SUB output: %d", alu_output);
        #10
        $finish;

    end

endmodule