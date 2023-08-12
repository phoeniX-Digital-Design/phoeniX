`include "..\\Branch_Unit.v"

module TB_Branch;

  // Inputs
  reg [6:0] opcode;
  reg [2:0] funct3;
  reg [6:0] funct7;
  reg [31:0] bus_rs1;
  reg [31:0] bus_rs2;
  reg branch_signal;

  // Outputs
  wire branch_enable;

  // Instantiate the module under test
  Branch_Unit uut 
  (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .bus_rs1(bus_rs1),
    .bus_rs2(bus_rs2),
    .branch_signal(branch_signal),
    .branch_enable(branch_enable)
  );


  initial begin

    opcode = 7'bxxxxxxx;
    funct3 = 3'bxxx;
    funct7 = 7'bxxxxxxx;
    bus_rs1 = 32'bx;
    bus_rs2 = 32'bx;
    branch_signal = 0;
    #10;

    // Test case 1: BEQ
    opcode = 7'b1100011;
    funct3 = 3'b000;
    funct7 = 7'bxxxxxxx;
    bus_rs1 = 32;
    bus_rs2 = 32;
    branch_signal = 1;
    #10;
    if (branch_enable) $display("BEQ  Test Passed");
    else $display("BEQ Test Failed");

    // Test case 2: BNE
    opcode = 7'b1100011;
    funct3 = 3'b001;
    funct7 = 7'bxxxxxxx;
    bus_rs1 = 33;
    bus_rs2 = 32;
    branch_signal = 1;
    #10;
    if (branch_enable) $display("BNE  Test Passed");
    else $display("BNE Test Failed");

    // Test case 3: BLT
    opcode = 7'b1100011;
    funct3 = 3'b100;
    funct7 = 7'bxxxxxxx;
    bus_rs1 = -1;
    bus_rs2 = 0;
    branch_signal = 1;
    #10;
    if (branch_enable) $display("BLT  Test Passed");
    else $display("BLT Test Failed");

    // Test case 4: BGE
    opcode = 7'b1100011;
    funct3 = 3'b101;
    funct7 = 7'bxxxxxxx;
    bus_rs1 = 0;
    bus_rs2 = -1;
    branch_signal = 1;
    #10;
    if (branch_enable) $display("BGE  Test Passed");
    else $display("BGE Test Failed");

    // Test case 5: BLTU
    opcode = 7'b1100011;
    funct3 = 3'b110;
    funct7 = 7'bxxxxxxx;
    bus_rs1 = 0;
    bus_rs2 = 1;
    branch_signal = 1;
    #10;
    if (branch_enable) $display("BLTU Test Passed");
    else $display("BLTU Test Failed");

    // Test case 6: BGEU
    opcode = 7'b1100011;
    funct3 = 3'b111;
    funct7 = 7'bxxxxxxx;
    bus_rs1 = 1;
    bus_rs2 = 0;
    branch_signal = 1;
    #10;
    if (branch_enable) $display("BGEU Test Passed");
    else $display("BGEU Test Failed");

    $finish;

  end

endmodule