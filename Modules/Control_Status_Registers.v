module Control_Status_Register 
(
    input  [6 : 0] opcode,
    input  [2 : 0] funct3,

    input  [31 : 0] CSR,
    input  [31 : 0] rs1,
    input  [31 : 0] immediate,

    output reg [31 : 0] rd
);

reg [31 : 0] temp;
reg [31 : 0] CSR_reg;

always @(*) begin

    CSR_reg <= CSR;

    case ({funct3, opcode})
        10'b001_1110011 : begin temp <= CSR_reg; CSR_reg <= rs1; rd <= temp; end            // CSRRW
        10'b010_1110011 : begin temp <= CSR_reg; CSR_reg <= temp | rs1; rd <= temp; end     // CSRRS
        10'b011_1110011 : begin temp <= CSR_reg; CSR_reg <= temp & ~rs1; rd <= temp; end    // CSRRC
        10'b101_1110011 : begin end // CSRRWI
        10'b110_1110011 : begin end // CSRRSI
        10'b111_1110011 : begin end // CSRRSI
    endcase
end
    
endmodule