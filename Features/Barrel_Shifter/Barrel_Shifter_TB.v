`include "Barrel_Shifter.v"

module Barrel_Shifter_Testbench;

    parameter WIDTH = 32;
    
    reg  [WIDTH - 1 : 0] value;
    reg  [$clog2(WIDTH) : 0] shift_amount;
    reg  direction;
    wire [WIDTH - 1 : 0] result;
    
    Barrel_Shifter #(WIDTH) uut 
    (
        .value(value),
        .shift_amount(shift_amount),
        .direction(direction),
        .result(result)
    );
    
    initial begin

        $dumpfile("Barrel_Shifter.vcd");
        $dumpvars(0, Barrel_Shifter_Testbench);

        value = 32'hFFFF_FFFF;
        shift_amount = 10;
        direction = 1'b0;
        #10
        $display("Value: %b", value);
        $display("Result: %b", result);
        #10;

        value = 32'hFFFF_FFFF;
        shift_amount = 10;
        direction = 1'b1;
        #10
        $display("Value: %b", value);
        $display("Result: %b", result);
        #10;
        
        $finish;

    end        
    
endmodule