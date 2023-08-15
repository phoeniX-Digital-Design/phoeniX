`include "..\\Fetch_Unit.v"

module TB_Fetch;

    parameter RESET_ADDRESS = 32'hFFFFFFFC;

    reg CLK = 1'b1;
    reg CLK_MEM = 1'b1;

    reg reset = 1'b1;
    reg enable = 1'b0;

    reg [31 : 0] PC;
    reg [31 : 0] instruction;

    reg [31 : 0] address_generated;
    reg jump_branch_enable = 1'b0;

    wire [31 : 0] next_PC;   
    wire [31 : 0] latched_instruction;
    wire fetch_done;

    Fetch_Unit uut 
    (
        CLK_MEM,
        enable,
        
        PC,
        address_generated,
        jump_branch_enable,
            
        next_PC,
        latched_instruction,
        fetch_done
    );

    // Instrution Register Behaviour
    always @(posedge CLK)
    begin
        instruction <= latched_instruction;    
    end

    // PC Register Behaviour
    always @(posedge CLK) 
    begin
        if (reset)
            PC <= RESET_ADDRESS;
        else
            PC <= next_PC; 
    end

    // Clock generation
    always #1 CLK_MEM = ~CLK_MEM;
    always #6 CLK = ~CLK;

    initial 
    begin

        $dumpfile("Test_Fetch.vcd");
        $dumpvars(0, TB_Fetch);

        $readmemh("..\\Instruction_Memory.txt", uut.instruction_memory.Memory);

        // Reset
        #14
        reset = 1'b1;
        enable = 1'b0;

        // Wait for a few clock cycles
        #12;
        reset  = 1'b0;
        #10;
        enable = 1'b1;
        #36
        address_generated = 32'h0;
        jump_branch_enable = 1'b1;
        #12
        jump_branch_enable = 1'b0;
        #100;
        $finish;
    end

endmodule