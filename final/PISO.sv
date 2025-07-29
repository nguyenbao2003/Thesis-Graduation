module PISO(
    input  logic         reset_n,            //  Active low reset.
    input  logic         send,               //  An enable to start sending data.
    input  logic         baud_clk,           //  Clocking signal from the BaudGen unit.
    input  logic         parity_bit,         //  The parity bit from the Parity unit.
	 input  logic 			 parity_type,
    input  logic [ 7:0]   data_in,            //  The data input.

    output logic         data_tx,            //  Serial transmitter's data out
    output logic         active_flag,        //  High when Tx is transmitting, low when idle.
	 output logic [ 3:0]   stop_count, bit_count,
    output logic [10:0]  frame_r,
    output logic [10:0]  frame_man,
    output logic         next_state,
    output logic         count_full,
    output logic         done_flag           //  High when transmission is done, low when active.
);

    // Internal declarations


    // Encoding the states
    typedef enum logic {
        IDLE   = 1'b0,
        ACTIVE = 1'b1
    } state_t;

	 

    // Frame generation
    always_ff @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n)
            frame_r <= {11{1'b1}};
        else if (next_state)
            frame_r <= frame_r;
        else
            frame_r <= {1'b1, parity_bit, data_in, 1'b0};
    end

    // Counter logic
    always_ff @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n)
            stop_count <= 4'd0;
		  else if ((!next_state) || count_full)
				stop_count <= 4'd0;
        else
            stop_count <= stop_count + 4'd1;
		//		bit_count <= bit_count + 4'd1;
    end

    assign count_full = (stop_count == 4'd11);

    // Transmission logic FSM
    always_ff @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n)
            next_state <= 1'b0;
        else begin
            case (next_state)
                1'b0: begin
                    if (send) begin
                        next_state <= 1'b1;
						//		done_flag  <= 1'b0;
                    end else
                        next_state <= 1'b0;
                end
                1'b1: begin
                    if (count_full) begin
                        next_state <= 1'b0;
								
							//	done_flag  <= 1'b1;
                    end else
                        next_state <= 1'b1;
                end
            endcase
        end
    end


	always@ (*) begin
        if (next_state && (stop_count != 4'd0)) begin
            data_tx      = frame_man[stop_count - 1];
         //   frame_man    = frame_man >> 1;
            active_flag  = 1'b1;
            done_flag    = 1'b0;
        end
        else begin
            data_tx      = 1'b1;
            frame_man    = frame_r;
            active_flag  = 1'b0;
            done_flag    = 1'b1;
        end
    end

endmodule
