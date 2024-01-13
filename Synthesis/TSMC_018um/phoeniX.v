`define OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11

`define INSTRUCTION_TYPES
    `define R_TYPE 0
    `define I_TYPE 1
    `define S_TYPE 2
    `define B_TYPE 3
    `define U_TYPE 4
    `define J_TYPE 5

`define EXCEPTIONS 
    `define INSTRUCTION_ADDRESS_MISALLIGNED 4'b0000
    `define INSTRUCTION_ACCESS_FAULT        4'b0001
    `define ILLEGAL_INSTRUCTION             4'b0010
    `define BREAKPOINT                      4'b0011
    `define LOAD_ADDRESS_MISALLIGNED        4'b0100
    `define LOAD_ACCESS_FAULT               4'b0101
    `define STORE_AMO_ADDRESS_MISALLIGNED   4'b0110
    `define STORE_AMO_ACCESS_FAULT          4'b0111
    `define ECALL_FROM_U_MODE               4'b1000
    `define ECALL_FROM_M_MODE               4'b1001
    `define INSTRUCTION_PAGE_FAULT          4'b1010
    `define LOAD_PAGE_FAULT                 4'b1011
    `define STORE_AMO_PAGE_FAULT            4'b1100

`define SYSTEM_INSTRUCTIONS
    `define ECALL   12'b000000000000
    `define EBREAK  12'b000000000001

`ifndef NOP_INSTRUCTION
    `define NOP                     32'h0000_0013
    `define NOP_OPCODE              `OP_IMM
    `define NOP_funct12             12'h000
    `define NOP_funct7              7'b000_0000
    `define NOP_funct3              3'b000
    `define NOP_immediate           12'h000
    `define NOP_instruction_type   `I_TYPE
    `define NOP_write_index         5'b00000
