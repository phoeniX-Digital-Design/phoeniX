`include "ACAPX_Adder.v"

module ACAPX_Adder_Testbench;

    integer n = 20;
    integer i = 0;

    parameter len = 32;
    parameter apx_len = 8;

    reg [apx_len - 1 : 0] Er = {4'b0, 4'b1};

    reg  [len - 1 : 0] A;
    reg  [len - 1 : 0] B;
    reg  Cin;


    wire [len - 1 : 0] Sum;
    wire Cout;

    reg [len : 0] res_check;

    ACAPX_Adder 
    #(
        .LEN(len),
        .APX_LEN(apx_len)
    )
    uut 
    (
        .Er(Er),
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial 
    begin
        $dumpfile("ACAPX_Adder.vcd");
        $dumpvars(0, ACAPX_Adder_Testbench);

        for (i = 0; i < n; i = i + 1)
        begin
            A = $random;
            B = $random;
            Cin = $random;
            res_check = A + B + Cin;
            #10;
            
            $display("Test case %d: %b", i, {Cout, Sum} == res_check);
            $display("A = %d \t B = %d \t Cin = %d", A, B, Cin);
            $display("Result = %d \t A + B + Cin = %d", {Cout, Sum}, res_check);
            // $display("Result = %b \t A + B + Cin = %b", {Cout, Sum}, res_check);
            $display("\n\n\n");
            #40;
        end
    end
endmodule