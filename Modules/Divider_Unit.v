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
        Input:  clk = Source clock signal
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

`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif /*OPCODES*/

`define DIV     3'b000
`define DIVU    3'b001
`define REM     3'b010
`define REMU    3'b011 

`define MULDIV  7'b0000001

module Divider_Unit
(
    input clk,                          // Source clock signal

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
        case ({funct7, funct3, opcode})
            {`MULDIV, `DIV, `OP} : begin  // DIV
                enable  = 1'b1;
                input_1 = operand_1;
                input_2 = $signed(operand_2);
                div_output = result;
            end
            {`MULDIV, `DIVU, `OP} : begin  // DIVU
                enable  = 1'b1;
                input_1 = operand_1;
                input_2 = operand_2;
                div_output = result;
            end
            {`MULDIV, `REM, `OP} : begin  // REM
                enable  = 1'b1;
                input_1 = operand_1;
                input_2 = $signed(operand_2);
                div_output = remainder;
            end
            {`MULDIV, `REMU, `OP} : begin  // REMU
                enable  = 1'b1;
                input_1 = operand_1;
                input_2 = operand_2;
                div_output = $signed(remainder);
            end
            default: begin div_output = 32'bz; div_unit_busy = 1'b0; enable = 1'b0; end // Wrong opcode                
        endcase
    end

    always @(negedge div_unit_busy) enable <= 1'b0;

    // *** Instantiate your divider here ***
    // Please instantiate your divider module according to the guidelines and naming conventions of phoeniX
    // ----------------------------------------------------------------------------------------------------
    Approximate_Accuracy_Controlable_Divider divider 
    (
        .clk(clk),
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
    input  clk,                 // Clock signal

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
    Approximate_Accuracy_Controlable_Adder_Div 
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
    always @(*) 
    begin
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
    always @(posedge clk) 
    begin  
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
        else
        begin  
            // Set up for an unsigned divide.  
            cycle  <= 5'd31;  
            result <= operand_1;  
            denom  <= operand_2;  
            work   <= 32'b0;  
            active <= 1;  
        end  
    end  
endmodule

module Approximate_Accuracy_Controlable_Adder_Div 
#(
    parameter LEN = 32,
    parameter APX_LEN = 8         // Valid Options for APX_LEN : 4, 8, 12, 16, ...
)
(
    input [APX_LEN - 1 : 0] Er,
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);

    wire [LEN - 1 : 0] C;
    
    ////////////////////
    //    [3 : 0]     //
    ////////////////////

    Error_Configurable_Ripple_Carry_Adder_Div #(.LEN(4)) EC_RCA_1 
    (
        .Er(Er[3  : 0]),
        .A(A[3 : 0]), 
        .B(B[3 : 0]), 
        .Cin(Cin), 
        .Sum(Sum[3 : 0]), 
        .Cout(C[3])
    );
    
    ////////////////////
    //    [31 : 4]    //
    ////////////////////

    genvar i;
    generate
        
        // ------------------- //
        // Approximate Circuit //
        // ------------------- //

        for (i = 4; i < APX_LEN; i = i + 4)
        begin
            wire HA_Carry;
            wire EC_RCA_Carry;
            wire [i + 3 : i] EC_RCA_Output;

            Half_Adder_Div HA
            (
                .A(A[i]), 
                .B(B[i]),
                .Sum(EC_RCA_Output[i]),
                .Cout(HA_Carry)
            );

            Error_Configurable_Ripple_Carry_Adder_Div
            #(
                .LEN(3)
            )
            EC_RCA
            (
                .Er(Er[i + 3 : i + 1]),
                .A(A[i + 3 : i + 1]), 
                .B(B[i + 3 : i + 1]), 
                .Cin(HA_Carry),
                .Sum(EC_RCA_Output[i + 3 : i + 1]),
                .Cout(EC_RCA_Carry)
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit_Div BU_1 (.A(EC_RCA_Output), .B(BU_Output), .C0(BU_Carry));

            Mux_2to1_Div 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1({EC_RCA_Carry, EC_RCA_Output}),
                .data_in_2({BU_Carry || EC_RCA_Carry, BU_Output}),
                .select(C[i - 1]),
                .data_out({C[i + 3], Sum[i + 3 : i]})
            );
        end
        
        // ------------- //
        // Exact Circuit //
        // ------------- //

        for (i = APX_LEN; i < LEN; i = i + 4)
        begin
            wire HA_Carry;
            wire RCA_Carry;
            wire [i + 3 : i] RCA_Output;

            Half_Adder_Div HA
            (
                .A(A[i]), 
                .B(B[i]),
                .Sum(RCA_Output[i]),
                .Cout(HA_Carry)
            );

            Ripple_Carry_Adder_Div
            #(
                .LEN(3)
            )
            RCA
            (
                .A(A[i + 3 : i + 1]), 
                .B(B[i + 3 : i + 1]), 
                .Cin(HA_Carry),
                .Sum(RCA_Output[i + 3 : i + 1]),
                .Cout(RCA_Carry)
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit_Div BU_1 (.A(RCA_Output), .B(BU_Output), .C0(BU_Carry));

            Mux_2to1_Div 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1({RCA_Carry, RCA_Output}),
                .data_in_2({BU_Carry || RCA_Carry, BU_Output}),
                .select(C[i - 1]),
                .data_out({C[i + 3], Sum[i + 3 : i]})
            );
        end

    endgenerate
    
    assign Cout = C[LEN - 1];
