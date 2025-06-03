module test_axi_apb_bridge_tb;

 localparam STEP = 10;
// input
	logic aclk;
	logic areset_n;
   
   logic [3:0] 	i_wstrb;
	logic  			psel;
	logic [31:0] 	i_addr, i_data;
	
	
	logic start_write;
	logic 			AWVALID, AWREADY, WVALID, WREADY, BREADY, BVALID;
	logic [31:0] 	debug_buffer;

// output  
	logic start_read;
	logic 			ARVALID, ARREADY, RREADY, RVALID ; // master
	logic [31:0] RDATA;


	
	logic [31:0] 	PADDR, PWDATA;
	logic 			PSLVERR, PWRITE, PSEL, PENABLE, PREADY;
	logic [31:0]   PRDATA;
	logic [31:0] 	debug_rdata;
	logic rx_done_flag;
	
	
	test_axi_apb_bridge u1(
		.aclk(aclk),
		.areset_n(areset_n),
		.start_read(start_read),
		.start_write(start_write),
		.addr(i_addr),
		.data(i_data),
		.wstrb(i_wstrb),
		.psel(psel),
		.rx_done_flag(rx_done_flag),
		
		.debug_rdata(debug_rdata),
		.arvalid_int(ARVALID),
		.awvalid_int(AWVALID),
		.wvalid_int(WVALID),
		.rready_int(RREADY),
		.bready_int(BREADY),
		
		.debug_buffer(debug_buffer),
		.AWREADY(AWREADY),
		.WREADY(WREADY),
		.ARREADY(ARREADY),
		.RVALID(RVALID),
		.BVALID(BVALID),
		.PREADY(PREADY),
		.PSLVERR(PSLVERR),
		.PSEL(PSEL),
		.PENABLE(PENABLE),
		.PWRITE(PWRITE),
		.PRDATA(PRDATA),
		.PADDR(PADDR),
		.PWDATA(PWDATA),
		.RDATA(RDATA)
	);

	// Clock generation
    always begin
        aclk = 1; #(STEP / 2);
        aclk = 0; #(STEP / 2);
    end
	 
	 initial begin
	  // Initialize signals
        start_read = 0; 
        start_write = 0;
        areset_n = 1;
        
        // Reset sequence
        #(STEP) areset_n = 0;
        #(STEP) areset_n = 1;
		  
		  psel = 1'b1;
		  
		  test_write(32'h10, 32'hdeadbeef, 4'b1111);
		  #(STEP*6);
		  test_write(32'h14, 32'hdeadaaaa, 4'b1111);
		  #(STEP*6);
		  test_write(32'h18, 32'hdeadbbbb, 4'b1111);
		  #(STEP*6);
		  test_write(32'h1C, 32'hdeadcccc, 4'b1111);
		  #(STEP*6);
		  test_read(32'h10, 32'hdeadbeef);
		  #(STEP*6);
		  test_read(32'h14, 32'hdeadbeef);
		  #(STEP*6);
		  test_read(32'h18, 32'hdeadbeef);
		  #(STEP*6);
		  test_read(32'h1C, 32'hdeadbeef);
		  
		  
	 
	 #500;
	 $stop;
	 end
	 
	 // Test tasks
    task test_write(input logic [31:0] addr, input logic [31:0] data, input logic [3:0] wstrb);
        begin
            // Simulate write operation
            @(posedge aclk);
            i_addr = addr;
            i_data = data;
				i_wstrb = wstrb;
				start_write = 1;
            
				@(posedge aclk);
				start_write = 0;
        end
    endtask
	 
	 task test_read(input logic [31:0] addr, input logic [31:0] expected_data);
        begin
            // Simulate read operation
            @(posedge aclk);
				  i_wstrb = 4'b0000;
				  i_addr = addr;
				  start_read = 1;
				  rx_done_flag = 1;

              @(posedge aclk);
				  start_read = 0;
				  

        end
    endtask
	
endmodule
