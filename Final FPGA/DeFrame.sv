module DeFrame(
    input  logic        reset_n,        // Active low reset
    input  logic        recieved_flag,  // Enable indicates when data is in progress
    input  logic [10:0]	data_parll,     // Data frame passed from the SIPO unit

    output logic        parity_bit,     // The parity bit separated from the data frame
    output logic        start_bit,      // The Start bit separated from the data frame
    output logic        stop_bit,       // The Stop bit separated from the data frame
    output logic        done_flag,      // Indicates that the data is received and ready for another data packet
    output logic [ 7:0] raw_data        // The 8-bit data separated from the data frame
);

    // -Deframing- Output Data & Parity Bit Logic with Asynchronous Reset
	always_comb begin
		if (!reset_n) begin
			// Idle
			raw_data     = {8{1'b1}};
         parity_bit   = 1'b1;
         start_bit    = 1'b0;
         stop_bit     = 1'b1;
         done_flag    = 1'b1;
		end else if (recieved_flag) begin
			start_bit  = data_parll[0];
         raw_data   = data_parll[8:1];
         parity_bit = data_parll[9];
         stop_bit   = data_parll[10];
         done_flag  = 1'b1;
		end else begin
			// Idle
         raw_data   = {8{1'b1}};
         parity_bit = 1'b1;
         start_bit  = 1'b0;
         stop_bit   = 1'b1;
         done_flag  = 1'b0;
		end
	end

endmodule