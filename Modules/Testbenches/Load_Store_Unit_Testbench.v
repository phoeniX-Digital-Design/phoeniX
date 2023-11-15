`timescale 1 ns / 1 ns
`include "..\\Load_Store_Unit.v"

`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif /*OPCODES*/

`define BYTE                3'b000
`define HALFWORD            3'b001
`define WORD                3'b010
`define BYTE_UNSIGNED       3'b100
`define HALFWORD_UNSIGNED   3'b101

`define MEMORY_DELAY        #15

module Load_Store_Unit_Testbench;
  
    //////////////////////
    // Clock Generation //
    //////////////////////
    parameter CLK_PERIOD = 4;
    reg clk = 1'b1;
    initial begin forever #(CLK_PERIOD/2) clk = ~clk; end
    initial #(1000 * CLK_PERIOD) $finish;

    reg  [6 : 0] opcode = 7'bz;
    reg  [2 : 0] funct3 = 3'bz;

    reg  [31 : 0] address = 32'bz;
    reg  [31 : 0] store_data = 32'bz; 
    wire [31 : 0] load_data;

    ///////////////////////////////////
    // Data Memory Interface Signals //
    ///////////////////////////////////
    wire data_memory_interface_enable;
    wire data_memory_interface_state;
    wire [31 : 0] data_memory_interface_address;
    wire [ 3 : 0] data_memory_interface_frame_mask;
    
    wire [31 : 0] data_memory_interface_data;
    reg  [31 : 0] data_memory_interface_data_reg;
    reg data_memory_interface_ready;

    assign data_memory_interface_data = data_memory_interface_data_reg;

    Load_Store_Unit uut 
    (
        .opcode(opcode),
        .funct3(funct3),

        .address(address),
        .store_data(store_data),
        .load_data(load_data),

        .memory_interface_enable(data_memory_interface_enable),
        .memory_interface_state(data_memory_interface_state),
        .memory_interface_address(data_memory_interface_address),
        .memory_interface_frame_mask(data_memory_interface_frame_mask),

        .memory_interface_data(data_memory_interface_data)
    );

    initial 
    begin
        $dumpfile("Load_Store_Unit.vcd");
        $dumpvars(0, Load_Store_Unit_Testbench);

        // Wait for a few clock cycles
        #(2 * CLK_PERIOD)
        address = 32'd16;
        store_data = 32'hDEADCAFE;
        opcode = `STORE;
        funct3 = `WORD;

        #(1 * CLK_PERIOD)
        address = 32'd20;
        store_data = 32'hDEADBEEF;
        opcode = `STORE;
        funct3 = `WORD;

        #(1 * CLK_PERIOD)
        address = 32'bz;
        store_data = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        #(1 * CLK_PERIOD) 
        address = 32'd20;
        opcode = `LOAD;
        funct3 = `WORD;
        
        #(5 * CLK_PERIOD);
        address = 32'bz;
        store_data = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        #(1 * CLK_PERIOD);
        $finish;
    end

    // Memory 
    reg [31 : 0] Memory [0 : 64 * 1024 - 1];

    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;

    // Data Memory Interface Behaviour
    always @(negedge clk)
    begin
        if (!data_memory_interface_enable)
        begin
             data_memory_interface_data_reg <= 32'bz;
             data_memory_interface_ready <= 1'b0;
        end
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
            begin
                `MEMORY_DELAY 
                data_memory_interface_data_reg <= Memory[data_memory_interface_address >> 2];
                data_memory_interface_ready <= 1'b1;
            end
        end   
    end

    always @(posedge clk) 
    begin
        if (data_memory_interface_ready)
        begin
           data_memory_interface_data_reg <= 32'bz;    
           data_memory_interface_ready <= 1'b0; 
        end
    end
endmodule