module Writeback_Mux 
(
    input  [1  : 0] writeback_output_select,        // Signal from Control Unit
    input  [31 : 0] immediate,                      // Immediate data
    input  [31 : 0] load_data,                      // LSU Load instruction output
    input  [31 : 0] execution_output,               // Execution stage latched output

    output reg [31 : 0] writeback_output
);
    always @(*) 
    begin    
        case (writeback_output_select)
            2'b00 : writeback_output = immediate; 
            2'b01 : writeback_output = load_data;
            2'b10 : writeback_output = execution_output;
        endcase
    end
endmodule