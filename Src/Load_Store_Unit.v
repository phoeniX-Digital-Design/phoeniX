// `include "Memory_Interface.v"
// `include "..\\Memory_Interface.v"

module Load_Store_Unit
(     
    input CLK,
    input enable,
    
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
    

    // Memory State and Frame Mask Generation
    always @(*) 
    begin
        {memory_state, frame_mask} = {1'bx, 4'bx};

        case ({funct3, opcode})
            // Load Instructions
            
            // LB and LBU
            10'b000_0000011, 10'b100_0000011: {memory_state, frame_mask} = 
            {   data_memory.READ, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            };

            // LH and LHU
            10'b001_0000011, 10'b101_0000011 : {memory_state, frame_mask} = 
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

            default : {memory_state, frame_mask} = {1'b0, 4'b0};
        endcase    
    end

    // Data Management in case of Store Instruction
    assign data = opcode == 7'b0100011 ? store_data : 32'bz;

    // Instantiating Memory Interface for Data Memory
    Memory_Interface data_memory 
    (
        .CLK(CLK),
        .enable(enable), 
        .memory_state(memory_state),
        .frame_mask(frame_mask),
        .address(address & 32'hFFFFFFFC), 
        .data(data), 
        .memory_done(memory_done)
    );
    
    // Latch condition when Loading
    always @(posedge memory_done)
    begin
        casex ({funct3, opcode})
            10'b000_0000011 : load_data <= { {24{data[7]}}, data[7 : 0]};       // LB
            10'b001_0000011 : load_data <= { {16{data[15]}}, data[15 : 0]};     // LH
            10'b100_0000011 : load_data <= { 24'b0, data[7 : 0]};               // LBU
            10'b101_0000011 : load_data <= { 16'b0, data[15 : 0]};              // LHU
            10'b010_0000011 : load_data <= data;                                // LW
        endcase    
    end
endmodule