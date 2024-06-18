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
`endif /*OPCODES*/

`ifndef INSTRUCTION_TYPES
    `define R_TYPE 3'b000
    `define I_TYPE 3'b001
    `define S_TYPE 3'b010
    `define B_TYPE 3'b011
    `define U_TYPE 3'b100
    `define J_TYPE 3'b101
`endif /*INSTRUCTION_TYPES*/

`ifndef EXCEPTIONS
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
`endif /*EXCEPTIONS*/

`ifndef SYSTEM_INSTRUCTIONS
    `define ECALL   12'b000000000000
    `define EBREAK  12'b000000000001
`endif /*SYSTEM_INSTRUCTIONS*/

`ifndef CSR_INSTRUCTIONS
    `define CSRRW  3'b001
    `define CSRRS  3'b010
    `define CSRRC  3'b011
    `define CSRRWI 3'b101
    `define CSRRSI 3'b110
    `define CSRRCI 3'b111
`endif /*CSR_INSTRUCTIONS*/

`ifndef EXECUTION_UNITS_CSR
    `define alucsr      12'h800
    `define mulcsr      12'h801
    `define divcsr      12'h802
    `define mcycle      12'hC00
    `define mcycleh     12'hC80 
    `define minstret    12'hC02
    `define minstreth   12'hC82               
`endif /*EXECUTION_UNITS_CSR*/

`ifndef MUL_DIV_INSTRCUTIONS
    `define MUL     3'b000
    `define MULH    3'b001
    `define MULHSU  3'b010
    `define MULHU   3'b011 

    `define DIV     3'b100
    `define DIVU    3'b101
    `define REM     3'b110
    `define REMU    3'b111

    `define MULDIV  7'b0000001
`endif /*MUL_DIV_INSTRCUTIONS*/

`ifndef I_INSTRUCTIONS
    `define ADDI    3'b000
    `define SLTI    3'b010
    `define SLTIU   3'b011
    `define XORI    3'b100
    `define ORI     3'b110
    `define ANDI    3'b111
    `define SLLI    3'b001      // Shift Left Immediate -> Logical
    `define SRI     3'b101      // Shift Right Immediate -> Logical & Arithmetic
`endif /*I_INSTRUCTIONS*/

`ifndef R_INSTRUCTIONS
    `define ADDSUB  3'b000
    `define SLL     3'b001      // Shift Left -> Logical   
    `define SLT     3'b010
    `define SLTU    3'b011    
    `define XOR     3'b100    
    `define SR      3'b101      // Shift Right -> Logical & Arithmetic   
    `define OR      3'b110    
    `define AND     3'b111
`endif /*R_INSTRUCTIONS*/

`ifndef ALU_AUXILIARY_DEFINES
    `define LOGICAL     7'b000_0000
    `define ARITHMETIC  7'b010_0000
    `define ADD         7'b000_0000     
    `define SUB         7'b010_0000

    `define RIGHT 1'b1
    `define LEFT  1'b0
`endif /*ALU_AUXILIARY_DEFINES*/

`ifndef BRANCH_INSTRUCTIONS
    `define BEQ  3'b000
    `define BNE  3'b001
    `define BLT  3'b100
    `define BGE  3'b101
    `define BLTU 3'b110
    `define BGEU 3'b111
`endif /*BRANCH_INSTRUCTIONS*/

`ifndef MEMORY_ACCESS_SIZE
    `define BYTE                3'b000
    `define HALFWORD            3'b001
    `define WORD                3'b010
    `define BYTE_UNSIGNED       3'b100
    `define HALFWORD_UNSIGNED   3'b101
`endif /*MEMORY_ACCESS_SIZE*/

`ifndef NOP_INSTRUCTION
    `define NOP                     32'h0000_0013
    `define NOP_opcode              `OP_IMM
    `define NOP_funct12             12'h000
    `define NOP_funct7              7'b000_0000
    `define NOP_funct3              3'b000
    `define NOP_immediate           12'h000
    `define NOP_instruction_type   `I_TYPE
    `define NOP_write_index         5'b00000
`endif /*NOP_INSTRUCTION*/

`ifndef CONTROL_SIGNALS
    `define DISABLE     1'b0
    `define ENABLE      1'b1
    
    `define READ        1'b0
    `define WRITE       1'b1
`endif /*CONTROL_SIGNALS*/

