`include "..\Modules\Fetch_Unit.v"

module Fetch_Testbench;
    parameter RESET_ADDRESS = 32'hFFFFFFFC;

    reg CLK = 1'b1;
    reg CLK_MEM = 1'b1;

    // Clock generation
    always #1 CLK_MEM = ~CLK_MEM;
    always #6 CLK = ~CLK;

    reg reset = 1'b1;
    reg enable = 1'b0;

    // uut input/ouput signals
    reg [31 : 0] PC;
    reg [31 : 0] instruction;

    reg [31 : 0] address;
    reg jump_branch_enable = 1'b0;

    wire [31 : 0] next_PC;   

    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////
    wire enable_Imem;
    wire memory_state_Imem;
    wire [31 : 0] address_Imem;
    wire [3 : 0] frame_mask_Imem;

    Fetch_Unit uut 
    (
        .enable(enable),
        
        .PC(PC),
        .address(address),
        .jump_branch_enable(jump_branch_enable),
            
        .next_PC(next_PC),

        .memory_interface_enable(enable_Imem),
        .memory_interface_memory_state(memory_state_Imem),
        .memory_interface_address(address_Imem),
        .memory_interface_frame_mask(frame_mask_Imem)
    );

    // Instrution Register Behaviour
    always @(posedge CLK)
    begin
        instruction <= data_in_Imem;    
    end

    // PC Register Behaviour
    always @(posedge CLK) 
    begin
        if (reset)
            PC <= RESET_ADDRESS;
        else
            PC <= next_PC; 
    end

    initial 
    begin
        $dumpfile("Fetch_Testbench.vcd");
        $dumpvars(0, Fetch_Testbench);

        $readmemh("firmware.hex", Memory);

        // Reset
        #14
        reset = 1'b1;
        enable = 1'b0;

        // Wait for a few clock cycles
        #12;
        reset  = 1'b0;
        enable = 1'b1;
        #58
        address = 32'h0;
        jump_branch_enable = 1'b1;
        #12
        jump_branch_enable = 1'b0;
        #100;
        $finish;
    end
    
    // Memory 
    reg [31 : 0] Memory [0 : 16 * 1024- 1];

    // Signals for Instruction Memory Interface
    reg [31 : 0] data_in_Imem;

    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;

    // Memeory Interface Behaviour
    always @(posedge CLK) 
    begin
        if (!instruction_memory_interface_enable) instruction_memory_interface_data <= 32'bz;
        else
        begin
            if (instruction_memory_interface_state == READ)
                instruction_memory_interface_data <= Memory[instruction_memory_interface_address >> 2];
        end    
    end
endmodule