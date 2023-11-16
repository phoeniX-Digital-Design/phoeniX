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

`ifndef CSR_INSTRUCTIONS
    `define CSRRW  3'b001
    `define CSRRS  3'b010
    `define CSRRC  3'b011
    `define CSRRWI 3'b101
    `define CSRRSI 3'b110
    `define CSRRCI 3'b111
`endif /*CSR_INSTRUCTIONS*/

`ifndef EXECUTION_UNITS_CSR
    `define ALU_CSR     12'h800
    `define MUL_CSR     12'h801
    `define DIV_CSR     12'h802
`endif /*EXECUTION_UNITS_CSR*/

module Control_Status_Unit 
(
    input  [6  : 0] opcode,
    input  [2  : 0] funct3,

    input  [31 : 0] CSR_in,
    input  [31 : 0] rs1,
    input  [4  : 0] unsigned_immediate,

    output reg [31 : 0] rd,
    output reg [31 : 0] CSR_out
);

    always @(*) 
    begin
        case ({funct3, opcode})
            {`CSRRW,  `SYSTEM} : begin rd <= CSR_in; CSR_out <= rs1; end                                        
            {`CSRRS,  `SYSTEM} : begin rd <= CSR_in; CSR_out <= CSR_in | rs1; end                               
            {`CSRRC,  `SYSTEM} : begin rd <= CSR_in; CSR_out <= CSR_in & ~rs1; end                              
            {`CSRRWI, `SYSTEM} : begin rd <= CSR_in; CSR_out <= {27'b0, unsigned_immediate}; end                
            {`CSRRSI, `SYSTEM} : begin rd <= CSR_in; CSR_out <= CSR_in | {27'b0, unsigned_immediate}; end       
            {`CSRRCI, `SYSTEM} : begin rd <= CSR_in; CSR_out <= CSR_in & ~{27'b0, unsigned_immediate}; end         
            default : begin rd <= 32'bz; CSR_out <= 32'bz; end
        endcase
    end
endmodule

module Control_Status_Register_File 
(
    input clk,
    input reset,

    input read_enable_csr,
    input write_enable_csr,

    input [11 : 0] csr_read_index,
    input [11 : 0] csr_write_index,

    input  [31 : 0] csr_write_data,
    output reg [31 : 0] csr_read_data
);

    reg [31 : 0] alu_csr;       // Arithmetic Logic Unit Aproximation Control Register
    reg [31 : 0] mul_csr;       // Multiplier Unit Aproximation Control Register
    reg [31 : 0] div_csr;       // Divider Unit Aproximation Control Register

    always @(posedge reset)
    begin
        alu_csr = 32'b0;
        mul_csr = 32'b0;
        div_csr = 32'b0;
    end

    always @(*) 
    begin
        if (read_enable_csr)
        begin
            case (csr_read_index)
                `ALU_CSR : csr_read_data <= alu_csr;
                `MUL_CSR : csr_read_data <= mul_csr;
                `DIV_CSR : csr_read_data <= div_csr;
                default  : csr_read_data <= 32'bz;
            endcase
        end
        else csr_read_data <= 32'bz;
    end    
    always @(negedge clk) 
    begin   
        if (write_enable_csr)
        begin
            case (csr_write_index)
                `ALU_CSR : alu_csr <= csr_write_data;
                `MUL_CSR : mul_csr <= csr_write_data;
                `DIV_CSR : div_csr <= csr_write_data;
            endcase
        end  
    end
endmodule