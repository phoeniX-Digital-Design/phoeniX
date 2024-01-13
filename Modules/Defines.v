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

`ifndef INSTRUCTION_TYPES
    `define R_TYPE 3'b000
    `define I_TYPE 3'b001
    `define S_TYPE 3'b010
    `define B_TYPE 3'b011
    `define U_TYPE 3'b100
    `define J_TYPE 3'b101
`endif /*INSTRUCTION_TYPES*/

`ifndef EXCEPTIONS
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
`endif /*EXCEPTIONS*/

`ifndef SYSTEM_INSTRUCTIONS
    `define ECALL   12'b000000000000
    `define EBREAK  12'b000000000001
`endif /*SYSTEM_INSTRUCTIONS*/

`ifndef CSR_INSTRUCTIONS
    `define CSRRW  3'b001
    `define CSRRS  3'b010
    `define CSRRC  3'b011
    `define CSRRWI 3'b101
    `define CSRRSI 3'b110
    `define CSRRCI 3'b111
`endif /*CSR_INSTRUCTIONS*/

`ifndef EXECUTION_UNITS_CSR
    `define alucsr      12'h800
    `define mulcsr      12'h801
    `define divcsr      12'h802
    `define mcycle      12'hC00
    `define mcycleh     12'hC80 
    `define minstret    12'hC02
    `define minstreth   12'hC82               
`endif /*EXECUTION_UNITS_CSR*/

`ifndef MUL_DIV_INSTRCUTIONS
    `define MUL     3'b000
    `define MULH    3'b001
    `define MULHSU  3'b010
    `define MULHU   3'b011 

    `define DIV     3'b100
    `define DIVU    3'b101
    `define REM     3'b110
    `define REMU    3'b111

    `define MULDIV  7'b0000001
`endif /*MUL_DIV_INSTRCUTIONS*/

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

`ifndef ALU_AUXILIARY_DEFINES
    `define LOGICAL     7'b000_0000
    `define ARITHMETIC  7'b010_0000
    `define ADD         7'b000_0000     
    `define SUB         7'b010_0000

    `define RIGHT 1'b1
    `define LEFT  1'b0
`endif /*ALU_AUXILIARY_DEFINES*/

`ifndef BRANCH_INSTRUCTIONS
    `define BEQ  3'b000
    `define BNE  3'b001
    `define BLT  3'b100
    `define BGE  3'b101
    `define BLTU 3'b110
    `define BGEU 3'b111
`endif /*BRANCH_INSTRUCTIONS*/

`ifndef MEMORY_ACCESS_SIZE
    `define BYTE                3'b000
    `define HALFWORD            3'b001
    `define WORD                3'b010
    `define BYTE_UNSIGNED       3'b100
    `define HALFWORD_UNSIGNED   3'b101
`endif /*MEMORY_ACCESS_SIZE*/

`ifndef NOP_INSTRUCTION
    `define NOP                     32'h0000_0013
    `define NOP_opcode              `OP_IMM
    `define NOP_funct12             12'h000
    `define NOP_funct7              7'b000_0000
    `define NOP_funct3              3'b000
    `define NOP_immediate           12'h000
    `define NOP_instruction_type   `I_TYPE
    `define NOP_write_index         5'b00000
`endif /*NOP_INSTRUCTION*/

`ifndef CONTROL_SIGNALS
    `define DISABLE     1'b0
    `define ENABLE      1'b1
    
    `define READ        1'b0
    `define WRITE       1'b1
`endif /*CONTROL_SIGNALS*/