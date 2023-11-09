`include "Kogge_Stone_Adder.v"

module Kogge_Stone_Adder_Testbnech;

    reg  [31 : 0] a; 
    reg  [31 : 0] b; 
    reg           c_in;
    wire [31 : 0] sum;
    wire          c_out;

    reg  [32 : 0] check;   // 33-bit value to check correctness
    integer num_correct;   // counter to keep track of the number correct
    integer num_wrong;     // counter to keep track of the number wrong

    Kogge_Stone_Adder kogge_stone_adder
    (   
        .carry_in(c_in), 
        .input_A(a), 
        .input_B(b), 
        .sum(sum), 
        .carry_out(c_out)
    );

    integer i, j, k;
    initial begin
    $display("Running testbench, this may take a minute or two...");
    num_correct = 0; num_wrong = 0;
    for (i = 0; i < 200; i = i + 1) begin
        a = i;
        for (j = 0; j < 200; j = j + 1) 
        begin
            b = j;
            for (k = 0; k < 2; k = k + 1) 
            begin
                c_in = k;
                check = a + b + c_in;
                // compute and check the product
                #2;
                if ({c_out, sum} == check) begin
                    num_correct = num_correct + 1;
                end else begin
                    num_wrong = num_wrong + 1;
                end
                $display($time, " %d + %d + %d = %d (correct = %d)", a, b, c_in, {c_out, sum}, check);
            end
        end
    end
    $display("num_correct = %d, num_wrong = %d", num_correct, num_wrong);
    $finish;
    end

endmodule