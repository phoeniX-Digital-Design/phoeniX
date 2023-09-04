module Clock_Generator 
#(
    parameter DIVIDER = 10
)
(
    input        reset,
    input        clk_in,    // Input clock
    output reg   clk_out    // Output clock
);

    reg [DIVIDER - 1 : 0] count = 0;        // Counter for clock division

    always @(posedge reset) begin           // Always needs a restart signal tp initialize output clock
        clk_out <= 1'b0;
    end

    always @(posedge clk_in) begin
        if (count == DIVIDER - 1) begin     // Reset counter when it reaches the division factor
            count <= 0;
            clk_out <= ~clk_out; 
        end else
            count <= count + 1;
    end

endmodule

