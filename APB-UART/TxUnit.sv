module TxUnit(
    input logic         reset_n,       // Active low reset
    input logic         send,          // Enable to start sending data
    input logic         clock,         // The main system's clock
    input logic [1:0]   parity_type,   // Parity type agreed upon by the Tx and Rx units
    input logic [1:0]   baud_rate,     // Baud rate agreed upon by the Tx and Rx units
    input logic [7:0]   data_in,       // The data input

    output logic        data_tx,       // Serial transmitter's data out
    output logic        active_flag,   // High when Tx is transmitting, low when idle
	 output logic 			next_state,
	 output logic  		baud_clk_w,	
    output logic        done_flag      // High when transmission is done, low when active
);
//  Interconnections
logic parity_bit_w;

//  Baud generator unit instantiation
BaudGenTx Unit1(
    //  Inputs
    .reset_n(reset_n),
    .clock(clock),
    .baud_rate(baud_rate),
    
    //  Output
    .baud_clk(baud_clk_w)
);

//Parity unit instantiation 
Parity Unit2(
    //  Inputs
    .reset_n(reset_n),
    .data_in(data_in),
    .parity_type(parity_type),
    
    //  Output
    .parity_bit(parity_bit_w)
);

//  PISO shift register unit instantiation
PISO Unit3(
    //  Inputs
    .reset_n(reset_n),
    .send(send),
    .baud_clk(baud_clk_w),
    .data_in(data_in),
    .parity_bit(parity_bit_w),
	 .next_state(next_state),
    //  Outputs
    .data_tx(data_tx),
    .active_flag(active_flag),
    .done_flag(done_flag)
);

endmodule