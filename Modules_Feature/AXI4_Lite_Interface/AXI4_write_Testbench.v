`include "AXI4_write.v"

module AXI4_write_Testbench;

parameter ADDRESS_WIDTH = 2;

reg axi_clk = 1'b1;
reg reset = 1'b1;

// write address channel
reg [ADDRESS_WIDTH - 1 : 0] write_addr;
reg write_addr_valid;
wire write_addr_ready;

// write data channel
reg [31 : 0] write_data;
reg write_data_valid;
wire write_data_ready;

// write response channel	
wire [ADDRESS_WIDTH - 1 : 0] write_resp;
reg write_resp_ready;
wire write_resp_valid;

// four test registers
reg  [31 : 0] memory [2**ADDRESS_WIDTH : 0];
wire [ADDRESS_WIDTH - 1  : 0] write_address;
wire [31 : 0] rdata_in;
wire write_enable;


AXI4_write axi4_write
#(
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
)
(
    .axi_clk(axi_clk),
    .resetn(resetn),

    .write_addr(write_addr),
    .write_addr_valid(write_addr_valid),
    .write_addr_ready(write_addr_ready),
    
    .write_data(write_data),
    .write_data_valid(write_data_valid),
    .write_data_ready(write_data_ready),

    .write_resp(write_resp),
    .write_resp_ready(write_resp_ready),
    .write_resp_valid(write_resp_valid),

    .data_out(rdata_in),
    .addr_out(write_address),
    .data_valid(write_enable)
);

integer i;
// write logic for a test memory
always @(posedge axi_clk)
begin
	if(resetn == 0)
	begin
		for(i = 0 ; i < 4 ; i = i + 1)
			memory[i] <= 0;
	end
	else if(write_enable)
		memory[write_address] <= rdata_in;
end


initial begin
    $dumpfile("AXI4_write.vcd");
    $dumpvars(0, AXI4_write_Testbench);

    

end

endmodule