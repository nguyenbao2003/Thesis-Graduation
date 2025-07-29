module RxUnit(
    input  logic        reset_n,       // Active low reset
    input  logic        data_tx,       // Serial data received from the transmitter
    input  logic        clock,         // The system's main clock
    input  logic [ 1:0]	parity_type,   // Parity type agreed upon by the Tx and Rx units
    input  logic [ 1:0] baud_rate,     // Baud rate agreed upon by the Tx and Rx units

    output logic       	active_flag,   // Logic 1 when data is in progress
    output logic       	done_flag,     // Logic 1 when data is received
    output logic [ 2:0]	error_flag,    // Error flags: [ParityError, StartError, StopError]
    output logic [ 7:0] data_out,       // The 8-bit data separated from the frame
	 output logic       	baud_clk_R,
	 output logic [10:0] Recieved_Frame,
	 input logic rx_enable
);
	//  Intermediate wires
	//wire baud_clk_R;          //  The clocking signal from the baud generator.
	logic [10:0]	data_parll_w; //  data_out parallel comes from the SIPO unit.
	logic 			recieved_flag_w;     //  works as an enable for deframe unit.
	logic 			def_par_bit_w;       //  The Parity bit from the Deframe unit to the ErrorCheck unit.
	logic 			def_strt_bit_w;      //  The Start bit from the Deframe unit to the ErrorCheck unit.
	logic 			def_stp_bit_w;       //  The Stop bit from the Deframe unit to the ErrorCheck unit.

	assign Recieved_Frame = data_parll_w;
	//  clocking Unit Instance
	BaudGenRx Unit1(
		//  Inputs
		.reset_n(reset_n),
		.clock(clock),
		.baud_rate(baud_rate),

		//  Output
		.baud_clk(baud_clk_R)
	);

	//  Shift Register Unit Instance
	SIPO Unit2(
		//  Inputs
		.reset_n(reset_n),
		.data_tx(data_tx),
		.baud_clk(baud_clk_R),
		.rx_enable(rx_enable),

		//  Outputs
		.active_flag(active_flag),
		.recieved_flag(recieved_flag_w),
		.data_parll(data_parll_w)
	//	 .data_parll_temp(Recieved_Frame)
	);

	//  DeFramer Unit Instance
	DeFrame Unit3(
		//  Inputs
		.reset_n(reset_n),
		.recieved_flag(recieved_flag_w),
		.data_parll(data_parll_w),
    
		//  Outputs
		.parity_bit(def_par_bit_w),
		.start_bit(def_strt_bit_w),
		.stop_bit(def_stp_bit_w),
		.done_flag(done_flag),
		.raw_data(data_out)
	);

	//  Error Checking Unit Instance
	ErrorCheck Unit4(
		//  Inputs
		.reset_n(reset_n),
		.recieved_flag(done_flag),
		.parity_bit(def_par_bit_w),
		.start_bit(def_strt_bit_w),
		.stop_bit(def_stp_bit_w),
		.parity_type(parity_type),
		.raw_data(data_out),

		//  Output
		.error_flag(error_flag)
	);

endmodule