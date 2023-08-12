module Memory_Interface 
(
  input wire clk,
  input wire reset,
  input wire enable,
  input wire read_enable,
  input wire write_enable,
  input wire [31 : 0] address,
  input wire [31 : 0] data_in,
  output reg [31 : 0] data_out
);

  reg [31 : 0] memory [0 : 255];

  always @(posedge clk or posedge reset) begin
    
    if (reset) begin
      data_out <= 32'b0; // Reset data output to 0
    end 
    
    else if (enable) begin
      if (address <= 255) begin // Check if address is within memory range
        if (write_enable) begin 
          memory[address] <= data_in;  // Write operation
        end 
        else if (read_enable) begin 
          data_out <= memory[address]; // Read operation
        end
      end
    end
  end

endmodule