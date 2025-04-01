module third_reg (
  // Inputs from Execute (E) stage
  input  logic         i_clk     ,
  input  logic         i_rst     ,
  input  logic [31:0]  alu_data_E,  // ALU output from Execute stage
  input  logic [31:0]  pc_four_E ,  // PC + 4 from Execute stage
  input  logic [ 2:0]  funct3_E  ,  // funct3 from instruction
  input  logic         mem_wren_E,  // Memory write enable signal
  input  logic [ 1:0]  wb_sel_E  ,  // Write-back selection signal
  input  logic         rd_wren_E ,  // Register write enable signal
  input  logic [ 4:0]  rd_addr_E ,  // Destination register address
  input  logic [31:0]  ld_data_E ,  // Load data from Execute stage

  // Outputs to Memory Access (M) stage
  output logic [31:0]  alu_data_M,  // ALU output to Memory stage
  output logic [31:0]  pc_four_M ,  // PC + 4 to Memory stage
  output logic [ 2:0]  funct3_M  ,  // funct3 to LSU
  output logic [ 4:0]  rd_addr_M ,  // Destination register address
  output logic         mem_wren_M,  // Memory write enable to LSU
  output logic [ 1:0]  wb_sel_M  ,  // Write-back selection to MUX
  output logic         rd_wren_M ,  // Register write enable to MUX
  output logic [31:0]  ld_data_M    // Load data to Memory stage
);

  always_ff @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
      // Reset all outputs
      alu_data_M      <= 32'b0;
      pc_four_M       <= 32'b0;
      funct3_M        <= 3'b0;
      mem_wren_M      <= 1'b0;
      wb_sel_M        <= 2'b0;
      rd_wren_M       <= 1'b0;
      rd_addr_M       <= 5'b0;
      ld_data_M       <= 32'b0;
    end else begin
      // Pass-through from Execute (E) stage to Memory (M) stage
      alu_data_M      <= alu_data_E;
      pc_four_M       <= pc_four_E;
      funct3_M        <= funct3_E;
      mem_wren_M      <= mem_wren_E;
      wb_sel_M        <= wb_sel_E;
      rd_wren_M       <= rd_wren_E;
      rd_addr_M       <= rd_addr_E;
      ld_data_M       <= ld_data_E;
    end
  end
endmodule
