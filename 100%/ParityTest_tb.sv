`timescale 1ns/1ps
module ParityTest_tb;

// Regs to drive the inputs
reg       reset_n;
reg [7:0] reg_data;


// Wire to show the output
wire      parity_bit;

typedef enum logic [1:0] {
    NOPARITY00  = 2'b00,
    ODD  = 2'b01,
    EVEN  = 2'b10,
    NOPARITY11 = 2'b11
} parity_bit_t;

parity_bit_t parity_type;
parity_bit_t parity[4] = {NOPARITY00, ODD, EVEN, NOPARITY11};

// Instantiation of the design module
Parity ForTest(
    .data_in(reg_data),
    .reset_n(reset_n),
    .parity_type(parity_type),

    .parity_bit(parity_bit)
);


// Monitoring the outputs and the inputs
initial begin
    $monitor($time, 
             " Outputs: Parity Bit = %b, Inputs: Parity Type = %s, Reset = %b, Data In = %b",
             parity_bit, parity_type, reset_n, reg_data);
end

// Resetting the system
initial
begin
    reset_n = 1'b0;
    #10 reset_n = 1'b1;
end

// Test
initial
begin
    reg_data = 8'b00010111;
    #10 reg_data = 8'b00001111;
    #10 reg_data = 8'b10101111;
    #10 reg_data = 8'b10101001;
    #10 reg_data = 8'b10101001;
    #10 reg_data = 8'b10111101;
end


// Parity Types
initial
begin
    parity_type = parity[0];
    #10 parity_type = parity[0];
    #10 parity_type = parity[1];
    #10 parity_type = parity[2];
    #10 parity_type = parity[3];
end

endmodule