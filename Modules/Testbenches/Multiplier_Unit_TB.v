`include "../Multiplier_Unit.v"

module Multiplier_Unit_TB;

    reg [ 6  : 0] opcode;
    reg [ 6  : 0] funct7;
    reg [ 2  : 0] funct3;
    reg [31  : 0] accuracy_control;
    reg [31  : 0] rs1;
    reg [31  : 0] rs2;

    wire [31 : 0] mul_output;
    wire mul_unit_busy;

    Multiplier_Unit uut 
    (
        .CLK(CLK),
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .accuracy_control(accuracy_control),
        .rs1(rs1),
        .rs2(rs2),
        .mul_unit_busy(mul_unit_busy),
        .mul_output(mul_output)
    );

    reg CLK = 1'b1;
    parameter T_CLK = 20;

    always #(T_CLK/2) CLK = ~CLK;

    initial begin
        $dumpfile("Multiplier_Unit.vcd");
        $dumpvars(0, Multiplier_Unit_TB);
        
        opcode = 7'b0;
        funct7 = 7'b0;
        funct3 = 3'b0;
        
        #60;
        opcode = 7'b0110011;
        funct7 = 7'b0000001;
        funct3 = 3'b000;

        // Case 1 : Accurate MUL
        accuracy_control = 32'b11111111_001;
        rs1 = 32'd500;
        rs2 = 32'd55;

        #(8 * T_CLK);
        $display("Multiplier unit output = %d", mul_output);
        $display("Multiplier unit busy = %d",   mul_unit_busy);
        #(T_CLK);


        // // Case 2 : Approximate MUL
        // accuracy_control = 32'b11111111_001;
        // rs1 = 32'd6000;
        // rs2 = 32'd7000;
        // #200;
        // $display("Multiplier unit output = %d", mul_output);
        // $display("Multiplier unit busy = %d",   mul_unit_busy);

        $finish;
    end

endmodule