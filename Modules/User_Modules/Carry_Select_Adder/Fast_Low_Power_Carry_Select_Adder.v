`include "Basic_Unit.v"
`include "Half_Adder.v"
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
Ripple_Adder #(.LEN(4)) RCA1 (.A(A[3 : 0]), .B(B[3 : 0]), .Carry_in(Cin), .Sum(Sum[3 : 0]), .Carry_out(C3));

// Bits 4 - 7
wire HA1_carry;
wire [3 : 0] RCA2_output;
wire RCA2_carry_out;
Half_Adder HA1 (.A(A[4]), .B(B[4]), .Sum(RCA2_output[0]), .Carry(HA1_carry));
Ripple_Adder #(.LEN(3)) RCA2 (.A(A[7 : 5]), .B(B[7 : 5]), .Carry_in(HA1_carry), .Sum(RCA2_output[3 : 1]), .Carry_out(RCA2_carry_out));
wire BU1_carry_out;
wire [3 : 0] BU1_output;
wire C7;
Basic_Unit BU1 (.A(RCA2_output), .B(BU1_output), .C0(BU1_carry_out));
MUX_10to5  MUX1 (.data_in_1(RCA2_output), .data_in_2(BU1_output), .select(C3), .carry_in_1(RCA2_carry_out), .carry_in_2(BU1_carry_out), .data_out(Sum[7 : 4]), .carry_out(C7));
    
// Bits 8 - 11
wire HA2_carry;
wire [3 : 0] RCA3_output;
wire RCA3_carry_out;
Half_Adder HA2 (.A(A[8]), .B(B[8]), .Sum(RCA3_output[0]), .Carry(HA2_carry));
Ripple_Adder #(.LEN(3)) RCA3 (.A(A[11 : 9]), .B(B[11 : 9]), .Carry_in(HA2_carry), .Sum(RCA3_output[3 : 1]), .Carry_out(RCA3_carry_out));
wire BU2_carry_out;
wire [3 : 0] BU2_output;
wire C11;
Basic_Unit BU2  (.A(RCA3_output), .B(BU2_output), .C0(BU2_carry_out));
MUX_10to5  MUX2 (.data_in_1(RCA3_output), .data_in_2(BU2_output), .select(C7), .carry_in_1(RCA3_carry_out), .carry_in_2(BU2_carry_out), .data_out(Sum[11 : 8]), .carry_out(C11));
       
// Bits 12 - 15
wire HA3_carry;
wire [3 : 0] RCA4_output;
wire RCA4_carry_out;
Half_Adder HA3 (.A(A[12]), .B(B[12]), .Sum(RCA4_output[0]), .Carry(HA3_carry));
Ripple_Adder #(.LEN(3)) RCA4 (.A(A[15 : 13]), .B(B[15 : 13]), .Carry_in(HA3_carry), .Sum(RCA4_output[3 : 1]), .Carry_out(RCA4_carry_out));
wire BU3_carry_out;
wire [3 : 0] BU3_output;
Basic_Unit BU3  (.A(RCA4_output), .B(BU3_output), .C0(BU3_carry_out));
MUX_10to5  MUX3 (.data_in_1(RCA4_output), .data_in_2(BU3_output), .select(C11), .carry_in_1(RCA4_carry_out), .carry_in_2(BU3_carry_out), .data_out(Sum[15 : 12]), .carry_out(Cout));

endmodule