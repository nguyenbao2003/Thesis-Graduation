module ErrorCheck(
    input logic        reset_n,       // Active low reset
    input logic        recieved_flag, // Enable from the SIPO unit for the flags
    input logic        parity_bit,    // The parity bit from the frame for comparison
    input logic        start_bit,     // The Start bit from the frame for comparison
    input logic        stop_bit,      // The Stop bit from the frame for comparison
    input logic [1:0]  parity_type,   // Parity type agreed upon by the Tx and Rx units
    input logic [7:0]  raw_data,      // The 8-bit data separated from the data frame

    output logic [2:0] error_flag     // Bus of three bits for error flags
);

    // Internal signals
    logic error_parity;
    logic parity_flag;
    logic start_flag;
    logic stop_flag;

    // Encoding for the 4 types of parity
   localparam [2:0]
        ODD        = 2'b01,
        EVEN       = 2'b10,
        NOPARITY00 = 2'b00,
        NOPARITY11 = 2'b11;

    // Parity Check Logic
    always_comb begin
        case (parity_type)
            NOPARITY00, NOPARITY11: error_parity = 1'b1;
            ODD:                     error_parity = (^raw_data) ? 1'b0 : 1'b1;
            EVEN:                    error_parity = (^raw_data) ? 1'b1 : 1'b0;
            default:                 error_parity = 1'b1;  // No parity
        endcase
    end

    // Flag logic
    always_comb begin
        if (!reset_n) begin
            parity_flag  = 1'b0;
            start_flag   = 1'b0;
            stop_flag    = 1'b0;
        end else if (recieved_flag) begin
            parity_flag = ~(error_parity && parity_bit);
            start_flag  = (start_bit || 1'b0);
            stop_flag   = ~(stop_bit && 1'b1);
        end else begin
            parity_flag  = 1'b0;
            start_flag   = 1'b0;
            stop_flag    = 1'b0;
        end
    end

    // Output logic
    always_comb begin
        error_flag = {stop_flag, start_flag, parity_flag};
    end

endmodule