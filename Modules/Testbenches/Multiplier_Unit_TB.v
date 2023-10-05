`include "../Multiplier_Unit.v"

module Multiplier_Unit_TB;

    parameter X_EXTENISION = 1;
    parameter USER_DESIGN = 1;  // Change to 1 for testing if statement in module -> test passed
    parameter APX_ACC_CONTROL = 1;
    reg CLK = 0;
    reg [6:0] opcode;
    reg [6:0] funct7;
    reg [2:0] funct3;
    reg [7:0] accuracy_level;
    reg [31:0] rs1;
    reg [31:0] rs2;

    wire mul_unit_busy;
    wire [31:0] mul_output;

    Multiplier_Unit #(X_EXTENISION, USER_DESIGN, APX_ACC_CONTROL) uut 
    (
        .CLK(CLK),
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .accuracy_level(accuracy_level),
        .rs1(rs1),
        .rs2(rs2),
        .mul_unit_busy(mul_unit_busy),
        .mul_output(mul_output)
    );

    always #10 CLK = ~CLK;

    initial begin
        $dumpfile("MUL.vcd");
        $dumpvars(0, Multiplier_Unit_TB);

        opcode = 7'b0110011;
        funct7 = 7'b0000001;
        funct3 = 3'b000;

        accuracy_level = 8'b00000000;
        rs1 = 32'd10;
        rs2 = 32'd20;

        #20;
        $display("Multiplier output: %d", mul_output);
        $display("Multiplier busy: %d", mul_unit_busy);

        opcode = 7'b0110011;
        funct7 = 7'b0000001;
        funct3 = 3'b000;

        accuracy_level = 8'b00000001;
        rs1 = 32'd10;
        rs2 = 32'd20;
        #20;
        $display("Multiplier output: %d", mul_output);
        $display("Multiplier busy: %d", mul_unit_busy);

        accuracy_level = 8'b00000010;
        rs1 = 32'd10;
        rs2 = 32'd20;
        #20;
        $display("Multiplier output: %d", mul_output);
        $display("Multiplier busy: %d", mul_unit_busy);

        $finish;
    end

endmodule