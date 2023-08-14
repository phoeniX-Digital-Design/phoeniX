`include "Memory_Interface.v"

module Load_Store_Unit
(     
    input CLK,
    input enable,
    
    input  [6 : 0] opcode,      // Load/Store function
    input  [2 : 0] funct3,      // Load/Store function

    input  [31 : 0] address,    // Generated in Address Generator module
    input  [31 : 0] store_data, // Connected to Register Source 2
    output [31 : 0] load_data
);

    reg   memory_state;
    reg   [3  : 0] frame_mask;

    wire   memory_done;
    wire   [31 : 0] data;
    
    always @(*) 
    begin
        casex ({funct3, opcode})
            // Load Instructions

            // LB and LBU
            10'bX00_0000011 : {memory_state, frame_mask} = 
            {   data_memory.READ, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            }; 
            // LH and LHU
            10'bX01_0000011 : {memory_state, frame_mask} = 
            {   data_memory.READ,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            }; 
            // LW
            10'b010_0000011 : {memory_state, frame_mask} = {data_memory.READ, 4'b1111}; 
            
            // Store Instructions

            // SB
            10'b000_0100011 : {memory_state, frame_mask} = 
            {   data_memory.WRITE, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            }; 
            // SH
            10'b001_0100011 : {memory_state, frame_mask} = 
            {   data_memory.WRITE,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            }; 
            // SW
            10'b010_0100011 : {memory_state, frame_mask} = {data_memory.WRITE, 4'b1111};
            default: {memory_state, frame_mask} = 5'bz;
        endcase    
    end

    Memory_Interface data_memory 
    (
        .CLK(CLK),
        .enable(enable), 
        .memory_state(memory_state),
        .frame_mask(frame_mask),
        .address(address), 
        .data(data), 
        .memory_done(memory_done)
    );

endmodule