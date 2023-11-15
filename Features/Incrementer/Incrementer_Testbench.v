`include "Incrementer.v"

module Incrementer_Testbench;
    parameter WIDTH = 30;

    reg  [WIDTH - 1 : 0] A;
    wire [WIDTH - 1 : 0] B;

    Incrementer uut 
    (
        .operand_1(A),
        .result(B)
    );
    
    initial begin
        A = $random;
        #10
        $display("A: %b", A);
        $display("B: %b", B);
        #10;

        A = $random;
        #10
        $display("A: %b", A);
        $display("B: %b", B);
        #10;

        A = $random;
        #10
        $display("A: %b", A);
        $display("B: %b", B);
        #10;

        $finish;
    end      
endmodule