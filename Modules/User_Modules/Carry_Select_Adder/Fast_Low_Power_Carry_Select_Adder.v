`include "Basic_Unit.v"
`include "Ripple_Adder.v"
`include "MUX_10to5.v"

module Fast_Low_Power_Carry_Select_Adder #(parameter LEN = 16) 
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);
// Bits 0 - 3
wire [3 : 0] bits_0_to_3;
wire C3;
Ripple_Adder #(.LEN(4)) RCA1 (.A(A[3 : 0]), .B(B[3 : 0]), .Carry_in(Cin), .Sum(bits_0_to_3), .Carry_out(C3));

// Bits 4 - 7
wire [3 : 0] bits_4_to_7;
wire HA1_output = 0;
wire [3 : 0] RCA2_output;
wire RCA2_carry_out;
Ripple_Adder #(.LEN(4)) RCA2 (.A(A[7 : 4]), .B(B[7 : 4]), .Carry_in(HA1_output), .Sum(RCA2_output), .Carry_out(RCA2_carry_out));
wire BU1_carry_out;
wire [3 : 0] BU1_output;
wire C7;
Basic_Unit BU1 (.A(RCA2_output), .B(BU1_output), .C0(BU1_carry_out));
MUX_10to5  MUX1 (.data_in_1(RCA2_output), .data_in_2(BU1_output), .select(C3), .carry_in_1(RCA2_carry_out), .carry_in_2(BU1_carry_out), .data_out(bits_4_to_7), .carry_out(C7));
    
// Bits 8 - 11
wire [3 : 0] bits_8_to_11;
wire HA2_output = 0;
wire [3 : 0] RCA3_output;
wire RCA3_carry_out;
Ripple_Adder #(.LEN(4)) RCA3 (.A(A[11 : 8]), .B(B[11 : 8]), .Carry_in(HA2_output), .Sum(RCA3_output), .Carry_out(RCA3_carry_out));
wire BU2_carry_out;
wire [3 : 0] BU2_output;
wire C11;
Basic_Unit BU2 (.A(RCA3_output), .B(BU2_output), .C0(BU2_carry_out));
MUX_10to5  MUX2 (.data_in_1(RCA3_output), .data_in_2(BU2_output), .select(C7), .carry_in_1(RCA3_carry_out), .carry_in_2(BU2_carry_out), .data_out(bits_8_to_11), .carry_out(C11));
    
// Bits 12 - 15
wire [3 : 0] bits_12_to_15;
wire HA3_output = 0;
wire [3 : 0] RCA4_output;
wire RCA4_carry_out;
Ripple_Adder #(.LEN(4)) RCA4 (.A(A[15 : 12]), .B(B[15 : 12]), .Carry_in(HA3_output), .Sum(RCA4_output), .Carry_out(RCA4_carry_out));
wire BU3_carry_out;
wire [3 : 0] BU3_output;
Basic_Unit BU3 (.A(RCA4_output), .B(BU3_output), .C0(BU3_carry_out));
MUX_10to5  MUX3 (.data_in_1(RCA4_output), .data_in_2(BU3_output), .select(C11), .carry_in_1(RCA4_carry_out), .carry_in_2(BU3_carry_out), .data_out(bits_12_to_15), .carry_out(Cout));

assign Sum = {bits_12_to_15, bits_8_to_11, bits_4_to_7, bits_0_to_3};

endmodule