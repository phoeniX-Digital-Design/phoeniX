`include "Defines.v"

module Jump_Branch_Unit 
(
    input wire [ 6 : 0] opcode,
    input wire [ 2 : 0] funct3,
    input wire [ 2 : 0] instruction_type,

    input wire [31 : 0] rs1,
    input wire [31 : 0] rs2,
      
    output reg jump_branch_enable     
);

    reg branch_enable;
    reg jump_enable;

    always @(*) 
    begin
            if (instruction_type == `B_TYPE)  
                case (funct3)
                    `BEQ  : begin if ($signed(rs1) == $signed(rs2))   branch_enable = `ENABLE; else  branch_enable = `DISABLE; end 
                    `BNE  : begin if ($signed(rs1) != $signed(rs2))   branch_enable = `ENABLE; else  branch_enable = `DISABLE; end                    
                    `BLT  : begin if ($signed(rs1) <  $signed(rs2))   branch_enable = `ENABLE; else  branch_enable = `DISABLE; end                    
                    `BGE  : begin if ($signed(rs1) >= $signed(rs2))   branch_enable = `ENABLE; else  branch_enable = `DISABLE; end                    
                    `BLTU : begin if (rs1 < rs2)                      branch_enable = `ENABLE; else  branch_enable = `DISABLE; end
                    `BGEU : begin if (rs1 >= rs2)                     branch_enable = `ENABLE; else  branch_enable = `DISABLE; end                    
                    default: branch_enable = `DISABLE;
                endcase
            else branch_enable = `DISABLE;

            if (opcode == `JAL || opcode == `JALR) jump_enable = `ENABLE;
            else jump_enable = `DISABLE;
            
            jump_branch_enable = jump_enable || branch_enable;
    end 
endmodule