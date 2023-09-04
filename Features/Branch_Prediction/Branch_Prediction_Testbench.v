`include "Branch_Predictor.v"

module Branch_Prediction_Testbench;

  reg clk;
  reg reset;
  reg branch;
  wire predict;

  Branch_Prediction uut 
  (
    .clk(clk),
    .reset(reset),
    .branch(branch),
    .predict(predict)
  );

  always #1 clk = ~clk;

  initial begin

    clk = 0;
    reset = 1;
    branch = 0;
    #5 reset = 0;

    // Pattern 1: Not Taken
    #5 branch = 0;
    #5 branch = 0;
    #5 branch = 0;
    #5 branch = 0;
    $display("Pattern 1 - Predicted: %b, Actual: 0", predict);

    // Pattern 2: Taken
    #5 branch = 1;
    #5 branch = 1;
    #5 branch = 1;
    #5 branch = 1;
    $display("Pattern 2 - Predicted: %b, Actual: 1", predict);

    // Pattern 3: Alternating
    #5 branch = 0;
    #5 branch = 1;
    #5 branch = 0;
    #5 branch = 1;
    $display("Pattern 3 - Predicted: %b, Actual: 0", predict);

    // Pattern 4: Random
    #5 branch = $random;
    #5 branch = $random;
    #5 branch = $random;
    #5 branch = $random;
    $display("Pattern 4 - Predicted: %b", predict);

    #10 $finish;

  end

endmodule