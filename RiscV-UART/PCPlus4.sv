module PCPlus4(
	input  logic [31:0]  pc,
	output logic [31:0]  pc_four
);
  always_comb begin
	 pc_four = pc + 4;
  end

endmodule