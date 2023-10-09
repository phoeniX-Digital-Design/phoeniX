`include "../Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Multiplier.v"

module Approximate_Accuracy_Controlable_Multiplier_TB;

    integer n = 20;
    integer i = 0;

    reg CLK = 0;
    always #10 CLK = ~CLK;

    parameter len = 8;
    reg  [len - 1 : 0] Multiplicand;
    reg  [len - 1 : 0] Multiplier;
    wire [2 * len - 1 : 0] Product;
    reg [6 : 0] Er = 7'b111_1111;

    Approximate_Accuracy_Controlable_Multiplier uut 
    (
        CLK,
        Er,
        Multiplicand,
        Multiplier,
        Product
    );

    initial 
    begin
        $dumpfile("Approximate_Accuracy_Controlable_Multiplier.vcd");
        $dumpvars(0, Approximate_Accuracy_Controlable_Multiplier_TB);

        for (i = 0; i < n; i = i + 1)
        begin
            Multiplicand = $random;
            Multiplier = $random;
            #60;
            
            $display("Test case %d:");
            $display("A = %d \t B = %d", Multiplicand, Multiplier);
            $display("Result = %d \t", Product);
            $display("\n\n\n");
            #40;
        end
        $finish;
    end
endmodule