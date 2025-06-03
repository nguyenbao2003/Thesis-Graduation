module test_axi_apb_bridge(
	input  logic aclk,
	input  logic areset_n,
  
	input  logic start_read,
	input  logic start_write,
	input  logic [31:0] 	addr, data,
	input  logic [3:0] 	wstrb,
	input  logic  			psel,
	input  logic rx_done_flag,
  
	output logic [31:0] 	debug_rdata,
	output logic 			arvalid_int, awvalid_int, wvalid_int, rready_int, bready_int, // master

	output logic [31:0] 	debug_buffer,
  
	// debug
	output logic [31:0] 	addr_reg, wdata_reg,
	output logic 			AWREADY, WREADY, ARREADY, RVALID, BVALID,
	output logic  [2:0] 	bridge_state, master_state,
	output logic 			PREADY, PSLVERR, PSEL, PENABLE, PWRITE,
	output logic [31:0] 	PRDATA, PADDR, PWDATA, RDATA,
 
	
	output logic [31:0] ARADDR, AWADDR, WDATA
);	 
	axi_lite_master u1(
		.aclk(aclk),
		.areset_n(areset_n),
		.start_read (start_read),
		.start_write (start_write),
		.debug_rdata (debug_rdata),
		.arvalid_int (arvalid_int),
		.awvalid_int (awvalid_int),
		.wvalid_int (wvalid_int),
		.rready_int (rready_int),
		.bready_int (bready_int),
		.addr (addr),
		.data (data),
		.wstrb (wstrb),
	  
		// debugs
		.AWREADY(AWREADY),
		.WREADY(WREADY),
		.ARREADY(ARREADY),
		.BVALID(BVALID),
		.RVALID(RVALID),
		.ARADDR(ARADDR),
		.AWADDR(AWADDR),
		.s_WDATA(WDATA),
		.s_rdata(RDATA),
		.state(master_state)
	);
	
	axi_apb_bridge u2(
	  .ACLK(aclk),
	  .ARESETn(areset_n),
	  .i_psel (psel),
	  
	  // from axi master
	  .AWADDR(AWADDR),
	  .WDATA(WDATA),
	  .ARADDR(ARADDR),
	  .ARVALID(arvalid_int),
	  .WVALID(wvalid_int),
	  .AWVALID(awvalid_int),
	  .BREADY(bready_int),
	  .RREADY(rready_int),
	  
	  // from apb slave
	  .PREADY(PREADY),
//	  .PSLVERR(PSLVERR),
	  .PRDATA(PRDATA),
	  
	  // to apb slave
	  .PSEL(PSEL),
	  .PENABLE(PENABLE),
	  .PWRITE(PWRITE),
	  .PADDR(PADDR),
	  .PWDATA(PWDATA),
	  
	  // to axi master
	  .BVALID(BVALID),
	  .RVALID(RVALID),
//	  .BRESP(m_axi_lite.bresp),
//	  .RRESP(m_axi_lite.rresp),
	  .AWREADY(AWREADY),
	  .WREADY(WREADY),
	  .ARREADY(ARREADY),
	  .RDATA(RDATA),
	  
	  //debug
	  .addr_reg(addr_reg),
	  .wdata_reg(wdata_reg),
	  .state(bridge_state)
	);
	
	
	// Instantiate UART_APB_Bridge
    NEW_UART_APB_Bridge uart_apb_bridge_inst (
        .PCLK(aclk),
        .PRESETn(areset_n),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
		  .debug_buffer (debug_buffer),
		  .rx_done_flag(rx_done_flag)
    );
	 
//	 // Instantiate Duplex UART
//    Duplex uart_inst (
//        .reset_n(areset_n),
//        .send(uart_send),
//        .clock(aclk),
//        .parity_type(uart_parity_type),
//        .baud_rate(uart_baud_rate),
//        .data_in(uart_data_out),
//		  .rx_enable(rx_enable),
////        .RX(RX),
//		  .RX(connect),
//
//        .tx_active_flag(uart_tx_active),
//        .tx_done_flag(uart_tx_done),
//        .rx_active_flag(uart_rx_active),
//        .rx_done_flag(uart_rx_done),
////        .TX(TX),
//		  .TX(connect),
//        .data_out(uart_data_in),
//		  .baud_clk_w(baud_clk_w),
//        .error_flag(uart_error),
//		  .readEN_ctrl(readEN_ctrl),
//		  .fifo_tx_data_out(fifo_tx_data_out), // output cua tx_fifo)
//		  .tx_start(tx_start),
//		  .tx_start_init(tx_start_init),
//		  .tx_fifo_empty(tx_fifo_empty),
//		  .frame_man_piso(frame_man_piso),
//		  .Recieved_Frame(Recieved_Frame),  // DATA PARALLEL
//		  .fifo_rx_data_in(datain_rx_fifo)
//    );
	 
endmodule