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

module Address_Generator
(
    input [ 6 : 0] opcode, 
    input [31 : 0] rs1,            
    input [31 : 0] pc,
    input [31 : 0] immediate,

    output reg [31 : 0] address
);
    
    reg  [31 : 0] adder_input_1;
    reg  [31 : 0] adder_input_2;
    wire [31 : 0] adder_result;

    always @(*) 
    begin
        case (opcode)
            `STORE   : begin adder_input_1 = rs1; adder_input_2 = immediate; address = adder_result; end    //  Store  ->   rs1  + immediate
            `LOAD    : begin adder_input_1 = rs1; adder_input_2 = immediate; address = adder_result; end    //  Load   ->   rs1  + immediate
            `JALR    : begin adder_input_1 = rs1; adder_input_2 = immediate; address = adder_result; end    //  JALR   ->   rs1  + immediate
            `JAL     : begin adder_input_1 = pc;  adder_input_2 = immediate; address = adder_result; end    //  JAL    ->    pc  + immediate
            `AUIPC   : begin adder_input_1 = pc;  adder_input_2 = immediate; address = adder_result; end    //  AUIPC  ->    pc  + immediate
            `BRANCH  : begin adder_input_1 = pc;  adder_input_2 = immediate; address = adder_result; end    //  Branch ->    pc  + immediate
            default  : address = 32'bz;
        endcase 
    end

    Kogge_Stone_Adder adder_address_generator 
    (
        .carry_in(1'b0), 
        .input_A(adder_input_1),
        .input_B(adder_input_2),
        .sum(adder_result)
    );
    
endmodule

module Kogge_Stone_Adder
(
    input  wire          carry_in,
    input  wire [31 : 0] input_A,
    input  wire [31 : 0] input_B,
    output wire [31 : 0] sum,
    output wire          carry_out
);

    wire [31 : 0] p1;
    wire [31 : 0] g1;
    wire          c1;

    wire [30 : 0] p2;
    wire [31 : 0] g2;
    wire          c2;
    wire [31 : 0] ps1;

    wire [28 : 0] p3;
    wire [31 : 0] g3;
    wire          c3;
    wire [31 : 0] ps2;

    wire [24 : 0] p4;
    wire [31 : 0] g4;
    wire          c4;
    wire [31 : 0] ps3;

    wire [16 : 0] p5;
    wire [31 : 0] g5;
    wire          c5;
    wire [31 : 0] ps4;

    wire [31 : 0] p6;
    wire [31 : 0] g6;
    wire          c6;

    kogge_stone_cell_1 s1(carry_in, input_A, input_B, p1, g1, c1);
    kogge_stone_cell_2 s2(c1, p1, g1, c2,  p2, g2, ps1);
    kogge_stone_cell_3 s3(c2, p2, g2, ps1, c3, p3, g3, ps2);
    kogge_stone_cell_4 s4(c3, p3, g3, ps2, c4, p4, g4, ps3);
    kogge_stone_cell_5 s5(c4, p4, g4, ps3, c5, p5, g5, ps4);
    kogge_stone_cell_6 s6(c5, p5, g5, ps4, c6, p6, g6);
    kogge_stone_cell_7 s7(c6, p6, g6, sum, carry_out);
endmodule

module kogge_stone_cell_7
(
    input  wire          i_c0,
    input  wire [31 : 0] i_pk,
    input  wire [31 : 0] i_gk,
    output wire [31 : 0] o_s,
    output wire          o_carry
);
    assign o_carry     = i_gk[31];
    assign o_s[0]      = i_c0 ^ i_pk[0];
    assign o_s[31 : 1] = i_gk[30 : 0] ^ i_pk[31 : 1];
endmodule

module kogge_stone_cell_6
(
    input  wire        i_c0,
    input  wire [16 : 0] i_pk,
    input  wire [31 : 0] i_gk,
    input  wire [31 : 0] i_p_save,
    output wire        o_c0,
    output wire [31 : 0] o_pk,
    output wire [31 : 0] o_gk
);

    wire [16 : 0] gkj;

    assign o_c0         = i_c0;
    assign o_pk         = i_p_save[31 : 0];
    assign gkj[0]       = i_c0;
    assign gkj[16 : 1]  = i_gk[15 : 0];
    assign o_gk[15 : 0] = i_gk[15 : 0];

    genvar i;
    generate
    for (i = 1; i <= 16; i = i + 1) begin
        Grey_Cell gc 
        (
            .i_gj(gkj[i]),
            .i_pk(i_pk[i]),
            .i_gk(i_gk[i+15]),
            .o_g(o_gk[i+15])
        );
    end
    endgenerate
endmodule

module kogge_stone_cell_5
(
    input  wire          i_c0,
    input  wire [24 : 0] i_pk,
    input  wire [31 : 0] i_gk,
    input  wire [31 : 0] i_p_save,
    output wire          o_c0,
    output wire [16 : 0] o_pk,
    output wire [31 : 0] o_gk,
    output wire [31 : 0] o_p_save
);

    wire [24 : 0] gkj;
    wire [16 : 0] pkj;

    assign o_c0        = i_c0;
    assign o_p_save    = i_p_save[31 : 0];
    assign gkj[0]      = i_c0;
    assign gkj[24 : 1] = i_gk[23 : 0];
    assign pkj         = i_pk[16 : 0];
    assign o_gk[6 : 0] = i_gk[6  : 0];

    genvar i;
    generate
    for (i = 0; i < 8; i = i + 1) begin
        Grey_Cell gc 
        (
            .i_gj(gkj[i]),
            .i_pk(i_pk[i]),
            .i_gk(i_gk[i+7]),
            .o_g(o_gk[i+7])
        );
    end
    endgenerate

    genvar j;
    generate
    for (j = 0; j < 17; j = j + 1) begin
        Black_Cell bc 
        (
            .i_pj(pkj[j]),
            .i_gj(gkj[j+8]),
            .i_pk(i_pk[j+8]),
            .i_gk(i_gk[j+15]),
            .o_g(o_gk[j+15]),
            .o_p(o_pk[j])
        );
    end
    endgenerate
endmodule

module kogge_stone_cell_4
(
    input  wire          i_c0,
    input  wire [28 : 0] i_pk,
    input  wire [31 : 0] i_gk,
    input  wire [31 : 0] i_p_save,
    output wire          o_c0,
    output wire [24 : 0] o_pk,
    output wire [31 : 0] o_gk,
    output wire [31 : 0] o_p_save
);

    wire [28 : 0] gkj;
    wire [24 : 0] pkj;

    assign o_c0        = i_c0;
    assign o_p_save    = i_p_save[31 : 0];
    assign gkj[0]      = i_c0;
    assign gkj[28 : 1] = i_gk[27 : 0];
    assign pkj         = i_pk[24 : 0];
    assign o_gk[2 : 0] = i_gk[2  : 0];

    genvar i;
    generate
    for (i = 0; i < 4; i = i + 1) begin
        Grey_Cell gc 
        (
            .i_gj(gkj[i]),
            .i_pk(i_pk[i]),
            .i_gk(i_gk[i+3]),
            .o_g(o_gk[i+3])
        );
    end
    endgenerate

    genvar j;
    generate
    for (j = 0; j < 25; j = j + 1) begin
        Black_Cell bc 
        (
            .i_pj(pkj[j]),
            .i_gj(gkj[j+4]),
            .i_pk(i_pk[j+4]),
            .i_gk(i_gk[j+7]),
            .o_g(o_gk[j+7]),
            .o_p(o_pk[j])
        );
    end
    endgenerate
endmodule

module kogge_stone_cell_3
(
    input  wire          i_c0,
    input  wire [30 : 0] i_pk,
    input  wire [31 : 0] i_gk,
    input  wire [31 : 0] i_p_save,
    output wire          o_c0,
    output wire [28 : 0] o_pk,
    output wire [31 : 0] o_gk,
    output wire [31 : 0] o_p_save
);

    wire [30 : 0] gkj;
    wire [28 : 0] pkj;

    assign o_c0        = i_c0;
    assign o_p_save    = i_p_save[31 : 0];
    assign gkj[0]      = i_c0;
    assign gkj[30 : 1] = i_gk[29 : 0];
    assign pkj         = i_pk[28 : 0];
    assign o_gk[0]     = i_gk[0];

    Grey_Cell  gc_0(gkj[0], i_pk[0], i_gk[1], o_gk[1]);
    Grey_Cell  gc_1(gkj[1], i_pk[1], i_gk[2], o_gk[2]);

    genvar i;
    generate
    for (i = 0; i < 29; i = i + 1) begin : blk_cells
        Black_Cell bc 
        (
            .i_pj(pkj[i]),
            .i_gj(gkj[i+2]),
            .i_pk(i_pk[i+2]),
            .i_gk(i_gk[i+3]),
            .o_g (o_gk[i+3]),
            .o_p (o_pk[i])
        );
    end
    endgenerate
endmodule

module kogge_stone_cell_2
(
    input  wire          i_c0,
    input  wire [31 : 0] i_pk,
    input  wire [31 : 0] i_gk,
    output wire          o_c0,
    output wire [30 : 0] o_pk,
    output wire [31 : 0] o_gk,
    output wire [31 : 0] o_p_save
);

    wire [31 : 0] gkj;
    wire [30 : 0] pkj;

    assign o_c0         = i_c0;
    assign o_p_save     = i_pk [31 : 0] ;
    assign gkj [0]      = i_c0;
    assign gkj [31 : 1] = i_gk [30 : 0] ;
    assign pkj          = i_pk [30 : 0] ;

    Grey_Cell gc_0(gkj[0], i_pk[0], i_gk[0], o_gk[0]);
    genvar i;
    generate
    for (i = 0; i < 31 ; i = i + 1) 
    begin
        Black_Cell bc 
        (
            .i_pj(pkj[i]),
            .i_gj(gkj[i + 1]),
            .i_pk(i_pk[i + 1]),
            .i_gk(i_gk[i + 1]),
            .o_g(o_gk[i + 1]),
            .o_p(o_pk[i])
        );
    end
    endgenerate
endmodule

module kogge_stone_cell_1
(
    input                i_c0,
    input  wire [31 : 0] i_a,
    input  wire [31 : 0] i_b,
    output wire [31 : 0] o_pk_1,
    output wire [31 : 0] o_gk_1,
    output o_c0_1
);

    assign o_c0_1 = i_c0;

    genvar i;
    generate
    for (i = 0; i < 32; i = i + 1) 
    begin
        PG pg 
        (
            .i_a(i_a[i]),
            .i_b(i_b[i]),
            .o_p(o_pk_1[i]),
            .o_g(o_gk_1[i])
        );
    end
    endgenerate
endmodule

module PG
(
    input  wire i_a,
    input  wire i_b,
    output wire o_p,
    output wire o_g
);
    assign o_p = i_a ^ i_b;
    assign o_g = i_a & i_b;
endmodule

module Black_Cell
(
    input  wire i_pj,
    input  wire i_gj,
    input  wire i_pk,
    input  wire i_gk,
    output wire o_g,
    output wire o_p
);
    assign o_g = i_gk | (i_gj & i_pk);
    assign o_p = i_pk & i_pj;
endmodule



module Grey_Cell
(
    input  wire i_gj,
    input  wire i_pk,
    input  wire i_gk,
    output wire o_g
);
    assign o_g = i_gk | (i_gj & i_pk);
endmodule