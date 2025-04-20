module main(
	input  logic         i_clk,
	input  logic         i_rst,
	input  logic [9:0]  i_io_sw,
	input  logic [31:0]  i_io_btn,
	input  logic [31:0]  RX_DATA,

   output logic [31:0]	o_pc_debug,
	output logic 			o_insn_vld,
	output logic [10:0] cnt,
	output logic [10:0] cnt_instr,

	output logic [31:0] 	o_io_ledg,
	output logic [31:0]	o_io_ledr,
	output logic [ 6:0]	o_io_hex0,
	output logic [ 6:0]	o_io_hex1,
	output logic [ 6:0]	o_io_hex2,
	output logic [ 6:0]	o_io_hex3,
	output logic [ 6:0]	o_io_hex4,
	output logic [ 6:0]	o_io_hex5,
	output logic [ 6:0]	o_io_hex6,
	output logic [ 6:0]	o_io_hex7,
	output logic [ 3:0]  alu_op_E,
	output logic         br_sel_final, br_unsigned_E, br_less,
	output logic [ 4:0]  rd_addr_W,
	output logic [ 1:0]  forward_A_E,
	output logic [ 1:0]  forward_B_E,
	output logic [31:0]  instr,
	output logic [31:0]  pc,
	output logic         prediction, mispredict, is_jump, flush_E, flush_D,  // From Branch Prediction
	output logic [31:0]  PCTargetF, // From Branch Prediction
	output logic         stall_F,
	output logic [ 1:0]  wb_sel_E, wb_sel,
	output logic [ 4:0]  rs1_addr_E, rs2_addr_E,
	output logic [31:0]  alu_data_E,
//	output logic [31:0]  checkx1,  
//   output logic [31:0]  checkx2,
   output logic [31:0]  checkx3,
//   output logic [31:0]  checkx4,
//   output logic [31:0]  checkx5,
	output logic [31:0] o_axi_addr_reg,
	output logic [31:0] o_axi_data_reg,
	output logic  o_axi_sel_reg,
	output logic [3:0] o_axi_strobe_reg,
	output logic [1:0] o_axi_control_reg,
	output logic [31:0] read_data_M // load data from lsu
);

	logic [31:0]  checkx1;  
   logic [31:0]  checkx2;
//   logic [31:0]  checkx3; 
   logic [31:0]  checkx4;
   logic [31:0]  checkx5;  
	logic [31:0]  src_A_E, operand_a, rs1_data, rs2_data;
	logic [31:0]  write_data_E, operand_b;
	logic [31:0] pc_four, instr_D, pc_D, pc_four_D,instr_debug;

    // Internal signals for pipeline registers and inter-module connections
    
