`include "Full_Adder.v"

module Ripple_Adder #(parameter LEN = 4) 
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Carry_in,
    output [LEN - 1 : 0] Sum,
    output Carry_out
);

    wire [LEN : 0] Carry;
    assign Carry[0] = Carry_in;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Full_Adder uut (.A(A[i]), .B(B[i]), .Carry_in(Carry[i]), .Sum(Sum[i]), .Carry_out(Carry[i + 1]));
        end
    assign Carry_out = Carry[LEN];
    endgenerate
    
endmodule