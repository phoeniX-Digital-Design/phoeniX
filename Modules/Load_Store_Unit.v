`include "Defines.v"

module Load_Store_Unit
(
    input wire [ 6 : 0] opcode,                  
    input wire [ 2 : 0] funct3,                  

    input wire [31 : 0] address,           
    input wire [31 : 0] store_data,        
    output reg [31 : 0] load_data,         

    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////

    output  reg  memory_interface_enable,
    output  reg  memory_interface_state,
    output  reg  [31 : 0] memory_interface_address,
    output  reg  [ 3 : 0] memory_interface_frame_mask,
    inout        [31 : 0] memory_interface_data
);
    
    // Memory Interface Enable Signal Generation
    always @(*)
    begin
        case (opcode)
            `LOAD   : begin memory_interface_enable = `ENABLE;  memory_interface_address = {address[31 : 2], 2'b00}; end
            `STORE  : begin memory_interface_enable = `ENABLE;  memory_interface_address = {address[31 : 2], 2'b00}; end 
            default : begin memory_interface_enable = `DISABLE; memory_interface_address = 32'bz; end
        endcase
    end

    // Memory State and Frame Mask Generation
    always @(*) 
    begin
        {memory_interface_state, memory_interface_frame_mask} = {1'bz, 4'bz};

        case ({opcode, funct3})
            // Load Instructions
            
            // LB and LBU
            {`LOAD, `BYTE}, {`LOAD, `BYTE_UNSIGNED}: {memory_interface_state, memory_interface_frame_mask} = 
            {   `READ, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            };

            // LH and LHU
            {`LOAD, `HALFWORD}, {`LOAD, `HALFWORD_UNSIGNED} : {memory_interface_state, memory_interface_frame_mask} = 
            {   `READ,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            };

            // LW
            {`LOAD, `WORD} : {memory_interface_state, memory_interface_frame_mask} = {`READ, 4'b1111}; 
            
            // Store Instructions

            // SB
            {`STORE, `BYTE} : {memory_interface_state, memory_interface_frame_mask} = 
            {   `WRITE, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            }; 

            // SH
            {`STORE, `HALFWORD} : {memory_interface_state, memory_interface_frame_mask} = 
            {   `WRITE,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            }; 

            // SW
            {`STORE, `WORD} : {memory_interface_state, memory_interface_frame_mask} = {`WRITE, 4'b1111};

            default : {memory_interface_state, memory_interface_frame_mask} = {1'bz, 4'bz};
        endcase    
    end

    // Data Management in case of Store Instruction
    reg [31 : 0] store_data_reg;
    assign memory_interface_data = opcode == `STORE ? store_data_reg : 32'bz;

    // Latch condition when Loading
    always @(*)
    begin
        if (opcode == `LOAD)
        case (funct3)
            `BYTE : 
            begin
                if (memory_interface_frame_mask == 4'b0001) load_data = { {24{memory_interface_data[31]}}, memory_interface_data[31 : 24]}; 
                if (memory_interface_frame_mask == 4'b0010) load_data = { {24{memory_interface_data[23]}}, memory_interface_data[23 : 16]}; 
                if (memory_interface_frame_mask == 4'b0100) load_data = { {24{memory_interface_data[15]}}, memory_interface_data[15 :  8]}; 
                if (memory_interface_frame_mask == 4'b1000) load_data = { {24{memory_interface_data[ 7]}}, memory_interface_data[ 7 :  0]}; 
            end    
              
            `BYTE_UNSIGNED : 
            begin
                if (memory_interface_frame_mask == 4'b0001) load_data = { 24'b0, memory_interface_data[31 : 24]};
                if (memory_interface_frame_mask == 4'b0010) load_data = { 24'b0, memory_interface_data[23 : 16]};
                if (memory_interface_frame_mask == 4'b0100) load_data = { 24'b0, memory_interface_data[15 :  8]};
                if (memory_interface_frame_mask == 4'b1000) load_data = { 24'b0, memory_interface_data[ 7 :  0]}; 
            end

            `HALFWORD : 
            begin
                if (memory_interface_frame_mask == 4'b0011) load_data = { {16{memory_interface_data[31]}}, memory_interface_data[31 : 16]};
                if (memory_interface_frame_mask == 4'b1100) load_data = { {16{memory_interface_data[15]}}, memory_interface_data[15 :  0]};
            end
            `HALFWORD_UNSIGNED :
            begin
                if (memory_interface_frame_mask == 4'b0011) load_data = { 16'b0, memory_interface_data[31 : 16]};
                if (memory_interface_frame_mask == 4'b1100) load_data = { 16'b0, memory_interface_data[15 :  0]};
            end 
            `WORD : load_data = memory_interface_data;         
            default load_data = 32'bz;                                      
        endcase    
        else load_data = 32'bz;

        if (opcode == `STORE)
        case (funct3)
            `BYTE : 
            begin
                if (memory_interface_frame_mask == 4'b0001) store_data_reg[31 : 24] = store_data[ 7 : 0];
                if (memory_interface_frame_mask == 4'b0010) store_data_reg[23 : 16] = store_data[ 7 : 0];
                if (memory_interface_frame_mask == 4'b0100) store_data_reg[15 :  8] = store_data[ 7 : 0];
                if (memory_interface_frame_mask == 4'b1000) store_data_reg[ 7 :  0] = store_data[ 7 : 0];
            end 
            `HALFWORD : 
            begin
                if (memory_interface_frame_mask == 4'b0011) store_data_reg[31 : 16] = store_data[15 : 0];
                if (memory_interface_frame_mask == 4'b1100) store_data_reg[15 :  0] = store_data[15 : 0];
            end
            `WORD : 
            begin
                if (memory_interface_frame_mask == 4'b1111) store_data_reg[31 : 0] = store_data[31 : 0];
            end 
            default : store_data_reg = 32'bz;
        endcase
        else store_data_reg = 32'bz;
    end
endmodule