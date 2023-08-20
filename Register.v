module Register 
#(
    parameter WIDTH = 32
) 
(
    input CLK,
    input reset,
    input enable,
    input   [WIDTH - 1 : 0] RESET_VALUE,

    input   [WIDTH - 1 : 0] register_input,
    output reg [WIDTH - 1 : 0] register_output
);
    always @(posedge CLK)
    begin
        if (reset)
            register_output <= RESET_VALUE;
        if  (enable)
            register_output <= register_input;
        if (!enable)
            register_output <=  {WIDTH{1'bz}};
    end
endmodule