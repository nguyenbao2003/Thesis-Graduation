module Parity(
    input logic        reset_n,     // Active low reset
    input logic [7:0]  data_in,     // The data input from the InReg unit
    input logic [1:0]  parity_type, // Parity type agreed upon by the Tx and Rx units

    output logic       parity_bit   // The parity bit output for the frame
);

    // Encoding for the parity types
	localparam [2:0]
        NOPARITY00 = 2'b00,
        ODD        = 2'b01,
        EVEN       = 2'b10,
        NOPARITY11 = 2'b11;
 

    // Parity logic with asynchronous active low reset
    always_comb begin
        if (!reset_n) begin
            // No parity bit
            parity_bit = 1'b1;
        end else begin
            case (parity_type)
                NOPARITY00, NOPARITY11: parity_bit = 1'b1; // No parity bit
                ODD:                   parity_bit = (^data_in) ? 1'b0 : 1'b1; // Odd parity
                EVEN:                  parity_bit = (^data_in) ? 1'b1 : 1'b0; // Even parity
                default:               parity_bit = 1'b1; // No parity
            endcase
        end
    end

endmodule