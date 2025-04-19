module FIFO_Buffer
(
	input              reset,               // Active low reset
                      clk,                // Clock
                      writeEn, 				// Write enable
                      readEn, 				// Read enable
	input      	 [7:0] dataIn, 				// Data written into FIFO
	output logic [2:0] wptr, rptr,
   output logic [7:0] dataOut, 				// Data read from FIFO
   output              		EMPTY, 				// FIFO is empty when high
                           FULL 				// FIFO is full when high
);


  logic [7:0]	fifo[8];
  
  assign check_fifo_tx = fifo[wptr];

  always @ (posedge clk or negedge reset) begin
    if (!reset) begin
      wptr <= 0;
    end else begin
      if (writeEn & !FULL) begin
        fifo[wptr] <= dataIn;
        wptr <= wptr + 1;
      end
    end
  end
  always @ (posedge clk or negedge reset) begin
    if (!reset) begin
      rptr <= 0;
    end else begin
      if (readEn & !EMPTY) begin
        dataOut <= fifo[rptr];
        rptr <= rptr + 1;
      end
    end
  end

  assign FULL  = ((wptr + 3'd1) == rptr);
  assign EMPTY = wptr == rptr;
endmodule