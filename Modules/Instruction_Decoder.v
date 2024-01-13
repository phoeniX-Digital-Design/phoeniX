`include "Defines.v"

module Instruction_Decoder 
(
    input wire [31 : 0] instruction,

    output reg [ 2 : 0] instruction_type,
    output reg [ 6 : 0] opcode,
    output reg [ 2 : 0] funct3,
    output reg [ 6 : 0] funct7,
    output reg [11 : 0] funct12,

    output reg [ 4 : 0] read_index_1,
    output reg [ 4 : 0] read_index_2,
    output reg [ 4 : 0] write_index,
    output reg [11 : 0] csr_index,

    output reg read_enable_1,
    output reg read_enable_2,
    output reg write_enable,

    output reg read_enable_csr,
    output reg write_enable_csr
);

    always @(*) 
    begin
        opcode  = instruction[ 6 :  0];
        funct7  = instruction[31 : 25];
        funct3  = instruction[14 : 12];
        funct12 = instruction[31 : 20]; 
    end
    
    always @(*) 
    begin
        read_index_1 = instruction[19 : 15];
        read_index_2 = instruction[24 : 20];
        write_index  = instruction[11 :  7];
        csr_index    = instruction[31 : 20];
    end

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
            `R_TYPE : begin read_enable_1 = `ENABLE;    read_enable_2 = `ENABLE;    write_enable = `ENABLE;     end
            `I_TYPE : begin read_enable_1 = `ENABLE;    read_enable_2 = `DISABLE;   write_enable = `ENABLE;     end
            `S_TYPE : begin read_enable_1 = `ENABLE;    read_enable_2 = `ENABLE;    write_enable = `DISABLE;    end
            `B_TYPE : begin read_enable_1 = `ENABLE;    read_enable_2 = `ENABLE;    write_enable = `DISABLE;    end
            `U_TYPE : begin read_enable_1 = `DISABLE;   read_enable_2 = `DISABLE;   write_enable = `ENABLE;     end
            `J_TYPE : begin read_enable_1 = `DISABLE;   read_enable_2 = `DISABLE;   write_enable = `ENABLE;     end 
            default : begin read_enable_1 = `DISABLE;   read_enable_2 = `DISABLE;   write_enable = `DISABLE;    end // Raise Exception
        endcase    

        // Disable Write Signal when destination is x0
        if (write_index == 5'b00000) write_enable = `DISABLE;
    end

    always @(*) 
    begin
        // CSR register file read/write enable signals evaluation
        case ({opcode, funct3})
            {`SYSTEM, `CSRRW}   : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRS}   : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRC}   : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRWI}  : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRSI}  : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            {`SYSTEM, `CSRRCI}  : begin read_enable_csr = `ENABLE;  write_enable_csr = `ENABLE & ~(csr_index[11] & csr_index[10]); end 
            default             : begin read_enable_csr = `DISABLE; write_enable_csr = `DISABLE; end
        endcase  
    end
endmodule