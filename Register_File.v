module Register_File
(
    input CLK,

    input wire read_enable_1,
    input wire read_enable_2,
    input wire write_enable,
    
    input wire [4 : 0] read_index_1,
    input wire [4 : 0] read_index_2,
    input wire [4 : 0] write_index,

    input wire [31 : 0] write_data,

    output reg [31 : 0] read_data_1,
    output reg [31 : 0] read_data_2

);

	reg [31 : 0] Registers [0 : 31];      

    integer i;    	
    initial
    begin
        for (i = 0 ; i < 32 ; i = i + 1)
            Registers[i] = 32'b0;

    end
	
    always @(posedge CLK)
    begin
        if (write_enable == 1'b1 && write_index != 0)
        begin
            Registers[write_index] <= write_data;
        end

        if (read_enable_1 == 1'b1)
            read_data_1 <= Registers[read_index_1];
        else
            read_data_1 <= 32'bz;

        if (read_enable_2 == 1'b1)
            read_data_2 <= Registers[read_index_2];
        else
            read_data_2 <= 32'bz;
    end
    
endmodule