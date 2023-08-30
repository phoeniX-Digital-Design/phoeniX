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
`endif 

`define BYTE                3'b000
`define HALFWORD            3'b001
`define WORD                3'b010
`define BYTE_UNSIGNED       3'b100
`define HALFWORD_UNSIGNED   3'b101

module Load_Store_Unit
(       
    input  [6 : 0] opcode,                  // Load/Store function
    input  [2 : 0] funct3,                  // Load/Store function

    input       [31 : 0] address,           // Generated in Address Generator module
    input       [31 : 0] store_data,        // Connected to Register Source 2
    output reg  [31 : 0] load_data,         // Data returned from memory

    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////

    output  reg  memory_interface_enable,
    output  reg  memory_interface_memory_state,
    output  reg  [31 : 0]   memory_interface_address,
    output  reg  [3 : 0]    memory_interface_frame_mask,

    inout   [31 : 0] memory_interface_data
);
    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;
    
    // Memory Interface Enable Signal Generation
    always @(*)
    begin
        case (opcode)
            `LOAD   : begin memory_interface_enable = 1'b1; memory_interface_address = {address[31 : 2], 2'b00}; end
            `STORE  : begin memory_interface_enable = 1'b1; memory_interface_address = {address[31 : 2], 2'b00}; end 
            default : begin memory_interface_enable = 1'b0; memory_interface_address = 32'bz; end
        endcase
    end

    // Memory State and Frame Mask Generation
    always @(*) 
    begin
        {memory_interface_memory_state, memory_interface_frame_mask} = {1'bx, 4'bx};

        case ({opcode, funct3})
            // Load Instructions
            
            // LB and LBU
            {`LOAD, `BYTE}, {`LOAD, `BYTE_UNSIGNED}: {memory_interface_memory_state, memory_interface_frame_mask} = 
            {   READ, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            };

            // LH and LHU
            {`LOAD, `HALFWORD}, {`LOAD, `HALFWORD_UNSIGNED} : {memory_interface_memory_state, memory_interface_frame_mask} = 
            {   READ,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            };

            // LW
            {`LOAD, `WORD} : {memory_interface_memory_state, memory_interface_frame_mask} = {READ, 4'b1111}; 
            
            // Store Instructions

            // SB
            {`STORE, `BYTE} : {memory_interface_memory_state, memory_interface_frame_mask} = 
            {   WRITE, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            }; 

            // SH
            {`STORE, `HALFWORD} : {memory_interface_memory_state, memory_interface_frame_mask} = 
            {   WRITE,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            }; 

            // SW
            {`STORE, `WORD} : {memory_interface_memory_state, memory_interface_frame_mask} = {WRITE, 4'b1111};

            default : {memory_interface_memory_state, memory_interface_frame_mask} = {1'b0, 4'b0};
        endcase    
    end

    // Data Management in case of Store Instruction
    reg [31 : 0] store_data_reg = 32'bz;
    assign memory_interface_data = opcode == `STORE ? store_data_reg : 32'bz;

    // Latch condition when Loading
    always @(*)
    begin
        if (opcode == `LOAD)
        casex ({funct3})
            `BYTE : 
            begin
                if (memory_interface_frame_mask == 4'b0001) load_data <= { {24{memory_interface_data[31]}}, memory_interface_data[31 : 24]}; 
                if (memory_interface_frame_mask == 4'b0010) load_data <= { {24{memory_interface_data[23]}}, memory_interface_data[23 : 16]}; 
                if (memory_interface_frame_mask == 4'b0100) load_data <= { {24{memory_interface_data[15]}}, memory_interface_data[15 :  7]}; 
                if (memory_interface_frame_mask == 4'b1000) load_data <= { {24{memory_interface_data[ 7]}}, memory_interface_data[ 7 :  0]}; 
            end    
              
            `BYTE_UNSIGNED : 
            begin
                if (memory_interface_frame_mask == 4'b0001) load_data <= { 24'b0, memory_interface_data[31 : 24]};
                if (memory_interface_frame_mask == 4'b0010) load_data <= { 24'b0, memory_interface_data[23 : 16]};
                if (memory_interface_frame_mask == 4'b0100) load_data <= { 24'b0, memory_interface_data[15 :  7]};
                if (memory_interface_frame_mask == 4'b1000) load_data <= { 24'b0, memory_interface_data[ 7 :  0]}; 
            end

            `HALFWORD : 
            begin
                if (memory_interface_frame_mask == 4'b0011) load_data <= { {16{memory_interface_data[31]}}, memory_interface_data[31 : 16]};
                if (memory_interface_frame_mask == 4'b1100) load_data <= { {16{memory_interface_data[15]}}, memory_interface_data[15 :  0]};
            end
            `HALFWORD_UNSIGNED :
            begin
                if (memory_interface_frame_mask == 4'b0011) load_data <= { 16'b0, memory_interface_data[31 : 16]};
                if (memory_interface_frame_mask == 4'b1100) load_data <= { 16'b0, memory_interface_data[15 :  0]};
            end 
            `WORD : load_data <= memory_interface_data;                                               
        endcase    
        else load_data <= 32'bz;

        if (opcode == `STORE)
        casex ({funct3})
            `BYTE : 
            begin
                if (memory_interface_frame_mask == 4'b0001) store_data_reg[31 : 24] <= store_data[ 7 : 0];
                if (memory_interface_frame_mask == 4'b0010) store_data_reg[23 : 16] <= store_data[ 7 : 0];
                if (memory_interface_frame_mask == 4'b0100) store_data_reg[15 :  7] <= store_data[ 7 : 0];
                if (memory_interface_frame_mask == 4'b1000) store_data_reg[ 7 :  0] <= store_data[ 7 : 0];
            end 
            `HALFWORD : 
            begin
                if (memory_interface_frame_mask == 4'b0011) store_data_reg[31 : 16] <= store_data[15 : 0];
                if (memory_interface_frame_mask == 4'b1100) store_data_reg[15 :  0] <= store_data[15 : 0];
            end
            `WORD : store_data_reg <= store_data;
        endcase
        else store_data_reg <= 32'bz;
    end
endmodule