
`timescale 1ps / 1ps

//import axi_lite_pkg::*;


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
    logic AWVALID, AWREADY, WVALID, WREADY, BREADY, BVALID, ARVALID, ARREADY, RREADY, RVALID;
  // debug
    logic [31:0] addr_reg, wdata_reg;
    logic [2:0] bridge_state, master_state;
    logic PWRITE, PSLVERR, PSEL, PENABLE, PREADY;
    logic [31:0] PRDATA, RDATA, PADDR, PWDATA;
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
    logic rx_enable, tx_enable, readEN_ctrl;
	 logic [7:0] fifo_tx_data_out;
	 logic tx_start,tx_start_init, tx_fifo_empty;
	 logic [31:0] debug_load_from_lsu, o_io_ledr;
//	 logic TX, RX;
	
	// Instantiate the AXI Lite Interface
//    axi_lite_if axi_lite();
	 
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
		.arvalid_int(ARVALID),
		.awvalid_int(AWVALID),
		.wvalid_int(WVALID),
		.rready_int(RREADY),
		.bready_int(BREADY),
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
		.RDATA (RDATA),
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
//		.m_axi_lite(axi_lite.master),
		.readEN_ctrl(readEN_ctrl),
		.fifo_tx_data_out(fifo_tx_data_out),
		
		// debug recieved data from herculus
		.debug_load_from_lsu(debug_load_from_lsu),
		.o_io_ledr(o_io_ledr),
		
		.start_write(start_write), //debug
		.start_read(start_read),  // debug
		.tx_start(tx_start),
		.tx_start_init(tx_start_init),
		.tx_fifo_empty(tx_fifo_empty)
//		.RX(RX),
//		.TX(TX)
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