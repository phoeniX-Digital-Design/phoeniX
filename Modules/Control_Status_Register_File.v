module Control_Status_Register_File 
(
    input CLK,
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

/*
    always @(posedge reset)
    begin
        alu_csr = 32'b0;
        mul_csr = 32'b0;
        div_csr = 32'b0;
    end
*/

    always @(*) 
    begin
        if (read_enable_csr)
        begin
            case (csr_read_index)
                12'h800: csr_read_data <= alu_csr;
                12'h801: csr_read_data <= mul_csr;
                12'h802: csr_read_data <= div_csr;
                default: csr_read_data <= 32'bz;
            endcase
        end
    end    
    always @(negedge CLK) 
    begin   
        if (write_enable_csr)
        begin
            case (csr_write_index)
                12'h800: alu_csr <= csr_write_data;
                12'h801: mul_csr <= csr_write_data;
                12'h802: div_csr <= csr_write_data;
            endcase
        end  
    end

endmodule