module APB_UART_Top (
    input  wire         clk,             // System clock
    input  wire         reset_n,         // Active low reset
    input  wire         apb_en,    // Transfer request
    input  wire [1:0]   apb_sel,         // APB slave select
    input  wire [4:0]   apb_addr,        // APB address
    input  wire         apb_write,       // APB write control
    input  wire [31:0]  apb_wdata,       // APB write data
//    input  wire 		   uart_rx,         // UART received data

    output wire [31:0]  apb_rdata,       // APB read data
    output wire         apb_ready,       // APB ready signal
    output wire         apb_error,       // APB error signal
    output wire         uart_tx_active,  // UART Tx active flag
    output wire         uart_tx_done,    // UART Tx done flag
    output wire         uart_rx_active,  // UART Rx active flag
    output wire         uart_rx_done,    // UART Rx done flag
//    output wire		   uart_tx,         // UART Tx data
	 output wire [7:0] uart_data_out,
	 output wire apb_pwrite_out,
    output wire apb_penable_out,
    output wire [4:0] apb_paddr_out,
    output wire [31:0] apb_pwdata_out,
    output wire apb_psel1,
    output wire apb_psel2,
	 output wire uart_send, baud_clk_w,
	 output wire [1:0] uart_baud_rate,
	 output wire [1:0] uart_parity_type,
    output wire [2:0]   uart_error,       // UART error flags
	 output wire [7:0] uart_data_in,
	 output wire connect
);

    // Internal Signals
    wire apb_penable;
    wire [31:0] apb_prdata;
//	 wire [7:0] uart_data_in;
	
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
