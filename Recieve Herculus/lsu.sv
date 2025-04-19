module lsu (
  input  logic           i_clk      ,  // Clock input
  input  logic           i_rst      ,  // Reset signal (active high)
  input  logic [31:0]    i_st_data  ,  // 32-bit input data to be written
  input  logic [31:0]    i_lsu_addr ,  // 32-bit memory address (word-aligned)
  input  logic           i_lsu_wren ,  // Write enable signal
  input  logic [2:0]     funct3     ,
  input	logic	[31:0] 	 i_io_sw    ,  // 32-bit switch inputs
  input	logic	[31:0] 	 i_io_btn   ,  // 32-bit button inputs (optional)
  input  logic [31:0]    RX_DATA    ,
  output logic [31:0]    o_ld_data  ,  // 32-bit output data (read data)
  output logic [6:0] 	 o_io_hex0  ,  // 7-segment LED outputs
  output logic [6:0] 	 o_io_hex1  ,
  output logic [6:0] 	 o_io_hex2  ,
  output logic [6:0] 	 o_io_hex3  ,
  output logic [6:0] 	 o_io_hex4  ,
  output logic [6:0] 	 o_io_hex5  ,
  output logic [6:0] 	 o_io_hex6  ,
  output logic [6:0] 	 o_io_hex7  ,
  output logic [31:0] 	 o_io_ledg  ,  // 32-bit Green LED outputs
  output logic [31:0] 	 o_io_ledr  ,  // 32-bit Red LED outputs
  
  // APB interface
  output logic [ 31:0]    o_axi_addr_reg,
  output logic [31:0]    o_axi_data_reg,
  output logic    		 o_axi_sel_reg,
  output logic [ 3:0]    o_axi_strobe_reg,
  output logic [ 1:0]    o_axi_control_reg
);

  // Declare a 4KB memory (8-bit wide, 4096 bytes)
