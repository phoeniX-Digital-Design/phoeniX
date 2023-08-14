/*
    Address Generator:
    There are 3 types of addresses generated in this module:
    1. Branch Address
    2. Jump and Link Address
    3. Load/Store Address
    Immediate values are determined in Immediate_Generator module.
    So no determination (Mux) will be needed here.(I-J-B immediate)
*/

module Address_Generator
(
    input  [31 : 0] immediate,
    input  [31 : 0] PC,

    output [31 : 0] address
);

    assign address = PC + immediate;
    
endmodule