module Half_Adder
(
    input A, 
    input B, 
    output Sum, 
    output Carry
);

    xor G1 (Sum, A, B);
    and G2 (Carry, A, B);

endmodule