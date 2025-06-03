`timescale 1ns/1ps
module PisoTest_tb;

//Test Inputs
logic       reset_n;
logic       send;
logic       baud_clk;
logic       parity_bit;
//logic [1:0] parity_type;
logic [7:0] reg_data;


//Test outputs
logic      data_tx;
logic      active_flag;
logic      done_flag;

logic [3:0]   stop_count;
logic [10:0]  frame_r;
logic [10:0]  frame_man;
logic         next_state;
logic         count_full;

typedef enum logic [1:0] {
    NOPARITY00  = 2'b00,
    ODD  = 2'b01,
    EVEN  = 2'b10,
    NOPARITY11 = 2'b11
} parity_bit_t;

parity_bit_t parity_type;
parity_bit_t parity[4] = {NOPARITY00, ODD, EVEN, NOPARITY11};

//Instantiation of the designed block
PISO ForTest(
    .parity_type(parity_type),
    .parity_bit(parity_bit),
    .send(send),
    .reset_n(reset_n),
	 .baud_clk(baud_clk),
    .data_in(reg_data),

    .data_tx(data_tx),
    .active_flag(active_flag),
    .done_flag(done_flag),
	 
	 .stop_count(stop_count),
	 .frame_r(frame_r),
	 .frame_man(frame_man),
	 .next_state(next_state),
	 .count_full(count_full)
);

//  dump
initial
begin
    $dumpfile("PisoTest.vcd");
    $dumpvars;
end

//Monitorin the outputs and the inputs
initial begin
    $monitor($time, "   The Outputs:  DataOut = %b  ActiveFlag = %b  DoneFlag = %b The Inputs:   Send = %b  Reset = %b   ParityType = %b   Parity Bit = %b  Data In = %b ",
     data_tx, active_flag, done_flag, send, reset_n, parity_type[1:0], parity_bit, reg_data[7:0]);
end


//   Resetting the system
initial begin
         reset_n = 1'b0;
    #100 reset_n = 1'b1;
end

//   Set up a clock "Baudrate"
//   For example: Baud Rate of 9600
initial
begin
    baud_clk = 1'b0;
    forever
    begin
     #104166.667 baud_clk = ~baud_clk;
    end
end

//   Set up the send signal
initial begin
          send = 1'b0;
    #1000 send = 1'b1;
end 

//   Varying the stopits, datalength, paritytype >>> 4-bits with 16 different cases with 8 ignored cases <<<
initial
begin
     //  no parity
     parity_type = parity[0];
     parity_bit  =   (^(8'b01001010))? 1'b0 : 1'b1;
     //   odd parity
     #2291653;
     parity_type = parity[1];
     parity_bit  =   (^(8'b01001010))? 1'b0 : 1'b1;
     //  even parity
     #2291653;
     parity_type = parity[2];
     parity_bit  =   (^(8'b01001010))? 1'b1 : 1'b0;
     //  no parity
     #2291653;
     parity_type = parity[3];
     parity_bit  =   (^(8'b01011010))? 1'b0 : 1'b1;
     #2291653;
end


//   Various Data In 
initial begin

    reg_data = 8'b01001010;
    #2291653;
    reg_data = 8'b01001010;
    #2291653;
    reg_data = 8'b01001010;
    #2291653;
    reg_data = 8'b01011010;
    #2291653;
end

initial begin
    #12000000 $stop;
end

endmodule