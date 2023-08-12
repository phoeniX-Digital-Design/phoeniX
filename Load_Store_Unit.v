`include "Memory_Interface.v"

module Load_Store_Unit
(     
      input CLK,
      input [6 : 0] opcode,
      input [2 : 0] funct3,

      input [31 : 0] bus_rs1,   // For Address Generation
      input [31 : 0] immediate, // For Address Generation

      input  [31 : 0] Store_Data,
      output [31 : 0] Load_Data
);
      wire enable;
      wire read_enable;  // Load Instruction
      wire write_enable; // Store Instruction

      // -------------- INSTRUCTION DECODING MUST BE ADDED --------------

      // Memory_Interface data_memory (CLK, 1'b0, enable, read_enable, write_enable, address, Load_Data, Store_Data);

endmodule