module Hazard_Forward_Unit 
(
    input [4 : 0] source_index,          
    
    input [4 : 0] destination_index_1,
    input [4 : 0] destination_index_2,
    input [4 : 0] destination_index_3,

    input [31 : 0] data_1,
    input [31 : 0] data_2,
    input [31 : 0] data_3,

    input enable_1,
    input enable_2,
    input enable_3,
    
    output reg forward_enable,
    output reg [31 : 0] forward_data
);

    always @(*) 
    begin
        if (source_index == destination_index_1 && enable_1 == 1'b1)
        begin
            forward_data <= data_1;
            forward_enable <= 1'b1;
        end
            
        else if (source_index == destination_index_2 && enable_2 == 1'b1)
        begin
            forward_data <= data_2;
            forward_enable <= 1'b1;
        end
            
        else if (source_index == destination_index_3 && enable_3 == 1'b1)
        begin
            forward_data <= data_3;
            forward_enable <= 1'b1;
        end
        else
        begin
            forward_data <= 32'bz;
            forward_enable <= 1'b0;
        end
    end
endmodule