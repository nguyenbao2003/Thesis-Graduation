module branch_prediction (
  input  logic         i_clk           ,
  input  logic         i_rst           ,
  
  // Fetch stage input signals
  input  logic [31:0]  i_PC_F          ,  // Current Program Counter
  output logic         o_prediction    ,  // Branch prediction (1: Taken, 0: Not Taken)
  output logic [31:0]  o_PCTarget_F    ,  // Predicted target PC (valid if prediction = 1)
    
  // Decode
  input  logic [ 1:0]  i_index_D       ,
  input  logic [31:0]  i_PC_D          ,
  input  logic [31:0]  i_instr_D       ,
	 
  // Execute stage input signals
  input  logic [ 1:0]  i_index_E       ,  // PCE[3:2]
  input  logic [27:0]  i_tag_E         ,  // PCE[31:4]
  input  logic [31:0]  i_PCTarget_E    ,  // Actual target PC if branch is taken
  input  logic         i_branch_E      ,  // Indicates if the current instruction is a branch
  input  logic         i_branch_taken_E,  // Actual branch outcome from execute stage
  input  logic         i_jump_E        ,  // Indicates if the current instruction is a jump
  input  logic [31:0]  i_pc_four_E     ,
  output logic         o_mispredict
);

  // Parameters
  localparam INDEX_BITS = 2;          // Number of bits for indexing (2 bits for 4 entries)
  localparam TAG_BITS = 28;           // Remaining bits for the tag (32-bit PC minus 2 index bits)

  // Define the 2-bit FSM states
  localparam logic [1:0] STRONG_NOT_TAKEN = 2'b00;
  localparam logic [1:0] WEAK_NOT_TAKEN   = 2'b01;
  localparam logic [1:0] WEAK_TAKEN       = 2'b10;
  localparam logic [1:0] STRONG_TAKEN     = 2'b11;

  // BTB Entry Structure
  struct packed {
    logic [TAG_BITS-1:0] tag;       // Higher bits of PC for correctness check
	 logic [31:0] target;            // Predicted target address
	 logic [1:0] state;              // FSM state for branch prediction
  }BTB [0:(1 << INDEX_BITS)-1];

  // Extract index and tag from PC
  logic [INDEX_BITS-1:0] index;
  logic [TAG_BITS-1:0] tag, i_tag_D;
  logic is_branch_D;


  assign index = i_PC_F[3:2];                 // Use bits [3:2] of the PC for indexing
  assign tag = i_PC_F[31:4];                  // Use the remaining bits as the tag
  assign is_branch_D = (i_instr_D[6:0] == 7'b1100011);
  assign i_tag_D = i_PC_D[31:4]; 
  integer i;

  assign o_mispredict = ((i_tag_E == BTB[i_index_E].tag) && i_branch_taken_E != BTB[i_index_E].state[1]) | i_jump_E ;
 
  // Fetch Stage Logic
  always_comb begin
    o_prediction = 1'b0;                  // Default prediction: Not Taken
	 o_PCTarget_F = 32'h00000000;           // Default target: 0
	   if (o_mispredict) begin
		  o_prediction = 1'b1;
		if (i_branch_taken_E)
		  o_PCTarget_F = i_PCTarget_E;
		else 
		  o_PCTarget_F = i_pc_four_E;
	   end else if ((BTB[index].tag == tag)) begin
			// Tag matches, predict based on FSM state
		  case (BTB[index].state)
		    STRONG_NOT_TAKEN, WEAK_NOT_TAKEN: o_prediction = 1'b0;
			 WEAK_TAKEN, STRONG_TAKEN: o_prediction = 1'b1;
		  endcase
		  if (o_prediction)
		    o_PCTarget_F = BTB[index].target;
		end
  end

  // Execute Stage Logic
  logic [1:0] state_num;
  always_ff @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
		// Reset logic: Initialize BTB entries
	   for (i = 0; i < (1 << INDEX_BITS); i = i + 1) begin
		  BTB[i].tag <= {TAG_BITS{1'b0}};
		  BTB[i].target <= 32'h00000000;
		  BTB[i].state <= STRONG_NOT_TAKEN;
      end
	 end else if (is_branch_D) begin
	   if (BTB[i_index_D].tag != i_tag_D) begin
	     BTB[i_index_D].tag <= i_PC_D[31:4]; // Update tag
	     BTB[i_index_D].state <= STRONG_NOT_TAKEN;
		end  
	 end else if (i_branch_E) begin
		// FSM state transition
	   state_num = BTB[i_index_E].state;
		
		case (state_num)
		  // state 0
		  STRONG_NOT_TAKEN: begin
		    if (i_branch_taken_E) begin
			   state_num++;
			 end else begin
				state_num = STRONG_NOT_TAKEN;
			 end
		  end
		  // state 1
		  WEAK_NOT_TAKEN: begin
		    if (i_branch_taken_E) begin
		      state_num++;
			 end else begin
				state_num--;
			 end
		  end
		  // state 2
		  WEAK_TAKEN: begin
		    if (i_branch_taken_E) begin
			   state_num++;
			 end else begin
			   state_num--;
			 end
		  end
		  // state 3
		  STRONG_TAKEN: begin
		    if (i_branch_taken_E) begin
			   state_num = STRONG_TAKEN;
			 end else begin
			   state_num--;
			 end
		  end
		  // default state
		  default: begin
		    state_num = STRONG_NOT_TAKEN;
			end
		 endcase

		 // Update the BTB entry with the new state
		 BTB[i_index_E].state <= state_num;

		 // Update the target if the branch was taken
		 if (i_branch_taken_E) begin
		   BTB[i_index_E].target <= i_PCTarget_E;
		 end
	  end
  end
    
endmodule