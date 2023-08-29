module Memory_Interface_Test 
(
    input wire [31 : 0] address,
    input wire [31 : 0] write_data,
    input wire write_enable,
    input wire read_enable,
    output reg [31 : 0] read_data
);

  reg [31 : 0] memory [0 : 31];

  always @(posedge read_enable or negedge write_enable) begin
    if (read_enable)
      read_data <= memory[address];
    else if (!write_enable)
      memory[address] <= write_data;
  end

endmodule