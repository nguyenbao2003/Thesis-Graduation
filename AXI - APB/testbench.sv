`timescale 1ns / 1ps

import axi_lite_pkg::*;

module testbench;

    localparam STEP = 10;

    logic aclk, areset_n;
//    logic start_read, start_write;
	 logic [31:0] i_addr, i_data;
	 logic [3:0]  i_wstrb;
	 logic [31:0] debug_buffer ,debug_rdata;
	 logic start_read, arvalid_int, arready_int, rready_int, rvalid_int;
	 logic start_write, awvalid_int, awready_int, wvalid_int, wready_int, bready_int, bvalid_int;

    // Instantiate the top module
    axi_lite uut (
        .aclk(aclk),
        .areset_n(areset_n),
		  .addr(i_addr),
		  .data(i_data),
		  .wstrb(i_wstrb),
		  // Read
		  .start_read(start_read),
		  .arvalid_int(arvalid_int),
		  .arready_int(arready_int),
		  .rready_int(rready_int),
		  .rvalid_int(rvalid_int),
		  // Write
		  .start_write(start_write),
		  .awvalid_int(awvalid_int),
		  .awready_int(awready_int),
		  .wvalid_int(wvalid_int),
		  .wready_int(wready_int),
		  .bready_int(bready_int),
		  .bvalid_int(bvalid_int),
		  
		  .debug_rdata(debug_rdata),
		  .debug_buffer(debug_buffer)
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
        test_write(32'h4, 32'hdeadbeef, 4'b1110);
        #(STEP*3);
		  test_write(32'h8, 32'hAAAA_BBBB, 4'b1100);
		  #(STEP*3);
		  test_write(32'hC, 32'hCDCD_CDCD, 4'b1000);
		  #(STEP*3);
        test_read(32'h4, 32'hdeadbeef);
		   #(STEP*2);
        test_read(32'h8, 32'hdeadbeef);
		   #(STEP*2);
        test_read(32'h10, 32'hdeadbeef);
		   #(STEP*2);
        test_read(32'hC, 32'hdeadbeef);

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

    #50;

        #50;
		  $stop;
    end

    // Test tasks
    task test_write(input addr_t addr, input data_t data, input strb_t wstrb);
        begin
            // Simulate write operation
            @(posedge aclk);
            i_addr = addr;
            i_data = data;
				i_wstrb = wstrb;
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
				  i_addr = addr;
				  start_read = 1;
//            uut.axi_lite.arvalid = 1;

//            wait(uut.axi_lite.arready);
              @(posedge aclk);
				  start_read = 0;

        end
    endtask

endmodule
