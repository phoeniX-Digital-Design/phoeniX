module Basic_Unit 
(
    input  [3 : 0] A,
    output [3 : 0] B,
    output C0
);

    wire c1;                        // C1
    wire c2;                        // C2
    wire c3;                        // C3

    and and1 (c1, A[0], A[1]);      // Internal signal
    and and2 (c2, A[2], A[3]);      // Internal signal
    and and3 (c3, c1, A[2]);        // Internal signal
    
    not not1 (B[0], A[0]);          // B1
    xor xor1 (B[1], A[0], A[1]);    // B2
    xor xor2 (B[2], c1, A[2]);      // B3
    xor xor3 (B[3], c3, A[3]);      // B4

    and and4 (C0, c1, c2);           // C0

endmodule