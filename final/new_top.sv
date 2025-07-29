module new_top(
	input  logic        apb_axi_clk,
   input  logic        a_reset_n,
	  
	 input logic start_read, start_write,
	 input logic [31:0] addr, data,
	 output logic [31:0] debug_rdata,
	 
	 
	 
//    input  logic        p_clk_en,
	 output  logic [31:0] aw_addr,
	 output  logic        aw_valid,
    output logic        aw_ready,
	 output  logic [31:0] w_data,
	 output  logic        w_valid,
    output logic        w_ready,
    output  logic        b_ready,
    output logic        b_valid,
    output logic [1:0]  b_resp,
	 output  logic [31:0] ar_addr,
    output  logic        ar_valid,
    output logic        ar_ready,
    output  logic        r_ready,
    output logic        r_valid,
    output logic [31:0] r_data,
    output logic [1:0]  r_resp,
	 
	 output logic [31:0] p_addr,
	 output logic [31:0] p_wdata,
    output logic        p_sel,
	 output logic        p_write,
    output logic        p_enable,
	 output logic        p_ready,
    output logic [31:0] p_rdata,
    output logic        p_slverr,
	 
	 // After implement Duplex
	output logic         uart_tx_active,  // UART Tx active flag
   output logic         uart_tx_done,    // UART Tx done flag
   output logic         uart_rx_active,  // UART Rx active flag
   output logic         uart_rx_done,    // UART Rx done flag
	output logic 			uart_send, baud_clk_w,
	output logic [ 1:0] 	uart_baud_rate,
	output logic [ 1:0] 	uart_parity_type,
   output logic [ 2:0]  uart_error,       // UART error flags
	output logic [ 7:0] 	uart_data_in,
	output logic [ 7:0] 	uart_data_out,
	output logic 			tx_start,tx_fifo_empty, tx_start_init, connect,
	output logic 			rx_enable, tx_enable,readEN_ctrl,
	output logic [ 7:0] 	fifo_tx_data_out,
	output logic [10:0] frame_man_piso,
	input  logic RX,
	output logic TX,
	output logic [10:0] Recieved_Frame,
	output logic [7:0] datain_rx_fifo,
	 
	 // Check
	 output logic  aw_full, aw_empty, aw_al_empty,
	 output logic w_full, w_empty, w_al_empty,
	 output logic req, w_req, r_req,
	 output logic w_grant, r_grant,
	 output logic done, w_done, r_done,
	 output logic [31:0] aw_addr_out,
	 output logic [31:0] debug_buffer_apb
);



	new_axi_lite_master u1(
		.aclk(apb_axi_clk),
		.areset_n(a_reset_n),
		
		.start_read(start_read),
		.start_write(start_write),
		.addr(addr),
		.data(data),
//		.wstrb(wstrb)
		.debug_rdata(debug_rdata),
		
		.AWADDR(aw_addr),
		.ARADDR(ar_addr),
		.ARVALID(ar_valid),
		.ARREADY(ar_ready),
		.RVALID(r_valid),
		.RREADY(r_ready),
		.RDATA(r_data),
		.AWVALID(aw_valid),
		.AWREADY(aw_ready),
		.WVALID(w_valid),
		.WREADY(w_ready),
		.WDATA(w_data),
//		.WSTRB(),
		.BVALID(b_valid),
		.BREADY(b_ready)
	);
	
	
	new_axi_apb_bridge u2(
	 .a_clk(apb_axi_clk), .a_reset_n(a_reset_n),
    .aw_valid(aw_valid), .aw_ready(aw_ready), .aw_addr(aw_addr),
    .w_valid(w_valid), .w_ready(w_ready), .w_data(w_data),
    .b_valid(b_valid), .b_ready(b_ready), .b_resp(b_resp),
    .ar_valid(ar_valid), .ar_ready(ar_ready), .ar_addr(ar_addr),
    .r_valid(r_valid), .r_ready(r_ready), .r_data(r_data), .r_resp(r_resp),
    .p_addr(p_addr), .p_sel(p_sel), .p_enable(p_enable),
    .p_write(p_write), .p_wdata(p_wdata), .p_rdata(p_rdata),
    .p_ready(p_ready), .p_slverr(p_slverr),
	 .aw_full(aw_full), .aw_empty(aw_empty), .aw_al_empty(aw_al_empty),
	 .w_full(w_full), .w_empty(w_empty), .w_al_empty(w_al_empty),
	 .req(req), .w_req(w_req), .r_req(r_req),
	 .w_grant(w_grant), .r_grant(r_grant),
	 .done(done), .w_done(w_done), .r_done(r_done),
	 .aw_addr_out(aw_addr_out)
	);
	
	uart_apb_bridge u3(
		.p_clk(apb_axi_clk), .p_reset_n(a_reset_n),
      .p_addr(p_addr), .p_sel(p_sel), .p_enable(p_enable), .p_write(p_write),
      .p_wdata(p_wdata), .p_rdata(p_rdata), .p_ready(p_ready), .p_slverr(p_slverr),
		.debug_buffer_apb(debug_buffer_apb),
		
		.DATA_RX(uart_data_in),
      .tx_done_flag(uart_tx_done),
		.tx_active_flag(uart_tx_active),
      .rx_done_flag(uart_rx_done),
		.error_flag(uart_error),
      .send(uart_send),
      .parity_type(uart_parity_type),
      .baud_rate(uart_baud_rate),
      .DATA_TX(uart_data_out),
      
		  
		.rx_enable(rx_enable),
		.tx_enable(tx_enable) // FROM SW
	);
	
	Duplex u4(
		.reset_n(a_reset_n),
      .send(uart_send),
      .clock(apb_axi_clk),
      .parity_type(uart_parity_type),
      .baud_rate(uart_baud_rate),
      .data_in(uart_data_out),
		.rx_enable(rx_enable),
//        .RX(RX),
		.RX(connect),

      .tx_active_flag(uart_tx_active),
      .tx_done_flag(uart_tx_done),
      .rx_active_flag(uart_rx_active),
      .rx_done_flag(uart_rx_done),
//        .TX(TX),
		.TX(connect),
      .data_out(uart_data_in),
		.baud_clk_w(baud_clk_w),
      .error_flag(uart_error),
		.readEN_ctrl(readEN_ctrl),
		.fifo_tx_data_out(fifo_tx_data_out), // output cua tx_fifo)
		.tx_start(tx_start),
		.tx_start_init(tx_start_init),
		.tx_fifo_empty(tx_fifo_empty),
		.frame_man_piso(frame_man_piso),
		.Recieved_Frame(Recieved_Frame),  // DATA PARALLEL
		.fifo_rx_data_in(datain_rx_fifo)
	);
	
endmodule
