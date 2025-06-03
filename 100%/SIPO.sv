module SIPO(
    input  logic				reset_n,        //  Active low reset.
    input  logic				data_tx,        //  Serial Data recieved from the transmitter.
    input  logic				baud_clk,       //  The clocking input comes from the sampling unit.
	 input  logic rx_enable,

    output logic  			active_flag,    //  outputs logic 1 when data is in progress.
    output logic          	recieved_flag,  //  outputs a signal enables the deframe unit. 
    output logic  [10:0]	data_parll      //  outputs the 11-bit parallel frame.
);
	//  Internal
	logic [3:0]  frame_counter;
	logic [3:0]  stop_count;
	logic [1:0]  next_state;

	//  Encoding the states of the reciever
	//  Every State captures the corresponding bit from the frame
	localparam IDLE   = 2'b00,
				  CENTER = 2'b01,
              FRAME  = 2'b10,
              HOLD   = 2'b11;

	//  FSM with Asynchronous Reset logic
	always_ff @(posedge baud_clk or negedge reset_n) begin
		if (~reset_n) begin
			next_state        <= IDLE;
		end else begin
			case (next_state)
			//  Idle case waits untill start bit
				IDLE : begin
					data_parll    <= {11{1'b1}};
					stop_count    <= 4'd0;
					frame_counter <= 4'd0;
					recieved_flag <= 1'b0;
					active_flag   <= 1'b0;
					//  waits till sensing the start bit which is low
					if(~data_tx) begin
//					if(rx_enable) begin
						next_state  <= CENTER;
						active_flag <= 1'b1;
					end else begin
						next_state  <= IDLE;
						active_flag <= 1'b0;
					end
				end

				//  shifts the sampling to the Center of the recieved bit
				//  due to the protocol, thus the bit is stable.
				CENTER : begin
					if(stop_count == 7) begin
					//  This is an equivalent condition to (stop_count == 7)
					//  in order to avoid comparators/xors

						//  Captures the start bit
						data_parll[0]  <= data_tx;
						stop_count     <= 4'd0;
						next_state     <= FRAME;
					end else begin
						stop_count  <= stop_count + 4'b1;
						next_state  <= CENTER;
					end
				end

				//  shifts the remaining 10-bits of the frame,
				//  then returns to the idle case.
				FRAME : begin
					if(frame_counter == 4'd10) begin
					//  This is an equivalent condition to (frame_counter == 4'd10)
					//  in order to avoid comparators/xors
						frame_counter <= 4'd0;
						recieved_flag <= 1'b1;
						next_state    <= HOLD;
						active_flag   <= 1'b0;
					end else if(stop_count == 4'd15) begin
						//  This is an equivalent condition to (stop_count == 4'd15)
						//  in order to avoid comparators/xors
          
						data_parll[frame_counter + 4'd1]    <= data_tx;
						frame_counter                       <= frame_counter + 4'b1;
						stop_count                          <= 4'd0; 
						next_state                          <= FRAME;
					end else begin
						stop_count <= stop_count + 4'b1;
						next_state <= FRAME;
					end
				end

				//  Holds the data recieved for a 16 baud cycles
				HOLD : begin
					if(stop_count == 4'd15) begin
					//  This is an equivalent condition to (stop_count == 4'd15)
					//  in order to avoid comparators/xors
						data_parll    <= data_parll;

						frame_counter <= 4'd0;
						stop_count    <= 4'd0; 
						recieved_flag <= 1'b0;
						next_state    <= IDLE;
					end else begin
						stop_count <= stop_count + 4'b1;
						next_state <= HOLD;
					end
				end

				//  Automatically directs to the IDLE state
				default : begin
					next_state <= IDLE;
				end
			endcase
		end
	end

endmodule