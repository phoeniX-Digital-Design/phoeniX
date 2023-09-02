`timescale 1ns/1ns
`include "..\Modules\Load_Store_Unit.v"

module LSU_Testbench;
    reg CLK     = 1'b1;

    // Clock generation
    always #6 CLK = ~CLK;

    reg  [6 : 0] opcode = 7'bz;
    reg  [2 : 0] funct3 = 3'bz;

    reg  [31 : 0] address = 32'bz;
    reg  [31 : 0] store_data = 32'bz; 
    wire [31 : 0] load_data;

    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////
    wire enable_Dmem;
    wire memory_state_Dmem;
    wire    [31 : 0] address_Dmem;
    wire    [3 : 0] frame_mask_Dmem;

    wire    [31 : 0] data_Dmem;
    reg     [31 : 0] data_Dmem_reg;
    assign data_Dmem = data_Dmem_reg;

    Load_Store_Unit uut 
    (
        .opcode(opcode),
        .funct3(funct3),

        .address(address),
        .store_data(store_data),
        .load_data(load_data),

        .memory_interface_enable(enable_Dmem),
        .memory_interface_memory_state(memory_state_Dmem),
        .memory_interface_address(address_Dmem),
        .memory_interface_frame_mask(frame_mask_Dmem),

        .memory_interface_data(data_Dmem)
    );

    initial 
    begin
        $dumpfile("LSU_Testbench.vcd");
        $dumpvars(0, LSU_Testbench);

        $readmemh("firmware.hex", Memory);

        // Wait for a few clock cycles

        // --> Load Word (32 bits) from address 16
        #12
        address = 32'd16;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        

        #12
        
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;
        
        // --> Load Byte (8 bits) from address 19 zero extend the result to 32 bits
        #12
        address = 32'd19;

        opcode = 7'b0000011;
        funct3 = 3'b100;
        

        #12
        
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Load Word (32 bits) from address 20
        #12 
        address = 32'd20;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        

        #12
        
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Store Word (32 bits) to address 20
        #12 
        address = 32'd20;
        store_data = 32'hFEDCBA98;
        opcode = 7'b0100011;
        funct3 = 3'b010;
        

        #12
        
        address = 32'bz;
        store_data = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Load Word (32 bits) from address 20
        #12 
        address = 32'd20;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        

        #12
        
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Store Half-Word (16 bits) to address 22
        #12 
        address = 32'd22;
        store_data = 32'hBABA;
        opcode = 7'b0100011;
        funct3 = 3'b001;
        

        #12
        
        address = 32'bz;
        store_data = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Load Word (32 bits) from address 20
        #12 
        address = 32'd20;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        

        #12
        
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Store Byte (8 bits) to address 22
        #12 
        address = 32'd22;
        store_data = 32'hAB;
        opcode = 7'b0100011;
        funct3 = 3'b000;
        

        #12
        
        address = 32'bz;
        store_data = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        // --> Load Word (32 bits) from address 20
        #12 
        address = 32'd20;
        
        opcode = 7'b0000011;
        funct3 = 3'b010;
        

        #12
        
        address = 32'bz;
        opcode = 7'bz;
        funct3 = 3'bz;

        #12;
        $finish;
    end

    // Memory 
    reg [31 : 0] Memory [0 : 16 * 1024 - 1];

    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;
    
    // Memeory Interface Behaviour
    always @(negedge CLK) 
    begin
        if (!enable_Dmem)   data_Dmem_reg <= 32'bz;
        else
        begin
            if (memory_state_Dmem == WRITE) 
            begin
                if (frame_mask_Dmem[3]) Memory[address_Dmem >> 2][ 7 :  0] <= data_Dmem[ 7 :  0];
                if (frame_mask_Dmem[2]) Memory[address_Dmem >> 2][15 :  8] <= data_Dmem[15 :  8];
                if (frame_mask_Dmem[1]) Memory[address_Dmem >> 2][23 : 16] <= data_Dmem[23 : 16];
                if (frame_mask_Dmem[0]) Memory[address_Dmem >> 2][31 : 24] <= data_Dmem[31 : 24];
            end 
            if (memory_state_Dmem == READ)
                data_Dmem_reg <= Memory[address_Dmem >> 2];
        end    
    end
endmodule