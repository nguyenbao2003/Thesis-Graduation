module Duplex (
    input  logic        reset_n,        // Active low reset
    input  logic        send,           // Enable to start sending data
    input  logic        clock,          // The main system's clock
    input  logic [ 1:0]	parity_type,    // Parity type agreed upon by the Tx and Rx units
    input  logic [ 1:0]  baud_rate,      // Baud rate agreed upon by the Tx and Rx units
    input  logic [ 7:0]  data_in,        // Data input to be sent
	 input  logic  		RX,
	 input logic rx_enable,

    output logic        tx_active_flag, // Logic 1 when Tx is in progress
    output logic        tx_done_flag,   // Logic 1 when transmission is done
    output logic        rx_active_flag, // Logic 1 when Rx is in progress
    output logic        rx_done_flag,   // Logic 1 when data is received
    output logic  		TX,       // 8-bit data output from the FIFO 
	 output logic [ 7:0]  data_out, 
	 output logic 			connect,
	 output logic [ 7:0]  fifo_tx_data_out,       // Data output from Tx FIFO to Tx unit
    output logic [ 2:0]  error_flag,      // Error flags: Parity, Start, Stop errors
	 output logic        baud_clk_R, tx_fifo_empty, tx_fifo_full, // Tx FIFO status flags
	 output logic        baud_clk_w,
	 output logic [10:0] Recieved_Frame,
	 output logic 			readEN_ctrl,
	 output logic [ 2:0] 	wptr,rptr,
	 output logic 			tx_start, tx_start_init,
	 output logic [10:0] frame_man_piso
);

	typedef enum logic [1:0] {
		IDLE      = 2'b00,
		WAIT_DONE = 2'b01,
		READ_ONCE = 2'b10,
		ONE_DATA = 2'b11
	} state_t;

	state_t curr_state, next_state;
  
	 // Internal wires
	logic       data_tx_w;              // Serial transmitter's data out
   
   logic [7:0] fifo_rx_data_in;        // Data input to Rx FIFO from Rx unit

   logic       rx_fifo_empty, rx_fifo_full; // Rx FIFO status flags
	logic 		tx_fifo_read_en;
	logic [1:0] state;
	
//	logic tx_start;	 
	
	assign fifo_empty = tx_fifo_empty;
	
	// Transmitter FIFO
   FIFO_Buffer tx_fifo (
		.clk(clock),
      .reset(reset_n),
      .dataIn(data_in),            // Data input from external source
		.writeEn(send), // Write enable controlled by send and FIFO full flag
		.readEn(readEN_ctrl),
      .dataOut(fifo_tx_data_out), // Data output to Tx unit
      .EMPTY(tx_fifo_empty),
      .FULL(tx_fifo_full),
		.wptr(wptr),
		.rptr(rptr)
    );

	// Receiver FIFO
   FIFO_Buffer rx_fifo (
		.clk(clock),
      .reset(reset_n),
      .dataIn(fifo_rx_data_in),    // Data input from Rx unit
      .writeEn(tx_done_flag), // Write on Rx done and FIFO not full
      .readEn(rx_done_flag && tx_done_flag),     // Read when FIFO is not empty
      .dataOut(data_out),          // Data output to external consumer
      .EMPTY(rx_fifo_empty),
      .FULL(rx_fifo_full) 
	);

	// Transmitter unit instance
   TxUnit Transmitter (
		.reset_n(reset_n),
		.send(tx_start || tx_start_init),    // Send data only when FIFO has data
      .clock(clock),
      .parity_type(parity_type),
      .baud_rate(baud_rate),
      .data_in(fifo_tx_data_out),     // Data input from Tx FIFO
      .data_tx(TX),            // Serial output
      .active_flag(tx_active_flag),
		.baud_clk_w(baud_clk_w),
      .done_flag(tx_done_flag),
		.frame_man_piso(frame_man_piso)
	);

	// Receiver unit instance
   RxUnit Receiver (
		.reset_n(reset_n),
      .clock(clock),
      .parity_type(parity_type),
      .baud_rate(baud_rate),
      .data_tx(RX),            // Serial data from Tx unit
      .data_out(fifo_rx_data_in),     // Data output to Rx FIFO
      .error_flag(error_flag),
      .active_flag(rx_active_flag),
      .done_flag(rx_done_flag),
		.baud_clk_R(baud_clk_R),
		.Recieved_Frame(Recieved_Frame),
		.rx_enable(rx_enable)
	);

	always_ff @(posedge baud_clk_w) begin
		if (!tx_fifo_empty) begin
			tx_start <= 1;
		end else
			tx_start <= 0;
	end


	logic initial_data, tmp_initial_data;
	
	// State register
	always_ff @(posedge clock or negedge reset_n) begin
		if (!reset_n) begin
			curr_state <= IDLE;
			initial_data <= 0;
		end else begin
			curr_state <= next_state;
			initial_data <= tmp_initial_data;
		end
	end

	// Next-state logic & outputs
	assign tmp_baud_clk_w = baud_clk_w;

	always_comb begin
		// Default assignments
		next_state = curr_state;
		readEN_ctrl = 0;
		tmp_initial_data = initial_data;
		tx_start_init = 1'b0;
		case (curr_state)
			IDLE: begin
				if (~tx_fifo_empty && ~initial_data) begin
					readEN_ctrl = 1;
					tmp_initial_data = 1;
				end
			
				if (!baud_clk_w && ~tx_fifo_empty && ~initial_data) begin
					next_state = ONE_DATA;
				end
			
				if (tx_active_flag) begin
					// Wait for active=1
					next_state = WAIT_DONE;			 
				end 
			end
	
			ONE_DATA: begin 
				tx_start_init = 1'b1;
				if (baud_clk_w) begin
					tx_start_init = 1'b0;
					next_state = IDLE;
				end else 
					next_state = ONE_DATA;
			end 
			
			WAIT_DONE: begin
				// Wait for done=1
				if (tx_done_flag) begin
					next_state = READ_ONCE;
				end
			end
	
			READ_ONCE: begin
				if (!tx_active_flag) begin
					// Assert readEn for 1 cycle
					readEN_ctrl     = 1'b1;
				end
					next_state = IDLE;
				end
	
			default: begin
				// Safe default (should never happen)
				next_state = IDLE;
			end
		endcase
	end

	endmodule
