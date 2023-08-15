module Control_Unit 
(
      input [6 : 0] opcode,               // inputs from Instruction Decoder
      input [2 : 0] funct3,               // inputs from Instruction Decoder
      input [6 : 0] funct7,               // inputs from Instruction Decoder
      input [2 : 0] instruction_type,     // inputs from Instruction Decoder

      input fetch_done,                   // Fetch operation end signal from Fetch Unit

      output address_type,                // select type for Address Generator module

      output [2 : 0] mux1_select,         // ALU multiplexer select pin
      output [2 : 0] mux2_select,         // ALU multiplexer select pin

      output fetch_enable,                // Fetch Unit enable pin

      output lsu_enable,                  // Load Store Unit enable pin

      output read_enable_1,               // Register File read port 1 enable
      output read_enable_2,               // Register File read port 2 enable
      output write_enable,                // Register File write port enable

      output IR_enable,                   // Instruction Register enbale pin
      output PC_enable,                   // Program Counter enbale pin

      output writeback_output_signal      // Writeback stage output select  between
                                          // execution unit output and LSU output
);
      
endmodule