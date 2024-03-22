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

module phoeniX_AXI4_Interface 
(
	input wire          clk, 
    input wire          reset,

	// AXI4-lite master memory interface

	output reg          axi_awvalid,
	input wire          axi_awready,
	output reg [31 : 0] axi_awaddr,
	output reg [ 2 : 0] axi_awprot,

	output reg          axi_wvalid,
	input wire          axi_wready,
	output reg [31 : 0] axi_wdata,
	output reg [ 3 : 0] axi_wstrb,

	input wire          axi_bvalid,
	output reg          axi_bready,

	output reg          axi_arvalid,
	input wire          axi_arready,
	output reg [31 : 0] axi_araddr,
	output reg [ 2 : 0] axi_arprot,

	input wire          axi_rvalid,
	output reg          axi_rready,
	input wire [31 : 0] axi_rdata,

	// Native phoeniX memory interface

	input wire          valid,
    //input wire instruction_memory_interface_state,
	input wire          instr,
    //input wire           instruction_memory_interface_enable,
    //input wire           data_memory_interface_enable
	output reg          ready,
	input wire [31 : 0] addr,
    //input wire  [31 : 0] instruction_memory_interface_address,
    //input wire  [31 : 0] data_memory_interface_address,
	input wire [31 : 0] wdata,
    //input wire [31 : 0] instruction_memory_interface_address,
    //input wire [31 : 0] data_memory_interface_address,

	input wire [ 3 : 0] wstrb,
    //input wire  [ 3 : 0] instruction_memory_interface_frame_mask
    //input wire  [ 3 : 0] data_memory_interface_frame_mask
	output reg [31 : 0] rdata

    /*
    //////////////////////////////////////////
    // Instruction Memory Interface Signals //
    //////////////////////////////////////////
    output reg          instruction_memory_interface_enable,
    output reg          instruction_memory_interface_state,
    output reg [31 : 0] instruction_memory_interface_address,
    output reg [ 3 : 0] instruction_memory_interface_frame_mask,
    input wire [31 : 0] instruction_memory_interface_data, 

    ///////////////////////////////////
    // Data Memory Interface Signals //
    ///////////////////////////////////
    output reg          data_memory_interface_enable,
    output reg          data_memory_interface_state,
    output reg [31 : 0] data_memory_interface_address,
    output reg [ 3 : 0] data_memory_interface_frame_mask,
    inout      [31 : 0] data_memory_interface_data
    */

);
	reg ack_awvalid;
	reg ack_arvalid;
	reg ack_wvalid;
	reg transfer_done;

    always @(*) 
    begin
    
        assign axi_awvalid = valid && |wstrb && !ack_awvalid; // axi_awvalid = instruction_memory_interface_enable && |instruction_memory_interface_frame_mask && !ack_awvalid;
        assign axi_awaddr  = addr;
        assign axi_awprot  = 0;

        assign axi_arvalid = valid && !wstrb && !ack_arvalid;
        assign axi_araddr  = addr;
        assign axi_arprot  = instr ? 3'b100 : 3'b000;

        assign axi_wvalid = valid && |wstrb && !ack_wvalid;
        assign axi_wdata  = wdata;
        assign axi_wstrb  = wstrb;

        assign ready      = axi_bvalid || axi_rvalid;
        assign axi_bready = valid && |wstrb;
        assign axi_rready = valid && !wstrb;
        assign rdata      = axi_rdata;
        
    end

	always @(posedge clk) 
    begin
		if (reset) begin
			ack_awvalid <= 0;
		end else begin
			transfer_done <= valid && ready;
			if (axi_awready && axi_awvalid)
				ack_awvalid <= 1;
			if (axi_arready && axi_arvalid)
				ack_arvalid <= 1;
			if (axi_wready && axi_wvalid)
				ack_wvalid <= 1;
			if (transfer_done || !valid) 
            begin
				ack_awvalid <= 0;
				ack_arvalid <= 0;
				ack_wvalid  <= 0;
			end
		end
	end

endmodule