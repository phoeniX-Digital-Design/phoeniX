// AXI4 lite signals:
// axi_aclk     Input   Clock signal. 
// axi_aresetn  Input   Active-Low synchronous reset signal
// axi_awalid   Input   Write address valid. This signal indicates that the channel is signaling valid write address.
// axi_awready  Output  Write address ready. This signal indicates that the slave is ready to accept an address.
// axi_awaddr   Input   Write address. The write address gives the address of the transaction.
// axi_wvalid   Input   Write valid. This signal indicates that valid write data are available.
// axi_wready   Output  Write ready. This signal indicates that the slave can accept the write data.
// axi_wdata    Input   Write data.
// axi_bvalid   Output  Write response valid. This signal indicates that the channel is signaling a valid write response.
// axi_bready   Input   Write response ready. This signal indicates that the master can accept a write response.
// axi_bresp    Output  Write response. This signal indicate the status of the write transaction.
// axi_arvalid  Input   Read address valid. This signal indicates that the channel is signaling valid read address.
// axi_arready  Output  Read address ready. This signal indicates that the slave is ready to accept an address.
// axi_araddr   Input   Read address. The read address gives the address of the transaction.
// axi_rvalid   Output  Read valid. This signal indicates that the channel is signaling the required read data.
// axi_rready   Input   Read ready. This signal indicates that the master can accept the read data and response information.
// axi_rdata    Output  Read data.
// axi_rresp    Output  Read response. This signal indicate the status of the read transfer.
// Reference : https://docs.xilinx.com/r/en-US/pg211-50g-ethernet/AXI4-Lite-Interface-Ports

module AXI4_Lite_Interface 
(
	input  axi_clk, 
    input  resetn, // AXI is reset low

	output axi_awvalid,
	input  axi_awready,
	output [31 : 0] axi_awaddr,
	output [2  : 0] axi_awprot,

    // AXI4 Lite write logic signals
	output axi_wvalid,
	input  axi_wready,
	output [31 : 0] axi_wdata,
	output [3  : 0] axi_wstrb,

	input  axi_bvalid,
	output axi_bready,

    // AXI4 Lite write logic signals
	output axi_arvalid,
	input  axi_arready,
	output [31 : 0] axi_araddr,
	output [2  : 0] axi_arprot,

	input  axi_rvalid,
	output axi_rready,
	input  [31 : 0] axi_rdata,

	// Signals interacting with core
	input  valid,
	input  instr,
	output ready,
	input  [31 : 0] addr,
	input  [31 : 0] wdata,
	input  [3  : 0] wstrb,
	output [31 : 0] rdata
);
	reg ack_awvalid;
	reg ack_arvalid;
	reg ack_wvalid;
	reg response;

    // Write logic signal generation
	assign axi_awvalid = valid && |wstrb && !ack_awvalid;
	assign axi_awaddr = addr;
	assign axi_awprot = 0;
    assign axi_wvalid = valid && |wstrb && !ack_wvalid;
	assign axi_wdata = wdata;
	assign axi_wstrb = wstrb;
    // Read logic signal generation
	assign axi_arvalid = valid && !wstrb && !ack_arvalid;
	assign axi_araddr = addr;
	assign axi_arprot = instr ? 3'b100 : 3'b000;
	assign ready = axi_bvalid || axi_rvalid;
	assign axi_bready = valid && |wstrb;
	assign axi_rready = valid && !wstrb;
	assign rdata = axi_rdata;

	always @(posedge axi_clk) 
    begin
		if (!resetn) begin
			ack_awvalid <= 0;
		end else begin
			response <= valid && ready;
			if (axi_awready && axi_awvalid)
				ack_awvalid <= 1;
			if (axi_arready && axi_arvalid)
				ack_arvalid <= 1;
			if (axi_wready && axi_wvalid)
				ack_wvalid <= 1;
			if (response || !valid) 
            begin
				ack_awvalid <= 0;
				ack_arvalid <= 0;
				ack_wvalid <= 0;
			end
		end
	end

endmodule