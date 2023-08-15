module Bypass_Mux
(
  input [31 : 0] bus_rs1,
  input [31 : 0] forwarded_exe_data,
  input [31 : 0] forwarded_mem_data,
  input [31 : 0] forwarded_store_data,
  input [2  : 0] forward_control,

  output reg [31 : 0] bypass_mux_output
);

always @(*) begin
  
  case (forward_control)
    3'b000 : bypass_mux_output = bus_rs1;
    3'b001 : bypass_mux_output = forwarded_exe_data;
    3'b010 : bypass_mux_output = forwarded_mem_data;
    3'b011 : bypass_mux_output = forwarded_store_data;
    default: bypass_mux_output = bus_rs1;
  endcase

end

endmodule