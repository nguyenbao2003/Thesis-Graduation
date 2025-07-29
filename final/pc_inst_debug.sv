module pc_inst_debug(
	input  logic         i_clk     ,
	input  logic         i_rst     ,
	input  logic         insn_vld  ,
	input  logic [31:0]  pc        ,
	output logic         o_insn_vld,
	output logic [31:0]  o_pc_debug
);

  always_ff @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
	   o_insn_vld <= 1'b0;
		o_pc_debug <= 32'b0;
	 end else begin
		o_insn_vld <= insn_vld;
		o_pc_debug <= pc;
	 end
  end
endmodule