`define I_TYPE 0
`define B_TYPE 1
`define S_TYPE 2
`define U_TYPE 3
`define J_TYPE 4
`define R_TYPE 6

module Control_Unit 
(
    input [6 : 0] opcode,               // inputs from Instruction Decoder
    input [2 : 0] funct3,               // inputs from Instruction Decoder
    input [6 : 0] funct7,               // inputs from Instruction Decoder
    input [2 : 0] instruction_type,     // inputs from Instruction Decoder

    input forward_exe_mux1,             // Forward data from execution satge - mux 1
    input forward_exe_mux2,             // Forward data from execution satge - mux 2
    input forward_mem_mux1,             // Forward data from memory satge - mux 1
    input forward_mem_mux2,             // Forward data from memory satge - mux 2

    input fetch_done,                   // Fetch operation end signal from Fetch Unit

    output reg address_type,            // select type for Address Generator module

    output reg [2 : 0] mux1_select,     // ALU multiplexer select pin
    output reg [3 : 0] mux2_select,     // ALU multiplexer select pin

    output reg fetch_enable,            // Fetch Unit enable pin

    output reg lsu_enable,              // Load Store Unit enable pin

    output reg read_enable_1,           // Register File read port 1 enable
    output reg read_enable_2,           // Register File read port 2 enable
    output reg write_enable,            // Register File write port enable

    output reg IR_enable,               // Instruction Register enbale pin
    output reg PC_enable,               // Program Counter enbale pin

    output reg writeback_output_signal  // Writeback stage output select  between
                                        // execution unit output and LSU output
);

    always @(*) begin

        // Address Type evaluation
        case (opcode)
            7'b0100011: address_type = 1'b1;    //  Store  -> bus_rs1 + immediate
            7'b0000011: address_type = 1'b1;    //  Load   -> bus_rs1 + immediate
            7'b1101111: address_type = 1'b0;    //  JAL    ->    PC   + immediate
            7'b1100111: address_type = 1'b0;    //  JALR   ->    PC   + immediate
            7'b1100011: address_type = 1'b0;    //  Brnach ->    PC   + immediate
            default: address_type = 1'bz;
        endcase

        // Register File read/write enable signals evaluation
        case (instruction_type)
            `I_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b0; write_enable = 1'b1; end
            `B_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b0; end
            `S_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b0; end
            `U_TYPE : begin read_enable_1 = 1'b0; read_enable_2 = 1'b0; write_enable = 1'b1; end
            `J_TYPE : begin read_enable_1 = 1'b0; read_enable_2 = 1'b0; write_enable = 1'b1; end 
            `R_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b1; end
            default : begin end // Exception raise 
        endcase

        // ALU multiplexers select pin evaluation
        case ({forward_mem_mux2, forward_mem_mux1, forward_exe_mux2, forward_exe_mux1, opcode})
            // Multiplexer outputs without forwarding data
            11'b0_0_0_0_0010011 : begin mux1_select = 2'b00; mux2_select = 3'b010; end // I-TYPE ALU operations
            11'b0_0_0_0_0110011 : begin mux1_select = 2'b00; mux2_select = 3'b000; end // R-TYPE ALU operations
            11'b0_0_0_0_1101111 : begin mux1_select = 2'b10; mux2_select = 3'b011; end // JAL  instruction
            11'b0_0_0_0_1100111 : begin mux1_select = 2'b10; mux2_select = 3'b011; end // JALR instruction
            
            // Multiplexer outputs with forwarding data from execution stage
            11'b0_0_0_1_0010011 : begin mux1_select = 2'b01; mux2_select = 3'b010; end // I-TYPE ALU operations
            11'b0_0_0_1_0110011 : begin mux1_select = 2'b01; mux2_select = 3'b000; end // R-TYPE ALU operations
            11'b0_0_1_0_0110011 : begin mux1_select = 2'b00; mux2_select = 3'b001; end // R-TYPE ALU operations
            11'b0_0_1_1_0110011 : begin mux1_select = 2'b01; mux2_select = 3'b001; end // R-TYPE ALU operations
            // JAL and JALR ???? *****************************************************

            // Multiplexer outputs with forwarding data from memory unit
            11'b0_1_0_0_0010011 : begin mux1_select = 2'b11; mux2_select = 3'b010; end // I-TYPE ALU operations
            11'b0_1_0_0_0110011 : begin mux1_select = 2'b11; mux2_select = 3'b000; end // R-TYPE ALU operations
            11'b1_0_0_0_0110011 : begin mux1_select = 2'b00; mux2_select = 3'b100; end // R-TYPE ALU operations
            11'b1_1_0_0_0110011 : begin mux1_select = 2'b11; mux2_select = 3'b100; end // R-TYPE ALU operations
            // JAL and JALR ???? *****************************************************

            //Multiplexer outputs with forwarding data from both execution and memory units

        endcase
        
    end
      
endmodule