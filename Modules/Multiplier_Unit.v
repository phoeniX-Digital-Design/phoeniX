/*
  =====================================================================
  Module: User Multiplier
  Description: Multiplier module with configurable accuracy (optional)
  PLEASE DO NOT REMOVE THE COMMENTS IN THIS MODULE
  =====================================================================
  Inputs:
  - CLK: Source clock signal
  - input_1:  32-bit input operand 1.
  - input_2:  32-bit input operand 2.
  - accuracy: 8-bit accuracy setting.
  Outputs:
  - busy: Output indicating the busy status of the multiplier.
  - result: 32-bit result of the multiplication.
  =====================================================================
  Naming Convention:
  All user-defined multiplier modules should follow this format:
  - Inputs: CLK, input_1, input_2, accuracy
  - Outputs: busy, result
  ======================================================================
*/

// *** Include your headers and modules here ***
`include "../User_Modules/Sample_Multiplier/Sample_Multiplier.v"
// *** End of including headers and modules ***

module Multiplier_Unit #(parameter APPROXIMATE = 0, parameter ACCURACY = 0)
(
    input CLK,
    input [6 : 0] opcode,
    input [6 : 0] funct7,
    input [2 : 0] funct3,

    input [7 : 0] accuracy_level,

    input [31 : 0] rs1,
    input [31 : 0] rs2,

    output reg mul_unit_busy,
    output reg [31 : 0] mul_output
);

    // Data forwarding will be considered in the core file (phoeniX.v)
    reg  [31 : 0] operand_1; 
    reg  [31 : 0] operand_2;
    reg  [31 : 0] input_1;
    reg  [31 : 0] input_2;
    reg  [7  : 0] accuracy;
    wire [31 : 0] result;

    // Latching operands coming from data bus
    always @(*) begin
        operand_1 = rs1;
        operand_2 = rs2;
        accuracy = accuracy_level;
        // Checking if the multiplier is accuracy controlable or not
        if (APPROXIMATE == 1 && ACCURACY == 0)
        begin
            accuracy = 8'bz; // Multiplier is not accuracy controlable -> input signal = Z
        end
        else if (APPROXIMATE == 0 && ACCURACY == 0)
        begin
            accuracy = 8'bz; // Multiplier is not accuracy controlable -> input signal = Z
        end
        else if (APPROXIMATE == 0 && ACCURACY == 1)
        begin
            accuracy = 8'bz; // Multiplier is not accuracy controlable -> input signal = Z
        end
        // If the multiplier is accuracy controlable, the accuarcy will be extracted from CSRs.
        // The extracted accuracy level will be directly give to `accuracy_level` and `accuracy`
    end

    always @(*) 
    begin
        mul_output = result;
        mul_unit_busy = busy;
        casex ({funct7, funct3, opcode})
            17'b0000001_000_0110011 : begin  // MUL
                input_1 = $signed(operand_1);
                input_2 = $signed(operand_2);
            end
            17'b0000001_001_0110011 : begin  // MULH
                input_1 = $signed(operand_1);
                input_2 = $signed(operand_2);
                mul_output = mul_output >>> 32;
            end
            17'b0000001_010_0110011 : begin  // MULHSU
                input_1 = $signed(operand_1);
                input_2 = operand_2;
                mul_output = mul_output >>> 32;
            end
            17'b0000001_011_0110011 : begin  // MULHU
                input_1 = operand_1;
                input_2 = operand_2;
                mul_output = mul_output >> 32;
            end
            default: begin mul_output = 32'bz; mul_unit_busy = 1'bz; end // Wrong opcode                
        endcase
    end

    // *** Instantiate your multiplier here ***
    // Please instantiate your multiplier module using the guidelines and phoeniX naming conventions
    Sample_Multiplier mul (CLK, input_1, input_2, accuracy, busy, result);
    // *** End of multiplier instantiation ***

endmodule