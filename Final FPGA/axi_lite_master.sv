module axi_lite_master(
    input  logic 			aclk,
    input  logic 			areset_n,
    input  logic 			start_read,
    input  logic 			start_write,
    output logic [31:0] debug_rdata, // New port to expose rdata
	 output logic 			arvalid_int, awvalid_int, wvalid_int, rready_int, bready_int,
	 input  logic [31:0] addr, data,
	 input  logic [ 3:0] wstrb,
	 
	 input  logic 			AWREADY, WREADY, ARREADY, RVALID, BVALID,
	 output logic [31:0] ARADDR, AWADDR, s_WDATA,
	 input  logic [31:0] s_rdata,
	 output logic [ 2:0] state
);

    typedef enum logic [2:0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
    state_type next_state;

    logic [31:0] rdata;
    logic start_read_delay, start_write_delay;
	 
	 assign ARADDR = addr;
	 assign AWADDR = addr;
	 assign s_WDATA = data;

	 assign rdata = (state == RDATA)? s_rdata : 32'b0;
    assign debug_rdata = rdata;

    // Register delays for start_read and start_write
    always_ff @(posedge aclk) begin
        if (~areset_n) begin
            start_read_delay <= 0;
            start_write_delay <= 0;
        end else begin
            start_read_delay <= start_read;
            start_write_delay <= start_write;
        end
    end

    // State transition logic
    always_comb begin
        next_state = IDLE;
        arvalid_int = 0;
        awvalid_int = 0;
        wvalid_int = 0;
        rready_int = 0;
        bready_int = 0;

        case (state)
            IDLE: begin
                if (start_read_delay) begin
                    next_state = RADDR;
                    arvalid_int = 1;
                end else if (start_write_delay) begin
                    next_state = WADDR;
                    awvalid_int = 1;
                end
            end

            RADDR: begin
                arvalid_int = 1;
					 if (ARREADY) begin
                    next_state = RDATA;
                end
            end

            RDATA: begin
                rready_int = 1;
					 if (RVALID) begin
                    next_state = IDLE;
                end else begin
					    next_state = RDATA;
					 end
            end

            WADDR: begin
                awvalid_int = 1;
					 if (AWREADY) begin
                    next_state = WDATA;
						  wvalid_int = 1;
                end
            end

            WDATA: begin
                wvalid_int = 1;
					 if (WREADY) begin
                    next_state = WRESP;
                end
            end

            WRESP: begin
                bready_int = 1'b1;
					 if (BVALID) begin
                    next_state = IDLE;
                end else begin
					   next_state = WRESP;
					 end
            end

            default: next_state = IDLE;
        endcase
    end

    // State register
    always_ff @(posedge aclk) begin
        if (~areset_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

endmodule
