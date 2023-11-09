module Fetch_Unit
(
	input enable,                    // Memory interface enable pin

    input [31 : 0] PC,

	input [31 : 0] jump_branch_address,         
	input jump_branch_enable,       
    
    // input [31 : 0] stall_address,
    // input stall_enable,

    output reg [31 : 0] next_PC,    // next instruction PC output
    
    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////

    output  reg  memory_interface_enable,
    output  reg  memory_interface_state,
    output  reg  [31 : 0]   memory_interface_address,
    output  reg  [ 3 : 0]   memory_interface_frame_mask
);
    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;

    always @(*) 
    begin
        memory_interface_enable = enable;
        memory_interface_state = READ;
        memory_interface_frame_mask = 4'b1111;
        memory_interface_address = PC;  
    end

    always @(*)
    begin
        if (jump_branch_enable) next_PC <= jump_branch_address;
        // else if (stall_enable)  next_PC <= stall_address;
        else                    next_PC <= PC + 32'd4;
    end
endmodule