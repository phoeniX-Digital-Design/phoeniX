// `include "Memory_Interface.v"
// `include "..\\Src\\Memory_Interface.v"
`ifndef OPCODES
    `include "Modules\\Opcodes.v"
`endif

`define BYTE                3'b000
`define HALFWORD            3'b001
`define WORD                3'b010
`define BYTE_UNSIGNED       3'b100
`define HALFWORD_UNSIGNED   3'b101

module Load_Store_Unit
#(
    parameter ADDRESS_WIDTH = 8
)
(     
    input CLK,
    
    input  [6 : 0] opcode,                  // Load/Store function
    input  [2 : 0] funct3,                  // Load/Store function

    input       [31 : 0] address,           // Generated in Address Generator module
    input       [31 : 0] store_data,        // Connected to Register Source 2
    output reg  [31 : 0] load_data
);

    reg   memory_state;
    reg   [3 : 0] frame_mask;

    wire   memory_done;
    wire   [31 : 0] data;
    
    // Memory Interface Enable Signal Generation
    reg enable;
    always @(*)
    begin
        case (opcode)
            `LOAD   : enable = 1'b1;
            `STORE  : enable = 1'b1; 
            default : enable = 1'b0;
        endcase
    end

    // Memory State and Frame Mask Generation
    always @(*) 
    begin
        {memory_state, frame_mask} = {1'bx, 4'bx};

        case ({opcode, funct3})
            // Load Instructions
            
            // LB and LBU
            {`LOAD, `BYTE}, {`LOAD, `BYTE_UNSIGNED}: {memory_state, frame_mask} = 
            {   data_memory.READ, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            };

            // LH and LHU
            {`LOAD, `HALFWORD}, {`LOAD, `HALFWORD_UNSIGNED} : {memory_state, frame_mask} = 
            {   data_memory.READ,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            };

            // LW
            {`LOAD, `WORD} : {memory_state, frame_mask} = {data_memory.READ, 4'b1111}; 
            
            // Store Instructions

            // SB
            {`STORE, `BYTE} : {memory_state, frame_mask} = 
            {   data_memory.WRITE, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            }; 

            // SH
            {`STORE, `HALFWORD} : {memory_state, frame_mask} = 
            {   data_memory.WRITE,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            }; 

            // SW
            {`STORE, `WORD} : {memory_state, frame_mask} = {data_memory.WRITE, 4'b1111};

            default : {memory_state, frame_mask} = {1'b0, 4'b0};
        endcase    
    end

    // Data Management in case of Store Instruction
    assign data = opcode == `STORE ? store_data : 32'bz;

    // Instantiating Memory Interface for Data Memory
    Memory_Interface 
    #(
        .DEPTH(2 ** ADDRESS_WIDTH)
    )
    data_memory 
    (
        .CLK(CLK),
        .enable(enable), 
        .memory_state(memory_state),
        .frame_mask(frame_mask),
        .address(address & 32'hFFFF_FFFC), 
        .data(data), 
        .memory_done(memory_done)
    );
    
    // Latch condition when Loading
    always @(posedge memory_done)
    begin
        if (opcode == `LOAD)
        casex ({funct3})
            `BYTE               : load_data <= { {24{data[7]}}, data[7 : 0]};       // LB
            `HALFWORD           : load_data <= { {16{data[15]}}, data[15 : 0]};     // LH
            `BYTE_UNSIGNED      : load_data <= { 24'b0, data[7 : 0]};               // LBU
            `HALFWORD_UNSIGNED  : load_data <= { 16'b0, data[15 : 0]};              // LHU
            `WORD               : load_data <= data;                                // LW
        endcase    
    end
endmodule