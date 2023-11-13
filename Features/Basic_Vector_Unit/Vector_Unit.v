`ifndef  VECTOR_EXTENSION
    `define     V_ADD   4'b0000
    `define     V_SUB   4'b0001
    `define     V_SHR   4'b0010
    `define     V_SHL   4'b0011
    `define     V_AND   4'b0100
    `define     V_OR    4'b0101
    `define     V_XOR   4'b0110
    `define     V_MUL   4'b0111
    `define     V_MULX  4'b1000
    `define     V_DIV   4'b1001
    `define     V_DIVX  4'b1010
`endif

module Vector_Unit 
(
    input clk,
    input reset,

    input [3  : 0] v_function,

    input [4  : 0] head,
    input [4  : 0] tail,

    input [31 : 0][0 : 31] v_operand_1,
    input [31 : 0][0 : 31] v_operand_2,
    
    output reg [31 : 0][0 : 31] v_result
);

    always @(posedge clk) begin
        
        if (reset)          // Reset vector registers and result
        begin
            for (integer i = head ; i < tail ; i = i + 1) begin v_result[i] <= 0; end
        end

        else begin
            case (v_function)
                `V_ADD:     // Vector ADD
                begin 
                    for (integer i = head ; i < tail ; i = i + 1) begin
                        v_result[i] <= v_operand_1[i] + v_operand_2[i];
                    end 
                end
                `V_SUB:     // Vector SUB
                begin
                    for (integer i = head ; i < tail ; i = i + 1) begin
                        v_result[i] <= v_operand_1[i] - v_operand_2[i];
                    end 
                end
                `V_SHL:     // Vector SHL
                begin
                    for (integer i = head ; i < tail ; i = i + 1) begin
                        v_result[i] <= v_operand_1[i] << v_operand_2[i];
                    end 
                end
                `V_SHL:     // Vector SHR
                begin
                    for (integer i = head ; i < tail ; i = i + 1) begin
                        v_result[i] <= v_operand_1[i] >> v_operand_2[i];
                    end 
                end
                default:    // Default case
                begin
                    for (integer i = head ; i < tail ; i = i + 1) begin
                        v_result[i] <= 0;
                    end 
                end
            endcase
        end
    end

endmodule

module Vector_Unit_Controller 
(
    input [6  : 0] opcode,
    input [2  : 0] funct3,
    input [6  : 0] funct7,

    output [31 : 0] memory_head,
    output [31 : 0] memory_tail,

    output [4  : 0] head,
    output [4  : 0] tail,

    output [3  : 0] v_function
);

    // LOGIC
    
endmodule