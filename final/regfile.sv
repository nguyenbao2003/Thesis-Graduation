module regfile (
  input  logic [ 4:0]  i_rs1_addr,
  input  logic [ 4:0]  i_rs2_addr,
  input  logic [ 4:0]  i_rd_addr ,
  input  logic [31:0]  i_rd_data ,
  input  logic         i_clk     ,
  input  logic         i_rd_wren ,
  input  logic         i_rst     ,
  output logic [31:0]  o_rs1_data,
  output logic [31:0]  o_rs2_data,
  output logic [31:0]  checkx1   ,  //it is to see x1 of logicister file (you can ignore it if your simulator allows you to see full RF)
  output logic [31:0]  checkx2   ,
  output logic [31:0]  checkx3   ,
  output logic [31:0]  checkx4   ,
  output logic [31:0]  checkx5   ,
  output logic [31:0]  checkx6   ,
  output logic [31:0]  checkx7
);
  logic [31:0] Registers[31:0];
  integer j;

  always_comb begin
    o_rs1_data = Registers[i_rs1_addr];
    o_rs2_data = Registers[i_rs2_addr];
		  
    checkx1 = Registers[1];
    checkx2 = Registers[2];
    checkx3 = Registers[3];
    checkx4 = Registers[4];
    checkx5 = Registers[5];
    checkx6 = Registers[6];
	 checkx7 = Registers[7];
  end

  always_ff @(negedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
      for(j = 0; j < 32;j = j + 1) begin
        Registers[j] <= 32'd0;
      end
    end else if (i_rd_wren && (|i_rd_addr)) begin    //i_rd_addr, avoid writing at x0
      Registers[i_rd_addr] <= i_rd_data;
    end
  end
    
endmodule