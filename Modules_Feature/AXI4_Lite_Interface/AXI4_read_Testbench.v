`include "AXI4_read.v"

module AXI4_read_Testbench;

parameter ADDRESS_WIDTH = 2;

reg axi_clk = 1'b1;
reg resetn = 1'b0;

always #5 axi_clk = ~axi_clk;

// read address channel
reg [ADDRESS_WIDTH - 1 : 0] read_addr;
reg read_addr_valid;
wire read_addr_ready;

// read data channel
wire [31 : 0] read_data;
wire read_data_valid;
reg  read_data_ready;

// read response channel	
wire [ADDRESS_WIDTH - 1 : 0] read_resp;
reg read_resp_ready;
wire read_resp_valid;

// four test registers
reg  [31 : 0] memory [2**ADDRESS_WIDTH : 0];

reg [ADDRESS_WIDTH - 1  : 0] read_address;
reg [31 : 0] rdata_in;
reg read_enable;

AXI4_read #(.ADDRESS_WIDTH(ADDRESS_WIDTH)) uut
(
    .axi_clk(axi_clk),
    .resetn(resetn),

    .read_addr(read_addr),
    .read_addr_valid(read_addr_valid),
    .read_addr_ready(read_addr_ready),

    .read_data(read_data),
    .read_data_valid(read_data_valid),
    .read_data_ready(read_data_ready),

    .read_resp(read_resp),
    .read_resp_ready(read_resp_ready),
    .read_resp_valid(read_resp_valid),

    .data_in(rdata_in),
    .addr_in(read_address),
    .data_valid(read_enable)
);


integer i;
// read logic for a test memory
always @(posedge axi_clk)
begin
	if(resetn == 0)
	begin
		for(i = 0 ; i < 4 ; i = i + 1)
			memory[i] <= 0;
	end
	else if(read_enable)
		rdata_in <= memory[read_address];
end
    
initial begin
    $dumpfile("AXI4_read.vcd");
    $dumpvars(0, AXI4_read_Testbench);

    // Initialize signals
    write_addr = 2'b0;
    write_addr_valid = 0;
    write_data = 0;
    write_data_valid = 0;
    write_resp_ready = 0;
    // Deassert reset
    #10 resetn = 1'b1;
    // Wait for a few clock cycles
    #20;
    
end


endmodule