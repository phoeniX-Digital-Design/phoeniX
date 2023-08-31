module AXI4_read #(parameter ADDRESS_WIDTH = 2)
(
    input axi_clk,
    input resetn,    // AXI is reset low

    // read address channel
    input  [ADDRESS_WIDTH - 1 : 0] read_addr,
    input  read_addr_valid,
    output reg read_addr_ready,

    // read data channel
    input  [31 : 0] read_data,
    input  read_data_valid,
    output reg read_data_ready,

    // read response channel
    output [ADDRESS_WIDTH - 1 : 0] read_resp,
    input  read_resp_ready,
    output reg read_resp_valid,

    output  [31 : 0] data_out,                    // data outout from external logic
    output  [ADDRESS_WIDTH - 1 : 0] addr_out,     // address input from external logic
    output  data_valid                            // signal indicating input data and address are valid
);

    reg addr_done;
    reg data_done;

    assign data_valid = data_done & addr_done;

    // flip flops for latching data
    reg [31 : 0] data_latch;
    reg [ADDRESS_WIDTH - 1 : 0] addr_latch;

    assign data_out = data_latch;
	assign addr_out = addr_latch;

    
    assign read_resp = {2'b0}; // always indicate OKAY status for reads

    // read address handshake
    always @(posedge axi_clk)
    begin
        if (~resetn | (read_addr_valid & read_addr_ready))
            read_addr_ready <= 0;
        else if (~read_addr_ready & read_addr_valid)
            read_addr_ready <= 1;
    end

    // read data handshake
    always @(posedge axi_clk)
    begin
        if (~resetn | (read_data_valid & read_data_ready))
            read_data_ready <= 0;
        else if (read_data_valid & ~read_data_ready)
            read_data_ready <= 1;
    end

    // keep track of which handshakes completed
    always @(posedge axi_clk)
    begin
        if (resetn == 0 || (addr_done & data_done)) // reset or both phases done
        begin
            addr_done <= 0;
            data_done <= 0;
        end
        else
        begin    
            if (read_addr_valid & read_addr_ready) // look for address handshake
                addr_done <= 1;
            
            if (read_data_valid & read_data_ready) // look for data handshake
                data_done <= 1;    
        end
    end

    // latching logic
    always @(posedge axi_clk)
    begin
        if (resetn == 0) // reset values
        begin
            data_latch <= 32'd0;
            addr_latch <= {ADDRESS_WIDTH{1'b0}};
        end
        else
        begin
            if (read_data_valid & read_data_ready) // look for data handshake
                data_latch <= read_data;
            
            if (read_addr_valid & read_addr_ready) // look for address handshake
                addr_latch <= read_addr;
        end
    end

    // read response logic
    always @(posedge axi_clk)
    begin    
        if (resetn == 0 | (read_resp_valid & read_resp_ready))
            read_resp_valid <= 0;
        else if (~read_resp_valid & (data_done & addr_done))
            read_resp_valid <= 1;    
    end

endmodule