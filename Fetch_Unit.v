`include "Register.v"
`include "Memory_Interface.v"

module Fetch_Unit 
(
    input CLK,
    input Reset,

	input branch_enable,
	input [31 : 0] immediate,

	output [31 : 0] PC,
	output [31 : 0] instruction
);

	wire [31 : 0] branch_target;
	wire [31 : 0] next_PC;
	wire [31 : 0] PC_register_input;

	assign branch_target = PC + immediate;
	assign next_PC = branch_enable ? branch_target : PC + 4;
	assign PC_register_input = Reset ? 32'b0 - 4 : next_PC;

	Register pc_register (CLK, enable, PC_register_input, PC);

    //   Memory_Interface instruction_memory (CLK, Reset, 1'b1, 1'b1, 1'b0, PC/4, 32'b0, instruction);
      
endmodule