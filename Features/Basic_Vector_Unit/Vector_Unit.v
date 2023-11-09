`ifndef  VECTOR_EXTENSION
    `define     V_ADD   4'b0000
    `define     V_SUB   4'b0001
    `define     V_SHR   4'b0010
    `define     V_SHL   4'b0011
    `define     V_AND   4'b0100
    `define     V_OR    4'b0101
    `define     V_XOR   4'b0110
    `define     V_MUL   4'b0111
`endif

module Vector_Unit 
(
    input CLK,
    input reset,

    input [6  : 0] opcode,
    input [2  : 0] funct3,
    input [6  : 0] funct7,

    input [31 : 0][0 : 31] v_operand_1,
    input [31 : 0][0 : 31] v_operand_2,
    
    output reg [31 : 0][0 : 31] v_result
);

    reg [3  : 0] v_function; // Must be determined from opcode, funct3, funct7

    always @(posedge CLK) begin
        
        if (reset)          // Reset vector registers and result
        begin
            for (integer i = 0; i < 32; i = i + 1) begin v_result[i] <= 0; end
        end

        else begin
            case (v_function)
                `V_ADD:     // Vector ADD
                begin 
                    for (integer i = 0; i < 32; i = i + 1) begin
                        v_result[i] <= v_operand_1[i] + v_operand_2[i];
                    end 
                end
                `V_SUB:     // Vector SUB
                begin
                    for (integer i = 0; i < 32; i = i + 1) begin
                        v_result[i] <= v_operand_1[i] - v_operand_2[i];
                    end 
                end
                `V_SHL:     // Vector SHL
                begin
                    for (integer i = 0; i < 32; i = i + 1) begin
                        v_result[i] <= v_operand_1[i] << v_operand_2[i];
                    end 
                end
                `V_SHL:     // Vector SHR
                begin
                    for (integer i = 0; i < 32; i = i + 1) begin
                        v_result[i] <= v_operand_1[i] >> v_operand_2[i];
                    end 
                end
                default:    // Default case
                begin
                    for (integer i = 0; i < 32; i = i + 1) begin
                        v_result[i] <= 0;
                    end 
                end
            endcase
        end
    end

endmodule