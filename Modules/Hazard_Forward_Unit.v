    /* --------------------------------------------------------------
    |    THE FOLLOWING MODULE IS ONLY THE BASE OF HAZARD DETECTION  |
    |    AND FORWARDING UNIT. THIS MODULE IS NOT COMPLETED YET      |
    |    AND IT WILL BE UPDATED SOON                                |
    -------------------------------------------------------------- */

module Hazard_Forward_Unit 
(
    input [4 : 0] source_index,          
    
    input [4 : 0] destination_index_1,
    input [4 : 0] destination_index_2,
    input [4 : 0] destination_index_3,

    input [31 : 0] data_1,
    input [31 : 0] data_2,
    input [31 : 0] data_3,
    
    output reg [31 : 0] forward_data
);

    always @(*) 
    begin
        if (source_index == destination_index_1)
            forward_data <= data_1;
        else if (source_index == destination_index_2)
            forward_data <= data_2;
        else if (source_index == destination_index_3)
            forward_data <= data_3;
    end
    
endmodule