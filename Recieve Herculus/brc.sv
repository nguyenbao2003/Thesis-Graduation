module brc(
  input  logic [31:0]  i_rs1_data,      // First input data (A)
  input  logic [31:0]  i_rs2_data,      // Second input data (B)
  input  logic         i_br_un   ,      // Flag to indicate if comparison is unsigned
  input  logic [31:0]  ImmExtE   ,
  input  logic			  i_slti_sel,
  output logic         o_br_less ,      // Output: true if rs1_data < rs2_data
  output logic         o_br_equal       // Output: true if rs1_data == rs2_data
);

  logic [31:0] eq_bits;             // Bits indicating equality for each bit position
  logic [32:0] sub_result;          // Subtraction result (33 bits to hold carry-out)
  logic [31:0] i_rs2_data_tmp;

  assign i_rs2_data_tmp = (i_slti_sel)? ImmExtE : i_rs2_data;
  
  // Generate equality bits: eq_bits[i] is true if rs1_data[i] == rs2_data[i]
  assign eq_bits = ~(i_rs1_data ^ i_rs2_data_tmp);

  // br_equal is true if all bits are equal (AND reduction of eq_bits)
  assign o_br_equal = &eq_bits;

  // Combinational logic to determine less-than condition
  always_comb begin
    // Perform subtraction using two's complement
    sub_result = {1'b0, i_rs1_data} + {1'b0, ~i_rs2_data_tmp} + 1;

    if (i_br_un) begin
      o_br_less = !sub_result[32]; // For unsigned, check MSB of the subtraction result
    end else begin
      // For signed, check sign bits and fallback to subtraction result
      o_br_less = (i_rs1_data[31] ^ i_rs2_data_tmp[31]) ? i_rs1_data[31] : sub_result[31];
    end
  end

endmodule













