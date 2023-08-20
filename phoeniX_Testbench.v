`timescale 1ns/100ps
`include "phoeniX.v"

module phoeniX_Testbench;
    reg CLK = 1'b1;
    reg CLK_MEM = 1'b1;

    reg reset = 1'b1;

    phoeniX uut
    (
        .CLK(CLK),
        .CLK_MEM(CLK_MEM),
        .reset(reset)
    );
    
    // Clock Generation
    always #1 CLK_MEM = ~CLK_MEM;
    always #6 CLK = ~CLK;

    initial
    begin
        $dumpfile("phoeniX.vcd");
        $dumpvars(0, phoeniX_Testbench);

        $readmemh("Instruction_Memory.txt", uut.fetch_unit.instruction_memory.Memory);

        // Reset
        #24
        reset = 1'b1;
        #12
        reset = 1'b0;
        #144
        $finish;
    end
endmodule