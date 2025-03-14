import axi_lite_pkg::*;

module axi_lite_slave (
    input logic aclk,
    input logic areset_n,
    axi_lite_if.slave s_axi_lite,
    output logic [31:0] debug_buffer, // Add this port for debugging
	 output logic arready_int, awready_int, rvalid_int, wready_int, bvalid_int
);

    typedef enum logic [2:0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
    state_type state, next_state;

    addr_t addr;
    logic [31:0] buffer[0:255];

    // Internal control signals
//    logic arready_int, awready_int, rvalid_int, wready_int, bvalid_int;
    logic [31:0] rdata_int;

    // Connect internal signals to AXI-Lite interface
    assign s_axi_lite.arready = arready_int;
    assign s_axi_lite.awready = awready_int;
    assign s_axi_lite.rvalid = rvalid_int;
    assign s_axi_lite.wready = wready_int;
    assign s_axi_lite.bvalid = bvalid_int;

    assign s_axi_lite.rdata = rdata_int;
    assign s_axi_lite.rresp = RESP_OKAY;
    assign s_axi_lite.bresp = RESP_OKAY;

    // Address latch logic
    always_ff @(posedge aclk) begin
        if (~areset_n) begin
            addr <= 0;
        end else if (state == RADDR) begin
            addr <= s_axi_lite.araddr;
        end else if (state == WADDR) begin
            addr <= s_axi_lite.awaddr;
        end
    end

    // Buffer write logic
    always_ff @(posedge aclk) begin
        if (~areset_n) begin
            for (int i = 0; i < 32; i++) begin
                buffer[i] <= 32'h0;
            end
        end else if (state == WDATA) begin
            if (s_axi_lite.wstrb[0]) buffer[addr][7:0]   <= s_axi_lite.wdata[7:0];
            if (s_axi_lite.wstrb[1]) buffer[addr][15:8]  <= s_axi_lite.wdata[15:8];
            if (s_axi_lite.wstrb[2]) buffer[addr][23:16] <= s_axi_lite.wdata[23:16];
            if (s_axi_lite.wstrb[3]) buffer[addr][31:24] <= s_axi_lite.wdata[31:24];
        end
    end

    // State machine for AXI-Lite protocol
    always_comb begin
        next_state = IDLE;

        // Default signal values
        arready_int = 0;
        awready_int = 0;
        rvalid_int = 0;
        wready_int = 0;
        bvalid_int = 0;
        rdata_int = 0;

        case (state)
            IDLE: begin
                if (s_axi_lite.arvalid) begin
                    next_state = RADDR;
                //    arready_int = 1;
                end else if (s_axi_lite.awvalid) begin
                    next_state = WADDR;
                //    awready_int = 1;
                end
            end

            
				RADDR: begin
                arready_int = 1;
                if (s_axi_lite.arvalid && s_axi_lite.arready) begin
                    next_state = RDATA;
                end
            end

            RDATA: begin
                rvalid_int = 1;
                rdata_int = buffer[addr];
                if (s_axi_lite.rvalid && s_axi_lite.rready) begin
                    next_state = IDLE;
                end
            end

            WADDR: begin
                awready_int = 1;
                if (s_axi_lite.awvalid && s_axi_lite.awready) begin
                    next_state = WDATA;
                end
            end

            WDATA: begin
                wready_int = 1;
                if (s_axi_lite.wvalid && s_axi_lite.wready) begin
                    next_state = WRESP;
                end
            end

            WRESP: begin
                bvalid_int = 1;
                if (s_axi_lite.bvalid && s_axi_lite.bready) begin
                    next_state = IDLE;
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

    // Connect the internal buffer to the debug output port
    assign debug_buffer = buffer[addr];

endmodule // axi_lite_slave
