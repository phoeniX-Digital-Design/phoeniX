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
        U-TYPE : AUIPC         
*/

`ifndef DIRECTION
    `define RIGHT 1'b1
    `define LEFT  1'b0
`endif 

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

module Arithmetic_Logic_Unit
(
    input [6 : 0] opcode,               
    input [2 : 0] funct3,               
    input [6 : 0] funct7,               

    input [31 : 0] accuracy_control,    

    input [31 : 0] rs1,                 
    input [31 : 0] rs2,                 
    input [31 : 0] immediate,           

    output reg [31 : 0] alu_output      
);
    reg alu_enable;

    reg  [31 : 0] operand_1; 
    reg  [31 : 0] operand_2;

    reg adder_Cin;
    reg  [31 : 0] adder_input_1;
    reg  [31 : 0] adder_input_2;
    
    wire [31 : 0] adder_result;

    reg  [31 : 0] shifter_input;
    reg  [4  : 0] shifter_amount;
    reg           shift_direction;
    wire [31 : 0] shifter_result;

    always @(*) 
    begin
        case (opcode)
        `OP     : begin operand_1 = rs1; operand_2 = rs2;       end // R-TYPE 
        `OP_IMM : begin operand_1 = rs1; operand_2 = immediate; end // I-TYPE 
        default : begin operand_1 = 32'bz; operand_2 = 32'bz;   end
        endcase        
    end

    // ----------------------------------- //
    // Main R-type and I-type Instrcutions //
    // ----------------------------------- //
    always @(*)
    begin
        $display("%t : Deciding ... ", $time);
        casez ({funct7, funct3, opcode})
            // I-TYPE Intructions
            {7'bz_zzz_zzz, 3'b000, `OP_IMM} : begin $display("ADDI %t", $time);alu_enable = 1'b1; alu_output = adder_result; end
            {7'b0_000_000, 3'b001, `OP_IMM} : begin $display("SLLI %t", $time);alu_enable = 1'b1; alu_output = operand_1 << operand_2 [4 : 0];                     end     // SLLI
            {7'bz_zzz_zzz, 3'b010, `OP_IMM} : begin $display("SLTI %t", $time);alu_enable = 1'b1; alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;    end     // SLTI
            {7'bz_zzz_zzz, 3'b011, `OP_IMM} : begin $display("SLTIU %t", $time);alu_enable = 1'b1; alu_output = operand_1 < operand_2 ? 1 : 0;                      end     // SLTIU
            {7'bz_zzz_zzz, 3'b100, `OP_IMM} : begin $display("XORI %t", $time);alu_enable = 1'b1; alu_output = operand_1 ^ operand_2;                              end     // XORI
            {7'b0_000_000, 3'b101, `OP_IMM} : begin $display("SRLI %t", $time);alu_enable = 1'b1; alu_output = operand_1 >> operand_2 [4 : 0];                     end     // SRLI
            {7'b0_100_000, 3'b101, `OP_IMM} : begin $display("SRAI %t", $time);alu_enable = 1'b1; alu_output = operand_1 >> $signed(operand_2 [4 : 0]);            end     // SRAI
            {7'bz_zzz_zzz, 3'b110, `OP_IMM} : begin $display("ORI %t", $time);alu_enable = 1'b1; alu_output = operand_1 | operand_2;                              end     // ORI
            {7'bz_zzz_zzz, 3'b111, `OP_IMM} : begin $display("ANDI %t", $time);alu_enable = 1'b1; alu_output = operand_1 & operand_2;                              end     // ANDI
            {7'bz_zzz_zzz, 3'b000, `OP_IMM} : alu_output = adder_result;
            {7'b0_000_000, 3'b001, `OP_IMM} : 
            begin shifter_input = operand_1; shifter_amount = operand_2 [4 : 0]; shift_direction = `LEFT; alu_output = shifter_result;  end     // SLLI
            {7'bz_zzz_zzz, 3'b010, `OP_IMM} : begin alu_enable = 1'b1; alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;    end     // SLTI
            {7'bz_zzz_zzz, 3'b011, `OP_IMM} : begin alu_enable = 1'b1; alu_output = operand_1 < operand_2 ? 1 : 0;                      end     // SLTIU
            {7'bz_zzz_zzz, 3'b100, `OP_IMM} : begin alu_enable = 1'b1; alu_output = operand_1 ^ operand_2;                              end     // XORI
            {7'b0_000_000, 3'b101, `OP_IMM} : 
            begin shifter_input = operand_1; shifter_amount = operand_2 [4 : 0]; shift_direction = `RIGHT; alu_output = shifter_result; end     // SRLI
            {7'b0_100_000, 3'b101, `OP_IMM} :                                                                                                   // SRAI
            begin shifter_input = operand_1; shifter_amount = $signed(operand_2 [4 : 0]); shift_direction = `RIGHT; alu_output = shifter_result; end 
            {7'bz_zzz_zzz, 3'b110, `OP_IMM} : begin alu_enable = 1'b1; alu_output = operand_1 | operand_2;                              end     // ORI
            {7'bz_zzz_zzz, 3'b111, `OP_IMM} : begin alu_enable = 1'b1; alu_output = operand_1 & operand_2;                              end     // ANDI
            
            // R-TYPE Instructions
            {7'b0_000_000, 3'b000, `OP}     : alu_output = adder_result;
            {7'b0_100_000, 3'b000, `OP}     : alu_output = adder_result;
            {7'b0_000_000, 3'b001, `OP}     : 
            begin shifter_input = operand_1; shifter_amount = operand_2 [4 : 0]; shift_direction = `LEFT; alu_output = shifter_result;  end     // SLL
            {7'b0_000_000, 3'b010, `OP}     : begin alu_enable = 1'b1; alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;    end     // SLT
            {7'b0_000_000, 3'b011, `OP}     : begin alu_enable = 1'b1; alu_output = operand_1 < operand_2 ? 1 : 0;                      end     // SLTU
            {7'b0_000_000, 3'b100, `OP}     : begin alu_enable = 1'b1; alu_output = operand_1 ^ operand_2;                              end     // XOR
            {7'b0_000_000, 3'b101, `OP}     : 
            begin shifter_input = operand_1; shifter_amount = operand_2 [4 : 0]; shift_direction = `RIGHT; alu_output = shifter_result; end     // SRL
            {7'b0_100_000, 3'b101, `OP}     :                                                                                                   // SRA
            begin shifter_input = operand_1; shifter_amount = $signed(operand_2 [4 : 0]); shift_direction = `RIGHT; alu_output = shifter_result; end
            {7'b0_000_000, 3'b110, `OP}     : begin alu_enable = 1'b1; alu_output = operand_1 | operand_2;                              end     // OR
            {7'b0_000_000, 3'b111, `OP}     : begin alu_enable = 1'b1; alu_output = operand_1 & operand_2;                              end     // AND
            
            default: begin $display("default case @ %t", $time);alu_enable = 1'b0; alu_output = 32'bz; end
        endcase
    end

    Barrel_Shifter
    #(
        .WIDTH(32)
    )
    arithmetic_logic_unit_shifter_circuit
    (
        .value(shifter_input),
        .shift_amount(shifter_amount),
        .direction(shift_direction),
        .result(shifter_result)
    );

    // ----------------------------------------- //
    // Arithmetical Instructions: ADDI, ADD, SUB //
    // ----------------------------------------- //

    reg adder_enable;
    // *** Implement the control systems required for your circuit ***
    always @(*) 
    begin
        casez ({funct7, funct3, opcode})
            {7'bz_zzz_zzz, 3'b000, `OP_IMM} :
            begin adder_enable = 1'b1; adder_input_1 = operand_1; adder_input_2 = operand_2; adder_Cin = 1'b0;  end // ADDI
            {7'b0_000_000, 3'b000, `OP}     : 
            begin adder_enable = 1'b1; adder_input_1 = operand_1; adder_input_2 = operand_2; adder_Cin = 1'b0;  end // ADD
            {7'b0_100_000, 3'b000, `OP}     : 
            begin adder_enable = 1'b1; adder_input_1 = operand_1; adder_input_2 = ~operand_2; adder_Cin = 1'b1; end // SUB
            default: begin adder_enable = 1'b0; end
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
    approximate_accuracy_controlable_adder 
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

module Barrel_Shifter #(parameter WIDTH = 32)
(
    input  [WIDTH - 1         : 0]   value,
    input  [$clog2(WIDTH) - 1 : 0]   shift_amount,
    input                         direction,
    output reg [WIDTH - 1  : 0]   result
);

    reg [WIDTH - 1 : 0] shifted;

    always @(*)
    begin
        // Right shift
        if (direction)
        begin
            shifted = value;
            for (integer i = 0 ; i < WIDTH ; i = i + 1)
            begin
                if (i < WIDTH - shift_amount)
                    result[i] = shifted[i + shift_amount];
                else
                    result[i] = 0;
            end
        end 
        // Left shift
        if (!direction)
        begin
            shifted = value;
            for (integer i = 0 ; i < WIDTH ; i = i + 1)
            begin
                if (i < shift_amount)
                    result[i] = 0;
                else
                    result[i] = shifted[i - shift_amount];
            end
        end 
    end

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