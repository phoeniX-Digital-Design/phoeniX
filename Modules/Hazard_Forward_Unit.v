`include "Defines.v"

module Hazard_Forward_Unit 
(
    input wire [ 4 : 0] source_index,          
    
    input wire [ 4 : 0] destination_index_1,
    input wire [ 4 : 0] destination_index_2,

    input wire [31 : 0] data_1,
    input wire [31 : 0] data_2,

    input wire enable_1,
    input wire enable_2,
    
    output reg forward_enable,
    output reg [31 : 0] forward_data
);

    always @(*) 
    begin
        if (source_index == destination_index_1 && enable_1 == `ENABLE)
        begin
            forward_data <= data_1;
            forward_enable <= `ENABLE;
        end
            
        else if (source_index == destination_index_2 && enable_2 == `ENABLE)
        begin
            forward_data <= data_2;
            forward_enable <= `ENABLE;
        end
            
        else
        begin
            forward_data <= 32'bz;
            forward_enable <= `DISABLE;
        end
    end
endmodule