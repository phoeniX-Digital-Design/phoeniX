module Fetch_Unit
(
	input enable,                                       // Memory Interface module enable pin (from Control Unit)

    input [31 : 0] PC,

	input [31 : 0] address,                             // Branch or Jump address generated in Address Generator
	input jump_branch_enable,                           // Generated in Branch Unit module

    output [31 : 0] next_PC,                            // next instruction PC output
    
    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////

    output  reg  memory_interface_enable,
    output  reg  memory_interface_memory_state,
    output  reg  [31 : 0]   memory_interface_address,
    output  reg  [3 : 0]    memory_interface_frame_mask
);
    localparam  READ        = 1'b0,
                WRITE       = 1'b1;

    always @(*) 
    begin
        memory_interface_enable = enable;
        memory_interface_memory_state = READ;
        memory_interface_frame_mask = 4'b1111;
        memory_interface_address = PC;  
    end

    assign next_PC = jump_branch_enable ? address : PC + 32'd4;
endmodule