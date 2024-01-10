`include "Vector_Arithmetic_Logic_Unit.v"

module Vector_Arithmetic_Logic_Unit_tb;

reg  [ 6 : 0] opcode;
reg  [ 2 : 0] funct3;
reg  [ 6 : 0] funct7;
reg  [ 2 : 0] vector_unit_control;
reg  [31 : 0] vector_input_1;
reg  [31 : 0] vector_input_2;
wire [31 : 0] vector_result;

Vector_Arithmetic_Logic_Unit uut 
(
  .opcode(opcode),
  .funct3(funct3),
  .funct7(funct7),
  .vector_unit_control(vector_unit_control),
  .vector_input_1(vector_input_1),
  .vector_input_2(vector_input_2),
  .vector_result(vector_result)
);

initial begin
    $dumpfile("VALU.vcd");
    $dumpvars(0, Vector_Arithmetic_Logic_Unit_tb);
  #10;
  // Test VADD
  vector_unit_control = `VADD;
  vector_input_1 = 32'b00001111_00001111_00001111_00001111;
  vector_input_2 = 32'b01100000_01100000_01100000_01100000;
  #10;
  $display("VADD Result: %b", vector_result);
  // Test VSUB
  vector_unit_control = `VSUB;
  vector_input_1 = 32'b11111111_11111111_11111111_11111111;
  vector_input_2 = 32'b11110000_11110000_11110000_11110000;
  #10;
  $display("VADD Result: %b", vector_result);
  $finish;
end

endmodule