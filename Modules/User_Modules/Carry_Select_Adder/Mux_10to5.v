module MUX_10to5 
(
    input [3 : 0] data_in_1,        // RCA output
    input [3 : 0] data_in_2,        // Basic Block output
    input select,                   // Select pin = Carry

    input carry_in_1,               // Input carry 1
    input carry_in_2,               // Input carry 2

    output reg [3 : 0] data_out,    // Data out
    output reg carry_out            // Output carry
);

    always @(*) 
    begin
        case (select)
            1'b0: begin data_out = data_in_1; carry_out = carry_in_1; end
            1'b1: begin data_out = data_in_2; carry_out = carry_in_2; end
            default: begin data_out = 4'bz; carry_out = 1'bz; end
        endcase
    end

endmodule