module Memory_Interface_Test
#(
    parameter ADDRESS_WIDTH = 8
)
(
    input [31 : 0] address,
    input [31 : 0] write_data,

    input write_enable,
    input read_enable,

    output reg [31 : 0] read_data
);

    // 1KB chache memory inside the interface module
    reg [31 : 0] cache_memory [0 : 2 ** ADDRESS_WIDTH - 1]; 

    always @(posedge read_enable) begin
        if (read_enable)
        read_data <= cache_memory[address];
    end

    always @(posedge write_enable) begin
        if (write_enable)
        cache_memory[address] <= write_data;
    end

endmodule