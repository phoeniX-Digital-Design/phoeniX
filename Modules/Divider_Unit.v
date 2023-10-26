/*
    phoeniX RV32IMX Divider Unit: Developer Guidelines
    ==========================================================================================================================
    DEVELOPER NOTICE:
    - Kindly adhere to the established guidelines and naming conventions outlined in the project documentation. 
    - Following these standards will ensure smooth integration of your custom-made modules into this codebase.
    - Thank you for your cooperation.
    ==========================================================================================================================
    Divider Unit Unit Approximation CSR:
    - One adder circuit is used for 3 integer instructions: DIV/DIVU/REM/REMU
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
        Output: reamainder    = Module remainder output
        Output: busy          = Module busy signal
    ==========================================================================================================================
    - This unit executes R-Type instructions
    - Inputs `rs1`, `rs2` comes from `Register_File` (DATA BUS)
    - Input signals `opcode`, `funct3`, `funct7`, comes from `Instruction_Decoder`
    - Supported Instructions :
        R-TYPE :  DIV - DIVU - REM - REMU
*/

// *** Include your headers and modules here ***
// -----------------------------------------------------------------------------------
// `include "Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Divider.v"
// -----------------------------------------------------------------------------------
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
    output reg [31 : 0] div_output      // DIV Result (DIV/REM)
);

    // Data forwarding will be considered in the core file (phoeniX.v)
    reg  enable;

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
                enable  = 1'b1;
                input_1 = operand_1;
                input_2 = $signed(operand_2);
                div_output = result;
            end
            17'b0000001_101_0110011 : begin  // DIVU
                enable  = 1'b1;
                input_1 = operand_1;
                input_2 = operand_2;
                div_output = result;
            end
            17'b0000001_110_0110011 : begin  // REM
                enable  = 1'b1;
                input_1 = operand_1;
                input_2 = $signed(operand_2);
                div_output = remainder;
            end
            17'b0000001_111_0110011 : begin  // REMU
                enable  = 1'b1;
                input_1 = operand_1;
                input_2 = operand_2;
                div_output = $signed(remainder);
            end
            default: begin div_output = 32'bz; div_unit_busy = 1'bz; enable = 1'b0; end // Wrong opcode                
        endcase
    end

    always @(negedge div_unit_busy) enable <= 1'b0;

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

    // Add your custom divider circuit here ***
    // Please create your divider module according to the guidelines and naming conventions of phoeniX
    // ----------------------------------------------------------------------------------------------------
    module Approximate_Accuracy_Controlable_Divider
    (  
        input  CLK,                 // Clock signal

        input  [7  : 0] Er,         // Error rate

        input  [31 : 0] operand_1,  // Operand 1
        input  [31 : 0] operand_2,  // Operand 2

        output reg [31 : 0] div,    // Division result
        output reg [31 : 0] rem,    // Remainder
        output busy                 // = 1 while calculation
    );

        reg active;                 // True if the divider is running  
        reg [4  : 0] cycle;         // Number of cycles to go  
        reg [31 : 0] result;        // Begin with operand_1, end with division result  
        reg [31 : 0] denom;         // Second operand (operand_2)  
        reg [31 : 0] work;          // remunning remainder

        wire c_out;
        wire [31 : 0] sub_module;
        wire [32 : 0] sub;

        // Calculate the current digit
        Approximate_Accuracy_Controlable_Adder 
        #(
            .LEN(32),
            .APX_LEN(8)
        )
        approximate_subtract
        (
            .Er(Er),
            .A({work[30 : 0], result[31]}),
            .B(~denom),
            .Cin(1'b1),
            .Sum(sub_module),
            .Cout(c_out)
        );
        assign sub = {sub_module[31], sub_module}; // sign-extend

        wire [31 : 0] div_result;
        wire [31 : 0] rem_result;
        reg  [31 : 0] latched_div_result;
        reg  [31 : 0] latched_rem_result;
        
        always @(*) 
        begin
            if ((output_ready == 1) && (busy == 0))
            begin
                assign latched_div_result = div_result;  
                assign latched_rem_result = rem_result;
            end
        end
        always @(*) begin
            if ((output_ready == 1) && (busy == 0))
            begin
                div = latched_div_result;
                rem = latched_rem_result;
            end
        end

        assign div_result = result;
        assign rem_result = work;

        assign output_ready = ~active;
        assign busy = active;

        // The state machine  
        always @(posedge CLK) begin  
                if (active) 
                begin  
                    // remun an iteration of the divide.  
                    if (sub[32] == 0) 
                    begin  
                        work  <= sub[31 : 0];
                        result <= {result[30 : 0], 1'b1};
                    end  
                    else 
                    begin  
                        work <= {work[30 : 0], result[31]};
                        result <= {result[30 : 0], 1'b0};
                    end  
                    if (cycle == 0) begin active <= 0; end  
                    cycle <= cycle - 5'd1;  
                end
                else begin  
                    // Set up for an unsigned divide.  
                    cycle  <= 5'd31;  
                    result <= operand_1;  
                    denom  <= operand_2;  
                    work   <= 32'b0;  
                    active <= 1;  
                end  
            end  

    endmodule

    // --------------------------------------------------------------------------------------------------
    // *** End of divider module definition ***