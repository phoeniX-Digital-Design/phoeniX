/*
    phoeniX RV32IMX Multiplier: Developer Guidelines
    ==========================================================================================================================
    DEVELOPER NOTICE:
    - Kindly adhere to the established guidelines and naming conventions outlined in the project documentation. 
    - Following these standards will ensure smooth integration of your custom-made modules into this codebase.
    - Thank you for your cooperation.
    ==========================================================================================================================
    Multiplier Approximation CSR:
    - Multiplier circuit is used for 4 M-Extension instructions: MUL/MULH/MULHSU/MULHU
    - Internal signals are all generated according to phoeniX core "Self Control Logic" of the modules so developer won't 
      need to change anything inside this module (excepts parts which are considered for developers to instatiate their own 
      custom made designs).
    - Instantiate your modules (Approximate or Accurate) between the comments in the code.
    - How to work with the speical purpose CSR:
        CSR [0]      : APPROXIMATE = 1 | ACCURATE = 0
        CSR [2  : 1] : CIRCUIT_SELECT (Defined for switching between 4 accuarate and approximate circuits)
        CSR [31 : 3] : APPROXIMATION_ERROR_CONTROL
    - PLEASE DO NOT REMOVE ANY OF THE COMMENTS IN THIS FILE
    - Input and Output paramaters:
        Input:  CLK = Source clock signal
        Input:  error_control = {accuracy_control[USER_ERROR_LEN:3], accuracy_control[2:1] (module select), accuracy_control[0]}
        Input:  input_1       = First operand of your module
        Input:  input_2       = Second operand of your module
        Output: result        = Module division output
        Output: busy          = Module busy signal
    ==========================================================================================================================
*/

// *** Include your headers and modules here ***
`include "../Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Multiplier.v"
// *** End of including headers and modules ***

module Multiplier_Unit
(
    input CLK,                          // Source Clock Signal

    // input enable,

    input [6 : 0] opcode,               // ALU Operation
    input [6 : 0] funct7,               // ALU Operation
    input [2 : 0] funct3,               // ALU Operation

    input [31 : 0] accuracy_control,    // Approximation Control Register

    input [31 : 0] rs1,                 // Register Source 1
    input [31 : 0] rs2,                 // Register Source 2

    output reg mul_unit_busy,           // For Multiplier Unit Condition Checking
    output reg [31 : 0] mul_output      // Multiplier Unit Result
);

    // Data forwarding will be considered in the core file (top = phoeniX.v)
    reg  enable;

    reg  [31 : 0] operand_1;            // Bus RS1 latch
    reg  [31 : 0] operand_2;            // Bus RS2 latch

    reg  [31 : 0] input_1;              // Module input 1
    reg  [31 : 0] input_2;              // Module input 2

    wire [63 : 0] result;               // Multiplier 64-bit result

    always @(*) 
    begin
        operand_1 = rs1;
        operand_2 = rs2;
        mul_output = result;        // Low-word (32-bit) of 64-bit result
        mul_unit_busy = ~n_busy;    // NOT [Ready] = Unit Busy
        casex ({funct7, funct3, opcode})
            17'b0000001_000_0110011 : begin  // MUL
                enable  = 1'b1;
                input_1 = $signed(operand_1);
                input_2 = $signed(operand_2);
            end
            17'b0000001_001_0110011 : begin  // MULH
                enable  = 1'b1;
                input_1 = $signed(operand_1);
                input_2 = $signed(operand_2);
                mul_output = mul_output >>> 32;
            end
            17'b0000001_010_0110011 : begin  // MULHSU
                enable  = 1'b1;
                input_1 = $signed(operand_1);
                input_2 = operand_2;
                mul_output = mul_output >>> 32;
            end
            17'b0000001_011_0110011 : begin  // MULHU
                enable  = 1'b1;
                input_1 = operand_1;
                input_2 = operand_2;
                mul_output = mul_output >> 32;
            end
            default: begin enable  = 1'b0; mul_output = 32'bz; mul_unit_busy = 1'bz; end // Wrong opcode             
        endcase
        if (multiplier.Ready == 1'b1) begin enable = 1'b0; end
    end

    // *** Instantiate your multiplier circuit here ***
    // Please instantiate your multiplier module according to the guidelines and naming conventions of phoeniX
    // -------------------------------------------------------------------------------------------------------
    Approximate_Accuracy_Controlable_Multiplier multiplier 
    (
        .CLK(CLK),
        .enable(enable),
        .Er(accuracy_control[9 : 3] | {7{~accuracy_control[0]}}),
        .Operand_1(input_1), 
        .Operand_2(input_2),  
        .Result(result),
        .Ready(n_busy)
    );
    // -------------------------------------------------------------------------------------------------------
    // *** End of multiplier module instantiation ***

endmodule