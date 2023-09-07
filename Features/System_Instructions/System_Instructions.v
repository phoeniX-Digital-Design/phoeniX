//`include "CSR_Register_File.v"

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

`define SYS_FUNCT3 3'b000
`define SYS_FUNCT7 3'b000
`define ECALL      5'b00_000
`define EBREAK     7'b0_000_000

`ifndef EXCEPTIONS 
    // The RISC-V privileged specs define the following exceptions, in decreasing priority order:
    `define INSTRUCTION_ADDRESS_MISALLIGNED 4'b0000
    `define INSTRUCTION_ACCESS_FAULT        4'b0001
    `define ILLEGAL_INSTRUCTION             4'b0010
    `define BREAKPOINT                      4'b0011
    `define LOAD_ADDRESS_MISALLIGNED        4'b0100
    `define LOAD_ACCESS_FAULT               4'b0101
    `define STORE_AMO_ADDRESS_MISALLIGNED   4'b0110
    `define STORE_AMO_ACCESS_FAULT          4'b0111
    `define ECALL_FROM_U_MODE               4'b1000
    `define ECALL_FROM_M_MODE               4'b1001
    `define INSTRUCTION_PAGE_FAULT          4'b1010
    `define LOAD_PAGE_FAULT                 4'b1011
    `define STORE_AMO_PAGE_FAULT            4'b1100
`endif

module System_Instructions 
(
    input [6 : 0] opcode,
    input [4 : 0] read_index_2,
    input [2 : 0] funct3,
    input [6 : 0] funct7
);

reg [3 : 0] exception_type; 

always @(*) 
begin
    case ({funct7, read_index_2, funct3, opcode})
        {`SYS_FUNCT7, `ECALL,  `SYS_FUNCT3, `SYSTEM}: begin /* RAISE EXCEPTION */end  // ECALL
        {`SYS_FUNCT7, `EBREAK, `SYS_FUNCT3, `SYSTEM}: begin /* RAISE EXCEPTION */end  // EBREAK
    endcase
end
// CSR Register File must be instantiated:
// Exceptions flags are CSRs

// CSR_Register_File csr_regfile (...)
    
endmodule