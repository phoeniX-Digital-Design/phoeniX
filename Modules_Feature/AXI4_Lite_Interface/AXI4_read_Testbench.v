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
reg  read_data_valid;
wire read_data_ready;

// read response channel	
wire [ADDRESS_WIDTH - 1 : 0] read_resp;
reg  read_resp_ready;
wire read_resp_valid;

// four test registers
reg  [31 : 0] memory [2**ADDRESS_WIDTH : 0];

// always @(posedge axi_clk or negedge axi_clk) begin
//     memory[0] = 32'hF;
//     memory[1] = 32'hA;    
// end

wire [ADDRESS_WIDTH - 1  : 0] read_address;
reg  [31 : 0] rdata_in;
wire read_enable;

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

// read logic for a test memory
always @(posedge axi_clk)
begin
	if(resetn == 0)
	begin
		for(integer i = 0 ; i < 4 ; i = i + 1)
			memory[i] <= 0;
	end
	else if(read_enable)
		rdata_in <= memory[read_address];
end
    
initial begin
    $dumpfile("AXI4_read.vcd");
    $dumpvars(0, AXI4_read_Testbench);

    // Initialize signals
    memory[0] = 32'hA5A5A5A5;
    memory[1] = 32'hF;
    read_addr = 2'b0;
    read_addr_valid = 0;
    read_resp_ready = 0;
    read_data_valid = 0;
    // Deassert reset
    #10 resetn = 1'b1;
    // Wait for a few clock cycles
    #20;

    // Here, we will read data from memory[0]
    // Set read address
    read_addr = 2'b00;
    // Assert read address and data valid
    read_addr_valid = 1'b1;
    read_data_valid = 1'b1;

    // Wait for read address and data to be accepted
    repeat (10) @(posedge axi_clk);
    read_addr_valid = 1'b0;
    read_data_valid = 1'b0;

    // Wait for read response to be valid
    repeat (10) @(posedge axi_clk);

    // Check read response
    if (read_resp_valid) begin
        case (read_resp)
            2'b00: $display("Read transaction from memory[0] successful");
            2'b01: $display("Read transaction from memory[1] successful");
            default: $display("Read transaction failed");
        endcase
    end
    else begin
        $display("Read response not received");
    end

    // Repeat for another read transaction
    // Set read address and data
    read_addr = 2'b01;

    // Assert read address and data valid
    read_addr_valid = 1'b1;
    read_data_valid = 1'b1;

    // Wait for read address and data to be accepted
    repeat (10) @(posedge axi_clk);
    read_addr_valid = 1'b0;
    read_data_valid = 1'b0;

    // Wait for read response to be valid
    repeat (10) @(posedge axi_clk);

    // Check read response
    if (read_resp_valid) begin
        case (read_resp)
            2'b00: $display("Read transaction from memory[0] successful");
            2'b01: $display("Read transaction from memory[1] successful");
            default: $display("Read transaction failed");
        endcase
    end
    else begin
        $display("Read response not received");
    end

    // End simulation
    #10;
    $finish;
end

endmodule