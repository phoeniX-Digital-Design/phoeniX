`include "..\\Memory_Interface.v"

module TB_Mem;

  reg clk;
  reg reset;
  reg enable;
  reg read_enable;
  reg write_enable;
  reg [15:0] address;
  reg [31:0] dataIn;
  wire [31:0] dataOut;
  
  wire [31 : 0] Data = uut.memory[2];

  Memory_Interface uut 
  (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .read_enable(read_enable),
    .write_enable(write_enable),
    .address(address),
    .dataIn(dataIn),
    .dataOut(dataOut)
  );

  // Clock generation
  always #1 clk = ~clk;
  
  initial begin

    // Reset
    clk = 1'b0;
    reset = 1'b1;
    enable = 1'b0;
    address = 16'b0;
    dataIn = 32'b0;

    // Wait for a few clock cycles
    #10;
    reset = 1'b0;

    // Write operation
    enable = 1'b1;
    write_enable = 1'b1;
    address = 16'b0000000000000010;
    dataIn = 32'b01010101010101010101010101010101;
    #10;

    // Read operation
    enable = 1'b1;
    read_enable = 1'b1;
    write_enable = 1'b0;
    address = 16'b0000000000000010;
    #10;

    $display ("Data = %b ", Data);
    $finish;

  end

endmodule