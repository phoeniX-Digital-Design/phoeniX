module Memory_Interface 
#(
    parameter DEPTH = 256
)
(
  	input CLK,
  	input enable,
  	input memory_state,

  	input [3  : 0] frame_mask,
  	input [31 : 0] address,

  	inout [31 : 0] data,
    output reg  memory_done
);

 	reg [7 : 0] Memory [0 : DEPTH - 1];
    // Memory must be replace with data bus
    reg [31 : 0] data_in;
    reg [7  : 0] data_bus; //?

    localparam  READ        = 1'b0,
                WRITE       = 1'b1;

  	// Memory Interface Finite State Machine
  	reg [3 : 0] state;
	reg [3 : 0] next_state;

	localparam  STABLE      = 4'd0,
                B_0001      = 4'd1,
                B_0010      = 4'd2,
                B_0100      = 4'd3,
                B_1000      = 4'd4,
                H_0011_1    = 4'd5,
                H_0011_2    = 4'd6,
                H_1100_1    = 4'd7,
                H_1100_2    = 4'd8,
                W_1111_1    = 4'd9,
                W_1111_2    = 4'd10,
                W_1111_3    = 4'd11,
                W_1111_4    = 4'd12,
                FINISH      = 4'd13;

  	always @(posedge CLK)
    begin
        if (enable)
            state <= next_state;
        else    
            state <= STABLE; 
    end

    always @(*)
    begin
        case (state)
            STABLE : begin
                memory_done <= 1'b0;
                data_in <= 32'bz;
                
                if (frame_mask == 4'b0000)  next_state <= STABLE;

                if (frame_mask == 4'b0001)  next_state <= B_0001;
                if (frame_mask == 4'b0010)  next_state <= B_0010;
                if (frame_mask == 4'b0100)  next_state <= B_0100;
                if (frame_mask == 4'b1000)  next_state <= B_1000;

                if (frame_mask == 4'b0011)  next_state <= H_0011_1;
                if (frame_mask == 4'b1100)  next_state <= H_1100_1;

                if (frame_mask == 4'b1111)  next_state <= W_1111_1;
            end
            // TBD changes are left in the comments:
            B_0001 : begin
                if (memory_state == READ)   data_in <= Memory[address + 3]; // data_in <= data [7 : 0]
                if (memory_state == WRITE)  Memory[address + 3] <= data;    // data [7 : 0] <= data_in
                next_state <= FINISH;
            end
            
            B_0010 : begin
                if (memory_state == READ)   data_in <= Memory[address + 2]; // data_in <= data [15 : 8]
                if (memory_state == WRITE)  Memory[address + 2] <= data;    // data [15 : 8] <= data_in
                next_state <= FINISH;
            end
            
            B_0100 : begin
                if (memory_state == READ)   data_in <= Memory[address + 1]; // data_in <= data [23 : 16]
                if (memory_state == WRITE)  Memory[address + 1] <= data;    // data [23 : 16] <= data_in
                next_state <= FINISH;
            end

            B_1000 : begin
                if (memory_state == READ)   data_in <= Memory[address + 0]; // data_in <= data [31 : 24]
                if (memory_state == WRITE)  Memory[address + 0] <= data;    // data [31 : 24] <= data_in
                next_state <= FINISH;
            end

            H_0011_1 : begin
                if (memory_state == READ)   data_in[15 : 8] <= Memory[address + 2]; // data_in[15 : 8] <= data [15 : 8]
                if (memory_state == WRITE)  Memory[address + 2] <= data[15 : 8];    // data [15 : 8] <= data_in[15 : 8]
                next_state <= H_0011_2;
            end

            H_0011_2 : begin
                if (memory_state == READ)   data_in[7 : 0] <= Memory[address + 3];  // data_in [7 : 0] <= data [7 : 0]
                if (memory_state == WRITE)  Memory[address + 3] <= data[7 : 0];     // data [7 : 0] <= data_in [7 : 0]  
                next_state <= FINISH;
            end

            H_1100_1 : begin
                if (memory_state == READ)   data_in[15 : 8] <= Memory[address + 0]; // data_in [15 : 8] <= data [31 : 24]
                if (memory_state == WRITE)  Memory[address + 0] <= data[15 : 8];    // data [31 : 24] <= data_in [15 : 8] 
                next_state <= H_1100_2;
            end

            H_1100_2 : begin
                if (memory_state == READ)   data_in[7 : 0] <= Memory[address + 1]; // data_in [7 : 0] <= data [23 : 16]
                if (memory_state == WRITE)  Memory[address + 1] <= data[7 : 0];    // data [23 : 16] <= data_in [7 : 0]
                next_state <= FINISH;
            end

            W_1111_1 : begin
                if (memory_state == READ)   data_in[31 : 24] <= Memory[address + 0];    // data_in [31 : 24] <= data [31 : 24]
                if (memory_state == WRITE)  Memory[address + 0] <= data[31 : 24];       // data [31 : 24] <= data_in [31 : 24]
                next_state <= W_1111_2;
            end

            W_1111_2 : begin
                if (memory_state == READ)   data_in[23 : 16] <= Memory[address + 1];    // data_in [23 : 16] <= data [23 : 16]
                if (memory_state == WRITE)  Memory[address + 1] <= data[23 : 16];       // data [23 : 16] <= data_in [23 : 16]
                next_state <= W_1111_3;
            end

            W_1111_3 : begin
                if (memory_state == READ)   data_in[15 : 8] <= Memory[address + 2];     // data_in [15 : 8] <= data [15 : 8]
                if (memory_state == WRITE)  Memory[address + 2] <= data[15 : 8];        // data [15 : 8] <= data_in [15 : 8]
                next_state <= W_1111_4;
            end

            W_1111_4 : begin
                if (memory_state == READ)   data_in[7 : 0] <= Memory[address + 3];      // data_in [7 : 0] <= data [7 : 0]
                if (memory_state == WRITE)  Memory[address + 3] <= data[7 : 0];         // data [7 : 0] <= data_in [7 : 0]
                next_state <= FINISH;
            end

            FINISH : begin
                memory_done <= 1'b1;
                next_state <= STABLE;
            end
        endcase
    end

    assign data = data_in;

endmodule