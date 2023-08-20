`include "Register.v"
`include "Fetch_Unit.v"
`include "Control_Unit.v"

`include "Instruction_Decoder.v"
`include "Immediate_Generator.v"
`include "Register_File.v"

`include "Arithmetic_Logic_Unit.v"
`include "Jump_Branch_Unit.v"
`include "Address_Generator.v"

// `include "Load_Store_Unit.v"

module phoeniX 
#(
    parameter RESET_ADDRESS = 32'hFFFFFFFC
) (
    input CLK,
    input CLK_MEM,
    input reset
);

    // ---------------------------------
    // Wire Declarations for Fetch Stage
    // ---------------------------------
    wire [31 : 0] instruction_fetch_wire;
    wire [31 : 0] PC_fetch_wire;
    wire [31 : 0] next_PC_wire;
    
    // --------------------------------
    // Reg Declarations for Fetch Stage
    // --------------------------------
    reg [31 : 0] PC_fetch_reg;

    // ------------------------
    // Fetch Unit Instantiation
    // ------------------------
    Fetch_Unit fetch_unit
    (
        .CLK(CLK_MEM),
        .enable(!reset),              // TBD : to be changed to fetch control state with control
        .PC(PC_fetch_reg),
        .address(32'bz),
        .jump_branch_enable(1'b0),
        .next_PC(next_PC_wire),
        .fetched_instruction(instruction_fetch_wire)    
    );

    // ------------------------
    // Program Counter Register 
    // ------------------------

    always @(posedge CLK)
    begin
        if (reset)
            PC_fetch_reg <= RESET_ADDRESS;
        else
            PC_fetch_reg <= next_PC_wire; 
    end
    // Register program_counter 
    // (
    //     .CLK(CLK),
    //     .reset(reset),
    //     .enable(1'b1),               // TBD : to be changed to fetch control state with control     
    //     .RESET_VALUE(RESET_ADDRESS),

    //     .register_input(next_PC_reg),
    //     .register_output(PC_fetch_wire)
    // );
    
    // --------------------------------------
    // Register Declarations for Decode Stage
    // --------------------------------------
    reg [31 : 0] instruction_decode_reg;
    reg [31 : 0] PC_decode_reg; 

    ////////////////////////////////////////
    //     FETCH TO DECODE TRANSITION     //
    ////////////////////////////////////////
    always @(posedge CLK) 
    begin
        instruction_decode_reg <= instruction_fetch_wire;
        PC_decode_reg <= PC_fetch_reg;    
    end

    // ----------------------------------
    // Wire Declarations for Decode Stage
    // ----------------------------------
    wire [2 : 0] instruction_type_decode_wire;
    wire [6 : 0] opcode_decode_wire;
    wire [2 : 0] funct3_decode_wire;
    wire [6 : 0] funct7_decode_wire;
    wire [4 : 0] read_index_1_decode_wire;
    wire [4 : 0] read_index_2_decode_wire;
    wire [4 : 0] write_index_decode_wire;
    wire [31 : 0] immediate_decode_wire;

    // ---------------------------------
    // Instruction Decoder Instantiation
    // ---------------------------------
    Instruction_Decoder Instruction_Decoder
    (
        .instruction(instruction_decode_reg),
        .instruction_type(instruction_type_decode_wire),
        .opcode(opcode_decode_wire),
        .funct3(funct3_decode_wire),
        .funct7(funct7_decode_wire),
        .read_index_1(read_index_1_decode_wire),
        .read_index_2(read_index_2_decode_wire),
        .write_index(write_index_decode_wire)
    );

    // ---------------------------------
    // Immediate Generator Instantiation
    // --------------------------------- 
    Immediate_Generator immediate_generator
    (
        .instruction(instruction_decode_reg),
        .instruction_type(instruction_type_decode_wire),
        .immediate(immediate_decode_wire)
    );

endmodule