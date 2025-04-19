module decoder (
  input  logic [31:0]  instr_D ,
  output logic [ 4:0]  rs1_addr,
  output logic [ 4:0]  rs2_addr,
  output logic [ 4:0]  rd_addr ,
  output logic [ 6:0]  OP      ,
  output logic [ 2:0]  funct3  ,
  output logic         funct7  ,
  output logic         OPb5    ,
  output logic [24:0]  imm     ,
  output logic [ 6:0]  funct77
);
  always_comb begin
    rs1_addr = instr_D[19:15];
	 rs2_addr = instr_D[24:20];
	 rd_addr  = instr_D[11:7];
	 OP       = instr_D[6:0];
	 OPb5	 	 = instr_D[5];
	 funct3   = instr_D[14:12];
	 funct7   = instr_D[30];
	 imm      = instr_D[31:7];
	 funct77  = instr_D[31:25];
  end
   
endmodule