module NEW_UART_APB_Bridge (
    // APB Interface
    input  logic         	PCLK,             // APB clock
    input  logic         	PRESETn,          // APB active-low reset
    input  logic         	PWRITE,           // APB write control signal
    input  logic 		   	PSEL,             // APB slave select
    input  logic         	PENABLE,          // APB enable signal
    input  logic [ 4:0]		PADDR,            // APB address
    input  logic [31:0]		PWDATA,           // APB write data
    output logic [31:0]   	PRDATA,           // Data read from the bridge
    output logic          	PREADY,           // Bridge ready signal
    // UART Interface
    input  logic [ 7:0]   	DATA_RX,          // Data received from UART
    input  logic         	tx_done_flag,     // UART Tx done flag
	 input  logic				tx_active_flag,
    input  logic         	rx_done_flag,     // UART Rx done flag
	 input  logic [ 2:0]    error_flag,
    output logic          	send,             // Control signal to send data
    output logic [1:0]    	parity_type,      // UART parity type
    output logic [1:0]    	baud_rate,        // UART baud rate
	 output logic [7:0]   	DATA_TX,       // Data received from UART
	 output logic [31:0] 	debug_buffer,
    // Error Flags
	 output logic 				rx_enable, tx_enable
);

    // Internal logicisters
    logic [31:0] enable_reg;    // Enable register
    logic [31:0] control_reg;   // Control register
    logic [31:0] status_reg;    // Status register
    logic [ 7:0]  data_reg;      // Single shared data register
//	 logic rx_enable;
//	 logic tx_enable;
	 logic [31:0] MEM [255:0];
//	 logic send_tmp;
	
// Sequential logic: Register update and state holding variables
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Reset all registers and signals
            enable_reg  <= 32'b0;
            control_reg <= 32'b0;
            status_reg  <= 32'b0;
            data_reg    <= 8'b0;
//            PRDATA      <= 32'b0;

            // Reset UART control signals
            send        <= 1'b0;
            rx_enable   <= 1'b0;
            tx_enable   <= 1'b0;
            parity_type <= 2'b0;
            baud_rate   <= 2'b0;
            PREADY      <= 1'b0;  // Default ready signal
        end else if (!PENABLE) begin
				PREADY <= 1'b0; // Indicate ready for transfer
		  end else if (PSEL && PENABLE && PWRITE) begin
				PREADY <= 1'b1;
				// Write Operation
				if (PENABLE && PWRITE) begin
					case (PADDR)
						5'h00: begin
							enable_reg <= PWDATA;
							MEM [PADDR] <= PWDATA;
							rx_enable  <= PWDATA[0];
							tx_enable  <= PWDATA[1];
						end
						5'h04: begin
							control_reg  <= PWDATA;
							MEM [PADDR] <= PWDATA;
							parity_type  <= PWDATA[1:0];
							baud_rate    <= PWDATA[3:2];
						end
						5'h0C: begin
							if (tx_enable) begin
								MEM [PADDR] <= PWDATA;
								DATA_TX <= PWDATA[7:0];
								send    <= 1'b1; // Trigger UART send
							end
						end
					endcase
				end
				
				// Capture Received Data (RX Buffering)
				if (rx_done_flag && rx_enable) begin
					data_reg <= DATA_RX;
				end
	
				// Update Status Register
				status_reg <= {24'b0, tx_done_flag, rx_done_flag, error_flag};
	
				// Clear UART Send Signal
				if (send && tx_done_flag) begin
					send <= 1'b0;
				end
			end
		end
    // Handling PREADY signal separately
//    always_ff @(posedge PCLK or negedge PRESETn) begin
//        if (!PRESETn) begin
//            PREADY <= 1'b0;
//        end 
//        else begin
//            if (PSEL && PENABLE && PWRITE) begin
//                PREADY <= 1'b1;
//            end 
//            else if (PSEL && !PENABLE && PWRITE) begin
//                PREADY <= 1'b0;
//            end
//        end
//    end
	 
//	assign PREADY = (PENABLE)? 1 : 0;

	// Combinational logic: Read Operation
	always_comb begin
		PRDATA = 32'b0; // Default value
			if (PSEL) begin
				if (PENABLE && !PWRITE) begin
					case (PADDR)
						 5'h00: PRDATA = enable_reg;  // Enable Register
						 5'h04: PRDATA = control_reg; // Control Register
						 5'h08: PRDATA = status_reg;  // Status Register
						 5'h0C: begin
							  if (rx_enable) begin
									PRDATA = {24'b0, data_reg}; // Read RX data
							  end
						 end
					endcase
			  end
			end else begin
				PRDATA = 32'b0;
			end
    end

	assign debug_buffer = MEM [PADDR];

	endmodule
