`include "AXI4_Lite_Interface.v"

module AXI4_Lite_Interface_Testbench;

    reg axi_clk;
    reg resetn;
    
    wire axi_awvalid;
    reg  axi_awready;
    wire  [31 : 0] axi_awaddr;
    wire  [2  : 0] axi_awprot;
    
    wire axi_wvalid;
    reg  axi_wready;
    wire [31 : 0] axi_wdata;
    wire [3  : 0] axi_wstrb;
    
    reg  axi_bvalid;
    wire axi_bready;
    
    wire axi_arvalid;
    reg  axi_arready;
    wire [31 : 0] axi_araddr;
    wire [2  : 0] axi_arprot;
    
    reg  axi_rvalid;
    wire axi_rready;
    wire [31 : 0] axi_rdata;

    reg valid;
    reg instr;
    reg [31 : 0] addr;
    reg [31 : 0] wdata;
    reg [3  : 0] wstrb;
    wire ready;
    wire [31 : 0] rdata;

    AXI4_Lite_Interface uut 
    (
        .axi_clk(axi_clk),
        .resetn(resetn),
        .axi_awvalid(axi_awvalid),
        .axi_awready(axi_awready),
        .axi_awaddr(axi_awaddr),
        .axi_awprot(axi_awprot),
        .axi_wvalid(axi_wvalid),
        .axi_wready(axi_wready),
        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_bvalid(axi_bvalid),
        .axi_bready(axi_bready),
        .axi_arvalid(axi_arvalid),
        .axi_arready(axi_arready),
        .axi_araddr(axi_araddr),
        .axi_arprot(axi_arprot),
        .axi_rvalid(axi_rvalid),
        .axi_rready(axi_rready),
        .axi_rdata(axi_rdata),
        .valid(valid),
        .instr(instr),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .ready(ready),
        .rdata(rdata)
    );
    
    initial begin

        $dumpfile("AXI4_Lite_Interface.vcd");
        $dumpvars(0, AXI4_Lite_Interface_Testbench);

        resetn  = 0;
        axi_clk = 0;
        resetn  = 0;
        valid   = 0;
        instr   = 0;
        addr    = 0;
        wdata   = 0;
        wstrb   = 0;
        axi_bvalid = 0;
        #5;
        resetn = 1;
        #10;

        // Test 1: Write operation
        valid = 1;
        instr = 1;
        axi_bvalid = 1;
        axi_wready = 1;
        axi_awready = 0;
        axi_arready = 0;
        addr  = 32'h12345678;
        wdata = 32'hABCDEF01;
        wstrb = 4'b1111;
        #10;

        // Test 2: Read operation
        valid = 1;
        instr = 0;
        axi_bvalid = 0;
        axi_wready = 0;
        axi_awready = 1;
        axi_arready = 1;
        addr  = 32'h87654321;
        wdata = 32'h00000000;
        wstrb = 4'b0000;
        #10;

        $finish;

    end

endmodule