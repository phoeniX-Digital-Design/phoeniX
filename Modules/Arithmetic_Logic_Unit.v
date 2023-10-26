/*
    phoeniX RV32IMX ALU: Developer Guidelines
    ==========================================================================================================================
    DEVELOPER NOTICE:
    - Kindly adhere to the established guidelines and naming conventions outlined in the project documentation. 
    - Following these standards will ensure smooth integration of your custom-made modules into this codebase.
    - Thank you for your cooperation.
    ==========================================================================================================================
    ALU Approximation CSR:
    - One adder circuit is used for 3 integer instructions: ADD/ADDI/SUB
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
        Input:  error_control = {accuracy_control[USER_ERROR_LEN:3], accuracy_control[2:1] (module select), accuracy_control[0]}
        Input:  adder_input_1 = First operand of your module
        Input:  adder_input_2 = Second operand of your module
        Input:  adder_Cin     = Input Carry
        Output: adder_result  = Module output
    ==========================================================================================================================
    - This unit executes R-Type, I-Type and J-Type instructions
    - Inputs `rs1`, `rs2` comes from `Register_File` (DATA BUS)
    - Input `immediate` comes from `Immediate_Generator`
    - Input signals `opcode`, `funct3`, `funct7`, comes from `Instruction_Decoder`
    - Supported Instructions :
        I-TYPE : ADDI - SLTI - SLTIU            R-TYPE : ADD  - SUB  - SLL           
                 XORI - ORI  - ANDI                      SLT  - SLTU - XOR                         
                 SLLI - SRLI - SRAI                      SRL  - SRA  - OR  - AND
        J-TYPE : JAL  - JALR                    U-TYPE : AUIPC         
*/

// *** Include your header files and modules here ***
// ---------------------------------------------------------------------------------
// `include "Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Adder.v"
// ---------------------------------------------------------------------------------
// *** End of including header files and modules ***

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
`endif

module Arithmetic_Logic_Unit
(
    input [6 : 0] opcode,               // ALU Operation
    input [2 : 0] funct3,               // ALU Operation
    input [6 : 0] funct7,               // ALU Operation

    input [31 : 0] accuracy_control,    // Approximation Control Register

    input [31 : 0] PC,                  // Program Counter Register
    input [31 : 0] rs1,                 // Register Source 1
    input [31 : 0] rs2,                 // Register Source 2
    input [31 : 0] immediate,           // Immediate Source

    output reg [31 : 0] alu_output      // ALU Result
);

    reg  [31 : 0] operand_1; 
    reg  [31 : 0] operand_2;

    reg adder_Cin;
    reg  [31 : 0] adder_input_1;
    reg  [31 : 0] adder_input_2;
    
    wire [31 : 0] adder_result;

    reg         mux1_select;
    reg [1 : 0] mux2_select;

    // ALU multiplexers signals evaluation
    always @(*) 
    begin
        case (opcode)
        `OP     : begin mux1_select = 1'b0; mux2_select = 2'b00; end // R-TYPE 
        `OP_IMM : begin mux1_select = 1'b0; mux2_select = 2'b01; end // I-TYPE 
        `JALR   : begin mux1_select = 1'b1; mux2_select = 2'b10; end // JALR   
        `JAL    : begin mux1_select = 1'b1; mux2_select = 2'b10; end // JAL    
        `AUIPC  : begin mux1_select = 1'b1; mux2_select = 2'b01; end // AUIPC
        endcase        
    end
    
    // ALU Multiplexer 1
    always @(*) 
    begin
        case (mux1_select)
            1'b0 : operand_1 = rs1;
            1'b1 : operand_1 = PC;
        endcase
    end
    
    // ALU Multiplexer 2
    always @(*) 
    begin
        case (mux2_select)
            2'b00 : operand_2 = rs2;
            2'b01 : operand_2 = immediate;
            2'b10 : operand_2 = 4;
        endcase
    end

    // ----------------------------------------- //
    // Logical, Jump and PC Control Instrcutions //
    // ----------------------------------------- //
    always @(*)
    begin
        casex ({funct7, funct3, opcode})
            // I-TYPE Intructions
            {7'b0_000_000, 3'b001, `OP_IMM} : alu_output = operand_1 << operand_2 [4 : 0];                      // SLLI
            {7'bx_xxx_xxx, 3'b010, `OP_IMM} : alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;     // SLTI
            {7'bx_xxx_xxx, 3'b011, `OP_IMM} : alu_output = operand_1 < operand_2 ? 1 : 0;                       // SLTIU
            {7'bx_xxx_xxx, 3'b100, `OP_IMM} : alu_output = operand_1 ^ operand_2;                               // XORI
            {7'b0_000_000, 3'b101, `OP_IMM} : alu_output = operand_1 >> operand_2 [4 : 0];                      // SRLI
            {7'b0_100_000, 3'b101, `OP_IMM} : alu_output = operand_1 >> $signed(operand_2 [4 : 0]);             // SRAI
            {7'bx_xxx_xxx, 3'b110, `OP_IMM} : alu_output = operand_1 | operand_2;                               // ORI
            {7'bx_xxx_xxx, 3'b111, `OP_IMM} : alu_output = operand_1 & operand_2;                               // ANDI
            
            // R-TYPE Instructions
            {7'b0_000_000, 3'b001, `OP}     : alu_output = operand_1 << operand_2;                              // SLL
            {7'b0_000_000, 3'b010, `OP}     : alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;     // SLT
            {7'b0_000_000, 3'b011, `OP}     : alu_output = operand_1 < operand_2 ? 1 : 0;                       // SLTU
            {7'b0_000_000, 3'b100, `OP}     : alu_output = operand_1 ^ operand_2;                               // XOR
            {7'b0_000_000, 3'b101, `OP}     : alu_output = operand_1 >> operand_2;                              // SRL
            {7'b0_100_000, 3'b101, `OP}     : alu_output = operand_1 >> $signed(operand_2);                     // SRA
            {7'b0_000_000, 3'b110, `OP}     : alu_output = operand_1 | operand_2;                               // OR
            {7'b0_000_000, 3'b111, `OP}     : alu_output = operand_1 & operand_2;                               // AND

            // JAL and JALR Instructions
            {7'bx_xxx_xxx, 3'bxxx, `JAL}    : alu_output = operand_1 + operand_2;                               // JAL
            {7'bx_xxx_xxx, 3'b000, `JALR}   : alu_output = operand_1 + operand_2;                               // JALR
            
            // AUIPC Instruction
            {7'bx_xxx_xxx, 3'bxxx, `AUIPC}  : alu_output = operand_1 + operand_2;                               // AUIPC

            default: alu_output = 32'bz; 
        endcase
    end

    // ----------------------------------------- //
    // Arithmetical Instructions: ADDI, ADD, SUB //
    // ----------------------------------------- //

    reg enable; // In case of need for different designs

    // *** Implement the control systems required for your circuit ***
    always @(*) 
    begin
        casex ({funct7, funct3, opcode})
            {7'bx_xxx_xxx, 3'b000, `OP_IMM} : begin enable = 1'b1; adder_input_1 = operand_1; adder_input_2 = operand_2; adder_Cin = 1'b0;  alu_output = adder_result; end // ADDI
            {7'b0_000_000, 3'b000, `OP}     : begin enable = 1'b1; adder_input_1 = operand_1; adder_input_2 = operand_2; adder_Cin = 1'b0;  alu_output = adder_result; end // ADD
            {7'b0_100_000, 3'b000, `OP}     : begin enable = 1'b1; adder_input_1 = operand_1; adder_input_2 = ~operand_2; adder_Cin = 1'b1; alu_output = adder_result; end // SUB
            default: begin enable = 1'b0; alu_output = 32'bz; end
        endcase    
    end
    
    // *** Instantiate your adder circuit here ***
    // Please instantiate your adder module according to the guidelines and naming conventions of phoeniX
    // --------------------------------------------------------------------------------------------------
    Approximate_Accuracy_Controlable_Adder 
    #(
        .LEN(32),
        .APX_LEN(8)
    )
    AC_APX_Adder 
    (
        .Er(accuracy_control[10 : 3] | {8{~accuracy_control[0]}}), 
        .A(adder_input_1),
        .B(adder_input_2),
        .Cin(adder_Cin),
        .Sum(adder_result)
    );
    // --------------------------------------------------------------------------------------------------
    // *** End of adder module instantiation ***

