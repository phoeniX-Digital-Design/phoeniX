/*
    phoeniX RV32IMX Multiplier: Designer Guidelines
    ==========================================================================================================================
    DESIGNER NOTICE:
    - Kindly adhere to the established guidelines and naming conventions outlined in the project documentation. 
    - Following these standards will ensure smooth integration of your custom-made modules into this codebase.
    - Thank you for your cooperation.
    ==========================================================================================================================
    Multiplier Approximation CSR:
    - MUL CSR is addressed as 0x801 in control status registers.
    - Multiplier circuit is used for 4 M-Extension instructions: MUL/MULH/MULHSU/MULHU
    - Internal signals are all generated according to phoeniX core "Self Control Logic" of the modules so designer won't 
      need to change anything inside this module (excepts parts which are considered for designers to instatiate their own 
      custom made designs).
    - Instantiate your modules (Approximate or Accurate) between the comments in the code.
    - How to work with the speical purpose CSR:
        CSR [0]       : APPROXIMATE = 1 | ACCURATE = 0
        CSR [2   : 1] : CIRCUIT_SELECT (Defined for switching between 4 accuarate or approximate circuits)
        CSR [7   : 3] : TRUNCATION_CONTROL
        CSR [11  : 8] : CUSTOM_FIELD_1
        CSR [15 : 12] : CUSTOM_FIELD_2
        CSR [31 : 16] : APPROXIMATION_ERROR_CONTROL
    - PLEASE DO NOT REMOVE ANY OF THE COMMENTS IN THIS FILE
    - Input and Output paramaters:
        Input:  clk           = Source clock signal
        Input:  control_status_register = {accuracy_control[USER_ERROR_LEN:3], accuracy_control[2:1] (module select), accuracy_control[0]}
        Input:  input_1       = First operand of your module
        Input:  input_2       = Second operand of your module
        Output: result        = Module division output
        Output: busy          = Module busy signal
    ==========================================================================================================================
*/

