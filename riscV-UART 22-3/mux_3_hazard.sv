module mux4 #
(
  parameter WIDTH = 32
) 
(
  input  logic [WIDTH-1:0] rs2_data_E,   // Source 2 data in Execute stage
  input  logic [WIDTH-1:0] wb_data_W,    // Write-back data in Write-back stage
  input  logic [WIDTH-1:0] alu_data_M,   // ALU result in Memory stage
  input  logic [1:0]       forward_B_E,  // Forwarding control for ALU operand B
  output logic [WIDTH-1:0] write_data_E  // Write data for memory or ALU input B
);
  
  assign write_data_E = forward_B_E[1] ? alu_data_M : 
                          (forward_B_E[0] ? wb_data_W : rs2_data_E);
endmodule
