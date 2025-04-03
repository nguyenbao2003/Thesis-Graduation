module axi_apb_bridge(
	input  logic 			ACLK,
	input  logic 			ARESETn,
	input  logic 			i_psel,
	input  logic [31:0] 	AWADDR, // from axi master
	input  logic [31:0] 	WDATA, // from axi master
	input  logic [31:0] 	ARADDR, // from axi master
	input  logic 			ARVALID, // from axi master
	input  logic 			WVALID,  // from axi master
	input  logic 			AWVALID,  // from axi master
	input  logic	 		BREADY,  // from axi master
	input  logic 			RREADY, // from axi master
  
	input  logic 			PREADY, // from apb slave
	input  logic [ 1:0]	PSLVERR, // from apb slave
	input  logic [31:0] 	PRDATA, // from apb slave
  
	output logic 			PSEL,  // to apb slave
	output logic 			PENABLE, // to apb slave
	output logic 			PWRITE, // to apb slave
	output logic [31:0] 	PADDR, // to apb slave
	output logic [31:0] 	PWDATA, // to apb slave
  
	output logic 			BVALID, // to axi master
	output logic 			RVALID,  // to axi master  
	output logic 			BRESP, // to axi master
	output logic 			RRESP, // to axi master
	output logic 			AWREADY, // to axi master
	output logic 			WREADY, // to axi master
	output logic 			ARREADY, // to axi master
	output logic [31:0] 	RDATA, // to axi master
  
	//debug
	output logic [31:0] addr_reg, wdata_reg,
	output logic [ 2:0] state
);
   // State encoding for the bridge FSM
   typedef enum logic [2:0] {IDLE, SETUP_WRITE, SETUP_READ, WRITE_ACCESS, WRITE_WAIT, READ_ACCESS, READ_WAIT} state_t;
//   state_t state;

	// Registers to hold address and data during transfers
//	logic [31:0] addr_reg, wdata_reg;
	logic write_reg;  // 1 if current transfer is write, 0 if read
	logic sel_reg;    // latched APB slave select (if multiple slaves)
	
	// AXI handshake signals (assuming single master environment)
//	assign AWREADY = (state == IDLE && AWVALID);  // ready for write address if idle and no read happening
	assign WREADY  = (state == SETUP_WRITE && WVALID);   // (for simplicity, expecting AW and W together)
//	assign ARREADY = (state == IDLE && ARVALID);              // ready for read address if idle
//	assign RREADY  = (state == SETUP_READ && RVALID);

//	assign PSEL = i_psel;
	always_ff @(posedge ACLK or negedge ARESETn) begin
	  if (!ARESETn) begin
		 state    <= IDLE;
		 PSEL     <= 1'b0;
		 PENABLE  <= 1'b0;
		 BVALID   <= 1'b0;
		 RVALID   <= 1'b0;
		 AWREADY  <= 1'b0;
		 ARREADY  <= 1'b0;
	  end else begin
//	    AWREADY <= (state == IDLE && !ARVALID && ARESETn && AWVALID);
		 case(state)
			IDLE: begin
			  if (AWVALID) begin
			    AWREADY <= 1'b1;
				 state <= SETUP_WRITE;
			  end else if (ARVALID) begin
			    ARREADY <= 1'b1;
				 state <= SETUP_READ;
			  end
			end
				
			SETUP_WRITE: begin
				// Latch write request
				AWREADY <= 0;
				if (WREADY) begin 
					addr_reg  <= AWADDR;
					wdata_reg <= WDATA;
					write_reg <= 1'b1;
					// (Decode address to select APB slave - here assume single slave UART)
					PSEL   <= i_psel;      // assert select for APB UART
					PWRITE <= 1'b1;
					PADDR  <= AWADDR;
					PWDATA <= WDATA;
					// tell AXI we accepted the write
					// (AXI AWREADY/WREADY are combinational as above, or could be registered here)
					state <= WRITE_ACCESS;  // move to write access phase
				end else
					state <= SETUP_WRITE;
			end
			
			SETUP_READ: begin
				// Latch write request
				ARREADY <= 0;
				if (RREADY) begin
					addr_reg  <= ARADDR;
					write_reg <= 1'b0;
					PSEL   <= i_psel;
					PWRITE <= 1'b0;
					PADDR  <= ARADDR;
					state  <= READ_ACCESS;  // move to read access phase
				end else
					state  <= SETUP_READ;
			end		
				  				
			WRITE_ACCESS: begin
				// Enter APB access phase for write
				PENABLE <= 1'b1;
				// Wait for APB ready
				if (PREADY) begin
					// Capture any error and prepare response
					PENABLE <= 1'b0;
					PSEL    <= 0;
					BRESP   <= PSLVERR ? 2'b10 : 2'b00;  // SLVERR or OKAY
					BVALID  <= 1'b1;   // issue write response to AXI
					state   <= WRITE_WAIT;
				end else
					state   <= WRITE_ACCESS;
			end
	
			WRITE_WAIT: begin
				// Wait for AXI master to acknowledge write response
				if (BREADY) begin
					BVALID <= 1'b0;
					state  <= IDLE;  // done, return to idle
				end else
					state  <= WRITE_WAIT;
			end
	
			READ_ACCESS: begin
				// Enter APB access phase for read
				PENABLE <= 1'b1;
				if (PREADY) begin
					PENABLE <= 1'b0;
					PSEL    <= 0;
					RDATA   <= PRDATA;
					RRESP   <= PSLVERR ? 2'b10 : 2'b00;
					RVALID  <= 1'b1;   // present read data to AXI
					state   <= READ_WAIT;
				end else
					state   <= READ_ACCESS;
			end
	
			READ_WAIT: begin
				// Wait for AXI master to take read data
				if (RREADY) begin
					RVALID <= 1'b0;
					state  <= IDLE;
				end else
					state  <= READ_WAIT;
			end
		endcase
	  end
	end

endmodule