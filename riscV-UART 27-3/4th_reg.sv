module fourth_reg	 (
  // Inputs from Memory (MEM) stage
  input  logic [31:0]  alu_data_M ,  // ALU result from Memory stage
  input  logic [31:0]  read_data_M,  // Data read from memory
  input  logic [31:0]  pc_four_M  ,  // PC + 4 from Memory stage
  input  logic [ 4:0]  rd_addr_M  ,  // Destination 	ister address in Memory stage
  input  logic	        i_rst      ,  // Reset signal
  input  logic	        i_clk      ,  // Clock signal
  input  logic [ 1:0]  wb_sel_M   ,  // Write-back selection from Memory stage
  input  logic	        rd_wren_M  ,  // Register write enable from Memory stage

  // Outputs to Write-Back (WB) stage
  output logic [31:0]  alu_data_W ,  // ALU result to Write-back stage
  output logic [31:0]  read_data_W,  // Data read from memory to Write-back stage
  output logic [31:0]  pc_four_W  ,  // PC + 4 to Write-back stage
  output logic [ 4:0]  rd_addr_W  ,  // Destination 	ister address to Write-back stage
  output logic [ 1:0]  wb_sel_W   ,  // Write-back selection to Write-back stage
  output logic 		  rd_wren_W     // Register write enable to Write-back stage
);

  always_ff @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
      alu_data_W  <= 32'd0;
      read_data_W <= 32'd0;
      pc_four_W   <= 32'd0;
      rd_addr_W   <=  5'd0;
      wb_sel_W    <=  2'd0;
      rd_wren_W   <=  1'b0;
    end else begin
      alu_data_W  <= alu_data_M ;
      read_data_W <= read_data_M;
      pc_four_W   <= pc_four_M  ;
      rd_addr_W   <= rd_addr_M  ;
      wb_sel_W    <= wb_sel_M   ;
      rd_wren_W   <= rd_wren_M  ;
    end
  end

endmodule
