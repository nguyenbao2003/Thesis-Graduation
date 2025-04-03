module ImmGen (
	input  logic [24:0]   imm    ,
	input  logic [ 2:0]   ImmSel ,
	output logic [31:0]   ImmExtD
);

  always_comb begin
    casex(ImmSel)
      3'b000:  ImmExtD = {{20{imm[24]}}, imm[24:13]};                            // I-type
		3'b001:  ImmExtD = {{20{imm[24]}}, imm[24:18], imm[4:0]};                  // S-type (stores)
		3'b010:  ImmExtD = {{20{imm[24]}}, imm[0],  imm[23:18], imm[4:1], 1'b0};   // B-type (branches)
		3'b011:  ImmExtD = {{12{imm[24]}}, imm[12:5],  imm[13], imm[23:14], 1'b0}; // J-type (branches)		
		3'b100:  ImmExtD = {imm[24:5], 12'b000000000000 };                         // U-type
		default: ImmExtD = 32'dx;                                                  // undefined
    endcase
  end
endmodule