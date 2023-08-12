`include "Multiplier_Unit.v"

module TB_Mul;

    reg [6 : 0] opcode;
    reg [6 : 0] funct7;
    reg [2 : 0] funct3;

    reg mux1_select;
    reg mux2_select;
    
    reg [6 : 0] mask;
    
    reg [31 : 0] bus_rs1;
    reg [31 : 0] bus_rs2;
    reg [31 : 0] Forward_rs1;
    reg [31 : 0] Forward_rs2;

    wire [31 : 0] mul_output;

    Multiplier_Unit dut 
    (
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .mux1_select(mux1_select),
        .mux2_select(mux2_select),
        .mask(mask),
        .bus_rs1(bus_rs1),
        .bus_rs2(bus_rs2),
        .Forward_rs1(Forward_rs1),
        .Forward_rs2(Forward_rs2),
        .mul_output(mul_output)
    );

    initial begin
        // Test case 1: MUL
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000001;
        mux1_select = 1'b0;
        mux2_select = 1'b0;
        mask = 7'b000_0000;
        bus_rs1 = 30;
        bus_rs2 = 30;
        Forward_rs1 = 20;
        Forward_rs2 = 20;
        #1;
        $display("Mask 000_0000 : Multiplier output for MUL: %d", mul_output);

        // Test case 2: MUL
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000001;
        mux1_select = 1'b0;
        mux2_select = 1'b0;
        mask = 7'b111_1111;
        bus_rs1 = 30;
        bus_rs2 = 30;
        Forward_rs1 = 20;
        Forward_rs2 = 20;
        #1;
        $display("Mask 111_1111 : Multiplier output for MUL: %d", mul_output);

        // Test case 3: MULH
        opcode = 7'b0110011;
        funct3 = 3'b001;
        funct7 = 7'b0000001;
        mux1_select = 1'b0;
        mux2_select = 1'b0;
        mask = 7'b111_1111;
        bus_rs1 = 30;
        bus_rs2 = 30;
        Forward_rs1 = 20;
        Forward_rs2 = 20;
        #1;
        $display("Mask 111_1111 : Multiplier output for MULH: %d", mul_output);

        // Test case 4: Default
        opcode = 7'b0010011;
        funct3 = 3'b001;
        funct7 = 7'b0000000;
        mux1_select = 1'b0;
        mux2_select = 1'b0;
        mask = 7'b0000000;
        bus_rs1 = 32'h00000001;
        bus_rs2 = 32'h00000002;
        Forward_rs1 = 20;
        Forward_rs2 = 20;
        #1;
        $display("Wrong opcode : Multiplier output for default case: %h", mul_output);
        if (mul_output !== 32'hz) $error("Test case 3 failed");

        $display("All test cases passed");
        $finish;
    end

endmodule