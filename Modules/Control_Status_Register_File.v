//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Control Status Register File Module
//  Copyright 2024 Iran University of Science and Technology. <iustCompOrg@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

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