module SQRT_Unit # (parameter WIDTH = 32, parameter FBITS = 10) 
(
    input CLK,
    input [1 : 0] stage,

    input [6 : 0] opcode,
    input [6 : 0] funct7,
    input funct7_valid,

    input [31 : 0] bus_rs1,

    output reg [31 : 0] sqrt_output,
    output reg sqrt_busy
);
    wire stage_23 = stage == 2 || stage == 3;
    wire stage_1 = stage == 1;
    
    wire [31 : 0] rad = bus_rs1;
    wire start = {funct7_valid, funct7, opcode} ==? 15'b1_0101100_1010011 && stage_1;

    initial
    begin
        sqrt_busy = 0;
    end


    reg [WIDTH - 1 : 0] x, x_next;              
    reg [WIDTH - 1 : 0] q, q_next;              
    reg [WIDTH + 1 : 0] ac, ac_next;            
    reg [WIDTH + 1 : 0] test_res;               

    reg [WIDTH - 1 : 0] root;
    reg valid;

    localparam ITER = (WIDTH + FBITS) >> 1;     
    reg [4 : 0] i = 0;                              

    
    always @(*)
    begin
        test_res = ac - {q, 2'b01};

        if (test_res[WIDTH + 1] == 0) 
        begin  // test_res ≥0? (check MSB)
            {ac_next, x_next} = {test_res[WIDTH - 1 : 0], x, 2'b0};
            q_next = {q[WIDTH - 2 : 0], 1'b1};
        end 
        else 
        begin
            {ac_next, x_next} = {ac[WIDTH - 1 : 0], x, 2'b0};
            q_next = q << 1;
        end
    end
    

    always @(negedge CLK) 
    begin
        if (start) 
        begin
            sqrt_busy <= 1;
            valid <= 0;
            i <= 0;
            q <= 0;
            {ac, x} <= {{WIDTH{1'b0}}, rad, 2'b0};
        end 
        
        else if (sqrt_busy) 
        begin

            if (i == ITER-1) 
            begin  // we're done
                sqrt_busy <= 0;
                valid <= 1;
                root <= q_next;
            end

            else 
            begin  // next iteration
                i <= i + 1;
                x <= x_next;
                ac <= ac_next;
                q <= q_next;
            end
        end
    end


    always @(posedge CLK)
    begin

        if ({funct7_valid, funct7, opcode} ==? 15'b1_0101100_1010011 && stage_23)
            sqrt_output = root;
        else
            sqrt_output = 32'bz;

        
    end
endmodule