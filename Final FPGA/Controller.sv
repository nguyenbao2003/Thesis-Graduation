
module Controller (
  input  logic [31:0]  instr_D    ,
  input  logic [ 6:0]  OP         ,
  input  logic [ 6:0]  funct77    ,
  input  logic [ 2:0]  funct3     ,
  input  logic         funct7     ,
  input	logic			  OPb5       ,
  output logic         mem_wren   ,
  output logic         rd_wren    ,
  output logic 		  op_a_sel   ,
  output logic 		  op_b_sel   ,
  output logic 		  br_sel     ,
  output logic	 		  br_unsigned,
  output logic 		  slti_sel   ,
  output logic 		  insn_vld   ,
  output logic [ 3:0]  alu_op     ,
  output logic [ 1:0]  wb_sel     ,
  output logic [ 2:0]  ImmSel     ,
  input  logic  i_clk,
  input  logic  i_rst,
  output logic [10:0]  cnt,
  output logic [10:0]  cnt_instr
);
 
  logic [1:0] alu_control;
  logic 		  br_sel_tmp;
	
  // Check instr_Duction valid
  always_comb begin
    if (instr_D == 32'b0) begin
      insn_vld = 0;  // instr_Duction is invalid if it's all zeros
    end else begin
			// Check if the opcode matches one of the valid opcodes
      case (OP)
        7'b0000011: insn_vld = 1; // lw
		  7'b0100011: insn_vld = 1; // sw
		  7'b0110011: insn_vld = 1; // R-type
	     7'b1100011: insn_vld = 1; // branch
		  7'b0010011: insn_vld = 1; // I-type
		  7'b1101111: insn_vld = 1; // j
		  7'b1100111: insn_vld = 1; // jalr
		  7'b0110111: insn_vld = 1; // lui
        7'b0010111: insn_vld = 1; // auipc
        default: insn_vld = 0;  // Invalid instr_Duction if opcode doesn't match
      endcase
    end
  end
  
  always_ff @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
	   cnt <= 0; 
    end else if (insn_vld) begin
	   cnt <= cnt + 1;
		cnt_instr <= cnt_instr + 1;
    end else begin
	   cnt_instr <= cnt_instr + 1;
	 end
  end
	
  always_comb begin
    br_unsigned = 0;
    slti_sel = 0;
    if (OP == 7'b1100011) begin
      case(funct3)
	     3'b000:   br_unsigned =  0; //beq
		  3'b001:   br_unsigned =  0; //bne
		  3'b100:   br_unsigned =  0;  //blt
		  3'b101:   br_unsigned =  0;  //bge
		  3'b110:   br_unsigned =  1;  //bltu
		  3'b111:   br_unsigned =  1; //bgeu
		  default : br_unsigned =  0;
	   endcase
    end else if (OP == 7'b0110011) begin
		case(funct3)
		  3'b010:   br_unsigned =  0; // slt
		  3'b011:   br_unsigned =  1; // sltu
		  default: br_unsigned = 0;
		endcase
    end else if (OP == 7'b0010011) begin
		case(funct3)
		  3'b010: begin
		    slti_sel = 1;
			 br_unsigned = 0;	// slti
		  end
		  3'b011: begin
		    slti_sel = 1;
		    br_unsigned = 1;	// sltiu
		  end
		  default: begin
		    slti_sel = 0;
		    br_unsigned = 0;
		  end
      endcase
    end else begin
      br_unsigned = 0;
    end
  end	
		
//  always_comb begin
//    case(funct3)
//	   3'b000:   br_sel_tmp = (br_equal)? 1'b1 : 1'b0; //beq
//		3'b001:   br_sel_tmp = (~br_equal)? 1'b1 : 1'b0; //bne
//		3'b100:   br_sel_tmp = (br_less)? 1'b1 : 1'b0;  //blt
//		3'b101:   br_sel_tmp = (!br_less | br_equal)? 1'b1 : 1'b0;  //bge
//		3'b110:   br_sel_tmp = (br_less)? 1'b1 : 1'b0;  //bltu
//		3'b111:   br_sel_tmp = (!br_less | br_equal)? 1'b1 : 1'b0; //bgeu
//		default : br_sel_tmp =  1'b0;
//    endcase
//  end
	 
  always_comb begin
    casex (OP)
	   7'b0000011: begin        //lw
		  mem_wren = 1'b0;
		  rd_wren = 1'b1;
		  op_a_sel = 1'b0;
		  op_b_sel = 1'b1;
		  br_sel = 1'b0;
		  wb_sel = 2'b01;
		  alu_control= 2'b00;
		  ImmSel    = 3'b000;
      end 

      7'b0100011: begin  //sw
		  mem_wren = 1'b1;
		  rd_wren = 1'b0;
		  op_a_sel = 1'b0;
		  op_b_sel = 1'b1;
		  br_sel = 1'b0;
		  wb_sel = 2'bxx;
		  alu_control= 2'b00;
		  ImmSel    = 3'b001;
      end

		7'b0110011: begin  //R-type
		  mem_wren = 1'b0;
		  rd_wren = 1'b1;
		  op_a_sel = 1'b0;
		  op_b_sel = 1'b0;
		  br_sel = 1'b0;
		  wb_sel = 2'b00;
		  alu_control= 2'b10;
		  ImmSel    = 3'bxxx;
      end

      7'b1100011: begin  //branch
		  mem_wren = 1'b0;
		  rd_wren = 1'b0;
		  op_a_sel = 1'b1;
		  op_b_sel = 1'b1;
	//	  br_sel = br_sel_tmp;
		  br_sel = 1'b0;
		  wb_sel = 2'bxx;
		  alu_control= 2'b00; // add
		  ImmSel    = 3'b010;
      end

      7'b0010011: begin  //I-Type
		  mem_wren = 1'b0;
		  rd_wren = 1'b1;
		  op_a_sel = 1'b0;
		  op_b_sel = 1'b1;
		  br_sel = 1'b0;
		  wb_sel = 2'b00;
		  alu_control= 2'b10;
		  ImmSel    = 3'b000;
      end
            
      7'b1101111: begin //j
		  mem_wren = 1'b0;
		  rd_wren = 1'b1;
		  op_a_sel = 1'b1;
		  op_b_sel = 1'b1;
		  br_sel = 1'b1;
		  wb_sel = 2'b11;
		  alu_control= 2'b11;
		  ImmSel    = 3'b011;
	   end
				
      7'b1100111: begin //jalr
		  mem_wren = 1'b0;	
		  rd_wren = 1'b1;
		  op_a_sel = 1'b0;
		  op_b_sel = 1'b1;
		  br_sel = 1'b1;
		  wb_sel = 2'b11;
		  alu_control= 2'b11;
		  ImmSel    = 3'b000;
      end
         
      7'b0110111: begin //LUI
		  mem_wren = 1'b0;
		  rd_wren = 1'b1;
		  op_a_sel = 1'bx;
		  op_b_sel = 1'b1;
		  br_sel = 1'b0;
		  wb_sel = 2'b00;
		  alu_control= 2'b01;
		  ImmSel = 3'b100;
      end
			
      7'b0010111: begin //AUIPC
		  mem_wren = 1'b0;
		  rd_wren = 1'b1;
		  op_a_sel = 1'b1;
		  op_b_sel = 1'b1;
		  br_sel = 1'b0;
		  wb_sel = 2'b00;
		  alu_control= 2'b00;
		  ImmSel = 3'b100;
      end 
                
      default: begin
		  mem_wren = 1'b0;
		  rd_wren = 1'b0;
		  op_a_sel = 1'b0;
		  op_b_sel = 1'b0;
		  br_sel = 1'b0;
		  wb_sel = 2'b00;
		  alu_control= 2'b00;
		  ImmSel    = 3'b000;
		end 
    endcase
  end
	
  logic RtypeSub;
  assign RtypeSub = funct7 & OPb5; // TRUE for R-type subtract
	
  always @ (*) begin
    case(alu_control)
      2'b00: alu_op = 4'b0000; // addition // lw // auipc
		2'b01: alu_op = 4'b1100; // lui
		2'b11: alu_op = 4'b0000; // jal, jalr
	   default: begin
		  case(funct3) // R–type or I–type ALU
		    3'b000: 
			   if (RtypeSub)
				  alu_op = 4'b0001; // sub, done
				else
				  alu_op = 4'b0000; // add, addi , done
	       3'b001: alu_op = 4'b0100; // sll, slli, done
			 3'b010: alu_op = 4'b0101; // slt, slti, done
			 3'b011: alu_op = 4'b1000; // sltu, sltiu
			 3'b100: alu_op = 4'b1010; // xor, xori, done
			 3'b101: 
			   if (~funct7)
				  alu_op = 4'b1011;	// srl, srli , done
				else
				  alu_op = 4'b0111;  // sra, srai done
			 3'b110: alu_op = 4'b0011; // or, ori, done
			 3'b111: alu_op = 4'b0010; // and, andi, done
			 default: alu_op = 4'bxxxx; // ???
			endcase
      end		
    endcase
	end
endmodule