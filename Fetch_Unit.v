`include "Memory_Interface.v"

module Fetch_Unit 
(
    	input CLK,
	input enable,			// Memory Interface module enable pin (from Control Unit)

	input [31 : 0] address,		// Branch address generated in Address Generator
	input branch_enable,		// Generated in Branch Unit module
	input jump_enable,            // ******************************************************
    	input Reset, 			// Set PC address to 32'FFFC

	output [31 : 0] instruction,  // output "data" in Memory Interface module
	output fetch_done			// output "memory_done" in Memory Interface module
);

	wire [31 : 0] PC;
	wire [31 : 0] next_PC;

    	assign next_PC = branch_enable ? address : PC + 4;
	assign next_PC = jump_enable   ? address : PC + 4;

	assign PC = Reset ? 32'b0 - 4 : next_PC;

	Memory_Interface instruction_memory (CLK, enable, 1'b0, 4'b1111, PC/4, instruction, fetch_done);

endmodule