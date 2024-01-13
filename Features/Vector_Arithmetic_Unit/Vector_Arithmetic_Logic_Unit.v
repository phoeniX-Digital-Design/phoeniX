`ifndef VECTOR_UNIT
    `define VADD    3'b010   // Vector Addition
    `define VSUB    3'b110   // Vector Subtraction
    `define VDOT    3'b001   // Dot Product
    `define VCROSS  3'b100   // Cross Product
`endif

module Vector_Arithmetic_Logic_Unit 
(
    input wire [ 6 : 0] opcode,               
    input wire [ 2 : 0] funct3,               
    input wire [ 6 : 0] funct7,
    input wire [ 2 : 0] vector_unit_control,
    input wire [31 : 0] vector_input_1,
    input wire [31 : 0] vector_input_2,
    output reg [31 : 0] vector_result
);

    // reg [2 : 0] vector_unit_control;

    wire [15 : 0] signed_extended_input_1_1;
    wire [15 : 0] signed_extended_input_2_1;

    wire [15 : 0] signed_extended_input_1_2;
    wire [15 : 0] signed_extended_input_2_2;

    wire [15 : 0] signed_extended_input_1_3;
    wire [15 : 0] signed_extended_input_2_3;

    wire [15 : 0] signed_extended_input_1_4;
    wire [15 : 0] signed_extended_input_2_4;

    wire [7  : 0] partial_result_1;
    wire [7  : 0] partial_result_2;
    wire [7  : 0] partial_result_3;
    wire [7  : 0] partial_result_4;

    reg signed [7  : 0] vector_0_7_input_1;
    reg signed [7  : 0] vector_0_7_input_2;
    reg signed [7  : 0] vector_8_15_input_1;
    reg signed [7  : 0] vector_8_15_input_2;
    reg signed [7  : 0] vector_16_23_input_1; 
    reg signed [7  : 0] vector_16_23_input_2; 
    reg signed [7  : 0] vector_24_31_input_1; 
    reg signed [7  : 0] vector_24_31_input_2;
    // reg signed [15 : 0] s1, s2, s3, s4;

    // Sign Extension
    assign signed_extended_input_1_1 = {{8{vector_input_1[7]}},  vector_input_1[7:0]};
    assign signed_extended_input_2_1 = {{8{vector_input_2[7]}},  vector_input_2[7:0]};

    assign signed_extended_input_1_2 = {{8{vector_input_1[15]}}, vector_input_1[15:8]};
    assign signed_extended_input_2_2 = {{8{vector_input_2[15]}}, vector_input_2[15:8]};

    assign signed_extended_input_1_3 = {{8{vector_input_1[23]}}, vector_input_1[23:16]};
    assign signed_extended_input_2_3 = {{8{vector_input_2[23]}}, vector_input_2[23:16]};

    assign signed_extended_input_1_4 = {{8{vector_input_1[31]}}, vector_input_1[31:24]};
    assign signed_extended_input_2_4 = {{8{vector_input_2[31]}}, vector_input_2[31:24]};

    reg [7 : 0] circuit_1_input_2;
    reg [7 : 0] circuit_2_input_2;
    reg [7 : 0] circuit_3_input_2;
    reg [7 : 0] circuit_4_input_2;

    reg circuit_1_carry_input;
    reg circuit_2_carry_input;
    reg circuit_3_carry_input;
    reg circuit_4_carry_input;
    
    always @(*) 
    begin
        vector_0_7_input_1 = vector_input_1 [7 : 0];
        vector_0_7_input_2 = vector_input_2 [7 : 0];

        vector_8_15_input_1 = vector_input_1 [15 : 8];
        vector_8_15_input_2 = vector_input_2 [15 : 8];
        
        vector_16_23_input_1 = vector_input_1 [23 : 16];
        vector_16_23_input_2 = vector_input_2 [23 : 16];
        
        vector_24_31_input_1 = vector_input_1 [31 : 24];
        vector_24_31_input_2 = vector_input_2 [31 : 24];

        case (vector_unit_control)
            `VADD: 
                begin
                    circuit_1_input_2 = vector_0_7_input_2;
                    circuit_2_input_2 = vector_8_15_input_2;
                    circuit_3_input_2 = vector_16_23_input_2;
                    circuit_4_input_2 = vector_24_31_input_2;

                    circuit_1_carry_input = 1'b0;
                    circuit_2_carry_input = 1'b0;
                    circuit_3_carry_input = 1'b0;
                    circuit_4_carry_input = 1'b0;
                    /*
                    partial_result_1 = vector_0_7_input_1   + vector_0_7_input_2;
                    partial_result_2 = vector_8_15_input_1  + vector_8_15_input_2;
                    partial_result_3 = vector_16_23_input_1 + vector_16_23_input_2;
                    partial_result_4 = vector_24_31_input_1 + vector_24_31_input_2;
                    */
                    vector_result = {partial_result_4, partial_result_3, partial_result_2, partial_result_1};
                end
            `VSUB: 
                begin
                    circuit_1_input_2 = ~vector_0_7_input_2;
                    circuit_2_input_2 = ~vector_8_15_input_2;
                    circuit_3_input_2 = ~vector_16_23_input_2;
                    circuit_4_input_2 = ~vector_24_31_input_2;

                    circuit_1_carry_input = 1'b1;
                    circuit_2_carry_input = 1'b1;
                    circuit_3_carry_input = 1'b1;
                    circuit_4_carry_input = 1'b1;
                    /*
                    partial_result_1 = vector_0_7_input_1   - vector_0_7_input_2;
                    partial_result_2 = vector_8_15_input_1  - vector_8_15_input_2;
                    partial_result_3 = vector_16_23_input_1 - vector_16_23_input_2;
                    partial_result_4 = vector_24_31_input_1 - vector_24_31_input_2;
                    */
                    vector_result    = {partial_result_4, partial_result_3, partial_result_2, partial_result_1};
                end
            /*
            `VDOT: 
                begin
                    s1  = signed_extended_input_1_1 * signed_extended_input_2_1 ;
                    s2  = signed_extended_input_1_2 * signed_extended_input_2_2 ;
                    s3  = signed_extended_input_1_3 * signed_extended_input_2_3 ;
                    s4  = signed_extended_input_1_4 * signed_extended_input_2_4 ; //16bits
                    vector_result = s1 + s2 + s3 + s4;
                end
            */
            /*
            `VCROSS:
                begin
                    
                end
            */
            default: begin vector_result = vector_input_1; end
        endcase
    end

    Vector_CLA #(.LEN(8)) vector_adder_1
    (    
        .A(vector_0_7_input_1),
        .B(circuit_1_input_2),
        .C_in(circuit_1_carry_input),
        .Sum(partial_result_1)
    );
    Vector_CLA #(.LEN(8)) vector_adder_2
    (    
        .A(vector_8_15_input_1),
        .B(circuit_2_input_2),
        .C_in(circuit_2_carry_input),
        .Sum(partial_result_2)
    );
    Vector_CLA #(.LEN(8)) vector_adder_3
    (    
        .A(vector_16_23_input_1),
        .B(circuit_3_input_2),
        .C_in(circuit_3_carry_input),
        .Sum(partial_result_3)
    );
    Vector_CLA #(.LEN(8)) vector_adder_4
    (    
        .A(vector_24_31_input_1),
        .B(circuit_4_input_2),
        .C_in(circuit_4_carry_input),
        .Sum(partial_result_4)
    );
    
endmodule

module Vector_CLA #(parameter LEN = 8) 
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input C_in,
    
    output [LEN - 1 : 0] Sum,
    output C_out
);

    wire [LEN : 0] Carry;
    wire [LEN : 0] CarryX;
    wire [LEN - 1 : 0] P;
    wire [LEN - 1 : 0] G;
    assign P = A | B;   // Bitwise AND
    assign G = A & B;   // Bitwise OR

    assign Carry[0] = C_in;

    genvar i;

    generate
        for (i = 1 ; i <= LEN; i = i + 1)
        begin
            assign Carry[i] = G[i - 1] | (P[i - 1] & Carry[i - 1]);
        end
    endgenerate

    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Full_Adder_Vector FA (.A(A[i]), .B(B[i]), .C_in(Carry[i]), .C_out(CarryX[i + 1]), .Sum(Sum[i]));
        end
    assign C_out = Carry[LEN];
    endgenerate

endmodule

module Full_Adder_Vector 
(
    input A,
    input B,
    input C_in,

    output C_out,
    output Sum
);
    assign Sum = A ^ B ^ C_in;
    assign C_out = (A && B) || (A && C_in) || (B && C_in); 
endmodule