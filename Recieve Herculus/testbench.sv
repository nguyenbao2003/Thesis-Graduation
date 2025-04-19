`timescale 1ps / 1ps

module testbench;

   logic clk;             // System clock
   logic reset_n;         // Active low reset
	logic					  apb_en;    // Transfer request
	logic			[1:0]   apb_sel;         // APB slave select
	logic			[4:0]   apb_addr;        // APB address
	logic					  apb_write;       // APB write control
	logic			[31:0]  apb_wdata;       // APB write data
//	logic						uart_rx;         // UART received data
	
	/* OUTPUT */
	logic		[31:0]  apb_rdata;       // APB read data
	logic            connect;
	logic					apb_ready;       // APB ready signal
	logic		[7:0] uart_data_out;
	logic		[1:0] uart_baud_rate;
	logic		[1:0] uart_parity_type;
	logic		uart_send;
	logic		apb_psel1;

	logic					apb_error;       // APB error signal
	logic					uart_tx_active;  // UART Tx active flag
	logic					uart_tx_done;    // UART Tx done flag
	logic					uart_rx_active;  // UART Rx active flag
	logic					uart_rx_done;    // UART Rx done flag
	logic             baud_clk_w;
	logic    [7:0]    uart_data_in;
//	logic					uart_tx;         // UART Tx data
	
	logic		apb_pwrite_out;
	logic		apb_penable_out;
	logic		[4:0] apb_paddr_out;
	logic		[31:0] apb_pwdata_out;
	
	logic		apb_psel2;
	
	logic		[2:0]   uart_error;       // UART error flags
	
	APB_UART_Top dut(
	.clk(clk),
	.reset_n(reset_n),
	.apb_en(apb_en),
	.apb_sel(apb_sel),
	.apb_addr(apb_addr),
	.apb_write(apb_write),
	.apb_wdata(apb_wdata),
	
	/* OUTPUT */
	.apb_rdata(apb_rdata),
	.apb_ready(apb_ready),
	.apb_error(apb_error),
	.uart_tx_active(uart_tx_active),
	.uart_tx_done(uart_tx_done),
	.uart_rx_active(uart_rx_active),
	.uart_rx_done(uart_rx_done),
	.uart_data_out(uart_data_out),
	.apb_pwrite_out(apb_pwrite_out),
	.apb_penable_out(apb_penable_out),
	.apb_paddr_out(apb_paddr_out),
	.apb_pwdata_out(apb_pwdata_out),
	.apb_psel1(apb_psel1),
	.apb_psel2(apb_psel2),
	.uart_send(uart_send),
	.uart_baud_rate(uart_baud_rate),
	.uart_parity_type(uart_parity_type),
	.uart_error(uart_error),
	.connect(connect),
	.uart_data_in(uart_data_in),
	.baud_clk_w(baud_clk_w)
	);
	
	
// Clock Generation
	initial begin
		clk = 0;
		forever #5 clk = ~clk;  // 0.5 ns period
	end
	
	initial begin
	  reset_n = 0;
	  @(posedge clk);
	  reset_n = 1;
	  
	  apb_addr = 5'b00000;
	  apb_sel = 2'b01;
	  apb_wdata = 32'h2;
	  apb_write = 1'b1;
	  apb_en = 1'b1;
	  
	  @(posedge clk);
	  @(posedge clk);
	  @(posedge clk);
	  apb_addr = 5'h4;
	  apb_wdata = 32'hC;
	  
	  @(posedge clk);
	  @(posedge clk);
	  @(posedge clk);
	  apb_addr = 5'hC;
	  apb_wdata = 32'hBEEF;
	  
	  @(posedge clk);
	  @(posedge clk);
	  @(posedge clk);
	  apb_addr = 5'hC;
	  apb_wdata = 32'hBEAA;
	  
	  @(posedge clk);
	  @(posedge clk);
	  @(posedge clk);
	  apb_addr = 5'hC;
	  apb_wdata = 32'hBEBB;
	  
	  @(posedge clk);
	  @(posedge clk);
	  @(posedge clk);
	  apb_addr = 5'b00000;
	  apb_wdata = 32'h1;
	  @(posedge clk);
	  @(posedge clk);
	  @(posedge clk);
	  apb_write = 1'b0;
     apb_addr = 5'hC;
	   
	  #900000;
		$stop;
	end
	
endmodule