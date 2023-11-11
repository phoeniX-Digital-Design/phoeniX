`include "Defines.vh"
`include "Fetch_Unit.v"
`include "Instruction_Decoder.v"
`include "Immediate_Generator.v"
`include "Register_File.v"
`include "Arithmetic_Logic_Unit___.v"
`include "Jump_Branch_Unit.v"
`include "Address_Generator.v"
`include "Load_Store_Unit.v"
`include "Hazard_Forward_Unit.v"
`include "Control_Status_Unit.v"
`include "Control_Status_Register_File.v"
`include "Divider_Unit.v"
`include "Multiplier_Unit.v"

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

module phoeniX 
#(
    parameter RESET_ADDRESS = 32'hFFFFFFFC,
    parameter M_EXTENSION   = 1'b0,
    parameter E_EXTENSION   = 1'b0
) 
(
    input clk,
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
    wire [31 : 0] next_pc_fetch_wire;
    
    // --------------------------------
    // Reg Declarations for Fetch Stage
    // --------------------------------
    reg [31 : 0] pc_fetch_reg;

    // ------------------------
    // Fetch Unit Instantiation
    // ------------------------
    Fetch_Unit fetch_unit
    (
        .enable(!reset && !(|stall_condition[1 : 3])),              
        .pc(pc_fetch_reg),
        .jump_branch_address(address_execute_wire),
        .jump_branch_enable(jump_branch_enable_execute_wire),
        .next_pc(next_pc_fetch_wire),

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
            pc_fetch_reg <= RESET_ADDRESS;
        else if (!(|stall_condition[1 : 3]))
            pc_fetch_reg <= next_pc_fetch_wire; 
    end
    
    // --------------------------------------
    // Register Declarations for Decode Stage
    // --------------------------------------
    reg [31 : 0] instruction_decode_reg;
    reg [31 : 0] pc_decode_reg; 
    reg [31 : 0] next_pc_decode_reg;

    ////////////////////////////////////////
    //     FETCH TO DECODE TRANSITION     //
    ////////////////////////////////////////
    always @(posedge clk) 
    begin
        if (jump_branch_enable_execute_wire)
            instruction_decode_reg <= `NOP;

        else if (!(|stall_condition[1 : 3]))
        begin
            pc_decode_reg <= pc_fetch_reg;
            next_pc_decode_reg <= next_pc_fetch_wire;
            instruction_decode_reg <= instruction_memory_interface_data;
        end    
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
    wire [11 : 0] csr_index_decode_wire;

    wire [31 : 0] immediate_decode_wire;
    wire read_enable_1_decode_wire;
    wire read_enable_2_decode_wire;
    wire write_enable_decode_wire;

    wire read_enable_csr_decode_wire;
    wire write_enable_csr_decode_wire;

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
        .csr_index(csr_index_decode_wire),
        .read_enable_1(read_enable_1_decode_wire),
        .read_enable_2(read_enable_2_decode_wire),
        .write_enable(write_enable_decode_wire),
        .read_enable_csr(read_enable_csr_decode_wire),
        .write_enable_csr(write_enable_csr_decode_wire)
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
    wire [31 : 0] csr_data_decode_wire;

    // -----------------------------------------------
    // Wire Declaration for inputs to source bus 1 & 2
    // ----------------------------------------------- 
    wire [31 : 0] rs1_decode_wire;
    wire [31 : 0] rs2_decode_wire;

    // -----------------------------------------------------------------------------------
    // assign inputs to source bus 1 & 2  --> to be selected between RF source and FW data
    // -----------------------------------------------------------------------------------
    assign rs1_decode_wire = FW_enable_1 ? FW_source_1 : RF_source_1;
    assign rs2_decode_wire = FW_enable_2 ? FW_source_2 : RF_source_2;
    
    // ----------------------------------
    // Reg Declarations for Execute Stage
    // ----------------------------------
    reg [31 : 0] pc_execute_reg;
    reg [31 : 0] next_pc_execute_reg;

    reg [ 6 : 0] opcode_execute_reg;
    reg [ 2 : 0] funct3_execute_reg;
    reg [ 6 : 0] funct7_execute_reg;
    reg [11 : 0] funct12_execute_reg;

    reg [31 : 0] immediate_execute_reg;
    reg [ 2 : 0] instruction_type_execute_reg;
    reg [ 4 : 0] write_index_execute_reg;
    reg [ 4 : 0] read_index_1_execute_reg;
    reg [11 : 0] csr_index_execute_reg;

    reg write_enable_execute_reg;
    reg write_enable_csr_execute_reg;
    
    reg [31 : 0] rs1_execute_reg;
    reg [31 : 0] rs2_execute_reg;
    reg [31 : 0] csr_data_execute_reg;

    ////////////////////////////////////////
    //    DECODE TO EXECUTE TRANSITION    //
    ////////////////////////////////////////
    always @(posedge (clk)) 
    begin
        if (jump_branch_enable_execute_wire || stall_condition[2])
        begin
            write_enable_execute_reg <= 1'b0;  

            opcode_execute_reg <= `NOP_opcode;
            funct3_execute_reg <= `NOP_funct3;
            funct7_execute_reg <= `NOP_funct7;
            funct12_execute_reg <= `NOP_funct12;

            immediate_execute_reg <= `NOP_immediate;
            instruction_type_execute_reg <= `NOP_instruction_type;
            write_index_execute_reg <= `NOP_write_index;
        end

        else if (!(|stall_condition[1 : 3]))
        begin
            pc_execute_reg <= pc_decode_reg;
            next_pc_execute_reg <= next_pc_decode_reg;
            write_enable_execute_reg <= write_enable_decode_wire;
            
            opcode_execute_reg <= opcode_decode_wire;
            funct3_execute_reg <= funct3_decode_wire;
            funct7_execute_reg <= funct7_decode_wire;
            funct12_execute_reg <= funct12_decode_wire;

            immediate_execute_reg <= immediate_decode_wire; 
            instruction_type_execute_reg <= instruction_type_decode_wire;
            write_index_execute_reg <= write_index_decode_wire;
        
            rs1_execute_reg <= rs1_decode_wire;
            rs2_execute_reg <= rs2_decode_wire;

            write_enable_csr_execute_reg <= write_enable_csr_decode_wire;
            csr_index_execute_reg <= csr_index_decode_wire;
            csr_data_execute_reg <= csr_data_decode_wire;
            read_index_1_execute_reg <= read_index_1_decode_wire;
        end
    end

    // ------------------------------------
    // Wire Declaration for Execution Units
    // ------------------------------------
    wire [31 : 0] alu_output_execute_wire;
    wire [31 : 0] mul_output_execute_wire;
    wire [31 : 0] div_output_execute_wire;

    wire mul_busy_execute_wire;
    wire div_busy_execute_wire;

    wire [31 : 0] address_execute_wire;
    wire jump_branch_enable_execute_wire;

    wire [31 : 0] csr_rd_execute_wire;
    wire [31 : 0] csr_data_out_execute_wire;

    // -----------------------------------
    // Arithmetic Logic Unit Instantiation
    // -----------------------------------
    Arithmetic_Logic_Unit arithmetic_logic_unit
    (
        .opcode(opcode_execute_reg),
        .funct3(funct3_execute_reg),
        .funct7(funct7_execute_reg),
        .accuracy_control(control_status_register_file.alu_csr),    
        .rs1(rs1_execute_reg),
        .rs2(rs2_execute_reg),
        .immediate(immediate_execute_reg),
        .alu_output(alu_output_execute_wire)
    );

    // -------------------------------------
    // Multiplier/Divider Unit Instantiation
    // -------------------------------------
    generate if (M_EXTENSION)
    begin
        Multiplier_Unit multiplier_unit
        (
            .clk(clk),
            .opcode(opcode_execute_reg),
            .funct3(funct3_execute_reg),
            .funct7(funct7_execute_reg),
            .accuracy_control(control_status_register_file.mul_csr),    
            .rs1(rs1_execute_reg),
            .rs2(rs2_execute_reg),
            .mul_busy(mul_busy_execute_wire),
            .mul_output(mul_output_execute_wire)
        );

        Divider_Unit divider_unit
        (
            .clk(clk),
            .opcode(opcode_execute_reg),
            .funct3(funct3_execute_reg),
            .funct7(funct7_execute_reg),
            .accuracy_control(control_status_register_file.div_csr),    
            .rs1(rs1_execute_reg),
            .rs2(rs2_execute_reg),
            .div_unit_busy(div_busy_execute_wire),
            .div_output(div_output_execute_wire)
        );
    end
    endgenerate

    // ------------------------------------
    // Address Generator Unit Instantiation
    // ------------------------------------
    Address_Generator address_generator
    (
        .opcode(opcode_execute_reg),
        .rs1(rs1_execute_reg),
        .pc(pc_execute_reg),
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
        .rs1(rs1_execute_reg),
        .rs2(rs2_execute_reg),
        .jump_branch_enable(jump_branch_enable_execute_wire)
    );

    // ---------------------------------
    // Control Status Unit Instantiation
    // ---------------------------------
    Control_Status_Unit control_status_unit
    (
        .opcode(opcode_execute_reg),
        .funct3(funct3_execute_reg),

        .CSR_in(csr_data_execute_reg),
        .rs1(rs1_execute_reg),
        .unsigned_immediate(read_index_1_execute_reg),

        .rd(csr_rd_execute_wire),
        .CSR_out(csr_data_out_execute_wire)
    );

    // ----------------------------------------
    // Reg Declaration for result of execution
    // ----------------------------------------
    reg [31 : 0] result_execute_reg;

    // ----------------------------------------------------------
    //  Assigning result to alu output / mul output / div output
    // ----------------------------------------------------------
    always @(*) 
    begin
        case ({funct7_execute_reg, funct3_execute_reg, opcode_execute_reg})
            {`MULDIV, `MUL,    `OP} : result_execute_reg = mul_output_execute_wire;
            {`MULDIV, `MULH,   `OP} : result_execute_reg = mul_output_execute_wire;
            {`MULDIV, `MULHSU, `OP} : result_execute_reg = mul_output_execute_wire;
            {`MULDIV, `MULHU,  `OP} : result_execute_reg = mul_output_execute_wire;

            {`MULDIV, `DIV,    `OP} : result_execute_reg = div_output_execute_wire;
            {`MULDIV, `DIVU,   `OP} : result_execute_reg = div_output_execute_wire;
            {`MULDIV, `REM,    `OP} : result_execute_reg = div_output_execute_wire;
            {`MULDIV, `REMU,   `OP} : result_execute_reg = div_output_execute_wire;

            default: result_execute_reg = alu_output_execute_wire;    
        endcase 
    end

    // --------------------------------
    // Reg Declarations for Memory Stage
    // --------------------------------
    reg [31 : 0] pc_memory_reg;
    reg [31 : 0] next_pc_memory_reg;

    reg [ 6 : 0] opcode_memory_reg;
    reg [ 2 : 0] funct3_memory_reg;
    reg [ 6 : 0] funct7_memory_reg;
    reg [11 : 0] funct12_memory_reg;

    reg [31 : 0] immediate_memory_reg;
    reg [ 2 : 0] instruction_type_memory_reg;
    reg [ 4 : 0] write_index_memory_reg;
    reg write_enable_memory_reg;

    reg [31 : 0] address_memory_reg;
    reg [31 : 0] rs2_memory_reg;
    reg [31 : 0] result_memory_reg;

    reg jump_branch_enable_memory_reg;

    ////////////////////////////////////////
    //    EXECUTE TO MEMORY TRANSITION    //
    ////////////////////////////////////////
    always @(posedge clk) 
    begin
        if (stall_condition[1])
        begin
            write_enable_memory_reg <= 1'b0;  

            opcode_memory_reg <= `NOP_opcode;
            funct3_memory_reg <= `NOP_funct3;
            funct7_memory_reg <= `NOP_funct7;
            funct12_memory_reg <= `NOP_funct12;

            immediate_memory_reg <= `NOP_immediate;
            instruction_type_memory_reg <= `NOP_instruction_type;
            write_index_memory_reg <= `NOP_write_index;            
        end

        else if (!(|stall_condition[1 : 3]))
        begin
            pc_memory_reg <= pc_execute_reg;
            next_pc_memory_reg <= next_pc_execute_reg;

            opcode_memory_reg <= opcode_execute_reg;
            funct3_memory_reg <= funct3_execute_reg;
            funct7_memory_reg <= funct7_execute_reg;
            funct12_memory_reg <= funct12_execute_reg;

            immediate_memory_reg <= immediate_execute_reg;
            instruction_type_memory_reg <= instruction_type_execute_reg;
            write_index_memory_reg <= write_index_execute_reg;
            write_enable_memory_reg <= write_enable_execute_reg;    

            address_memory_reg <= address_execute_wire;
            rs2_memory_reg <= rs2_execute_reg;
            result_memory_reg <= result_execute_reg;

            result_memory_reg <= result_execute_reg;
            jump_branch_enable_memory_reg <= jump_branch_enable_execute_wire;
        end
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
        .store_data(rs2_memory_reg),
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
    reg [31 : 0] pc_writeback_reg;
    reg [31 : 0] next_pc_writeback_reg;

    reg [ 6 : 0] opcode_writeback_reg;
    reg [ 2 : 0] funct3_writeback_reg;
    reg [ 6 : 0] funct7_writeback_reg;
    reg [11 : 0] funct12_writeback_reg;

    reg [31 : 0] address_writeback_reg;
    reg [31 : 0] immediate_writeback_reg;
    reg [ 2 : 0] instruction_type_writeback_reg;
    reg [ 4 : 0] write_index_writeback_reg;
    reg write_enable_writeback_reg;

    reg [31 : 0] load_data_writeback_reg;
    reg [31 : 0] result_writeback_reg;

    ////////////////////////////////////////
    //   MEMORY TO WRITEBACK TRANSITION   //
    ////////////////////////////////////////
    always @(posedge clk) 
    begin
        if (stall_condition[3])
        begin
            write_enable_writeback_reg <= 1'b0;  

            opcode_writeback_reg <= `NOP_opcode;
            funct3_writeback_reg <= `NOP_funct3;
            funct7_writeback_reg <= `NOP_funct7;
            funct12_writeback_reg <= `NOP_funct12;

            immediate_writeback_reg <= `NOP_immediate;
            instruction_type_writeback_reg <= `NOP_instruction_type;
            write_index_writeback_reg <= `NOP_write_index; 
        end

        if (!(|stall_condition[1 : 3]))
        begin
            pc_writeback_reg <= pc_memory_reg;
            next_pc_writeback_reg <= next_pc_memory_reg;
            
            opcode_writeback_reg <= opcode_memory_reg;
            funct3_writeback_reg <= funct3_memory_reg;
            funct7_writeback_reg <= funct7_memory_reg;
            funct12_writeback_reg <= funct12_memory_reg;

            address_writeback_reg <= address_memory_reg;
            immediate_writeback_reg <= immediate_memory_reg;
            instruction_type_writeback_reg <= instruction_type_memory_reg;
            write_index_writeback_reg <= write_index_memory_reg;
            write_enable_writeback_reg <= write_enable_memory_reg; 

            load_data_writeback_reg <= load_data_memory_wire;  
            result_writeback_reg <= result_memory_reg; 
        end
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
            `JAL    : write_data_writeback_reg = next_pc_writeback_reg;
            `JALR   : write_data_writeback_reg = next_pc_writeback_reg;
            `AUIPC  : write_data_writeback_reg = address_writeback_reg;
            `LOAD   : write_data_writeback_reg = load_data_writeback_reg;
            `LUI    : write_data_writeback_reg = immediate_writeback_reg;
            default : write_data_writeback_reg = 32'bz;
        endcase
    end
    
    //////////////////////////////////////
    //     Hazard Detection Units       //
    //////////////////////////////////////
    Hazard_Forward_Unit hazard_forward_unit_source_1
    (
        .source_index(read_index_1_decode_wire),
        
        .destination_index_1(write_index_execute_reg),
        .destination_index_2(write_index_memory_reg),
        .destination_index_3(write_index_writeback_reg),

        .data_1(opcode_execute_reg == `LUI ? immediate_execute_reg : result_execute_reg),
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

        .data_1(opcode_execute_reg == `LUI ? immediate_execute_reg : result_execute_reg),
        .data_2(opcode_memory_reg == `LOAD ? load_data_memory_wire : result_memory_reg),
        .data_3(write_data_writeback_reg),

        .enable_1(write_enable_execute_reg),
        .enable_2(write_enable_memory_reg),
        .enable_3(write_enable_writeback_reg),

        .forward_enable(FW_enable_2),
        .forward_data(FW_source_2)
    );

    ////////////////////////////////////
    //          Bubble Unit           //
    ////////////////////////////////////    

    reg [1 : 3] stall_condition;
    /*
        1 -> Stall Condition 1 corresponds to instructions with multi-cycle execution
        1 -> Stall Condition 2 corresponds to instructions with multi-cycle memory access
        3 -> Stall Condition 3 corresponds to instructions with dependencies on previous instructions whose values are not available in the pipeline
    */

    always @(*) 
    begin
        if (mul_busy_execute_wire || div_busy_execute_wire)
        begin
            stall_condition[1] = 1'b1;
        end
        else stall_condition[1] = 1'b0;
        
        if  (opcode_execute_reg == `LOAD & write_enable_execute_reg &
            (((write_index_execute_reg == read_index_1_decode_wire) & read_enable_1_decode_wire)  || 
             ((write_index_execute_reg == read_index_2_decode_wire) & read_enable_2_decode_wire))) 
        begin
            stall_condition[2] = 1'b1;
        end   
        else stall_condition[2] = 1'b0;

        stall_condition[3] = 1'b0;
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

        .read_enable_1(read_enable_1_decode_wire),
        .read_enable_2(read_enable_2_decode_wire),
        .write_enable(write_enable_writeback_reg),

        .read_index_1(read_index_1_decode_wire),
        .read_index_2(read_index_2_decode_wire),
        .write_index(write_index_writeback_reg),

        .write_data(write_data_writeback_reg),
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

        .read_enable_csr(read_enable_csr_decode_wire),
        .write_enable_csr(write_enable_csr_execute_reg),

        .csr_read_index(csr_index_decode_wire),
        .csr_write_index(csr_index_execute_reg),

        .csr_write_data(csr_data_out_execute_wire),
        .csr_read_data(csr_data_decode_wire)
    );
endmodule