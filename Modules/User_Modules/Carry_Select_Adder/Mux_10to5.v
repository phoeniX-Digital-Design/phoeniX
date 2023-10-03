module Mux_10to5 
(
    input [4 : 0] data_in_1,        // RCA output
    input [4 : 0] data_in_2,        // Basic Block output
    input select,                   // Input carry
    output reg [3 : 0] data_out,    // Data out
    output reg carry                // Output carry
);

    always @(*) 
    begin
        case (select)
            1'b0: begin data_out = data_in_1 [3 : 0]; carry = data_in_1 [4]; end
            1'b1: begin data_out = data_in_2 [3 : 0]; carry = data_in_2 [4];end
            default: data_out = 5'bz;
        endcase
    end

endmodule