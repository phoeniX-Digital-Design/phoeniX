`ifndef CSR_OPCODE
    `define CSR_OP   7'b11_100_11
`endif


module Control_Status_Register 
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
        {3'b001, `CSR_OP} : begin rd <= CSR_reg; CSR_reg <= rs1;  end                             // CSRRW
        {3'b010, `CSR_OP} : begin rd <= CSR_reg; CSR_reg <= CSR_reg | rs1; end                    // CSRRS
        {3'b011, `CSR_OP} : begin rd <= CSR_reg; CSR_reg <= CSR_reg & ~rs1; end                   // CSRRC
        {3'b101, `CSR_OP} : begin rd <= CSR_reg; CSR_reg <= immediate [4 : 0]; end                // CSRRWI
        {3'b110, `CSR_OP} : begin rd <= CSR_reg; CSR_reg <= CSR_reg | immediate [4 : 0]; end      // CSRRSI
        {3'b111, `CSR_OP} : begin rd <= CSR_reg; CSR_reg <= CSR_reg & ~immediate [4 : 0]; end     // CSRRSI
    endcase
end
    
endmodule