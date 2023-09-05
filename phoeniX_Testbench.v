`timescale 1 ns / 1 ns
`include "phoeniX.v"

`ifndef FIRMWARE
    `define FIRMWARE "Software\\User_Codes\\fibonacci_assembly\\fibonacci_assembly_firmware.hex"
`endif /*FIRMWARE*/

module phoeniX_Testbench;

    // initial #10000 $finish;

    // Clock Generation
    reg CLK = 1'b1;
    always #2 CLK = ~CLK;

    reg reset = 1'b1;
    
    //////////////////////////////////////////
    // Instruction Memory Interface Signals //
    //////////////////////////////////////////
    wire instruction_memory_interface_enable;
    wire instruction_memory_interface_state;
    wire [31 : 0] instruction_memory_interface_address;
    wire [ 3 : 0] instruction_memory_interface_frame_mask;
    reg  [31 : 0] instruction_memory_interface_data;
    
    ///////////////////////////////////
    // Data Memory Interface Signals //
    ///////////////////////////////////
    wire data_memory_interface_enable;
    wire data_memory_interface_state;
    wire [31 : 0] data_memory_interface_address;
    wire [ 3 : 0] data_memory_interface_frame_mask;
    
    wire [31 : 0] data_memory_interface_data;
    reg  [31 : 0] data_memory_interface_data_reg;
    assign data_memory_interface_data = data_memory_interface_data_reg;

    phoeniX uut
    (
        .CLK(CLK),
        .reset(reset),

        .instruction_memory_interface_enable(instruction_memory_interface_enable),
        .instruction_memory_interface_state(instruction_memory_interface_state),
        .instruction_memory_interface_address(instruction_memory_interface_address),
        .instruction_memory_interface_frame_mask(instruction_memory_interface_frame_mask),
        .instruction_memory_interface_data(instruction_memory_interface_data),

        .data_memory_interface_enable(data_memory_interface_enable),
        .data_memory_interface_state(data_memory_interface_state),
        .data_memory_interface_address(data_memory_interface_address),
        .data_memory_interface_frame_mask(data_memory_interface_frame_mask),
        .data_memory_interface_data(data_memory_interface_data)
    );
    
    // Debug Wires for Register File
    `ifndef DISABLE_DEBUG
        wire [31 : 0] x0_zero 	= uut.register_file.Registers[0];
        wire [31 : 0] x1_ra 	= uut.register_file.Registers[1];
        wire [31 : 0] x2_sp 	= uut.register_file.Registers[2];
        wire [31 : 0] x3_gp 	= uut.register_file.Registers[3];
        wire [31 : 0] x4_tp 	= uut.register_file.Registers[4];
        wire [31 : 0] x5_t0 	= uut.register_file.Registers[5];
        wire [31 : 0] x6_t1 	= uut.register_file.Registers[6];
        wire [31 : 0] x7_t2 	= uut.register_file.Registers[7];
        wire [31 : 0] x8_s0 	= uut.register_file.Registers[8];
        wire [31 : 0] x9_s1 	= uut.register_file.Registers[9];
        wire [31 : 0] x10_a0 	= uut.register_file.Registers[10];
        wire [31 : 0] x11_a1 	= uut.register_file.Registers[11];
        wire [31 : 0] x12_a2 	= uut.register_file.Registers[12];
        wire [31 : 0] x13_a3 	= uut.register_file.Registers[13];
        wire [31 : 0] x14_a4 	= uut.register_file.Registers[14];
        wire [31 : 0] x15_a5 	= uut.register_file.Registers[15];
        wire [31 : 0] x16_a6 	= uut.register_file.Registers[16];
        wire [31 : 0] x17_a7 	= uut.register_file.Registers[17];
        wire [31 : 0] x18_s2 	= uut.register_file.Registers[18];
        wire [31 : 0] x19_s3 	= uut.register_file.Registers[19];
        wire [31 : 0] x20_s4 	= uut.register_file.Registers[20];
        wire [31 : 0] x21_s5 	= uut.register_file.Registers[21];
        wire [31 : 0] x22_s6 	= uut.register_file.Registers[22];
        wire [31 : 0] x23_s7 	= uut.register_file.Registers[23];
        wire [31 : 0] x24_s8 	= uut.register_file.Registers[24];
        wire [31 : 0] x25_s9 	= uut.register_file.Registers[25];
        wire [31 : 0] x26_s10 	= uut.register_file.Registers[26];
        wire [31 : 0] x27_s11 	= uut.register_file.Registers[27];
        wire [31 : 0] x28_t3 	= uut.register_file.Registers[28];
        wire [31 : 0] x29_t4 	= uut.register_file.Registers[29];
        wire [31 : 0] x30_t5 	= uut.register_file.Registers[30];
        wire [31 : 0] x31_t6 	= uut.register_file.Registers[31];
    `endif

    ///////////////////////////////////
    //   4 MB Memory Instantiation   //
    ///////////////////////////////////
    reg [31 : 0] Memory [0 : 1024 * 1024 - 1];
    initial $readmemh(`FIRMWARE, Memory);
    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;

    initial
    begin
        $dumpfile("phoeniX.vcd");
        $dumpvars(0, phoeniX_Testbench);
        // Reset
        repeat (5) @(posedge CLK);
		reset <= 1'b0;
    end

    // Instruction Memory Interface Behaviour
    always @(negedge CLK)
    begin
        if (!instruction_memory_interface_enable) instruction_memory_interface_data <= 32'bz;
        else
        begin
            if (instruction_memory_interface_state == READ)
                instruction_memory_interface_data <= Memory[instruction_memory_interface_address >> 2];
        end    
    end

    // Data Memory Interface Behaviour
    always @(negedge CLK)
    begin
        if (!data_memory_interface_enable) data_memory_interface_data_reg <= 32'bz;
        else
        begin
            if (data_memory_interface_state == WRITE) 
            begin
                if (data_memory_interface_frame_mask[3]) Memory[data_memory_interface_address >> 2][ 7 :  0] <= data_memory_interface_data[ 7 :  0];
                if (data_memory_interface_frame_mask[2]) Memory[data_memory_interface_address >> 2][15 :  8] <= data_memory_interface_data[15 :  8];
                if (data_memory_interface_frame_mask[1]) Memory[data_memory_interface_address >> 2][23 : 16] <= data_memory_interface_data[23 : 16];
                if (data_memory_interface_frame_mask[0]) Memory[data_memory_interface_address >> 2][31 : 24] <= data_memory_interface_data[31 : 24];
            end 
            if (data_memory_interface_state == READ)
                data_memory_interface_data_reg <= Memory[data_memory_interface_address >> 2];
        end   
        
        ////////////////////////////////////
        // Environment Support for printf //
        ////////////////////////////////////
        // if (data_memory_interface_address == 32'h1000_0000)
        // begin
        //     $write("%c", data_memory_interface_data[7 : 0]);
        // end 

    end
    always @(posedge CLK) 
    begin
        data_memory_interface_data_reg <= 32'bz;    
    end

    always @(*) 
    begin
        if (uut.opcode_writeback_reg == `SYSTEM && uut.funct12_writeback_reg == `EBREAK) 
        begin
            reset <= 1'b1;
            repeat (5) @(posedge CLK);
            $display("--> EXECUTION FINISHED <--");
            $dumpoff;
            $finish;
        end
    end
endmodule