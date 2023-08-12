module Memory_Interface 
(
  input enable,
  input memory_state,

  input [3  : 0] frame_mask,
  input [31 : 0] address,
  inout [31 : 0] data
);

  reg [31 : 0] data_in;
  reg [31 : 0] data_out;

  reg [7 : 0] memory [0 : 1023];

  always @(*) begin
    
    if (enable) begin
      if (address <= 255) begin // Check if address is within memory range

        if (memory_state) begin         // Write operation

          case (frame_mask)
            // Store Byte 
            4'b0001 : memory[address + 3] = data;
            4'b0010 : memory[address + 2] = data;
            4'b0100 : memory[address + 1] = data;
            4'b1000 : memory[address + 0] = data;
            // Store Half-word 
            4'b0011 : begin
              memory[address + 2] = data;
            end
            4'b1100 : memory[address + 0] = data;
          endcase

          
        end 
        else if (!memory_state) begin   // Read operation



        end
      end
    end
  end

endmodule