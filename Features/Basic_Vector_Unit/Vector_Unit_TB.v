`include "Vector_Unit.v"

module Vector_Unit_TB;
    reg  CLK;
    reg  reset;
    reg  [6 : 0] opcode;
    reg  [2 : 0] funct3;
    reg  [6 : 0] funct7;
    reg  [31 : 0][0 : 31] v_operand_1;
    reg  [31 : 0][0 : 31] v_operand_2;
    wire [31 : 0][0 : 31] v_result;
    
    Vector_Unit uut 
    (
        .CLK(CLK),
        .reset(reset),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .v_operand_1(v_operand_1),
        .v_operand_2(v_operand_2),
        .v_result(v_result)
    );
    
    // Clock generation
    always #5 CLK = ~CLK;

    initial begin

        $dumpfile("Vector_Unit.vcd");
        $dumpvars(0, Vector_Unit_TB);
        
        CLK = 0;
        reset = 1;
        opcode = 7'b0000_000;
        funct3 = 3'b000;
        funct7 = 7'b0000_000;
        v_operand_1 = 32'h0000_0000;
        v_operand_2 = 32'h0000_0000;
        #10 reset = 0;

        // Test case 1: Vector ADD
        uut.v_function = 4'b0000;
        v_operand_1[3] = 32'h0000_0001;
        v_operand_2[3] = 32'h0000_0002;
        #10;
        $display("Case 1 Result:");
        for (integer i = 0 ; i < 32 ; i = i + 1)
        begin
            $display("Register #%d : %h", i, v_result[i]);
        end
        

        // Test case 2: Vector SUB
        uut.v_function = 4'b0001;
        v_operand_1[30] = 32'h0000_0008;
        v_operand_2[30] = 32'h0000_0002;
        #10;
        $display("\nCase 2 Result:");
        for (integer i = 0 ; i < 32 ; i = i + 1)
        begin
            $display("Register #%d : %h", i, v_result[i]);
        end
        $finish;
    end

endmodule