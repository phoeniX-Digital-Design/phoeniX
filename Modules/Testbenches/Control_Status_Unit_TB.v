`include "../Control_Status_Unit.v"

module Control_Status_Unit_TB;
    reg  CLK = 0;
    reg  [6 : 0] opcode;
    reg  [2 : 0] funct3;
    reg  [31 : 0] CSR_in;
    reg  [31 : 0] rs1;
    reg  [4  : 0] unsigned_immediate;
    wire [31 : 0] rd;
    wire [31 : 0] CSR_out;

    Control_Status_Unit uut 
    (
        .CLK(CLK),
        .opcode(opcode),
        .funct3(funct3),
        .CSR_in(CSR_in),
        .rs1(rs1),
        .unsigned_immediate(unsigned_immediate),
        .rd(rd),
        .CSR_out(CSR_out)
    );

    always #5 CLK = ~CLK;

    initial begin
        
        $dumpfile("Control_Status_Unit.vcd");
        $dumpvars(0, Control_Status_Unit_TB);

        opcode = 7'b11_100_11;
        funct3 = 3'b001;
        CSR_in = 32'h12345678;
        rs1 = 32'hABCDEF01;
        unsigned_immediate = 5'd10;

        #10;
        // Initial values
        $display("Initial Values:");
        $display("CSR_in: %d", CSR_in);
        $display("rs1: %d", rs1);
        $display("unsigned_immediate: %d", unsigned_immediate);
        $display("");
        // Output values
        $display("Output Values:");
        $display("rd: %d", rd);
        $display("CSR_out: %d", CSR_out);
        $display("");
        #10;

        opcode = 7'b11_100_11;
        funct3 = 3'b010;
        CSR_in = 32'h12345678;
        rs1 = 32'hABCDEF01;
        unsigned_immediate = 5'b11111;

        #10;
        // Initial values
        $display("Initial Values:");
        $display("CSR_in: %b", CSR_in);
        $display("rs1: %b", rs1);
        $display("unsigned_immediate: %b", unsigned_immediate);
        $display("");
        // Output values
        $display("Output Values:");
        $display("rd: %b", rd);
        $display("CSR_out: %b", CSR_out);
        $display("");
    end

    initial #50 $finish;

endmodule