module mux_1(
  input  logic [31:0] 	pc_four  ,
  input 	logic	[31:0] 	alu_data ,
  input 	logic	[31:0] 	ld_data_2,
  input 	logic	[ 1:0] 	wb_sel   ,
  output logic [31:0] 	wb_data
);

  always_comb begin
    case (wb_sel)
      2'b00: 	wb_data 	= alu_data;
	   2'b01: 	wb_data 	= ld_data_2;
		default: wb_data 	= pc_four;
	 endcase
  end
endmodule	