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
    input [6 : 0] opcode, 
    input [31 : 0] rs1,            // to be connected to bus_rs1
    input [31 : 0] PC,
    input [31 : 0] immediate,

    output [31 : 0] address
);
    reg  address_type;
    always @(*) 
    begin
        // Address Type evaluation (for Address Generator module)
        case (opcode)
            7'b0100011: address_type = 1'b1;    //  Store  -> bus_rs1 + immediate
            7'b0000011: address_type = 1'b1;    //  Load   -> bus_rs1 + immediate
            7'b1101111: address_type = 1'b0;    //  JAL    ->    PC   + immediate
            7'b1100111: address_type = 1'b0;    //  JALR   ->    PC   + immediate
            7'b1100011: address_type = 1'b0;    //  Branch ->    PC   + immediate
            default: address_type = 1'bz;
        endcase 
    end

    wire [31 : 0] value = address_type ? rs1 : PC;
    assign address = value + immediate;
    
endmodule