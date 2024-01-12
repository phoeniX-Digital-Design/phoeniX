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
            {`CSRRW,  `SYSTEM}  : begin rd = CSR_in;    CSR_out = rs1; end                                        
            {`CSRRS,  `SYSTEM}  : begin rd = CSR_in;    CSR_out = CSR_in | rs1; end                               
            {`CSRRC,  `SYSTEM}  : begin rd = CSR_in;    CSR_out = CSR_in & ~rs1; end                              
            {`CSRRWI, `SYSTEM}  : begin rd = CSR_in;    CSR_out = {27'b0, unsigned_immediate}; end                
            {`CSRRSI, `SYSTEM}  : begin rd = CSR_in;    CSR_out = CSR_in | {27'b0, unsigned_immediate}; end       
            {`CSRRCI, `SYSTEM}  : begin rd = CSR_in;    CSR_out = CSR_in & ~{27'b0, unsigned_immediate}; end         
            default             : begin rd = 32'bz;     CSR_out = 32'bz; end
        endcase
    end
endmodule

module Control_Status_Register_File 
(
    input wire clk,
    input wire reset,

    input wire read_enable_csr,
    input wire write_enable_csr,

    input wire [11 : 0] csr_read_index,
    input wire [11 : 0] csr_write_index,

    input wire [31 : 0] csr_write_data,
    output reg [31 : 0] csr_read_data
);

    reg [31 : 0] alucsr_reg;       // Arithmetic Logic Unit Aproximation Control Register
    reg [31 : 0] mulcsr_reg;       // Multiplier Unit Aproximation Control Register
    reg [31 : 0] divcsr_reg;       // Divider Unit Aproximation Control Register

    reg [63 : 0] mcycle_reg;
    reg [63 : 0] minstret_reg;

    always @(posedge reset)
    begin
        alucsr_reg      = 32'b0;
        mulcsr_reg      = 32'b0;
        divcsr_reg      = 32'b0;
        mcycle_reg      = 64'b0;
        minstret_reg    = 64'b0;
    end

    always @(*) 
    begin
        if (read_enable_csr)
        begin
            case (csr_read_index)
                `alucsr :       csr_read_data = alucsr_reg;
                `mulcsr :       csr_read_data = mulcsr_reg;
                `divcsr :       csr_read_data = divcsr_reg;
                `mcycle :       csr_read_data = mcycle_reg[31 :  0];
                `mcycleh :      csr_read_data = mcycle_reg[63 : 32];
                `minstret :     csr_read_data = minstret_reg[31 :  0];
                `minstreth :    csr_read_data = minstret_reg[63 : 32];
                default :       csr_read_data = 32'bz;
            endcase
        end
        else csr_read_data <= 32'bz;
    end    
    
    always @(negedge clk) 
    begin   
        if (write_enable_csr)
        begin
            case (csr_write_index)
                `alucsr : alucsr_reg <= csr_write_data;
                `mulcsr : mulcsr_reg <= csr_write_data;
                `divcsr : divcsr_reg <= csr_write_data;
            endcase
        end  
    end
endmodule