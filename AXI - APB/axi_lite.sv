import axi_lite_pkg::*;

module axi_lite (
    input logic aclk,
    input logic areset_n,
	 input logic start_read, start_write,
	 output logic [31:0] debug_rdata,
	 output logic [31:0] debug_buffer,
	 output logic arvalid_int, awvalid_int, wvalid_int, rready_int, bready_int, // master
	 output logic arready_int, awready_int, rvalid_int, wready_int, bvalid_int, // slave
	 input logic [31:0] addr, data,
	 input logic [3:0] wstrb
);

    // Instantiate AXI-Lite interface
    axi_lite_if axi_lite();

    // Instantiate AXI-Lite Master
    axi_lite_master u_axi_lite_master (
        .aclk(aclk),
        .areset_n(areset_n),
		  .start_read (start_read),
		  .start_write (start_write),
		  .debug_rdata (debug_rdata),
        .m_axi_lite(axi_lite.master), // Connect master modport
		  .arvalid_int (arvalid_int),
		  .awvalid_int (awvalid_int),
		  .wvalid_int (wvalid_int),
		  .rready_int (rready_int),
		  .bready_int (bready_int),
		  .addr (addr),
		  .data (data),
		  .wstrb (wstrb)
    );

    // Instantiate AXI-Lite Slave
    axi_lite_slave u_axi_lite_slave (
        .aclk(aclk),
        .areset_n(areset_n),
		  .debug_buffer (debug_buffer),
        .s_axi_lite(axi_lite.slave), // Connect slave modport
		  .arready_int (arready_int),
		  .awready_int (awready_int),
		  .rvalid_int (rvalid_int),
		  .wready_int (wready_int),
		  .bvalid_int (bvalid_int)
    );

endmodule
