module Address_Generator (
  input  logic         i_rst  ,
  input  logic         i_clk  ,
  input  logic         br_sel ,
  input  logic         StallF ,  // Stall signal for Fetch stage
  input  logic [31:0]  pc_four,
  input  logic [31:0]  pc_bru ,
  output logic [31:0]  pc
);
  logic [31:0] nxt_pc;

  // Combinational logic for next PC
  always_comb begin
    nxt_pc = br_sel ? pc_bru : pc_four;
  end

  // Sequential logic for PC update
  always_ff @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
      pc <= 32'd0; // Reset PC to 0
    end else if(StallF) begin
      pc <= pc;   
    end else begin
      pc <= nxt_pc;
    end
  end
endmodule