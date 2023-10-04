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