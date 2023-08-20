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

    // Debug Wires for Register File

    wire [31 : 0] x0 	= uut.register_file.Registers[0];
    wire [31 : 0] x1 	= uut.register_file.Registers[1];
    wire [31 : 0] x2 	= uut.register_file.Registers[2];
    wire [31 : 0] x3 	= uut.register_file.Registers[3];
    wire [31 : 0] x4 	= uut.register_file.Registers[4];
    wire [31 : 0] x5 	= uut.register_file.Registers[5];
    wire [31 : 0] x10 	= uut.register_file.Registers[10];
    wire [31 : 0] x11 	= uut.register_file.Registers[11];
    wire [31 : 0] x12 	= uut.register_file.Registers[12];
        
    initial
    begin
        $dumpfile("phoeniX.vcd");
        $dumpvars(0, phoeniX_Testbench);

        $readmemh("Test_RV32I_HEX.txt", uut.fetch_unit.instruction_memory.Memory);

        // Reset
        #24
        reset = 1'b1;
        #12
        reset = 1'b0;
        #1440
        $finish;
    end
endmodule