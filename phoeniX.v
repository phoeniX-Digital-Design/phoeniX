`include "Defines.v"
`include "Fetch_Unit.v"
`include "Instruction_Decoder.v"
`include "Immediate_Generator.v"
`include "Register_File.v"
`include "Arithmetic_Logic_Unit.v"
`include "Jump_Branch_Unit.v"
`include "Address_Generator.v"
`include "Load_Store_Unit.v"
`include "Hazard_Forward_Unit.v"
`include "Control_Status_Unit.v"
`include "Control_Status_Register_File.v"
`include "Divider_Unit.v"
`include "Multiplier_Unit.v"

module phoeniX 
#(
    parameter RESET_ADDRESS = 32'h0000_0000,
    parameter M_EXTENSION   = 1'b0,
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

    wire [31 : 0] address_EX_wire;
    wire jump_branch_enable_EX_wire;

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
        .control_status_register(control_status_register_file.alucsr_reg),    
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
            .control_status_register(control_status_register_file.mulcsr_reg),    
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
            .control_status_register(control_status_register_file.divcsr_reg),    
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

    reg [1 : 2] stall_condition;
    /*
        1 -> Stall Condition 1 corresponds to instructions with multi-cycle execution
        2 -> Stall Condition 2 corresponds to instructions with dependencies on previous instructions whose values are not available in the pipeline
    */

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

        .read_enable_csr(read_enable_csr_FD_wire),
        .write_enable_csr(write_enable_csr_EX_reg),

        .csr_read_index(csr_index_FD_wire),
        .csr_write_index(csr_index_EX_reg),

        .csr_write_data(csr_data_out_EX_wire),
        .csr_read_data(csr_data_FD_wire)
    );

    ////////////////////////////////
    //    Performance Counters    //
    ////////////////////////////////

    // -------------
    // Cycle Counter
    // -------------

    always @(posedge clk) 
    begin
        if (reset)  control_status_register_file.mcycle_reg <= 32'b0;
        else        control_status_register_file.mcycle_reg <= control_status_register_file.mcycle_reg + 32'd1; 
    end

    // -------------------
    // Instruction Counter
    // -------------------

    always @(posedge clk) 
    begin
        if (reset)  control_status_register_file.minstret_reg <= 32'b0;
        else if (!(
            opcode_MW_reg       == `NOP_opcode  &
            funct3_MW_reg       == `NOP_funct3  &  
            funct7_MW_reg       == `NOP_funct7  & 
            funct12_MW_reg      == `NOP_funct12 &
            write_index_MW_reg  == `NOP_write_index    
        ))
                    control_status_register_file.minstret_reg <= control_status_register_file.minstret_reg + 32'b1;
    end
endmodule