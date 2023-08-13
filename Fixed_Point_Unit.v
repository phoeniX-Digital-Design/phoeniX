/*
    RV32IMF Core - Fixed Point Unit
    - This unit executes 'F' estension instructions
    - Inputs bus_rs1, bus_rs2 comes from Register_File (Fixed Point Register File)
    - Input immediate comes from Immediate_Generator
    - Inputs forward_rs1, forward_rs2 comes from the execution-unit output (bypassed)
    - Input signals opcode, funct3, funct7, comes from Instruction_Decoder
    - Input signals mux1_select, mux2_select comes from Control_Unit
    - Supported Instructions :

        F-TYPE : TBD                        
*/
module Fixed_Point_Unit #(parameter FLEN = 10)
(
    input [6 : 0] opcode,               // FPU Operation
    input [2 : 0] funct3,               // FPU Operation
    input [6 : 0] funct7,               // FPU Operation

    input [4 : 0] read_index_1,         // Register Address 1
    input [4 : 0] read_index_2,         // Register Address 2
    
    input         mux1_select,          // Bypass Mux for operand_1
    input         mux2_select,          // Bypass Mux for operand_2

    input [31 : 0] bus_rs1,             // Register Source 1
    input [31 : 0] bus_rs2,             // Register Source 2
    input [31 : 0] forward_rs1,         // Forwarded Data 1
    input [31 : 0] forward_rs2,         // Forwarded Data 2

    output reg [31 : 0] fpu_output      // FPU Result
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
            2'b0: operand_2 = bus_rs2;
            2'b1: operand_2 = forward_rs2;
        endcase
    end

    always @(*)
    begin
        casex ({funct7, funct3, opcode})
            // F-TYPE Intructions
            17'b0000000_xxx_1010011 : fpu_output = operand_1 + operand_2;             // FADD.S
            17'b0000100_xxx_1010011 : fpu_output = operand_1 - operand_2;             // FSUB.S
            17'b1101000_xxx_1010011 : begin
                if (read_index_2 == 5'b00000)
                    fpu_output = $signed(operand_1) << FLEN;                          // FCVT.S.W
            end
            17'b1101000_xxx_1010011 : begin 
                if (read_index_2 == 5'b00001) 
                    fpu_output = operand_1 << FLEN;                                   // FCVT.S.W
            end        

            default: fpu_output = 32'bz; 
        endcase
    end

endmodule