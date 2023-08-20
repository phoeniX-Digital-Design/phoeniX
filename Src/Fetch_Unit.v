`include "Memory_Interface.v"
// `include "..\\Memory_Interface.v"

module Fetch_Unit 
(
    input CLK,
	input enable,			                                // Memory Interface module enable pin (from Control Unit)

    input [31 : 0] PC,

	input [31 : 0] address,		                            // Branch or Jump address generated in Address Generator
	input jump_branch_enable,		                        // Generated in Branch Unit module

    output [31 : 0] next_PC,
	output reg [31 : 0] fetched_instruction                // output "data" in Memory Interface module
	// output fetch_done			                            // output "memory_done" in Memory Interface module
);
    wire    [31 : 0] fetched_instruction_wire;
    wire fetch_done;

	Memory_Interface instruction_memory 
    (
        .CLK(CLK),
        .enable(enable), 
        .memory_state(instruction_memory.READ),
        .frame_mask(4'b1111),
        .address(PC), 
        .data(fetched_instruction_wire), 
        .memory_done(fetch_done)
    );

    assign next_PC = jump_branch_enable ? address : PC + 32'd4;

    always @(posedge fetch_done) 
    begin
        fetched_instruction <= fetched_instruction_wire;
    end

endmodule