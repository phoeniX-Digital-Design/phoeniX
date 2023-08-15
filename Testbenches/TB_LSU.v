`timescale 1ns/1ns
`include "..\\Load_Store_Unit.v"

module TB_LSU;

    reg CLK     = 1'b1;
    reg CLK_MEM = 1'b1;

    reg enable = 1'b0;

    reg  [6 : 0] opcode = 7'bz;
    reg  [2 : 0] funct3 = 3'bz;

    reg  [31 : 0] address = 32'bz;
    reg  [31 : 0] store_data = 32'bz; 
        
    wire [31 : 0] load_data; // variable is declared as "output reg" in the main module

    // Clock generation
    always #1 CLK_MEM = ~CLK_MEM;
    always #6 CLK = ~CLK;
    
    Load_Store_Unit uut 
    (
        CLK_MEM,
        enable,
        opcode,
        funct3,
        address,
        store_data,
        load_data
    );

    initial 
    begin
        $dumpfile("Test_LSU.vcd");
        $dumpvars(0, TB_LSU);

        $readmemh("..\\Instruction_Memory.txt", uut.data_memory.Memory);

        // Wait for a few clock cycles

        // --> Load Word (32 bits) from address 16
        #12
        address = 32'd16;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        enable = 1'b1;

        #12
        enable = 1'b0;
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;
        
        // --> Load Byte (8 bits) from address 19 zero extend the result to 32 bits
        #12
        address = 32'd19;

        opcode = 7'b0000011;
        funct3 = 3'b100;
        enable = 1'b1;

        #12
        enable = 1'b0;
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Load Word (32 bits) from address 20
        #12 
        address = 32'd20;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        enable = 1'b1;

        #12
        enable = 1'b0;
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Store Word (32 bits) to address 20
        #12 
        address = 32'd20;
        store_data = 32'hFEDCBA98;
        opcode = 7'b0100011;
        funct3 = 3'b010;
        enable = 1'b1;

        #12
        enable = 1'b0;
        address = 32'bz;
        store_data = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Load Word (32 bits) from address 20
        #12 
        address = 32'd20;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        enable = 1'b1;

        #12
        enable = 1'b0;
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Store Half-Word (16 bits) to address 22
        #12 
        address = 32'd22;
        store_data = 32'hBABA;
        opcode = 7'b0100011;
        funct3 = 3'b001;
        enable = 1'b1;

        #12
        enable = 1'b0;
        address = 32'bz;
        store_data = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Load Word (32 bits) from address 20
        #12 
        address = 32'd20;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        enable = 1'b1;

        #12
        enable = 1'b0;
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Store Byte (8 bits) to address 22
        #12 
        address = 32'd22;
        store_data = 32'hAB;
        opcode = 7'b0100011;
        funct3 = 3'b000;
        enable = 1'b1;

        #12
        enable = 1'b0;
        address = 32'bz;
        store_data = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Load Word (32 bits) from address 20
        #12 
        address = 32'd20;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        enable = 1'b1;

        #12
        enable = 1'b0;
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        #12;
        $finish;
    end
endmodule