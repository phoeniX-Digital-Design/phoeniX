`include "..\\Memory_Interface.v"

module Memory_Testbench;

    reg CLK = 1'b0;
    reg reset;

    reg enable;
    reg memory_state;

    reg [3 : 0] frame_mask;

    reg [31 : 0] address;
    
    wire [31 : 0] data;
    reg  [31 : 0] data_reg;

    assign data = data_reg;

    wire memory_done;

    Memory_Interface uut 
    (
        CLK,
        enable,
        memory_state,
        frame_mask,
        address,
        data,
        memory_done
    );

    // Clock generation
    always #1 CLK = ~CLK;
    
    // Memory Initialize
    

    initial begin

        $dumpfile("Memory_Testbench.vcd");
        $dumpvars(0, TB_Mem);

        $readmemh("..\\Instruction_Memory.txt", uut.Memory);

        data_reg = 32'bz;

        // Reset
        reset = 1'b1;
        enable = 1'b0;
        address = 32'b0;

        // Wait for a few clock cycles
        #10;
        reset = 1'b0;

        // Fetch Test
        #1 enable = 1'b1;
        memory_state = uut.READ;
        frame_mask = 4'b1111;
        address = 32'h04;
        #10
        enable = 1'b0;
        $display ("--> Testing Fetch Operation: ADDRESS = %h\tDATA = %h\n", address, data);
        #10;

        // Write operation
        enable = 1'b1;
        memory_state = uut.WRITE;
        address = 32'h04;
        frame_mask = 4'b0011;
        data_reg = 16'hFD;
        #6
        enable = 1'b0;
        data_reg = 32'bz;
        $display ("--> Testing Write Operation: ADDRESS = %h\tDATA = %h\n", address, data);
        #10;

        // Read operation
        enable = 1'b1;
        memory_state = uut.READ;
        frame_mask = 4'b1111;
        address = 32'h04;
        #10
        enable = 1'b0;
        $display ("--> Testing Read Operation: ADDRESS = %h\tDATA = %h\n", address, data);
        #10
        $finish;
    end
endmodule