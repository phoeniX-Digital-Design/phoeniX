`include "..\\Immediate_Generator.v"

module TB;

reg [31 : 0] instruction;
reg [2 : 0] instruction_type;

wire [31 : 0] immediate;

Immediate_Generator imm (instruction, instruction_type, immediate);

initial begin
      #10;
      instruction = 32'h06200613;
      instruction_type = 0;
      #10 $display("IMM = %d", immediate);
      #10;
end
      
endmodule