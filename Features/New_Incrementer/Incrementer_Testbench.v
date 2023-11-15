`include "..\\Incrementer.v"

module Incrementer_Testbench;
    parameter LEN  = 30;

    reg   [LEN - 1 : 0]  value;
    wire  [LEN - 1 : 0]  result;

    Incrementer 
    #(
        .LEN(LEN)
    )
    uut 
    (
        .value(value),
        .result(result)
    );

    initial
    begin
        $display(uut.COUNT);
        value = $random;
        #10
        $display("value:\t%b", value);
        $display("result:\t%b\n", result);
        #10;

        value = $random;
        #10
        $display("value:\t%b", value);
        $display("result:\t%b\n", result);
        #10;

        value = $random;
        #10
        $display("value:\t%b", value);
        $display("result:\t%b\n", result);
        #10;

        value = $random;
        #10
        $display("value:\t%b", value);
        $display("result:\t%b\n", result);
        #10;
        $finish;
    end
endmodule