module uart_apb_bridge #(
	 parameter int NumWords = 64,                // Should be a power of 2
    parameter logic[31:0] BaseAddr = 32'h0      // Should be aligned with NumWords
)(
    // APB Interface
	 input logic readEN_ctrl,
    input  logic         	p_clk,             // APB clock
    input  logic         	p_reset_n,          // APB active-low reset
	 input  logic [31:0]		p_addr,            // APB address
    input  logic 		   	p_sel,             // APB slave select
    input  logic         	p_enable,          // APB enable signal
	 input  logic         	p_write,           // APB write control signal
    input  logic [31:0]		p_wdata,           // APB write data
	 output logic [31:0]   	p_rdata,           // Data read from the bridge
	 output logic          	p_ready,           // Bridge ready signal
	 output logic 				p_slverr,
	 
	 output logic [31:0] debug_buffer_apb,

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
	 output logic 				rx_enable,
	 output logic 				tx_enable
);

    localparam AddrWidth = $clog2(NumWords * 4);
	 

    // ---------------- Signal declarations --------------------
    // Registers
    logic[31:0] regs[NumWords];
    // Address decode
    logic[31:AddrWidth] addr_tag;
    logic[AddrWidth-1:2] word_offset;
    logic[1:0] byte_offset;
    logic addr_valid, addr_in_range, addr_aligned;
    // APB
    logic write_en, read_en;
	 
	 
	 
	 // Internal logicisters
    logic [31:0] enable_reg;    // Enable register
    logic [31:0] control_reg;   // Control register
    logic [31:0] status_reg;    // Status register
    logic [ 7:0]  data_reg;      // Single shared data register

	     // Address decode
    assign {addr_tag, word_offset, byte_offset} = p_addr;
    assign addr_in_range = (addr_tag == BaseAddr[31:AddrWidth]);
    assign addr_aligned = (byte_offset == '0);
    assign addr_valid = addr_in_range & addr_aligned;

    // APB
    assign write_en = p_sel & p_enable & p_write;
    assign read_en = p_sel & p_enable & ~p_write;
    // No wait states
    assign p_ready = p_sel & p_enable;
    // Raise error when address is invalid
    assign p_slverr = p_sel & p_enable & ~addr_valid;
	 
	 assign debug_buffer_apb = regs[word_offset];
	
	 // -------------------- Definitions ------------------------
    // Register write
    always_ff @(posedge p_clk or negedge p_reset_n) begin
        if (~p_reset_n) begin
            // Reset
            for (int i = 0; i < NumWords; i++)
                regs[i] <= '0;
        end
        else begin
            // Write
            if (write_en) begin
					case (p_addr)
						5'h00: begin
							enable_reg <= p_wdata;
							regs[word_offset] <= p_wdata;
							rx_enable  <= p_wdata[1];
							tx_enable  <= p_wdata[0];
						end
						5'h04: begin
							control_reg  <= p_wdata;
							regs[word_offset] <= p_wdata;
							parity_type  <= p_wdata[1:0];
							baud_rate    <= p_wdata[3:2];
						end
						5'h0C: begin
							if (tx_enable) begin
								regs[word_offset] <= p_wdata;
								DATA_TX <= p_wdata[7:0];
								 // Trigger UART send
								send <= 1'b1;
							end else begin
								send <= 1'b0;
							end
						end
						default: regs[word_offset] <= p_wdata;
					endcase
				end
				
				// Clear UART Send Signal
				if (send && tx_done_flag) begin
					send <= 1'b0;
				end
				
			end
		end
		
//	always_comb begin
//		data_reg = 0;
//		if (rx_done_flag && rx_enable) begin
//					data_reg = DATA_RX;
//		end
//	end
		
    // Register read
//    assign p_rdata = (read_en & addr_valid) ? regs[word_offset] : '0;
	 
	 always_comb begin
		p_rdata = 32'b1;
		if (read_en & addr_valid) begin
			case (p_addr)
				5'h00: p_rdata = enable_reg;  // Enable Register
				5'h04: p_rdata = control_reg; // Control Register
				5'h08: p_rdata = status_reg;  // Status Register
				5'h0C: begin
					if (rx_enable)
						p_rdata = {24'b0, DATA_RX}; // Read RX dat
				end
				default: p_rdata = regs[word_offset];
			endcase
		end else
			p_rdata = 32'b0;
	 end
	


	endmodule