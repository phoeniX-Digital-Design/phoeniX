module AXI4_read #(parameter ADDRESS_WIDTH = 2)
(
    input axi_clk,
    input resetn,    // AXI is reset low

    // Read address channel
    input [ADDRESS_WIDTH - 1 : 0] read_addr,
    input read_addr_valid,
    output reg read_addr_ready,

    // Read data channel
    output reg [31 : 0] read_data,
    output reg read_data_valid,
    input read_data_ready,

    // Read response channel
    output [1 : 0] read_resp,
    input read_resp_ready,
    output reg read_resp_valid,

    input [31 : 0] data_in,                     // Data input from external logic
    input [ADDRESS_WIDTH - 1 : 0] addr_in,      // Address input from external logic
    input data_valid                            // Signal indicating input data and address are valid
);

    reg addr_done;
    reg data_done;

    // Flip flops for latching data
    reg [31 : 0] data_latch;
    reg [ADDRESS_WIDTH - 1 : 0] addr_latch;

    always @(*) begin
        assign read_data = data_latch;
    end
    assign read_resp = {2'b0}; // Always indicate OKAY status for reads

    // Read address handshake
    always @(posedge axi_clk)
    begin
        if (~resetn | (read_addr_valid & read_addr_ready))
            read_addr_ready <= 0;
        else if (~read_addr_ready & read_addr_valid)
            read_addr_ready <= 1;
    end

    // Read data handshake
    always @(posedge axi_clk)
    begin
        if (~resetn | (read_data_valid & read_data_ready))
            read_data_valid <= 0;
        else if (~read_data_valid & read_data_ready)
            read_data_valid <= 1;
    end

    // Keep track of which handshakes completed
    always @(posedge axi_clk)
    begin
        if (resetn == 0 || (addr_done & data_done)) // Reset or both phases done
        begin
            addr_done <= 0;
            data_done <= 0;
        end
        else
        begin    
            if (read_addr_valid & read_addr_ready) // Look for address handshake
                addr_done <= 1;
            
            if (read_data_valid & read_data_ready) // Look for data handshake
                data_done <= 1;    
        end
    end

    // Latching logic
    always @(posedge axi_clk)
    begin
        if (resetn == 0) // Reset values
        begin
            data_latch <= 32'd0;
            addr_latch <= {ADDRESS_WIDTH{1'b0}};
        end
        else
        begin
            if (read_data_valid & read_data_ready) // Look for data handshake
                data_latch <= data_in;
            
            if (read_addr_valid & read_addr_ready) // Look for address handshake
                addr_latch <= read_addr;
        end
    end

    // Read response logic
    always @(posedge axi_clk)
    begin    
        if (resetn == 0 | (read_resp_valid & read_resp_ready))
            read_resp_valid <= 0;
        else if (~read_resp_valid & (data_done & addr_done))
            read_resp_valid <= 1;    
    end

endmodule