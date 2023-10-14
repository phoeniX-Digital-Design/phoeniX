module Approximate_Accuracy_Controlable_Multiplier (
    input CLK,
    input enable,

    input [6 : 0] Er,
    input [31 : 0] Operand_1,
    input [31 : 0] Operand_2,

    output [63 : 0] Result,
    output Ready
);
    
    wire [31 : 0] Partial_Product [0 : 3];
    wire Partial_Ready [0 : 3];

    Approximate_Accuracy_Controlable_Multiplier_16bit multiplier_LOWxLOW
    (
        .CLK(CLK),
        .enable(enable),

        .Er(Er),
        .Operand_1(Operand_1[15 : 0]),
        .Operand_2(Operand_2[15 : 0]),

        .Result(Partial_Product[0]),
        .Ready(Partial_Ready[0])
    );

    Approximate_Accuracy_Controlable_Multiplier_16bit multiplier_HIGHxLOW
    (
        .CLK(CLK),
        .enable(enable),

        .Er({7{1'b1}}),
        .Operand_1(Operand_1[31 : 16]),
        .Operand_2(Operand_2[15 :  0]),

        .Result(Partial_Product[1]),
        .Ready(Partial_Ready[1])
    );

    Approximate_Accuracy_Controlable_Multiplier_16bit multiplier_LOWxHIGH
    (
        .CLK(CLK),
        .enable(enable),

        .Er({7{1'b1}}),
        .Operand_1(Operand_1[15 :  0]),
        .Operand_2(Operand_2[31 : 16]),

        .Result(Partial_Product[2]),
        .Ready(Partial_Ready[2])
    );

    Approximate_Accuracy_Controlable_Multiplier_16bit multiplier_HIGHxHIGH
    (
        .CLK(CLK),
        .enable(enable),

        .Er({7{1'b1}}),
        .Operand_1(Operand_1[31 : 16]),
        .Operand_2(Operand_2[31 : 16]),

        .Result(Partial_Product[3]),
        .Ready(Partial_Ready[3])
    );

    assign Result = {32'b0, Partial_Product[0]} + {16'b0, Partial_Product[1], 16'b0} + {16'b0, Partial_Product[2], 16'b0} + {Partial_Product[3], 32'b0};
    assign Ready = &{Partial_Ready[0], Partial_Ready[1], Partial_Ready[2], Partial_Ready[3]};
endmodule

module Approximate_Accuracy_Controlable_Multiplier_16bit 
(
    input CLK,
    input enable,

    input [6 : 0] Er,
    input [15 : 0] Operand_1,
    input [15 : 0] Operand_2,

    output reg [31 : 0] Result,
    output reg Ready
);

    reg     [ 7 : 0] mul_input_1;
    reg     [ 7 : 0] mul_input_2;
    
    wire    [15 : 0] mul_result;
    reg     [15 : 0] mul_result_1;
    reg     [15 : 0] mul_result_2;
    reg     [15 : 0] mul_result_3;
    reg     [15 : 0] mul_result_4;

    Approximate_Accuracy_Controlable_Multiplier_8bit mul
    (
        .CLK(CLK),
        .Er(Er),
        .Operand_1(mul_input_1),
        .Operand_2(mul_input_2),
        .Result(mul_result)
    );

    reg [2 : 0] state;
    reg [2 : 0] next_state;

    localparam reset = 3'b000;

    always @(posedge CLK) 
    begin
        if (~enable)   
        begin 
            state <= reset;
            Ready <= 1'b0;
        end
        else
            state <= next_state;
    end

    always @(*) 
    begin
        next_state = 'bx;

        case (state)
            3'b000 : begin next_state <= 3'b001; Ready <= 1'b0; end
            3'b001 : begin mul_input_1 <= Operand_1[ 7 : 0]; mul_input_2 <= Operand_2[ 7 : 0]; next_state <= 3'b010; end
            3'b010 : begin mul_input_1 <= Operand_1[15 : 8]; mul_input_2 <= Operand_2[ 7 : 0]; next_state <= 3'b011; end
            3'b011 : begin mul_input_1 <= Operand_1[ 7 : 0]; mul_input_2 <= Operand_2[15 : 8]; mul_result_1 <= mul_result; next_state <= 3'b100; end
            3'b100 : begin mul_input_1 <= Operand_1[15 : 8]; mul_input_2 <= Operand_2[15 : 8]; mul_result_2 <= mul_result; next_state <= 3'b101; end
            3'b101 : begin mul_result_3 <= mul_result; next_state = 3'b110; end
            3'b110 : begin mul_result_4 <= mul_result; next_state = 3'b111; end
            3'b111 : begin Result = {16'b0, mul_result_1} + {8'b0, mul_result_2, 8'b0} + {8'b0, mul_result_3, 8'b0} + {mul_result_4, 16'b0}; Ready = 1'b1; end
        endcase 
    end
endmodule

module Approximate_Accuracy_Controlable_Multiplier_8bit
(
    input CLK,

    input [6 : 0] Er,
    input [7 : 0] Operand_1,
    input [7 : 0] Operand_2,

    output [15 : 0] Result
);

    ////////////////////
    //    Stage 1     //
    ////////////////////

    wire [10 : 0] P5_Stage_1;
    wire [10 : 0] P6_Stage_1;
    wire [14 : 0] V1_Stage_1;
    wire [14 : 0] V2_Stage_1;

    Multiplier_Stage_1 MS1 
    (
        Operand_1,
        Operand_2,

        P5_Stage_1,
        P6_Stage_1,
        V1_Stage_1,
        V2_Stage_1
    );

    reg [10 : 0] P5_Stage_2;
    reg [10 : 0] P6_Stage_2;
    reg [14 : 0] V1_Stage_2;
    reg [14 : 0] V2_Stage_2;

    always @(posedge CLK)
    begin
        P5_Stage_2 <= P5_Stage_1;
        P6_Stage_2 <= P6_Stage_1;
        V1_Stage_2 <= V1_Stage_1;
        V2_Stage_2 <= V2_Stage_1;
    end
    
    ////////////////////
    //    Stage 2     //
    ////////////////////

    wire [14 : 0] SumSignal_Stage_2;
    wire [14 : 0] CarrySignal_Stage_2;

    Multiplier_Stage_2 MS2
    (
        P5_Stage_2,
        P6_Stage_2,
        V1_Stage_2,
        V2_Stage_2,

        SumSignal_Stage_2,
        CarrySignal_Stage_2
    );
    
    reg [14 : 0] SumSignal_Stage_3;
    reg [14 : 0] CarrySignal_Stage_3;

    always @(posedge CLK) 
    begin
        SumSignal_Stage_3 <= SumSignal_Stage_2;
        CarrySignal_Stage_3 <= CarrySignal_Stage_2;
    end
    ////////////////////
    //    Stage 3     //
    ////////////////////

    Multiplier_Stage_3 MS3
    (
        Er,
        SumSignal_Stage_3,
        CarrySignal_Stage_3,
        Result
    );
endmodule

module Multiplier_Stage_1
(
    input [7 : 0] Operand_1,
    input [7 : 0] Operand_2,

    output [10 : 0] P5,
    output [10 : 0] P6,
    output [14 : 0] V1,
    output [14 : 0] V2
);
    wire [7 : 0] Partial_Product [1 : 8];

    generate
        for (genvar i = 1; i < 9; i = i + 1)
        begin
            assign Partial_Product[i] = {8{Operand_2[i - 1]}} & Operand_1;
        end
    endgenerate

    wire [8 : 0] P1;
    wire [8 : 0] P2;
    wire [8 : 0] P3;
    wire [8 : 0] P4;

    ATC_8 atc_8 
    (
        Partial_Product[1],
        Partial_Product[2],
        Partial_Product[3],
        Partial_Product[4],
        Partial_Product[5],
        Partial_Product[6],
        Partial_Product[7],
        Partial_Product[8],
        P1, P2, P3, P4, V1
    );

    ATC_4 atc_4 (P1, P2, P3, P4, P5, P6, V2);
endmodule

module Multiplier_Stage_2
(
    input [10 : 0] P5,
    input [10 : 0] P6,
    input [14 : 0] V1,
    input [14 : 0] V2,

    output [14 : 0] SumSignal,
    output [14 : 0] CarrySignal
);
    wire [14 : 0] P7;
    wire [14 : 0] Q7;

    iCAC #(11, 4) iCAC_7 (P5, P6, P7, Q7);

    wire [10 : 4] ORed_PPs = V1 [10 : 4] | V2 [10 : 4];

    assign SumSignal[0] = P7[0];
    assign CarrySignal[0] = 0;
    assign CarrySignal[1] = 0;

    Half_Adder HA_1 (P7[1], V1[1], SumSignal[1], CarrySignal[2]);

    Full_Adder FA_1 (P7[2], V1[2], V2[2], SumSignal[2], CarrySignal[3]);
    Full_Adder FA_2 (P7[3], V1[3], V2[3], SumSignal[3], CarrySignal[4]);

    Full_Adder FA_3 (P7[4], Q7[4], ORed_PPs[4], SumSignal[4], CarrySignal[5]);
    Full_Adder FA_4 (P7[5], Q7[5], ORed_PPs[5], SumSignal[5], CarrySignal[6]);
    Full_Adder FA_5 (P7[6], Q7[6], ORed_PPs[6], SumSignal[6], CarrySignal[7]);
    Full_Adder FA_6 (P7[7], Q7[7], ORed_PPs[7], SumSignal[7], CarrySignal[8]);
    Full_Adder FA_7 (P7[8], Q7[8], ORed_PPs[8], SumSignal[8], CarrySignal[9]);
    Full_Adder FA_8 (P7[9], Q7[9], ORed_PPs[9], SumSignal[9], CarrySignal[10]);
    Full_Adder FA_9 (P7[10], Q7[10], ORed_PPs[10], SumSignal[10], CarrySignal[11]);

    Full_Adder FA_10 (P7[11], V1[11], V2[11], SumSignal[11], CarrySignal[12]);
    Full_Adder FA_11 (P7[12], V1[12], V2[12], SumSignal[12], CarrySignal[13]);

    Half_Adder HA_2 (P7[13], V1[13], SumSignal[13], CarrySignal[14]);

    assign SumSignal[14] = P7[14];
endmodule

module Multiplier_Stage_3
(
    input [6 : 0] Er,
    input [14 : 0] SumSignal,
    input [14 : 0] CarrySignal,
    
    output [15 : 0] Result
);
    assign Result[0] = SumSignal[0];
    assign Result[1] = SumSignal[1];

    assign Result[2] = SumSignal[2] | CarrySignal[2];
    assign Result[3] = SumSignal[3] | CarrySignal[3];
    assign Result[4] = SumSignal[4] | CarrySignal[4];

    wire [13 : 5] inter_Carry;

    Error_Configurable_Full_Adder ECA_FA_1 (Er[0], SumSignal[5], CarrySignal[5], 1'b0, Result[5], inter_Carry[5]);

    Error_Configurable_Full_Adder ECA_FA_2 (Er[1], SumSignal[6], CarrySignal[6], inter_Carry[5], Result[6], inter_Carry[6]);
    Error_Configurable_Full_Adder ECA_FA_3 (Er[2], SumSignal[7], CarrySignal[7], inter_Carry[6], Result[7], inter_Carry[7]);
    Error_Configurable_Full_Adder ECA_FA_4 (Er[3], SumSignal[8], CarrySignal[8], inter_Carry[7], Result[8], inter_Carry[8]);
    Error_Configurable_Full_Adder ECA_FA_5 (Er[4], SumSignal[9], CarrySignal[9], inter_Carry[8], Result[9], inter_Carry[9]);
    Error_Configurable_Full_Adder ECA_FA_6 (Er[5], SumSignal[10], CarrySignal[10], inter_Carry[9], Result[10], inter_Carry[10]);
    Error_Configurable_Full_Adder ECA_FA_7 (Er[6], SumSignal[11], CarrySignal[11], inter_Carry[10], Result[11], inter_Carry[11]);


    Full_Adder FA_12 (SumSignal[12], CarrySignal[12], inter_Carry[11], Result[12], inter_Carry[12]);
    Full_Adder FA_13 (SumSignal[13], CarrySignal[13], inter_Carry[12], Result[13], inter_Carry[13]);
    Full_Adder FA_14 (SumSignal[14], CarrySignal[14], inter_Carry[13], Result[14], Result[15]);
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