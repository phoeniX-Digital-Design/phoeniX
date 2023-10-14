`include "../Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Adder.v" 
 
module Approximate_Accuracy_Controlable_Divider
(  
    input  CLK,                 // Clock signal

    input  [7  : 0] Er,         // Error rate

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

    wire [32 : 0] sub_test;
    //wire [32 : 0] sub = {work[30 : 0], result[31]} - denom;
    wire c_out;
    //wire [32 : 0] sub_prim = {work[30 : 0], result[31]} + ~denom + 1'b1;
    wire [31 : 0] sub_module; 

    // Calculate the current digit
    Approximate_Accuracy_Controlable_Adder 
    #(
        .LEN(32),
        .APX_LEN(8)
    )
    approximate_subtract
    (
        .Er(Er),
        .A({work[30 : 0], result[31]}),
        .B(~denom),
        .Cin(1'b1),
        .Sum(sub_module),
        .Cout(c_out)
    );
    assign sub_test = {sub_module[31], sub_module}; // sign-extend

    wire [31 : 0] div_result;
    wire [31 : 0] rem_result;
    reg  [31 : 0] latched_div_result;
    reg  [31 : 0] latched_rem_result;
    
    always @(*) 
    begin
        //$display("operand 1 = %b | operand 2 = %b", {work[30 : 0], result[31]}, denom);
        //$display("SUB_Normal = %d | SUB_Prim = %b | SUB_Module = %b \n" , sub, sub_prim, sub_test);
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
                if (sub_test[32] == 0) 
                begin  
                    work  <= sub_test[31 : 0];
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