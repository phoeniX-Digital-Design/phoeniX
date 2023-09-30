module Multiplier_ECA 
(
    input [6 : 0] u,
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

    HalfAdder HA_1 (P7[1], V1[1], CarrySignal[2], SumSignal[1]);

    FullAdder FA_1 (P7[2], V1[2], V2[2], CarrySignal[3], SumSignal[2]);
    FullAdder FA_2 (P7[3], V1[3], V2[3], CarrySignal[4], SumSignal[3]);

    FullAdder FA_3 (P7[4], Q7[4], ORed_PPs[4], CarrySignal[5], SumSignal[4]);
    FullAdder FA_4 (P7[5], Q7[5], ORed_PPs[5], CarrySignal[6], SumSignal[5]);
    FullAdder FA_5 (P7[6], Q7[6], ORed_PPs[6], CarrySignal[7], SumSignal[6]);
    FullAdder FA_6 (P7[7], Q7[7], ORed_PPs[7], CarrySignal[8], SumSignal[7]);
    FullAdder FA_7 (P7[8], Q7[8], ORed_PPs[8], CarrySignal[9], SumSignal[8]);
    FullAdder FA_8 (P7[9], Q7[9], ORed_PPs[9], CarrySignal[10], SumSignal[9]);
    FullAdder FA_9 (P7[10], Q7[10], ORed_PPs[10], CarrySignal[11], SumSignal[10]);

    FullAdder FA_10 (P7[11], V1[11], V2[11], CarrySignal[12], SumSignal[11]);
    FullAdder FA_11 (P7[12], V1[12], V2[12], CarrySignal[13], SumSignal[12]);

    HalfAdder HA_2 (P7[13], V1[13], CarrySignal[14], SumSignal[13]);

    assign SumSignal[14] = P7[14];

    // Stage 4

    assign Result[0] = SumSignal[0];
    assign Result[1] = SumSignal[1];

    assign Result[2] = SumSignal[2] | CarrySignal[2];
    assign Result[3] = SumSignal[3] | CarrySignal[3];
    assign Result[4] = SumSignal[4] | CarrySignal[4];

    wire [13 : 5] inter_Carry;

    ErrorConfigurableAdder ECA_FA_1 (u[0], SumSignal[5], CarrySignal[5], 1'b0, Result[5], inter_Carry[5]);

    ErrorConfigurableAdder ECA_FA_2 (u[1], SumSignal[6], CarrySignal[6], inter_Carry[5], Result[6], inter_Carry[6]);
    ErrorConfigurableAdder ECA_FA_3 (u[2], SumSignal[7], CarrySignal[7], inter_Carry[6], Result[7], inter_Carry[7]);
    ErrorConfigurableAdder ECA_FA_4 (u[3], SumSignal[8], CarrySignal[8], inter_Carry[7], Result[8], inter_Carry[8]);
    ErrorConfigurableAdder ECA_FA_5 (u[4], SumSignal[9], CarrySignal[9], inter_Carry[8], Result[9], inter_Carry[9]);
    ErrorConfigurableAdder ECA_FA_6 (u[5], SumSignal[10], CarrySignal[10], inter_Carry[9], Result[10], inter_Carry[10]);
    ErrorConfigurableAdder ECA_FA_7 (u[6], SumSignal[11], CarrySignal[11], inter_Carry[10], Result[11], inter_Carry[11]);


    FullAdder FA_12 (SumSignal[12], CarrySignal[12], inter_Carry[11], inter_Carry[12], Result[12]);
    FullAdder FA_13 (SumSignal[13], CarrySignal[13], inter_Carry[12], inter_Carry[13], Result[13]);
    FullAdder FA_14 (SumSignal[14], CarrySignal[14], inter_Carry[13], Result[15], Result[14]);

endmodule

module ErrorConfigurableAdder 
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

module iCAC #(parameter WIDTH = 8, parameter SHIFT_BITS = 1) 
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

module FullAdder 
(
    input A,
    input B, 
    input C_in,

    output C_out,
    output Sum
);
    wire xor_g1_o;
    wire and_g1_o;
    wire and_g2_o;

    xor xor_g1 (xor_g1_o, A, B);
    and and_g1 (and_g1_o, xor_g1_o, C_in);
    and and_g2 (and_g2_o, A, B);
    or or_g1 (C_out, and_g1_o, and_g2_o);
    xor xor_g2 (Sum, xor_g1_o, C_in);
endmodule

module HalfAdder 
(
    input A,
    input B,

    output C_out,
    output Sum
);
    xor xor_g1 (Sum, A, B);
    and and_g1 (C_out, A, B);
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