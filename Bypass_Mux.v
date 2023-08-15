module Bypass_Mux
(
  input [31 : 0] bus_rs,                    // Data coming from Registers
  input [31 : 0] forwarded_exe_data,        // Execution stage output
  input [31 : 0] forwarded_mem_data,        // Memory stage output
  input [31 : 0] forwarded_store_data,      // Forwarded address

  input [2  : 0] forward_control,           // Select pin (from Control Unit)

  output reg [31 : 0] bypass_mux_output
);

always @(*) begin
  case (forward_control)
    3'b000 : bypass_mux_output = bus_rs;
    3'b001 : bypass_mux_output = forwarded_exe_data;
    3'b010 : bypass_mux_output = forwarded_mem_data;
    3'b011 : bypass_mux_output = forwarded_store_data;
    default: bypass_mux_output = bus_rs;
  endcase
end

endmodule