`include "Clock_Generator.v"

module Clock_Generator_Testbench;

    reg  reset;
    reg  clk_in;
    wire clk_out;

    Clock_Generator #(.DIVIDER(10)) uut 
    (
        .reset(reset),
        .clk_in(clk_in),
        .clk_out(clk_out)
    );

    always begin
        #5 clk_in = ~clk_in;  // Toggle the input clock every 5 time units
    end

    initial begin
        $dumpfile("Clock_Generator.vcd");
        $dumpvars(0, Clock_Generator_Testbench);
        reset  = 1;   // Restart : Initialize output clock
        clk_in = 0;   // Initialize input clock
        #20 
        reset = 0;    // Start cLock generation
        #2000 $finish;
    end

endmodule