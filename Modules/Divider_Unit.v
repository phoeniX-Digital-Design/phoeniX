/*
  =====================================================================
  Module: User Divider
  Description: Divider module with configurable accuracy (optional)
  PLEASE DO NOT REMOVE THE COMMENTS IN THIS MODULE
  =====================================================================
*/

// *** Include your headers and modules here ***
`include "../Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Divider.v"
// *** End of including headers and modules ***

module Divider_Unit
(
    input CLK,                          // Sourcee clock signal

    input [6 : 0] opcode,               // DIV Operation
    input [6 : 0] funct7,               // DIV Operation
    input [2 : 0] funct3,               // DIV Operation

    input [31 : 0] accuracy_control,    // Approximation Control Register

    input [31 : 0] rs1,                 // Register Source 1
    input [31 : 0] rs2,                 // Register Source 1

    output reg div_unit_busy,           // Divider unit busy signal
    output reg [31 : 0] div_output     // DIV Result (DIV/REM)
);

    // Data forwarding will be considered in the core file (phoeniX.v)
    reg  [31 : 0] operand_1; 
    reg  [31 : 0] operand_2;
    reg  [31 : 0] input_1;
    reg  [31 : 0] input_2;
    wire [31 : 0] result;
    wire [31 : 0] remainder;
    wire busy;

    always @(*) 
    begin
        operand_1 = rs1;
        operand_2 = rs2;
        div_unit_busy = busy;
        casex ({funct7, funct3, opcode})
            17'b0000001_100_0110011 : begin  // DIV
                input_1 = operand_1;
                input_2 = $signed(operand_2);
                div_output = result;
            end
            17'b0000001_101_0110011 : begin  // DIVU
                input_1 = operand_1;
                input_2 = operand_2;
                div_output = result;
            end
            17'b0000001_110_0110011 : begin  // REM
                input_1 = operand_1;
                input_2 = $signed(operand_2);
                div_output = remainder;
            end
            17'b0000001_111_0110011 : begin  // REMU
                input_1 = operand_1;
                input_2 = operand_2;
                div_output = $signed(remainder);
            end
            default: begin div_output = 32'bz; div_unit_busy = 1'bz; end // Wrong opcode                
        endcase
    end

    // *** Instantiate your divider here ***
    // Please instantiate your divider module according to the guidelines and naming conventions of phoeniX
    // ----------------------------------------------------------------------------------------------------
    Approximate_Accuracy_Controlable_Divider divider 
    (
        .CLK(CLK),
        .Er(accuracy_control[10 : 3] | {8{~accuracy_control[0]}}),
        .operand_1(input_1),  
        .operand_2(input_2),  
        .div(result),  
        .rem(remainder), 
        .busy(busy)
    );
    // ----------------------------------------------------------------------------------------------------
    // *** End of divider instantiation ***

endmodule