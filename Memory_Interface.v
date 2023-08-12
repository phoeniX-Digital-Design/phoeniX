module Memory_Interface 
(
  input wire clk,
  input wire reset,
  input wire enable,
  input wire read_enable,
  input wire write_enable,
  input wire [31 : 0] address,
  input wire [31 : 0] dataIn,
  output reg [31 : 0] dataOut
);

  reg [31 : 0] memory [0 : 255];

  always @(posedge clk or posedge reset) begin
    
    if (reset) begin
      dataOut <= 32'b0; // Reset data output to 0
    end 
    
    else if (enable) begin
      if (address <= 255) begin // Check if address is within memory range
        if (write_enable) begin 
          memory[address] <= dataIn;  // Write operation
        end 
        else if (read_enable) begin 
          dataOut <= memory[address]; // Read operation
        end
      end
    end
  end

endmodule