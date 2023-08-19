`define I_TYPE 0
`define B_TYPE 1
`define S_TYPE 2
`define U_TYPE 3
`define J_TYPE 4
`define R_TYPE 5

module Control_Unit 
(
    // Signals form instruction decoder
    input [6 : 0] opcode,               // inputs from Instruction Decoder
    input [2 : 0] funct3,               // inputs from Instruction Decoder
    input [6 : 0] funct7,               // inputs from Instruction Decoder
    input [2 : 0] instruction_type,     // inputs from Instruction Decoder

    output reg address_type,            // select type for Address Generator module

    output reg  mux1_select,            // ALU multiplexer select pin
    output reg [1 : 0] mux2_select,     // ALU multiplexer select pin

    output reg [2 : 0] forward_control, // Forwarding multiplexers control pins

    output reg fetch_enable,            // Fetch Unit enable pin

    output reg lsu_enable,              // Load Store Unit enable pin

    output reg read_enable_1,           // Register File read port 1 enable
    output reg read_enable_2,           // Register File read port 2 enable
    output reg write_enable,            // Register File write port enable

    // output reg IR_enable,               // Instruction Register enbale pin
    // output reg PC_enable,               // Program Counter enbale pin

    output reg writeback_output_select  // Writeback stage output select  between
                                        // execution unit output and LSU output
);

    always @(*) begin

        // Address Type evaluation (for Address Generator module)
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
        
        // ALU multiplexers signals evaluation
        case (opcode)
            7'b0110011 : begin mux1_select = 1'b0; mux2_select = 2'b00; end // R-TYPE instructions
            7'b0010011 : begin mux1_select = 1'b0; mux2_select = 2'b01; end // I-TYPE instructions
            7'b1101111 : begin mux1_select = 1'b1; mux2_select = 2'b10; end // JAL    instructions
            7'b1100111 : begin mux1_select = 1'b1; mux2_select = 2'b10; end // JALR   instructions
        endcase

        // Load and Store signals evaluation
        case (opcode)
            7'b0000011 : lsu_enable = 1'b1;
            7'b0100011 : lsu_enable = 1'b1;
            default    : lsu_enable = 1'b0;
        endcase

        // Fetch done signal evaluation
        // ------------------------------------------------
        // This signal is generated according to exceptions
        // ------------------------------------------------

        // Writeback enable signal evaluation
        case (opcode)
            7'b0000011 : writeback_output_select = 2'b01;
            7'b0010011 : writeback_output_select = 2'b10;
            7'b0110011 : writeback_output_select = 2'b10;
            7'b0110011 : writeback_output_select = 2'b10;
            7'b1101111 : writeback_output_select = 2'b10;
            7'b1100111 : writeback_output_select = 2'b10;
            7'b0010111 : writeback_output_select = 2'b10;
            7'b0110111 : writeback_output_select = 2'b00;
        endcase

    end
      
endmodule