module phoeniX
#(
    parameter RESET_ADDRESS = 32'h0000_0000,
    parameter M_EXTENSION   = 1'b1,
    parameter E_EXTENSION   = 1'b0
) 
(
    input           clk,
    input           reset,

    //////////////////////////////////////////
    // Instruction Memory Interface Signals //
    //////////////////////////////////////////
    output          instruction_memory_interface_enable,
    output          instruction_memory_interface_state,
    output [31 : 0] instruction_memory_interface_address,
    output [ 3 : 0] instruction_memory_interface_frame_mask,
    input  [31 : 0] instruction_memory_interface_data, 

    ///////////////////////////////////
    // Data Memory Interface Signals //
    ///////////////////////////////////
    output          data_memory_interface_enable,
    output          data_memory_interface_state,
    output [31 : 0] data_memory_interface_address,
    output [ 3 : 0] data_memory_interface_frame_mask,
    inout  [31 : 0] data_memory_interface_data
);
    // ---------------------------------------------
    // Wire Declarations for Fetch/Decode Stage (FD)
    // ---------------------------------------------
    wire [31 : 0] next_pc_FD_wire;
    
    // --------------------------------------------
    // Reg Declarations for Fetch/Decode Stage (FD)
    // --------------------------------------------
    reg [31 : 0] pc_FD_reg;

    reg [1 : 2] stall_condition;
    /*
        1 -> Stall Condition 1 corresponds to instructions with multi-cycle execution
        2 -> Stall Condition 2 corresponds to instructions with dependencies on previous instructions whose values are not available in the pipeline
    */

    wire [31 : 0] alucsr_wire;
    wire [31 : 0] mulcsr_wire;
    wire [31 : 0] divcsr_wire;
    // ------------------------
    // Fetch Unit Instantiation
    // ------------------------
    Fetch_Unit fetch_unit
    (
        .enable(!reset && !(|stall_condition[1 : 2])),              
        
        .pc(pc_FD_reg),
        .next_pc(next_pc_FD_wire),

        .memory_interface_enable(instruction_memory_interface_enable),
        .memory_interface_state(instruction_memory_interface_state),
        .memory_interface_address(instruction_memory_interface_address),
        .memory_interface_frame_mask(instruction_memory_interface_frame_mask)    
    );

    wire [31 : 0] address_EX_wire;
    wire jump_branch_enable_EX_wire;

    // ------------------------
    // Program Counter Register 
    // ------------------------
    always @(posedge clk)
    begin
        if (reset)
            pc_FD_reg <= RESET_ADDRESS;
        else if (jump_branch_enable_EX_wire)
            pc_FD_reg <= address_EX_wire;
        else if (!(|stall_condition[1 : 2]))
            pc_FD_reg <= next_pc_FD_wire; 
    end
    
    // ------------------------------------------
    // Register Declarations for Decode Procedure
    // ------------------------------------------
    reg [31 : 0] instruction_FD_reg;

    // --------------------
    // Instruction Register 
    // --------------------
    always @(*) 
    begin
        if (reset)
            instruction_FD_reg <= 32'bz;
        else if (!(|stall_condition[1 : 2]))
            instruction_FD_reg <= instruction_memory_interface_data;
    end

    // --------------------------------------
    // Wire Declarations for Decode Procedure
    // --------------------------------------
    wire [ 2 : 0] instruction_type_FD_wire;
    wire [ 6 : 0] opcode_FD_wire;
    wire [ 2 : 0] funct3_FD_wire;
    wire [ 6 : 0] funct7_FD_wire;
    wire [11 : 0] funct12_FD_wire;

    wire [ 4 : 0] read_index_1_FD_wire;
    wire [ 4 : 0] read_index_2_FD_wire;
    wire [ 4 : 0] write_index_FD_wire;
    wire [11 : 0] csr_index_FD_wire;

    wire read_enable_1_FD_wire;
    wire read_enable_2_FD_wire;
    wire write_enable_FD_wire;

    wire read_enable_csr_FD_wire;
    wire write_enable_csr_FD_wire;

    wire [31 : 0] immediate_FD_wire;

    // ---------------------------------
    // Instruction Decoder Instantiation
    // ---------------------------------
    Instruction_Decoder instruction_decoder
    (
        .instruction(instruction_FD_reg),

        .instruction_type(instruction_type_FD_wire),
        .opcode(opcode_FD_wire),
        .funct3(funct3_FD_wire),
        .funct7(funct7_FD_wire),
        .funct12(funct12_FD_wire),

        .read_index_1(read_index_1_FD_wire),
        .read_index_2(read_index_2_FD_wire),
        .write_index(write_index_FD_wire),
        .csr_index(csr_index_FD_wire),

        .read_enable_1(read_enable_1_FD_wire),
        .read_enable_2(read_enable_2_FD_wire),
        .write_enable(write_enable_FD_wire),

        .read_enable_csr(read_enable_csr_FD_wire),
        .write_enable_csr(write_enable_csr_FD_wire)
    );

    // ---------------------------------
    // Immediate Generator Instantiation
    // --------------------------------- 
    Immediate_Generator immediate_generator
    (
        .instruction(instruction_FD_reg[31 : 7]),
        .instruction_type(instruction_type_FD_wire),
        .immediate(immediate_FD_wire)
    );

    // ----------------------------------------------------------------------
    // Wire Declaration for Reading From Register File and Forwarding Sources
    // ---------------------------------------------------------------------- 
    wire [31 : 0] RF_source_1;
    wire [31 : 0] RF_source_2;

    wire [31 : 0] FW_source_1;
    wire [31 : 0] FW_source_2;
    
    wire FW_enable_1;
    wire FW_enable_2;

    // ---------------------------------------------------
    // Wire Declaration for Reading From CSR Register File
    // ---------------------------------------------------
    wire [31 : 0] csr_data_FD_wire;

    // -----------------------------------------------
    // Wire Declaration for inputs to source bus 1 & 2
    // ----------------------------------------------- 
    wire [31 : 0] rs1_FD_wire;
    wire [31 : 0] rs2_FD_wire;

    // -----------------------------------------------------------------------------------
    // assign inputs to source bus 1 & 2  --> to be selected between RF source and FW data
    // -----------------------------------------------------------------------------------
    assign rs1_FD_wire = FW_enable_1 ? FW_source_1 : RF_source_1;
    assign rs2_FD_wire = FW_enable_2 ? FW_source_2 : RF_source_2;
    
    // ---------------------------------------
    // Reg Declarations for Execute Stage (EX)
    // ---------------------------------------
    reg [31 : 0] pc_EX_reg;
    reg [31 : 0] next_pc_EX_reg;

    reg [ 2 : 0] instruction_type_EX_reg;
    reg [ 6 : 0] opcode_EX_reg;
    reg [ 2 : 0] funct3_EX_reg;
    reg [ 6 : 0] funct7_EX_reg;
    reg [11 : 0] funct12_EX_reg;

    reg [ 4 : 0] write_index_EX_reg;
    reg [ 4 : 0] read_index_1_EX_reg;
    reg [11 : 0] csr_index_EX_reg;

    reg write_enable_EX_reg;
    reg write_enable_csr_EX_reg;
    
    reg [31 : 0] immediate_EX_reg;

    reg [31 : 0] rs1_EX_reg;
    reg [31 : 0] rs2_EX_reg;
    reg [31 : 0] csr_data_EX_reg;

    //////////////////////////////////////////////
    //    FETCH/DECODE TO EXECUTE TRANSITION    //
    //////////////////////////////////////////////
    always @(posedge clk) 
    begin
        if (jump_branch_enable_EX_wire || (!(stall_condition[1]) & stall_condition[2]))
        begin
            write_enable_EX_reg <= `DISABLE;  
            rs1_EX_reg <= 32'bz;
            rs2_EX_reg <= 32'bz;

            opcode_EX_reg <= `NOP_opcode;
            funct3_EX_reg <= `NOP_funct3;
            funct7_EX_reg <= `NOP_funct7;
            funct12_EX_reg <= `NOP_funct12;

            immediate_EX_reg <= `NOP_immediate;
            instruction_type_EX_reg <= `NOP_instruction_type;
            write_index_EX_reg <= `NOP_write_index;
        end

        else if (!(|stall_condition[1 : 2]))
        begin
            pc_EX_reg <= pc_FD_reg;
            next_pc_EX_reg <= next_pc_FD_wire;
            
            
            instruction_type_EX_reg <= instruction_type_FD_wire;
            opcode_EX_reg <= opcode_FD_wire;
            funct3_EX_reg <= funct3_FD_wire;
            funct7_EX_reg <= funct7_FD_wire;
            funct12_EX_reg <= funct12_FD_wire;

            immediate_EX_reg <= immediate_FD_wire; 
            
            rs1_EX_reg <= rs1_FD_wire;
            rs2_EX_reg <= rs2_FD_wire;

            write_index_EX_reg <= write_index_FD_wire;
            write_enable_EX_reg <= write_enable_FD_wire;

            write_enable_csr_EX_reg <= write_enable_csr_FD_wire;
            csr_index_EX_reg <= csr_index_FD_wire;
            csr_data_EX_reg <= csr_data_FD_wire;
            read_index_1_EX_reg <= read_index_1_FD_wire;
        end
    end

    // ------------------------------------
    // Wire Declaration for Execution Units
    // ------------------------------------
    wire [31 : 0] alu_output_EX_wire;
    wire [31 : 0] mul_output_EX_wire;
    wire [31 : 0] div_output_EX_wire;

    wire mul_busy_EX_wire;
    wire div_busy_EX_wire;

    wire [31 : 0] csr_rd_EX_wire;
    wire [31 : 0] csr_data_out_EX_wire;

    // -----------------------------------
    // Arithmetic Logic Unit Instantiation
    // -----------------------------------
    Arithmetic_Logic_Unit
    #(
        .GENERATE_CIRCUIT_1(1),
        .GENERATE_CIRCUIT_2(0),
        .GENERATE_CIRCUIT_3(0),
        .GENERATE_CIRCUIT_4(0)
    )  
    arithmetic_logic_unit
    (
        .opcode(opcode_EX_reg),
        .funct3(funct3_EX_reg),
        .funct7(funct7_EX_reg),
        .control_status_register(alucsr_wire),    
        .rs1(rs1_EX_reg),
        .rs2(rs2_EX_reg),
        .immediate(immediate_EX_reg),
        .alu_output(alu_output_EX_wire)
    );

    // -------------------------------------
    // Multiplier/Divider Unit Instantiation
    // -------------------------------------
    generate if (M_EXTENSION)
    begin : M_EXTENSION_Generate_Block
        Multiplier_Unit
        #(
            .GENERATE_CIRCUIT_1(1),
            .GENERATE_CIRCUIT_2(0),
            .GENERATE_CIRCUIT_3(0),
            .GENERATE_CIRCUIT_4(0)
        ) 
        multiplier_unit
        (
            .clk(clk),
            .opcode(opcode_EX_reg),
            .funct3(funct3_EX_reg),
            .funct7(funct7_EX_reg),
            .control_status_register(mulcsr_wire),    
            .rs1(rs1_EX_reg),
            .rs2(rs2_EX_reg),
            .multiplier_unit_busy(mul_busy_EX_wire),
            .multiplier_unit_output(mul_output_EX_wire)
        );

        Divider_Unit
        #(
            .GENERATE_CIRCUIT_1(1),
            .GENERATE_CIRCUIT_2(0),
            .GENERATE_CIRCUIT_3(0),
            .GENERATE_CIRCUIT_4(0)
        ) 
        divider_unit
        (
            .clk(clk),
            .opcode(opcode_EX_reg),
            .funct3(funct3_EX_reg),
            .funct7(funct7_EX_reg),
            .control_status_register(divcsr_wire),    
            .rs1(rs1_EX_reg),
            .rs2(rs2_EX_reg),
            .divider_unit_busy(div_busy_EX_wire),
            .divider_unit_output(div_output_EX_wire)
        );
    end
    endgenerate

    // ------------------------------------
    // Address Generator Unit Instantiation
    // ------------------------------------
    Address_Generator address_generator
    (
        .opcode(opcode_EX_reg),
        .rs1(rs1_EX_reg),
        .pc(pc_EX_reg),
        .immediate(immediate_EX_reg),
        .address(address_EX_wire)
    );

    // ------------------------------
    // Jump Branch Unit Instantiation
    // ------------------------------
    Jump_Branch_Unit jump_branch_unit
    (
        .opcode(opcode_EX_reg),
        .funct3(funct3_EX_reg),
        .instruction_type(instruction_type_EX_reg),
        .rs1(rs1_EX_reg),
        .rs2(rs2_EX_reg),
        .jump_branch_enable(jump_branch_enable_EX_wire)
    );

    // ---------------------------------
    // Control Status Unit Instantiation
    // ---------------------------------
    Control_Status_Unit control_status_unit
    (
        .opcode(opcode_EX_reg),
        .funct3(funct3_EX_reg),

        .CSR_in(csr_data_EX_reg),
        .rs1(rs1_EX_reg),
        .unsigned_immediate(read_index_1_EX_reg),

        .rd(csr_rd_EX_wire),
        .CSR_out(csr_data_out_EX_wire)
    );

    // ----------------------------------------
    // Reg Declaration for result of execution
    // ----------------------------------------
    reg [31 : 0] execution_result_EX_reg;

    // ----------------------------------------------------------
    //  Assigning result to alu output / mul output / div output
    // ----------------------------------------------------------
    always @(*) 
    begin
        case ({funct7_EX_reg, funct3_EX_reg, opcode_EX_reg})
            {`MULDIV, `MUL,    `OP} : execution_result_EX_reg = mul_output_EX_wire;
            {`MULDIV, `MULH,   `OP} : execution_result_EX_reg = mul_output_EX_wire;
            {`MULDIV, `MULHSU, `OP} : execution_result_EX_reg = mul_output_EX_wire;
            {`MULDIV, `MULHU,  `OP} : execution_result_EX_reg = mul_output_EX_wire;

            {`MULDIV, `DIV,    `OP} : execution_result_EX_reg = div_output_EX_wire;
            {`MULDIV, `DIVU,   `OP} : execution_result_EX_reg = div_output_EX_wire;
            {`MULDIV, `REM,    `OP} : execution_result_EX_reg = div_output_EX_wire;
            {`MULDIV, `REMU,   `OP} : execution_result_EX_reg = div_output_EX_wire;

            default: execution_result_EX_reg = alu_output_EX_wire;    
        endcase 
    end

    // ------------------------------------------------
    // Reg Declarations for Memory/Writeback Stage (MW)
    // ------------------------------------------------
    reg [31 : 0] pc_MW_reg;
    reg [31 : 0] next_pc_MW_reg;

    reg [ 2 : 0] instruction_type_MW_reg;
    reg [ 6 : 0] opcode_MW_reg;
    reg [ 2 : 0] funct3_MW_reg;
    reg [ 6 : 0] funct7_MW_reg;
    reg [11 : 0] funct12_MW_reg;

    reg [31 : 0] immediate_MW_reg;
    
    reg [ 4 : 0] write_index_MW_reg;
    reg write_enable_MW_reg;

    reg [31 : 0] address_MW_reg;
    reg [31 : 0] rs2_MW_reg;
    reg [31 : 0] execution_result_MW_reg;
    reg [31 : 0] csr_rd_MW_reg;

    //////////////////////////////////////////////////
    //    EXECUTE TO MEMORY/WRITEBACK TRANSITION    //
    //////////////////////////////////////////////////
    always @(posedge clk) 
    begin
        if (stall_condition[1])
        begin
            write_enable_MW_reg <= `DISABLE;  

            opcode_MW_reg <= `NOP_opcode;
            funct3_MW_reg <= `NOP_funct3;
            funct7_MW_reg <= `NOP_funct7;
            funct12_MW_reg <= `NOP_funct12;

            immediate_MW_reg <= `NOP_immediate;
            instruction_type_MW_reg <= `NOP_instruction_type;
            write_index_MW_reg <= `NOP_write_index;            
        end

        else if (!(stall_condition[1]))
        begin
            pc_MW_reg <= pc_EX_reg;
            next_pc_MW_reg <= next_pc_EX_reg;

            instruction_type_MW_reg <= instruction_type_EX_reg;
            opcode_MW_reg <= opcode_EX_reg;
            funct3_MW_reg <= funct3_EX_reg;
            funct7_MW_reg <= funct7_EX_reg;
            funct12_MW_reg <= funct12_EX_reg;

            immediate_MW_reg <= immediate_EX_reg;
            
            write_index_MW_reg <= write_index_EX_reg;
            write_enable_MW_reg <= write_enable_EX_reg;    

            address_MW_reg <= address_EX_wire;
            rs2_MW_reg <= rs2_EX_reg;
            execution_result_MW_reg <= execution_result_EX_reg;
            csr_rd_MW_reg <= csr_rd_EX_wire;
        end
    end

    // -----------------------------------
    // Wire Declarations for Memory Access
    // -----------------------------------
    wire [31 : 0] load_data_MW_wire;

    // -----------------------------
    // Load Store Unit Instantiation
    // -----------------------------
    Load_Store_Unit load_store_unit
    (
        .opcode(opcode_MW_reg),
        .funct3(funct3_MW_reg),
        .address(address_MW_reg),
        .store_data(rs2_MW_reg),
        .load_data(load_data_MW_wire),

        .memory_interface_enable(data_memory_interface_enable),
        .memory_interface_state(data_memory_interface_state),
        .memory_interface_address(data_memory_interface_address),
        .memory_interface_frame_mask(data_memory_interface_frame_mask),
        .memory_interface_data(data_memory_interface_data)
    );
    
    // ---------------------------------------------------------------
    // assigning write back data from immediate or load data or result
    // ---------------------------------------------------------------
    reg [31 : 0] write_data_MW_reg;
    always @(*) 
    begin    
        case (opcode_MW_reg)
            `OP_IMM : write_data_MW_reg = execution_result_MW_reg;
            `OP     : write_data_MW_reg = execution_result_MW_reg;
            `JAL    : write_data_MW_reg = next_pc_MW_reg;
            `JALR   : write_data_MW_reg = next_pc_MW_reg;
            `AUIPC  : write_data_MW_reg = address_MW_reg;
            `LOAD   : write_data_MW_reg = load_data_MW_wire;
            `LUI    : write_data_MW_reg = immediate_MW_reg;
            `SYSTEM : write_data_MW_reg = csr_rd_MW_reg;
            default : write_data_MW_reg = 32'bz;
        endcase
    end
    
    //////////////////////////////////////
    //     Hazard Detection Units       //
    //////////////////////////////////////
    Hazard_Forward_Unit hazard_forward_unit_source_1
    (
        .source_index(read_index_1_FD_wire),
        
        .destination_index_1(write_index_EX_reg),
        .destination_index_2(write_index_MW_reg),

        .data_1(    opcode_EX_reg == `LUI      ? immediate_EX_reg : 
                    opcode_EX_reg == `AUIPC    ? address_EX_wire  : 
                    opcode_EX_reg == `SYSTEM   ? csr_rd_EX_wire   : 
                    execution_result_EX_reg
                ),

        .data_2(write_data_MW_reg),

        .enable_1(write_enable_EX_reg),
        .enable_2(write_enable_MW_reg),

        .forward_enable(FW_enable_1),
        .forward_data(FW_source_1)
    );

    Hazard_Forward_Unit hazard_forward_unit_source_2
    (
        .source_index(read_index_2_FD_wire),
        
        .destination_index_1(write_index_EX_reg),
        .destination_index_2(write_index_MW_reg),

        .data_1(    opcode_EX_reg == `LUI      ? immediate_EX_reg : 
                    opcode_EX_reg == `AUIPC    ? address_EX_wire  : 
                    opcode_EX_reg == `SYSTEM   ? csr_rd_EX_wire   : 
                    execution_result_EX_reg
                ),

        .data_2(write_data_MW_reg),

        .enable_1(write_enable_EX_reg),
        .enable_2(write_enable_MW_reg),

        .forward_enable(FW_enable_2),
        .forward_data(FW_source_2)
    );

    ////////////////////////////////////
    //          Bubble Unit           //
    ////////////////////////////////////    

    always @(*) 
    begin
        if (mul_busy_EX_wire || div_busy_EX_wire)
        begin
            stall_condition[1] = `ENABLE;
        end
        else stall_condition[1] = `DISABLE;
        
        if  (opcode_EX_reg == `LOAD & write_enable_EX_reg &
            (((write_index_EX_reg == read_index_1_FD_wire) & read_enable_1_FD_wire)  || 
             ((write_index_EX_reg == read_index_2_FD_wire) & read_enable_2_FD_wire))) 
        begin
            stall_condition[2] = `ENABLE;
        end   
        else stall_condition[2] = `DISABLE;
    end

    ////////////////////////////////////////
    //    Register File Instantiation     //
    ////////////////////////////////////////
    Register_File 
    #(
        .WIDTH(32),
        .DEPTH(E_EXTENSION ? 4 : 5)
    )
    register_file
    (
        .clk(clk),
        .reset(reset),

        .read_enable_1(read_enable_1_FD_wire),
        .read_enable_2(read_enable_2_FD_wire),
        .write_enable(write_enable_MW_reg),

        .read_index_1(read_index_1_FD_wire),
        .read_index_2(read_index_2_FD_wire),
        .write_index(write_index_MW_reg),

        .write_data(write_data_MW_reg),
        .read_data_1(RF_source_1),
        .read_data_2(RF_source_2)
    );

    ///////////////////////////////////////////////////////
    //    Control Status Register File Instantiation     //
    ///////////////////////////////////////////////////////
    Control_Status_Register_File control_status_register_file
    (
        .clk(clk),
        .reset(reset),

        .opcode(opcode_MW_reg),
        .funct3(funct3_MW_reg),
        .funct7(funct7_MW_reg),
        .funct12(funct12_MW_reg),
        .write_index(write_index_MW_reg),

        .read_enable_csr(read_enable_csr_FD_wire),
        .write_enable_csr(write_enable_csr_EX_reg),

        .csr_read_index(csr_index_FD_wire),
        .csr_write_index(csr_index_EX_reg),

        .csr_write_data(csr_data_out_EX_wire),
        .csr_read_data(csr_data_FD_wire),

        .alucsr_wire(alucsr_wire),
        .mulcsr_wire(mulcsr_wire),
        .divcsr_wire(divcsr_wire)
    );

endmodule

module Address_Generator
(
    input wire [ 6 : 0] opcode, 
    input wire [31 : 0] rs1,            
    input wire [31 : 0] pc,
    input wire [31 : 0] immediate,

    output reg [31 : 0] address
);
    
    reg  [31 : 0] adder_input_1;
    reg  [31 : 0] adder_input_2;
    wire [31 : 0] adder_result;

    always @(*) 
    begin
        case (opcode)
            `STORE   : begin adder_input_1 = rs1;   adder_input_2 = immediate; address = adder_result; end    //  Store  ->   rs1  + immediate
            `LOAD    : begin adder_input_1 = rs1;   adder_input_2 = immediate; address = adder_result; end    //  Load   ->   rs1  + immediate
            `JALR    : begin adder_input_1 = rs1;   adder_input_2 = immediate; address = adder_result; end    //  JALR   ->   rs1  + immediate
            `JAL     : begin adder_input_1 = pc;    adder_input_2 = immediate; address = adder_result; end    //  JAL    ->   pc   + immediate
            `AUIPC   : begin adder_input_1 = pc;    adder_input_2 = immediate; address = adder_result; end    //  AUIPC  ->   pc   + immediate
            `BRANCH  : begin adder_input_1 = pc;    adder_input_2 = immediate; address = adder_result; end    //  Branch ->   pc   + immediate
            default  : begin adder_input_1 = 32'bz; adder_input_2 = 32'bz;     address = 32'bz;        end
        endcase 
    end

    Address_Generator_CLA 
    #(
        .LEN(32)
    ) 
    address_generator
    (    
        .A(adder_input_1),
        .B(adder_input_2),
        .C_in(1'b0),
        .Sum(adder_result)
    );

endmodule

module Address_Generator_CLA #(parameter LEN = 32) 
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input C_in,
    
    output [LEN - 1 : 0] Sum,
    output C_out
);

    wire [LEN : 0] Carry;
    wire [LEN : 0] CarryX;
    wire [LEN - 1 : 0] P;
    wire [LEN - 1 : 0] G;
    assign P = A | B;   // Bitwise AND
    assign G = A & B;   // Bitwise OR

    assign Carry[0] = C_in;

    genvar i;

    generate
        for (i = 1 ; i <= LEN; i = i + 1)
        begin : Address_Generator_CLA_Generate_Block_1
            assign Carry[i] = G[i - 1] | (P[i - 1] & Carry[i - 1]);
        end
    endgenerate

    generate
        for (i = 0; i < LEN; i = i + 1)
        begin : Address_Generator_CLA_Generate_Block_2
            Full_Adder_CLA FA (.A(A[i]), .B(B[i]), .C_in(Carry[i]), .C_out(CarryX[i + 1]), .Sum(Sum[i]));
        end
    assign C_out = Carry[LEN];
    endgenerate

endmodule

module Full_Adder_CLA 
(
    input A,
    input B,
    input C_in,

    output C_out,
    output Sum
);
    assign Sum = A ^ B ^ C_in;
    assign C_out = (A && B) || (A && C_in) || (B && C_in); 
endmodule

module Arithmetic_Logic_Unit
#(
    parameter GENERATE_CIRCUIT_1 = 1,
    parameter GENERATE_CIRCUIT_2 = 0,
    parameter GENERATE_CIRCUIT_3 = 0,
    parameter GENERATE_CIRCUIT_4 = 0
)
(
    input wire [ 6 : 0] opcode,               
    input wire [ 2 : 0] funct3,               
    input wire [ 6 : 0] funct7,               

    input wire [31 : 0] control_status_register,    

    input wire [31 : 0] rs1,                 
    input wire [31 : 0] rs2,                 
    input wire [31 : 0] immediate,           

    output reg [31 : 0] alu_output      
);
    reg alu_enable;

    reg  [31 : 0] operand_1; 
    reg  [31 : 0] operand_2;

    reg adder_Cin;
    reg  [31 : 0] adder_input_1;
    reg  [31 : 0] adder_input_2;
    wire [31 : 0] adder_result;

    reg  [31 : 0] shift_input;
    reg  [4  : 0] shift_amount;
    reg           shift_direction;
    wire [31 : 0] shift_result;

    reg  adder_0_enable;
    reg  adder_1_enable;
    reg  adder_2_enable;
    reg  adder_3_enable;

    wire [31 : 0] adder_0_result;
    wire [31 : 0] adder_1_result;
    wire [31 : 0] adder_2_result;
    wire [31 : 0] adder_3_result;

    always @(*) 
    begin
        case (opcode)
            `OP     : begin operand_1 = rs1;    operand_2 = rs2;        end // R-TYPE 
            `OP_IMM : begin operand_1 = rs1;    operand_2 = immediate;  end // I-TYPE 
            default : begin operand_1 = 32'bz;  operand_2 = 32'bz;      end
        endcase        
    end

    // ----------------------------------- //
    // Main R-type and I-type Instrcutions //
    // ----------------------------------- //
    always @(*)
    begin
        case ({funct3, opcode})
            // I-TYPE Intructions
            {`ADDI,     `OP_IMM} : 
            begin 
                alu_output = adder_result;
            end
            {`SLLI,     `OP_IMM} : 
            begin 
                shift_direction = `LEFT; shift_input = operand_1; shift_amount = operand_2[4 : 0]; alu_output = shift_result;
            end 
            {`SLTI,     `OP_IMM} : 
            begin 
                alu_output = $signed(operand_1) < $signed(operand_2) ? 32'd1 : 32'd0;  
            end
            {`SLTIU,    `OP_IMM} : 
            begin 
                alu_output = operand_1 < operand_2 ? 32'd1 : 32'd0;
            end
            {`XORI,     `OP_IMM} : 
            begin 
                alu_output = operand_1 ^ operand_2;
            end
            {`ORI,      `OP_IMM} : 
            begin 
                alu_output = operand_1 | operand_2;
            end
            {`ANDI,     `OP_IMM} : 
            begin 
                alu_output = operand_1 & operand_2;
            end
            {`SRI,      `OP_IMM} : 
            begin
                case (funct7)
                    `LOGICAL : 
                    begin 
                        shift_direction = `RIGHT; 
                        shift_input = operand_1; 
                        shift_amount = operand_2[4 : 0]; 
                        alu_output = shift_result; 
                    end    
                    `ARITHMETIC :
                    begin 
                        shift_direction = `RIGHT; 
                        shift_input = operand_1; 
                        shift_amount = operand_2[4 : 0]; 
                        alu_output = shift_result; 
                    end     
                endcase
            end
        
            // R-TYPE Instructions
            {`ADDSUB,   `OP} : 
            begin  
                alu_output = adder_result;
            end  
            {`SLL,      `OP} : 
            begin 
                shift_direction = `LEFT; 
                shift_input = operand_1; 
                shift_amount = operand_2[4 : 0]; 
                alu_output = shift_result;
            end
            {`SLT,      `OP} : 
            begin  
                alu_output = $signed(operand_1) < $signed(operand_2) ? 32'd1 : 32'd0;    
            end
            {`SLTU,     `OP} : 
            begin  
                alu_output = operand_1 < operand_2 ? 32'd1 : 32'd0;
            end
            {`XOR,      `OP} : 
            begin   
                alu_output = operand_1 ^ operand_2;
            end
            {`OR,       `OP} : 
            begin    
                alu_output = operand_1 | operand_2;
            end
            {`AND,      `OP} : 
            begin 
                alu_output = operand_1 & operand_2;  
            end
            {`SR,       `OP} :
            begin
                case (funct7)
                    `LOGICAL : 
                    begin 
                        shift_direction = `RIGHT; 
                        shift_input = operand_1; 
                        shift_amount = operand_2[4 : 0]; 
                        alu_output = shift_result; 
                    end
                    `ARITHMETIC : 
                    begin 
                        shift_direction = `RIGHT; 
                        shift_input = operand_1; 
                        shift_amount = $signed(operand_2[4 : 0]); 
                        alu_output = shift_result; 
                    end
                endcase
            end           
            default: 
            begin 
                alu_output = 32'bz; 
            end
        endcase
    end

    // ----------------------------------------- //
    // Arithmetical Instructions: ADDI, ADD, SUB //
    // ----------------------------------------- //

    reg adder_enable;
    // *** Implement the control systems required for your circuit ***
    always @(*) 
    begin
        case ({funct3, opcode})
            {`ADDI, `OP_IMM} : 
            begin 
                adder_enable = 1'b1; 
                adder_input_1 = operand_1; 
                adder_input_2 = operand_2; 
                adder_Cin = 1'b0;
            end 

            {`ADDSUB, `OP} :
            begin
                case (funct7)
                    `ADD : 
                    begin 
                        adder_enable = 1'b1; 
                        adder_input_1 = operand_1; 
                        adder_input_2 = operand_2; 
                        adder_Cin = 1'b0;
                    end 
                    `SUB : 
                    begin 
                        adder_enable = 1'b1; 
                        adder_input_1 = operand_1; 
                        adder_input_2 = ~operand_2; 
                        adder_Cin = 1'b1; 
                    end 
                endcase
            end
            default : 
            begin 
                adder_enable = 1'b0; 
            end
        endcase    
    end

    always @(posedge adder_enable) 
    begin
        case (control_status_register[2 : 1])
            2'b00:   begin adder_0_enable = 1'b1; adder_1_enable = 1'b0; adder_2_enable = 1'b0; adder_3_enable = 1'b0; end
            2'b01:   begin adder_0_enable = 1'b0; adder_1_enable = 1'b1; adder_2_enable = 1'b0; adder_3_enable = 1'b0; end
            2'b10:   begin adder_0_enable = 1'b0; adder_1_enable = 1'b0; adder_2_enable = 1'b1; adder_3_enable = 1'b0; end
            2'b11:   begin adder_0_enable = 1'b0; adder_1_enable = 1'b0; adder_2_enable = 1'b0; adder_3_enable = 1'b1; end 
            default: begin adder_0_enable = 1'b1; adder_1_enable = 1'b0; adder_2_enable = 1'b0; adder_3_enable = 1'b0; end
        endcase
    end

    assign adder_result =   (adder_0_enable) ? adder_0_result :
                            (adder_1_enable) ? adder_1_result :
                            (adder_2_enable) ? adder_2_result :
                            (adder_3_enable) ? adder_3_result : adder_0_result;

    // Instantiation of Barrel Shifter circuit
    // ---------------------------------------
    Barrel_Shifter alu_shifter_circuit
    (
        .input_value(shift_input),
        .shift_amount(shift_amount),
        .direction(shift_direction),
        .result(shift_result)
    );
    // ---------------------------------------
    // End of Barrel Shifter instantiation

    // *** Instantiate your adder circuit here ***
    // Please instantiate your adder module according to the guidelines and naming conventions of phoeniX
    // --------------------------------------------------------------------------------------------------
    generate 
        if (GENERATE_CIRCUIT_1)
        begin : Arithmetic_Logic_Unit_Adder_Circuit_Generate_Block_1
            // Circuit 1 (default) instantiation
            //----------------------------------
            Approximate_Accuracy_Controllable_Adder 
            #(
                .LEN(32),
                .APX_LEN(8)
            )
            approximate_accuracy_controllable_adder 
            (
                .Er(control_status_register[10 : 3] | {8{~control_status_register[0]}}), 
                .A(adder_input_1),
                .B(adder_input_2),
                .Cin(adder_Cin),
                .Sum(adder_0_result)
            );
            //----------------------------------
            // End of Circuit 1 instantiation
        end
        if (GENERATE_CIRCUIT_2)
        begin : Arithmetic_Logic_Unit_Adder_Circuit_Generate_Block_2
            // Circuit 2 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 2 instantiation
        end
        if (GENERATE_CIRCUIT_3)
        begin : Arithmetic_Logic_Unit_Adder_Circuit_Generate_Block_3
            // Circuit 3 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 3 instantiation
        end
        if (GENERATE_CIRCUIT_4)
        begin : Arithmetic_Logic_Unit_Adder_Circuit_Generate_Block_4
            // Circuit 4 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 4 instantiation
        end
    endgenerate
    // --------------------------------------------------------------------------------------------------
    // *** End of adder module instantiation ***
endmodule

module Barrel_Shifter
(
    input  [31 : 0] input_value, 
    input  [4  : 0] shift_amount,
    input           direction,          // direction = 1 : RIGHT, direction = 0 : LEFT

    output [31 : 0] result 
);

    wire [31 : 0] shift_mux_0; 
    wire [31 : 0] shift_mux_1; 
    wire [31 : 0] shift_mux_2; 
    wire [31 : 0] shift_mux_3; 
    wire [31 : 0] shift_mux_4; 
    wire [31 : 0] reversed;
     
    // reverse -> shift right -> then reverse again
    Reverser_Circuit #(.N(32)) RC1 (input_value, direction, reversed);

    // Stage 0: shift 0 or 1 bit
    assign shift_mux_0 = shift_amount[0] ? {1'b0,  reversed[31 : 1]} : reversed;
    // Stage 1: shift 0 or 2 bits 
    assign shift_mux_1 = shift_amount[1] ? {2'b0,  shift_mux_0[31 : 2]} : shift_mux_0;
    // Stage 2: shift 0 or 4 bits 
    assign shift_mux_2 = shift_amount[2] ? {4'b0,  shift_mux_1[31 : 4]} : shift_mux_1;
    // Stage 3: shift 0 or 8 bits 
    assign shift_mux_3 = shift_amount[3] ? {8'b0,  shift_mux_2[31 : 8]} : shift_mux_2;
    // Stage 4: shift 0 or 16 bits 
    assign shift_mux_4 = shift_amount[4] ? {16'b0, shift_mux_3[31 : 16]} : shift_mux_3;

    // Reverse again 
    Reverser_Circuit #(.N(32)) RC2 (shift_mux_4, direction, result);
endmodule

module Reverser_Circuit
#(
    parameter N = 32
)
(
    input  [N - 1 : 0]  input_value, 
    input               enable, 
    output [N - 1 : 0]  reversed_value
);

    wire [N - 1 : 0] temp;
    
    genvar i;
    generate    
        for (i = 0 ; i <= N - 1 ; i = i + 1)
        begin : Reverser_Circuit_Generate_Block
            assign temp[i] = input_value[N - 1 - i];
        end
    endgenerate
    // enable = 1 (RIGHT) -> reverse module does nothing 
    // enable = 0 (LEFT)  -> result = temp (reversed)
    assign reversed_value = enable ? input_value : temp;
endmodule

// Add your custom adder circuit here ***
// Please create your adder module according to the guidelines and naming conventions of phoeniX
// --------------------------------------------------------------------------------------------------
module Approximate_Accuracy_Controllable_Adder 
#(
    parameter LEN = 32,
    parameter APX_LEN = 8         // Valid Options for APX_LEN : 4, 8, 12, 16, ...
)
(
    input [APX_LEN - 1 : 0] Er,
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);

    wire [LEN - 1 : 0] C;
    
    ////////////////////
    //    [3 : 0]     //
    ////////////////////

    Error_Configurable_Ripple_Carry_Adder #(.LEN(4)) EC_RCA_1 
    (
        .Er(Er[3  : 0]),
        .A(A[3 : 0]), 
        .B(B[3 : 0]), 
        .Cin(Cin), 
        .Sum(Sum[3 : 0]), 
        .Cout(C[3])
    );
    
    ////////////////////
    //    [31 : 4]    //
    ////////////////////

    genvar i;
    generate
        
        // ------------------- //
        // Approximate Circuit //
        // ------------------- //

        for (i = 4; i < APX_LEN; i = i + 4)
        begin : Approximate_Accuracy_Controllable_Adder_Approximate_Part_Generate_Block
            wire HA_Carry;
            wire EC_RCA_Carry;
            wire [i + 3 : i] EC_RCA_Output;

            Half_Adder HA
            (
                .A(A[i]), 
                .B(B[i]),
                .Sum(EC_RCA_Output[i]),
                .Cout(HA_Carry)
            );

            Error_Configurable_Ripple_Carry_Adder
            #(
                .LEN(3)
            )
            EC_RCA
            (
                .Er(Er[i + 3 : i + 1]),
                .A(A[i + 3 : i + 1]), 
                .B(B[i + 3 : i + 1]), 
                .Cin(HA_Carry),
                .Sum(EC_RCA_Output[i + 3 : i + 1]),
                .Cout(EC_RCA_Carry)
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit BU_1 (.A(EC_RCA_Output), .B(BU_Output), .C0(BU_Carry));

            Mux_2to1 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1({EC_RCA_Carry, EC_RCA_Output}),
                .data_in_2({BU_Carry || EC_RCA_Carry, BU_Output}),
                .select(C[i - 1]),
                .data_out({C[i + 3], Sum[i + 3 : i]})
            );
        end
        
        // ------------- //
        // Exact Circuit //
        // ------------- //

        for (i = APX_LEN; i < LEN; i = i + 4)
        begin : Approximate_Accuracy_Controllable_Adder_Exact_Part_Generate_Block
            wire HA_Carry;
            wire RCA_Carry;
            wire [i + 3 : i] RCA_Output;

            Half_Adder HA
            (
                .A(A[i]), 
                .B(B[i]),
                .Sum(RCA_Output[i]),
                .Cout(HA_Carry)
            );

            Ripple_Carry_Adder
            #(
                .LEN(3)
            )
            RCA
            (
                .A(A[i + 3 : i + 1]), 
                .B(B[i + 3 : i + 1]), 
                .Cin(HA_Carry),
                .Sum(RCA_Output[i + 3 : i + 1]),
                .Cout(RCA_Carry)
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit BU_1 (.A(RCA_Output), .B(BU_Output), .C0(BU_Carry));

            Mux_2to1 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1({RCA_Carry, RCA_Output}),
                .data_in_2({BU_Carry || RCA_Carry, BU_Output}),
                .select(C[i - 1]),
                .data_out({C[i + 3], Sum[i + 3 : i]})
            );
        end

    endgenerate
    
    assign Cout = C[LEN - 1];
endmodule

module Basic_Unit 
(
    input  [3 : 0] A,
    output [4 : 1] B,
    output C0
);

    assign B[1] = ~A[0];
    assign B[2] = A[1] ^ A[0];
    wire   C1   = A[1] & A[0];
    wire   C2   = A[2] & A[3];
    assign C0   = C1 & C2;
    wire   C3   = C1 & A[2];
    assign B[3] = A[2] ^ C1;
    assign B[4] = A[3] ^ C3;
endmodule

module Mux_2to1
#(
    parameter LEN = 5
) 
(
    input [LEN - 1 : 0] data_in_1,        
    input [LEN - 1 : 0] data_in_2,        
    input select,                   

    output reg [LEN - 1: 0] data_out            
);

    always @(*) 
    begin
        case (select)
            1'b0: begin data_out = data_in_1; end
            1'b1: begin data_out = data_in_2; end
            default: begin data_out = {LEN{1'bz}}; end
        endcase
    end
endmodule

module Error_Configurable_Ripple_Carry_Adder 
#(
    parameter LEN = 4
) 
(
    input [LEN - 1 : 0] Er,
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);
    wire [LEN : 0] Carry;
    assign Carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin : Error_Configurable_Ripple_Carry_Adder_Generate_Block
            Error_Configurable_Full_Adder ECFA 
            (
                .Er(Er[i]),
                .A(A[i]), 
                .B(B[i]), 
                .Cin(Carry[i]), 
                .Sum(Sum[i]), 
                .Cout(Carry[i + 1])
            );
        end
    assign Cout = Carry[LEN];
    endgenerate
endmodule

module Ripple_Carry_Adder 
#(
    parameter LEN = 4
) 
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);
    wire [LEN : 0] Carry;
    assign Carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin : Ripple_Carry_Adder_Generate_Block
            Full_Adder FA 
            (
                .A(A[i]), 
                .B(B[i]), 
                .Cin(Carry[i]), 
                .Sum(Sum[i]), 
                .Cout(Carry[i + 1])
            );
        end
    assign Cout = Carry[LEN];
    endgenerate
endmodule

module Error_Configurable_Full_Adder
(
    input Er,
    input A,
    input B, 
    input Cin,

    output Sum, 
    output Cout
);
    assign Sum = ~(Er && (A ^ B) && Cin) && ((A ^ B) || Cin);
    assign Cout = (Er && B && Cin) || ((B || Cin) && A);
endmodule

module Full_Adder 
(
    input A,
    input B,
    input Cin,

    output Sum,
    output Cout
);
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A && B) || (A && Cin) || (B && Cin); 
endmodule

module Half_Adder 
(
    input A,
    input B, 
    output Sum, 
    output Cout
);
    assign Sum = A ^ B;
    assign Cout = A & B;
endmodule

// --------------------------------------------------------------------------------------------------
// *** End of adder module definition ***

module Control_Status_Register_File 
(
    input wire clk,
    input wire reset,

    input wire [ 6 : 0] opcode,
    input wire [ 2 : 0] funct3,
    input wire [ 6 : 0] funct7,
    input wire [11 : 0] funct12,
    input wire [ 4 : 0] write_index,

    input wire read_enable_csr,
    input wire write_enable_csr,

    input wire [11 : 0] csr_read_index,
    input wire [11 : 0] csr_write_index,

    input wire [31 : 0] csr_write_data,
    output reg [31 : 0] csr_read_data,

    output wire [31 : 0] alucsr_wire,
    output wire [31 : 0] mulcsr_wire,
    output wire [31 : 0] divcsr_wire
);

    reg [31 : 0] alucsr_reg;       // Arithmetic Logic Unit Aproximation Control Register
    assign alucsr_wire = alucsr_reg;
    
    reg [31 : 0] mulcsr_reg;       // Multiplier Unit Aproximation Control Register
    assign mulcsr_wire = mulcsr_reg;

    reg [31 : 0] divcsr_reg;       // Divider Unit Aproximation Control Register
    assign divcsr_wire = divcsr_reg;

    reg [63 : 0] mcycle_reg;
    reg [63 : 0] minstret_reg;

    always @(*) 
    begin
        if (read_enable_csr)
        begin
            case (csr_read_index)
                `alucsr :       csr_read_data = alucsr_reg;
                `mulcsr :       csr_read_data = mulcsr_reg;
                `divcsr :       csr_read_data = divcsr_reg;
                `mcycle :       csr_read_data = mcycle_reg[31 :  0];
                `mcycleh :      csr_read_data = mcycle_reg[63 : 32];
                `minstret :     csr_read_data = minstret_reg[31 :  0];
                `minstreth :    csr_read_data = minstret_reg[63 : 32];
                default :       csr_read_data = 32'bz;
            endcase
        end
        else csr_read_data = 32'bz;
    end    
    
    always @(negedge clk or posedge reset) 
    begin   
        if (reset)
        begin
            alucsr_reg <= 32'b0;
            mulcsr_reg <= 32'b0;
            divcsr_reg <= 32'b0;
        end
        else if (write_enable_csr)
        begin
            case (csr_write_index)
                `alucsr : alucsr_reg <= csr_write_data;
                `mulcsr : mulcsr_reg <= csr_write_data;
                `divcsr : divcsr_reg <= csr_write_data;
            endcase
        end  
    end

    ////////////////////////////////
    //    Performance Counters    //
    ////////////////////////////////

    // -------------
    // Cycle Counter
    // -------------

    always @(posedge clk) 
    begin
        if (reset)  mcycle_reg <= 32'b0;
        else        mcycle_reg <= mcycle_reg + 32'd1; 
    end

    // -------------------
    // Instruction Counter
    // -------------------

    always @(posedge clk) 
    begin
        if (reset)  minstret_reg <= 32'b0;
        else if (!(
            opcode       == `NOP_opcode  &
            funct3       == `NOP_funct3  &  
            funct7       == `NOP_funct7  & 
            funct12      == `NOP_funct12 &
            write_index  == `NOP_write_index    
        ))
                    minstret_reg <= minstret_reg + 32'b1;
    end
