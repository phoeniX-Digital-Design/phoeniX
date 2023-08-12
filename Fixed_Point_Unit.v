/*
    RV32IMF Core - Fixed Point Unit
    - This unit executes R-Type and I-Type 'F' standard RV32 extension
    - Inputs bus_rs1, bus_rs2 comes from Register_File
    - Input immediate comes from Immediate_Generator
    - Inputs forward_rs1, forward_rs2 comes from the execution-unit output (bypassed)
    - Input signals opcode, funct3, funct7, comes from Instruction_Decoder
    - Input signals mux1_select, mux2_select comes from Control_Unit
    - Supported Instructions :

        F-TYPE : TBD                        
*/
module Fixed_Point_Unit 
(
    input [6 : 0] opcode,               // ALU Operation
    input [2 : 0] funct3,               // ALU Operation
    input [6 : 0] funct7,               // ALU Operation
    
    input         mux1_select,          // Bypass Mux for operand_1
    input [1 : 0] mux2_select,          // Bypass Mux for operand_2

    input [31 : 0] bus_rs1,             // Register Source 1
    input [31 : 0] bus_rs2,             // Register Source 2
    input [31 : 0] immediate,           // Immediate Source
    input [31 : 0] forward_rs1,         // Forwarded Data 1
    input [31 : 0] forward_rs2,         // Forwarded Data 2

    output reg [31 : 0] alu_output      // ALU Result
);

    reg [31 : 0] operand_1;
    reg [31 : 0] operand_2;

    // Bypassing (Data Forwarding) Multiplexer 1
    always @(*) begin
        case (mux1_select)
            1'b0: operand_1 = bus_rs1;
            1'b1: operand_1 = forward_rs1;
        endcase
    end
    // Bypassing (Data Forwarding) Multiplexer 2
    always @(*) begin
        case (mux2_select)
            2'b00: operand_2 = bus_rs2;
            2'b01: operand_2 = forward_rs2;
            2'b10: operand_2 = immediate;
        endcase
    end

    always @(*)
    begin
        casex ({funct7, funct3, opcode})
            // F-TYPE Intructions
            17'b0000000_xxx_1010011 : alu_output = operand_1 + operand_2;                           // FADD

            default: alu_output = 32'bz; 
        endcase
    end
    
endmodule