//	 logic [31:0]  write_data_E, operand_b;
    logic [31:0] rs1_data_E , rs2_data_E, ImmExtD, ImmExtE, alu_data_W;
    logic [31:0] alu_data_M, pc_E, pc_M, pc_four_E, pc_four_M, pc_four_W;
    logic [31:0] wb_data, wb_data_W, ld_data_E, ld_data_M,read_data_W;
    logic [4:0]  rs1_addr, rs2_addr, rd_addr, rd_addr_E, rd_addr_M;
    logic [6:0]  OP, OP_E, funct77;
    logic [2:0]  funct3, ImmSel, funct3_E, funct3_M;
    logic [24:0] imm;
    logic        funct7, OPb5, br_equal, mem_wren, rd_wren;
    logic        op_a_sel, op_a_selD, op_a_selE, op_b_selE, op_b_selD, br_sel, br_sel_E, br_unsigned, slti_sel,slti_sel_E, insn_vld;
    logic [3:0]  alu_op;
    logic [1:0]   wb_sel_M, wb_sel_W;
    logic        mem_wren_E, mem_wren_M, rd_wren_E, rd_wren_M, rd_wren_W;
    logic        stall_D;
	 logic        is_branch; // for branch prediction
   
	 
    // Instruction Fetch (IF) Stage
    
	 branch_prediction br_predict(
	   .i_clk           (i_clk       ),
		.i_rst           (i_rst       ),
		.i_PC_F          (pc          ),
		.o_PCTarget_F    (PCTargetF   ),
		.i_index_D       (pc_D[3:2]   ),
		.i_PC_D          (pc_D        ),
		.i_instr_D       (instr_D     ),
		.i_index_E       (pc_E[3:2]   ),
      .i_tag_E         (pc_E[31:4]  ),		
		.i_PCTarget_E    (alu_data_E  ), // from alu
		.i_branch_E      (is_branch   ),   // from alu
		.i_branch_taken_E(br_sel_final), // from alu
		.i_jump_E        (is_jump     ),       // from alu
		.o_prediction 	  (prediction  ),
		.i_pc_four_E     (pc_four_E   ),
		.o_mispredict    (mispredict  )
	 );
	 
	 
	 Address_Generator addr_gen (
        .i_rst(i_rst),
        .i_clk(i_clk),
        .br_sel(prediction),    // Branch selection from Branch Prediction
        .pc_four(pc_four),
        .pc_bru(PCTargetF),     // From Branch Prediction
		  .StallF(stall_F),
        .pc(pc)
    );

    PCPlus4 pc_plus4 (
        .pc(pc),
        .pc_four(pc_four)
    );

    I$ instruction_memory (
        .pc(pc),
        .instr(instr),
		  .instr_debug(instr_debug)
    );

    first_reg first_reg1 (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .StallD(stall_D),    // Stall signal from hazard unit
        .FlushD(flush_D),    // Flush signal from hazard unit
        .instr(instr),
        .pc(pc),
        .pc_four(pc_four),
        .instr_D(instr_D),
        .pc_D(pc_D),
        .pc_four_D(pc_four_D)
    );

    // Instruction Decode (ID) Stage
    decoder dec (
        .instr_D(instr_D),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .OP(OP),
        .funct3(funct3),
        .funct7(funct7),
        .OPb5(OPb5),
        .imm(imm),
        .funct77(funct77)
    );

    ImmGen imm_gen (
        .imm(imm),
        .ImmSel(ImmSel),
        .ImmExtD(ImmExtD)
    );

    regfile rf (
        .i_rs1_addr(rs1_addr),
        .i_rs2_addr(rs2_addr),
        .i_rd_addr(rd_addr_W),
        .i_rd_data(wb_data),
        .i_clk(i_clk),
        .i_rd_wren(rd_wren_W),
        .i_rst(i_rst),
        .o_rs1_data(rs1_data),
        .o_rs2_data(rs2_data),
		  .checkx1(checkx1),
		  .checkx2(checkx2),
		  .checkx3(checkx3),
		  .checkx4(checkx4),
		  .checkx5(checkx5)
    );

    Controller ctrl (
        .instr_D(instr_D),
        .OP(OP),
        .funct77(funct77),
        .funct3(funct3),
        .funct7(funct7),
        .OPb5(OPb5),
//        .br_less(br_less),
//        .br_equal(br_equal),
        .mem_wren(mem_wren),
        .rd_wren(rd_wren),
        .op_a_sel(op_a_selD),
        .op_b_sel(op_b_selD),
        .br_sel(br_sel),
        .br_unsigned(br_unsigned),
        .slti_sel(slti_sel),
        .insn_vld(insn_vld),
        .alu_op(alu_op),
        .wb_sel(wb_sel),
        .ImmSel(ImmSel),
		  .i_clk(i_clk),
		  .i_rst (i_rst),
		  .cnt(cnt),
		  .cnt_instr (cnt_instr)
    );
	 
    // ID to EX Pipeline Register
    second_reg second_reg2 (
        .i_clk(i_clk),
        .i_rst(i_rst),
		  .OP_D (OP),
        .pc_D(pc_D),
        .pc_four_D(pc_four_D),
        .ImmExtD(ImmExtD),
        .rs1_data_D(rs1_data),
        .rs2_data_D(rs2_data),
        .rd_addr_D(rd_addr),
        .rs1_addr_D(rs1_addr),
        .rs2_addr_D(rs2_addr),
        .funct3_D(funct3),
        .alu_op_D(alu_op),
        .wb_sel_D(wb_sel),
        .mem_wren_D(mem_wren),
        .rd_wren_D(rd_wren),
		  .br_sel(br_sel),
        .br_unsigned_D(br_unsigned),
        .op_a_sel_D(op_a_selD),
        .op_b_sel_D(op_b_selD),
        .slti_sel_D(slti_sel),
        .FlushE(flush_E),
        .pc_E(pc_E),
        .pc_four_E(pc_four_E),
        .ImmExtE(ImmExtE),
        .rs1_data_E(rs1_data_E),
        .rs2_data_E(rs2_data_E),
        .rd_addr_E(rd_addr_E),
        .rs1_addr_E(rs1_addr_E),
        .rs2_addr_E(rs2_addr_E),
        .funct3_E(funct3_E),
        .alu_op_E(alu_op_E),
        .wb_sel_E(wb_sel_E),
        .mem_wren_E(mem_wren_E),
        .rd_wren_E(rd_wren_E),
        .br_unsigned_E(br_unsigned_E),
		  .br_sel_E(br_sel_E),
		  .OP_E (OP_E),
        .op_a_sel_E(op_a_selE),
        .op_b_sel_E(op_b_selE),
        .slti_sel_E(slti_sel_E)
    );

    // Execute (EX) Stage
    mux5 mux_a (
        .rs1_data_E(rs1_data_E),
        .wb_data_W(wb_data),
        .alu_data_M(alu_data_M),
        .forward_A_E(forward_A_E),
        .src_A_E(src_A_E)
    );

    mux4 mux_b (
        .rs2_data_E(rs2_data_E),
        .wb_data_W(wb_data),
        .alu_data_M(alu_data_M),
        .forward_B_E(forward_B_E),
        .write_data_E(write_data_E)
    );

    brc branch_comp (
        .i_rs1_data(src_A_E),
        .i_rs2_data(write_data_E),
        .i_br_un(br_unsigned_E),
        .ImmExtE(ImmExtE),
        .i_slti_sel(slti_sel_E),
        .o_br_less(br_less),
        .o_br_equal(br_equal)
    );

    alu alu_unit (
        .i_operand_a(src_A_E),
        .i_operand_b(write_data_E),
        .op_a_sel(op_a_selE),
        .op_b_sel(op_b_selE),
        .pc(pc_E),
        .ImmExtE(ImmExtE),
        .i_alu_op(alu_op_E),
        .br_less(br_less),
		  .br_equal (br_equal),
		  .br_sel (br_sel_E),
		  .OP (OP_E),
		  .funct3 (funct3_E),
		  //checker
		  .operand_a (operand_a),
		  .operand_b (operand_b),
        .o_br_sel_final (br_sel_final),
		  .is_branch (is_branch),  // for branch prediction
		  .is_jump (is_jump),      // for branch prediction
		  .o_alu_data(alu_data_E)
    );

    hazard hazard_unit (
		  .i_rst(i_rst),
        .rs1_addr_E(rs1_addr_E),
        .rs2_addr_E(rs2_addr_E),
        .rd_addr_M(rd_addr_M),
        .rd_addr_W(rd_addr_W),
        .rs1_addr_D(rs1_addr),
        .rs2_addr_D(rs2_addr),
        .rd_addr_E(rd_addr_E),
        .wb_sel_E(wb_sel_E),
        .rd_wren_M(rd_wren_M),
        .rd_wren_W(rd_wren_W),
        .br_sel(br_sel_final),
		  .mispredict(mispredict), // From Branch Prediction
        .StallF(stall_F),
        .StallD(stall_D),
        .FlushE(flush_E),
        .FlushD(flush_D),
        .forward_A_E(forward_A_E),
        .forward_B_E(forward_B_E)
    );