`endif /*NOP_INSTRUCTION*/

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

    reg [ 6 : 0] opcode_execute_reg;
    reg [ 2 : 0] funct3_execute_reg;
    reg [ 6 : 0] funct7_execute_reg;
    reg [11 : 0] funct12_execute_reg;

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
            funct12_execute_reg <= `NOP_funct12;

            immediate_execute_reg <= `NOP_immediate;
            instruction_type_execute_reg <= `NOP_instruction_type;
            write_index_execute_reg <= `NOP_write_index;
        end
        else
        begin
            instruction_execute_reg <= instruction_decode_reg;
            write_enable_execute_reg <= write_enable_decode_wire;
            
            opcode_execute_reg <= opcode_decode_wire;
            funct3_execute_reg <= funct3_decode_wire;
            funct7_execute_reg <= funct7_decode_wire;
            funct12_execute_reg <= funct12_decode_wire;

            immediate_execute_reg <= immediate_decode_wire; 
            instruction_type_execute_reg <= instruction_type_decode_wire;
            write_index_execute_reg <= write_index_decode_wire;
        end
        
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

    reg [ 6 : 0] opcode_memory_reg;
    reg [ 2 : 0] funct3_memory_reg;
    reg [ 6 : 0] funct7_memory_reg;
    reg [11 : 0] funct12_memory_reg;

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
        funct12_memory_reg <= funct12_execute_reg;

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

    reg [ 6 : 0] opcode_writeback_reg;
    reg [ 2 : 0] funct3_writeback_reg;
    reg [ 6 : 0] funct7_writeback_reg;
    reg [11 : 0] funct12_writeback_reg;

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
        funct12_writeback_reg <= funct12_memory_reg;

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

    reg write_enable;
    reg [ 4 : 0] write_index;
    reg [31 : 0] write_data;

    always @(*)
    begin
        case (opcode_execute_reg)
            `LUI :
            begin
                write_enable = write_enable_execute_reg;
                write_index = write_index_execute_reg;
                write_data = immediate_execute_reg;  
            end
            default : 
            begin
                write_enable = write_enable_writeback_reg;
                write_index = write_index_writeback_reg;
                write_data = write_data_writeback_reg;
            end
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
        .write_enable(write_enable),

        .read_index_1(read_index_1_decode_wire),
        .read_index_2(read_index_2_decode_wire),
        .write_index(write_index),

        .write_data(write_data),
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
        if  (opcode_execute_reg == `LOAD & write_enable_execute_reg &
            (((write_index_execute_reg == read_index_1_decode_wire) & read_enable_1_decode_wire) || 
             ((write_index_execute_reg == read_index_2_decode_wire) & read_enable_2_decode_wire)))
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

/*
    Address Generator:
    There are 3 types of addresses generated in this module:
    1. Branch Address
    2. Jump and Link Address
    3. Load/Store Address
    Immediate values are determined in Immediate_Generator module.
    So no determination (Mux) will be needed here.(I-J-B immediate)
*/

`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif 

module Address_Generator
(
    input [6 : 0] opcode, 
    input [31 : 0] rs1,            // to be connected to bus_rs1
    input [31 : 0] PC,
    input [31 : 0] immediate,

    output reg [31 : 0] address
);
    reg  [31 : 0] value;
    
    always @(*) 
    begin
        // Address Type evaluation (for Address Generator module)
        case (opcode)
            `STORE   : value = rs1;    //  Store  -> bus_rs1 + immediate
            `LOAD    : value = rs1;    //  Load   -> bus_rs1 + immediate
            `JAL     : value = PC;     //  JAL    ->    PC   + immediate
            `JALR    : value = rs1;    //  JALR   -> bus_rs1 + immediate
            `BRANCH  : value = PC;     //  Branch ->    PC   + immediate
            default  : value = 1'bz;
        endcase 
        
        address = value + immediate;
    end
endmodule

/*
    phoeniX RV32I core - Arithmetic Logic Unit
    - This unit executes R-Type, I-Type and J-Type instructions
    - Inputs bus_rs1, bus_rs2 comes from Register_File
    - Input immediate comes from Immediate_Generator
    - Input signals opcode, funct3, funct7, comes from Instruction_Decoder
    - Supported Instructions :

        I-TYPE : ADDI - SLTI - SLTIU            R-TYPE : ADD  - SUB  - SLL           
                 XORI - ORI  - ANDI                      SLT  - SLTU - XOR                         
                 SLLI - SRLI - SRAI                      SRL  - SRA  - OR  - AND
        
        J-TYPE : JAL  - JALR                    U-TYPE : AUIPC         
*/

`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif

module Arithmetic_Logic_Unit 
(
    input [6 : 0] opcode,               // ALU Operation
    input [2 : 0] funct3,               // ALU Operation
    input [6 : 0] funct7,               // ALU Operation

    input [31 : 0] PC,                  // Program Counter Register
    input [31 : 0] rs1,                 // Register Source 1
    input [31 : 0] rs2,                 // Register Source 2
    input [31 : 0] immediate,           // Immediate Source

    output reg [31 : 0] alu_output      // ALU Result
);

    reg [31 : 0] operand_1;
    reg [31 : 0] operand_2;
    
    reg         mux1_select;
    reg [1 : 0] mux2_select;

    // ALU multiplexers signals evaluation
    always @(*) 
    begin
        case (opcode)
        `OP     : begin mux1_select = 1'b0; mux2_select = 2'b00; end // R-TYPE 
        `OP_IMM : begin mux1_select = 1'b0; mux2_select = 2'b01; end // I-TYPE 
        `JALR   : begin mux1_select = 1'b1; mux2_select = 2'b10; end // JALR   
        `JAL    : begin mux1_select = 1'b1; mux2_select = 2'b10; end // JAL    
        `AUIPC  : begin mux1_select = 1'b1; mux2_select = 2'b01; end // AUIPC
        endcase        
    end

    // ALU Multiplexer 1
    always @(*) 
    begin
        case (mux1_select)
            1'b0 : operand_1 = rs1;
            1'b1 : operand_1 = PC;
        endcase
    end

    // ALU Multiplexer 2
    always @(*) 
    begin
        case (mux2_select)
            2'b00 : operand_2 = rs2;
            2'b01 : operand_2 = immediate;
            2'b10 : operand_2 = 4;
        endcase
    end

    always @(*)
    begin
        casex ({funct7, funct3, opcode})
            // I-TYPE Intructions
            {7'bx_xxx_xxx, 3'b000, `OP_IMM} : alu_output = operand_1 + operand_2;                               // ADDI
            {7'b0_000_000, 3'b001, `OP_IMM} : alu_output = operand_1 << operand_2 [4 : 0];                      // SLLI
            {7'bx_xxx_xxx, 3'b010, `OP_IMM} : alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;     // SLTI
            {7'bx_xxx_xxx, 3'b011, `OP_IMM} : alu_output = operand_1 < operand_2 ? 1 : 0;                       // SLTIU
            {7'bx_xxx_xxx, 3'b100, `OP_IMM} : alu_output = operand_1 ^ operand_2;                               // XORI
            {7'b0_000_000, 3'b101, `OP_IMM} : alu_output = operand_1 >> operand_2 [4 : 0];                      // SRLI
            {7'b0_100_000, 3'b101, `OP_IMM} : alu_output = operand_1 >> $signed(operand_2 [4 : 0]);             // SRAI
            {7'bx_xxx_xxx, 3'b110, `OP_IMM} : alu_output = operand_1 | operand_2;                               // ORI
            {7'bx_xxx_xxx, 3'b111, `OP_IMM} : alu_output = operand_1 & operand_2;                               // ANDI
            
            // R-TYPE Instructions
            {7'b0_000_000, 3'b000, `OP}     : alu_output = operand_1 + operand_2;                               // ADD
            {7'b0_100_000, 3'b000, `OP}     : alu_output = operand_1 - operand_2;                               // SUB
            {7'b0_000_000, 3'b001, `OP}     : alu_output = operand_1 << operand_2;                              // SLL
            {7'b0_000_000, 3'b010, `OP}     : alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;     // SLT
            {7'b0_000_000, 3'b011, `OP}     : alu_output = operand_1 < operand_2 ? 1 : 0;                       // SLTU
            {7'b0_000_000, 3'b100, `OP}     : alu_output = operand_1 ^ operand_2;                               // XOR
            {7'b0_000_000, 3'b101, `OP}     : alu_output = operand_1 >> operand_2;                              // SRL
            {7'b0_100_000, 3'b101, `OP}     : alu_output = operand_1 >> $signed(operand_2);                     // SRA
            {7'b0_000_000, 3'b110, `OP}     : alu_output = operand_1 | operand_2;                               // OR
            {7'b0_000_000, 3'b111, `OP}     : alu_output = operand_1 & operand_2;                               // AND

            // JAL and JALR Instructions
            {7'bx_xxx_xxx, 3'bxxx, `JAL}    : alu_output = operand_1 + operand_2;                               // JAL
            {7'bx_xxx_xxx, 3'b000, `JALR}   : alu_output = operand_1 + operand_2;                               // JALR
            
            // AUIPC Instruction
            {7'bx_xxx_xxx, 3'bxxx, `AUIPC}  : alu_output = operand_1 + operand_2;                               // AUIPC

            default: alu_output = 32'bz; 
        endcase
    end
endmodule

module Fetch_Unit
(
	input enable,                    // Memory interface enable pin

    input [31 : 0] PC,

	input [31 : 0] address,         // Branch or Jump address generated in Address Generator
	input jump_branch_enable,       // Generated in Branch Unit module

    output reg [31 : 0] next_PC,    // next instruction PC output
    
    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////

    output  reg  memory_interface_enable,
    output  reg  memory_interface_state,
    output  reg  [31 : 0]   memory_interface_address,
    output  reg  [3 : 0]    memory_interface_frame_mask
);
    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;

    always @(*) 
    begin
        memory_interface_enable = enable;
        memory_interface_state = READ;
        memory_interface_frame_mask = 4'b1111;
        memory_interface_address = PC;  
    end

    always @(*)
    begin
        if (jump_branch_enable) next_PC <= address;
        else                    next_PC <= PC + 32'd4;
    end
endmodule

module Hazard_Forward_Unit 
(
    input [4 : 0] source_index,          
    
    input [4 : 0] destination_index_1,
    input [4 : 0] destination_index_2,
    input [4 : 0] destination_index_3,

    input [31 : 0] data_1,
    input [31 : 0] data_2,
    input [31 : 0] data_3,

    input enable_1,
    input enable_2,
    input enable_3,
    
    output reg forward_enable,
    output reg [31 : 0] forward_data
);

    always @(*) 
    begin
        if (source_index == destination_index_1 && enable_1 == 1'b1)
        begin
            forward_data <= data_1;
            forward_enable <= 1'b1;
        end
            
        else if (source_index == destination_index_2 && enable_2 == 1'b1)
        begin
            forward_data <= data_2;
            forward_enable <= 1'b1;
        end
            
        else if (source_index == destination_index_3 && enable_3 == 1'b1)
        begin
            forward_data <= data_3;
            forward_enable <= 1'b1;
        end
        else
        begin
            forward_data <= 32'bz;
            forward_enable <= 1'b0;
        end
    end
endmodule

`ifndef INSTRUCTION_TYPES
    `define R_TYPE 0
    `define I_TYPE 1
    `define S_TYPE 2
    `define B_TYPE 3
    `define U_TYPE 4
    `define J_TYPE 5
`endif

module Immediate_Generator 
(
	input [31 : 0] instruction,
	input [2 : 0] instruction_type,

	output reg [31 : 0] immediate
);
    always @(*) begin
        case (instruction_type)
            `I_TYPE : immediate = { {21{instruction[31]}}, instruction[30 : 20] };
            `S_TYPE : immediate = { {21{instruction[31]}}, instruction[30 : 25], instruction[11 : 7] };
            `B_TYPE : immediate = { {20{instruction[31]}}, instruction[7], instruction[30 : 25], instruction[11 : 8], 1'b0 };
            `U_TYPE : immediate = { instruction[31 : 12], {12{1'b0}} };
            `J_TYPE : immediate = { {12{instruction[31]}}, instruction[19 : 12], instruction[20], instruction[30 : 21], 1'b0 };
            default : immediate = { 32{1'bz} };
        endcase
    end
endmodule

`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif

`ifndef INSTRUCTION_TYPES
    `define R_TYPE 0
    `define I_TYPE 1
    `define S_TYPE 2
    `define B_TYPE 3
    `define U_TYPE 4
    `define J_TYPE 5
`endif

module Instruction_Decoder 
(
    input [31 : 0] instruction,

    output [2 : 0] instruction_type,

    output [6 : 0] opcode,
    output [2 : 0] funct3,
    output [6 : 0] funct7,
    output [11 : 0] funct12,

    output [4 : 0] read_index_1,
    output [4 : 0] read_index_2,
    output [4 : 0] write_index,

    output reg read_enable_1,
    output reg read_enable_2,
    output reg write_enable
);

    assign opcode = instruction [6 : 0];

    assign instruction_type_i = opcode == `LOAD         ||
                                opcode == `LOAD_FP      ||
                                opcode == `OP_IMM       ||
                                opcode == `OP_IMM_32    ||
                                opcode == `JALR;
        
    assign instruction_type_b = opcode == `BRANCH;

    assign instruction_type_r = opcode == `OP ||
                                opcode == `OP_FP;

    assign instruction_type_s = opcode == `STORE ||
                                opcode == `STORE_FP;

    assign instruction_type_u = opcode == `AUIPC ||
                                opcode == `LUI;

    assign instruction_type_j = opcode == `JAL;

    assign instruction_type =   (instruction_type_r) ? `R_TYPE :
                                (instruction_type_i) ? `I_TYPE : 
                                (instruction_type_s) ? `S_TYPE :
                                (instruction_type_b) ? `B_TYPE :
                                (instruction_type_u) ? `U_TYPE : 
                                (instruction_type_j) ? `J_TYPE :
                                1'bz; // Default value

    assign funct7 = instruction[31 : 25];
    assign funct3 = instruction[14 : 12];
    assign funct12 = instruction[31 : 20];
    
    assign read_index_1 = instruction[19 : 15];
    assign read_index_2 = instruction[24 : 20];
    assign write_index  = instruction[11 :  7];

    always @(*) 
    begin
        // Register File read/write enable signals evaluation
        case (instruction_type)
            `I_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b0; write_enable = 1'b1; end
            `B_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b0; end
            `S_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b0; end
            `U_TYPE : begin read_enable_1 = 1'b0; read_enable_2 = 1'b0; write_enable = 1'b1; end
            `J_TYPE : begin read_enable_1 = 1'b0; read_enable_2 = 1'b0; write_enable = 1'b1; end 
            `R_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b1; end
            default : begin end // Raise Exception
        endcase    

        // Disable Write Signal when destination is x0
        if (write_index == 5'b00000)
            write_enable <= 1'b0;
    end
endmodule

`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif

`ifndef INSTRUCTION_TYPES
    `define R_TYPE 0
    `define I_TYPE 1
    `define S_TYPE 2
    `define B_TYPE 3
    `define U_TYPE 4
    `define J_TYPE 5
`endif

`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BGE  3'b101
`define BLTU 3'b110
`define BGEU 3'b111

module Jump_Branch_Unit 
(
    input [6 : 0] opcode,
    input [2 : 0] funct3,
    input [2 : 0] instruction_type,

    input [31 : 0] rs1,
    input [31 : 0] rs2,
      
    output jump_branch_enable     // Goes to Fetch_Unit
);

    reg branch_enable;
    reg jump_enable;

    always @(*) 
    begin
            if (instruction_type == `B_TYPE)  // B-TYPE Instructions
                casex ({funct3})
                {`BEQ} :    if ($signed(rs1) == $signed(rs2))   branch_enable = 1'b1; 

                {`BNE} :    if ($signed(rs1) != $signed(rs2))   branch_enable = 1'b1;
                
                {`BLT} :    if ($signed(rs1) < $signed(rs2))    branch_enable = 1'b1;
                
                {`BGE} :    if ($signed(rs1) >= $signed(rs2))   branch_enable = 1'b1;
                
                {`BLTU} :   if (rs1 < rs2)                      branch_enable = 1'b1;
                
                {`BGEU} :   if (rs1 >= rs2)                     branch_enable = 1'b1;
                
                default:    branch_enable = 1'b0;
                endcase
            else
                branch_enable = 1'b0;

            if (opcode == `JAL || opcode == `JALR)
                jump_enable = 1'b1;
            else
                jump_enable = 1'b0;
      end  

      assign jump_branch_enable = jump_enable || branch_enable;
endmodule

`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif 

`define BYTE                3'b000
`define HALFWORD            3'b001
`define WORD                3'b010
`define BYTE_UNSIGNED       3'b100
`define HALFWORD_UNSIGNED   3'b101

module Load_Store_Unit
(
    input  [6 : 0] opcode,                  // Load/Store function
    input  [2 : 0] funct3,                  // Load/Store function

    input       [31 : 0] address,           // Generated in Address Generator module
    input       [31 : 0] store_data,        // Connected to Register Source 2
    output reg  [31 : 0] load_data,         // Data returned from memory

    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////

    output  reg  memory_interface_enable,
    output  reg  memory_interface_state,
    output  reg  [31 : 0]   memory_interface_address,
    output  reg  [3 : 0]    memory_interface_frame_mask,

    inout   [31 : 0] memory_interface_data
);
    localparam  READ    = 1'b0;
    localparam  WRITE   = 1'b1;
    
    // Memory Interface Enable Signal Generation
    always @(*)
    begin
        case (opcode)
            `LOAD   : begin memory_interface_enable = 1'b1; memory_interface_address = {address[31 : 2], 2'b00}; end
            `STORE  : begin memory_interface_enable = 1'b1; memory_interface_address = {address[31 : 2], 2'b00}; end 
            default : begin memory_interface_enable = 1'b0; memory_interface_address = 32'bz; end
        endcase
    end

    // Memory State and Frame Mask Generation
    always @(*) 
    begin
        {memory_interface_state, memory_interface_frame_mask} = {1'bx, 4'bx};

        case ({opcode, funct3})
            // Load Instructions
            
            // LB and LBU
            {`LOAD, `BYTE}, {`LOAD, `BYTE_UNSIGNED}: {memory_interface_state, memory_interface_frame_mask} = 
            {   READ, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            };

            // LH and LHU
            {`LOAD, `HALFWORD}, {`LOAD, `HALFWORD_UNSIGNED} : {memory_interface_state, memory_interface_frame_mask} = 
            {   READ,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            };

            // LW
            {`LOAD, `WORD} : {memory_interface_state, memory_interface_frame_mask} = {READ, 4'b1111}; 
            
            // Store Instructions

            // SB
            {`STORE, `BYTE} : {memory_interface_state, memory_interface_frame_mask} = 
            {   WRITE, 
            {                   
                ~address[1] & ~address[0], 
                ~address[1] &  address[0], 
                 address[1] & ~address[0], 
                 address[1] &  address[0]
            }
            }; 

            // SH
            {`STORE, `HALFWORD} : {memory_interface_state, memory_interface_frame_mask} = 
            {   WRITE,
            {                   
                {2{~address[1]}}, {2{address[1]}}
            }
            }; 

            // SW
            {`STORE, `WORD} : {memory_interface_state, memory_interface_frame_mask} = {WRITE, 4'b1111};

            default : {memory_interface_state, memory_interface_frame_mask} = {1'b0, 4'b0};
        endcase    
    end

    // Data Management in case of Store Instruction
    reg [31 : 0] store_data_reg = 32'bz;
    assign memory_interface_data = opcode == `STORE ? store_data_reg : 32'bz;

    // Latch condition when Loading
    always @(*)
    begin
        if (opcode == `LOAD)
        casex ({funct3})
            `BYTE : 
            begin
                if (memory_interface_frame_mask == 4'b0001) load_data <= { {24{memory_interface_data[31]}}, memory_interface_data[31 : 24]}; 
                if (memory_interface_frame_mask == 4'b0010) load_data <= { {24{memory_interface_data[23]}}, memory_interface_data[23 : 16]}; 
                if (memory_interface_frame_mask == 4'b0100) load_data <= { {24{memory_interface_data[15]}}, memory_interface_data[15 :  7]}; 
                if (memory_interface_frame_mask == 4'b1000) load_data <= { {24{memory_interface_data[ 7]}}, memory_interface_data[ 7 :  0]}; 
            end    
              
            `BYTE_UNSIGNED : 
            begin
                if (memory_interface_frame_mask == 4'b0001) load_data <= { 24'b0, memory_interface_data[31 : 24]};
                if (memory_interface_frame_mask == 4'b0010) load_data <= { 24'b0, memory_interface_data[23 : 16]};
                if (memory_interface_frame_mask == 4'b0100) load_data <= { 24'b0, memory_interface_data[15 :  7]};
                if (memory_interface_frame_mask == 4'b1000) load_data <= { 24'b0, memory_interface_data[ 7 :  0]}; 
            end

            `HALFWORD : 
            begin
                if (memory_interface_frame_mask == 4'b0011) load_data <= { {16{memory_interface_data[31]}}, memory_interface_data[31 : 16]};
                if (memory_interface_frame_mask == 4'b1100) load_data <= { {16{memory_interface_data[15]}}, memory_interface_data[15 :  0]};
            end
            `HALFWORD_UNSIGNED :
            begin
                if (memory_interface_frame_mask == 4'b0011) load_data <= { 16'b0, memory_interface_data[31 : 16]};
                if (memory_interface_frame_mask == 4'b1100) load_data <= { 16'b0, memory_interface_data[15 :  0]};
            end 
            `WORD : load_data <= memory_interface_data;                                               
        endcase    
        else load_data <= 32'bz;

        if (opcode == `STORE)
        casex ({funct3})
            `BYTE : 
            begin
                if (memory_interface_frame_mask == 4'b0001) store_data_reg[31 : 24] <= store_data[ 7 : 0];
                if (memory_interface_frame_mask == 4'b0010) store_data_reg[23 : 16] <= store_data[ 7 : 0];
                if (memory_interface_frame_mask == 4'b0100) store_data_reg[15 :  7] <= store_data[ 7 : 0];
                if (memory_interface_frame_mask == 4'b1000) store_data_reg[ 7 :  0] <= store_data[ 7 : 0];
            end 
            `HALFWORD : 
            begin
                if (memory_interface_frame_mask == 4'b0011) store_data_reg[31 : 16] <= store_data[15 : 0];
                if (memory_interface_frame_mask == 4'b1100) store_data_reg[15 :  0] <= store_data[15 : 0];
            end
            `WORD : 
            begin
                if (memory_interface_frame_mask == 4'b1111) store_data_reg[31 : 0] = store_data[31 : 0];
            end 
        endcase
        else store_data_reg <= 32'bz;
    end
endmodule

module Register_File
#(
    parameter WIDTH = 32,
    parameter DEPTH = 5
)
(
    input CLK,
    input reset,
    
    input wire read_enable_1,
    input wire read_enable_2,
    input wire write_enable,
    
    input wire [DEPTH - 1 : 0] read_index_1,
    input wire [DEPTH - 1 : 0] read_index_2,
    input wire [DEPTH - 1 : 0] write_index,

    input wire [WIDTH - 1 : 0] write_data,

    output reg [WIDTH - 1 : 0] read_data_1,
    output reg [WIDTH - 1 : 0] read_data_2
);
	reg [WIDTH - 1 : 0] Registers [0 : 31];      

    integer i;    	
    always @(posedge reset)
    begin
        for (i = 0; i < 32; i = i + 1)
            Registers[i] = {WIDTH{1'b0}};
    end
	
    always @(negedge CLK)
    begin
        if (write_enable == 1'b1 && write_index != 0)
        begin
            Registers[write_index] <= write_data;
        end
    end

    always @(*) 
    begin
        if (read_enable_1 == 1'b1)
            read_data_1 <= Registers[read_index_1];
        else
            read_data_1 <= {WIDTH{1'bz}};

        if (read_enable_2 == 1'b1)
            read_data_2 <= Registers[read_index_2];
        else
            read_data_2 <= {WIDTH{1'bz}};
    end
endmodule