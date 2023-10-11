`include "../Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Divider.v"

`timescale 1ns / 1ns  

 module Approximate_Accuracy_Controlable_Divider_TB;  
 
    reg CLK = 0;

    reg [7  : 0] Error;
    reg [31 : 0] operand_1;  
    reg [31 : 0] operand_2;  
 
    wire [31 : 0] div;  
    wire [31 : 0] rem;  
    wire busy;

    Approximate_Accuracy_Controlable_Divider uut 
    (  
        .CLK(CLK),    
        .Er(Error),
        .operand_1(operand_1),   
        .operand_2(operand_2),   
        .div(div),   
        .rem(rem),   
        .busy(busy)
    );

    initial begin   
        forever #10 CLK = ~CLK;  
    end 

    initial begin
        $dumpfile("Approximate_Accuracy_Controlable_Divider.vcd");
        $dumpvars(0, Approximate_Accuracy_Controlable_Divider_TB);
        Error     = 8'b1111_1111;
        operand_1 = 32'd1023;  
        operand_2 = 32'd50;  
        #4000;  
        $display("div = %d - rem = %d - busy = %b", div, rem, busy);
        Error     = 8'b1111_1111;
        operand_1 = 32'd2000;  
        operand_2 = 32'd80;  
        #4000;  
        $display("div = %d - rem = %d - busy = %b", div, rem, busy);
        Error     = 8'b1111_1111;
        operand_1 = 32'd725;  
        operand_2 = 32'd50;  
        #4000;  
        $display("div = %d - rem = %d - busy = %b", div, rem, busy);
        $finish;  
    end

 endmodule