`include "../Arithmetic_Logic_Unit.v"

module Arithmetic_Logic_Unit_TB;

    reg  [6  : 0] opcode;
    reg  [2  : 0] funct3;
    reg  [6  : 0] funct7;
    reg  [31 : 0] accuracy_control;
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
        .rs1(rs1),
        .rs2(rs2),
        .immediate(immediate),
        .alu_output(alu_output)
    );

    initial begin
        opcode = 7'b00_100_11;  // Shift opcode
        funct3 = 3'b001;        // SLLI
        funct7 = 7'b0_000_000;
        accuracy_control = 32'h0;
        rs1 = 32'hFFFF_FFFF;
        rs2 = 32'd4;
        immediate = 32'd6;
        #10;
        $display("Source Register: %b", rs1);
        $display("Shift Amount: %d", immediate);
        $display("ALU Output: %b", alu_output);
        #20;
        opcode = 7'b00_100_11;  // Shift opcode
        funct3 = 3'b101;        // SRLI
        funct7 = 7'b0_000_000;
        accuracy_control = 32'h0;
        rs1 = 32'hA5A5_A5A5;
        rs2 = 32'd4;
        immediate = 32'd4;
        #10;
        $display("Source Register: %b", rs1);
        $display("Shift Amount: %d", immediate);
        $display("ALU Output: %b", alu_output);
        #20;
        opcode = 7'b01_100_11;  // Shift opcode
        funct3 = 3'b101;        // SRL
        funct7 = 7'b0_000_000;
        accuracy_control = 32'h0;
        rs1 = 32'hFFFF_FFFF;
        rs2 = 32'd10;
        immediate = 32'd4;
        #10;
        $display("Source Register: %b", rs1);
        $display("Shift Amount: %d", rs2);
        $display("ALU Output: %b", alu_output);
        
        $finish;
    end

endmodule