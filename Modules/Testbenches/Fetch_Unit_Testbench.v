`include "../Fetch_Unit.v"

module Fetch_Unit_Testbench;
    
    reg enable = 1'b0;
    reg [31 : 0] PC_fetch_reg;
    reg jump_branch_enable = 1'b0;

    wire [31 : 0] next_PC_wire;

    

    Fetch_Unit uut (
        .enable(enable),
        .PC(PC_fetch_reg),
        .address(32'hDEADBEEF),         
        .jump_branch_enable(jump_branch_enable),       
        .next_PC(next_PC_wire),    

        .memory_interface_enable(instruction_memory_interface_enable),
        .memory_interface_state(instruction_memory_interface_state),
        .memory_interface_address(instruction_memory_interface_address),
        .memory_interface_frame_mask(instruction_memory_interface_frame_mask)  
    );


    ///////////////////////////////////
    //   4 MB Memory Instantiation   //
    ///////////////////////////////////
    reg [31 : 0] Memory [0 : 1024 * 1024 - 1];
    initial $readmemh(`FIRMWARE, Memory);
    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;

    // Instruction Memory Interface Behaviour
    always @(negedge CLK)
    begin
        if (!instruction_memory_interface_enable) instruction_memory_interface_data <= 32'bz;
        else
        begin
            if (instruction_memory_interface_state == READ)
                instruction_memory_interface_data <= Memory[instruction_memory_interface_address >> 2];
        end    
    end
endmodule