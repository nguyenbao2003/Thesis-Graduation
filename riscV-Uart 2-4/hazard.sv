module hazard (
  // Inputs
  input  logic        i_rst      ,
  input  logic [4:0]  rs1_addr_E ,  // Source register 1 address in Execute stage
  input  logic [4:0]  rs2_addr_E ,  // Source register 2 address in Execute stage
  input  logic [4:0]  rd_addr_M  ,  // Destination register address in Memory stage
  input  logic [4:0]  rd_addr_W  ,  // Destination register address in Write-back stage
  input  logic [4:0]  rs1_addr_D ,  // Source register 1 address in Decode stage
  input  logic [4:0]  rs2_addr_D ,  // Source register 2 address in Decode stage
  input  logic [4:0]  rd_addr_E  ,  // Destination register address in Execute stage
  input  logic [1:0]  wb_sel_E   ,  // Write-back selection in Execute stage
  input  logic        rd_wren_M  ,  // Register write enable in Memory stage
  input  logic        rd_wren_W  ,  // Register write enable in Write-back stage
  input  logic        br_sel     ,  // Program counter selection in Execute stage
  input  logic        mispredict ,  // From Branch Prediction

  // Outputs
  output logic        StallF     ,  // Stall signal for Fetch stage
  output logic        StallD     ,  // Stall signal for Decode stage
  output logic        FlushE     ,  // Flush signal for Execute stage
  output logic        FlushD     ,  // Flush signal for Decode stage
  output logic [1:0]  forward_A_E,  // Forwarding control for ALU operand A
  output logic [1:0]  forward_B_E   // Forwarding control for ALU operand B
);
  
  logic lw_stall;
  // Forwarding logic for ALU Operand A
   assign forward_A_E = (i_rst == 1'b0) ? 2'b00 : 
                         ((rd_wren_M == 1'b1) && (rd_addr_M != 5'h00) && (rd_addr_M == rs1_addr_E)) ? 2'b10 :
                         ((rd_wren_W == 1'b1) && (rd_addr_W != 5'h00) && (rd_addr_W == rs1_addr_E)) ? 2'b01 : 
                         2'b00;

  // Forwarding logic for ALU Operand B
  assign forward_B_E = (i_rst == 1'b0) ? 2'b00 : 
                         ((rd_wren_M == 1'b1) && (rd_addr_M != 5'h00) && (rd_addr_M == rs2_addr_E)) ? 2'b10 :
                         ((rd_wren_W == 1'b1) && (rd_addr_W != 5'h00) && (rd_addr_W == rs2_addr_E)) ? 2'b01 : 
                         2'b00;
  always_comb begin
    // Detect Load-Use Hazard
      lw_stall = (wb_sel_E[0] & ((rs1_addr_D == rd_addr_E) | (rs2_addr_D == rd_addr_E)));

    // Set stall and flush signals
      StallF  = lw_stall;
      StallD  = lw_stall;
      FlushE  = lw_stall | mispredict;
      FlushD  = mispredict;
  end
endmodule

