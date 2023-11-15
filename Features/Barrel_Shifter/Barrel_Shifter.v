module Barrel_Shifter
(
    input  [31 : 0] input_value, 
    input  [4  : 0] shift_amount, 
    input           direction,  // direction = 1 : RIGHT / direction = 0 : LEFT 
    output [31 : 0] result 
);

    wire [31 : 0] shift_mux_0; 
    wire [31 : 0] shift_mux_1; 
    wire [31 : 0] shift_mux_2; 
    wire [31 : 0] shift_mux_3; 
    wire [31 : 0] shift_mux_4; 
    wire [31 : 0] reversed;
     
    // reverse -> shift right -> then reverse again
    Reverser_Circuit #(.N(32)) RC1 (input_value, direction, reversed);

    // Stage 0: shift 0 or 1 bit
    assign shift_mux_0 = shift_amount[0] ? {1'b0,  reversed[31 : 1]} : reversed;
    // Stage 1: shift 0 or 2 bits 
    assign shift_mux_1 = shift_amount[1] ? {2'b0,  shift_mux_0[31 : 2]} : shift_mux_0;
    // Stage 2: shift 0 or 4 bits 
    assign shift_mux_2 = shift_amount[2] ? {4'b0,  shift_mux_1[31 : 4]} : shift_mux_1;
    // Stage 3: shift 0 or 8 bits 
    assign shift_mux_3 = shift_amount[3] ? {8'b0,  shift_mux_2[31 : 8]} : shift_mux_2;
    // Stage 4: shift 0 or 16 bits 
    assign shift_mux_4 = shift_amount[4] ? {16'b0, shift_mux_3[31 : 16]} : shift_mux_3;

    // Reverse again 
    Reverser_Circuit #(.N(32)) RC2 (shift_mux_4, direction, result);

endmodule

module Reverser_Circuit
#(parameter N = 32)
(
    input  [N - 1 : 0]  input_value, 
    input               enable, 
    output [N - 1 : 0]  reversed_value
);

    wire [N - 1 : 0] temp;
    generate
        genvar i;
        for (i = 0 ; i <= N - 1 ; i = i + 1)
            assign temp[i] = input_value[N - 1 - i];
    endgenerate
    // enable = 1 (RIGHT) -> reverse module does nothing 
    // enable = 0 (LEFT)  -> result = temp (reversed)
    assign reversed_value = enable ? input_value : temp;
    
endmodule