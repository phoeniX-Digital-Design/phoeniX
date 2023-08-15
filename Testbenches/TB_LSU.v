`include "..\\Load_Store_Unit.v"

module TB_LSU;

reg CLK     = 1'b1;
reg CLK_MEM = 1'b1;

reg enable;

reg  [6 : 0] opcode;
reg  [2 : 0] funct3;

reg  [31 : 0] address;
reg  [31 : 0] store_data; 
    
wire [31 : 0] load_data; // variable is declared as "output reg" in the main module

// Clock generation
always #1 CLK_MEM = ~CLK_MEM;
always #6 CLK = ~CLK;


Load_Store_Unit LSU 
(
      CLK_MEM,
      enable,
      opcode,
      funct3,
      address,
      store_data,
      load_data
);


initial begin

        $dumpfile("Test_LSU");
        $dumpvars(0, TB_LSU);

        $readmemh("..\\Instruction_Memory.txt", uut.data_memory.Memory);

        // No memory operation
        #14
        enable = 1'b0;

        // Wait for a few clock cycles
        #12;
        enable = 1'b1;
        
        #36
        address = 32'h0;
        opcode  = 7'b0000011;
        funct3  = 3'b000;
        #1 $display("load data = %h", load_data);
        
        #12
        address = 32'h4;
        opcode  = 7'b0100011;
        funct3  = 3'b000;
        store_data = 8'b0000_1111;
        #1 $display("store data = %h", store_data);

        #100;
        $finish;
    end


endmodule