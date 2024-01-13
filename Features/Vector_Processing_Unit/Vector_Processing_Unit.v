//`include "Defines.v"

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

    `define OP_V        7'b11_110_11
`endif /*OPCODES*/

`ifndef VECTOR_UNIT
    `define VECTOR          7'b111_0000 // Custom funct7 for vector arithmetic
    `define VADD            3'b000      // Vector Addition
    `define VSUB            3'b001      // Vector Subtraction
    `define VDOT            3'b010      // Dot Product
    `define VCROSS          3'b011      // Cross Product
    `define VSMUL           3'b100      // Scalar multiplication
`endif

module Vector_Processing_Unit 
(
    input wire [ 6 : 0] opcode,               
    input wire [ 2 : 0] funct3,
    input wire [ 6 : 0] funct7,           
    input wire [31 : 0] vector_input_1,
    input wire [31 : 0] vector_input_2,
    output reg [31 : 0] vector_result
);

    reg [2 : 0] vector_unit_control;

    wire [15 : 0] signed_extended_input_1_1;
    wire [15 : 0] signed_extended_input_2_1;

    wire [15 : 0] signed_extended_input_1_2;
    wire [15 : 0] signed_extended_input_2_2;

    wire [15 : 0] signed_extended_input_1_3;
    wire [15 : 0] signed_extended_input_2_3;

    wire [15 : 0] signed_extended_input_1_4;
    wire [15 : 0] signed_extended_input_2_4;

    wire [7  : 0] partial_result_1;
    wire [7  : 0] partial_result_2;
    wire [7  : 0] partial_result_3;
    wire [7  : 0] partial_result_4;

    reg signed [7  : 0] vector_0_7_input_1;
    reg signed [7  : 0] vector_0_7_input_2;
    reg signed [7  : 0] vector_8_15_input_1;
    reg signed [7  : 0] vector_8_15_input_2;
    reg signed [7  : 0] vector_16_23_input_1; 
    reg signed [7  : 0] vector_16_23_input_2; 
    reg signed [7  : 0] vector_24_31_input_1; 
    reg signed [7  : 0] vector_24_31_input_2;

    wire [15 : 0] scalar_1;
    wire [15 : 0] scalar_2;
    wire [15 : 0] scalar_3;
    wire [15 : 0] scalar_4;

    // Sign Extension
    assign signed_extended_input_1_1 = {{8{vector_input_1[7]}},  vector_input_1[7:0]};
    assign signed_extended_input_2_1 = {{8{vector_input_2[7]}},  vector_input_2[7:0]};

    assign signed_extended_input_1_2 = {{8{vector_input_1[15]}}, vector_input_1[15:8]};
    assign signed_extended_input_2_2 = {{8{vector_input_2[15]}}, vector_input_2[15:8]};

    assign signed_extended_input_1_3 = {{8{vector_input_1[23]}}, vector_input_1[23:16]};
    assign signed_extended_input_2_3 = {{8{vector_input_2[23]}}, vector_input_2[23:16]};

    assign signed_extended_input_1_4 = {{8{vector_input_1[31]}}, vector_input_1[31:24]};
    assign signed_extended_input_2_4 = {{8{vector_input_2[31]}}, vector_input_2[31:24]};

    reg [7 : 0] circuit_1_input_2;
    reg [7 : 0] circuit_2_input_2;
    reg [7 : 0] circuit_3_input_2;
    reg [7 : 0] circuit_4_input_2;

    reg [7 : 0] multiplier_circuit_1_input_1;
    reg [7 : 0] multiplier_circuit_2_input_1;
    reg [7 : 0] multiplier_circuit_3_input_1;
    reg [7 : 0] multiplier_circuit_4_input_1;

    reg [7 : 0] multiplier_circuit_1_input_2;
    reg [7 : 0] multiplier_circuit_2_input_2;
    reg [7 : 0] multiplier_circuit_3_input_2;
    reg [7 : 0] multiplier_circuit_4_input_2;

    reg circuit_1_carry_input;
    reg circuit_2_carry_input;
    reg circuit_3_carry_input;
    reg circuit_4_carry_input;

    always @(*)
    begin
        case ({funct7, funct3, opcode})
            {`VECTOR, `VADD,    `OP_V} : begin vector_unit_control = `VADD; end
            {`VECTOR, `VSUB,    `OP_V} : begin vector_unit_control = `VSUB; end
            {`VECTOR, `VDOT,    `OP_V} : begin vector_unit_control = `VDOT; end
            {`VECTOR, `VCROSS,  `OP_V} : begin vector_unit_control = `VCROSS; end
            default: begin vector_unit_control = `VADD; end
        endcase
    end
    
    always @(*) 
    begin
        vector_0_7_input_1 = vector_input_1 [7 : 0];
        vector_0_7_input_2 = vector_input_2 [7 : 0];

        vector_8_15_input_1 = vector_input_1 [15 : 8];
        vector_8_15_input_2 = vector_input_2 [15 : 8];
        
        vector_16_23_input_1 = vector_input_1 [23 : 16];
        vector_16_23_input_2 = vector_input_2 [23 : 16];
        
        vector_24_31_input_1 = vector_input_1 [31 : 24];
        vector_24_31_input_2 = vector_input_2 [31 : 24];

        case (vector_unit_control)
            `VADD: 
                begin
                    circuit_1_input_2 = vector_0_7_input_2;
                    circuit_2_input_2 = vector_8_15_input_2;
                    circuit_3_input_2 = vector_16_23_input_2;
                    circuit_4_input_2 = vector_24_31_input_2;

                    circuit_1_carry_input = 1'b0;
                    circuit_2_carry_input = 1'b0;
                    circuit_3_carry_input = 1'b0;
                    circuit_4_carry_input = 1'b0;
                    /*
                    partial_result_1 = vector_0_7_input_1   + vector_0_7_input_2;
                    partial_result_2 = vector_8_15_input_1  + vector_8_15_input_2;
                    partial_result_3 = vector_16_23_input_1 + vector_16_23_input_2;
                    partial_result_4 = vector_24_31_input_1 + vector_24_31_input_2;
                    */
                    vector_result = {partial_result_4, partial_result_3, partial_result_2, partial_result_1};
                end
            `VSUB: 
                begin
                    circuit_1_input_2 = ~vector_0_7_input_2;
                    circuit_2_input_2 = ~vector_8_15_input_2;
                    circuit_3_input_2 = ~vector_16_23_input_2;
                    circuit_4_input_2 = ~vector_24_31_input_2;

                    circuit_1_carry_input = 1'b1;
                    circuit_2_carry_input = 1'b1;
                    circuit_3_carry_input = 1'b1;
                    circuit_4_carry_input = 1'b1;
                    /*
                    partial_result_1 = vector_0_7_input_1   - vector_0_7_input_2;
                    partial_result_2 = vector_8_15_input_1  - vector_8_15_input_2;
                    partial_result_3 = vector_16_23_input_1 - vector_16_23_input_2;
                    partial_result_4 = vector_24_31_input_1 - vector_24_31_input_2;
                    */
                    vector_result    = {partial_result_4, partial_result_3, partial_result_2, partial_result_1};
                end
            
            `VDOT: 
                begin
                    multiplier_circuit_1_input_1 = signed_extended_input_1_1;
                    multiplier_circuit_2_input_1 = signed_extended_input_1_2;
                    multiplier_circuit_3_input_1 = signed_extended_input_1_3;
                    multiplier_circuit_4_input_1 = signed_extended_input_1_4;

                    multiplier_circuit_1_input_2 = signed_extended_input_2_1;
                    multiplier_circuit_2_input_2 = signed_extended_input_2_2;
                    multiplier_circuit_3_input_2 = signed_extended_input_2_3;
                    multiplier_circuit_4_input_2 = signed_extended_input_2_4;

                    //scalar_1  = signed_extended_input_1_1 * signed_extended_input_2_1 ;
                    //scalar_2  = signed_extended_input_1_2 * signed_extended_input_2_2 ;
                    //scalar_3  = signed_extended_input_1_3 * signed_extended_input_2_3 ;
                    //scalar_4  = signed_extended_input_1_4 * signed_extended_input_2_4 ;

                    vector_result = scalar_1 + scalar_2 + scalar_3 + scalar_4;
                end
            `VSMUL: 
                begin
                    multiplier_circuit_1_input_1 = vector_input_1 [7 : 0];
                    multiplier_circuit_2_input_1 = vector_input_1 [15 : 8];

                    multiplier_circuit_1_input_2 = vector_input_2 [7  : 0];
                    multiplier_circuit_2_input_2 = vector_input_2 [15 : 8];

                    vector_result = {scalar_2, scalar_1};
                end
            /*
            `VCROSS:
                begin
                    
                end
            */
            default: begin vector_result = vector_input_1; end
        endcase
    end

    // 8-bit Adders
    Vector_CLA #(.LEN(8)) vector_adder_1
    (    
        .A(vector_0_7_input_1),
        .B(circuit_1_input_2),
        .C_in(circuit_1_carry_input),
        .Sum(partial_result_1)
    );
    Vector_CLA #(.LEN(8)) vector_adder_2
    (    
        .A(vector_8_15_input_1),
        .B(circuit_2_input_2),
        .C_in(circuit_2_carry_input),
        .Sum(partial_result_2)
    );
    Vector_CLA #(.LEN(8)) vector_adder_3
    (    
        .A(vector_16_23_input_1),
        .B(circuit_3_input_2),
        .C_in(circuit_3_carry_input),
        .Sum(partial_result_3)
    );
    Vector_CLA #(.LEN(8)) vector_adder_4
    (    
        .A(vector_24_31_input_1),
        .B(circuit_4_input_2),
        .C_in(circuit_4_carry_input),
        .Sum(partial_result_4)
    );

    // 8-bit Multipliers
    Vector_8bit_Multiplier vector_multiplier_1
    (
        .Operand_1(multiplier_circuit_1_input_1),
        .Operand_2(multiplier_circuit_1_input_2),
        .u(7'b111_1111),
        .Result(scalar_1)
    );
    Vector_8bit_Multiplier vector_multiplier_2
    (
        .Operand_1(multiplier_circuit_2_input_1),
        .Operand_2(multiplier_circuit_2_input_2),
        .u(7'b111_1111),
        .Result(scalar_2)
    );
    Vector_8bit_Multiplier vector_multiplier_3
    (
        .Operand_1(multiplier_circuit_3_input_1),
        .Operand_2(multiplier_circuit_3_input_2),
        .u(7'b111_1111),
        .Result(scalar_3)
    );
    Vector_8bit_Multiplier vector_multiplier_4
    (
        .Operand_1(multiplier_circuit_4_input_1),
        .Operand_2(multiplier_circuit_4_input_2),
        .u(7'b111_1111),
        .Result(scalar_4)
    );
    
endmodule

module Vector_CLA #(parameter LEN = 8) 
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input C_in,
    
    output [LEN - 1 : 0] Sum,
    output C_out
);

    wire [LEN : 0] Carry;
    wire [LEN : 0] CarryX;
    wire [LEN - 1 : 0] P;
    wire [LEN - 1 : 0] G;
    assign P = A | B;   // Bitwise AND
    assign G = A & B;   // Bitwise OR

    assign Carry[0] = C_in;

    genvar i;

    generate
        for (i = 1 ; i <= LEN; i = i + 1)
        begin
            assign Carry[i] = G[i - 1] | (P[i - 1] & Carry[i - 1]);
        end
    endgenerate

    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Full_Adder_Vector FA (.A(A[i]), .B(B[i]), .C_in(Carry[i]), .C_out(CarryX[i + 1]), .Sum(Sum[i]));
        end
    assign C_out = Carry[LEN];
    endgenerate

endmodule

module Full_Adder_Vector 
(
    input A,
    input B,
    input C_in,

    output C_out,
    output Sum
);
    assign Sum = A ^ B ^ C_in;
    assign C_out = (A && B) || (A && C_in) || (B && C_in); 
endmodule


module Vector_8bit_Multiplier 
(
    input [7 : 0] Operand_1,
    input [7 : 0] Operand_2,
    
    input [6 : 0] u,

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

    ATC_8_VECTOR atc_8 (PP[1], PP[2], PP[3], PP[4], PP[5], PP[6], PP[7], PP[8], P1, P2, P3, P4, V1);

    // Stage 1 - ATC_4 wires and instantiation
    wire [10 : 0] P5;
    wire [10 : 0] P6;

    wire [14 : 0] V2;

    ATC_4_VECTOR atc_4 (P1, P2, P3, P4, P5, P6, V2);

    // Stage 1 - Final row of iCACs (ATC_2)

    wire [14 : 0] P7;
    wire [14 : 0] Q7;

    iCAC_VECTOR #(11, 4) iCAC_7 (P5, P6, P7, Q7);

    // Stage 2

    wire [10 : 4] ORed_PPs = V1 [10 : 4] | V2 [10 : 4];

    // Stage 3

    wire [14 : 0] SumSignal, CarrySignal;

    assign SumSignal[0] = P7[0];
    assign CarrySignal[0] = 0;
    assign CarrySignal[1] = 0;

    Half_Adder_Vector HA_1 (P7[1], V1[1], CarrySignal[2], SumSignal[1]);
    
    Full_Adder_Vector FA_1 (P7[2], V1[2], V2[2], CarrySignal[3], SumSignal[2]);
    Full_Adder_Vector FA_2 (P7[3], V1[3], V2[3], CarrySignal[4], SumSignal[3]);

    Full_Adder_Vector FA_3 (P7[4], Q7[4], ORed_PPs[4], CarrySignal[5], SumSignal[4]);
    Full_Adder_Vector FA_4 (P7[5], Q7[5], ORed_PPs[5], CarrySignal[6], SumSignal[5]);
    Full_Adder_Vector FA_5 (P7[6], Q7[6], ORed_PPs[6], CarrySignal[7], SumSignal[6]);
    Full_Adder_Vector FA_6 (P7[7], Q7[7], ORed_PPs[7], CarrySignal[8], SumSignal[7]);
    Full_Adder_Vector FA_7 (P7[8], Q7[8], ORed_PPs[8], CarrySignal[9], SumSignal[8]);
    Full_Adder_Vector FA_8 (P7[9], Q7[9], ORed_PPs[9], CarrySignal[10], SumSignal[9]);
    Full_Adder_Vector FA_9 (P7[10], Q7[10], ORed_PPs[10], CarrySignal[11], SumSignal[10]);

    Full_Adder_Vector FA_10 (P7[11], V1[11], V2[11], CarrySignal[12], SumSignal[11]);
    Full_Adder_Vector FA_11 (P7[12], V1[12], V2[12], CarrySignal[13], SumSignal[12]);

    Half_Adder_Vector HA_2 (P7[13], V1[13], CarrySignal[14], SumSignal[13]);

    assign SumSignal[14] = P7[14];

    // Stage 4

    assign Result[0] = SumSignal[0];
    assign Result[1] = SumSignal[1];

    assign Result[2] = SumSignal[2] | CarrySignal[2];
    assign Result[3] = SumSignal[3] | CarrySignal[3];
    assign Result[4] = SumSignal[4] | CarrySignal[4];

    wire [13 : 5] inter_Carry;
    
    Error_Configurable_Adder ECA_FA_1 (u[0], SumSignal[5], CarrySignal[5], 1'b0, Result[5], inter_Carry[5]);
    
    Error_Configurable_Adder ECA_FA_2 (u[1], SumSignal[6], CarrySignal[6], inter_Carry[5], Result[6], inter_Carry[6]);
    Error_Configurable_Adder ECA_FA_3 (u[2], SumSignal[7], CarrySignal[7], inter_Carry[6], Result[7], inter_Carry[7]);
    Error_Configurable_Adder ECA_FA_4 (u[3], SumSignal[8], CarrySignal[8], inter_Carry[7], Result[8], inter_Carry[8]);
    Error_Configurable_Adder ECA_FA_5 (u[4], SumSignal[9], CarrySignal[9], inter_Carry[8], Result[9], inter_Carry[9]);
    Error_Configurable_Adder ECA_FA_6 (u[5], SumSignal[10], CarrySignal[10], inter_Carry[9], Result[10], inter_Carry[10]);
    Error_Configurable_Adder ECA_FA_7 (u[6], SumSignal[11], CarrySignal[11], inter_Carry[10], Result[11], inter_Carry[11]);


    Full_Adder_Vector FA_12 (SumSignal[12], CarrySignal[12], inter_Carry[11], inter_Carry[12], Result[12]);
    Full_Adder_Vector FA_13 (SumSignal[13], CarrySignal[13], inter_Carry[12], inter_Carry[13], Result[13]);
    Full_Adder_Vector FA_14 (SumSignal[14], CarrySignal[14], inter_Carry[13], Result[15], Result[14]);

endmodule

module Error_Configurable_Adder 
(
    input M,
    input A,
    input B,
    input C_in,

    output Sum,
    output C_out
);

    wire xor_g1_o;
    wire nand_g1_o;
    wire or_g1_o;

    xor xor_g1 (xor_g1_o, A, B);
    nand nand_g1 (nand_g1_o, M, xor_g1_o, C_in);
    or or_g1 (or_g1_o, xor_g1_o, C_in);
    and and_g1 (Sum, nand_g1_o, or_g1_o);

    wire nand_g2_o;
    wire or_g2_o;
    wire nand_g3_o;

    nand nand_g2 (nand_g2_o, M, B, C_in);
    or or_g2 (or_g2_o, B, C_in);
    nand nand_g3 (nand_g3_o, A, or_g2_o);
    nand nand_g4 (C_out, nand_g2_o, nand_g3_o);
    
endmodule

module iCAC_VECTOR 
#(
    parameter WIDTH = 8,
    parameter SHIFT_BITS = 1
) (
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

module Half_Adder_Vector
(
    input A,
    input B,

    output C_out,
    output Sum
);
    xor xor_g1 (Sum, A, B);
    and and_g1 (C_out, A, B);
endmodule

module ATC_4_VECTOR 
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

    iCAC_VECTOR #(9, 2) iCAC_5 (P1, P2 , P5, Q5);
    iCAC_VECTOR #(9, 2) iCAC_6 (P3, P4 , P6, Q6);

    assign V2 = Q5 | Q6 << 4;
endmodule

module ATC_8_VECTOR 
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

    iCAC_VECTOR #(8, 1) iCAC_1 (PP_1, PP_2, P1, Q1);
    iCAC_VECTOR #(8, 1) iCAC_2 (PP_3, PP_4, P2, Q2);
    iCAC_VECTOR #(8, 1) iCAC_3 (PP_5, PP_6, P3, Q3);
    iCAC_VECTOR #(8, 1) iCAC_4 (PP_7, PP_8, P4, Q4);

    assign V1 = Q1 | Q2 << 2 | Q3 << 4 | Q4 << 6;
    
endmodule