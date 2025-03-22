module first_reg (
    input  logic         i_clk,
    input  logic         i_rst,
    input  logic         StallD,
    input  logic         FlushD,
    input  logic [31:0]  instr,       // Lệnh từ I$
    input  logic [31:0]  pc,          // Giá trị PC từ Address_Generator
    input  logic [31:0]  pc_four,     // Giá trị PC + 4 từ Address_Generator
    output logic [31:0]  instr_D,      // Lệnh sau giai đoạn Decode
    output logic [31:0]  pc_D,         // PC sau giai đoạn Decode
    output logic [31:0]  pc_four_D     // PC + 4 sau giai đoạn Decode
);
    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            instr_D    <= 32'd0;
            pc_D       <= 32'd0;
            pc_four_D  <= 32'd0;
        end
        else if (StallD) begin
            instr_D    <= instr_D;
            pc_D       <= pc_D;
            pc_four_D  <= pc_four_D;
        end
        else if (FlushD) begin
            instr_D    <= 32'd0;
            pc_D       <= 32'd0;
            pc_four_D  <= 32'd0;
        end
        else begin
            instr_D    <= instr;
            pc_D       <= pc;
            pc_four_D  <= pc_four;
        end
    end
endmodule
