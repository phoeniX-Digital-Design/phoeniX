module Fetch_Unit
(
	input enable,                    

    input [31 : 0] pc,

	input [31 : 0] jump_branch_address,         
	input jump_branch_enable,       
    
    output reg [31 : 0] next_pc,  
    
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
        memory_interface_address = pc;  
    end

    always @(*)
    begin
        if (jump_branch_enable) next_pc <= jump_branch_address;
        else                    next_pc <= pc + 32'd4;
    end
endmodule