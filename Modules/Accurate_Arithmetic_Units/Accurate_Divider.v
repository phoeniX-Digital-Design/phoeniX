 module Accurate_Divider
 (  
    input  CLK,                 // Clock signal
    input  [31 : 0] operand_1,  // Operand 1
    input  [31 : 0] operand_2,  // Operand 2
    output reg [31 : 0] div,    // Division result
    output reg [31 : 0] rem,    // Remainder
    output busy                 // = 1 while calculation
);

    reg active;                 // True if the divider is running  
    reg [4  : 0] cycle;         // Number of cycles to go  
    reg [31 : 0] result;        // Begin with operand_1, end with division result  
    reg [31 : 0] denom;         // Second operand (operand_2)  
    reg [31 : 0] work;          // remunning remainder

    // Calculate the current digit
    wire [32 : 0] sub = {work[30 : 0], result[31]} - denom;

    wire [31 : 0] div_result;
    wire [31 : 0] rem_result;
    reg  [31 : 0] latched_div_result;
    reg  [31 : 0] latched_rem_result;
    
    always @(*) 
    begin
        if ((output_ready == 1) && (busy == 0))
        begin
            assign latched_div_result = div_result;  
            assign latched_rem_result = rem_result;
        end
    end
    always @(*) begin
        if ((output_ready == 1) && (busy == 0))
        begin
            div = latched_div_result;
            rem = latched_rem_result;
        end
    end

    assign div_result = result;
    assign rem_result = work;

    assign output_ready = ~active;
    assign busy = active;

    // The state machine  
    always @(posedge CLK) begin  

            if (active) 
            begin  
                // remun an iteration of the divide.  
                if (sub[32] == 0) 
                begin  
                    work  <= sub[31 : 0];
                    result <= {result[30 : 0], 1'b1};
                end  
                else 
                begin  
                    work <= {work[30 : 0], result[31]};
                    result <= {result[30 : 0], 1'b0};
                end  
                if (cycle == 0) begin active <= 0; end  
                cycle <= cycle - 5'd1;  
            end
            else begin  
                // Set up for an unsigned divide.  
                cycle  <= 5'd31;  
                result <= operand_1;  
                denom  <= operand_2;  
                work   <= 32'b0;  
                active <= 1;  
            end  
        end  

endmodule   