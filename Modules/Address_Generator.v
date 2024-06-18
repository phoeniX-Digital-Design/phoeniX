//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Address Generation Unit (AGU) Module
//  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

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

endmodule

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