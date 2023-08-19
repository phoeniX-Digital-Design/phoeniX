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
    input  address_type,
    input  [31 : 0] bus_rs1,
    input  [31 : 0] PC,
    input  [31 : 0] immediate,

    output [31 : 0] address
);
    wire [31 : 0] value;

    assign value = address_type ? bus_rs1 : PC;
    assign address = value + immediate;
    
endmodule