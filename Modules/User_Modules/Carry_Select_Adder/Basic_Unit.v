module Basic_Unit 
(
    input  [3 : 0] A,
    output [3 : 0] B,
    output C0
);

    wire C1;                        // C1
    wire C2;                        // C2
    wire C3;                        // C3

    and and1 (C1, A[0], A[1]);      // Internal signal
    and and2 (C2, A[2], A[3]);      // Internal signal
    and and3 (C3, C1, A[2]);        // Internal signal
    
    not not1 (B[0], A[0]);          // B1
    xor xor1 (B[1], A[0], A[1]);    // B2
    xor xor2 (B[2], C1, A[2]);      // B3
    xor xor3 (B[3], C3, A[3]);      // B4

    and and4 (C0, C1, C2);          // C0

endmodule