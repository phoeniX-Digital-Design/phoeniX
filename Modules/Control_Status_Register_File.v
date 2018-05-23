`include "Defines.v"

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
    
    always @(negedge clk or posedge reset) 
    begin   
        if (reset)
        begin
            alucsr_reg <= 32'b0;
            mulcsr_reg <= 32'b0;
            divcsr_reg <= 32'b0;
        end
        else if (write_enable_csr)
        begin
            case (csr_write_index)
                `alucsr : alucsr_reg <= csr_write_data;
                `mulcsr : mulcsr_reg <= csr_write_data;
                `divcsr : divcsr_reg <= csr_write_data;
            endcase
        end  
    end
endmodule