`include "Defines.v"

module Multiplier_Unit
#(
    parameter GENERATE_CIRCUIT_1 = 1,
    parameter GENERATE_CIRCUIT_2 = 0,
    parameter GENERATE_CIRCUIT_3 = 0,
    parameter GENERATE_CIRCUIT_4 = 0
)
(
    input wire clk, 

    input wire [ 6 : 0] opcode, 
    input wire [ 6 : 0] funct7,
    input wire [ 2 : 0] funct3, 

    input wire [31 : 0] control_status_register, 

    input wire [31 : 0] rs1, 
    input wire [31 : 0] rs2,  

    output reg multiplier_unit_busy, 
    output reg [31 : 0] multiplier_unit_output  
);

    reg  multiplier_enable;

    reg  [31 : 0] operand_1;            // RS1 latch
    reg  [31 : 0] operand_2;            // RS2 latch

    reg  [31 : 0] input_1;              // Modules input 1
    reg  [31 : 0] input_2;              // Modules input 2

    reg  [ 6 : 0] multiplier_accuracy;
    reg  [31 : 0] multiplier_input_1;   // Latched modules input 1
    reg  [31 : 0] multiplier_input_2;   // Latched modules input 2

    reg multiplier_busy;                
    wire [63 : 0] result;               

    reg  multiplier_0_enable;
    reg  multiplier_1_enable;
    reg  multiplier_2_enable;
    reg  multiplier_3_enable;

    wire [63 : 0] multiplier_0_result;
    wire [63 : 0] multiplier_1_result;
    wire [63 : 0] multiplier_2_result;
    wire [63 : 0] multiplier_3_result;

    wire multiplier_0_busy;
    wire multiplier_1_busy;
    wire multiplier_2_busy;
    wire multiplier_3_busy;

    always @(*) 
    begin
        operand_1 = rs1;
        operand_2 = rs2;
        case ({funct7, funct3, opcode})
            {`MULDIV, `MUL, `OP} : 
            begin
                multiplier_enable  = 1'b1;
                input_1 = $signed(operand_1);
                input_2 = $signed(operand_2);
                multiplier_unit_output = result[31 : 0];
            end
            {`MULDIV, `MULH, `OP} : 
            begin 
                multiplier_enable  = 1'b1;
                input_1 = $signed(operand_1);
                input_2 = $signed(operand_2);
                multiplier_unit_output = result >>> 32;
            end
            {`MULDIV, `MULHSU, `OP} : 
            begin
                multiplier_enable  = 1'b1;
                input_1 = $signed(operand_1);
                input_2 = operand_2;
                multiplier_unit_output = result >>> 32;
            end
            {`MULDIV, `MULHU, `OP} : 
            begin
                multiplier_enable  = 1'b1;
                input_1 = operand_1;
                input_2 = operand_2;
                multiplier_unit_output = result >> 32;
            end
            default: 
            begin
                multiplier_unit_output = 32'bz; 
                multiplier_enable   = 1'b0; 
                multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0;
                multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0;
            end             
        endcase
    end

    always @(*) multiplier_unit_busy = multiplier_enable; 
    always @(negedge multiplier_busy) 
    begin
        multiplier_enable <= 1'b0;
        multiplier_input_1 <= 32'bz;
        multiplier_input_2 <= 32'bz;
        multiplier_accuracy <= 7'bz;
    end
    always @(posedge multiplier_enable) 
    begin
        multiplier_input_1 <= input_1;
        multiplier_input_2 <= input_2;
        multiplier_accuracy <= control_status_register[9 : 3] | {7{~control_status_register[0]}};
        case (control_status_register[2 : 1])
            2'b00:   begin multiplier_0_enable = 1'b1; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
            2'b01:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b1; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
            2'b10:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b1; multiplier_3_enable = 1'b0; end
            2'b11:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b1; end 
            default: begin multiplier_0_enable = 1'b1; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
        endcase
    end

    assign result = (multiplier_0_enable) ? multiplier_0_result :
                    (multiplier_1_enable) ? multiplier_1_result :
                    (multiplier_2_enable) ? multiplier_2_result :
                    (multiplier_3_enable) ? multiplier_3_result : multiplier_0_result;
  
    always @(*) 
    begin
        if (multiplier_0_enable)
            multiplier_busy <= multiplier_0_busy;
        else if (multiplier_1_enable)
            multiplier_busy <= multiplier_1_busy;
        else if (multiplier_2_enable)
            multiplier_busy <= multiplier_2_busy;
        else if (multiplier_3_enable)
            multiplier_busy <= multiplier_3_busy;
        else
            multiplier_busy <= 1'b0; 
    end

    // *** Instantiate your multiplier circuit here ***
    // Please instantiate your multiplier module according to the guidelines and naming conventions of phoeniX
    // -------------------------------------------------------------------------------------------------------
    generate 
        if (GENERATE_CIRCUIT_1)
        begin
            // Circuit 1 (default) instantiation
            //----------------------------------
            Approximate_Accuracy_Controllable_Multiplier approximate_accuracy_controllable_multiplier 
            (
                .clk(clk),
                .enable(multiplier_0_enable),
                .Er(multiplier_accuracy),
                .Operand_1(multiplier_input_1), 
                .Operand_2(multiplier_input_2),  
                .Result(multiplier_0_result),
                .Busy(multiplier_0_busy)
            );
            //----------------------------------
            // End of Circuit 1 instantiation
        end
        if (GENERATE_CIRCUIT_2)
        begin
            // Circuit 2 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 2 instantiation
        end
        if (GENERATE_CIRCUIT_3)
        begin
            // Circuit 3 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 3 instantiation
        end
        if (GENERATE_CIRCUIT_4)
        begin
            // Circuit 4 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 4 instantiation
        end
    endgenerate
    // -------------------------------------------------------------------------------------------------------
    // *** End of multiplier module instantiation ***
endmodule

// Add your custom multilpier circuit here ***
// Please create your multilpier module according to the guidelines and naming conventions of phoeniX
// --------------------------------------------------------------------------------------------------------
module Approximate_Accuracy_Controllable_Multiplier 
(
    input wire clk,
    input wire enable,

    input wire [ 6 : 0] Er,
    input wire [31 : 0] Operand_1,
    input wire [31 : 0] Operand_2,

    output reg [63 : 0] Result,
    output reg Busy
);
    
    wire [31 : 0] Partial_Product [0 : 3];
    wire Partial_Busy [0 : 3];

    Approximate_Accuracy_Controllable_Multiplier_16bit multiplier_LOWxLOW
    (
        .clk(clk),
        .enable(enable),

        .Er(Er),
        .Operand_1(Operand_1[15 : 0]),
        .Operand_2(Operand_2[15 : 0]),

        .Result(Partial_Product[0]),
        .Busy(Partial_Busy[0])
    );

    Approximate_Accuracy_Controllable_Multiplier_16bit multiplier_HIGHxLOW
    (
        .clk(clk),
        .enable(enable),

        .Er({7{1'b1}}),
        .Operand_1(Operand_1[31 : 16]),
        .Operand_2(Operand_2[15 :  0]),

        .Result(Partial_Product[1]),
        .Busy(Partial_Busy[1])
    );

    Approximate_Accuracy_Controllable_Multiplier_16bit multiplier_LOWxHIGH
    (
        .clk(clk),
        .enable(enable),

        .Er({7{1'b1}}),
        .Operand_1(Operand_1[15 :  0]),
        .Operand_2(Operand_2[31 : 16]),

        .Result(Partial_Product[2]),
        .Busy(Partial_Busy[2])
    );

    Approximate_Accuracy_Controllable_Multiplier_16bit multiplier_HIGHxHIGH
    (
        .clk(clk),
        .enable(enable),

        .Er({7{1'b1}}),
        .Operand_1(Operand_1[31 : 16]),
        .Operand_2(Operand_2[31 : 16]),

        .Result(Partial_Product[3]),
        .Busy(Partial_Busy[3])
    );

    always @(*) 
    begin
        Result = {32'b0, Partial_Product[0]} + {16'b0, Partial_Product[1], 16'b0} + {16'b0, Partial_Product[2], 16'b0} + {Partial_Product[3], 32'b0};
        Busy = &{Partial_Busy[0], Partial_Busy[1], Partial_Busy[2], Partial_Busy[3]};
    end
endmodule

module Approximate_Accuracy_Controllable_Multiplier_16bit 
(
    input wire clk,
    input wire enable,

    input wire [ 6 : 0] Er,
    input wire [15 : 0] Operand_1,
    input wire [15 : 0] Operand_2,

    output reg [31 : 0] Result,
    output reg Busy
);

    reg     [ 7 : 0] mul_input_1;
    reg     [ 7 : 0] mul_input_2;
    wire    [15 : 0] mul_result;

    reg     [15 : 0] partial_result_1;
    reg     [15 : 0] partial_result_2;
    reg     [15 : 0] partial_result_3;
    reg     [15 : 0] partial_result_4;

    Approximate_Accuracy_Controllable_Multiplier_8bit mul
    (
        .Er(Er),
        .Operand_1(mul_input_1),
        .Operand_2(mul_input_2),
        .Result(mul_result)
    );

    reg [2 : 0] state;
    reg [2 : 0] next_state;

    always @(posedge clk) 
    begin
        if (~enable)    state <= 3'b000;
        else            state <= next_state;
    end

    always @(*) 
    begin
        next_state = 'bz;
       
        case (state)
            3'b000 : 
            begin 
                mul_input_1 <= 'bz; 
                mul_input_2 <= 'bz; 
                
                partial_result_1 <= 'bz; 
                partial_result_2 <= 'bz; 
                partial_result_3 <= 'bz; 
                partial_result_4 <= 'bz; 
                
                Busy <= 1'b0; 
                next_state <= 3'b001; 
            end
            3'b001 : begin mul_input_1 <= Operand_1[ 7 : 0]; mul_input_2 <= Operand_2[ 7 : 0]; partial_result_1 <= mul_result; next_state <= 3'b010; Busy <= 1'b1; end
            3'b010 : begin mul_input_1 <= Operand_1[15 : 8]; mul_input_2 <= Operand_2[ 7 : 0]; partial_result_2 <= mul_result; next_state <= 3'b011; end
            3'b011 : begin mul_input_1 <= Operand_1[ 7 : 0]; mul_input_2 <= Operand_2[15 : 8]; partial_result_3 <= mul_result; next_state <= 3'b100; end
            3'b100 : begin mul_input_1 <= Operand_1[15 : 8]; mul_input_2 <= Operand_2[15 : 8]; partial_result_4 <= mul_result; next_state <= 3'b101; end
            3'b101 : 
            begin 
                Result =    {16'b0, partial_result_1} +
                            {8'b0,  partial_result_2, 8'b0} +
                            {8'b0,  partial_result_3, 8'b0} +
                            {partial_result_4, 16'b0}; 

                next_state <= 3'b000; 
                Busy <= 1'b0;
            end
        endcase 
    end
endmodule

module Approximate_Accuracy_Controllable_Multiplier_8bit
(
    input [6 : 0] Er,
    input [7 : 0] Operand_1,
    input [7 : 0] Operand_2,

    output [15 : 0] Result
);
    
    wire [7 : 0] PP [1 : 8];

    generate
        for (genvar i = 1; i < 9; i = i + 1)
        begin
            assign PP[i] = {8{Operand_2[i - 1]}} & Operand_1;
        end
    endgenerate

    // Stage 1 -  ATC_8 wires and instantiation
    wire [8 : 0] P1;
    wire [8 : 0] P2;
    wire [8 : 0] P3;
    wire [8 : 0] P4;

    wire [14 : 0] V1;

    ATC_8 atc_8 (PP[1], PP[2], PP[3], PP[4], PP[5], PP[6], PP[7], PP[8], P1, P2, P3, P4, V1);

    // Stage 1 - ATC_4 wires and instantiation
    wire [10 : 0] P5;
    wire [10 : 0] P6;

    wire [14 : 0] V2;

    ATC_4 atc_4 (P1, P2, P3, P4, P5, P6, V2);

    // Stage 1 - Final row of iCACs (ATC_2)

    wire [14 : 0] P7;
    wire [14 : 0] Q7;

    iCAC #(11, 4) iCAC_7 (P5, P6, P7, Q7);

    // Stage 2

    wire [10 : 4] ORed_PPs = V1 [10 : 4] | V2 [10 : 4];

    // Stage 3

    wire [14 : 0] SumSignal, CarrySignal;

    assign SumSignal[0] = P7[0];
    assign CarrySignal[0] = 0;
    assign CarrySignal[1] = 0;

    Half_Adder_Mul HA_1 (P7[1], V1[1], SumSignal[1], CarrySignal[2]);
    
    Full_Adder_Mul FA_1 (P7[2], V1[2], V2[2], SumSignal[2], CarrySignal[3]);
    Full_Adder_Mul FA_2 (P7[3], V1[3], V2[3], SumSignal[3], CarrySignal[4]);

    Full_Adder_Mul FA_3 (P7[4], Q7[4], ORed_PPs[4], SumSignal[4], CarrySignal[5]);
    Full_Adder_Mul FA_4 (P7[5], Q7[5], ORed_PPs[5], SumSignal[5], CarrySignal[6]);
    Full_Adder_Mul FA_5 (P7[6], Q7[6], ORed_PPs[6], SumSignal[6], CarrySignal[7]);
    Full_Adder_Mul FA_6 (P7[7], Q7[7], ORed_PPs[7], SumSignal[7], CarrySignal[8]);
    Full_Adder_Mul FA_7 (P7[8], Q7[8], ORed_PPs[8], SumSignal[8], CarrySignal[9]);
    Full_Adder_Mul FA_8 (P7[9], Q7[9], ORed_PPs[9], SumSignal[9], CarrySignal[10]);
    Full_Adder_Mul FA_9 (P7[10], Q7[10], ORed_PPs[10], SumSignal[10], CarrySignal[11]);

    Full_Adder_Mul FA_10 (P7[11], V1[11], V2[11], SumSignal[11], CarrySignal[12]);
    Full_Adder_Mul FA_11 (P7[12], V1[12], V2[12], SumSignal[12], CarrySignal[13]);

    Half_Adder_Mul HA_2 (P7[13], V1[13], SumSignal[13], CarrySignal[14]);

    assign SumSignal[14] = P7[14];

    // Stage 4

    assign Result[0] = SumSignal[0];
    assign Result[1] = SumSignal[1];

    assign Result[2] = SumSignal[2] | CarrySignal[2];
    assign Result[3] = SumSignal[3] | CarrySignal[3];
    assign Result[4] = SumSignal[4] | CarrySignal[4];

    wire [13 : 5] inter_Carry;
    
    Error_Configurable_Full_Adder_Mul ECA_FA_1 (Er[0], SumSignal[5], CarrySignal[5], 1'b0, Result[5], inter_Carry[5]);
    
    Error_Configurable_Full_Adder_Mul ECA_FA_2 (Er[1], SumSignal[6], CarrySignal[6], inter_Carry[5], Result[6], inter_Carry[6]);
    Error_Configurable_Full_Adder_Mul ECA_FA_3 (Er[2], SumSignal[7], CarrySignal[7], inter_Carry[6], Result[7], inter_Carry[7]);
    Error_Configurable_Full_Adder_Mul ECA_FA_4 (Er[3], SumSignal[8], CarrySignal[8], inter_Carry[7], Result[8], inter_Carry[8]);
    Error_Configurable_Full_Adder_Mul ECA_FA_5 (Er[4], SumSignal[9], CarrySignal[9], inter_Carry[8], Result[9], inter_Carry[9]);
    Error_Configurable_Full_Adder_Mul ECA_FA_6 (Er[5], SumSignal[10], CarrySignal[10], inter_Carry[9], Result[10], inter_Carry[10]);
    Error_Configurable_Full_Adder_Mul ECA_FA_7 (Er[6], SumSignal[11], CarrySignal[11], inter_Carry[10], Result[11], inter_Carry[11]);


    Full_Adder_Mul FA_12 (SumSignal[12], CarrySignal[12], inter_Carry[11], inter_Carry[12], Result[12]);
    Full_Adder_Mul FA_13 (SumSignal[13], CarrySignal[13], inter_Carry[12], inter_Carry[13], Result[13]);
    Full_Adder_Mul FA_14 (SumSignal[14], CarrySignal[14], inter_Carry[13], Result[15], Result[14]);
endmodule

module iCAC 
#(
    parameter WIDTH = 8, 
    parameter SHIFT_BITS = 1
) 
(
    input [WIDTH - 1 : 0] D1,
    input [WIDTH - 1 : 0] D2,

    output [WIDTH + SHIFT_BITS - 1 : 0] P,
    output [WIDTH + SHIFT_BITS - 1 : 0] Q
);
    assign P [SHIFT_BITS - 1 : 0] = D1 [SHIFT_BITS - 1 : 0];
    assign Q [SHIFT_BITS - 1 : 0] = 0;

    wire [WIDTH + SHIFT_BITS - 1 : 0] D2_Shifted  = D2 << SHIFT_BITS;
    assign P [WIDTH + SHIFT_BITS - 1 : WIDTH] = D2_Shifted [WIDTH + SHIFT_BITS - 1 : WIDTH];
    assign Q [WIDTH + SHIFT_BITS - 1 : WIDTH] = 0;

    assign P[WIDTH - 1 : SHIFT_BITS] = D1[WIDTH - 1 : SHIFT_BITS] | D2_Shifted[WIDTH - 1 : SHIFT_BITS];
    assign Q[WIDTH - 1 : SHIFT_BITS] = D1[WIDTH - 1 : SHIFT_BITS] & D2_Shifted[WIDTH - 1 : SHIFT_BITS];
endmodule

module Error_Configurable_Full_Adder_Mul
(
    input Er,
    input A,
    input B, 
    input Cin,

    output Sum, 
    output Cout
);
    assign Sum = ~(Er && (A ^ B) && Cin) && ((A ^ B) || Cin);
    assign Cout = (Er && B && Cin) || ((B || Cin) && A);
endmodule

module Full_Adder_Mul 
(
    input A,
    input B,
    input Cin,

    output Sum,
    output Cout
);
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A && B) || (A && Cin) || (B && Cin); 
endmodule

module Half_Adder_Mul 
(
    input A,
    input B, 
    output Sum, 
    output Cout
);
    assign Sum = A ^ B;
    assign Cout = A & B;
endmodule

module ATC_4 
(
    input [8 : 0] P1,
    input [8 : 0] P2,
    input [8 : 0] P3,
    input [8 : 0] P4,

    output [10 : 0] P5,
    output [10 : 0] P6,

    output [14 : 0] V2
);

    wire [10 : 0] Q5;
    wire [10 : 0] Q6;

    iCAC #(9, 2) iCAC_5 (P1, P2 , P5, Q5);
    iCAC #(9, 2) iCAC_6 (P3, P4 , P6, Q6);

    assign V2 = Q5 | Q6 << 4;
endmodule

module ATC_8 
(
    input [7 : 0] PP_1,
    input [7 : 0] PP_2,
    input [7 : 0] PP_3,
    input [7 : 0] PP_4,
    input [7 : 0] PP_5,
    input [7 : 0] PP_6,
    input [7 : 0] PP_7,
    input [7 : 0] PP_8,

    output [8 : 0] P1,
    output [8 : 0] P2,
    output [8 : 0] P3,
    output [8 : 0] P4,

    output [14 : 0] V1
);

    wire [8 : 0] Q1;
    wire [8 : 0] Q2;
    wire [8 : 0] Q3;
    wire [8 : 0] Q4;

    iCAC #(8, 1) iCAC_1 (PP_1, PP_2, P1, Q1);
    iCAC #(8, 1) iCAC_2 (PP_3, PP_4, P2, Q2);
    iCAC #(8, 1) iCAC_3 (PP_5, PP_6, P3, Q3);
    iCAC #(8, 1) iCAC_4 (PP_7, PP_8, P4, Q4);

    assign V1 = Q1 | Q2 << 2 | Q3 << 4 | Q4 << 6;
endmodule

// --------------------------------------------------------------------------------------------------
// *** End of multiplier module definition ***