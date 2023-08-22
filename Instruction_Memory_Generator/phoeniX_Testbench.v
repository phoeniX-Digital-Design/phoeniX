`timescale 1ns/1ns
`include "phoeniX.v"

module phoeniX_Testbench;
    integer data_memory_file;
    parameter ADDRESS_WIDTH = 10;

    reg CLK = 1'b1;
    reg CLK_MEM = 1'b1;

    reg reset = 1'b1;

    phoeniX 
    #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    uut
    (
        .CLK(CLK),
        .CLK_MEM(CLK_MEM),
        .reset(reset)
    );
    
    // Clock Generation
    always #1 CLK_MEM = ~CLK_MEM;
    always #6 CLK = ~CLK;

    // Debug Wires for Register File

    wire [31 : 0] x0_zero 	= uut.register_file.Registers[0];
    wire [31 : 0] x1_ra 	= uut.register_file.Registers[1];
    wire [31 : 0] x2_sp 	= uut.register_file.Registers[2];
    wire [31 : 0] x3_gp 	= uut.register_file.Registers[3];
    wire [31 : 0] x4_tp 	= uut.register_file.Registers[4];
    wire [31 : 0] x5_t0 	= uut.register_file.Registers[5];
    wire [31 : 0] x6_t1 	= uut.register_file.Registers[6];
    wire [31 : 0] x7_t2 	= uut.register_file.Registers[7];
    wire [31 : 0] x8_s0 	= uut.register_file.Registers[8];
    wire [31 : 0] x9_s1 	= uut.register_file.Registers[9];
    wire [31 : 0] x10_a0 	= uut.register_file.Registers[10];
    wire [31 : 0] x11_a1 	= uut.register_file.Registers[11];
    wire [31 : 0] x12_a2 	= uut.register_file.Registers[12];
    wire [31 : 0] x13_a3 	= uut.register_file.Registers[13];
    wire [31 : 0] x14_a4 	= uut.register_file.Registers[14];
    wire [31 : 0] x15_a5 	= uut.register_file.Registers[15];
    wire [31 : 0] x16_a6 	= uut.register_file.Registers[16];
    wire [31 : 0] x17_a7 	= uut.register_file.Registers[17];
    wire [31 : 0] x18_s2 	= uut.register_file.Registers[18];
    wire [31 : 0] x19_s3 	= uut.register_file.Registers[19];
    wire [31 : 0] x20_s4 	= uut.register_file.Registers[20];
    wire [31 : 0] x21_s5 	= uut.register_file.Registers[21];
    wire [31 : 0] x22_s6 	= uut.register_file.Registers[22];
    wire [31 : 0] x23_s7 	= uut.register_file.Registers[23];
    wire [31 : 0] x24_s8 	= uut.register_file.Registers[24];
    wire [31 : 0] x25_s9 	= uut.register_file.Registers[25];
    wire [31 : 0] x26_s10 	= uut.register_file.Registers[26];
    wire [31 : 0] x27_s11 	= uut.register_file.Registers[27];
    wire [31 : 0] x28_t3 	= uut.register_file.Registers[28];
    wire [31 : 0] x29_t4 	= uut.register_file.Registers[29];
    wire [31 : 0] x30_t5 	= uut.register_file.Registers[30];
    wire [31 : 0] x31_t6 	= uut.register_file.Registers[31];

    initial
    begin
        $dumpfile("phoeniX.vcd");
        $dumpvars(0, phoeniX_Testbench);

		$readmemh("Sample_Codes\\Test_RV32I_BubbleSort.mem", uut.fetch_unit.instruction_memory.Memory);
        
        // Reset
        #24
        reset = 1'b1;
        #12
        reset = 1'b0;
        
        #8000
        data_memory_file = $fopen("Sample_Codes\\Test_RV32I_max_array_data.mem", "w");

        for (integer i = 0; i < 2 ** ADDRESS_WIDTH; i = i + 4)
        begin
            $fdisplay(  data_memory_file, "%h\t%h\t%h\t%h\t%h",
                        i, 
                        uut.load_store_unit.data_memory.Memory[i],
                        uut.load_store_unit.data_memory.Memory[i + 1],
                        uut.load_store_unit.data_memory.Memory[i + 2],
                        uut.load_store_unit.data_memory.Memory[i + 3]);
        end
        $finish;
    end
endmodule