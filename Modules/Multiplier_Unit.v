`include "Multiplier_ECA.v"

module Multiplier_Unit 
(
    input [6 : 0] opcode,
    input [6 : 0] funct7,
    input [2 : 0] funct3,

    input mux1_select,
    input mux2_select,

    input [6  : 0] mask,

    input [31 : 0] bus_rs1,
    input [31 : 0] bus_rs2,
    input [31 : 0] Forward_rs1,
    input [31 : 0] Forward_rs2,

    output reg [31 : 0] mul_output
);

    reg  [31 : 0]  operand_1; 
    reg  [31 : 0]  operand_2;

    reg  [7 : 0] input_1;
    reg  [7 : 0] input_2;
    wire [15 : 0] result;

    // Bypassing (Data Forwarding) Multiplexer 1
    always @(*) begin
        case (mux1_select)
            1'b0: operand_1 = bus_rs1;
            1'b1: operand_1 = Forward_rs1;
        endcase
    end
    // Bypassing (Data Forwarding) Multiplexer 2
    always @(*) begin
        case (mux2_select)
            1'b0: operand_2 = bus_rs2;
            1'b1: operand_2 = Forward_rs2;
        endcase
    end

    always @(*) 
    begin
        mul_output = result;
        casex ({funct7, funct3, opcode})
            // I-TYPE Intructions
            17'b0000001_000_0110011 : begin  // MUL
                input_1 = $signed(operand_1 [7 : 0]);
                input_2 = $signed(operand_2 [7 : 0]);
            end
            17'b0000001_001_0110011 : begin  // MULH
                input_1 = $signed(operand_1 [7 : 0]);
                input_2 = $signed(operand_2 [7 : 0]);
                mul_output = mul_output >>> 8;
            end
            17'b0000001_010_0110011 : begin  // MULHSU
                input_1 = $signed(operand_1 [7 : 0]);
                input_2 = operand_2 [7 : 0];
                mul_output = mul_output >>> 8;
            end
            17'b0000001_011_0110011 : begin  // MULHU
                input_1 = operand_1 [7 : 0];
                input_2 = operand_2 [7 : 0];
                mul_output = mul_output >> 8;
            end
            default:    mul_output = 32'bz;  // Wrong opcode                
        endcase
    end

    Multiplier_ECA Multiplier (mask, input_1, input_2, result);

endmodule
