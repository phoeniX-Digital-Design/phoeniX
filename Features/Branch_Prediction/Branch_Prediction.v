module Branch_Predictor 
(
  input wire clk,
  input wire reset,
  input wire branch,
  output reg predict
);

  reg [1:0] state;        // 2-bit dyanamic state variable

  always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= 2'b00;    // Reset state to 'Strongly Not Taken'
      end else begin

      case (state)
        2'b00: begin         // Strongly Not Taken
          if (branch) begin
            state <= 2'b01;  // Move to 'Weakly Not Taken' state
          end
        end
        2'b01: begin         // Weakly Not Taken
          if (branch) begin
            state <= 2'b11;  // Move to 'Weakly Taken' state
          end else begin
            state <= 2'b00;  // Move back to 'Strongly Not Taken' state
          end
        end
        2'b10: begin     // Weakly Taken
          if (!branch) begin
            state <= 2'b01;  // Move to 'Weakly Not Taken' state
          end
        end
        2'b11: begin     // Strongly Taken
          if (!branch) begin
            state <= 2'b10;  // Move to 'Weakly Taken' state
          end
        end
      endcase
      
    end
  end

  always @(posedge clk) begin
    // Make a prediction based on the current state
    case (state)
      2'b00, 2'b01: predict <= 0;   // Predict 'Not Taken'
      2'b10, 2'b11: predict <= 1;   // Predict 'Taken'
    endcase
  end

endmodule