endmodule

module Basic_Unit_Div 
(
    input  [3 : 0] A,
    output [4 : 1] B,
    output C0
);

    assign B[1] =  ~A[0];
    assign B[2] = A[1] ^ A[0];
    wire C1 = A[1] & A[0];
    wire C2 = A[2] & A[3];
    wire C0 = C1 & C2;
    wire C3 = C1 & A[2];
    assign B[3] = A[2] ^ C1;
    assign B[4] = A[3] ^ C3;

endmodule

module Mux_2to1_Div
#(
    parameter LEN = 5
) 
(
    input [LEN - 1 : 0] data_in_1,        
    input [LEN - 1 : 0] data_in_2,        
    input select,                   

    output reg [LEN - 1: 0] data_out            
);

    always @(*) 
    begin
        case (select)
            1'b0: begin data_out = data_in_1; end
            1'b1: begin data_out = data_in_2; end
            default: begin data_out = {LEN{1'bz}}; end
        endcase
    end
endmodule

module Error_Configurable_Ripple_Carry_Adder_Div 
#(
    parameter LEN = 4
) 
(
    input [LEN - 1 : 0] Er,
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);
    wire [LEN : 0] Carry;
    assign Carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Error_Configurable_Full_Adder_Div ECFA 
            (
                .Er(Er[i]),
                .A(A[i]), 
                .B(B[i]), 
                .Cin(Carry[i]), 
                .Sum(Sum[i]), 
                .Cout(Carry[i + 1])
            );
        end
    assign Cout = Carry[LEN];
    endgenerate
endmodule

module Ripple_Carry_Adder_Div 
#(
    parameter LEN = 4
) 
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);
    wire [LEN : 0] Carry;
    assign Carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Full_Adder_Div FA 
            (
                .A(A[i]), 
                .B(B[i]), 
                .Cin(Carry[i]), 
                .Sum(Sum[i]), 
                .Cout(Carry[i + 1])
            );
        end
    assign Cout = Carry[LEN];
    endgenerate
endmodule

module Error_Configurable_Full_Adder_Div
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

module Full_Adder_Div 
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

module Half_Adder_Div 
(
    input A,
    input B, 
    output Sum, 
    output Cout
);
    assign Sum = A ^ B;
    assign Cout = A & B;
endmodule

// ----------------------------------------------------------------------------------------------------
// *** End of divider module definition ***