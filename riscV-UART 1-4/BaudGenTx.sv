module BaudGenTx(
    input logic         reset_n,           // Active low reset
    input logic         clock,             // The system's main clock
    input logic [1:0]	baud_rate,         // Baud rate agreed upon by the Tx and Rx units

    output logic        baud_clk           // Clocking output for the other modules
);

	// Internal declarations
	logic [13:0] clock_ticks;
	logic [13:0] final_value;

	// Encoding for the Baud Rates states
	localparam [2:0]
        BAUD24  = 2'b00,
        BAUD48  = 2'b01,
        BAUD96  = 2'b10,
        BAUD192 = 2'b11;


	// BaudRate 4-to-1 Mux
	always_comb begin
		case (baud_rate)
			// All these ratio ticks are calculated for 50MHz Clock,
         // The values shall change with the change of the clock frequency.
         BAUD24:  final_value = 14'd10417;  // Ratio ticks for the 2400 BaudRate
         BAUD48:  final_value = 14'd5208;   // Ratio ticks for the 4800 BaudRate
         BAUD96:  final_value = 14'd2604;   // Ratio ticks for the 9600 BaudRate
         BAUD192: final_value = 14'd1302;   // Ratio ticks for the 19200 BaudRate
			//BAUD192: final_value = 14'd16;   // Ratio ticks for the 19200 BaudRate
         default: final_value = 14'd0;      // The system's original clock
		endcase
	end

	// Timer logic
   always_ff @(posedge clock or negedge reset_n) begin
		if (!reset_n) begin
			clock_ticks <= 14'd0;
         baud_clk    <= 1'b0;
      end else if (clock_ticks == final_value) begin
			// Ticks whenever it reaches its final value,
         // Then resets and starts all over again.
			clock_ticks <= 14'd0;
         baud_clk    <= ~baud_clk;
      end else begin
         clock_ticks <= clock_ticks + 1'd1;
         baud_clk    <= baud_clk;  // Hold current state
      end
    end

endmodule
