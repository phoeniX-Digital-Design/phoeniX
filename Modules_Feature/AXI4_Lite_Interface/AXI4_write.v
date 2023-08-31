module AXI4_write #(parameter ADDRESS_WIDTH = 2)
(
	input axi_clk,
	input resetn,   //axi is reset low

	// write address channel
	input  [ADDRESS_WIDTH -  1 : 0] write_addr,
	input  write_addr_valid,
	output reg write_addr_ready,

	// write data channel
	input  [31 : 0] write_data,
	input  write_data_valid,
	output reg write_data_ready,

	// write response channel	
	output [ADDRESS_WIDTH - 1 : 0] write_resp,
	input  write_resp_ready,
	output reg write_resp_valid,
	
	output [31 : 0] data_out,                   // data output to external logic
	output [ADDRESS_WIDTH - 1 : 0] addr_out,    // address output to external logic
	output data_valid		                    // signal indicating output data and address are valid
);

	reg addr_done;
	reg data_done;

	// flip flops for latching data
	reg [31 : 0] data_latch;
	reg [ADDRESS_WIDTH - 1 : 0]  addr_latch;

	assign data_out = data_latch;
	assign addr_out = addr_latch;

	assign data_valid = data_done & addr_done;

	assign write_resp = {ADDRESS_WIDTH{1'b0}}; // always indicate OKAY status for writes

	// write address handshake
	always @(posedge axi_clk)
	begin
		if(~resetn | (write_addr_valid & write_addr_ready) )
			write_addr_ready <= 0;
		else if(~write_addr_ready & write_addr_valid)
			write_addr_ready <= 1;
	end

	// write data handshake
	always @(posedge axi_clk)
	begin
		if(~resetn | (write_data_valid & write_data_ready) )
			write_data_ready <= 0;
		else if(~write_data_ready & write_data_valid)
			write_data_ready <= 1;
	end

	// keep track of which handshakes completed
	always @(posedge axi_clk)
	begin
		if(resetn == 0 || (addr_done & data_done) ) // reset or both phases done
		begin
			addr_done <= 0;
			data_done <= 0;
		end
		else
		begin	
			if(write_addr_valid & write_addr_ready) // look for addr handshake
				addr_done <= 1;
		
			if(write_data_valid & write_data_ready) // look for data handshake
				data_done <= 1;	
		end
	end

	// latching logic
	always @(posedge axi_clk)
	begin
		if(resetn == 0) // reset values
		begin
			data_latch <= 32'd0;
			addr_latch <= {ADDRESS_WIDTH{1'b0}};
		end
		else
		begin
			if(write_data_valid & write_data_ready) // look for data handshake
				data_latch <= write_data;
			
			if(write_addr_valid & write_addr_ready) // look for address handshake
				addr_latch <= write_addr;
		end
	end

	// write response logic
	always @(posedge axi_clk)
	begin	
		if(resetn == 0 | (write_resp_valid & write_resp_ready))
			write_resp_valid <= 0;
		else if(~write_resp_valid & (data_done & addr_done))
			write_resp_valid <= 1;	
	end

endmodule