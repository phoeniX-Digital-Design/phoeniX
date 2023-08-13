`include "..\\Memory_Interface.v"

module TB_Mem;

    reg CLK = 1'b0;
    reg reset;

    reg enable;
    reg memory_state;

    reg [3 : 0] frame_mask;

    reg [31 : 0] address;
    
    wire [31 : 0] data;
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

    initial begin

        // Reset
        reset = 1'b1;
        enable = 1'b0;
        address = 32'b0;

        // Wait for a few clock cycles
        #10;
        reset = 1'b0;

        // Fetch Test
        enable = 1'b1;
        memory_state = uut.READ;
        frame_mask = 4'b1111;
        address = 32'h04;

        #10 $display ("--> Testing Fetch Operation: ADDRESS = %h\tDATA = %h\n", address, data);
        #10;

        // // Write operation
        // enable = 1'b1;
        // write_enable = 1'b1;
        // address = 16'b0000000000000010;
        // dataIn = 32'b01010101010101010101010101010101;
        // #10;

        // // Read operation
        // enable = 1'b1;
        // read_enable = 1'b1;
        // write_enable = 1'b0;
        // address = 16'b0000000000000010;
        // #10;

        // $display ("Data = %b ", Data);
        $finish;
    end
endmodule