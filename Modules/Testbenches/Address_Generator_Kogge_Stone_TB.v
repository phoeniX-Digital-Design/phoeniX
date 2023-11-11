`include "../Address_Generator.v"

module Address_Generator_Testbench;

    reg [6  : 0] opcode;
    reg [31 : 0] rs1;
    reg [31 : 0] pc;
    reg [31 : 0] immediate;

    wire [31 : 0] address;

    // Instantiate the module under test
    Address_Generator uut 
    (
        .opcode(opcode),
        .rs1(rs1),
        .pc(pc),
        .immediate(immediate),
        .address(address)
    );


    initial begin
        opcode = `LOAD;
        rs1 = 32'd12345;
        pc  = 32'd00000;
        immediate = 32'd4;
        #5;

        $display("Address: %d", address);

        #10;
        opcode = `BRANCH;
        rs1 = 32'd54321;
        pc = 32'd9;
        immediate = 32'h8;
        #5;
        $display("Address: %d", address);
        #10;
        $finish;
    end

endmodule