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

    reg [31 : 0] mstatus;       // Machine Status Register
    reg [31 : 0] mstatush;      // Upper 32 bits of Machine Status Register
    reg [31 : 0] mcause;        // Machine Exception Cause Register
    reg [31 : 0] mtvec;         // Machine Trap Vector Base Address Register
    reg [31 : 0] mep;           // Machine Exception Program Counter Register
    reg [31 : 0] mie;           // Machine Interrupt Enable Register
    reg [31 : 0] mcycle;        // Machine Cycle Counter Register
    reg [31 : 0] mtime;         // Machine Time Register
    reg [31 : 0] minstret;      // Machine Instructions Retired Register
    reg [31 : 0] misa;          // Machine ISA Register
    reg [31 : 0] mvendorid;     // Machine Vendor ID Register
    reg [31 : 0] marchid;       // Machine Architecture ID Register
    reg [31 : 0] mimpid;        // Machine Implementation ID Register
    reg [31 : 0] mscratch;      // Machine Scratch Register
    reg [31 : 0] mip;           // Machine Interrupt Pending Register
    reg [31 : 0] mhartid;       // Machine Hardware Thread ID Register
    reg [31 : 0] mcounteren;    // Machine Counter Enable Register
        
    always @(posedge reset)
    begin
        alu_csr = 32'b0;
        mul_csr = 32'b0;
        div_csr = 32'b0;

        mstatus    = 32'b0;
        mstatush   = 32'b0;
        mcause     = 32'b0;
        mtvec      = 32'b0;
        mep        = 32'b0;
        mie        = 32'b0;
        mcycle     = 32'b0;
        mtime      = 32'b0;
        minstret   = 32'b0;
        misa       = 32'b0;
        mvendorid  = 32'b0;
        marchid    = 32'b0;
        mimpid     = 32'b0;
        mscratch   = 32'b0;
        mip        = 32'b0;
        mhartid    = 32'b0;
        mcounteren = 32'bz;
    end

    always @(*) 
    begin
        if (read_enable_csr)
        begin
            case (csr_read_index)
                12'b0000_0000_0000: csr_read_data <= alu_csr;
                12'b0000_0000_0001: csr_read_data <= mul_csr;
                12'b0000_0000_0010: csr_read_data <= div_csr;
                default: csr_read_data <= 32'bz;
            endcase
        end
    end    
    always @(negedge CLK) 
    begin   
        if (write_enable_csr)
        begin
            case (csr_write_index)
                12'b0000_0000_0000: alu_csr <= csr_write_data;
                12'b0000_0000_0001: mul_csr <= csr_write_data;
                12'b0000_0000_0010: div_csr <= csr_write_data;
            endcase
        end  
    end

endmodule