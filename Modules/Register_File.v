//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: 32x32 Register File Module
//  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

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