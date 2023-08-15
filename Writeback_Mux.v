module Writeback_Mux 
(
      input  writeback_output_select,     // Signal from Control Unit
      input  [31 : 0] load_data,          // LSU Load instruction output
      input  [31 : 0] execution_output,   // Execution stage latched output

      output [31 : 0] writeback_output
);

      assign writeback_output = writeback_output_select ? load_data : execution_output;
      
endmodule