endmodule

module Control_Status_Unit 
(
    input wire [ 6 : 0] opcode,
    input wire [ 2 : 0] funct3,

    input wire [31 : 0] CSR_in,
    input wire [31 : 0] rs1,
    input wire [ 4 : 0] unsigned_immediate,

    output reg [31 : 0] rd,
    output reg [31 : 0] CSR_out
);

    always @(*) 
    begin
        case ({funct3, opcode})
            {`CSRRW,  `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= rs1; end                                        
            {`CSRRS,  `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= CSR_in | rs1; end                               
            {`CSRRC,  `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= CSR_in & ~rs1; end                              
            {`CSRRWI, `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= {27'b0, unsigned_immediate}; end                
            {`CSRRSI, `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= CSR_in | {27'b0, unsigned_immediate}; end       
            {`CSRRCI, `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= CSR_in & ~{27'b0, unsigned_immediate}; end         
            default             : begin rd <= 32'bz;     CSR_out <= 32'bz; end
        endcase
    end
endmodule

module Fetch_Unit
(
	input wire enable,                    

    input wire [31 : 0] pc, 
    output reg [31 : 0] next_pc,  
    
    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////

    output reg  memory_interface_enable,
    output reg  memory_interface_state,
    output reg  [31 : 0]   memory_interface_address,
    output reg  [ 3 : 0]   memory_interface_frame_mask
);

    wire [31 : 2] incrementer_result;

    Incrementer 
    #(
        .LEN(30)
    )
    incrementer
    (
        .value(pc[31 : 2]),
        .result(incrementer_result)
    );

    always @(*) 
    begin
        if (enable)
        begin
            memory_interface_enable = `ENABLE;
            memory_interface_state = `READ;
            memory_interface_frame_mask = 4'b1111;
            memory_interface_address = pc;  
            next_pc = {incrementer_result, 2'b00};    
        end
        else
        begin
            memory_interface_enable = `DISABLE;
            memory_interface_state = 'bz;
            memory_interface_frame_mask = 'bz;
            memory_interface_address = 'bz;  
            next_pc = 'bz;
        end
    end
endmodule

module Incrementer
#(
    parameter LEN = 32
)
(
    input   [LEN - 1 : 0]   value,
    output  [LEN - 1 : 0]   result
);
    localparam COUNT = LEN / 4;
    `define SLICE  [(i * 4) + 3 : (i * 4)]

    wire [COUNT - 1 : 0] carry_chain;
    
    Incrementer_Unit IU_1 
    (
        .value(value[3 : 0]),
        .result(result[3 : 0]),
        .Cout(carry_chain[0])
    );

    wire [3 : 0] incrementer_unit_result [1 : COUNT];
    wire [COUNT - 1 : 1] incrementer_unit_carry_out;

    genvar i;
    generate
        for (i = 1; i < COUNT; i = i + 1)
        begin : Incrementer_Generate_Block
            Incrementer_Unit IU
            (
                .value(value`SLICE),
                .result(incrementer_unit_result[i]),
                .Cout(incrementer_unit_carry_out[i])
            );

            Mux_2to1_Incrementer MUX
            (
                .data_in_1({1'b0, value`SLICE}),
                .data_in_2({incrementer_unit_carry_out[i], incrementer_unit_result[i]}),
                .select(carry_chain[i - 1]),
                .data_out({carry_chain[i], result`SLICE})
            );
        end

        if (COUNT * 4 < LEN)
            assign result[LEN - 1 : (COUNT * 4)] = value[LEN - 1 : (COUNT * 4)] + carry_chain[COUNT - 1]; 
    endgenerate
endmodule

module Incrementer_Unit 
(
    input  [3 : 0] value,
    output [4 : 1] result,
    output Cout
);

    assign result[1] = ~value[0];
    assign result[2] = value[1] ^ value[0];
    wire   C1   = value[1] & value[0];
    wire   C2   = value[2] & value[3];
    assign Cout = C1 & C2;
    wire   C3   = C1 & value[2];
    assign result[3] = value[2] ^ C1;
    assign result[4] = value[3] ^ C3;
endmodule

module Mux_2to1_Incrementer
#(
    parameter LEN = 5
) 
(
    input [LEN - 1 : 0] data_in_1,        
    input [LEN - 1 : 0] data_in_2,        
    input select,                   

    output reg [LEN - 1: 0] data_out            
);

    always @(*) 
    begin
        if (select)
            data_out <= data_in_2;
        else
            data_out <= data_in_1;
    end
endmodule

module Hazard_Forward_Unit 
(
    input wire [ 4 : 0] source_index,          
    
    input wire [ 4 : 0] destination_index_1,
    input wire [ 4 : 0] destination_index_2,

    input wire [31 : 0] data_1,
    input wire [31 : 0] data_2,

    input wire enable_1,
    input wire enable_2,
    
    output reg forward_enable,
    output reg [31 : 0] forward_data
);

    always @(*) 
    begin
        if (source_index == destination_index_1 && enable_1 == `ENABLE)
        begin
            forward_data <= data_1;
            forward_enable <= `ENABLE;
        end
            
        else if (source_index == destination_index_2 && enable_2 == `ENABLE)
        begin
            forward_data <= data_2;
            forward_enable <= `ENABLE;
        end
            
        else
        begin
            forward_data <= 32'bz;
            forward_enable <= `DISABLE;
        end
    end
endmodule

module Immediate_Generator 
(
	input wire [31 : 7] instruction,
	input wire [ 2 : 0] instruction_type,

	output reg [31 : 0] immediate
);
    always @(*)
    begin
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

module Instruction_Decoder 
(
    input wire [31 : 0] instruction,

    output reg [ 2 : 0] instruction_type,
    output reg [ 6 : 0] opcode,
    output reg [ 2 : 0] funct3,
    output reg [ 6 : 0] funct7,
    output reg [11 : 0] funct12,

    output reg [ 4 : 0] read_index_1,
    output reg [ 4 : 0] read_index_2,
    output reg [ 4 : 0] write_index,
    output reg [11 : 0] csr_index,

    output reg read_enable_1,
    output reg read_enable_2,
    output reg write_enable,

    output reg read_enable_csr,
    output reg write_enable_csr
);

    always @(*) 
    begin
        opcode  = instruction[ 6 :  0];
        funct7  = instruction[31 : 25];
        funct3  = instruction[14 : 12];
        funct12 = instruction[31 : 20]; 
    end
    
    always @(*) 
    begin
        read_index_1 = instruction[19 : 15];
        read_index_2 = instruction[24 : 20];
        write_index  = instruction[11 :  7];
        csr_index    = instruction[31 : 20];
    end

    always @(*)
    begin
        case (opcode)
            `OP         : instruction_type = `R_TYPE;
            `OP_FP      : instruction_type = `R_TYPE;

            `LOAD       : instruction_type = `I_TYPE;
            `LOAD_FP    : instruction_type = `I_TYPE;
            `OP_IMM     : instruction_type = `I_TYPE;
            `OP_IMM_32  : instruction_type = `I_TYPE;
            `JALR       : instruction_type = `I_TYPE;
            `SYSTEM     : instruction_type = `I_TYPE; 

            `STORE      : instruction_type = `S_TYPE;
            `STORE_FP   : instruction_type = `S_TYPE;

            `BRANCH     : instruction_type = `B_TYPE;

            `AUIPC      : instruction_type = `U_TYPE;
            `LUI        : instruction_type = `U_TYPE;

            `JAL        : instruction_type = `J_TYPE;
            default     : instruction_type = 3'bz;
        endcase
    end

    always @(*) 
    begin
        // Register File read/write enable signals evaluation
        case (instruction_type)
            `R_TYPE : begin read_enable_1 = `ENABLE;    read_enable_2 = `ENABLE;    write_enable = `ENABLE;     end
            `I_TYPE : begin read_enable_1 = `ENABLE;    read_enable_2 = `DISABLE;   write_enable = `ENABLE;     end
            `S_TYPE : begin read_enable_1 = `ENABLE;    read_enable_2 = `ENABLE;    write_enable = `DISABLE;    end
            `B_TYPE : begin read_enable_1 = `ENABLE;    read_enable_2 = `ENABLE;    write_enable = `DISABLE;    end
            `U_TYPE : begin read_enable_1 = `DISABLE;   read_enable_2 = `DISABLE;   write_enable = `ENABLE;     end
            `J_TYPE : begin read_enable_1 = `DISABLE;   read_enable_2 = `DISABLE;   write_enable = `ENABLE;     end 
            default : begin read_enable_1 = `DISABLE;   read_enable_2 = `DISABLE;   write_enable = `DISABLE;    end // Raise Exception
        endcase    

        // Disable Write Signal when destination is x0
        if (write_index == 5'b00000) write_enable = `DISABLE;
    end

    always @(*) 
    begin
        // CSR register file read/write enable signals evaluation
        case ({opcode, funct3})
            {`SYSTEM, `CSRRW}   : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRS}   : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRC}   : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRWI}  : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRSI}  : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRCI}  : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            default             : begin read_enable_csr = `DISABLE; write_enable_csr = `DISABLE; end
        endcase  
    end
endmodule

module Jump_Branch_Unit 
(
    input wire [ 6 : 0] opcode,
    input wire [ 2 : 0] funct3,
    input wire [ 2 : 0] instruction_type,

    input wire [31 : 0] rs1,
    input wire [31 : 0] rs2,
      
    output reg jump_branch_enable     
);

    reg branch_enable;
    reg jump_enable;

    always @(*) 
    begin
            if (instruction_type == `B_TYPE)  
                case (funct3)
                    `BEQ  : begin if ($signed(rs1) == $signed(rs2))   branch_enable = `ENABLE; else  branch_enable = `DISABLE; end 
                    `BNE  : begin if ($signed(rs1) != $signed(rs2))   branch_enable = `ENABLE; else  branch_enable = `DISABLE; end                    
                    `BLT  : begin if ($signed(rs1) <  $signed(rs2))   branch_enable = `ENABLE; else  branch_enable = `DISABLE; end                    
                    `BGE  : begin if ($signed(rs1) >= $signed(rs2))   branch_enable = `ENABLE; else  branch_enable = `DISABLE; end                    
                    `BLTU : begin if (rs1 < rs2)                      branch_enable = `ENABLE; else  branch_enable = `DISABLE; end
                    `BGEU : begin if (rs1 >= rs2)                     branch_enable = `ENABLE; else  branch_enable = `DISABLE; end                    
                    default: branch_enable = `DISABLE;
                endcase
            else branch_enable = `DISABLE;

            if (opcode == `JAL || opcode == `JALR) jump_enable = `ENABLE;
            else jump_enable = `DISABLE;
            
            jump_branch_enable = jump_enable || branch_enable;
    end 
endmodule

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

module Register_File
#(
    parameter WIDTH = 32,
    parameter DEPTH = 5
)
(
    input wire clk,
    input wire reset,
    
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
	reg [WIDTH - 1 : 0] Registers [0 : 2**DEPTH - 1];      

    integer i;    	
    
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            for (i = 0; i < 2**DEPTH; i = i + 1)
                Registers[i] <= {WIDTH{1'b0}};
        end
        else if (write_enable == `ENABLE)
        begin
            Registers[write_index] <= write_data;
        end
    end

    always @(*) 
    begin
        if (read_enable_1 == `ENABLE)
            read_data_1 <= Registers[read_index_1];
        else
            read_data_1 <= {WIDTH{1'bz}};

        if (read_enable_2 == `ENABLE)
            read_data_2 <= Registers[read_index_2];
        else
            read_data_2 <= {WIDTH{1'bz}};
    end
endmodule

module Multiplier_Unit
#(
    parameter GENERATE_CIRCUIT_1 = 1,
    parameter GENERATE_CIRCUIT_2 = 0,
    parameter GENERATE_CIRCUIT_3 = 0,
    parameter GENERATE_CIRCUIT_4 = 0
)
(
    input wire clk, 

    input wire [ 6 : 0] opcode, 
    input wire [ 6 : 0] funct7,
    input wire [ 2 : 0] funct3, 

    input wire [31 : 0] control_status_register, 

    input wire [31 : 0] rs1, 
    input wire [31 : 0] rs2,  

    output              multiplier_unit_busy, 
    output reg [31 : 0] multiplier_unit_output  
);

    reg  [31 : 0] operand_1;            // RS1 latch
    reg  [31 : 0] operand_2;            // RS2 latch

    reg  [31 : 0] input_1;              // Modules input 1
    reg  [31 : 0] input_2;              // Modules input 2

    wire [ 6 : 0] multiplier_accuracy;
    wire [31 : 0] multiplier_input_1;   // Latched modules input 1
    wire [31 : 0] multiplier_input_2;   // Latched modules input 2

    wire [63 : 0] result;               

    reg  multiplier_0_enable;
    reg  multiplier_1_enable;
    reg  multiplier_2_enable;
    reg  multiplier_3_enable;

    wire [63 : 0] multiplier_0_result;
    wire [63 : 0] multiplier_1_result;
    wire [63 : 0] multiplier_2_result;
    wire [63 : 0] multiplier_3_result;

    wire multiplier_0_busy;
    wire multiplier_1_busy;
    wire multiplier_2_busy;
    wire multiplier_3_busy;

    reg reset_enable_signals = 0;
    reg [1 : 0] signal_state;
    reg [1 : 0] next_state;

    localparam signal_zero = 2'b00;
    localparam signal_high = 2'b01;
    localparam signal_low  = 2'b10;

    reg reset_controller_enable;
    reg state_machine_enable;

    always @(*) 
    begin
        operand_1 = rs1;
        operand_2 = rs2;
        if (!reset_enable_signals)
        begin
        case ({funct7, funct3, opcode})
            {`MULDIV, `MUL, `OP} : 
            begin
                input_1 = $signed(operand_1);
                input_2 = $signed(operand_2);
                multiplier_unit_output = result[31 : 0];
                case (control_status_register[2 : 1])
                    2'b00:   begin multiplier_0_enable = 1'b1; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                    2'b01:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b1; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                    2'b10:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b1; multiplier_3_enable = 1'b0; end
                    2'b11:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b1; end 
                    default: begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                endcase
            end
            {`MULDIV, `MULH, `OP} : 
            begin 
                input_1 = $signed(operand_1);
                input_2 = $signed(operand_2);
                multiplier_unit_output = result >>> 32;
                case (control_status_register[2 : 1])
                    2'b00:   begin multiplier_0_enable = 1'b1; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                    2'b01:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b1; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                    2'b10:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b1; multiplier_3_enable = 1'b0; end
                    2'b11:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b1; end 
                    default: begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                endcase
            end
            {`MULDIV, `MULHSU, `OP} : 
            begin
                input_1 = $signed(operand_1);
                input_2 = operand_2;
                multiplier_unit_output = result >>> 32;
                case (control_status_register[2 : 1])
                    2'b00:   begin multiplier_0_enable = 1'b1; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                    2'b01:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b1; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                    2'b10:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b1; multiplier_3_enable = 1'b0; end
                    2'b11:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b1; end 
                    default: begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                endcase
            end
            {`MULDIV, `MULHU, `OP} : 
            begin
                input_1 = operand_1;
                input_2 = operand_2;
                multiplier_unit_output = result >> 32;
                case (control_status_register[2 : 1])
                    2'b00:   begin multiplier_0_enable = 1'b1; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                    2'b01:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b1; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                    2'b10:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b1; multiplier_3_enable = 1'b0; end
                    2'b11:   begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b1; end 
                    default: begin multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0; multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0; end
                endcase
            end
            default: 
            begin
                multiplier_unit_output = 32'bz; 
                multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0;
                multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0;
            end
        endcase
        end else if (reset_enable_signals) 
        begin
            multiplier_0_enable = 1'b0; multiplier_1_enable = 1'b0;
            multiplier_2_enable = 1'b0; multiplier_3_enable = 1'b0;
        end
    end

    assign multiplier_unit_busy = (multiplier_0_enable | multiplier_1_enable | multiplier_2_enable | multiplier_3_enable);

    always @(multiplier_0_busy or multiplier_1_busy or multiplier_2_busy or multiplier_3_busy or reset_controller_enable) 
    begin 
        if (!multiplier_0_busy) begin state_machine_enable <= 1; end 
        else if (!multiplier_1_busy) begin state_machine_enable <= 1; end 
        else if (!multiplier_2_busy) begin state_machine_enable <= 1; end
        else if (!multiplier_3_busy) begin state_machine_enable <= 1; end
        else if (reset_controller_enable) begin state_machine_enable <= 0; end
    end

    always @(posedge clk or negedge state_machine_enable) 
    begin
        if (!state_machine_enable) signal_state <= signal_zero;
        else signal_state <= next_state;
    end
    
    always @(*) 
    begin
        case (signal_state)
            signal_zero:   
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals <= 0; next_state <= signal_high; reset_controller_enable <= 0; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals <= 0; next_state <= signal_low;  reset_controller_enable <= 0; end
                end
            signal_high:   
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals <= 1; next_state <= signal_low; reset_controller_enable <= 0; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 0; end 
                end
            signal_low:    
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 1; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 0; end
                end
            default:       
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 1; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 0; end
                end
        endcase
    end

    assign multiplier_0_enable_wire = (!reset_enable_signals) ? multiplier_0_enable : 0;
    assign multiplier_1_enable_wire = (!reset_enable_signals) ? multiplier_1_enable : 0; 
    assign multiplier_2_enable_wire = (!reset_enable_signals) ? multiplier_2_enable : 0; 
    assign multiplier_3_enable_wire = (!reset_enable_signals) ? multiplier_3_enable : 0;  

    // Assigning multiplier circuits' inputs
    reg circuits_input_enable = 0;
    wire enables_combine = (multiplier_0_enable | multiplier_1_enable | multiplier_2_enable | multiplier_3_enable);
    always @(posedge enables_combine) 
    begin circuits_input_enable = 1; end
    assign multiplier_input_1  = (circuits_input_enable) ? input_1 : 32'bz;
    assign multiplier_input_2  = (circuits_input_enable) ? input_2 : 32'bz;
    assign multiplier_accuracy = (circuits_input_enable) ? (control_status_register[9 : 3] | {7{~control_status_register[0]}}) : 7'bz;

    // Assigning multiplier circuits' results to top unit result
    assign result = (multiplier_0_enable) ? multiplier_0_result :
                    (multiplier_1_enable) ? multiplier_1_result :
                    (multiplier_2_enable) ? multiplier_2_result :
                    (multiplier_3_enable) ? multiplier_3_result : multiplier_0_result;

    // *** Instantiate your multiplier circuit here ***
    // Please instantiate your multiplier module according to the guidelines and naming conventions of phoeniX
    // -------------------------------------------------------------------------------------------------------
    generate 
        if (GENERATE_CIRCUIT_1)
        begin : Multiplier_1_Generate_Block
            // Circuit 1 (default) instantiation
            //----------------------------------
            Approximate_Accuracy_Controllable_Multiplier approximate_accuracy_controllable_multiplier 
            (
                .clk(clk),
                .enable(multiplier_0_enable_wire),
                .Er(multiplier_accuracy),
                .Operand_1(multiplier_input_1), 
                .Operand_2(multiplier_input_2),  
                .Result(multiplier_0_result),
                .Busy(multiplier_0_busy)
            );
            //----------------------------------
            // End of Circuit 1 instantiation
        end
        if (GENERATE_CIRCUIT_2)
        begin : Multiplier_2_Generate_Block
            // Circuit 2 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 2 instantiation
        end
        if (GENERATE_CIRCUIT_3)
        begin : Multiplier_3_Generate_Block
            // Circuit 3 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 3 instantiation
        end
        if (GENERATE_CIRCUIT_4)
        begin : Multiplier_4_Generate_Block
            // Circuit 4 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 4 instantiation
        end
    endgenerate
    // -------------------------------------------------------------------------------------------------------
    // *** End of multiplier module instantiation ***
endmodule

// Add your custom multiplier circuit here ***
// Please create your multiplier module according to the guidelines and naming conventions of phoeniX
// --------------------------------------------------------------------------------------------------------
module Approximate_Accuracy_Controllable_Multiplier 
(
    input wire clk,
    input wire enable,

    input wire [ 6 : 0] Er,
    input wire [31 : 0] Operand_1,
    input wire [31 : 0] Operand_2,

    output reg [63 : 0] Result,
    output reg Busy
);
    
    wire [31 : 0] Partial_Product [0 : 3];
    wire Partial_Busy [0 : 3];

    Approximate_Accuracy_Controllable_Multiplier_16bit multiplier_LOWxLOW
    (
        .clk(clk),
        .enable(enable),

        .Er(Er),
        .Operand_1(Operand_1[15 : 0]),
        .Operand_2(Operand_2[15 : 0]),

        .Result(Partial_Product[0]),
        .Busy(Partial_Busy[0])
    );

    Approximate_Accuracy_Controllable_Multiplier_16bit multiplier_HIGHxLOW
    (
        .clk(clk),
        .enable(enable),

        .Er({7{1'b1}}),
        .Operand_1(Operand_1[31 : 16]),
        .Operand_2(Operand_2[15 :  0]),

        .Result(Partial_Product[1]),
        .Busy(Partial_Busy[1])
    );

    Approximate_Accuracy_Controllable_Multiplier_16bit multiplier_LOWxHIGH
    (
        .clk(clk),
        .enable(enable),

        .Er({7{1'b1}}),
        .Operand_1(Operand_1[15 :  0]),
        .Operand_2(Operand_2[31 : 16]),

        .Result(Partial_Product[2]),
        .Busy(Partial_Busy[2])
    );

    Approximate_Accuracy_Controllable_Multiplier_16bit multiplier_HIGHxHIGH
    (
        .clk(clk),
        .enable(enable),

        .Er({7{1'b1}}),
        .Operand_1(Operand_1[31 : 16]),
        .Operand_2(Operand_2[31 : 16]),

        .Result(Partial_Product[3]),
        .Busy(Partial_Busy[3])
    );

    always @(*) 
    begin
        Result = {32'b0, Partial_Product[0]} + {16'b0, Partial_Product[1], 16'b0} + {16'b0, Partial_Product[2], 16'b0} + {Partial_Product[3], 32'b0};
        Busy = &{Partial_Busy[0], Partial_Busy[1], Partial_Busy[2], Partial_Busy[3]};
    end
endmodule

module Approximate_Accuracy_Controllable_Multiplier_16bit 
(
    input wire clk,
    input wire enable,

    input wire [ 6 : 0] Er,
    input wire [15 : 0] Operand_1,
    input wire [15 : 0] Operand_2,

    output reg [31 : 0] Result,
    output reg Busy
);

    reg     [ 7 : 0] mul_input_1;
    reg     [ 7 : 0] mul_input_2;
    wire    [15 : 0] mul_result;

    reg     [15 : 0] partial_result_1;
    reg     [15 : 0] partial_result_2;
    reg     [15 : 0] partial_result_3;
    reg     [15 : 0] partial_result_4;

    Approximate_Accuracy_Controllable_Multiplier_8bit mul
    (
        .Er(Er),
        .Operand_1(mul_input_1),
        .Operand_2(mul_input_2),
        .Result(mul_result)
    );

    reg [2 : 0] state;
    reg [2 : 0] next_state;

    always @(posedge clk) 
    begin
        if (~enable)    state <= 3'b000;
        else            state <= next_state;
    end

    always @(*) 
    begin
        next_state <= 'bz;
       
        case (state)
            3'b000 : 
            begin 
                mul_input_1 <= 'bz; 
                mul_input_2 <= 'bz; 
                
                partial_result_1 <= 'bz; 
                partial_result_2 <= 'bz; 
                partial_result_3 <= 'bz; 
                partial_result_4 <= 'bz; 
                
                Busy <= 1'b0; 
                next_state <= 3'b001; 
            end
            3'b001 : begin mul_input_1 <= Operand_1[ 7 : 0]; mul_input_2 <= Operand_2[ 7 : 0]; partial_result_1 <= mul_result; next_state <= 3'b010; Busy <= 1'b1; end
            3'b010 : begin mul_input_1 <= Operand_1[15 : 8]; mul_input_2 <= Operand_2[ 7 : 0]; partial_result_2 <= mul_result; next_state <= 3'b011; end
            3'b011 : begin mul_input_1 <= Operand_1[ 7 : 0]; mul_input_2 <= Operand_2[15 : 8]; partial_result_3 <= mul_result; next_state <= 3'b100; end
            3'b100 : begin mul_input_1 <= Operand_1[15 : 8]; mul_input_2 <= Operand_2[15 : 8]; partial_result_4 <= mul_result; next_state <= 3'b101; end
            3'b101 : 
            begin 
                Result =    {16'b0, partial_result_1} +
                            {8'b0,  partial_result_2, 8'b0} +
                            {8'b0,  partial_result_3, 8'b0} +
                            {partial_result_4, 16'b0}; 

                next_state <= 3'b000; 
                Busy <= 1'b0;
            end
        endcase 
    end
endmodule

module Approximate_Accuracy_Controllable_Multiplier_8bit
(
    input [6 : 0] Er,
    input [7 : 0] Operand_1,
    input [7 : 0] Operand_2,

    output [15 : 0] Result
);
    
    wire [7 : 0] PP [1 : 8];

    generate
        for (genvar i = 1; i < 9; i = i + 1)
        begin : PP_Generation
            assign PP[i] = {8{Operand_2[i - 1]}} & Operand_1;
        end
    endgenerate

    // Stage 1 -  ATC_8 wires and instantiation
    wire [8 : 0] P1;
    wire [8 : 0] P2;
    wire [8 : 0] P3;
    wire [8 : 0] P4;

    wire [14 : 0] V1;

    ATC_8 atc_8 (PP[1], PP[2], PP[3], PP[4], PP[5], PP[6], PP[7], PP[8], P1, P2, P3, P4, V1);

    // Stage 1 - ATC_4 wires and instantiation
    wire [10 : 0] P5;
    wire [10 : 0] P6;

    wire [14 : 0] V2;

    ATC_4 atc_4 (P1, P2, P3, P4, P5, P6, V2);

    // Stage 1 - Final row of iCACs (ATC_2)

    wire [14 : 0] P7;
    wire [14 : 0] Q7;

    iCAC #(11, 4) iCAC_7 (P5, P6, P7, Q7);

    // Stage 2

    wire [10 : 4] ORed_PPs = V1 [10 : 4] | V2 [10 : 4];

    // Stage 3

    wire [14 : 0] SumSignal, CarrySignal;

    assign SumSignal[0] = P7[0];
    assign CarrySignal[0] = 0;
    assign CarrySignal[1] = 0;

    Half_Adder_Mul HA_1 (P7[1], V1[1], SumSignal[1], CarrySignal[2]);
    
    Full_Adder_Mul FA_1 (P7[2], V1[2], V2[2], SumSignal[2], CarrySignal[3]);
    Full_Adder_Mul FA_2 (P7[3], V1[3], V2[3], SumSignal[3], CarrySignal[4]);

    Full_Adder_Mul FA_3 (P7[4], Q7[4], ORed_PPs[4], SumSignal[4], CarrySignal[5]);
    Full_Adder_Mul FA_4 (P7[5], Q7[5], ORed_PPs[5], SumSignal[5], CarrySignal[6]);
    Full_Adder_Mul FA_5 (P7[6], Q7[6], ORed_PPs[6], SumSignal[6], CarrySignal[7]);
    Full_Adder_Mul FA_6 (P7[7], Q7[7], ORed_PPs[7], SumSignal[7], CarrySignal[8]);
    Full_Adder_Mul FA_7 (P7[8], Q7[8], ORed_PPs[8], SumSignal[8], CarrySignal[9]);
    Full_Adder_Mul FA_8 (P7[9], Q7[9], ORed_PPs[9], SumSignal[9], CarrySignal[10]);
    Full_Adder_Mul FA_9 (P7[10], Q7[10], ORed_PPs[10], SumSignal[10], CarrySignal[11]);

    Full_Adder_Mul FA_10 (P7[11], V1[11], V2[11], SumSignal[11], CarrySignal[12]);
    Full_Adder_Mul FA_11 (P7[12], V1[12], V2[12], SumSignal[12], CarrySignal[13]);

    Half_Adder_Mul HA_2 (P7[13], V1[13], SumSignal[13], CarrySignal[14]);

    assign SumSignal[14] = P7[14];

    // Stage 4

    assign Result[0] = SumSignal[0];
    assign Result[1] = SumSignal[1];

    assign Result[2] = SumSignal[2] | CarrySignal[2];
    assign Result[3] = SumSignal[3] | CarrySignal[3];
    assign Result[4] = SumSignal[4] | CarrySignal[4];

    wire [13 : 5] inter_Carry;
    
    Error_Configurable_Full_Adder_Mul ECA_FA_1 (Er[0], SumSignal[5], CarrySignal[5], 1'b0, Result[5], inter_Carry[5]);
    
    Error_Configurable_Full_Adder_Mul ECA_FA_2 (Er[1], SumSignal[6], CarrySignal[6], inter_Carry[5], Result[6], inter_Carry[6]);
    Error_Configurable_Full_Adder_Mul ECA_FA_3 (Er[2], SumSignal[7], CarrySignal[7], inter_Carry[6], Result[7], inter_Carry[7]);
    Error_Configurable_Full_Adder_Mul ECA_FA_4 (Er[3], SumSignal[8], CarrySignal[8], inter_Carry[7], Result[8], inter_Carry[8]);
    Error_Configurable_Full_Adder_Mul ECA_FA_5 (Er[4], SumSignal[9], CarrySignal[9], inter_Carry[8], Result[9], inter_Carry[9]);
    Error_Configurable_Full_Adder_Mul ECA_FA_6 (Er[5], SumSignal[10], CarrySignal[10], inter_Carry[9], Result[10], inter_Carry[10]);
    Error_Configurable_Full_Adder_Mul ECA_FA_7 (Er[6], SumSignal[11], CarrySignal[11], inter_Carry[10], Result[11], inter_Carry[11]);


    Full_Adder_Mul FA_12 (SumSignal[12], CarrySignal[12], inter_Carry[11], inter_Carry[12], Result[12]);
    Full_Adder_Mul FA_13 (SumSignal[13], CarrySignal[13], inter_Carry[12], inter_Carry[13], Result[13]);
    Full_Adder_Mul FA_14 (SumSignal[14], CarrySignal[14], inter_Carry[13], Result[15], Result[14]);
endmodule

module iCAC 
#(
    parameter WIDTH = 8, 
    parameter SHIFT_BITS = 1
) 
(
    input [WIDTH - 1 : 0] D1,
    input [WIDTH - 1 : 0] D2,

    output [WIDTH + SHIFT_BITS - 1 : 0] P,
    output [WIDTH + SHIFT_BITS - 1 : 0] Q
);
    assign P [SHIFT_BITS - 1 : 0] = D1 [SHIFT_BITS - 1 : 0];
    assign Q [SHIFT_BITS - 1 : 0] = 0;

    wire [WIDTH + SHIFT_BITS - 1 : 0] D2_Shifted  = D2 << SHIFT_BITS;
    assign P [WIDTH + SHIFT_BITS - 1 : WIDTH] = D2_Shifted [WIDTH + SHIFT_BITS - 1 : WIDTH];
    assign Q [WIDTH + SHIFT_BITS - 1 : WIDTH] = 0;

    assign P[WIDTH - 1 : SHIFT_BITS] = D1[WIDTH - 1 : SHIFT_BITS] | D2_Shifted[WIDTH - 1 : SHIFT_BITS];
    assign Q[WIDTH - 1 : SHIFT_BITS] = D1[WIDTH - 1 : SHIFT_BITS] & D2_Shifted[WIDTH - 1 : SHIFT_BITS];
endmodule

module Error_Configurable_Full_Adder_Mul
(
    input Er,
    input A,
    input B, 
    input Cin,

    output Sum, 
    output Cout
);
    assign Sum = ~(Er && (A ^ B) && Cin) && ((A ^ B) || Cin);
    assign Cout = (Er && B && Cin) || ((B || Cin) && A);
endmodule

module Full_Adder_Mul 
(
    input A,
    input B,
    input Cin,

    output Sum,
    output Cout
);
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A && B) || (A && Cin) || (B && Cin); 
endmodule

module Half_Adder_Mul 
(
    input A,
    input B, 
    output Sum, 
    output Cout
);
    assign Sum = A ^ B;
    assign Cout = A & B;
endmodule

module ATC_4 
(
    input [8 : 0] P1,
    input [8 : 0] P2,
    input [8 : 0] P3,
    input [8 : 0] P4,

    output [10 : 0] P5,
    output [10 : 0] P6,

    output [14 : 0] V2
);

    wire [10 : 0] Q5;
    wire [10 : 0] Q6;

    iCAC #(9, 2) iCAC_5 (P1, P2 , P5, Q5);
    iCAC #(9, 2) iCAC_6 (P3, P4 , P6, Q6);

    assign V2 = Q5 | Q6 << 4;
endmodule

module ATC_8 
(
    input [7 : 0] PP_1,
    input [7 : 0] PP_2,
    input [7 : 0] PP_3,
    input [7 : 0] PP_4,
    input [7 : 0] PP_5,
    input [7 : 0] PP_6,
    input [7 : 0] PP_7,
    input [7 : 0] PP_8,

    output [8 : 0] P1,
    output [8 : 0] P2,
    output [8 : 0] P3,
    output [8 : 0] P4,

    output [14 : 0] V1
);

    wire [8 : 0] Q1;
    wire [8 : 0] Q2;
    wire [8 : 0] Q3;
    wire [8 : 0] Q4;

    iCAC #(8, 1) iCAC_1 (PP_1, PP_2, P1, Q1);
    iCAC #(8, 1) iCAC_2 (PP_3, PP_4, P2, Q2);
    iCAC #(8, 1) iCAC_3 (PP_5, PP_6, P3, Q3);
    iCAC #(8, 1) iCAC_4 (PP_7, PP_8, P4, Q4);

    assign V1 = Q1 | Q2 << 2 | Q3 << 4 | Q4 << 6;
endmodule

// --------------------------------------------------------------------------------------------------
// *** End of multiplier module definition ***


module Divider_Unit
#(
    parameter GENERATE_CIRCUIT_1 = 1,
    parameter GENERATE_CIRCUIT_2 = 0,
    parameter GENERATE_CIRCUIT_3 = 0,
    parameter GENERATE_CIRCUIT_4 = 0
)
(
    input wire clk, 

    input wire [ 6 : 0] opcode, 
    input wire [ 6 : 0] funct7, 
    input wire [ 2 : 0] funct3, 

    input wire [31 : 0] control_status_register, 

    input wire [31 : 0] rs1, 
    input wire [31 : 0] rs2, 

    output              divider_unit_busy,  
    output reg [31 : 0] divider_unit_output 
);

    reg  enable;

    reg  [31 : 0] operand_1; 
    reg  [31 : 0] operand_2;
    
    reg  [31 : 0] input_1;
    reg  [31 : 0] input_2;

    wire [ 7 : 0] divider_accuracy;
    wire [31 : 0] divider_input_1;   // Latched Module input 1
    wire [31 : 0] divider_input_2;   // Latched Module input 2
    
    wire [31 : 0] result;
    wire [31 : 0] remainder;

    reg  divider_0_enable;
    reg  divider_1_enable;
    reg  divider_2_enable;
    reg  divider_3_enable;

    wire [31 : 0] divider_0_result;
    wire [31 : 0] divider_1_result;
    wire [31 : 0] divider_2_result;
    wire [31 : 0] divider_3_result;

    wire [31 : 0] divider_0_remainder;
    wire [31 : 0] divider_1_remainder;
    wire [31 : 0] divider_2_remainder;
    wire [31 : 0] divider_3_remainder;

    wire divider_0_busy;
    wire divider_1_busy;
    wire divider_2_busy;
    wire divider_3_busy;

    reg reset_enable_signals = 0;
    reg [1 : 0] signal_state;
    reg [1 : 0] next_state;

    localparam signal_zero = 2'b00;
    localparam signal_high = 2'b01;
    localparam signal_low  = 2'b10;

    reg reset_controller_enable;
    reg state_machine_enable;

    always @(*) 
    begin
        operand_1 = rs1;
        operand_2 = rs2;
        if (!reset_enable_signals)
        begin
            case ({funct7, funct3, opcode})
                {`MULDIV, `DIV, `OP} : begin
                    input_1 = operand_1;
                    input_2 = $signed(operand_2);
                    divider_unit_output = result;
                    case (control_status_register[2 : 1])
                        2'b00:   begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b01:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b1; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b10:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b1; divider_3_enable = 1'b0; end
                        2'b11:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b1; end 
                        default: begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                    endcase
                end
                {`MULDIV, `DIVU, `OP} : begin
                    input_1 = operand_1;
                    input_2 = operand_2;
                    divider_unit_output = result;
                    case (control_status_register[2 : 1])
                        2'b00:   begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b01:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b1; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b10:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b1; divider_3_enable = 1'b0; end
                        2'b11:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b1; end 
                        default: begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                    endcase
                end
                {`MULDIV, `REM, `OP} : begin 
                    input_1 = operand_1;
                    input_2 = $signed(operand_2);
                    divider_unit_output = remainder;
                    case (control_status_register[2 : 1])
                        2'b00:   begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b01:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b1; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b10:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b1; divider_3_enable = 1'b0; end
                        2'b11:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b1; end 
                        default: begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                    endcase
                end
                {`MULDIV, `REMU, `OP} : begin
                    input_1 = operand_1;
                    input_2 = operand_2;
                    divider_unit_output = $signed(remainder);
                    case (control_status_register[2 : 1])
                        2'b00:   begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b01:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b1; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b10:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b1; divider_3_enable = 1'b0; end
                        2'b11:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b1; end 
                        default: begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                    endcase
                end
                default: 
                begin 
                    divider_unit_output = 32'bz; 
                    divider_0_enable = 1'b0; divider_1_enable = 1'b0;
                    divider_2_enable = 1'b0; divider_3_enable = 1'b0;
                end              
            endcase
        end else if (reset_enable_signals) 
        begin
            divider_0_enable = 1'b0; divider_1_enable = 1'b0;
            divider_2_enable = 1'b0; divider_3_enable = 1'b0;
        end
    end

    assign divider_unit_busy = (divider_0_enable | divider_1_enable | divider_2_enable | divider_3_enable);

    always @(divider_0_busy or divider_1_busy or divider_2_busy or divider_3_busy or reset_controller_enable) 
    begin 
        if (!divider_0_busy) begin state_machine_enable <= 1; end 
        else if (!divider_1_busy) begin state_machine_enable <= 1; end 
        else if (!divider_2_busy) begin state_machine_enable <= 1; end
        else if (!divider_3_busy) begin state_machine_enable <= 1; end
        else if (reset_controller_enable) begin state_machine_enable <= 0; end
    end

    always @(posedge clk or negedge state_machine_enable) 
    begin
        if (!state_machine_enable) signal_state <= signal_zero;
        else signal_state <= next_state;
    end

    always @(*) 
    begin
        case (signal_state)
            signal_zero:   
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals <= 0; next_state <= signal_high; reset_controller_enable <= 0; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals <= 0; next_state <= signal_low;  reset_controller_enable <= 0; end
                end
            signal_high:   
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals <= 1; next_state <= signal_low; reset_controller_enable <= 0; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 0; end 
                end
            signal_low:    
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 1; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 0; end
                end
            default:       
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 1; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals <= 0; next_state <= signal_low; reset_controller_enable <= 0; end
                end
        endcase
    end

    assign divider_0_enable_wire = (!reset_enable_signals) ? divider_0_enable : 0;
    assign divider_1_enable_wire = (!reset_enable_signals) ? divider_1_enable : 0; 
    assign divider_2_enable_wire = (!reset_enable_signals) ? divider_2_enable : 0; 
    assign divider_3_enable_wire = (!reset_enable_signals) ? divider_3_enable : 0;  

    // Assigning divider circuits' inputs
    reg circuits_input_enable = 0;
    wire enables_combine = (divider_0_enable | divider_1_enable | divider_2_enable | divider_3_enable);
    always @(posedge enables_combine) 
    begin circuits_input_enable = 1; end
    assign divider_input_1  = (circuits_input_enable) ? input_1 : 32'bz;
    assign divider_input_2  = (circuits_input_enable) ? input_2 : 32'bz;
    assign divider_accuracy = (circuits_input_enable) ? (control_status_register[10 : 3] | {8{~control_status_register[0]}}) : 8'bz;

    // Assigning divider circuits' results to top unit result
    assign result = (divider_0_enable) ? divider_0_result :
                    (divider_1_enable) ? divider_1_result :
                    (divider_2_enable) ? divider_2_result :
                    (divider_3_enable) ? divider_3_result : divider_0_result;
    
    // Assigning divider circuits' remainder results to top unit result
    assign remainder =  (divider_0_enable) ? divider_0_remainder :
                        (divider_1_enable) ? divider_1_remainder :
                        (divider_2_enable) ? divider_2_remainder :
                        (divider_3_enable) ? divider_3_remainder : divider_0_remainder;

    // *** Instantiate your divider here ***
    // Please instantiate your divider module according to the guidelines and naming conventions of phoeniX
    // ----------------------------------------------------------------------------------------------------
    generate 
        if (GENERATE_CIRCUIT_1)
        begin : Divider_1_Generate_Block
            // Circuit 1 (default) instantiation
            //----------------------------------
            test_div div
            (
                .clk(clk),
                .enable(divider_0_enable),
                .divider_input_1(divider_input_1),
                .divider_input_2(divider_input_2),
                .divider_0_result(divider_0_result),
                .divider_0_remainder(divider_0_remainder),
                .divider_0_busy(divider_0_busy)
            );
            //----------------------------------
            // End of Circuit 1 instantiation
        end
        if (GENERATE_CIRCUIT_2)
        begin : Divider_2_Generate_Block
            // Circuit 2 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 2 instantiation
        end
        if (GENERATE_CIRCUIT_3)
        begin : Divider_3_Generate_Block
            // Circuit 3 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 3 instantiation
        end
        if (GENERATE_CIRCUIT_4)
        begin : Divider_4_Generate_Block
            // Circuit 4 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 4 instantiation
        end
    endgenerate
    // ----------------------------------------------------------------------------------------------------
    // *** End of divider instantiation ***
endmodule

module test_div
(
    input wire clk,
    input wire enable,
    input wire [31 : 0] divider_input_1,
    input wire [31 : 0] divider_input_2,
    output reg [31 : 0] divider_0_result,
    output reg [31 : 0] divider_0_remainder,
    output reg divider_0_busy
);
    always @(posedge clk) 
    begin
        if (enable)
        begin 
            divider_0_busy = 1;
            repeat (8) @(posedge clk);
            divider_0_result    = divider_input_1 / divider_input_2;
            divider_0_remainder = divider_input_1 % divider_input_2;
            divider_0_busy = 0;
        end 
    end
endmodule
