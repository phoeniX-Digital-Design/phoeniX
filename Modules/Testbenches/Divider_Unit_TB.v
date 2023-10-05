`include "../Divider_Unit.v"

module Divider_Unit_TB;

    parameter DIV_X_EXTENISION = 1;
    parameter DIV_USER_DESIGN  = 1; // Change to 1 for testing if statement in module -> test passed
    parameter DIV_APX_ACC_CONTROL = 1;
    reg CLK = 0;
    reg [6:0] opcode;
    reg [6:0] funct7;
    reg [2:0] funct3;
    reg [7:0] accuracy_level;
    reg [31:0] rs1;
    reg [31:0] rs2;

    wire div_unit_busy;
    wire [31:0] div_output;

    Divider_Unit #(DIV_X_EXTENISION, DIV_USER_DESIGN, DIV_APX_ACC_CONTROL) uut 
    (
        .CLK(CLK),
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .accuracy_level(accuracy_level),
        .rs1(rs1),
        .rs2(rs2),
        .div_unit_busy(div_unit_busy),
        .div_output(div_output)
    );

    always #10 CLK = ~CLK;

    initial begin
        $dumpfile("DIV.vcd");
        $dumpvars(0, Divider_Unit_TB);

        opcode = 7'b0110011;
        funct7 = 7'b0000001;
        funct3 = 3'b100;

        accuracy_level = 8'b00000000;
        rs1 = 32'd400;
        rs2 = 32'd20;

        #20;
        $display("Divider output: %d", div_output);
        $display("Divider busy: %d", div_unit_busy);

        accuracy_level = 8'b00000001;
        rs1 = 32'd100;
        rs2 = 32'd20;
        #20;
        $display("Divider output: %d", div_output);
        $display("Divider busy: %d", div_unit_busy);

        accuracy_level = 8'b00000010;
        rs1 = 32'd500;
        rs2 = 32'd20;
        #20;
        $display("Divider output: %d", div_output);
        $display("Divider busy: %d", div_unit_busy);

        $finish;
    end

endmodule