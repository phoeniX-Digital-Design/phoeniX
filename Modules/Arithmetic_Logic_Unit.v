/*
    phoeniX RV32IEM ALU: Designer Guidelines
    ==========================================================================================================================
    DESIGNER NOTICE:
    - Kindly adhere to the established guidelines and naming conventions outlined in the project documentation. 
    - Following these standards will ensure smooth integration of your custom-made modules into this codebase.
    - Thank you for your cooperation.
    ==========================================================================================================================
    ALU Approximation CSR
    - ALU CSR is addressed as 0x800 in control status registers.
    - One adder circuit is used for 3 integer instructions: ADD/ADDI/SUB
    - Internal signals are all generated according to phoeniX core "Self Control Logic" of the modules so designer won't 
      need to change anything inside this module (excepts parts which are considered for designers to instatiate their own 
      custom made designs).
    - Instantiate your modules (Approximate or Accurate) between the comments in the code.
    - How to work with the speical purpose CSR:
        CSR [0]      : APPROXIMATE = 1 | ACCURATE = 0
        CSR [2  : 1] : CIRCUIT_SELECT (Defined for switching between 4 accuarate or approximate circuits)
        CSR [31 : 3] : APPROXIMATION_ERROR_CONTROL
    - PLEASE DO NOT REMOVE ANY OF THE COMMENTS IN THIS FILE
    - Input and Output paramaters:
        Input:  error_control = {control_status_register[USER_ERROR_LEN:3], control_status_register[2:1] (module select), control_status_register[0]}
        Input:  adder_input_1 = First operand of your module
        Input:  adder_input_2 = Second operand of your module
        Input:  adder_Cin     = Input Carry
        Output: adder_result  = Module output
    ==========================================================================================================================
    - This unit executes R-Type, I-Type and J-Type instructions
    - Inputs `rs1`, `rs2` comes from `Register_File` (DATA BUS)
    - Input `immediate` comes from `Immediate_Generator`
    - Input signals `opcode`, `funct3`, `funct7`, comes from `Instruction_Decoder`
*/

`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif /*OPCODES*/

`ifndef I_INSTRUCTIONS
    `define ADDI    3'b000
    `define SLTI    3'b010
    `define SLTIU   3'b011
    `define XORI    3'b100
    `define ORI     3'b110
    `define ANDI    3'b111
    `define SLLI    3'b001      // Shift Left Immediate -> Logical
    `define SRI     3'b101      // Shift Right Immediate -> Logical & Arithmetic
`endif /*I_INSTRUCTIONS*/

`ifndef R_INSTRUCTIONS
    `define ADDSUB  3'b000
    `define SLL     3'b001      // Shift Left -> Logical   
    `define SLT     3'b010
    `define SLTU    3'b011    
    `define XOR     3'b100    
    `define SR      3'b101      // Shift Right -> Logical & Arithmetic   
    `define OR      3'b110    
    `define AND     3'b111
