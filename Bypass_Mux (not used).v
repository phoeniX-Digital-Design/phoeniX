module Bypass_Mux_4to1
(
  input [31:0] data_in_0,  // 32-bit input data 0
  input [31:0] data_in_1,  // 32-bit input data 1
  input [31:0] data_in_2,  // 32-bit input data 2
  input [31:0] data_in_3,  // 32-bit input data 3
  input [1:0] select,     // 2-bit select signal
  output reg [31:0] out   // 32-bit output
);

always @(*) begin
  case (select)
    2'b00: out = data_in_0;
    2'b01: out = data_in_1;
    2'b10: out = data_in_2;
    2'b11: out = data_in_3;
  endcase
end

endmodule

module Bypass_Mux_2to1
(
  input [31:0] data_in_0,  // 32-bit input data 0
  input [31:0] data_in_1,  // 32-bit input data 1
  input select,            // 1-bit select signal
  output reg [31:0] out    // 32-bit output
);

always @(*) begin
  if (select == 1'b0) begin
    out = data_in_0;
  end else begin
    out = data_in_1;
  end
end

endmodule