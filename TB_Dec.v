`include "Instruction_Decoder.v"

module TB_Dec;

reg [31 : 0] instruction;

wire branch_signal;
wire [2 : 0] instruction_type;

wire [6 : 0] opcode;
wire [2 : 0] funct3;
wire [6 : 0] funct7;
wire funct3_valid;
wire funct7_valid;

wire [4 : 0] read_index_1;
wire [4 : 0] read_index_2;
wire [4 : 0] write_index;

Instruction_Decoder Inst_Dec (instruction, branch_signal, instruction_type, opcode, funct3, funct7, funct3_valid, funct7_valid, read_index_1, read_index_2, write_index);

initial begin
      #10 instruction = 32'h00000533;
      #10 $display("%d %b %b %b %d %d %d", instruction_type, opcode, funct3, funct7, read_index_1, read_index_2, write_index);
      #10 instruction = 32'hFCC5CCE3;
      #10 $display("%d %b %b %b %d %d %d", instruction_type, opcode, funct3, funct7, read_index_1, read_index_2, write_index);

end      
endmodule