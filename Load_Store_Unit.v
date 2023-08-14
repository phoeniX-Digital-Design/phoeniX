`include "Memory_Interface.v"

module Load_Store_Unit
(     
    input CLK,
    input enable,
    
    input  [6 : 0] opcode,
    input  [2 : 0] funct3,

    input  [31 : 0] address,
    input  [31 : 0] store_data,
    output [31 : 0] load_data
);
    wire   memory_state;
    wire   memory_done;
    wire   [3  : 0] frame_mask;
    wire   [31 : 0] data;
    

    always @(*) begin

        casex ({funct3, opcode})
            // Load Instructions
            10'b000_0000011 : 
            10'b001_0000011 :
            10'b010_0000011 :
            10'b100_0000011 : 
            10'b101_0000011 : 
            // Store Instructions
            10'b000_0100011 : 
            10'b001_0100011 :
            10'b010_0100011 :
            default: 
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