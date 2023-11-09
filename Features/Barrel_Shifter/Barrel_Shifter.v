`ifndef DIRECTION
    `define RIGHT direction
    `define LEFT  !direction
`endif 

module Barrel_Shifter #(parameter WIDTH = 32)
(
    input  [WIDTH - 1      : 0]   value,
    input  [$clog2(WIDTH)  : 0]   shift_amount,
    input                         direction,
    output reg [WIDTH - 1  : 0]   result
);

    reg [WIDTH - 1 : 0] shifted;

    always @(*)
    begin
        // Right shift
        if (`RIGHT)
        begin
            shifted = value;
            for (integer i = 0 ; i < WIDTH ; i = i + 1)
            begin
                if (i < WIDTH - shift_amount)
                    result[i] = shifted[i + shift_amount];
                else
                    result[i] = 0;
            end
        end 
        // Left shift
        if (`LEFT)
        begin
            shifted = value;
            for (integer i = 0 ; i < WIDTH ; i = i + 1)
            begin
                if (i < shift_amount)
                    result[i] = 0;
                else
                    result[i] = shifted[i - shift_amount];
            end
        end 
    end

endmodule