`include "..\\Arithmetic_Logic_Unit.v"

module TB_ALU;

    // Inputs
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    reg [4:0] FLEN;
    reg mux1_select;
    reg [1:0] mux2_select;
    reg [31:0] bus_rs1;
    reg [31:0] bus_rs2;
    reg [31:0] immediate;
    reg [31:0] Forward_rs1;
    reg [31:0] Forward_rs2;

    // Outputs
    wire [31:0] alu_output;

    // Instantiate the unit under test
    Arithmetic_Logic_Unit alu
    (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .FLEN(FLEN),
        .mux1_select(mux1_select),
        .mux2_select(mux2_select),
        .bus_rs1(bus_rs1),
        .bus_rs2(bus_rs2),
        .immediate(immediate),
        .Forward_rs1(Forward_rs1),
        .Forward_rs2(Forward_rs2),
        .alu_output(alu_output)
    );

    initial begin
        // Test case 1: ADDI
        opcode = 7'b0010011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        FLEN = 5'b00000;
        mux1_select = 0;
        mux2_select = 2'b10;
        bus_rs1 = 32'h00000001;
        bus_rs2 = 32'h00000002;
        immediate = 32'h00000003;
        Forward_rs1 = 32'h00000000;
        Forward_rs2 = 32'h00000000;
        #1;
        $display("ALU output for ADDI: %h", alu_output);
        if (alu_output !== 32'h00000004) $error("Test case 1 failed");

        // Test case 2: AND
        opcode = 7'b0110011;
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        FLEN = 5'b00000;
        mux1_select = 0;
        mux2_select = 2'b00;
        bus_rs1 = 32'h000100ff;
        bus_rs2 = 32'h0001ff00;
        immediate = 32'h00000000;
        Forward_rs1 = 32'h00000000;
        Forward_rs2 = 32'h00000000;
        #1;
        $display("ALU output for AND: %h", alu_output);
        if (alu_output !== 32'h00010000) $error("Test case 2 failed");

        // Test case 3: SRL
        opcode = 7'b0110011;
        funct3 = 3'b101;
        funct7 = 7'b0000000;
        FLEN = 5'b00000;
        mux1_select = 0;
        mux2_select = 2'b00;
        bus_rs1 = 32'h80000000;
        bus_rs2 = 32'h00000001;
        immediate = 32'h00000000;
        Forward_rs1 = 32'h00000000;
        Forward_rs2 = 32'h00000000;
        #1;
        $display("ALU output for SRL: %h", alu_output);
        if (alu_output !== 32'h40000000) $error("Test case 3 failed");

        $display("All test cases passed");
        $finish;
    end

endmodule