endmodule


    // Add your custom adder circuit here ***
    // Please create your adder module according to the guidelines and naming conventions of phoeniX
    // --------------------------------------------------------------------------------------------------
    module Approximate_Accuracy_Controlable_Adder 
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

        Error_Configurable_Ripple_Carry_Adder #(.LEN(4)) EC_RCA_1 
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

                Half_Adder HA
                (
                    .A(A[i]), 
                    .B(B[i]),
                    .Sum(EC_RCA_Output[i]),
                    .Cout(HA_Carry)
                );

                Error_Configurable_Ripple_Carry_Adder
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

                Basic_Unit BU_1 (.A(EC_RCA_Output), .B(BU_Output), .C0(BU_Carry));

                Mux_2to1 
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

                Half_Adder HA
                (
                    .A(A[i]), 
                    .B(B[i]),
                    .Sum(RCA_Output[i]),
                    .Cout(HA_Carry)
                );

                Ripple_Carry_Adder
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

                Basic_Unit BU_1 (.A(RCA_Output), .B(BU_Output), .C0(BU_Carry));

                Mux_2to1 
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

    module Basic_Unit 
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

    module Mux_2to1
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

    module Error_Configurable_Ripple_Carry_Adder 
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
                Error_Configurable_Full_Adder ECFA 
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

    module Ripple_Carry_Adder 
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
                Full_Adder FA 
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

    module Error_Configurable_Full_Adder
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

    module Full_Adder 
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

    module Half_Adder 
    (
        input A,
        input B, 
        output Sum, 
        output Cout
    );
        assign Sum = A ^ B;
        assign Cout = A & B;
    endmodule

    // --------------------------------------------------------------------------------------------------
    // *** End of adder module definition ***