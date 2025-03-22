
`timescale 1ps / 1ps

import axi_lite_pkg::*;


module riscv_axi_tb;
   logic         aclk;
     logic         areset_n;
  
    logic [31:0]  o_axi_addr_reg;
    logic [31:0] o_axi_data_reg;
    logic   o_axi_sel_reg;
    logic [3:0]  o_axi_strobe_reg;
    logic [1:0]  o_axi_control_reg;
	 logic start_write, start_read;
    logic        checker_apb_write;
  
    logic [31:0] debug_rdata, debug_buffer;
    logic arvalid_int, awvalid_int, wvalid_int, rready_int, bready_int;
  // debug
    logic [31:0] addr_reg, wdata_reg;
    logic AWREADY, WREADY, ARREADY, RVALID, BVALID;
    logic [2:0] bridge_state, master_state;
    logic PWRITE, PSLVERR, PSEL, PENABLE, PREADY;
    logic [31:0] PRDATA, PADDR, PWDATA;
    logic         uart_tx_active;  // UART Tx active flag
    logic         uart_tx_done;    // UART Tx done flag
    logic         uart_rx_active;  // UART Rx active flag
    logic         uart_rx_done;    // UART Rx done flag
    logic [7:0] uart_data_out;
    logic uart_send, baud_clk_w;
    logic [1:0] uart_baud_rate;
    logic [1:0] uart_parity_type;
    logic [2:0]   uart_error;       // UART error flags
    logic [7:0] uart_data_in;
    logic connect;
    logic rx_enable, tx_enable;
	
	// Instantiate the AXI Lite Interface
    axi_lite_if axi_lite();
	 
	riscv_axi dut(
		.aclk(aclk),
		.areset_n(areset_n),
		.o_axi_addr_reg(o_axi_addr_reg),
		.o_axi_data_reg(o_axi_data_reg),
		.o_axi_sel_reg(o_axi_sel_reg),
		.o_axi_strobe_reg(o_axi_strobe_reg),
		.o_axi_control_reg(o_axi_control_reg),
		.checker_apb_write(checker_apb_write),
		.debug_rdata(debug_rdata),
		.arvalid_int(arvalid_int),
		.awvalid_int(awvalid_int),
		.wvalid_int(wvalid_int),
		.rready_int(rready_int),
		.bready_int(bready_int),
		.addr_reg(addr_reg),
		.wdata_reg(wdata_reg),
		.AWREADY(AWREADY),
		.WREADY(WREADY),
		.ARREADY(ARREADY),
		.RVALID(RVALID),
		.BVALID(BVALID),
		.bridge_state(bridge_state),
		.master_state(master_state),
		.PREADY(PREADY),
		.PSLVERR(PSLVERR),
		.PSEL(PSEL),
		.PENABLE(PENABLE),
		.PWRITE(PWRITE),
		.PRDATA(PRDATA),
		.PADDR(PADDR),
		.PWDATA(PWDATA),
		.debug_buffer(debug_buffer),
		.uart_tx_active(uart_tx_active),
		.uart_tx_done(uart_tx_done),
		.uart_rx_active(uart_rx_active),
		.uart_rx_done(uart_rx_done),
		.uart_data_out(uart_data_out),
		.uart_send(uart_send),
		.baud_clk_w(baud_clk_w),
		.uart_baud_rate(uart_baud_rate),
		.uart_parity_type(uart_parity_type),
		.uart_error(uart_error),
		.uart_data_in(uart_data_in),
		.connect(connect),
		.rx_enable(rx_enable),
		.tx_enable(tx_enable),
		.m_axi_lite(axi_lite.master),
		
		.start_write(start_write), //debug
		.start_read(start_read)  // debug
	);
	
	// Clock Generation
	initial begin
		aclk = 0;
		forever #5 aclk = ~aclk;  // 0.5 ns period
	end
	
	initial begin
	  areset_n = 0;
	  @(posedge aclk);
	  areset_n = 1;
	  	
	  
	  #9000000;
		$stop;
	end

endmodule