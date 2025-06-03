module new_top_tb;
	 parameter logic[31:0] BaseAddr = 32'h3000_1000;
    parameter logic[31:0] OtherAddr = 32'h2000_0000;
	 localparam STEP = 10;

	 logic        apb_axi_clk ;
      logic        a_reset_n ;
		logic start_read, start_write;
		logic [31:0] addr, data;
		logic [31:0] debug_rdata;
//      logic        p_clk_en ;
		logic [31:0] aw_addr ;
		logic        aw_valid ;
     logic        aw_ready ;
	  logic [31:0] w_data ;
	  logic        w_valid ;
     logic        w_ready ;
      logic        b_ready ;
     logic        b_valid ;
     logic [1:0]  b_resp ;
	   logic [31:0] ar_addr ;
      logic        ar_valid ;
     logic        ar_ready ;
      logic        r_ready ;
     logic        r_valid ;
     logic [31:0] r_data ;
     logic [1:0]  r_resp ;
	 
	  logic [31:0] p_addr ;
	  logic [31:0] p_wdata; 
     logic        p_sel ;
	  logic        p_write ;
     logic        p_enable ;
     logic        p_ready ;
     logic [31:0] p_rdata ;
     logic        p_slverr;
	  
	  logic uart_tx_active;
	  logic         uart_tx_done;
	  logic         uart_rx_active;
	  logic         uart_rx_done;
	  logic 			uart_send, baud_clk_w;
	  logic [ 1:0] 	uart_baud_rate;
	  logic [ 1:0] 	uart_parity_type;
	  logic [ 2:0]  uart_error;
	    logic [ 7:0] 	uart_data_in;
	  logic [ 7:0] 	uart_data_out;
	  logic 			tx_start,tx_fifo_empty, tx_start_init, connect;
	  logic 			rx_enable, tx_enable,readEN_ctrl;
	  logic [ 7:0] 	fifo_tx_data_out;
	  logic [10:0] frame_man_piso;
	  logic RX;
	  logic TX;
	  logic [10:0] Recieved_Frame;
	  logic [7:0] datain_rx_fifo;
	  
	  
	  
	  logic aw_full;
	  logic  aw_empty, aw_al_empty;
	  logic w_full, w_empty, w_al_empty;
	  logic req, w_req, r_req;
	  logic w_grant, r_grant;
	  logic done, w_done, r_done;
	  logic [31:0] aw_addr_out;
	  logic [31:0] debug_buffer_apb;
	  
	  
	  

    // -------------------- Test subject -----------------------
	 new_top dut (.*);
	 
	 initial begin
        apb_axi_clk = 1;
        forever #5 apb_axi_clk = ~apb_axi_clk;
    end
	 
	 
	 int num_reset;
endmodule