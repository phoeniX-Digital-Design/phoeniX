`include "AXI4_write.v"

module AXI4_write_Testbench;

parameter ADDRESS_WIDTH = 2;

reg axi_clk;
reg resetn;

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

wire [31 : 0] data_out;                     //data output to external logic
wire [ADDRESS_WIDTH - 1 : 0] addr_out;      // address output to external logic
wire data_valid;		                    // signal indicating output data and address are valid
    

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

    .data_out(data_out),
    .addr_out(addr_out),
    .data_valid(data_valid)
);

endmodule
