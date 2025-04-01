//import axi_lite_pkg::*;

module riscv_axi(
	input  logic         aclk,
	input  logic         areset_n,
	
	output logic [31:0]  o_axi_addr_reg,
	output logic [31:0]	o_axi_data_reg,
	output logic   		o_axi_sel_reg,
	output logic [ 3:0]  o_axi_strobe_reg,
	output logic [ 1:0]  o_axi_control_reg,
	output logic 			start_write, start_read,
	output logic        	checker_apb_write,
  
	output logic [31:0] 	debug_rdata,
	output logic 			arvalid_int, awvalid_int, wvalid_int, rready_int, bready_int,
	
	// debug
	output logic [31:0] 	addr_reg, wdata_reg,
	output logic 			AWREADY, WREADY, ARREADY, RVALID, BVALID,
	output logic [ 2:0] 	bridge_state, master_state,
	output logic 			PREADY, PSLVERR, PSEL, PENABLE, PWRITE,
	output logic [31:0] 	PRDATA, PADDR, PWDATA,
	output logic [31:0] 	debug_buffer,
  
  // APB_UART_TOP
//  output logic [31:0]  apb_rdata,       // APB read data
//  output logic         apb_ready,       // APB ready signal
//  output logic         apb_error,       // APB error signal
	output logic         uart_tx_active,  // UART Tx active flag
	output logic         uart_tx_done,    // UART Tx done flag
	output logic         uart_rx_active,  // UART Rx active flag
	output logic         uart_rx_done,    // UART Rx done flag
//    output logic		   uart_tx,         // UART Tx data
	output logic [ 7:0] 	uart_data_out,
//  output logic apb_pwrite_out,
//  output logic apb_penable_out,
//  output logic [4:0] apb_paddr_out,
//  output logic [31:0] apb_pwdata_out,
//  output logic apb_psel1,
//  output logic apb_psel2,
	output logic 			uart_send, baud_clk_w,
	output logic [ 1:0] 	uart_baud_rate,
	output logic [ 1:0] 	uart_parity_type,
	output logic [ 2:0]  uart_error,       // UART error flags
	output logic [ 7:0] 	uart_data_in,
	output logic 			connect, tx_start,
	output logic [ 7:0] 	fifo_tx_data_out,
	output logic 			rx_enable, tx_enable,readEN_ctrl, tx_fifo_empty,tx_start_init
);
//   logic [31:0]  o_axi_addr_reg;
//    logic [31:0] o_axi_data_reg;
//    logic   o_axi_sel_reg;
//    logic [3:0]  o_axi_strobe_reg;
//    logic [1:0]  o_axi_control_reg;
//    logic start_write, start_read;
//    logic        checker_apb_write;
//	 
//     logic [31:0] debug_rdata;
//     logic arvalid_int, awvalid_int, wvalid_int, rready_int, bready_int;
//  // debug
//     logic [31:0] addr_reg, wdata_reg;
//     logic AWREADY, WREADY, ARREADY, RVALID, BVALID;
//     logic [2:0] bridge_state, master_state;
//     logic PREADY, PSLVERR, PSEL, PENABLE, PWRITE;
//     logic [31:0] PRDATA, PADDR, PWDATA;
//     logic [31:0] debug_buffer;
 
 
	assign start_write = o_axi_control_reg[0];
	assign start_read = o_axi_control_reg[1];
	main dut2(
		.i_clk(aclk),
		.i_rst(areset_n),
		
		// Output
		.o_axi_addr_reg(o_axi_addr_reg),
		.o_axi_data_reg(o_axi_data_reg),
		.o_axi_sel_reg(o_axi_sel_reg),
		.o_axi_strobe_reg(o_axi_strobe_reg),
		.o_axi_control_reg(o_axi_control_reg)
	);

	top dut1(
		.aclk(aclk),
		.areset_n(areset_n),
		.start_read(o_axi_control_reg[1]),
		.start_write(o_axi_control_reg[0]),
		.addr(o_axi_addr_reg), // From lsu
		.data(o_axi_data_reg), // From lsu
		.wstrb(o_axi_strobe_reg),
		.psel(o_axi_sel_reg),
		
		.debug_rdata(debug_rdata),
		.arvalid_int(arvalid_int),
		.awvalid_int(awvalid_int),
		.wvalid_int(wvalid_int),
		.rready_int(rready_int),
		.bready_int(bready_int),
		.debug_buffer(debug_buffer),
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
		.uart_tx_active(uart_tx_active),
		.uart_tx_done(uart_tx_done),
		.uart_rx_active(uart_rx_active),
		.uart_rx_done(uart_rx_done),
		.uart_send(uart_send),
		.baud_clk_w(baud_clk_w),
		.uart_baud_rate(uart_baud_rate),
		.uart_parity_type(uart_parity_type),
		.uart_error(uart_error),
		.uart_data_in(uart_data_in),
		.uart_data_out(uart_data_out),
		.connect(connect),
		.rx_enable(rx_enable),
		.tx_enable(tx_enable),
		.readEN_ctrl(readEN_ctrl),
		.fifo_tx_data_out(fifo_tx_data_out),
		.tx_start(tx_start),
		.tx_start_init(tx_start_init),
		.tx_fifo_empty(tx_fifo_empty)
	);

endmodule