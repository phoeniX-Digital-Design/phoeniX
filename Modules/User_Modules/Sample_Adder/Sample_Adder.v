module Sample_Adder 
(
    input [31 : 0] input_1, 
    input [31 : 0] input_2, 
    input [7  : 0] accuracy, 
    output reg [31 : 0] result
);

    reg [31 : 0] output_alu;

    always @(*) begin
        assign result = output_alu;
        if (accuracy == 0)
        begin 
            output_alu = input_1 + input_2;
        end
        else if (accuracy == 1)
        begin 
            output_alu = (input_1 + input_2) - 1;
        end
        else if (accuracy == 2)
        begin 
            output_alu = (input_1 + input_2) - 2;
        end
        // No accuracy control logic in adder
        else begin 
            output_alu = input_1 + input_2;
        end
    end
    
endmodule