`include "Defines.v"

module Address_Generator
(
    input wire [ 6 : 0] opcode, 
    input wire [31 : 0] rs1,            
    input wire [31 : 0] pc,
    input wire [31 : 0] immediate,

    output reg [31 : 0] address
);
    
    reg  [31 : 0] adder_input_1;
    reg  [31 : 0] adder_input_2;
    wire [31 : 0] adder_result;

    always @(*) 
    begin
        case (opcode)
            `STORE   : begin adder_input_1 = rs1;   adder_input_2 = immediate; address = adder_result; end    //  Store  ->   rs1  + immediate
            `LOAD    : begin adder_input_1 = rs1;   adder_input_2 = immediate; address = adder_result; end    //  Load   ->   rs1  + immediate
            `JALR    : begin adder_input_1 = rs1;   adder_input_2 = immediate; address = adder_result; end    //  JALR   ->   rs1  + immediate
            `JAL     : begin adder_input_1 = pc;    adder_input_2 = immediate; address = adder_result; end    //  JAL    ->   pc   + immediate
            `AUIPC   : begin adder_input_1 = pc;    adder_input_2 = immediate; address = adder_result; end    //  AUIPC  ->   pc   + immediate
            `BRANCH  : begin adder_input_1 = pc;    adder_input_2 = immediate; address = adder_result; end    //  Branch ->   pc   + immediate
            default  : begin adder_input_1 = 32'bz; adder_input_2 = 32'bz;     address = 32'bz;        end
        endcase 
    end

    Address_Generator_CLA 
    #(
        .LEN(32)
    ) 
    address_generator
    (    
        .A(adder_input_1),
        .B(adder_input_2),
        .C_in(1'b0),
        .Sum(adder_result)
    );
/*
    Kogge_Stone_Adder adder_address_generator 
    (
        .carry_in(1'b0), 
        .input_A(adder_input_1),
        .input_B(adder_input_2),
        .sum(adder_result)
    );
*/
endmodule

/*
module Kogge_Stone_Adder
(
    input  wire          carry_in,
    input  wire [31 : 0] input_A,
    input  wire [31 : 0] input_B,
    output wire [31 : 0] sum,
    output wire          carry_out
);

    // Stage 1
    wire [31 : 0] p_stage_1; wire [31 : 0] g_stage_1; wire carry_stage_1;
    // Stage 2
    wire [30 : 0] p_stage_2; wire [31 : 0] g_stage_2; wire carry_stage_2; wire [31 : 0] p_saved_1;
    // Stage 3
    wire [28 : 0] p_stage_3; wire [31 : 0] g_stage_3; wire carry_stage_3; wire [31 : 0] p_saved_2;
    // Stage 4
    wire [24 : 0] p_stage_4; wire [31 : 0] g_stage_4; wire carry_stage_4; wire [31 : 0] p_saved_3;
    // Stage 5
    wire [16 : 0] p_stage_5; wire [31 : 0] g_stage_5; wire carry_stage_5; wire [31 : 0] p_saved_4;
    // Stage 6
    wire [31 : 0] p_stage_6; wire [31 : 0] g_stage_6; wire carry_stage_6;

    // Kogge Stone Stage 1
    assign carry_stage_1 = carry_in;
    genvar i;
    generate
    for (i = 0 ; i < 32 ; i = i + 1) 
    begin
        PG pg_stage_1 
        (
            .input_a(input_A[i]),
            .input_b(input_B[i]),
            .output_p(p_stage_1[i]),
            .output_g(g_stage_1[i])
        );
    end
    endgenerate

    // Kogge Stone Stage 2
    wire [31 : 0] gkj_stage_2;
    wire [30 : 0] pkj_stage_2;

    assign carry_stage_2        = carry_stage_1;
    assign p_saved_1            = p_stage_1 [31 : 0];
    assign gkj_stage_2 [0]      = carry_stage_1;
    assign gkj_stage_2 [31 : 1] = g_stage_1 [30 : 0];
    assign pkj_stage_2          = p_stage_1 [30 : 0];

    Grey_Cell gc_0(gkj_stage_2[0], p_stage_1[0], g_stage_1[0], g_stage_2[0]);
    genvar j;
    generate
    for (j = 0 ; j < 31 ; j = j + 1) 
    begin
        Black_Cell bc_stage_2 
        (
            .input_pj(pkj_stage_2[j]),
            .input_gj(gkj_stage_2[j + 1]),
            .input_pk(p_stage_1[j + 1]),
            .input_gk(g_stage_1[j + 1]),
            .output_g(g_stage_2[j + 1]),
            .output_p(p_stage_2[j])
        );
    end
    endgenerate

    // Kogge Stone Stage 3
    wire [30 : 0] gkj_stage_3;
    wire [28 : 0] pkj_stage_3;

    assign carry_stage_3       = carry_stage_2;
    assign p_saved_2           = p_saved_1[31 : 0];
    assign gkj_stage_3[0]      = carry_stage_2;
    assign gkj_stage_3[30 : 1] = g_stage_2[29 : 0];
    assign pkj_stage_3         = p_stage_2[28 : 0];
    assign g_stage_3[0]        = g_stage_2[0];

    Grey_Cell  gc_1(gkj_stage_3[0], p_stage_2[0], g_stage_2[1], g_stage_3[1]);
    Grey_Cell  gc_2(gkj_stage_3[1], p_stage_2[1], g_stage_2[2], g_stage_3[2]);

    genvar k;
    generate
    for (k = 0 ; k < 29 ; k = k + 1) 
    begin
        Black_Cell bc_stage_3 
        (
            .input_pj(pkj_stage_3[k]),
            .input_gj(gkj_stage_3[k + 2]),
            .input_pk(p_stage_2[k + 2]),
            .input_gk(g_stage_2[k + 3]),
            .output_g (g_stage_3[k + 3]),
            .output_p (p_stage_3[k])
        );
    end
    endgenerate

    // Kogge Stone Stage 4
    wire [28 : 0] gkj_stage_4;
    wire [24 : 0] pkj_stage_4;

    assign carry_stage_4       = carry_stage_3;
    assign p_saved_3           = p_saved_2[31 : 0];
    assign gkj_stage_4[0]      = carry_stage_3;
    assign gkj_stage_4[28 : 1] = g_stage_3[27 : 0];
    assign pkj_stage_4         = p_stage_3[24 : 0];
    assign g_stage_4[2 : 0]    = g_stage_3[2  : 0];

    genvar l;
    generate
    for (l = 0 ; l < 4 ; l = l + 1) 
    begin
        Grey_Cell gc_stage_4 
        (
            .input_gj(gkj_stage_4[l]),
            .input_pk(p_stage_3[l]),
            .input_gk(g_stage_3[l + 3]),
            .output_g(g_stage_4[l + 3])
        );
    end
    endgenerate

    genvar m;
    generate
    for (m = 0 ; m < 25 ; m = m + 1) 
    begin
        Black_Cell bc_stage_4 
        (
            .input_pj(pkj_stage_4[m]),
            .input_gj(gkj_stage_4[m + 4]),
            .input_pk(p_stage_3[m + 4]),
            .input_gk(g_stage_3[m + 7]),
            .output_g(g_stage_4[m + 7]),
            .output_p(p_stage_4[m])
        );
    end
    endgenerate

    // Kogge Stone Stage 5
    wire [24 : 0] gkj_stage_5;
    wire [16 : 0] pkj_stage_5;

    assign carry_stage_5       = carry_stage_4;
    assign p_saved_4           = p_saved_3[31 : 0];
    assign gkj_stage_5[0]      = carry_stage_4;
    assign gkj_stage_5[24 : 1] = g_stage_4[23 : 0];
    assign pkj_stage_5         = p_stage_4[16 : 0];
    assign g_stage_5[6 : 0]    = g_stage_4[6  : 0];

    genvar n;
    generate
    for (n = 0 ; n < 8 ; n = n + 1) 
    begin
        Grey_Cell gc_stage_5 
        (
            .input_gj(gkj_stage_5[n]),
            .input_pk(p_stage_4[n]),
            .input_gk(g_stage_4[n + 7]),
            .output_g(g_stage_5[n + 7])
        );
    end
    endgenerate

    genvar o;
    generate
    for (o = 0 ; o < 17 ; o = o + 1) 
    begin
        Black_Cell bc_stage_5 
        (
            .input_pj(pkj_stage_5[o]),
            .input_gj(gkj_stage_5[o + 8]),
            .input_pk(p_stage_4[o + 8]),
            .input_gk(g_stage_4[o + 15]),
            .output_g(g_stage_5[o + 15]),
            .output_p(p_stage_5[o])
        );
    end
    endgenerate

    // Kogge Stone Stage 6
    wire [16 : 0] gkj_stage_6;

    assign carry_stage_6       = carry_stage_5;
    assign p_stage_6           = p_saved_4[31 : 0];
    assign gkj_stage_6[0]      = carry_stage_5;
    assign gkj_stage_6[16 : 1] = g_stage_5[15 : 0];
    assign g_stage_6[15 : 0]   = g_stage_5[15 : 0];

    genvar p;
    generate
    for (p = 1 ; p <= 16 ; p = p + 1) 
    begin
        Grey_Cell gc_stage_6 
        (
            .input_gj(gkj_stage_6[p]),
            .input_pk(p_stage_5[p]),
            .input_gk(g_stage_5[p + 15]),
            .output_g(g_stage_6[p + 15])
        );
    end
    endgenerate

    // Kogge Stone Stage 7
    assign carry_out   = g_stage_6[31];
    assign sum[0]      = carry_stage_6 ^ p_stage_6[0];
    assign sum[31 : 1] = g_stage_6[30 : 0] ^ p_stage_6[31 : 1];
endmodule

module PG
(
    input  wire input_a,
    input  wire input_b,
    output wire output_p,
    output wire output_g
);
    assign output_p = input_a ^ input_b;
    assign output_g = input_a & input_b;
endmodule

module Black_Cell
(
    input  wire input_pj,
    input  wire input_gj,
    input  wire input_pk,
    input  wire input_gk,
    output wire output_g,
    output wire output_p
);
    assign output_g = input_gk | (input_gj & input_pk);
    assign output_p = input_pk & input_pj;
endmodule

module Grey_Cell
(
    input  wire input_gj,
    input  wire input_pk,
    input  wire input_gk,
    output wire output_g
);
    assign output_g = input_gk | (input_gj & input_pk);
endmodule
*/

module Address_Generator_CLA #(parameter LEN = 32) 
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
        begin : Address_Generator_CLA_Generate_Block_1
            assign Carry[i] = G[i - 1] | (P[i - 1] & Carry[i - 1]);
        end
    endgenerate

    generate
        for (i = 0; i < LEN; i = i + 1)
        begin : Address_Generator_CLA_Generate_Block_2
            Full_Adder_CLA FA (.A(A[i]), .B(B[i]), .C_in(Carry[i]), .C_out(CarryX[i + 1]), .Sum(Sum[i]));
        end
    assign C_out = Carry[LEN];
    endgenerate

endmodule

module Full_Adder_CLA 
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