// EX to MEM Pipeline Register
    third_reg third_reg1 (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .alu_data_E(alu_data_E),
		  .rd_addr_E(rd_addr_E),
        .pc_four_E(pc_four_E),
        .funct3_E(funct3_E),
        .mem_wren_E(mem_wren_E),
        .wb_sel_E(wb_sel_E),
        .rd_wren_E(rd_wren_E),
        .rd_addr_M(rd_addr_M),
        .alu_data_M(alu_data_M),
        .pc_four_M(pc_four_M),
        .funct3_M(funct3_M),
		  .ld_data_E(write_data_E),
		  .ld_data_M(ld_data_M),
        .mem_wren_M(mem_wren_M),
        .wb_sel_M(wb_sel_M),
        .rd_wren_M(rd_wren_M)
    );

    // Memory Access (MEM) Stage
    lsu load_store_unit (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_st_data(ld_data_M),  // Data to store from Execute stage
        .i_lsu_addr(alu_data_M),   // Address from ALU result
        .i_lsu_wren(mem_wren_M),   // Write enable from MEM stage
        .funct3(funct3_M),         // funct3 field for memory operation
        .i_io_sw(i_io_sw),           // Placeholder for switch inputs
        .i_io_btn(i_io_btn),          // Placeholder for button inputs
		  .RX_DATA(RX_DATA),  // Recieved Data
        .o_ld_data(read_data_M),   // Data loaded from memory
        .o_io_hex0(o_io_hex0), 
		  .o_io_hex1(o_io_hex1), 
		  .o_io_hex2(o_io_hex2), 
		  .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4), 
		  .o_io_hex5(o_io_hex5), 
		  .o_io_hex6(o_io_hex6), 
		  .o_io_hex7(o_io_hex7),
        .o_io_ledg(o_io_ledg), 
		  .o_io_ledr(o_io_ledr),
		  .o_axi_addr_reg(o_axi_addr_reg),
		  .o_axi_data_reg(o_axi_data_reg ),
		  .o_axi_sel_reg(o_axi_sel_reg),
		  .o_axi_strobe_reg(o_axi_strobe_reg),
		  .o_axi_control_reg(o_axi_control_reg)
