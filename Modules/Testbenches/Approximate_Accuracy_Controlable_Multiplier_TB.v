`include "../Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Multiplier.v"

module Approximate_Accuracy_Controlable_Multiplier_TB;

    integer n = 20;
    integer i = 0;

    reg CLK = 1'b1;
    parameter T_CLK = 20;

    always #(T_CLK/2) CLK = ~CLK;

    parameter len = 16;
    reg  [len - 1 : 0] Multiplicand;
    reg  [len - 1 : 0] Multiplier;
    wire [2 * len - 1 : 0] Product;
    reg [2 * len - 1 : 0] Result;

    reg [6 : 0] Er = 7'b111_1111;

    reg enable = 1'b0;

    Approximate_Accuracy_Controlable_Multiplier uut 
    (
        CLK,
        enable,
        Er,
        Multiplicand,
        Multiplier,
        Product
    );

    initial 
    begin
        $dumpfile("Approximate_Accuracy_Controlable_Multiplier.vcd");
        $dumpvars(0, Approximate_Accuracy_Controlable_Multiplier_TB);

        // for (i = 0; i < n; i = i + 1)
        // begin
        //     Multiplicand = $random;
        //     Multiplier = $random;
        //     Result = Multiplicand * Multiplier;
        //     #(1*T_CLK);
        //     // $display("A = %d \t B = %d \t Result = %d -- Accurate = %d --> %b\n", Multiplicand, Multiplier, Product, Result, Product == Multiplicand * Multiplier);
        //     // #40;
        // end
        // #(3*T_CLK)
        #(55)
        enable = 1'b1;
        #(5)
        
        Multiplicand = $random;
        Multiplier = $random;
        Result = Multiplicand * Multiplier;
        #(6 * T_CLK);
        $display("A = %d \t B = %d \t Result = %d -- Accurate = %d --> %b\n", Multiplicand, Multiplier, Product, Result, Product == Multiplicand * Multiplier);
        #40;
        $finish;
    end
endmodule