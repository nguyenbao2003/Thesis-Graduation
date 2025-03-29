//
//`timescale 1ns/1ns
//
//module fifo_tb;
//    reg [7:0] dataIn;
//    reg clk = 0, writeEn = 0, readEn = 0 , reset = 0;
//
//    // output
//    wire Empty, Full; 
//    wire [7:0] dataOut;
//
//    FIFO_Buffer f1 (
//        .clk(clk),
//        .reset(reset),
//        .EMPTY(Empty),
//        .FULL(Full),
//        .writeEn(writeEn),
//        .readEn(readEn),
//        .dataIn(dataIn),
//        .dataOut(dataOut)
//    );
//    
//    initial begin
//			
//		  reset = 0;
//		  #10
//		  reset = 1;
//        writeEn = 1;
//        dataIn = 8'd255;
//        #10
//        dataIn = 8'd165;
//        #10
//        dataIn = 8'd109;
//        #10
//        dataIn = 8'd170;
//        #10
//        dataIn = 8'd180;
//        #10
//        dataIn = 8'd200;
//        #10
//        dataIn = 8'd210;
//        #10
//        dataIn = 8'd220;
//        #10
//        dataIn = 8'd230;
//
//        writeEn = 0;
//        readEn = 1;
//
//    end 
//
//    always #5 clk = ~clk;
//endmodule
module fifo_tb;

  reg 	 		clk;
  reg [15:0]    din;
  wire [15:0] 	dout;
  reg [15:0] 	rdata;
  reg 			empty;
  reg 			rd_en;
  reg 			wr_en;
  wire 			full;
  reg 			rstn;
  reg 			stop;

  FIFO_Buffer u_sync_fifo ( .reset(rstn),
                         .writeEn(wr_en),
                         .readEn(rd_en),
                         .clk(clk),
                         .dataIn(din),
                         .dataOut(dout),
                         .EMPTY(empty),
                         .FULL(full)
                        );

  always #10 clk <= ~clk;
  initial begin
    clk 	<= 0;
    rstn 	<= 0;
    wr_en 	<= 0;
    rd_en 	<= 0;
    stop  	<= 0;

    #50 rstn <= 1;
  end

  initial begin
    @(posedge clk);

    for (int i = 0; i < 20; i = i+1) begin

      // Wait until there is space in fifo
      while (full) begin
      	@(posedge clk);
        $display("[%0t] FIFO is full, wait for reads to happen", $time);
      end;

      // Drive new values into FIFO
      wr_en <= 1;
      din 	<= $random;
      $display("[%0t] clk i=%0d wr_en=%0d din=0x%0h ", $time, i, wr_en, din);

      // Wait for next clock edge
      @(posedge clk);
    end

    stop = 1;
  end
  initial begin
    @(posedge clk);

    while (!stop) begin
      // Wait until there is data in fifo
      while (empty) begin
        rd_en <= 0;
        $display("[%0t] FIFO is empty, wait for writes to happen", $time);
        @(posedge clk);
      end;

      // Sample new values from FIFO at random pace
      rd_en <= $random;
      @(posedge clk);
      rdata <= dout;
      $display("[%0t] clk rd_en=%0d rdata=0x%0h ", $time, rd_en, rdata);
    end

    #500 $finish;
  end
endmodule