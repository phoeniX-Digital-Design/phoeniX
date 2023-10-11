`include "../Divider_Unit.v"

module Divider_Unit_TB;

    reg CLK = 0;
    reg [6  : 0] opcode;
    reg [6  : 0] funct7;
    reg [2  : 0] funct3;
    reg [31  : 0] accuracy_control;
    reg [31 : 0] rs1;
    reg [31 : 0] rs2;

    wire [31 : 0] div_output;
    wire div_unit_busy;

    Divider_Unit uut 
    (
        .CLK(CLK),
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .accuracy_control(accuracy_control),
        .rs1(rs1),
        .rs2(rs2),
        .div_unit_busy(div_unit_busy),
        .div_output(div_output)
    );

    always #10 CLK = ~CLK;

    initial begin
        $dumpfile("Divider_Unit.vcd");
        $dumpvars(0, Divider_Unit_TB);

        opcode = 7'b0110011;
        funct7 = 7'b0000001;
        funct3 = 3'b100;

        accuracy_control = 32'b11111111_001;
        rs1 = 32'd400;
        rs2 = 32'd20;
        #4000;
        $display("Divider output: %d", div_output);
        $display("Divider busy: %d", div_unit_busy);

        accuracy_control = 32'b11111111_001;
        rs1 = 32'd100;
        rs2 = 32'd20;
        #4000;
        $display("Divider output: %d", div_output);
        $display("Divider busy: %d", div_unit_busy);

        accuracy_control = 32'b11111111_001;
        rs1 = 32'd500;
        rs2 = 32'd20;
        #4000;
        $display("Divider output: %d", div_output);
        $display("Divider busy: %d", div_unit_busy);

        $finish;
    end

endmodule