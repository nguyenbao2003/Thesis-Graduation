//import axi_lite_pkg::*;

module riscv_axi(
	input  logic         aclk,
	input logic send,
	input logic [9:0] i_io_sw,
	input  logic         areset_n,
	
	output logic [31:0]  o_axi_addr_reg,
	output logic [31:0]	o_axi_data_reg,
	output logic   		o_axi_sel_reg,
	output logic [ 3:0]  o_axi_strobe_reg,
	output logic [ 1:0]  o_axi_control_reg,
	output logic 			start_write, start_read,
	output logic        	connect,
  
	output logic [31:0] 	debug_rdata,
	output logic 			arvalid_int, awvalid_int, wvalid_int, rready_int, bready_int,
	output logic [1:0] 	b_resp_int,
	
	// debug
	output logic 			AWREADY, WREADY, ARREADY, RVALID, BVALID,
	output logic [1:0]   r_resp_int,
	output logic [ 2:0] 	bridge_state, master_state,
	output logic 			PREADY, PSLVERR, PSEL, PENABLE, PWRITE,
	output logic [31:0] 	debug_buffer,
  
	output logic         uart_tx_active,  // UART Tx active flag
	output logic         uart_tx_done,    // UART Tx done flag
	output logic         uart_rx_active,  // UART Rx active flag
	output logic         uart_rx_done,    // UART Rx done flag
	output logic [ 7:0] 	uart_data_out,
	output logic [31:0] o_io_ledr, RDATA,
	output logic 			uart_send, baud_clk_w,
	output logic [ 1:0] 	uart_baud_rate,
	output logic [ 1:0] 	uart_parity_type,
	output logic [ 2:0]  uart_error,       // UART error flags
	output logic [ 7:0] 	uart_data_in,
	output logic 			tx_start,
	output logic [ 7:0] 	fifo_tx_data_out,
	output logic 			rx_enable, tx_enable,readEN_ctrl, tx_fifo_empty,tx_start_init,
	output logic TX,
	input  logic RX,
	output logic [31:0] debug_load_from_lsu, // for debus recieved data
	output logic [10:0] frame_man_piso, Recieved_Frame,
	output logic [7:0] datain_rx_fifo,
	
	output logic [31:0] debug_buffer_apb
);
		logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
		logic [31:0] aw_addr, ar_addr, w_data;
		logic [31:0] 	PRDATA, PADDR, PWDATA;
		logic [31:0] 	addr_reg, wdata_reg;

	  logic [6:0] o_io_hex0, o_io_hex1, o_io_hex2;
  
	assign start_write = o_axi_control_reg[0];
	assign start_read = o_axi_control_reg[1];
	main dut2(
		.i_clk(aclk),
		.i_rst(areset_n),
		.i_io_sw(i_io_sw),
		.RX_DATA(RDATA),  // From RDATA of AXI
		
		// Output
		.o_io_hex0(o_io_hex0),
		.o_io_hex1(o_io_hex1),
		.o_io_hex2(o_io_hex2),
		.o_io_ledr(o_io_ledr),
		.o_axi_addr_reg(o_axi_addr_reg),
		.o_axi_data_reg(o_axi_data_reg),
		.o_axi_sel_reg(o_axi_sel_reg),
		.o_axi_strobe_reg(o_axi_strobe_reg),
		.o_axi_control_reg(o_axi_control_reg),
		.read_data_M (debug_load_from_lsu)
	);
	new_top dut1(
		.apb_axi_clk(aclk),
		.a_reset_n(areset_n),
		.start_read(o_axi_control_reg[1]),
		.start_write(o_axi_control_reg[0]),
		.addr(o_axi_addr_reg), // From lsu
		.data(o_axi_data_reg), // From lsu
		.debug_buffer_apb(debug_buffer_apb),
		
		.debug_rdata(debug_rdata),
		.aw_addr(aw_addr),
		.ar_addr(ar_addr),
		.ar_valid(arvalid_int),
		.aw_valid(awvalid_int),
		.w_valid(wvalid_int),
		.r_ready(rready_int),
		.b_ready(bready_int),
		.b_resp(b_resp_int),
		.w_data(w_data),
		.aw_ready(AWREADY),
		.w_ready(WREADY),
		.ar_ready(ARREADY),
		.r_valid(RVALID),
		.b_valid(BVALID),
		.r_resp(r_resp_int),
		.p_ready(PREADY),
		.p_slverr(PSLVERR),
		.p_sel(PSEL),
		.p_enable(PENABLE),
		.p_write(PWRITE),
		.p_rdata(PRDATA),
		.p_addr(PADDR),
		.r_data(RDATA), // date recieve from hercules
		.p_wdata(PWDATA),
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
		.tx_fifo_empty(tx_fifo_empty),
		.TX(TX),
		.RX(RX),
		.frame_man_piso(frame_man_piso),
		.Recieved_Frame(Recieved_Frame), //Data parallel from RX
		.datain_rx_fifo(datain_rx_fifo)
	);
	
	seven_led dut3(
	.io_hex0_o(o_io_hex0),
	.io_hex1_o(o_io_hex1),
	.io_hex2_o(o_io_hex2),
	
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5),
	.HEX6(HEX6),
	.HEX7(HEX7)
	);

endmodule
