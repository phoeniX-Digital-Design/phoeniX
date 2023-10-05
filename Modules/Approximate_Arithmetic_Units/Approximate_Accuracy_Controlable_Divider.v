module Approximate_Accuracy_Controlable_Divider 
(
    input CLK,
    input [31 : 0] input_1, 
    input [31 : 0] input_2, 
    input [7  : 0] accuracy, 
    output busy, 
    output reg [31 : 0] result,
    output reg [31 : 0] remainder
);
    reg [31 : 0] output_div;

    always @(*) begin
        assign result = output_div;
        if (accuracy == 0)
        begin 
            output_div = input_1 / input_2;
            remainder  = input_1 % input_2;
        end
        else if (accuracy == 1)
        begin 
            output_div = (input_1 / input_2) - 1;
            remainder  = input_1 % input_2;
        end
        else if (accuracy == 2)
        begin 
            output_div = (input_1 / input_2) - 2;
            remainder  = input_1 % input_2;
        end
        // No accuracy control logic in divider
        else begin 
            output_div = input_1 / input_2;
            remainder  = input_1 % input_2;
        end
    end
    
endmodule