//logic [7:0] 	Data_Mem [255:0];  // Simulating SDRAM with some delay for demo
  logic [ 7:0] reg_7_segment [7:0];
  logic [31:0] sram_ld_data;
  logic [31:0] sram_st_data;
  logic [1:0]  byte_offset;
  
	 
  localparam [31:0] RED_LED_START    = 32'h7000, RED_LED_END   = 32'h700F;
  localparam [31:0] GREEN_LED_START  = 32'h7010, GREEN_LED_END = 32'h701F;
  localparam [31:0] SEVEN_SEG_START  = 32'h7020   , SEVEN_SEG_END = 32'h7027;
  localparam [31:0] LCD_CTRL_START   = 32'h7030, LCD_CTRL_END  = 32'h703F;
  localparam [31:0] SWITCH_START     = 32'h7800, SWITCH_END    = 32'h780F;
  localparam [31:0] BUTTON_START     = 32'h7810, BUTTON_END    = 32'h781F;
  
  // Interface with APB
  localparam [31:0] AXI_ADDR     = 32'h7900; // 5-bit ADDR
  localparam [31:0] AXI_DATA     = 32'h7904; // 32-bit WDATA
  localparam [31:0] AXI_SEL     = 32'h7908;   // 2-bit select slave
  localparam [31:0] AXI_STROBE     = 32'h790C;   // 4-bit strobe
  localparam [31:0] AXI_CONTROL     = 32'h7910; // [0]: start_write; [1]: start_read
  
  localparam [31:0] ADDRESS_RX = 32'h7914; // address to read recieved data
  
  // SDRAM memory range: 0x2000 -> 0x3FFF
  localparam [31:0] SDRAM_START      = 32'h2000, SDRAM_END     = 32'h3FFF;

  // Type load and store
  localparam F3_B   = 3'b000;  // LB/SB
  localparam F3_H   = 3'b001;  // LH/SH
  localparam F3_W   = 3'b010;  // LW/SW
  localparam F3_BU  = 3'b100;  // LBU
  localparam F3_HU  = 3'b101;  // LHU

  assign byte_offset = i_lsu_addr[1:0];
	
	 
	 //================================= SRAM ==========================================
	 
  logic [31:0] mem [255:0];
  logic [12:0] i_addr;

  assign i_addr  = {i_lsu_addr[12:2],2'b0};
//assign sram_ld_data = mem[i_addr];

  always_ff @(negedge i_clk) begin
    sram_ld_data <= mem[i_addr];
  end
	 
  always_ff @(posedge i_clk) begin
    if (i_lsu_wren)
      mem[i_addr] <= sram_st_data;
  end
	 
	 // ========================================================
  logic [31:0] ld_data;
  always_comb begin 
    case(i_lsu_addr[1:0]) 
      2'b00: ld_data = sram_ld_data;
      2'b01: ld_data = {8'b0, sram_ld_data[31:8]};
      2'b10: ld_data = {16'b0, sram_ld_data[31:16]};
      2'b11: ld_data = {24'b0, sram_ld_data[31:24]};
    endcase
  end
	 
  //============== Load ====================== 
  always_comb begin
    o_ld_data = 32'b0;
      if (!i_lsu_wren) begin
		  if (i_lsu_addr >= SDRAM_START && i_lsu_addr <= SDRAM_END) begin
		    o_ld_data = ld_data;
			 case (funct3)
			   F3_W: begin // LW
				o_ld_data = ld_data;
			 end
				
			 F3_H: begin // LH
				if (byte_offset != 2'b11)
				  o_ld_data = {{16{ld_data[15]}},ld_data[15:0]};
				else
				  o_ld_data = 32'b0; // Unaligned access
			 end
				
			 F3_B: begin // LB
			   o_ld_data = {{24{ld_data[7]}},ld_data[7:0]};
			 end
				
			 F3_BU: begin // LBU
			   o_ld_data = {24'b0,ld_data[7:0]};
			 end
				
			 F3_HU: begin // LHU
			   if (byte_offset != 2'b11)
				  o_ld_data = {16'b0,ld_data[15:0]};
				else
				  o_ld_data = 32'b0; // Unaligned access
			 end
				
			 default : o_ld_data = 32'b0;  
		  endcase	
		  end else if (i_lsu_addr >= RED_LED_START && i_lsu_addr <= RED_LED_END) begin
				o_ld_data = {15'b0, o_io_ledr[16:0]};
			end else if (i_lsu_addr >= GREEN_LED_START && i_lsu_addr <= GREEN_LED_END) begin
				o_ld_data = {24'b0, o_io_ledg[7:0]};
			end else if (i_lsu_addr >= 32'h7020 && i_lsu_addr <= 32'h7023) begin
				case (funct3)
					F3_W: begin // LW
						case (byte_offset)
							2'b00:
								o_ld_data = {reg_7_segment[3], reg_7_segment[2], reg_7_segment[1], reg_7_segment[0]};
							2'b01: 
								o_ld_data = {8'b0,reg_7_segment[3], reg_7_segment[2], reg_7_segment[1]};
							2'b10:
								o_ld_data = {16'b0,reg_7_segment[3], reg_7_segment[2]};
							2'b11:
								o_ld_data = {24'b0,reg_7_segment[3]};
						endcase		
					end
					
					F3_H: begin // LH
						case (byte_offset)
							2'b00:
								o_ld_data = {{16{reg_7_segment[1][7]}}, reg_7_segment[1], reg_7_segment[0]};
							2'b01: 
								o_ld_data = {{16{reg_7_segment[2][7]}}, reg_7_segment[2], reg_7_segment[1]};
							2'b10:
								o_ld_data = {{16{reg_7_segment[3][7]}},reg_7_segment[3], reg_7_segment[2]};
							2'b11:
								o_ld_data = 32'b0; // unligned acces
						endcase	
					end
					
					F3_B: begin // LB
						case (byte_offset)
							2'b00:
								o_ld_data = {{24{reg_7_segment[0][7]}}, reg_7_segment[0]};
							2'b01: 
								o_ld_data = {{24{reg_7_segment[1][7]}}, reg_7_segment[1]};
							2'b10:
								o_ld_data = {{24{reg_7_segment[2][7]}}, reg_7_segment[2]};
							2'b11:
								o_ld_data = {{24{reg_7_segment[3][7]}},reg_7_segment[3]};
						endcase
					end
					
					F3_BU: begin // LBU
							case (byte_offset)
							2'b00:
								o_ld_data = {24'b0, reg_7_segment[0]};
							2'b01: 
								o_ld_data = {24'b0, reg_7_segment[1]};
							2'b10:
								o_ld_data = {24'b0, reg_7_segment[2]};
							2'b11:
								o_ld_data = {24'b0,reg_7_segment[3]};
						endcase
					end
					
					F3_HU: begin // LHU
						case (byte_offset)
							2'b00:
								o_ld_data = {16'b0, reg_7_segment[1], reg_7_segment[0]};
							2'b01: 
								o_ld_data = {16'b0, reg_7_segment[2], reg_7_segment[1]};
							2'b10:
								o_ld_data = {16'b0,reg_7_segment[3], reg_7_segment[2]};
							2'b11:
								o_ld_data = 32'b0; // unligned acces
						endcase	
					end
					
					default : o_ld_data = 32'b0;  
				endcase
				
			end else if (i_lsu_addr >= 32'h7024 && i_lsu_addr <= 32'h7027) begin
				case (funct3)
					F3_W: begin // LW
						case (byte_offset)
							2'b00:
								o_ld_data = {reg_7_segment[7], reg_7_segment[6], reg_7_segment[5], reg_7_segment[4]};
							2'b01: 
								o_ld_data = {8'b0,reg_7_segment[7], reg_7_segment[6], reg_7_segment[5]};
							2'b10:
								o_ld_data = {16'b0,reg_7_segment[7], reg_7_segment[6]};
							2'b11:
								o_ld_data = {24'b0,reg_7_segment[7]};
						endcase		
					end
					
					F3_H: begin // LH
						case (byte_offset)
							2'b00:
								o_ld_data = {{16{reg_7_segment[5][7]}}, reg_7_segment[5], reg_7_segment[4]};
							2'b01: 
								o_ld_data = {{16{reg_7_segment[6][7]}}, reg_7_segment[6], reg_7_segment[5]};
							2'b10:
								o_ld_data = {{16{reg_7_segment[7][7]}},reg_7_segment[7], reg_7_segment[6]};
							2'b11:
								o_ld_data = 32'b0; // unligned acces
						endcase	
					end
					
					F3_B: begin // LB
						case (byte_offset)
							2'b00:
								o_ld_data = {{24{reg_7_segment[4][7]}}, reg_7_segment[4]};
							2'b01: 
								o_ld_data = {{24{reg_7_segment[5][7]}}, reg_7_segment[5]};
							2'b10:
								o_ld_data = {{24{reg_7_segment[6][7]}}, reg_7_segment[6]};
							2'b11:
								o_ld_data = {{24{reg_7_segment[7][7]}},reg_7_segment[7]};
						endcase
					end
					
					F3_BU: begin // LBU
							case (byte_offset)
							2'b00:
								o_ld_data = {24'b0, reg_7_segment[4]};
							2'b01: 
								o_ld_data = {24'b0, reg_7_segment[5]};
							2'b10:
								o_ld_data = {24'b0, reg_7_segment[6]};
							2'b11:
								o_ld_data = {24'b0,reg_7_segment[7]};
						endcase
					end
					
					F3_HU: begin // LHU
						case (byte_offset)
							2'b00:
								o_ld_data = {16'b0, reg_7_segment[5], reg_7_segment[4]};
							2'b01: 
								o_ld_data = {16'b0, reg_7_segment[6], reg_7_segment[5]};
							2'b10:
								o_ld_data = {16'b0,reg_7_segment[7], reg_7_segment[6]};
							2'b11:
								o_ld_data = 32'b0; // unligned acces
						endcase	
					end
					
					default : o_ld_data = 32'b0;  
				endcase
			end else if (i_lsu_addr >= SWITCH_START && i_lsu_addr <= SWITCH_END) begin
				o_ld_data <= {14'b0, i_io_sw[17:0]};
			end else if (i_lsu_addr >= BUTTON_START && i_lsu_addr <= BUTTON_END) begin
				o_ld_data <= {22'b0, i_io_btn[9:0]};
			end else if (i_lsu_addr == ADDRESS_RX) begin // RX_DATA
				o_ld_data <= RX_DATA;
			end else begin
				o_ld_data = 32'b0;
			end
		end
	 end
	 
	 //========================= Store =====================
	 
	 always_comb begin
		sram_st_data = sram_ld_data;
		if (i_lsu_addr >= SDRAM_START && i_lsu_addr <= SDRAM_END) begin
			case (byte_offset)
				2'b00: begin
					case (funct3)
						F3_W: begin // SW
							sram_st_data = i_st_data;
						end
						
						F3_H: begin // SH
							sram_st_data [15:0] = i_st_data [15:0];
						end
						
						F3_B: begin // SB
							sram_st_data [7:0] = i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
				
				2'b01: begin
					case (funct3)
						F3_W: begin // SW
							sram_st_data [31:8] = i_st_data [23:0];
						end
						
						F3_H: begin // SH
							sram_st_data [23:8] = i_st_data [15:0];
						end
						
						F3_B: begin // SB
							sram_st_data [15:8] = i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
				
				2'b10: begin
					case (funct3)
						F3_W: begin // SW
							sram_st_data [31:16] = i_st_data [15:0];
						end
						
						F3_H: begin // SH
							sram_st_data [31:16] = i_st_data [15:0];
						end
						
						F3_B: begin // SB
							sram_st_data [23:16] = i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
				
				2'b11: begin
					case (funct3)
						F3_W: begin // SW
							sram_st_data [31:24] = i_st_data [7:0];
						end
						
						F3_H: begin // SH
							sram_st_data [31:24] = i_st_data [7:0];
						end
						
						F3_B: begin // SB
							sram_st_data [31:24] = i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
			endcase
		end
	 end
		
		 
	 always_ff @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            reg_7_segment[0] <= 8'h0;
				reg_7_segment[1] <= 8'h0;
				reg_7_segment[2] <= 8'h0;
				reg_7_segment[3] <= 8'h0;
				reg_7_segment[4] <= 8'h0;
				reg_7_segment[5] <= 8'h0;
				reg_7_segment[6] <= 8'h0;
				reg_7_segment[7] <= 8'h0;
				o_axi_addr_reg <= 5'b0;
				o_axi_data_reg <= 32'b0;
				o_axi_sel_reg <= 2'b0;
				o_axi_strobe_reg <= 4'b0;
				o_axi_control_reg <= 2'b0;
            o_io_ledg <= 32'b0;
            o_io_ledr <= 32'b0;
		 end else if(i_lsu_wren) begin
			if (i_lsu_addr >= RED_LED_START && i_lsu_addr <= RED_LED_END) begin
				o_io_ledr <= i_st_data[16:0];
			end else if (i_lsu_addr >= GREEN_LED_START && i_lsu_addr <= GREEN_LED_END) begin
				o_io_ledg <= i_st_data[7:0];
			end else if (i_lsu_addr >= 32'h7020 && i_lsu_addr <= 32'h7023) begin
				case (byte_offset)
				2'b00: begin
					case (funct3)
						F3_W: begin // SW
							reg_7_segment[0] <= i_st_data [7:0];
							reg_7_segment[1] <= i_st_data [15:8];
							reg_7_segment[2] <= i_st_data [23:16];
							reg_7_segment[3] <= i_st_data [31:24];
						end
						
						F3_H: begin // SH
							reg_7_segment[0] <= i_st_data [7:0];
							reg_7_segment[1] <= i_st_data [15:8];
						end
						
						F3_B: begin // SB
							reg_7_segment[0] <= i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
				
				2'b01: begin
					case (funct3)
						F3_W: begin // SW
							reg_7_segment[1] <= i_st_data [7:0];
							reg_7_segment[2] <= i_st_data [15:8];
							reg_7_segment[3] <= i_st_data [23:16];
						end
						
						F3_H: begin // SH
							reg_7_segment[1] <= i_st_data [7:0];
							reg_7_segment[2] <= i_st_data [15:8];
						end
						
						F3_B: begin // SB
							reg_7_segment[1] <= i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
				
				2'b10: begin
					case (funct3)
						F3_W: begin // SW
							reg_7_segment[2] <= i_st_data [7:0];
							reg_7_segment[3] <= i_st_data [15:8];
						end
						
						F3_H: begin // SH
							reg_7_segment[2] <= i_st_data [7:0];
							reg_7_segment[3] <= i_st_data [15:8];
						end
						
						F3_B: begin // SB
							reg_7_segment[2] <= i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
				
				2'b11: begin
					case (funct3)
						F3_W: begin // SW
							reg_7_segment[3] <= i_st_data [7:0];
						end
						
						F3_H: begin // SH
							// do nothing
						end
						
						F3_B: begin // SB
							reg_7_segment[3] <= i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
			endcase	
			end else if (i_lsu_addr >= 32'h7023 && i_lsu_addr <= 32'h7027) begin
				case (byte_offset)
				2'b00: begin
					case (funct3)
						F3_W: begin // SW
							reg_7_segment[4] <= i_st_data [7:0];
							reg_7_segment[5] <= i_st_data [15:8];
							reg_7_segment[6] <= i_st_data [23:16];
							reg_7_segment[7] <= i_st_data [31:24];
						end
						
						F3_H: begin // SH
							reg_7_segment[4] <= i_st_data [7:0];
							reg_7_segment[5] <= i_st_data [15:8];
						end
						
						F3_B: begin // SB
							reg_7_segment[4] <= i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
				
				2'b01: begin
					case (funct3)
						F3_W: begin // SW
							reg_7_segment[5] <= i_st_data [7:0];
							reg_7_segment[6] <= i_st_data [15:8];
							reg_7_segment[7] <= i_st_data [23:16];
						end
						
						F3_H: begin // SH
							reg_7_segment[5] <= i_st_data [7:0];
							reg_7_segment[6] <= i_st_data [15:8];
						end
						
						F3_B: begin // SB
							reg_7_segment[5] <= i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
				
				2'b10: begin
					case (funct3)
						F3_W: begin // SW
							reg_7_segment[6] <= i_st_data [7:0];
							reg_7_segment[7] <= i_st_data [15:8];
						end
						
						F3_H: begin // SH
							reg_7_segment[6] <= i_st_data [7:0];
							reg_7_segment[7] <= i_st_data [15:8];
						end
						
						F3_B: begin // SB
							reg_7_segment[6] <= i_st_data [7:0];
						end
						
						default: ;// do nothing
					endcase
				end
				
				2'b11: begin
					case (funct3)
						F3_W: begin // SW
							reg_7_segment[7] <= i_st_data [7:0];
						end
						
						F3_H: begin // SH
							// do nothing
						end
						
						F3_B: begin // SB
							reg_7_segment[7] <= i_st_data [7:0];
						end
				
						default: ;// do nothing
					endcase
				end
			   endcase
			end else if (i_lsu_addr == AXI_ADDR) begin
			  o_axi_addr_reg <= i_st_data;
			end else if (i_lsu_addr == AXI_DATA) begin
			  o_axi_data_reg <= i_st_data;
			end else if (i_lsu_addr == AXI_SEL) begin
			  o_axi_sel_reg <= i_st_data[0];
			end else if (i_lsu_addr == AXI_STROBE) begin
			  o_axi_strobe_reg <= i_st_data[3:0];  
			end else if (i_lsu_addr == AXI_CONTROL) begin
			  o_axi_control_reg <= i_st_data[1:0];
			end
		 end
	end

	 
	 // Continuous assignment for 7-segment displays
    always_comb begin
        o_io_hex0 = reg_7_segment[0][6:0];
        o_io_hex1 = reg_7_segment[1][6:0];
        o_io_hex2 = reg_7_segment[2][6:0];
        o_io_hex3 = reg_7_segment[3][6:0];
        o_io_hex4 = reg_7_segment[4][6:0];
        o_io_hex5 = reg_7_segment[5][6:0];
        o_io_hex6 = reg_7_segment[6][6:0];
        o_io_hex7 = reg_7_segment[7][6:0];
    end
endmodule

