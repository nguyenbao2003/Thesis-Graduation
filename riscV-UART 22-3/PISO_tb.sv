module PISO_tb;

//Test Inputs
reg       reset_n;
reg       send;
reg       baud_clk;
reg       parity_bit;
reg [1:0] parity_type;
reg [7:0] reg_data;


//Test outputs
wire      data_tx;
wire      active_flag;
wire      done_flag;
wire [10:0]  frame_r;
 wire [10:0]  frame_man;
 wire         next_state;
    wire         count_full;
//Instantiation of the designed block
PISO ForTest(
    .parity_type(parity_type),
    .parity_bit(parity_bit),
	 .baud_clk(baud_clk),
    .send(send),
    .reset_n(reset_n),
    .data_in(reg_data),
	 .frame_r (frame_r),
	 .frame_man(frame_man),
	 .next_state(next_state),
	 .count_full(count_full),
    .data_tx(data_tx),
    .active_flag(active_flag),
    .done_flag(done_flag)
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
     #10 baud_clk = ~baud_clk;
    end
end

//   Set up the send signal
initial begin
          send = 1'b0;
    #150 send = 1'b1;
end 

//   Varying the stopits, datalength, paritytype >>> 4-bits with 16 different cases with 8 ignored cases <<<
initial
begin
     //  no parity
     parity_type = 2'b00;
     parity_bit  =   (^(01001010))? 1'b0 : 1'b1;
     //   odd parity
     #100;
     parity_type = 2'b01;
     parity_bit  =   (^(01001010))? 1'b0 : 1'b1;
     //  even parity
     #100;
     parity_type = 2'b10;
     parity_bit  =   (^(01001010))? 1'b1 : 1'b0;
     //  no parity
     #100;
     parity_type = 2'b11;
     parity_bit  =   (^(01011010))? 1'b0 : 1'b1;
     #100;
end


//   Various Data In 
initial begin

    reg_data = 8'b01001010;
    #100;
    reg_data = 8'b01001010;
    #100;
    reg_data = 8'b01001010;
    #100;
    reg_data = 8'b01011010;
    #100;
end

initial begin
    #2000 $stop;
end

endmodule