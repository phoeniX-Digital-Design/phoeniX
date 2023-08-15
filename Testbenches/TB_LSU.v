`include "..\\Load_Store_Unit.v"

module TB;

reg CLK     = 1'b1;
reg CLK_MEM = 1'b1;

reg enable;

reg  [6 : 0] opcode,
reg  [2 : 0] funct3,

reg  [31 : 0] address,
reg  [31 : 0] store_data, 
    
reg [31 : 0] load_data // variable is declared as "output reg" in the main module

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

endmodule