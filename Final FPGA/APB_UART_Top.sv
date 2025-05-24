module APB_UART_Top (
    input  logic         clk,             // System clock
    input  logic         reset_n,         // Active low reset
    input  logic         apb_en,    // Transfer request
    input  logic [1:0]   apb_sel,         // APB slave select
    input  logic [4:0]   apb_addr,        // APB address
    input  logic         apb_write,       // APB write control
    input  logic [31:0]  apb_wdata,       // APB write data
//    input  logic 		   uart_rx,         // UART received data

    output logic [31:0]  apb_rdata,       // APB read data
    output logic         apb_ready,       // APB ready signal
    output logic         apb_error,       // APB error signal
    output logic         uart_tx_active,  // UART Tx active flag
    output logic         uart_tx_done,    // UART Tx done flag
    output logic         uart_rx_active,  // UART Rx active flag
    output logic         uart_rx_done,    // UART Rx done flag
//    output logic		   uart_tx,         // UART Tx data
	 output logic [7:0] 	uart_data_out,
	 output logic 			apb_pwrite_out,
    output logic 			apb_penable_out,
    output logic [4:0] 	apb_paddr_out,
    output logic [31:0] apb_pwdata_out,
    output logic 			apb_psel1,
    output logic 			apb_psel2,
	 output logic 			uart_send, baud_clk_w,
	 output logic [1:0] 	uart_baud_rate,
	 output logic [1:0] 	uart_parity_type,
    output logic [2:0]  uart_error,       // UART error flags
	 output logic [7:0] 	uart_data_in,
	 output logic 			connect
);

    // Internal Signals
    logic apb_penable;
    logic [31:0] apb_prdata;
//	 logic [7:0] uart_data_in;
	
    // Instantiate APB Bus
    APB_Bus apb_bus_inst (
        .PCLK(clk),
        .PRESETn(reset_n),
        .PWRITE(apb_write),
        .PSEL(apb_sel),
        .TRANSFER(apb_en),
        .PADDR(apb_addr),
        .PWDATA(apb_wdata),

        .PREADY(apb_ready),
        .PRDATA(apb_prdata),
        

        .PWRITE_OUT(apb_pwrite_out),
        .PENABLE_OUT(apb_penable_out),
        .PADDR_OUT(apb_paddr_out),
        .PWDATA_OUT(apb_pwdata_out),
        .PSEL1(apb_psel1),
        .PSEL2(apb_psel2),

        .APB_RDATA(apb_rdata),
        .PSLVERR(apb_error),
        .ERROR_TYPE() // Optional detailed error handling
    );

    // Instantiate UART_APB_Bridge
    UART_APB_Bridge uart_apb_bridge_inst (
        .PCLK(clk),
        .PRESETn(reset_n),
        .PWRITE(apb_pwrite_out),
        .PSEL(apb_psel1),
        .PENABLE(apb_penable_out),
        .PADDR(apb_paddr_out),
        .PWDATA(apb_pwdata_out),
        .PRDATA(apb_prdata),
        .PREADY(apb_ready),
		  .tx_active_flag(uart_tx_active),
		  
        .DATA_RX(uart_data_in),
        .tx_done_flag(uart_tx_done),
        .rx_done_flag(uart_rx_done),
        .send(uart_send),
        .parity_type(uart_parity_type),
        .baud_rate(uart_baud_rate),
        .DATA_TX(uart_data_out),
        .error_flag(uart_error)
    );

    // Instantiate Duplex UART
    Duplex uart_inst (
        .reset_n(reset_n),
        .send(uart_send),
        .clock(clk),
        .parity_type(uart_parity_type),
        .baud_rate(uart_baud_rate),
        .data_in(uart_data_out),
        .RX(connect),

        .tx_active_flag(uart_tx_active),
        .tx_done_flag(uart_tx_done),
        .rx_active_flag(uart_rx_active),
        .rx_done_flag(uart_rx_done),
        .TX(connect),
        .data_out(uart_data_in),
		  .baud_clk_w(baud_clk_w),
        .error_flag(uart_error)
    );

endmodule
