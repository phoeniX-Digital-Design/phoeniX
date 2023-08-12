module Register
(
    input CLK,
    input enable,
    input [31 : 0] register_input,
    
    output reg [31 : 0] register_output
);
    always @(negedge CLK)
    begin
        if(enable)
            register_output <= register_input;
    end
    
endmodule