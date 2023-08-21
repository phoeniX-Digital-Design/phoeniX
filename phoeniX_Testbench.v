`timescale 1ns/1ns
`include "phoeniX.v"

module phoeniX_Testbench;
    integer data_memory_file;

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
    wire [31 : 0] x6 	= uut.register_file.Registers[6];
    wire [31 : 0] x7 	= uut.register_file.Registers[7];
    wire [31 : 0] x8 	= uut.register_file.Registers[8];
    wire [31 : 0] x9 	= uut.register_file.Registers[9];
    wire [31 : 0] x10 	= uut.register_file.Registers[10];
    wire [31 : 0] x11 	= uut.register_file.Registers[11];
    wire [31 : 0] x12 	= uut.register_file.Registers[12];
    wire [31 : 0] x13 	= uut.register_file.Registers[13];
    wire [31 : 0] x14 	= uut.register_file.Registers[14];
    wire [31 : 0] x15 	= uut.register_file.Registers[15];
    wire [31 : 0] x16 	= uut.register_file.Registers[16];
    wire [31 : 0] x17 	= uut.register_file.Registers[17];
    wire [31 : 0] x18 	= uut.register_file.Registers[18];
    wire [31 : 0] x19 	= uut.register_file.Registers[19];
    wire [31 : 0] x20 	= uut.register_file.Registers[20];
    wire [31 : 0] x21 	= uut.register_file.Registers[21];
    wire [31 : 0] x22 	= uut.register_file.Registers[22];
    wire [31 : 0] x23 	= uut.register_file.Registers[23];
    wire [31 : 0] x24 	= uut.register_file.Registers[24];
    wire [31 : 0] x25 	= uut.register_file.Registers[25];
    wire [31 : 0] x26 	= uut.register_file.Registers[26];
    wire [31 : 0] x27 	= uut.register_file.Registers[27];
    wire [31 : 0] x28 	= uut.register_file.Registers[28];
    wire [31 : 0] x29 	= uut.register_file.Registers[29];
    wire [31 : 0] x30 	= uut.register_file.Registers[30];
    wire [31 : 0] x31 	= uut.register_file.Registers[31];

    initial
    begin
        $dumpfile("phoeniX.vcd");
        $dumpvars(0, phoeniX_Testbench);

        $readmemh("Sample_Codes\\Test_RV32I_Simple.mem", uut.fetch_unit.instruction_memory.Memory);

        // Reset
        #24
        reset = 1'b1;
        #12
        reset = 1'b0;
        
        #8100
        data_memory_file = $fopen("Sample_Codes\\Test_RV32I_Simple_data.mem", "w");
        // $display("%d", uut.load_store_unit.data_memory.Memory.DEPTH);
        for (integer i = 0; i < 256; i = i + 1)
        begin
            $fdisplay(data_memory_file, "%h", uut.load_store_unit.data_memory.Memory[i]);
        end
        $finish;
    end
endmodule