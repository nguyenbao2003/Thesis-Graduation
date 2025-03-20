module UART_APB_Bridge (
    // APB Interface
    input  wire         PCLK,             // APB clock
    input  wire         PRESETn,          // APB active-low reset
    input  wire         PWRITE,           // APB write control signal
    input  wire 		   PSEL,             // APB slave select
    input  wire         PENABLE,          // APB enable signal
    input  wire [4:0]   PADDR,            // APB address
    input  wire [31:0]  PWDATA,           // APB write data
    output reg [31:0]   PRDATA,           // Data read from the bridge
    output reg          PREADY,           // Bridge ready signal
    // UART Interface
    input  wire [7:0]   DATA_RX,          // Data received from UART
    input  wire         tx_done_flag,     // UART Tx done flag
	 input  wire			tx_active_flag,
    input  wire         rx_done_flag,     // UART Rx done flag
	 input reg [2:0]    	error_flag,
    output reg          send,             // Control signal to send data
    output reg [1:0]    parity_type,      // UART parity type
    output reg [1:0]    baud_rate,        // UART baud rate
	 output reg [7:0]   DATA_TX       // Data received from UART
    // Error Flags

);

    // Internal Registers
    reg [31:0] enable_reg;    // Enable register
    reg [31:0] control_reg;   // Control register
    reg [31:0] status_reg;    // Status register
    reg [7:0]  data_reg;      // Single shared data register
	 reg rx_enable;
	 reg tx_enable;
//	 reg send_tmp;
	
	
    // APB Read/Write Logic
    always @(*) begin
        if (!PRESETn) begin
            // Reset all internal registers
            enable_reg = 32'b0;
            control_reg = 32'b0;
            status_reg = 32'b0;
            data_reg = 8'b0;
            PRDATA = 32'b0;
        
            // Reset UART signals
            send = 1'b0;
            rx_enable = 1'b0;
            tx_enable = 1'b0;
            parity_type = 2'b0;
            baud_rate = 2'b0;
            PREADY = 1'b0; // Default ready signal
				end
//				if (!send_tmp) begin
//				  send = send_tmp;
//				end 
            if (PSEL == 1'b1 && !PENABLE && !PWRITE) 
				begin
                PREADY = 1'b0; // Indicate ready for transfer
				end
				else if (PSEL == 1'b1 && PENABLE && PWRITE) begin
				    PREADY = 1'b1; // Indicate ready for transfer
                    // Write Operation
                    case (PADDR)
                        5'h00: begin
                            // Write to Enable Register
                            enable_reg = PWDATA;
                            rx_enable = PWDATA[0];
                            tx_enable = PWDATA[1];
                        end
                        5'h04: begin
                            // Write to Control Register
                            control_reg = PWDATA;
                            parity_type = PWDATA[1:0];
                            baud_rate = PWDATA[3:2];
                        end
                        5'h0C: begin
                            // Write to Data Register (TX data)
                            if (tx_enable) begin
                                DATA_TX = PWDATA[7:0];
                                send = 1'b1; // Trigger UART send
                            end 
								end
                    endcase
                end 
					 else if (PSEL == 1'b1 && PENABLE && !PWRITE) begin
					 	PREADY = 1'b1; // Indicate ready for transfer
                    // Read Operation
                    case (PADDR)
                        5'h00: PRDATA = enable_reg;            // Enable Register
                        5'h04: PRDATA = control_reg;           // Control Register
                        5'h08: PRDATA = status_reg;            // Status Register
                        5'h0C: begin
                            // Read from Data Register (RX data)
                            if (rx_enable) begin
                                PRDATA = {24'b0, data_reg};
                            end 
									end
                     endcase
                end
					 else if (PSEL == 1'b1 && !PENABLE && PWRITE)
					 begin 
					 PREADY = 0;
					 end 


            // Update Status Register
           status_reg = {24'b0, tx_done_flag, rx_done_flag, error_flag};

            // Capture Received Data (RX Buffering)
            if (rx_done_flag && rx_enable) begin
                data_reg = DATA_RX;
            end

            // Clear UART Send Signal
//            if (send && tx_done_flag) begin
//                send = 1'b0;
//            end

		end

				
endmodule
