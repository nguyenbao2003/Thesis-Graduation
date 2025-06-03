module APB_Bus (
    // Inputs from APB Master
    input  wire         PCLK,             // APB clock
    input  wire         PRESETn,          // APB active-low reset
    input  wire         PWRITE,           // APB write control signal
    input  wire [1:0]   PSEL,             // APB slave select
    input  wire         TRANSFER,          // APB enable signal
    input  wire [4:0]   PADDR,            // APB address
    input  wire [31:0]  PWDATA,           // APB write data

    // Inputs from Slave
    input  wire         PREADY,           // Slave ready signal
    input  wire [31:0]  PRDATA,           // Data read from the slave

    // Outputs to Slave
    output reg          PWRITE_OUT,       // Write signal to the slave
    output reg          PENABLE_OUT,      // Enable signal to the slave
    output reg [4:0]    PADDR_OUT,        // Address signal to the slave
    output reg [31:0]   PWDATA_OUT,       // Write data to the slave
    output reg          PSEL1,            // Select signal for slave 1
    output reg          PSEL2,            // Select signal for slave 2

    // Outputs to Master
    output reg [31:0]   APB_RDATA,        // Data read from the slave passed to master
    output reg          PSLVERR,          // Slave error signal
    output reg [2:0]    ERROR_TYPE        // Detailed error type
);

// State Definitions
localparam IDLE = 3'b001, SETUP = 3'b010, ENABLE = 3'b100;

// State variables
reg [2:0] current_state, next_state;

// Error Variables
reg invalid_setup_error, setup_error, invalid_read_paddr, invalid_write_paddr, invalid_write_data;

// Sequential Logic: Update State
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// Combinational Logic: State Transitions and Outputs
always @(*) begin
    // Default assignments
    next_state = IDLE;
    PENABLE_OUT = 0; // Default disable
    PWRITE_OUT = PWRITE;

    case (current_state)
        IDLE: begin
            PENABLE_OUT = 0;
            if (TRANSFER) 
                next_state = SETUP;
            else
                next_state = IDLE;
        end

        SETUP: begin
            PENABLE_OUT = 0;
            if (PWRITE) begin
                PADDR_OUT = PADDR;
                PWDATA_OUT = PWDATA;
            end else begin
                PADDR_OUT = PADDR;
            end
            if (TRANSFER && !PSLVERR)
                next_state = ENABLE;
            else
                next_state = IDLE;
        end

        ENABLE: begin
            if (PSEL1 || PSEL2) 
                PENABLE_OUT = 1;
            if (TRANSFER && !PSLVERR) begin
                if (PREADY) begin
                    if (PWRITE)
                        next_state = SETUP;
                    else begin
                        next_state = SETUP;
                        APB_RDATA = PRDATA;
                    end
                end else
                    next_state = ENABLE;
            end else
                next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end

// Slave Selection Logic
always @(*) begin
    PSEL1 = 0;
    PSEL2 = 0;
    case (PSEL)
        2'b01: PSEL1 = 1;
        2'b10: PSEL2 = 1;
        default: begin
            PSEL1 = 0;
            PSEL2 = 0;
        end
    endcase
end

// Error Handling Logic
always @(*) begin
    // Default values
    setup_error = 0;
    invalid_read_paddr = 0;
    invalid_write_paddr = 0;
    invalid_write_data = 0;

    if (current_state == IDLE && next_state == ENABLE) 
        setup_error = 1;

    if ((PWDATA === 32'dx) && (!PWRITE) && (current_state == SETUP || current_state == ENABLE)) 
        invalid_write_data = 1;

    if ((PADDR === 5'dx) && PWRITE && (current_state == SETUP || current_state == ENABLE)) 
        invalid_read_paddr = 1;

    if ((PADDR === 5'dx) && (!PWRITE) && (current_state == SETUP || current_state == ENABLE)) 
        invalid_write_paddr = 1;

    invalid_setup_error = setup_error || invalid_read_paddr || invalid_write_data || invalid_write_paddr;
end

assign PSLVERR = invalid_setup_error;

endmodule