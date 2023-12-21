`include "Defines.v"

module Instruction_Decoder 
(
    input  [31 : 0] instruction,

    output [ 6 : 0] opcode,
    output [ 2 : 0] funct3,
    output [ 6 : 0] funct7,
    output [11 : 0] funct12,

    output [ 4 : 0] read_index_1,
    output [ 4 : 0] read_index_2,
    output [ 4 : 0] write_index,
    output [11 : 0] csr_index,

    output reg [2 : 0] instruction_type,
    output reg read_enable_1,
    output reg read_enable_2,
    output reg write_enable,

    output reg read_enable_csr,
    output reg write_enable_csr
);

    assign opcode = instruction [6 : 0];
    assign funct7  = instruction[31 : 25];
    assign funct3  = instruction[14 : 12];
    assign funct12 = instruction[31 : 20];
    
    assign read_index_1 = instruction[19 : 15];
    assign read_index_2 = instruction[24 : 20];
    assign write_index  = instruction[11 :  7];
    assign csr_index    = instruction[31 : 20];
    
    always @(*)
    begin
        case (opcode)
            `OP         : instruction_type = `R_TYPE;
            `OP_FP      : instruction_type = `R_TYPE;

            `LOAD       : instruction_type = `I_TYPE;
            `LOAD_FP    : instruction_type = `I_TYPE;
            `OP_IMM     : instruction_type = `I_TYPE;
            `OP_IMM_32  : instruction_type = `I_TYPE;
            `JALR       : instruction_type = `I_TYPE;
            `SYSTEM     : instruction_type = `I_TYPE; 

            `STORE      : instruction_type = `S_TYPE;
            `STORE_FP   : instruction_type = `S_TYPE;

            `BRANCH     : instruction_type = `B_TYPE;

            `AUIPC      : instruction_type = `U_TYPE;
            `LUI        : instruction_type = `U_TYPE;

            `JAL        : instruction_type = `J_TYPE;
            default     : instruction_type = 3'bz;
        endcase
    end

    always @(*) 
    begin
        // Register File read/write enable signals evaluation
        case (instruction_type)
            `R_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b1; end
            `I_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b0; write_enable = 1'b1; end
            `S_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b0; end
            `B_TYPE : begin read_enable_1 = 1'b1; read_enable_2 = 1'b1; write_enable = 1'b0; end
            `U_TYPE : begin read_enable_1 = 1'b0; read_enable_2 = 1'b0; write_enable = 1'b1; end
            `J_TYPE : begin read_enable_1 = 1'b0; read_enable_2 = 1'b0; write_enable = 1'b1; end 
            default : begin read_enable_1 = 1'b0; read_enable_2 = 1'b0; write_enable = 1'b0; end // Raise Exception
        endcase    

        // Disable Write Signal when destination is x0
        if (write_index == 5'b00000)
            write_enable = 1'b0;
    end

    always @(*) 
    begin
        // CSR register file read/write enable signals evaluation
        case ({opcode, funct3})
            {`SYSTEM, `CSRRW}  : begin read_enable_csr = 1'b1; write_enable_csr = 1'b1 & ~(csr_index[11] & csr_index[10]); end // CSRRW
            {`SYSTEM, `CSRRS}  : begin read_enable_csr = 1'b1; write_enable_csr = 1'b1 & ~(csr_index[11] & csr_index[10]); end // CSRRS
            {`SYSTEM, `CSRRC}  : begin read_enable_csr = 1'b1; write_enable_csr = 1'b1 & ~(csr_index[11] & csr_index[10]); end // CSRRC
            {`SYSTEM, `CSRRWI} : begin read_enable_csr = 1'b1; write_enable_csr = 1'b1 & ~(csr_index[11] & csr_index[10]); end // CSRRWI
            {`SYSTEM, `CSRRSI} : begin read_enable_csr = 1'b1; write_enable_csr = 1'b1 & ~(csr_index[11] & csr_index[10]); end // CSRRSI
            {`SYSTEM, `CSRRCI} : begin read_enable_csr = 1'b1; write_enable_csr = 1'b1 & ~(csr_index[11] & csr_index[10]); end // CSRRCI
            default : begin read_enable_csr = 1'b0; write_enable_csr = 1'b0; end
        endcase  
    end
endmodule