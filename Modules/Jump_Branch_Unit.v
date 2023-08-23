`define R_TYPE 0
`define I_TYPE 1
`define S_TYPE 2
`define B_TYPE 3
`define U_TYPE 4
`define J_TYPE 5

`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BGE  3'b101
`define BLTU 3'b110
`define BGEU 3'b111

module Jump_Branch_Unit 
(
    input [2 : 0] funct3,
    input [2 : 0] instruction_type,

    input [31 : 0] rs1,
    input [31 : 0] rs2,
      
    output jump_branch_enable     // Goes to Fetch_Unit
);

    reg branch_enable;
    reg jump_enable;

    always @(*) 
    begin
            if (instruction_type == `B_TYPE)  // B-TYPE Instructions
                casex ({funct3})
                {`BEQ} :    if ($signed(rs1) == $signed(rs2))   branch_enable = 1'b1; 

                {`BNE} :    if ($signed(rs1) != $signed(rs2))   branch_enable = 1'b1;
                
                {`BLT} :    if ($signed(rs1) < $signed(rs2))    branch_enable = 1'b1;
                
                {`BGE} :    if ($signed(rs1) >= $signed(rs2))   branch_enable = 1'b1;
                
                {`BLTU} :   if (rs1 < rs2)                      branch_enable = 1'b1;
                
                {`BGEU} :   if (rs1 >= rs2)                     branch_enable = 1'b1;
                
                default:    branch_enable = 1'b0;
                endcase
            else
                branch_enable = 1'b0;

            if (instruction_type == `J_TYPE)
                jump_enable = 1'b1;
            else
                jump_enable = 1'b0;
      end  

      assign jump_branch_enable = jump_enable || branch_enable;
endmodule