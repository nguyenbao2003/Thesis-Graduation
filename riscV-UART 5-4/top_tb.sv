`timescale 1ps / 1ps

import axi_lite_pkg::*;

module top_tb;

    localparam STEP = 10;

    logic aclk, areset_n;
//    logic start_read, start_write;
	 logic [31:0] i_addr, i_data;
	 logic [3:0]  i_wstrb;
	 logic psel;
	 logic [31:0] debug_buffer ,debug_rdata;
	 logic start_write, awvalid_int, AWREADY, wvalid_int, WREADY, bready_int, BVALID;
	 logic start_read, arvalid_int, ARREADY, rready_int, RVALID ;
	 
	 //debug
	 logic [31:0] addr_reg, wdata_reg;
	 logic [2:0] bridge_state, master_state;
	 logic PWRITE, PSLVERR, PSEL, PENABLE, PREADY;
	 logic [31:0] PRDATA, PADDR, PWDATA;
	 
	 //After implement Duplex
	 logic					uart_tx_active;  // UART Tx active flag
	logic					uart_tx_done;    // UART Tx done flag
	logic					uart_rx_active;  // UART Rx active flag
	logic					uart_rx_done;    // UART Rx done flag
	logic             baud_clk_w;
	logic    [7:0]    uart_data_in;
	logic		[7:0] uart_data_out;
	logic		[1:0] uart_baud_rate;
	logic		[1:0] uart_parity_type;
	logic		uart_send;
	logic            connect;
	logic		[2:0]   uart_error;       // UART error flags
	
	logic tx_enable, rx_enable;
	 
	 // Instantiate the AXI Lite Interface
    axi_lite_if axi_lite_bus();

    // Instantiate the top module
    top uut (
        .aclk(aclk),
        .areset_n(areset_n),
		  .addr(i_addr),
		  .data(i_data),
		  .wstrb(i_wstrb),
		  .psel(psel),
		  // Read
		  .start_read(start_read),
		  .arvalid_int(arvalid_int),
//		  .arready_int(arready_int),
		  .rready_int(rready_int),
//		  .rvalid_int(rvalid_int),
		  // Write
		  .start_write(start_write),
		  .awvalid_int(awvalid_int),
//		  .awready_int(awready_int),
		  .wvalid_int(wvalid_int),
//		  .wready_int(wready_int),
		  .bready_int(bready_int),
//		  .bvalid_int(bvalid_int),
		  
		  .debug_rdata(debug_rdata),
		  .debug_buffer(debug_buffer),
		  .m_axi_lite(axi_lite_bus.master),
		  
		  //debug
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
		  
		  // After implement Duplex
		  .uart_send(uart_send),
			.uart_baud_rate(uart_baud_rate),
			.uart_parity_type(uart_parity_type),
			.uart_error(uart_error),
			.connect(connect),
			.uart_data_in(uart_data_in),
			.baud_clk_w(baud_clk_w),
			.uart_tx_active(uart_tx_active),
	.uart_tx_done(uart_tx_done),
	.uart_rx_active(uart_rx_active),
	.uart_rx_done(uart_rx_done),
	.uart_data_out(uart_data_out),
	
	.tx_enable(tx_enable),
	.rx_enable(rx_enable)
    );

    // Clock generation
    always begin
        aclk = 1; #(STEP / 2);
        aclk = 0; #(STEP / 2);
    end

    // Stimulus generation
    initial begin
        // Initialize signals
        start_read = 0; 
        start_write = 0;
        areset_n = 1;
        
        // Reset sequence
        #(STEP) areset_n = 0;
        #(STEP) areset_n = 1;

        // Perform write and read tests
        #(STEP);
//		  start_write = 1;
//		  start_read = 1;
		test_write(32'h0, 32'h2, 4'b1111, 1); // assert tx_enable
//		  i_addr = 32'h0;
//        i_data = 32'h2;
//		  i_wstrb = 4'b1111;
		  
		  #(STEP*5);
		  test_write(32'h4, 32'hC, 4'b1111, 1); // set parity_type and baudrate
//		  i_addr = 32'h4;
//        i_data = 32'hC;
//		  i_wstrb = 4'b1111;
		  
		  #(STEP*5);
		  test_write(32'hC, 32'hBEEF, 4'b1111, 1);

		  
		  #(STEP*5);
		  test_write(32'hC, 32'hBEAA, 4'b1111, 1);

		  
		  #(STEP*5);
		  test_write(32'hC, 32'hBEBB, 4'b1111, 1);

		  
		  #(STEP*5);
		  test_write(32'h0, 32'h1, 4'b1111, 1); // assert rx_enable

		  
//		  #(STEP*5);
//		  start_read = 0;
//		  test_write(32'h4, 32'hdeadbeef, 4'b1111);
		  #(STEP*5);
//		  test_read(32'h4, 32'hdeadbeef);
		  
		  
		  
//        test_write(32'h4, 32'hdeadbeef, 4'b1111);
		  
//        #(STEP*3);
//		  test_write(32'h8, 32'hAAAA_BBBB, 4'b1100);
//		  #(STEP*3);
//		  test_write(32'hC, 32'hCDCD_CDCD, 4'b1000);
//		  #(STEP*5); //minium: 5 cycle
//        test_read(32'h4, 32'hdeadbeef);
//		   #(STEP*2);
//        test_read(32'h8, 32'hdeadbeef);
//		   #(STEP*2);
//        test_read(32'h10, 32'hdeadbeef);
//		   #(STEP*2);
//        test_read(32'hC, 32'hdeadbeef);

//    test_write(32'h4, 32'hdeadbeef, 4'b1110);
//    #(STEP);
//    test_write(32'h8, 32'hAAAA_BBBB, 4'b1100);
//    #(STEP);
//    test_write(32'hC, 32'hCDCD_CDCD, 4'b1000);
//
//    #(STEP*2); // Allow write transactions to progress in parallel
//
//    test_read(32'h4, 32'hdeadbeef);
//    #(STEP);
//    test_read(32'h8, 32'hAAAA_BBBB);
//    #(STEP);
//    test_read(32'hC, 32'hCDCD_CDCD);

    #9000000;
		  $stop;
    end

    // Test tasks
    task test_write(input addr_t addr, input data_t data, input strb_t wstrb, input logic PSEL);
        begin
            // Simulate write operation
           @(posedge aclk);
            i_addr = addr;
            i_data = data;
				i_wstrb = wstrb;
				psel = PSEL;
				start_write = 1;
        //    uut.axi_lite.wvalid = 1;

      //      wait(uut.axi_lite.wready);
            @(posedge aclk);
				start_write = 0;
       //     uut.axi_lite.wvalid = 0;


        end
    endtask

    task test_read(input addr_t addr, input data_t expected_data);
        begin
            // Simulate read operation
            @(posedge aclk);
//            uut.axi_lite.araddr = addr;
				  i_wstrb = 4'b0000;
				  i_addr = addr;
				  start_read = 1;
//            uut.axi_lite.arvalid = 1;

//            wait(uut.axi_lite.arready);
              @(posedge aclk);
				  start_read = 0;

        end
    endtask

endmodule
