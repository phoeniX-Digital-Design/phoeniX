`timescale 1ns/100ps

module Full_Adder 
(
    input A,
    input B,
    input Carry_in,
    output Sum,
    output Carry_out
);
    wire Wire1;
    wire Wire2;
    wire Wire3;

    xor G1 (Wire1, A, B);
    xor G2 (Sum , Wire1, Carry_in);
    and G3 (Wire2, Wire1, Carry_in);
    and G4 (Wire3, A, B);
    or  G5 (Carry_out, Wire2, Wire3);

endmodule