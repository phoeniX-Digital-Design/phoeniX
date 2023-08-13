module Memory_Interface 
(
  	input CLK,
  	input enable,
  	input memory_state,

  	input [3  : 0] frame_mask,
  	input [31 : 0] address,
  	inout [31 : 0] data
);

  	reg [31 : 0] data_in;
  	reg [31 : 0] data_out;

  	reg [7 : 0] memory [0 : 1023];



  	// Memory Interface Finite State Machine

  	reg [3 : 0] state;
	reg [3 : 0] next_state;

	localparam  STABLE    = 4'd0,
			  B_0001    = 4'd1,
			  B_0010    = 4'd2,
			  B_0100    = 4'd3,
			  B_1000    = 4'd4,
			  H_0011_1  = 4'd5,
			  H_0011_2  = 4'd6,
			  H_1100_1  = 4'd7,
			  H_1100_2  = 4'd8,
			  W_1111_1  = 4'd9,
			  W_1111_2  = 4'd10,
			  W_1111_3  = 4'd11,
			  W_1111_4  = 4'd12;

  	always @(posedge CLK) state <= next_state;
    


	// always @(*) begin

	//   if (enable) begin
	//     if (address <= 255) begin // Check if address is within memory range

	//       if (memory_state) begin         // Write operation

	//         case (frame_mask)
	//           // Store Byte 
	//           4'b0001 : memory[address + 3] = data;
	//           4'b0010 : memory[address + 2] = data;
	//           4'b0100 : memory[address + 1] = data;
	//           4'b1000 : memory[address + 0] = data;
	//           // Store Half-word 
	//           4'b0011 : begin
	//             memory[address + 2] = data;
	//           end
	//           4'b1100 : memory[address + 0] = data;
	//         endcase

			
	//       end 
	//       else if (!memory_state) begin   // Read operation



	//       end
	//     end
	//   end
	// end

endmodule