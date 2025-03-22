module second_reg	 (
  // Inputs from Decode stage
  input  logic         i_clk        ,
  input  logic         i_rst        ,
  input  logic [31:0]  pc_D         ,  // PC from Decode
  input  logic [31:0]  pc_four_D    ,  // PC + 4 from Decode
  input  logic [31:0]  ImmExtD      ,  // Extended immediate from ImmGen
  input  logic [31:0]  rs1_data_D   ,  // Register source 1 data from 		file
  input  logic [31:0]  rs2_data_D   ,  // Register source 2 data from 		file
  input  logic [ 4:0]  rd_addr_D    ,  // Destination 		ister address
  input  logic [ 4:0]  rs1_addr_D   ,  // Source 		ister 1 address
  input  logic [ 4:0]  rs2_addr_D   ,  // Source 		ister 2 address
  input  logic [ 2:0]  funct3_D     ,  // funct3 field from Controller
  input  logic [ 3:0]  alu_op_D     ,  // ALU operation from Controller
  input  logic [ 1:0]  wb_sel_D     ,  // Write-back selection
  input  logic         mem_wren_D   ,  // Memory write enable from Controller
  input  logic 		  br_sel       ,
  input  logic [ 6:0]  OP_D         ,
  //	 input logic 		  br_less_D,
  input  logic         rd_wren_D    ,  // Register write enable from Controller
  input  logic         br_unsigned_D,  // Unsigned branch select from Controller
  input  logic         op_a_sel_D   ,  // Operand A selection
  input  logic         op_b_sel_D   ,  // Operand B selection
  input  logic         slti_sel_D   ,  // SLTI selection
  input  logic         FlushE       ,  // Flush signal for Execute stage

  // Outputs to Execute stage
  output logic [31:0]  pc_E         ,
  output logic [31:0]  pc_four_E    ,
  output logic [31:0]  ImmExtE      ,
  output logic [31:0]  rs1_data_E   ,
  output logic [31:0]  rs2_data_E   ,
  output logic [ 4:0]  rd_addr_E    ,
  output logic [ 4:0]  rs1_addr_E   ,
  output logic [ 4:0]  rs2_addr_E   ,
  output logic [ 2:0]  funct3_E     ,
  output logic [ 3:0]  alu_op_E     ,
  output logic [ 1:0]  wb_sel_E     ,
  output logic         mem_wren_E   ,
  output logic         rd_wren_E    ,
  output logic 		  br_sel_E     ,
  output logic [ 6:0]  OP_E         ,
//	 output 		 logic 		  br_less_E,
  output logic         br_unsigned_E,
  output logic         op_a_sel_E   ,
  output logic         op_b_sel_E   ,
  output logic         slti_sel_E
);

  always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
      // Reset all Execute-stage outputs
      pc_E           <= 32'b0;
      pc_four_E      <= 32'b0;
      ImmExtE        <= 32'b0;
      rs1_data_E     <= 32'b0;
      rs2_data_E     <= 32'b0;
      rd_addr_E      <= 5'b0;
      rs1_addr_E     <= 5'b0;
      rs2_addr_E     <= 5'b0;
      funct3_E       <= 3'b0;
      alu_op_E       <= 4'b0;
      wb_sel_E       <= 2'b0;
      mem_wren_E     <= 1'b0;
      rd_wren_E      <= 1'b0;
      br_unsigned_E  <= 1'b0;
      op_a_sel_E     <= 1'b0;
      op_b_sel_E     <= 1'b0;
      br_sel_E       <= 1'b0;
		OP_E           <= 7'b0;
//		  br_less_E       <= 1'b0;
      slti_sel_E     <= 1'b0;
    end else if (FlushE) begin
      // Flush Execute-stage outputs
      pc_E           <= 32'b0;
      pc_four_E      <= 32'b0;
      ImmExtE        <= 32'b0;
      rs1_data_E     <= 32'b0;
      rs2_data_E     <= 32'b0;
      rd_addr_E      <= 5'b0;
      rs1_addr_E     <= 5'b0;
      rs2_addr_E     <= 5'b0;
      funct3_E       <= 3'b0;
      alu_op_E       <= 4'b0;
      wb_sel_E       <= 2'b0;
      mem_wren_E     <= 1'b0;
      rd_wren_E      <= 1'b0;
      br_unsigned_E  <= 1'b0;
      op_a_sel_E     <= 1'b0;
      op_b_sel_E     <= 1'b0;
      br_sel_E       <= 1'b0;
		OP_E           <= 7'b0;
//		  br_less_E       <= 1'b0;
      slti_sel_E     <= 1'b0;
    end else begin
      // Pass values from Decode stage to Execute stage
      pc_E           <= pc_D;
      pc_four_E      <= pc_four_D;
      ImmExtE        <= ImmExtD;
      rs1_data_E     <= rs1_data_D;
      rs2_data_E     <= rs2_data_D;
      rd_addr_E      <= rd_addr_D;
      rs1_addr_E     <= rs1_addr_D;
      rs2_addr_E     <= rs2_addr_D;
      funct3_E       <= funct3_D;
      alu_op_E       <= alu_op_D;
      wb_sel_E       <= wb_sel_D;
      mem_wren_E     <= mem_wren_D;
      rd_wren_E      <= rd_wren_D;
      br_unsigned_E  <= br_unsigned_D;
      op_a_sel_E     <= op_a_sel_D;
      br_sel_E       <= br_sel;
		OP_E           <= OP_D;
//		  br_less_E       <= br_less_D;
      op_b_sel_E     <= op_b_sel_D;
      slti_sel_E     <= slti_sel_D;
    end
  end

endmodule