`endif /*R_INSTRUCTIONS*/

`define LOGICAL     7'b000_0000
`define ARITHMETIC  7'b010_0000
`define ADD         7'b000_0000     
`define SUB         7'b010_0000

`define RIGHT 1'b1
`define LEFT  1'b0

module Arithmetic_Logic_Unit
#(
    parameter GENERATE_CIRCUIT_1 = 1,
    parameter GENERATE_CIRCUIT_2 = 0,
    parameter GENERATE_CIRCUIT_3 = 0,
    parameter GENERATE_CIRCUIT_4 = 0
)
(
    input [6 : 0] opcode,               
    input [2 : 0] funct3,               
    input [6 : 0] funct7,               

    input [31 : 0] control_status_register,    

    input [31 : 0] rs1,                 
    input [31 : 0] rs2,                 
    input [31 : 0] immediate,           

    output reg [31 : 0] alu_output      
);
    reg alu_enable;

    reg  [31 : 0] operand_1; 
    reg  [31 : 0] operand_2;

    reg adder_Cin;
    reg  [31 : 0] adder_input_1;
    reg  [31 : 0] adder_input_2;
    wire [31 : 0] adder_result;

    reg  [31 : 0] shift_input;
    reg  [4  : 0] shift_amount;
    reg           shift_direction;
    wire [31 : 0] shift_result;

    reg  adder_0_enable;
    reg  adder_1_enable;
    reg  adder_2_enable;
    reg  adder_3_enable;

    wire [31 : 0] adder_0_result;
    wire [31 : 0] adder_1_result;
    wire [31 : 0] adder_2_result;
    wire [31 : 0] adder_3_result;

    always @(*) 
    begin
        case (opcode)
            `OP     : begin operand_1 = rs1; operand_2 = rs2;       end // R-TYPE 
            `OP_IMM : begin operand_1 = rs1; operand_2 = immediate; end // I-TYPE 
            default : begin operand_1 = 32'bz; operand_2 = 32'bz;   end
        endcase        
    end

    // ----------------------------------- //
    // Main R-type and I-type Instrcutions //
    // ----------------------------------- //
    always @(*)
    begin
        case ({funct3, opcode})
            // I-TYPE Intructions
            {`ADDI, `OP_IMM}  : begin alu_enable = 1'b1; alu_output = adder_result;             end
            {`SLLI, `OP_IMM}  : 
            begin shift_direction = `LEFT; shift_input = operand_1; shift_amount = operand_2[4 : 0]; alu_output = shift_result; end 
            {`SLTI, `OP_IMM}  : begin alu_enable = 1'b1; alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;  end
            {`SLTIU, `OP_IMM} : begin alu_enable = 1'b1; alu_output = operand_1 < operand_2 ? 1 : 0;                    end

            {`XORI, `OP_IMM}  : begin alu_enable = 1'b1; alu_output = operand_1 ^ operand_2;    end
            {`ORI, `OP_IMM}   : begin alu_enable = 1'b1; alu_output = operand_1 | operand_2;    end
            {`ANDI, `OP_IMM}  : begin alu_enable = 1'b1; alu_output = operand_1 & operand_2;    end
            
            {`SRI, `OP_IMM}   : 
            begin
                case (funct7)
                    `LOGICAL    : 
                    begin shift_direction = `RIGHT; shift_input = operand_1; shift_amount = operand_2[4 : 0]; alu_output = shift_result; end    
                    `ARITHMETIC :
                    begin shift_direction = `RIGHT; shift_input = operand_1; shift_amount = $signed(operand_2[4 : 0]); alu_output = shift_result; end     
                endcase
            end
        
            // R-TYPE Instructions
            {`ADDSUB, `OP}  : begin alu_enable = 1'b1; alu_output = adder_result;           end  
            {`SLL, `OP}     : 
            begin shift_direction = `LEFT; shift_input = operand_1; shift_amount = operand_2[4 : 0]; alu_output = shift_result; end
            {`SLT, `OP}     : begin alu_enable = 1'b1; alu_output = $signed(operand_1) < $signed(operand_2) ? 1 : 0;    end
            {`SLTU, `OP}    : begin alu_enable = 1'b1; alu_output = operand_1 < operand_2 ? 1 : 0; ;                    end
            {`XOR, `OP}     : begin alu_enable = 1'b1; alu_output = operand_1 ^ operand_2;  end
            {`OR, `OP}      : begin alu_enable = 1'b1; alu_output = operand_1 | operand_2;  end
            {`AND, `OP}     : begin alu_enable = 1'b1; alu_output = operand_1 & operand_2;  end
            {`SR, `OP}      :
            begin
                case (funct7)
                    `LOGICAL    : 
                    begin shift_direction = `RIGHT; shift_input = operand_1; shift_amount = operand_2[4 : 0]; alu_output = shift_result; end
                    `ARITHMETIC : 
                    begin shift_direction = `RIGHT; shift_input = operand_1; shift_amount = $signed(operand_2[4 : 0]); alu_output = shift_result; end
                endcase
            end           

            default: begin alu_enable = 1'b0; alu_output = 32'bz; end
        endcase
    end

    // ----------------------------------------- //
    // Arithmetical Instructions: ADDI, ADD, SUB //
    // ----------------------------------------- //

    reg adder_enable;
    // *** Implement the control systems required for your circuit ***
    always @(*) 
    begin
        case ({funct3, opcode})
            {`ADDI, `OP_IMM} : begin adder_enable = 1'b1; adder_input_1 = operand_1; adder_input_2 = operand_2; adder_Cin = 1'b0;  end 

            {`ADDSUB, `OP} :
            begin
                case (funct7)
                    `ADD : begin adder_enable = 1'b1; adder_input_1 = operand_1; adder_input_2 = operand_2; adder_Cin = 1'b0;  end 
                    `SUB : begin adder_enable = 1'b1; adder_input_1 = operand_1; adder_input_2 = ~operand_2; adder_Cin = 1'b1; end 
                endcase
            end
            default: begin adder_enable = 1'b0; end
        endcase    
    end

    always @(posedge adder_enable) 
    begin
        case (control_status_register[2 : 1])
            2'b00:   begin adder_0_enable = 1'b1; adder_1_enable = 1'b0; adder_2_enable = 1'b0; adder_3_enable = 1'b0; end
            2'b01:   begin adder_0_enable = 1'b0; adder_1_enable = 1'b1; adder_2_enable = 1'b0; adder_3_enable = 1'b0; end
            2'b10:   begin adder_0_enable = 1'b0; adder_1_enable = 1'b0; adder_2_enable = 1'b1; adder_3_enable = 1'b0; end
            2'b11:   begin adder_0_enable = 1'b0; adder_1_enable = 1'b0; adder_2_enable = 1'b0; adder_3_enable = 1'b1; end 
            default: begin adder_0_enable = 1'b1; adder_1_enable = 1'b0; adder_2_enable = 1'b0; adder_3_enable = 1'b0; end
        endcase
    end

    assign adder_result =   (adder_0_enable) ? adder_0_result :
                            (adder_1_enable) ? adder_1_result :
                            (adder_2_enable) ? adder_2_result :
                            (adder_3_enable) ? adder_3_result : adder_0_result;

    // Instantiation of Barrel Shifter circuit
    // ---------------------------------------
    Barrel_Shifter alu_shifter_circuit
    (
        .input_value(shift_input),
        .shift_amount(shift_amount),
        .direction(shift_direction),
        .result(shift_result)
    );
    // ---------------------------------------
    // End of Barrel Shifter instantiation

    // *** Instantiate your adder circuit here ***
    // Please instantiate your adder module according to the guidelines and naming conventions of phoeniX
    // --------------------------------------------------------------------------------------------------
    generate 
        if (GENERATE_CIRCUIT_1)
        begin
            // Circuit 0 (deafult) instantiation
            //----------------------------------
            Approximate_Accuracy_Controllable_Adder 
            #(
                .LEN(32),
                .APX_LEN(8)
            )
            approximate_accuracy_controllable_adder 
            (
                .Er(control_status_register[10 : 3] | {8{~control_status_register[0]}}), 
                .A(adder_input_1),
                .B(adder_input_2),
                .Cin(adder_Cin),
                .Sum(adder_0_result)
            );
            //----------------------------------
            // End of Circuit 0 instantiation
        end
        if (GENERATE_CIRCUIT_2)
        begin
            // Circuit 1 instantiation
            //-------------------------------
            Kogge_Stone_Adder_ALU default_fast_adder
            (
                .carry_in(adder_Cin), 
                .input_A(adder_input_1),
                .input_B(adder_input_2),
                .sum(adder_1_result)
            );
            //-------------------------------
            // End of Circuit 1 instantiation
        end
        if (GENERATE_CIRCUIT_3)
        begin
            // Circuit 2 instantiation
            //-------------------------------
            assign adder_2_result = (adder_2_enable) ? adder_input_1 + adder_input_2 + adder_Cin : 32'bz;
            //-------------------------------
            // End of Circuit 2 instantiation
        end
        if (GENERATE_CIRCUIT_4)
        begin
            // Circuit 3 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 3 instantiation
        end
    endgenerate
    // --------------------------------------------------------------------------------------------------
    // *** End of adder module instantiation ***
endmodule

module Kogge_Stone_Adder_ALU
(
    input  wire          carry_in,
    input  wire [31 : 0] input_A,
    input  wire [31 : 0] input_B,
    output wire [31 : 0] sum,
    output wire          carry_out
);

    // Stage 1
    wire [31 : 0] p_stage_1; wire [31 : 0] g_stage_1; wire carry_stage_1;
    // Stage 2
    wire [30 : 0] p_stage_2; wire [31 : 0] g_stage_2; wire carry_stage_2; wire [31 : 0] p_saved_1;
    // Stage 3
    wire [28 : 0] p_stage_3; wire [31 : 0] g_stage_3; wire carry_stage_3; wire [31 : 0] p_saved_2;
    // Stage 4
    wire [24 : 0] p_stage_4; wire [31 : 0] g_stage_4; wire carry_stage_4; wire [31 : 0] p_saved_3;
    // Stage 5
    wire [16 : 0] p_stage_5; wire [31 : 0] g_stage_5; wire carry_stage_5; wire [31 : 0] p_saved_4;
    // Stage 6
    wire [31 : 0] p_stage_6; wire [31 : 0] g_stage_6; wire carry_stage_6;

    // Kogge Stone Stage 1
    assign carry_stage_1 = carry_in;
    genvar i;
    generate
    for (i = 0 ; i < 32 ; i = i + 1) 
    begin
        PG_ALU pg_stage_1 
        (
            .input_a(input_A[i]),
            .input_b(input_B[i]),
            .output_p(p_stage_1[i]),
            .output_g(g_stage_1[i])
        );
    end
    endgenerate

    // Kogge Stone Stage 2
    wire [31 : 0] gkj_stage_2;
    wire [30 : 0] pkj_stage_2;

    assign carry_stage_2        = carry_stage_1;
    assign p_saved_1            = p_stage_1 [31 : 0];
    assign gkj_stage_2 [0]      = carry_stage_1;
    assign gkj_stage_2 [31 : 1] = g_stage_1 [30 : 0];
    assign pkj_stage_2          = p_stage_1 [30 : 0];

    Grey_Cell_ALU gc_0(gkj_stage_2[0], p_stage_1[0], g_stage_1[0], g_stage_2[0]);
    genvar j;
    generate
    for (j = 0 ; j < 31 ; j = j + 1) 
    begin
        Black_Cell_ALU bc_stage_2 
        (
            .input_pj(pkj_stage_2[j]),
            .input_gj(gkj_stage_2[j + 1]),
            .input_pk(p_stage_1[j + 1]),
            .input_gk(g_stage_1[j + 1]),
            .output_g(g_stage_2[j + 1]),
            .output_p(p_stage_2[j])
        );
    end
    endgenerate

    // Kogge Stone Stage 3
    wire [30 : 0] gkj_stage_3;
    wire [28 : 0] pkj_stage_3;

    assign carry_stage_3       = carry_stage_2;
    assign p_saved_2           = p_saved_1[31 : 0];
    assign gkj_stage_3[0]      = carry_stage_2;
    assign gkj_stage_3[30 : 1] = g_stage_2[29 : 0];
    assign pkj_stage_3         = p_stage_2[28 : 0];
    assign g_stage_3[0]        = g_stage_2[0];

    Grey_Cell_ALU  gc_1(gkj_stage_3[0], p_stage_2[0], g_stage_2[1], g_stage_3[1]);
    Grey_Cell_ALU  gc_2(gkj_stage_3[1], p_stage_2[1], g_stage_2[2], g_stage_3[2]);

    genvar k;
    generate
    for (k = 0 ; k < 29 ; k = k + 1) begin
        Black_Cell_ALU bc_stage_3 
        (
            .input_pj(pkj_stage_3[k]),
            .input_gj(gkj_stage_3[k + 2]),
            .input_pk(p_stage_2[k + 2]),
            .input_gk(g_stage_2[k + 3]),
            .output_g (g_stage_3[k + 3]),
            .output_p (p_stage_3[k])
        );
    end
    endgenerate

    // Kogge Stone Stage 4
    wire [28 : 0] gkj_stage_4;
    wire [24 : 0] pkj_stage_4;

    assign carry_stage_4       = carry_stage_3;
    assign p_saved_3           = p_saved_2[31 : 0];
    assign gkj_stage_4[0]      = carry_stage_3;
    assign gkj_stage_4[28 : 1] = g_stage_3[27 : 0];
    assign pkj_stage_4         = p_stage_3[24 : 0];
    assign g_stage_4[2 : 0]    = g_stage_3[2  : 0];

    genvar l;
    generate
    for (l = 0 ; l < 4 ; l = l + 1) begin
        Grey_Cell_ALU gc_stage_4 
        (
            .input_gj(gkj_stage_4[l]),
            .input_pk(p_stage_3[l]),
            .input_gk(g_stage_3[l + 3]),
            .output_g(g_stage_4[l + 3])
        );
    end
    endgenerate

    genvar m;
    generate
    for (m = 0 ; m < 25 ; m = m + 1) begin
        Black_Cell_ALU bc_stage_4 
        (
            .input_pj(pkj_stage_4[m]),
            .input_gj(gkj_stage_4[m + 4]),
            .input_pk(p_stage_3[m + 4]),
            .input_gk(g_stage_3[m + 7]),
            .output_g(g_stage_4[m + 7]),
            .output_p(p_stage_4[m])
        );
    end
    endgenerate

    // Kogge Stone Stage 5
    wire [24 : 0] gkj_stage_5;
    wire [16 : 0] pkj_stage_5;

    assign carry_stage_5       = carry_stage_4;
    assign p_saved_4           = p_saved_3[31 : 0];
    assign gkj_stage_5[0]      = carry_stage_4;
    assign gkj_stage_5[24 : 1] = g_stage_4[23 : 0];
    assign pkj_stage_5         = p_stage_4[16 : 0];
    assign g_stage_5[6 : 0]    = g_stage_4[6  : 0];

    genvar n;
    generate
    for (n = 0 ; n < 8 ; n = n + 1) begin
        Grey_Cell_ALU gc_stage_5 
        (
            .input_gj(gkj_stage_5[n]),
            .input_pk(p_stage_4[n]),
            .input_gk(g_stage_4[n + 7]),
            .output_g(g_stage_5[n + 7])
        );
    end
    endgenerate

    genvar o;
    generate
    for (o = 0 ; o < 17 ; o = o + 1) begin
        Black_Cell_ALU bc_stage_5 
        (
            .input_pj(pkj_stage_5[o]),
            .input_gj(gkj_stage_5[o + 8]),
            .input_pk(p_stage_4[o + 8]),
            .input_gk(g_stage_4[o + 15]),
            .output_g(g_stage_5[o + 15]),
            .output_p(p_stage_5[o])
        );
    end
    endgenerate

    // Kogge Stone Stage 6
    wire [16 : 0] gkj_stage_6;

    assign carry_stage_6       = carry_stage_5;
    assign p_stage_6           = p_saved_4[31 : 0];
    assign gkj_stage_6[0]      = carry_stage_5;
    assign gkj_stage_6[16 : 1] = g_stage_5[15 : 0];
    assign g_stage_6[15 : 0]   = g_stage_5[15 : 0];

    genvar p;
    generate
    for (p = 1 ; p <= 16 ; p = p + 1) begin
        Grey_Cell_ALU gc_stage_6 
        (
            .input_gj(gkj_stage_6[p]),
            .input_pk(p_stage_5[p]),
            .input_gk(g_stage_5[p + 15]),
            .output_g(g_stage_6[p + 15])
        );
    end
    endgenerate

    // Kogge Stone Stage 7
    assign carry_out   = g_stage_6[31];
    assign sum[0]      = carry_stage_6 ^ p_stage_6[0];
    assign sum[31 : 1] = g_stage_6[30 : 0] ^ p_stage_6[31 : 1];

endmodule

module PG_ALU
(
    input  wire input_a,
    input  wire input_b,
    output wire output_p,
    output wire output_g
);
    assign output_p = input_a ^ input_b;
    assign output_g = input_a & input_b;
endmodule

module Black_Cell_ALU
(
    input  wire input_pj,
    input  wire input_gj,
    input  wire input_pk,
    input  wire input_gk,
    output wire output_g,
    output wire output_p
);
    assign output_g = input_gk | (input_gj & input_pk);
    assign output_p = input_pk & input_pj;
endmodule

module Grey_Cell_ALU
(
    input  wire input_gj,
    input  wire input_pk,
    input  wire input_gk,
    output wire output_g
);
    assign output_g = input_gk | (input_gj & input_pk);
endmodule

module Barrel_Shifter
(
    input  [31 : 0] input_value, 
    input  [4  : 0] shift_amount,
    input           direction,          // direction = 1 : RIGHT, direction = 0 : LEFT

    output [31 : 0] result 
);

    wire [31 : 0] shift_mux_0; 
    wire [31 : 0] shift_mux_1; 
    wire [31 : 0] shift_mux_2; 
    wire [31 : 0] shift_mux_3; 
    wire [31 : 0] shift_mux_4; 
    wire [31 : 0] reversed;
     
    // reverse -> shift right -> then reverse again
    Reverser_Circuit #(.N(32)) RC1 (input_value, direction, reversed);

    // Stage 0: shift 0 or 1 bit
    assign shift_mux_0 = shift_amount[0] ? {1'b0,  reversed[31 : 1]} : reversed;
    // Stage 1: shift 0 or 2 bits 
    assign shift_mux_1 = shift_amount[1] ? {2'b0,  shift_mux_0[31 : 2]} : shift_mux_0;
    // Stage 2: shift 0 or 4 bits 
    assign shift_mux_2 = shift_amount[2] ? {4'b0,  shift_mux_1[31 : 4]} : shift_mux_1;
    // Stage 3: shift 0 or 8 bits 
    assign shift_mux_3 = shift_amount[3] ? {8'b0,  shift_mux_2[31 : 8]} : shift_mux_2;
    // Stage 4: shift 0 or 16 bits 
    assign shift_mux_4 = shift_amount[4] ? {16'b0, shift_mux_3[31 : 16]} : shift_mux_3;

    // Reverse again 
    Reverser_Circuit #(.N(32)) RC2 (shift_mux_4, direction, result);
endmodule

module Reverser_Circuit
#(
    parameter N = 32
)
(
    input  [N - 1 : 0]  input_value, 
    input               enable, 
    output [N - 1 : 0]  reversed_value
);

    wire [N - 1 : 0] temp;
    generate
        genvar i;
        for (i = 0 ; i <= N - 1 ; i = i + 1)
            assign temp[i] = input_value[N - 1 - i];
    endgenerate
    // enable = 1 (RIGHT) -> reverse module does nothing 
    // enable = 0 (LEFT)  -> result = temp (reversed)
    assign reversed_value = enable ? input_value : temp;
endmodule

// Add your custom adder circuit here ***
// Please create your adder module according to the guidelines and naming conventions of phoeniX
// --------------------------------------------------------------------------------------------------
module Approximate_Accuracy_Controllable_Adder 
#(
    parameter LEN = 32,
    parameter APX_LEN = 8         // Valid Options for APX_LEN : 4, 8, 12, 16, ...
)
(
    input [APX_LEN - 1 : 0] Er,
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);

    wire [LEN - 1 : 0] C;
    
    ////////////////////
    //    [3 : 0]     //
    ////////////////////

    Error_Configurable_Ripple_Carry_Adder #(.LEN(4)) EC_RCA_1 
    (
        .Er(Er[3  : 0]),
        .A(A[3 : 0]), 
        .B(B[3 : 0]), 
        .Cin(Cin), 
        .Sum(Sum[3 : 0]), 
        .Cout(C[3])
    );
    
    ////////////////////
    //    [31 : 4]    //
    ////////////////////

    genvar i;
    generate
        
        // ------------------- //
        // Approximate Circuit //
        // ------------------- //

        for (i = 4; i < APX_LEN; i = i + 4)
        begin
            wire HA_Carry;
            wire EC_RCA_Carry;
            wire [i + 3 : i] EC_RCA_Output;

            Half_Adder HA
            (
                .A(A[i]), 
                .B(B[i]),
                .Sum(EC_RCA_Output[i]),
                .Cout(HA_Carry)
            );

            Error_Configurable_Ripple_Carry_Adder
            #(
                .LEN(3)
            )
            EC_RCA
            (
                .Er(Er[i + 3 : i + 1]),
                .A(A[i + 3 : i + 1]), 
                .B(B[i + 3 : i + 1]), 
                .Cin(HA_Carry),
                .Sum(EC_RCA_Output[i + 3 : i + 1]),
                .Cout(EC_RCA_Carry)
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit BU_1 (.A(EC_RCA_Output), .B(BU_Output), .C0(BU_Carry));

            Mux_2to1 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1({EC_RCA_Carry, EC_RCA_Output}),
                .data_in_2({BU_Carry || EC_RCA_Carry, BU_Output}),
                .select(C[i - 1]),
                .data_out({C[i + 3], Sum[i + 3 : i]})
            );
        end
        
        // ------------- //
        // Exact Circuit //
        // ------------- //

        for (i = APX_LEN; i < LEN; i = i + 4)
        begin
            wire HA_Carry;
            wire RCA_Carry;
            wire [i + 3 : i] RCA_Output;

            Half_Adder HA
            (
                .A(A[i]), 
                .B(B[i]),
                .Sum(RCA_Output[i]),
                .Cout(HA_Carry)
            );

            Ripple_Carry_Adder
            #(
                .LEN(3)
            )
            RCA
            (
                .A(A[i + 3 : i + 1]), 
                .B(B[i + 3 : i + 1]), 
                .Cin(HA_Carry),
                .Sum(RCA_Output[i + 3 : i + 1]),
                .Cout(RCA_Carry)
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit BU_1 (.A(RCA_Output), .B(BU_Output), .C0(BU_Carry));

            Mux_2to1 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1({RCA_Carry, RCA_Output}),
                .data_in_2({BU_Carry || RCA_Carry, BU_Output}),
                .select(C[i - 1]),
                .data_out({C[i + 3], Sum[i + 3 : i]})
            );
        end

    endgenerate
    
    assign Cout = C[LEN - 1];
endmodule

module Basic_Unit 
(
    input  [3 : 0] A,
    output [4 : 1] B,
    output C0
);

    assign B[1] = ~A[0];
    assign B[2] = A[1] ^ A[0];
    wire   C1   = A[1] & A[0];
    wire   C2   = A[2] & A[3];
    wire   C0   = C1 & C2;
    wire   C3   = C1 & A[2];
    assign B[3] = A[2] ^ C1;
    assign B[4] = A[3] ^ C3;
endmodule

module Mux_2to1
#(
    parameter LEN = 5
) 
(
    input [LEN - 1 : 0] data_in_1,        
    input [LEN - 1 : 0] data_in_2,        
    input select,                   

    output reg [LEN - 1: 0] data_out            
);

    always @(*) 
    begin
        case (select)
            1'b0: begin data_out = data_in_1; end
            1'b1: begin data_out = data_in_2; end
            default: begin data_out = {LEN{1'bz}}; end
        endcase
    end
endmodule

module Error_Configurable_Ripple_Carry_Adder 
#(
    parameter LEN = 4
) 
(
    input [LEN - 1 : 0] Er,
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);
    wire [LEN : 0] Carry;
    assign Carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Error_Configurable_Full_Adder ECFA 
            (
                .Er(Er[i]),
                .A(A[i]), 
                .B(B[i]), 
                .Cin(Carry[i]), 
                .Sum(Sum[i]), 
                .Cout(Carry[i + 1])
            );
        end
    assign Cout = Carry[LEN];
    endgenerate
endmodule

module Ripple_Carry_Adder 
#(
    parameter LEN = 4
) 
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);
    wire [LEN : 0] Carry;
    assign Carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Full_Adder FA 
            (
                .A(A[i]), 
                .B(B[i]), 
                .Cin(Carry[i]), 
                .Sum(Sum[i]), 
                .Cout(Carry[i + 1])
            );
        end
    assign Cout = Carry[LEN];
    endgenerate
endmodule

module Error_Configurable_Full_Adder
(
    input Er,
    input A,
    input B, 
    input Cin,

    output Sum, 
    output Cout
);
    assign Sum = ~(Er && (A ^ B) && Cin) && ((A ^ B) || Cin);
    assign Cout = (Er && B && Cin) || ((B || Cin) && A);
endmodule

module Full_Adder 
(
    input A,
    input B,
    input Cin,

    output Sum,
    output Cout
);
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A && B) || (A && Cin) || (B && Cin); 
endmodule

module Half_Adder 
(
    input A,
    input B, 
    output Sum, 
    output Cout
);
    assign Sum = A ^ B;
    assign Cout = A & B;
endmodule

// --------------------------------------------------------------------------------------------------
// *** End of adder module definition ***