`include "../Divider_Unit.v"

module Divider_Unit_TB;

    parameter APPROXIMATE = 1; // Change to 1 for testing if statement in module -> test passed
    parameter ACCURACY = 1;
    
    reg [6:0] opcode;
    reg [6:0] funct7;
    reg [2:0] funct3;
    reg [7:0] accuracy_level;
    reg [31:0] bus_rs1;
    reg [31:0] bus_rs2;

    wire div_unit_busy;
    wire [31:0] div_output;

    Divider_Unit #(APPROXIMATE, ACCURACY) uut 
    (
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .accuracy_level(accuracy_level),
        .bus_rs1(bus_rs1),
        .bus_rs2(bus_rs2),
        .div_unit_busy(div_unit_busy),
        .div_output(div_output)
    );

    initial begin
        $dumpfile("DIV.vcd");
        $dumpvars(0, Divider_Unit_TB);

        opcode = 7'b0110011;
        funct7 = 7'b0000001;
        funct3 = 3'b100;

        accuracy_level = 8'b00000000;
        bus_rs1 = 32'd400;
        bus_rs2 = 32'd20;

        #20;
        $display("Divider output: %d", div_output);
        $display("Divider busy: %d", div_unit_busy);

        accuracy_level = 8'b00000001;
        bus_rs1 = 32'd100;
        bus_rs2 = 32'd20;
        #20;
        $display("Divider output: %d", div_output);
        $display("Divider busy: %d", div_unit_busy);

        accuracy_level = 8'b00000010;
        bus_rs1 = 32'd500;
        bus_rs2 = 32'd20;
        #20;
        $display("Divider output: %d", div_output);
        $display("Divider busy: %d", div_unit_busy);

        $finish;
    end

endmodule