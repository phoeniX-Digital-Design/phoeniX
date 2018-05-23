`timescale 1 ns / 1 ns
`include "phoeniX.v"

`ifndef FIRMWARE
    `define FIRMWARE "Software\\User_Codes\\test\\test_firmware.hex"
`endif /*FIRMWARE*/

`ifndef START_ADDRESS
    `define START_ADDRESS   32'h0000_0000
`endif /*START_ADDRESS*/

`ifndef DUMPFILE_PATH
    `define DUMPFILE_PATH "phoeniX.vcd"
`endif /*DUMPFILE_PATH*/

module phoeniX_Testbench;

    //////////////////////
    // Clock Generation //
    //////////////////////
    parameter CLK_PERIOD = 2;
    reg clk = 1'b1;
    initial begin forever #(CLK_PERIOD/2) clk = ~clk; end
    //initial #(20000 * CLK_PERIOD) $finish;

    reg reset = `ENABLE;
    
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

    phoeniX 
    #(
        .RESET_ADDRESS(`START_ADDRESS),
        .M_EXTENSION(1'b1),
        .E_EXTENSION(1'b0)
    ) 
    uut
    (
        .clk(clk),
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
        wire [31 : 0] alu_csr   = uut.control_status_register_file.alucsr_reg;
        wire [31 : 0] mul_csr   = uut.control_status_register_file.mulcsr_reg;
        wire [31 : 0] div_csr   = uut.control_status_register_file.divcsr_reg;
        wire [63 : 0] mcycle    = uut.control_status_register_file.mcycle_reg;
        wire [63 : 0] minstret  = uut.control_status_register_file.minstret_reg;
    `endif /*DISABLE_DEBUG*/

    `ifdef DHRYSTONE_LOG
        integer log_file;
        initial 
        begin
            log_file = $fopen("Dhrystone/dhrystone.log", "w");  
        end
    `endif /*DHRYSTONE_LOG*/
    
    initial
    begin
        $dumpfile(`DUMPFILE_PATH);
        $dumpvars(0, phoeniX_Testbench);
        // Reset
        repeat (5) @(posedge clk);
		reset <= `DISABLE;
    end

    integer enable_high_count = 0;
    integer enable_low_count = 0;

    always @(posedge clk) 
    begin
        if (uut.fetch_unit.enable)
            enable_high_count = enable_high_count + 1;
        else
            enable_low_count = enable_low_count + 1;    
    end

    ////////////////
    //   Memory   //
    ////////////////

    // 32 MB Memory Instantiation
    reg [31 : 0] Memory [0 : 8 * 1024 * 1024 - 1];
    initial $readmemh(`FIRMWARE, Memory);

    // Instruction Memory Interface Behaviour
    always @(negedge clk)
    begin
        if (!instruction_memory_interface_enable) instruction_memory_interface_data <= 32'bz;
        else
        begin
            if (instruction_memory_interface_state == `READ)
                instruction_memory_interface_data <= Memory[instruction_memory_interface_address >> 2];
        end    
    end

    always @(posedge clk) 
    begin
        instruction_memory_interface_data <= 32'bz;
    end


    // Data Memory Interface Behaviour
    always @(negedge clk)
    begin
        if (!data_memory_interface_enable)
        begin
             data_memory_interface_data_reg <= 32'bz;
        end
        else
        begin
            if (data_memory_interface_state == `WRITE) 
            begin
                if (data_memory_interface_frame_mask[3]) Memory[data_memory_interface_address >> 2][ 7 :  0] <= data_memory_interface_data[ 7 :  0];
                if (data_memory_interface_frame_mask[2]) Memory[data_memory_interface_address >> 2][15 :  8] <= data_memory_interface_data[15 :  8];
                if (data_memory_interface_frame_mask[1]) Memory[data_memory_interface_address >> 2][23 : 16] <= data_memory_interface_data[23 : 16];
                if (data_memory_interface_frame_mask[0]) Memory[data_memory_interface_address >> 2][31 : 24] <= data_memory_interface_data[31 : 24];
            end 
            if (data_memory_interface_state == `READ)
            begin
                data_memory_interface_data_reg <= Memory[data_memory_interface_address >> 2];
            end
        end    

        ////////////////////////////////////
        // Environment Support for printf //
        ////////////////////////////////////
        if (data_memory_interface_address == 32'h1000_0000)
        begin
            $write("%c", data_memory_interface_data);
            $fflush();

            `ifdef DHRYSTONE_LOG
                $fwrite(log_file, "%c", data_memory_interface_data);
            `endif /*DHRYSTONE_LOG*/
        end
    end

    always @(posedge clk) 
    begin
        data_memory_interface_data_reg <= 32'bz;
    end

    //////////////////
    // System Calls //
    //////////////////

    always @(*) 
    begin
        if (uut.opcode_MW_reg == `SYSTEM && uut.funct12_MW_reg == `EBREAK) 
        begin
            repeat (32) @(posedge clk);
            reset <= `ENABLE;
            repeat (5) @(posedge clk);
            $display("\n--> EXECUTION FINISHED <--\n");
            $display("Firmware File: %s\n", `FIRMWARE);
            $display("ON  TIME:\t%d\nOFF TIME:\t%d", enable_high_count * CLK_PERIOD, enable_low_count * CLK_PERIOD);
            $display("CPU USAGE:\t%d%%", 100 *(enable_high_count * CLK_PERIOD)/(enable_high_count * CLK_PERIOD + enable_low_count * CLK_PERIOD));
            $dumpoff;
            $finish;
        end
    end
endmodule