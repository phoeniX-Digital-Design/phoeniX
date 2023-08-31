`include "AXI4_write.v"

module AXI4_write_Testbench;

parameter ADDRESS_WIDTH = 2;

reg axi_clk = 1'b1;
reg resetn = 1'b0;

always #5 axi_clk = ~axi_clk;

// write address channel
reg  [ADDRESS_WIDTH - 1 : 0] write_addr;
reg  write_addr_valid;
wire write_addr_ready;

// write data channel
reg  [31 : 0] write_data;
reg  write_data_valid;
wire write_data_ready;

// write response channel	
wire [ADDRESS_WIDTH - 1 : 0] write_resp;
reg  write_resp_ready;
wire write_resp_valid;

// four test registers
reg  [31 : 0] memory [2**ADDRESS_WIDTH : 0];
wire [ADDRESS_WIDTH - 1  : 0] write_address;
wire [31 : 0] rdata_in;
wire write_enable;

AXI4_write #(.ADDRESS_WIDTH(ADDRESS_WIDTH)) uut 
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

    // Here, we will write data to memory[0] and memory[1]
    // Set write address and data
    write_addr = 2'b00;
    write_data = 32'hA5A5A5A5;
    // Assert write address and data valid
    write_addr_valid = 1'b1;
    write_data_valid = 1'b1;

    // Wait for write address and data to be accepted
    repeat (10) @(posedge axi_clk);
    write_addr_valid = 1'b0;
    write_data_valid = 1'b0;

    // Wait for write response to be valid
    repeat (10) @(posedge axi_clk);

    // Check write response
    if (write_resp_valid) begin
        case (write_resp)
            2'b00: $display("Write transaction to memory[0] successful");
            2'b01: $display("Write transaction to memory[1] successful");
            default: $display("Write transaction failed");
        endcase
    end
    else begin
        $display("Write response not received");
    end

    // Repeat for another write transaction
    // Set write address and data
    write_addr = 2'b01;
    write_data = 32'h5A5A5A5A;

    // Assert write address and data valid
    write_addr_valid = 1'b1;
    write_data_valid = 1'b1;

    // Wait for write address and data to be accepted
    repeat (10) @(posedge axi_clk);
    write_addr_valid = 1'b0;
    write_data_valid = 1'b0;

    // Wait for write response to be valid
    repeat (10) @(posedge axi_clk);

    // Check write response
    if (write_resp_valid) begin
        case (write_resp)
            2'b00: $display("Write transaction to memory[0] successful");
            2'b01: $display("Write transaction to memory[1] successful");
            default: $display("Write transaction failed");
        endcase
    end
    else begin
        $display("Write response not received");
    end

    #10;
    $finish;
end

endmodule