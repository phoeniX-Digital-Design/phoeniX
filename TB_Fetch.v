`include "Fetch_Unit.v"

module TB_Fetch;

reg CLK;
reg Reset;
reg branch_signal;
reg  [31 : 0] immediate;
wire [31 : 0] PC;
wire [31 : 0] instruction;

reg [31 : 0] mem [0 : 99];
reg [31 : 0] data;

Fetch_Unit Fetch_Circuit (CLK, Reset, branch_signal, immediate, PC, instruction);

// Clock generation
always #1 CLK = ~CLK;

initial begin

      $dumpfile("Test_Fetch.vcd");
      $dumpvars(0, TB_Fetch);

CLK = 1'b0; 
Reset = 1; #10 Reset = 0;
branch_signal = 0;
immediate = 25;
#20;

$readmemh("Imem.txt", mem);
for (integer i = 0; i < 20; i = i + 1) begin
      Fetch_Circuit.instruction_memory.memory[i] = mem[i];
      $display ("%d %d", PC, instruction);
end
#20 $finish;

end
      
endmodule