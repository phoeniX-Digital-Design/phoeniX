`include "../Multiplier_Unit.v"

module Multiplier_Unit_TB;

    // Parameters
    parameter APPROXIMATE = 0;
    parameter ACCURACY = 0;

    // Inputs
    reg [6:0] opcode;
    reg [6:0] funct7;
    reg [2:0] funct3;
    reg [7:0] accuracy_level;
    reg [31:0] bus_rs1;
    reg [31:0] bus_rs2;

    // Outputs
    wire mul_unit_busy;
    wire [31:0] mul_output;

    // Instantiate the DUT (Multiplier_Unit)
    Multiplier_Unit #(APPROXIMATE, ACCURACY) uut 
    (
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .accuracy_level(accuracy_level),
        .bus_rs1(bus_rs1),
        .bus_rs2(bus_rs2),
        .mul_unit_busy(mul_unit_busy),
        .mul_output(mul_output)
    );

    initial begin
        $dumpfile("MUL.vcd");
        $dumpvars(0, Multiplier_Unit_TB);

        opcode = 7'b0110011;
        funct7 = 7'b0000001;
        funct3 = 3'b000;

        accuracy_level = 8'b00000000;
        bus_rs1 = 32'd10;
        bus_rs2 = 32'd20;

        #20;
        $display("Multiplier output: %d", mul_output);
        $display("Multiplier busy: %d", mul_unit_busy);

        opcode = 7'b0110011;
        funct7 = 7'b0000001;
        funct3 = 3'b000;

        accuracy_level = 8'b00000001;
        bus_rs1 = 32'd10;
        bus_rs2 = 32'd20;
        #20;
        $display("Multiplier output: %d", mul_output);
        $display("Multiplier busy: %d", mul_unit_busy);

        accuracy_level = 8'b00000010;
        bus_rs1 = 32'd10;
        bus_rs2 = 32'd20;
        #20;
        $display("Multiplier output: %d", mul_output);
        $display("Multiplier busy: %d", mul_unit_busy);

        $finish;
    end

endmodule