`timescale 1ns/1ns
`include "../Fetch_Unit.v"

`define FIRMWARE "sum1to100_approximate_firmware.hex"

`ifndef NOP_INSTRUCTION
    `define NOP                     32'h0000_0013
    `define NOP_opcode              `OP_IMM
    `define NOP_funct12             12'h000
    `define NOP_funct7              7'b000_0000
    `define NOP_funct3              3'b000
    `define NOP_immediate           12'h000
    `define NOP_instruction_type   `I_TYPE
    `define NOP_write_index         5'b00000
`endif /*NOP_INSTRUCTION*/

module Fetch_Unit_Testbench;

    //////////////////////
    // Clock Generation //
    //////////////////////
    parameter T_CLK = 4;
    reg CLK = 1'b1;
    always #(T_CLK/2) CLK = ~CLK;

    reg reset = 1'b1;

    //////////////////////////////////////////
    // Instruction Memory Interface Signals //
    //////////////////////////////////////////
    wire instruction_memory_interface_enable;
    wire instruction_memory_interface_state;
    wire [31 : 0] instruction_memory_interface_address;
    wire [ 3 : 0] instruction_memory_interface_frame_mask;
    reg  [31 : 0] instruction_memory_interface_data;
    
    parameter RESET_ADDRESS = 32'hFFFFFFFC;

    reg enable = 1'b0;
    reg jump_branch_enable = 1'b0;
    reg stall = 1'b0;
    reg [31 : 0] PC_stall_address;
    always @(*) PC_stall_address = PC_fetch_reg;

    // ---------------------------------
    // Wire Declarations for Fetch Stage
    // ---------------------------------
    wire [31 : 0] next_PC_wire;
    
    // --------------------------------
    // Reg Declarations for Fetch Stage
    // --------------------------------
    reg [31 : 0] PC_fetch_reg;    

    Fetch_Unit uut (
        .enable(!reset && !stall),
        .PC(PC_fetch_reg),
        
        .jump_branch_address(32'hDEADBEEF),         
        .jump_branch_enable(jump_branch_enable),       

        .next_PC(next_PC_wire),    

        .memory_interface_enable(instruction_memory_interface_enable),
        .memory_interface_state(instruction_memory_interface_state),
        .memory_interface_address(instruction_memory_interface_address),
        .memory_interface_frame_mask(instruction_memory_interface_frame_mask)  
    );

    // ------------------------
    // Program Counter Register 
    // ------------------------
    always @(posedge CLK)
    begin
        if (reset)
            PC_fetch_reg <= RESET_ADDRESS;
        else if (!stall)
            PC_fetch_reg <= next_PC_wire; 
    end
    
    // --------------------------------------
    // Register Declarations for Decode Stage
    // --------------------------------------
    reg [31 : 0] instruction_decode_reg;
    reg [31 : 0] PC_decode_reg; 

    ////////////////////////////////////////
    //     FETCH TO DECODE TRANSITION     //
    ////////////////////////////////////////
    always @(posedge CLK) 
    begin
        if (jump_branch_enable || stall)
        begin
            instruction_decode_reg <= `NOP;
        end
        else
        begin
            PC_decode_reg <= PC_fetch_reg;
            instruction_decode_reg <= instruction_memory_interface_data;
        end
    end

    ///////////////////////////////////
    //   4 MB Memory Instantiation   //
    ///////////////////////////////////
    reg [31 : 0] Memory [0 : 1024 * 1024 - 1];
    initial $readmemh(`FIRMWARE, Memory);
    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;

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


    reg [31 : 0] PC_execute_reg;
    reg [31 : 0] instruction_execute_reg;

    ////////////////////////////////////////
    //    DECODE TO EXECUTE TRANSITION    //
    ////////////////////////////////////////
    always @(posedge (CLK)) 
    begin
        PC_execute_reg <= PC_decode_reg;
        instruction_execute_reg <= instruction_decode_reg;
    end

    ///////////////////////////
    //   Testbench Segment   //
    ///////////////////////////

    initial #(2000 * T_CLK) $finish;

    // always @(*) 
    // begin
    //     if (instruction_execute_reg == 32'h00100693) stall <= 1'b1;    
    // end
    initial
    begin
        $dumpfile("Fetch_Unit.vcd");
        $dumpvars(0, Fetch_Unit_Testbench);

        #(3 * T_CLK);
        reset = 1'b0;
        #(5 * T_CLK);
        stall = 1'b1;
        
        #(4 * T_CLK);
        stall = 1'b0;
    end
endmodule