module mux5 #
(
  parameter WIDTH = 32
)
(
  input  logic [WIDTH-1:0] rs1_data_E ,  // Source 1 data in Execute stage
  input  logic [WIDTH-1:0] wb_data_W  ,  // Write-back data in Write-back stage
  input  logic [WIDTH-1:0] alu_data_M ,  // ALU result in Memory stage
  input  logic [1:0]       forward_A_E,  // Forwarding control for ALU operand A
  output logic [WIDTH-1:0] src_A_E       // Source A input to ALU
);
  assign src_A_E = forward_A_E[1] ? alu_data_M : 
                   (forward_A_E[0] ? wb_data_W : rs1_data_E);
endmodule
