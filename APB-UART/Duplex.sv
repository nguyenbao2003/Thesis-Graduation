module Duplex (
    input  wire         reset_n,        // Active low reset
    input  wire         send,           // Enable to start sending data
    input  wire         clock,          // The main system's clock
    input  wire  [1:0]  parity_type,    // Parity type agreed upon by the Tx and Rx units
    input  wire  [1:0]  baud_rate,      // Baud rate agreed upon by the Tx and Rx units
    input  wire  [7:0]  data_in,        // Data input to be sent
	 input wire  			  RX,

    output wire         tx_active_flag, // Logic 1 when Tx is in progress
    output wire         tx_done_flag,   // Logic 1 when transmission is done
    output wire         rx_active_flag, // Logic 1 when Rx is in progress
    output wire         rx_done_flag,   // Logic 1 when data is received
    output wire  			 TX,       // 8-bit data output from the FIFO 
	 output wire  [7:0]  data_out, 
	 output wire 	connect,
	 output  wire [7:0]  fifo_tx_data_out,       // Data output from Tx FIFO to Tx unit
    output wire  [2:0]  error_flag,      // Error flags: Parity, Start, Stop errors
	 output wire        baud_clk_R, tx_fifo_empty, tx_fifo_full, // Tx FIFO status flags
	 output wire        baud_clk_w,
	 output wire  [10:0]      Recieved_Frame,
	 output reg readEN_ctrl,
	 output wire [2:0] wptr,rptr 
//	 output wire [3:0] counter
);

    typedef enum logic [1:0] {
    IDLE      = 2'b00,
    WAIT_DONE = 2'b01,
    READ_ONCE = 2'b10
  } state_t;

  state_t curr_state, next_state;
//  reg readEN_ctrl;
  
	 // Internal wires
    wire        data_tx_w;              // Serial transmitter's data out
   
    wire [7:0]  fifo_rx_data_in;        // Data input to Rx FIFO from Rx unit

    wire        rx_fifo_empty, rx_fifo_full; // Rx FIFO status flags
	 reg tx_fifo_read_en;
	reg [1:0] state;
	assign fifo_empty = tx_fifo_empty;
    // Transmitter FIFO
    FIFO_Buffer tx_fifo (
        .clk(clock),
        .reset(reset_n),
        .dataIn(data_in),            // Data input from external source
 //       .writeEn(send && !tx_fifo_full), // Write enable controlled by send and FIFO full flag
			.writeEn(send), // Write enable controlled by send and FIFO full flag
 //       .readEn(!tx_fifo_empty && tx_done_flag), // Read when FIFO not empty and Tx unit is ready
//			.readEn(tx_done_flag && !tx_fifo_empty ),
			.readEn(readEN_ctrl),
        .dataOut(fifo_tx_data_out), // Data output to Tx unit
        .EMPTY(tx_fifo_empty),
        .FULL(tx_fifo_full),
		  .wptr(wptr),
		  .rptr(rptr)
//		  .counter(counter)
    );

    // Receiver FIFO
    FIFO_Buffer rx_fifo (
        .clk(clock),
        .reset(reset_n),
        .dataIn(fifo_rx_data_in),    // Data input from Rx unit
        .writeEn(tx_done_flag), // Write on Rx done and FIFO not full
        .readEn(rx_done_flag),     // Read when FIFO is not empty
        .dataOut(data_out),          // Data output to external consumer
        .EMPTY(rx_fifo_empty),
       .FULL(rx_fifo_full)
		 
    );

    // Transmitter unit instance
    TxUnit Transmitter (
        .reset_n(reset_n),
        .send(!tx_fifo_empty),          // Send data only when FIFO has data
        .clock(clock),
        .parity_type(parity_type),
        .baud_rate(baud_rate),
        .data_in(fifo_tx_data_out),     // Data input from Tx FIFO
        .data_tx(connect),            // Serial output
        .active_flag(tx_active_flag),
		  .baud_clk_w(baud_clk_w),
        .done_flag(tx_done_flag)
    );

    // Receiver unit instance
    RxUnit Receiver (
        .reset_n(reset_n),
        .clock(clock),
        .parity_type(parity_type),
        .baud_rate(baud_rate),
        .data_tx(connect),            // Serial data from Tx unit
        .data_out(fifo_rx_data_in),     // Data output to Rx FIFO
        .error_flag(error_flag),
        .active_flag(rx_active_flag),
        .done_flag(rx_done_flag),
		  .baud_clk_R(baud_clk_R),
		  .Recieved_Frame(Recieved_Frame)
    );

//	 reg readEN_ctrl;
//	 
//	 always @(posedge clock) begin
//	    if (!reset_n) begin
//		   state <= 0;
//		 end else begin
//		   case (state) begin
//			  A: begin
//			    readEN_ctrl <= 0;
//				 if (tx_active_flag) begin
//				   state <= B;
//				 end
//			  end
//			  
//			  B: begin
//			    if (tx_done_flag) begin
//				   state <= C;
//				 end 
//			  end
//			  
//			  C: begin
//			    readEN_ctrl <= 1;
//				 state <= A;
//			  end
//			endcase
//		   default: begin
//		     readEN_ctrl <= 0;
//			  state <= A;
//			end	
//		 end
//	 end
	 


  // State register
  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n)
      curr_state <= IDLE;
    else
      curr_state <= next_state;
  end

  // Next-state logic & outputs
  assign tmp_baud_clk_w = baud_clk_w;
  always_comb begin
    // Default assignments
    next_state = curr_state;
    readEN_ctrl     = 1'b0;

    case (curr_state)
      IDLE: begin
        // Wait for active=1
        if (!tx_active_flag && tx_done_flag && !tmp_baud_clk_w) begin
          next_state = WAIT_DONE;
			 
        end
      end

      WAIT_DONE: begin
        // Wait for done=1
		
        if (tmp_baud_clk_w) begin
          next_state = READ_ONCE;
        end
      end

      READ_ONCE: begin
		if (!tx_active_flag) begin
        // Assert readEn for 1 cycle
        readEN_ctrl     = 1'b1;
        // Immediately move back to IDLE on next clock
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
