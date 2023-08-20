module Register #(
    parameter WIDTH = 32
)
(
    input CLK,
    input reset,
    input enable,
    input   [WIDTH : 0] RESET_ADDRESS,

    input   [WIDTH : 0] register_input,
    output reg [31 : 0] register_output
);
    always @(posedge CLK)
    begin
        if (reset)
            register_output <= RESET_ADDRESS;
        else if(enable)
            register_output <= register_input;
        else
            register_output <=  {WIDTH{1'bz}};
    end
endmodule