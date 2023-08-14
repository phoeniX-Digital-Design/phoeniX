`include "Fetch_Unit.v"

module TB_Fetch;

    reg CLK = 1'b0;
    reg enable;

    reg [31 : 0] address;
    reg branch_enable;
    reg jump_enable;
    reg Reset;
    
    wire [31 : 0] instruction;
    reg  [31 : 0] instruction_reg;

    assign instruction = instruction_reg;
    
    wire fetch_done;

    Fetch_Unit uut 
    (
        CLK,
        enable,
        address,
        branch_enable,
        jump_enable,
        Reset,
        instruction,
        fetch_done
    );

    // Clock generation
    always #1 CLK = ~CLK;
    
    // Memory Initialize
    

    initial begin

        $dumpfile("Test_Fetch.vcd");
        $dumpvars(0, TB_Fetch);

        $readmemh("Instruction_Memory.txt", uut.instruction_memory.Memory);

        instruction_reg = 32'bz;

        // Reset
        #10;
        Reset = 1'b1;
        enable = 1'b1;
        address = 32'b0;
        branch_enable = 1'b0;
        jump_enable = 1'b0;
        $display ("--> Testing Fetch Operation: ADDRESS = %h\tDATA = %h\n", address, instruction);

        // Wait for a few clock cycles
        #10;
        enable = 1'b0;
        Reset  = 1'b0;

        // Fetch Test
        #1 enable = 1'b1;
        branch_enable = 1'b1;
        jump_enable   = 1'b0;
        address = 32'h04;
        #10
        enable = 1'b0;
        $display ("--> Testing Fetch Operation: ADDRESS = %h\tDATA = %h\n", address, instruction);
        #10;

        $finish;
    end

endmodule