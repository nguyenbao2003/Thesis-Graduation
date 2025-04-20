

`timescale 1ns/1ps
module TxTest_tb;

//  Regs to drive the inputs
reg       reset_n;
reg       send;
reg       clock; 
wire baud_clk_T;
//reg [1:0] parity_type;
//reg [1:0] baud_rate;
reg [7:0] data_in; 

//  wires to show the output
wire      data_tx;
wire      active_flag;
wire      done_flag; 

typedef enum logic [1:0] {
    NOPARITY00  = 2'b00,
    ODD  = 2'b01,
    EVEN  = 2'b10,
    NOPARITY11 = 2'b11
} parity_bit_t;

parity_bit_t parity_type;
parity_bit_t parity[4] = {NOPARITY00, ODD, EVEN, NOPARITY11};
 
typedef enum logic [1:0] {
    BAUD24  = 2'b00,
    BAUD48  = 2'b01,
    BAUD96  = 2'b10,
    BAUD192 = 2'b11
} baud_rate_t;

baud_rate_t baud_rate;
baud_rate_t rates[4] = {BAUD24, BAUD48, BAUD96, BAUD192};

//  Instance for the design module
TxUnit ForTest(
    //  Inputs
    .reset_n(reset_n),
    .send(send), 
    .clock(clock),
    .parity_type(parity_type),
    .baud_rate(baud_rate),
    .data_in(data_in),
	 .baud_clk_T(baud_clk_T),

    //  Outputs
    .data_tx(data_tx),
    .active_flag(active_flag),
    .done_flag(done_flag)
);

//  dump
initial
begin
    $dumpfile("TxTest.vcd");
    $dumpvars;
end

//  Monitoring the outputs and the inputs
initial begin
    $monitor($time, "   The Outputs:  Data Tx = %b  Done Flag = %b  Active Flag = %b The Inputs:   Reset = %b  Data In = %b  Send = %b Parity Type = %b  Baud Rate = %b",
    data_tx, done_flag, active_flag, reset_n, 
    data_in[7:0], send, parity_type[1:0], baud_rate[1:0]);
end

//  50Mhz clock
initial
begin
    clock = 1'b0;
    forever
    begin
      #10 clock = ~clock; 
    end 
end

//  Reseting the system
initial
begin
    reset_n = 1'b0;
    send    = 1'b0;
    #100;
    reset_n = 1'b1;
    send    = 1'b1;
end

//  Varying the Baud Rate and the Parity Type
initial
begin
    //  Testing data
    data_in = 8'b10101010 ;
    //  test for baud rate 9600 and odd parity
    baud_rate   = rates[2];
    parity_type = parity[1];
    #1354166.671;   //  waits for the whole frame to be sent

    //  Testing data
    data_in = 8'b10101010 ;
    //  test for baud rate 19200 and even parity
    baud_rate   = rates[3];
    parity_type = parity[2];
    #677083.329;   //  waits for the whole frame to be sent
end

//  Stop
initial begin
    #2600000 $stop;
    // Simulation for 3 ms
end

endmodule