`include "Defines.v"

module Control_Status_Unit 
(
    input wire [ 6 : 0] opcode,
    input wire [ 2 : 0] funct3,

    input wire [31 : 0] CSR_in,
    input wire [31 : 0] rs1,
    input wire [ 4 : 0] unsigned_immediate,

    output reg [31 : 0] rd,
    output reg [31 : 0] CSR_out
);

    always @(*) 
    begin
        case ({funct3, opcode})
            {`CSRRW,  `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= rs1; end                                        
            {`CSRRS,  `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= CSR_in | rs1; end                               
            {`CSRRC,  `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= CSR_in & ~rs1; end                              
            {`CSRRWI, `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= {27'b0, unsigned_immediate}; end                
            {`CSRRSI, `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= CSR_in | {27'b0, unsigned_immediate}; end       
            {`CSRRCI, `SYSTEM}  : begin rd <= CSR_in;    CSR_out <= CSR_in & ~{27'b0, unsigned_immediate}; end         
            default             : begin rd <= 32'bz;     CSR_out <= 32'bz; end
        endcase
    end
endmodule
