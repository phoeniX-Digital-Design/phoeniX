`define BEQ  0
`define BNE  1
`define BLT  2
`define BGE  3
`define BLTU 4
`define BGEU 5

module Branch_Unit 
(
    input [6 : 0] opcode,
    input [2 : 0] funct3,
    input [6 : 0] funct7,

    input [31 : 0] bus_rs1,
    input [31 : 0] bus_rs2,

    input branch_signal,     // From Instruction_Decoder
      
    output reg branch_enable // Goes to Fetch_Unit
);

    reg [2 : 0] branch_type;

    always @(*) begin

            if (branch_signal) begin                  // B-TYPE Instructions

                casex ({funct7, funct3, opcode})
                17'bxxxxxxx_000_1100011 : begin     // BEQ
                    branch_type = `BEQ;
                    if ($signed(bus_rs1) == $signed(bus_rs2))
                            branch_enable = 1'b1;
                end
                17'bxxxxxxx_001_1100011 : begin     // BNE
                    branch_type = `BNE;
                    if ($signed(bus_rs1) != $signed(bus_rs2))
                            branch_enable = 1'b1;
                end
                17'bxxxxxxx_100_1100011 : begin     // BLT
                    branch_type = `BLT;
                    if ($signed(bus_rs1) < $signed(bus_rs2))
                            branch_enable = 1'b1;
                end
                17'bxxxxxxx_101_1100011 : begin     // BGE
                    branch_type = `BGE;
                    if ($signed(bus_rs1) >= $signed(bus_rs2))
                            branch_enable = 1'b1;
                end
                17'bxxxxxxx_110_1100011 : begin     // BLTU
                    branch_type = `BLTU;
                    if (bus_rs1 < bus_rs2)
                            branch_enable = 1'b1;
                end
                17'bxxxxxxx_111_1100011 : begin     // BGEU
                    branch_type = `BGEU;
                    if (bus_rs1 >= bus_rs2)
                            branch_enable = 1'b1;
                end
                default: branch_enable = 1'b0;
                endcase

            end else
                branch_enable = 1'b0;

      end  
      
endmodule