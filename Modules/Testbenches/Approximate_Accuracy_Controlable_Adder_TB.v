`include "../Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Adder.v"

`timescale 1ns / 1ns  

 module Approximate_Accuracy_Controlable_Adder_TB;  
 
    reg CLK = 0;

    reg [7  : 0] Error;
    reg [31 : 0] A;  
    reg [31 : 0] B;  
    reg Cin;

    wire [31 : 0] Sum;  
    wire Cout;

    Approximate_Accuracy_Controlable_Adder uut 
    (  
        .Er(Error),
        .A(A),   
        .B(B),   
        .Cin(Cin),   
        .Sum(Sum),   
        .Cout(Cout)
    );

    initial begin   
        forever #10 CLK = ~CLK;  
    end 

    initial begin
        $dumpfile("Approximate_Accuracy_Controlable_Adder.vcd");
        $dumpvars(0, Approximate_Accuracy_Controlable_Adder_TB);
        Error = 8'd0;
        A = 32'd3;  
        B = 32'd1;  
        Cin = 1'b0;
        #4000;  
        $display("%b", Sum);
        $finish;  
    end

 endmodule