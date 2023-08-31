`include "Modules\\Fetch_Unit.v"
`include "Modules\\Memory_Interface.v"
`include "Modules\\Instruction_Decoder.v"
`include "Modules\\Immediate_Generator.v"
`include "Modules\\Register_File.v"
`include "Modules\\Arithmetic_Logic_Unit.v"
`include "Modules\\Jump_Branch_Unit.v"
`include "Modules\\Address_Generator.v"
`include "Modules\\Load_Store_Unit.v"
`include "Modules\\Hazard_Forward_Unit.v"
`include "Modules\\Defines.v"

`define NOP         32'h0000_0013
`define NOP_OPCODE  `OP_IMM
`define NOP_funct7  7'bz
`define NOP_funct3  3'b000

module phoeniX 
#(
    parameter RESET_ADDRESS = 32'hFFFFFFFC
) 
(
    input CLK,
    input reset,

    //////////////////////////////////////////
    // Instruction Memory Interface Signals //
    //////////////////////////////////////////
    output instruction_memory_interface_enable,
    output instruction_memory_interface_state,
    output  [31 : 0] instruction_memory_interface_address,
    output  [ 3 : 0] instruction_memory_interface_frame_mask,
    input   [31 : 0] instruction_memory_interface_data, 

    ///////////////////////////////////
    // Data Memory Interface Signals //
    ///////////////////////////////////
    output data_memory_interface_enable,
    output data_memory_interface_state,
    output  [31 : 0] data_memory_interface_address,
    output  [ 3 : 0] data_memory_interface_frame_mask,
    inout   [31 : 0] data_memory_interface_data 
);
    // ---------------------------------
    // Wire Declarations for Fetch Stage
    // ---------------------------------
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
        .enable(!reset),              // TBD : to be changed to fetch control state with control
        .PC(PC_fetch_reg),
        .address(address_execute_wire),
        .jump_branch_enable(jump_branch_enable_execute_wire),
        .next_PC(next_PC_wire),

        .memory_interface_enable(instruction_memory_interface_enable),
        .memory_interface_state(instruction_memory_interface_state),
        .memory_interface_address(instruction_memory_interface_address),
        .memory_interface_frame_mask(instruction_memory_interface_frame_mask)    
    );

    // ------------------------
    // Program Counter Register 
    // ------------------------
    always @(posedge CLK)
    begin
        if (reset)
            PC_fetch_reg <= RESET_ADDRESS;
        else if (stall)
            PC_fetch_reg <= PC_stall_address;
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
        PC_decode_reg <= PC_fetch_reg;

        if (jump_branch_enable_execute_wire || stall)
            instruction_decode_reg <= `NOP;
        else
            instruction_decode_reg <= instruction_memory_interface_data;
    end

    // ----------------------------------
    // Wire Declarations for Decode Stage
    // ----------------------------------
    wire [ 2 : 0] instruction_type_decode_wire;
    
    wire [ 6 : 0] opcode_decode_wire;
    wire [ 2 : 0] funct3_decode_wire;
    wire [ 6 : 0] funct7_decode_wire;
    wire [11 : 0] funct12_decode_wire;

    wire [ 4 : 0] read_index_1_decode_wire;
    wire [ 4 : 0] read_index_2_decode_wire;
    wire [ 4 : 0] write_index_decode_wire;
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
        .funct12(funct12_decode_wire),
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

    wire [31 : 0] FW_source_1;
    wire [31 : 0] FW_source_2;
    
    wire FW_enable_1;
    wire FW_enable_2;

    // -----------------------------------------------
    // Wire Declaration for inputs to source bus 1 & 2
    // ----------------------------------------------- 
    wire [31 : 0] bus_rs1_decode_wire;
    wire [31 : 0] bus_rs2_decode_wire;

    // -----------------------------------------------------------------------------------
    // assign inputs to source bus 1 & 2  --> to be selected between RF source and FW data
    // -----------------------------------------------------------------------------------
    assign bus_rs1_decode_wire = FW_enable_1 ? FW_source_1 : RF_source_1;
    assign bus_rs2_decode_wire = FW_enable_2 ? FW_source_2 : RF_source_2;
    
    // ----------------------------------
    // Reg Declarations for Execute Stage
    // ----------------------------------
    reg [31 : 0] PC_execute_reg;
    reg [31 : 0] instruction_execute_reg;

    reg [6 : 0] opcode_execute_reg;
    reg [2 : 0] funct3_execute_reg;
    reg [6 : 0] funct7_execute_reg;

    reg [31 : 0] immediate_execute_reg;
    reg [ 2 : 0] instruction_type_execute_reg;
    reg [ 4 : 0] write_index_execute_reg;
    reg write_enable_execute_reg;
    
    reg [31 : 0] bus_rs1;
    reg [31 : 0] bus_rs2;

    ////////////////////////////////////////
    //    DECODE TO EXECUTE TRANSITION    //
    ////////////////////////////////////////
    always @(posedge CLK) 
    begin
        PC_execute_reg <= PC_decode_reg;

        if (jump_branch_enable_execute_wire || stall)
        begin
            instruction_execute_reg <= `NOP;
            write_enable_execute_reg <= 1'b0;  

            opcode_execute_reg <= `NOP_OPCODE;
            funct3_execute_reg <= `NOP_funct3;
            funct7_execute_reg <= `NOP_funct7;
        end
        else
        begin
            instruction_execute_reg <= instruction_decode_reg;
            write_enable_execute_reg <= write_enable_decode_wire;
            
            opcode_execute_reg <= opcode_decode_wire;
            funct3_execute_reg <= funct3_decode_wire;
            funct7_execute_reg <= funct7_decode_wire;
        end

        immediate_execute_reg <= immediate_decode_wire; 
        instruction_type_execute_reg <= instruction_type_decode_wire;
        write_index_execute_reg <= write_index_decode_wire;
        
        bus_rs1 <= bus_rs1_decode_wire;
        bus_rs2 <= bus_rs2_decode_wire;
    end

    // ------------------------------------
    // Wire Declaration for Execution Units
    // ------------------------------------
    wire [31 : 0] alu_output_execute_wire;
    wire [31 : 0] address_execute_wire;
    wire jump_branch_enable_execute_wire;

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

    // ------------------------------------
    // Address Generator Unit Instantiation
    // ------------------------------------
    Address_Generator address_generator
    (
        .opcode(opcode_execute_reg),
        .rs1(bus_rs1),
        .PC(PC_execute_reg),
        .immediate(immediate_execute_reg),
        .address(address_execute_wire)
    );

    // ------------------------------
    // Jump Branch Unit Instantiation
    // ------------------------------
    Jump_Branch_Unit jump_branch_unit
    (
        .opcode(opcode_execute_reg),
        .funct3(funct3_execute_reg),
        .instruction_type(instruction_type_execute_reg),
        .rs1(bus_rs1),
        .rs2(bus_rs2),
        .jump_branch_enable(jump_branch_enable_execute_wire)
    );

    // ----------------------------------------
    // Wire Declaration for result of execution
    // ----------------------------------------
    wire [31 : 0] result_execute_wire;

    // ----------------------------------------------------------
    // assigning result to alu output or mul output or fpu output
    // ----------------------------------------------------------
    assign result_execute_wire = alu_output_execute_wire;

    // --------------------------------
    // Reg Declarations for Memory Stage
    // --------------------------------
    reg [31 : 0] PC_memory_reg;
    reg [31 : 0] instruction_memory_reg;

    reg [6 : 0] opcode_memory_reg;
    reg [2 : 0] funct3_memory_reg;
    reg [6 : 0] funct7_memory_reg;

    reg [31 : 0] immediate_memory_reg;
    reg [ 2 : 0] instruction_type_memory_reg;
    reg [ 4 : 0] write_index_memory_reg;
    reg write_enable_memory_reg;

    reg [31 : 0] address_memory_reg;
    reg [31 : 0] bus_rs2_memory_reg;
    reg [31 : 0] result_memory_reg;

    reg jump_branch_enable_memory_reg;

    ////////////////////////////////////////
    //    EXECUTE TO MEMORY TRANSITION    //
    ////////////////////////////////////////
    always @(posedge CLK) 
    begin
        PC_memory_reg <= PC_execute_reg;
        instruction_memory_reg <= instruction_execute_reg;

        opcode_memory_reg <= opcode_execute_reg;
        funct3_memory_reg <= funct3_execute_reg;
        funct7_memory_reg <= funct7_execute_reg;
        
        immediate_memory_reg <= immediate_execute_reg;
        instruction_type_memory_reg <= instruction_type_execute_reg;
        write_index_memory_reg <= write_index_execute_reg;
        write_enable_memory_reg <= write_enable_execute_reg;    

        address_memory_reg <= address_execute_wire;
        bus_rs2_memory_reg <= bus_rs2;
        result_memory_reg <= result_execute_wire;

        result_memory_reg <= result_execute_wire;

        jump_branch_enable_memory_reg <= jump_branch_enable_execute_wire;
    end

    // ----------------------------------
    // Wire Declarations for Memory Stage
    // ----------------------------------
    wire [31 : 0] load_data_memory_wire;

    // -----------------------------
    // Load Store Unit Instantiation
    // -----------------------------
    Load_Store_Unit load_store_unit
    (
        .opcode(opcode_memory_reg),
        .funct3(funct3_memory_reg),
        .address(address_memory_reg),
        .store_data(bus_rs2_memory_reg),
        .load_data(load_data_memory_wire),

        .memory_interface_enable(data_memory_interface_enable),
        .memory_interface_state(data_memory_interface_state),
        .memory_interface_address(data_memory_interface_address),
        .memory_interface_frame_mask(data_memory_interface_frame_mask),
        .memory_interface_data(data_memory_interface_data)
    );

    // -------------------------------------
    // Reg Declarations for Write-Back Stage
    // -------------------------------------
    reg [31 : 0] PC_writeback_reg;
    reg [31 : 0] instruction_writeback_reg;

    reg [6 : 0] opcode_writeback_reg;
    reg [2 : 0] funct3_writeback_reg;
    reg [6 : 0] funct7_writeback_reg;

    reg [31 : 0] immediate_writeback_reg;
    reg [ 2 : 0] instruction_type_writeback_reg;
    reg [ 4 : 0] write_index_writeback_reg;
    reg write_enable_writeback_reg;

    reg [31 : 0] load_data_writeback_reg;
    reg [31 : 0] result_writeback_reg;

    ////////////////////////////////////////
    //   MEMORY TO WRITEBACK TRANSITION   //
    ////////////////////////////////////////
    always @(posedge CLK) 
    begin
        PC_writeback_reg <= PC_memory_reg;
        instruction_writeback_reg <= instruction_memory_reg;
        
        opcode_writeback_reg <= opcode_memory_reg;
        funct3_writeback_reg <= funct3_memory_reg;
        funct7_writeback_reg <= funct7_memory_reg;

        immediate_writeback_reg <= immediate_memory_reg;
        instruction_type_writeback_reg <= instruction_type_memory_reg;
        write_index_writeback_reg <= write_index_memory_reg;
        write_enable_writeback_reg <= write_enable_memory_reg; 

        load_data_writeback_reg <= load_data_memory_wire;  
        result_writeback_reg <= result_memory_reg; 
    end
    
    // ---------------------------------------------------------------
    // assigning write back data from immediate or load data or result
    // ---------------------------------------------------------------
    reg [31 : 0] write_data_writeback_reg;
    always @(*) 
    begin    
        case (opcode_writeback_reg)
            `OP_IMM : write_data_writeback_reg = result_writeback_reg;
            `OP     : write_data_writeback_reg = result_writeback_reg;
            `JAL    : write_data_writeback_reg = result_writeback_reg;
            `JALR   : write_data_writeback_reg = result_writeback_reg;
            `AUIPC  : write_data_writeback_reg = result_writeback_reg;
            `LOAD   : write_data_writeback_reg = load_data_writeback_reg;
            `LUI    : write_data_writeback_reg = immediate_writeback_reg;
        endcase
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

        .read_enable_1(read_enable_1_decode_wire),
        .read_enable_2(read_enable_2_decode_wire),
        .write_enable(opcode_execute_reg == `LUI ? write_enable_execute_reg : write_enable_writeback_reg),

        .read_index_1(read_index_1_decode_wire),
        .read_index_2(read_index_2_decode_wire),
        .write_index(opcode_execute_reg == `LUI ? write_index_execute_reg : write_index_writeback_reg),

        .write_data(opcode_execute_reg == `LUI ? immediate_execute_reg : write_data_writeback_reg),
        .read_data_1(RF_source_1),
        .read_data_2(RF_source_2)
    );

    ////////////////////////////////////////
    //     Hazard Detection Units         //
    ////////////////////////////////////////
    Hazard_Forward_Unit hazard_forward_unit_source_1
    (
        .source_index(read_index_1_decode_wire),
        
        .destination_index_1(write_index_execute_reg),
        .destination_index_2(write_index_memory_reg),
        .destination_index_3(write_index_writeback_reg),

        .data_1(opcode_execute_reg == `LUI ? immediate_execute_reg : result_execute_wire),
        .data_2(opcode_memory_reg == `LOAD ? load_data_memory_wire : result_memory_reg),
        .data_3(write_data_writeback_reg),

        .enable_1(write_enable_execute_reg),
        .enable_2(write_enable_memory_reg),
        .enable_3(write_enable_writeback_reg),

        .forward_enable(FW_enable_1),
        .forward_data(FW_source_1)
    );

    Hazard_Forward_Unit hazard_forward_unit_source_2
    (
        .source_index(read_index_2_decode_wire),
        
        .destination_index_1(write_index_execute_reg),
        .destination_index_2(write_index_memory_reg),
        .destination_index_3(write_index_writeback_reg),

        .data_1(opcode_execute_reg == `LUI ? immediate_execute_reg : result_execute_wire),
        .data_2(opcode_memory_reg == `LOAD ? load_data_memory_wire : result_memory_reg),
        .data_3(write_data_writeback_reg),

        .enable_1(write_enable_execute_reg),
        .enable_2(write_enable_memory_reg),
        .enable_3(write_enable_writeback_reg),

        .forward_enable(FW_enable_2),
        .forward_data(FW_source_2)
    );

    ////////////////////////////////////////
    //            Bubble Unit             //
    ////////////////////////////////////////    
    reg [31 : 0] PC_stall_address;
    reg stall;

    always @(*) 
    begin
        if  (opcode_execute_reg == `LOAD & (write_index_execute_reg == read_index_1_decode_wire || write_index_execute_reg == read_index_2_decode_wire ) & write_enable_execute_reg)
        begin
            stall = 1'b1;
            PC_stall_address = PC_decode_reg;
        end   
        else
        begin
            stall = 1'b0; 
            PC_stall_address = 32'bz; 
        end
    end
endmodule