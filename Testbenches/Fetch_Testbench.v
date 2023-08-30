`include "..\\Modules\\Fetch_Unit.v"

module Fetch_Testbench;

    parameter RESET_ADDRESS = 32'hFFFFFFFC;

    reg CLK = 1'b1;
    reg CLK_MEM = 1'b1;

    reg reset = 1'b1;
    reg enable = 1'b0;

    reg [31 : 0] PC;
    reg [31 : 0] instruction;

    reg [31 : 0] address;
    reg jump_branch_enable = 1'b0;

    wire [31 : 0] next_PC;   
    wire [31 : 0] latched_instruction;

    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////
    wire enable_Imem;
    wire memory_state_Imem;
    wire [31 : 0] address_Imem;
    wire [3 : 0] frame_mask_Imem;

    Fetch_Unit uut 
    (
        .enable(enable),
        
        .PC(PC),
        .address(address),
        .jump_branch_enable(jump_branch_enable),
            
        .next_PC(next_PC),
        .fetched_instruction(latched_instruction),

        .memory_interface_enable(enable_Imem),
        .memory_interface_memory_state(memory_state_Imem),
        .memory_interface_address(address_Imem),
        .memory_interface_frame_mask(frame_mask_Imem),
        
        .memory_interface_data(data_in_Imem),
        .memory_interface_memory_done(memory_done_Imem)
    );

    // Instrution Register Behaviour
    always @(posedge CLK)
    begin
        instruction <= latched_instruction;    
    end

    // PC Register Behaviour
    always @(posedge CLK) 
    begin
        if (reset)
            PC <= RESET_ADDRESS;
        else
            PC <= next_PC; 
    end

    // Clock generation
    always #1 CLK_MEM = ~CLK_MEM;
    always #6 CLK = ~CLK;

    initial 
    begin

        $dumpfile("Fetch_Testbench.vcd");
        $dumpvars(0, Fetch_Testbench);

        $readmemh("instruction.mem", Memory);

        // Reset
        #14
        reset = 1'b1;
        enable = 1'b0;

        // Wait for a few clock cycles
        #12;
        reset  = 1'b0;
        enable = 1'b1;
        #58
        address = 32'h0;
        jump_branch_enable = 1'b1;
        #12
        jump_branch_enable = 1'b0;
        #100;
        $finish;
    end
    
    // Memory Behaviour and interface FSM
    reg [7 : 0] Memory [0 : 16 * 1024 - 1];

    // Signals for Memory Interface
    reg [31 : 0] data_in_Imem;
    reg memory_done_Imem;

    localparam  READ        = 1'b0,
                WRITE       = 1'b1;

    // State Machine Parameters
    reg [3 : 0] state_Imem;
	reg [3 : 0] next_state_Imem;

	localparam  STABLE      = 4'd0,
                B_0001      = 4'd1,
                B_0010      = 4'd2,
                B_0100      = 4'd3,
                B_1000      = 4'd4,
                H_0011_1    = 4'd5,
                H_0011_2    = 4'd6,
                H_1100_1    = 4'd7,
                H_1100_2    = 4'd8,
                W_1111_1    = 4'd9,
                W_1111_2    = 4'd10,
                W_1111_3    = 4'd11,
                W_1111_4    = 4'd12,
                FINISH      = 4'd13;

  	always @(posedge CLK_MEM)
    begin
        if (enable_Imem)
            state_Imem <= next_state_Imem;
        else    
            state_Imem <= STABLE; 
    end

    always @(*)
    begin
        case (state_Imem)
            STABLE : begin
                memory_done_Imem <= 1'b0;
                data_in_Imem <= 32'bz;
                
                if (frame_mask_Imem == 4'b0000)  next_state_Imem <= STABLE;

                if (frame_mask_Imem == 4'b0001)  next_state_Imem <= B_0001;
                if (frame_mask_Imem == 4'b0010)  next_state_Imem <= B_0010;
                if (frame_mask_Imem == 4'b0100)  next_state_Imem <= B_0100;
                if (frame_mask_Imem == 4'b1000)  next_state_Imem <= B_1000;

                if (frame_mask_Imem == 4'b0011)  next_state_Imem <= H_0011_1;
                if (frame_mask_Imem == 4'b1100)  next_state_Imem <= H_1100_1;

                if (frame_mask_Imem == 4'b1111)  next_state_Imem <= W_1111_1;
            end

            B_0001 : begin
                if (memory_state_Imem == READ)   data_in_Imem <= Memory[address_Imem + 3];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 3] <= data;
                next_state_Imem <= FINISH;
            end

            B_0010 : begin
                if (memory_state_Imem == READ)   data_in_Imem <= Memory[address_Imem + 2];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 2] <= data;
                next_state_Imem <= FINISH;
            end
            
            B_0100 : begin
                if (memory_state_Imem == READ)   data_in_Imem <= Memory[address_Imem + 1];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 1] <= data;
                next_state_Imem <= FINISH;
            end

            B_1000 : begin
                if (memory_state_Imem == READ)   data_in_Imem <= Memory[address_Imem + 0];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 0] <= data;
                next_state_Imem <= FINISH;
            end

            H_0011_1 : begin
                if (memory_state_Imem == READ)   data_in_Imem[15 : 8] <= Memory[address_Imem + 2];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 2] <= data[15 : 8];
                next_state_Imem <= H_0011_2;
            end

            H_0011_2 : begin
                if (memory_state_Imem == READ)   data_in_Imem[7 : 0] <= Memory[address_Imem + 3];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 3] <= data[7 : 0];
                next_state_Imem <= FINISH;
            end

            H_1100_1 : begin
                if (memory_state_Imem == READ)   data_in_Imem[15 : 8] <= Memory[address_Imem + 0];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 0] <= data[15 : 8];
                next_state_Imem <= H_1100_2;
            end

            H_1100_2 : begin
                if (memory_state_Imem == READ)   data_in_Imem[7 : 0] <= Memory[address_Imem + 1];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 1] <= data[7 : 0];
                next_state_Imem <= FINISH;
            end

            W_1111_1 : begin
                if (memory_state_Imem == READ)   data_in_Imem[31 : 24] <= Memory[address_Imem + 0];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 0] <= data[31 : 24]; 
                next_state_Imem <= W_1111_2;
            end

            W_1111_2 : begin
                if (memory_state_Imem == READ)   data_in_Imem[23 : 16] <= Memory[address_Imem + 1];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 1] <= data[23 : 16]; 
                next_state_Imem <= W_1111_3;
            end

            W_1111_3 : begin
                if (memory_state_Imem == READ)   data_in_Imem[15 : 8] <= Memory[address_Imem + 2];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 2] <= data[15 : 8]; 
                next_state_Imem <= W_1111_4;
            end

            W_1111_4 : begin
                if (memory_state_Imem == READ)   data_in_Imem[7 : 0] <= Memory[address_Imem + 3];
                if (memory_state_Imem == WRITE)  Memory[address_Imem + 3] <= data[7 : 0]; 
                next_state_Imem <= FINISH;
            end

            FINISH : begin
                memory_done_Imem <= 1'b1;
                next_state_Imem <= STABLE;
            end
        endcase
    end
    wire [31 : 0] data;
    assign data = data_in_Imem;
endmodule