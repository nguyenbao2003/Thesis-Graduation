module BaudGenRx(
    input logic         reset_n,     // Active low reset
    input logic         clock,       // The system's main clock
    input logic  [1:0]  baud_rate,   // Baud rate agreed upon by the Tx and Rx units

    output logic        baud_clk     // Clocking output for the other modules
);

    // Internal declarations
    logic [9:0] final_value;  // Holds the number of ticks for each baud rate
    logic [9:0] clock_ticks;  // Counts until it equals final_value (timer principle)

    // Encoding the different Baud Rates
 localparam [2:0]
        BAUD24  = 2'b00,
        BAUD48  = 2'b01,
        BAUD96  = 2'b10,
        BAUD192 = 2'b11;
    // Baud rate 4-to-1 Mux
    always_comb begin
        case (baud_rate)
            BAUD24:  final_value = 10'd651;  // 16 * 2400 baud rate
            BAUD48:  final_value = 10'd326;  // 16 * 4800 baud rate
            BAUD96:  final_value = 10'd163;  // 16 * 9600 baud rate
            BAUD192: final_value = 10'd81;   // 16 * 19200 baud rate
				//BAUD192: final_value = 10'd1302;
			//s	BAUD192: final_value = 10'd1;
            default: final_value = 10'd163;  // Default to 9600 baud rate
        endcase
    end

    // Timer logic
    always_ff @(negedge reset_n or posedge clock) begin
        if (!reset_n) begin
            clock_ticks <= 10'd0;
            baud_clk    <= 1'b0;
        end else begin
            // Ticks whenever reaches its final value
            if (clock_ticks == final_value) begin
                baud_clk    <= ~baud_clk;
                clock_ticks <= 10'd0;
            end else begin
                clock_ticks <= clock_ticks + 1'd1;
                baud_clk    <= baud_clk;  // Hold current baud_clk state
            end
        end
    end

endmodule
