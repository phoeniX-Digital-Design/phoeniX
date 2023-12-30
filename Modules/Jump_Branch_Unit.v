`include "Defines.v"

module Jump_Branch_Unit 
(
    input [6 : 0] opcode,
    input [2 : 0] funct3,
    input [2 : 0] instruction_type,

    input [31 : 0] rs1,
    input [31 : 0] rs2,
      
    output jump_branch_enable     
);

    reg branch_enable;
    reg jump_enable;

    always @(*) 
    begin
            if (instruction_type == `B_TYPE)  
                casex ({funct3})
                    `BEQ  : begin if ($signed(rs1) == $signed(rs2))   branch_enable = 1'b1; else  branch_enable = 1'b0; end 
                    `BNE  : begin if ($signed(rs1) != $signed(rs2))   branch_enable = 1'b1; else  branch_enable = 1'b0; end                    
                    `BLT  : begin if ($signed(rs1) <  $signed(rs2))   branch_enable = 1'b1; else  branch_enable = 1'b0; end                    
                    `BGE  : begin if ($signed(rs1) >= $signed(rs2))   branch_enable = 1'b1; else  branch_enable = 1'b0; end                    
                    `BLTU : begin if (rs1 < rs2)                      branch_enable = 1'b1; else  branch_enable = 1'b0; end
                    `BGEU : begin if (rs1 >= rs2)                     branch_enable = 1'b1; else  branch_enable = 1'b0; end                    
                    default: branch_enable = 1'b0;
                endcase
            else
                branch_enable = 1'b0;

            if (opcode == `JAL || opcode == `JALR)
                jump_enable = 1'b1;
            else
                jump_enable = 1'b0;
      end  

      assign jump_branch_enable = jump_enable || branch_enable;
endmodule