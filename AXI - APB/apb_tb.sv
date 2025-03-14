`timescale 1ns / 1ps

module apb_tb;
    // Clock and Reset
    logic PCLK;
    logic PRESETn;

    // APB Inputs
    logic SWRITE;
    logic [31:0] SADDR, SWDATA;
    logic [3:0] SSTRB;
    logic [2:0] SPROT;
    logic transfer;
	 logic PSEL, PENABLE, PWRITE, PREADY, PSLVERR;
    
    // APB Outputs
    logic [31:0] PRDATA;

    // Clock generation
    always #5 PCLK = ~PCLK; // 10ns clock period

    // Instantiate DUT (Device Under Test)
    apb_wrapper DUT (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .SWRITE(SWRITE),
        .SADDR(SADDR),
        .SWDATA(SWDATA),
        .SSTRB(SSTRB),
        .SPROT(SPROT),
        .transfer(transfer),
        .PRDATA(PRDATA),
		  .PSEL(PSEL),
		  .PENABLE(PENABLE),
		  .PWRITE(PWRITE),
		  .PREADY(PREADY),
		  .PSLVERR(PSLVERR)
    );

    // Test Procedure
    initial begin
        // Initialize signals
        PCLK = 0;
        PRESETn = 0;
        SWRITE = 0;
        SADDR = 0;
        SWDATA = 0;
        SSTRB = 0;
        SPROT = 0;
        transfer = 0;
        
        // Apply Reset
        #10 PRESETn = 1;
        #10;

        // Test Write Operation
        SADDR = 32'h0000_0004;
        SWDATA = 32'hDEADBEEF;
        SWRITE = 1;
        SSTRB = 4'b1111; // Full word write
        transfer = 1;
        #10 transfer = 0;
        #20;

        // Test Read Operation
        SADDR = 32'h0000_0004;
        SWRITE = 0;
        SSTRB = 4'b0000;
        transfer = 1;
        #10 transfer = 0;
        #20;

        // Display Read Data
        $display("Read Data: %h", PRDATA);
        
        // Finish Simulation
        #50 $finish;
    end

endmodule
