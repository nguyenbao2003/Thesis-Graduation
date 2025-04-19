module fifo_tb;

  reg 	 		clk;
  reg [7:0]    din;
  wire [7:0] 	dout;
  reg [7:0] 	rdata;
  reg 			empty;
  reg 			rd_en;
  reg 			wr_en;
  wire 			full;
  reg 			rstn;
  reg 			stop;
  reg [2:0] wptr, rptr;

  FIFO_Buffer u_sync_fifo ( .reset(rstn),
                         .writeEn(wr_en),
                         .readEn(rd_en),
                         .clk(clk),
                         .dataIn(din),
                         .dataOut(dout),
                         .EMPTY(empty),
                         .FULL(full),
								 .wptr(wptr),
								 .rptr(rptr)
                        );

  always #10 clk <= ~clk;
  initial begin
    clk 	<= 0;
    rstn 	<= 0;
    wr_en 	<= 0;
    rd_en 	<= 0;
    stop  	<= 0;

    #20 rstn <= 1;
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