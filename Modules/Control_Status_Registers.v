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
`endif


module Control_Status_Unit 
(
    input  CLK,

    input  [6 : 0] opcode,
    input  [2 : 0] funct3,

    input  [31 : 0] CSR,
    input  [31 : 0] rs1,
    input  [31 : 0] immediate,

    output reg [31 : 0] rd
);

reg [31 : 0] CSR_reg;

always @(posedge CLK) begin

    CSR_reg <= CSR;

    case ({funct3, opcode})
        {3'b001, `SYSTEM} : begin rd <= CSR_reg; CSR_reg <= rs1;  end                             // CSRRW
        {3'b010, `SYSTEM} : begin rd <= CSR_reg; CSR_reg <= CSR_reg | rs1; end                    // CSRRS
        {3'b011, `SYSTEM} : begin rd <= CSR_reg; CSR_reg <= CSR_reg & ~rs1; end                   // CSRRC
        {3'b101, `SYSTEM} : begin rd <= CSR_reg; CSR_reg <= immediate [4 : 0]; end                // CSRRWI
        {3'b110, `SYSTEM} : begin rd <= CSR_reg; CSR_reg <= CSR_reg | immediate [4 : 0]; end      // CSRRSI
        {3'b111, `SYSTEM} : begin rd <= CSR_reg; CSR_reg <= CSR_reg & ~immediate [4 : 0]; end     // CSRRSI
    endcase
end

endmodule