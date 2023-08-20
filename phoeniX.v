`include "Register.v"
`include "Fetch_Unit.v"

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
    wire read_enable_1_decode_wire;
    wire read_enable_2_decode_wire;
    wire write_enable_decode_wire;

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
        .write_index(write_index_decode_wire),
        .read_enable_1(read_enable_1_decode_wire),
        .read_enable_2(read_enable_2_decode_wire),
        .write_enable(write_enable_decode_wire)
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

    // -----------------------------------------------
    // Wire Declaration for Reading From Register File
    // ----------------------------------------------- 
    wire [31 : 0] RF_source_1;
    wire [31 : 0] RF_source_2;

    // -----------------------------------------------
    // Wire Declaration for inputs to source bus 1 & 2
    // ----------------------------------------------- 
    wire [31 : 0] bus_rs1_decode_wire;
    wire [31 : 0] bus_rs2_decode_wire;

    // ----------------------------------------------------------------------------------------
    // assign inputs to source bus 1 & 2  --> TBD: to be selected between RF source and FW data
    // ----------------------------------------------------------------------------------------
    assign bus_rs1_decode_wire = RF_source_1;
    assign bus_rs2_decode_wire = RF_source_2;
    
    // ----------------------------------
    // Reg Declarations for Execute Stage
    // ----------------------------------
    reg [31 : 0] PC_execute_reg;

    reg [6 : 0] opcode_execute_reg;
    reg [2 : 0] funct3_execute_reg;
    reg [6 : 0] funct7_execute_reg;

    reg [31 : 0] immediate_execute_reg;
    reg [2 : 0] instruction_type_execute_reg;
    reg [4 : 0] write_index_execute_reg;
    reg write_enable_execute_reg;
    
    reg [31 : 0] bus_rs1;
    reg [31 : 0] bus_rs2;

    ////////////////////////////////////////
    //    DECODE TO EXECUTE TRANSITION    //
    ////////////////////////////////////////
    always @(posedge CLK) 
    begin
        PC_execute_reg <= PC_decode_reg;

        opcode_execute_reg <= opcode_decode_wire;
        funct3_execute_reg <= funct3_decode_wire;
        funct7_execute_reg <= funct7_decode_wire;

        immediate_execute_reg <= immediate_decode_wire; 
        instruction_type_execute_reg <= instruction_type_decode_wire;
        write_index_execute_reg <= write_index_decode_wire;
        write_enable_execute_reg <= write_enable_decode_wire;    
    end

    // ------------------------------------
    // Wire Declaration for Execution Units
    // ------------------------------------
    wire [31 : 0] alu_output_execute_wire;

    // -----------------------------------
    // Arithmetic Logic Unit Instantiation
    // -----------------------------------
    Arithmetic_Logic_Unit arithmetic_logic_unit
    (
        .opcode(opcode_execute_reg),
        .funct3(funct3_execute_reg),
        .funct7(funct7_execute_reg),

        .PC(PC_execute_reg),
        .rs1(bus_rs1),
        .rs2(bus_rs2),
        .immediate(immediate_execute_reg),
        .alu_output(alu_output_execute_wire)
    );


    // --------------------------------
    // Reg Declarations for Memory Stage
    // --------------------------------
    reg [31 : 0] PC_memory_reg;

    reg [6 : 0] opcode_memory_reg;
    reg [2 : 0] funct3_memory_reg;
    reg [6 : 0] funct7_memory_reg;

    reg [31 : 0] immediate_memory_reg;
    reg [2 : 0] instruction_type_memory_reg;
    reg [4 : 0] write_index_memory_reg;
    reg write_enable_memory_reg;

    ////////////////////////////////////////
    //    EXECUTE TO MEMORY TRANSITION    //
    ////////////////////////////////////////
    always @(posedge CLK) 
    begin
        PC_memory_reg <= PC_execute_reg;

        opcode_memory_reg <= opcode_execute_reg;
        funct3_memory_reg <= funct3_execute_reg;
        funct7_memory_reg <= funct7_execute_reg;
        
        immediate_memory_reg <= immediate_execute_reg;
        instruction_type_memory_reg <= instruction_type_execute_reg;
        write_index_memory_reg <= write_index_execute_reg;
        write_enable_memory_reg <= write_enable_execute_reg;    
    end


    // --------------------------------
    // Reg Declarations for Write-Back Stage
    // --------------------------------
    reg [31 : 0] PC_writeback_reg;

    reg [6 : 0] opcode_writeback_reg;
    reg [2 : 0] funct3_writeback_reg;
    reg [6 : 0] funct7_writeback_reg;

    reg [31 : 0] write_data_writeback_reg;
    reg [4 : 0] write_index_writeback_reg;
    reg write_enable_writeback_reg;

    ////////////////////////////////////////
    //   MEMORY TO WRITEBACK TRANSITION   //
    ////////////////////////////////////////
    always @(posedge CLK) 
    begin
        PC_writeback_reg <= PC_memory_reg;

        opcode_writeback_reg <= opcode_memory_reg;
        funct3_writeback_reg <= funct3_memory_reg;
        funct7_writeback_reg <= funct7_memory_reg;

        write_index_writeback_reg <= write_index_memory_reg;
        write_enable_writeback_reg <= write_enable_memory_reg;    
    end
    

    ////////////////////////////////////////
    //    Register File Instantiation     //
    ////////////////////////////////////////
    Register_File 
    #(
        .WIDTH(32),
        .DEPTH(5)
    )
    register_file
    (
        .CLK(CLK),
        .reset(reset),

        .read_enable_1(1'b0 & read_enable_1),
        .read_enable_2(1'b0 & read_enable_2),
        .write_enable(1'b0 & write_enable_writeback_reg),

        .read_index_1(read_index_1_decode_wire),
        .read_index_2(read_index_2_decode_wire),
        .write_index(write_index_decode_wire),

        .write_data(write_data_writeback_reg),
        .read_data_1(RF_source_1),
        .read_data_2(RF_source_2)
    );
endmodule