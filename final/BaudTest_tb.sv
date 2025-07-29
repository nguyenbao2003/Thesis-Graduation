`timescale 1ns/1ps
module BaudTest_tb;

//  Regs to drive inputs
reg       reset_n;
reg       clock;

// Using enum type for baud_rate
typedef enum logic [1:0] {
    BAUD24  = 2'b00,
    BAUD48  = 2'b01,
    BAUD96  = 2'b10,
    BAUD192 = 2'b11
} baud_rate_t;

baud_rate_t baud_rate;

//  wires to show outputs
wire      baud_clk;

//  Instance of the design module
BaudGenTx ForTest(
    .reset_n(reset_n),
    .clock(clock),
    .baud_rate(baud_rate),
    .baud_clk(baud_clk)
	 
);


//  System's clock 50MHz
initial
begin
    clock = 1'b0;
    forever #10 clock = ~clock;
end

//  Resetting the system
initial 
begin
    reset_n = 1'b0;
    #100  reset_n = 1'b1;
end

//  Test
integer i = 0;
baud_rate_t rates[4] = {BAUD24, BAUD48, BAUD96, BAUD192};
initial 
begin
    for (i = 0; i < 4; i = i +1) 
    begin
        baud_rate = rates[i];
        #(3000000 / (i + 1));  // Delay remains the same
    end
end

endmodule