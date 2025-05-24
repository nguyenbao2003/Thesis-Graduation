module seven_led(
	 input logic [6:0] io_hex0_o,  // 7-segment LED inputs
    input logic [6:0] io_hex1_o,
    input logic [6:0] io_hex2_o,
    input logic [6:0] io_hex3_o,
    input logic [6:0] io_hex4_o,
    input logic[6:0] io_hex5_o,
    input logic[6:0] io_hex6_o,
    input logic[6:0] io_hex7_o, 
	 output  logic[6:0]          HEX0, // 8 32-bit data to drive 7-segment LEDs.
	 output  logic[6:0]          HEX1,
	 output  logic[6:0]          HEX2,
	 output  logic[6:0]          HEX3,
	 output  logic[6:0]          HEX4,
	 output  logic[6:0]          HEX5,
	 output  logic[6:0]          HEX6,
	 output  logic[6:0]          HEX7
);

	logic [6:0] Display0,Display1, Display2, Display3, Display4,Display5, Display6, Display7;

	function [6:0] conv_to_seg(
		input [3:0] Digit
	);
		case (Digit)
			4'b0000 : conv_to_seg = 7'h40;
			4'b0001 : conv_to_seg = 7'h79;
			4'b0010 : conv_to_seg = 7'h24;
			4'b0011 : conv_to_seg = 7'h30;
			4'b0100 : conv_to_seg = 7'h19;          
			4'b0101 : conv_to_seg = 7'h12;
			4'b0110 : conv_to_seg = 7'h02;
			4'b0111 : conv_to_seg = 7'h78;
			4'b1000 : conv_to_seg = 7'h00; // 8
			4'b1001 : conv_to_seg = 7'h10; // 9
			4'b1010 : conv_to_seg = 7'h08; // A
			4'b1011 : conv_to_seg = 7'h03; // B
			4'b1100 : conv_to_seg = 7'h46; // C
			4'b1101 : conv_to_seg = 7'h21; // D
			4'b1110 : conv_to_seg = 7'h06; // E
			4'b1111 : conv_to_seg = 7'h0E; // F
			default: ;// do nothing
		endcase
	endfunction

	assign Display0 = conv_to_seg( io_hex0_o);
	assign Display1 = conv_to_seg( io_hex1_o);
	assign Display2 = 7'h3F;
	assign Display3 = 7'h3F;
	assign Display4 = 7'h3F;
	assign Display5 = 7'h3F;
	assign Display6 = 7'h3F;
	assign Display7 = 7'h3F;

   assign    HEX0 = Display0 ; // 8 32-bit data to drive 7-segment LEDs.
	assign    HEX1 = Display1 ;
	assign    HEX2 = Display2 ;
	assign    HEX3 = Display3 ;
	assign    HEX4 = Display4 ;
	assign    HEX5 = Display5 ;
	assign    HEX6 = Display6 ;
	assign    HEX7 = Display7 ; 
endmodule