//		  .o_io_lcd()
    );

    // MEM to WB Pipeline Register
	fourth_reg fourth_reg1 (
        .alu_data_M(alu_data_M),
        .read_data_M(read_data_M),
        .pc_four_M(pc_four_M),
        .rd_addr_M(rd_addr_M),
        .i_rst(i_rst),
        .i_clk(i_clk),
        .wb_sel_M(wb_sel_M),
        .rd_wren_M(rd_wren_M),
        .alu_data_W(alu_data_W),
        .read_data_W(read_data_W),
        .pc_four_W(pc_four_W),
        .rd_addr_W(rd_addr_W),
        .wb_sel_W(wb_sel_W),
        .rd_wren_W(rd_wren_W)
    );
	 
	  mux_1 wb_mux (
        .pc_four(pc_four_W),          // PC + 4 from MEM-to-WB register
        .alu_data(alu_data_W),        // ALU result from MEM-to-WB register
        .ld_data_2(read_data_W),      // Data loaded from memory
        .wb_sel(wb_sel_W),            // Write-back selection
        .wb_data(wb_data)             // Final data to write back to register file
    );
	 
	pc_inst_debug u11(
		.i_clk (i_clk),
		.i_rst (i_rst),
		.insn_vld (insn_vld),
		.pc (pc),
		.o_insn_vld (o_insn_vld),
		.o_pc_debug (o_pc_debug)
	);
	
endmodule

