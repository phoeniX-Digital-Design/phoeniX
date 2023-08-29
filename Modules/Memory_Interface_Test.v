module Memory_Interface_Test 
(
    input [31 : 0] address,
    input [31 : 0] write_data,
    input write_enable,
    input read_enable,
    output reg [31 : 0] read_data
);

  reg [31 : 0] cache_memory [0 : 255]; // 1KB chache memory inside the interface module

  always @(posedge read_enable or negedge write_enable) begin
    if (read_enable)
      read_data <= cache_memory[address];
    else if (!write_enable)
      cache_memory[address] <= write_data;
  end

endmodule