`include "AXI4_write.v"

module AXI4_write_Testbench_2;

    parameter ADDRESS_WIDTH = 2;
    // Testbench inputs
    reg axi_clk;
    reg resetn;
    reg [ADDRESS_WIDTH - 1:0] write_addr;
    reg write_addr_valid;
    reg [31:0] write_data;
    reg write_data_valid;
    reg write_resp_ready;

    // Testbench outputs
    wire write_addr_ready;
    wire write_data_ready;
    wire [ADDRESS_WIDTH - 1:0] write_resp;
    wire write_resp_valid;
    wire [31:0] data_out;
    wire [ADDRESS_WIDTH - 1:0] addr_out;
    wire data_valid;

    // Instantiate the UUT
    AXI4_write #(.ADDRESS_WIDTH(ADDRESS_WIDTH)) uut (
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

    // Clock generation
    always #5 axi_clk = ~axi_clk;

    // Initialize signals
    initial begin
        axi_clk = 0;
        resetn = 0;
        write_addr = 0;
        write_addr_valid = 0;
        write_data = 0;
        write_data_valid = 0;
        write_resp_ready = 0;
        // Apply reset
        resetn = 0;
        #10;
        resetn = 1;
        #10;
        // Test scenario
        write_addr = 2'b00;
        write_addr_valid = 1;
        write_data = 32'hA5A5A5A5;
        write_data_valid = 1;
        write_resp_ready = 1;
        #20;
        write_addr_valid = 0;
        write_data_valid = 0;
        #20;
        // Display outputs
        $display("data_out = %h", data_out);
        $display("addr_out = %h", addr_out);
        $display("data_valid = %b", data_valid);
        // Finish simulation
        $finish;
    end

endmodule