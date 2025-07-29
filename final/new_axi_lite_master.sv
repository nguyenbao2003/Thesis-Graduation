module new_axi_lite_master #(
    parameter ADDR_W = 32,
    parameter DATA_W = 32
//    parameter STRB_W = DATA_W/8
)(
    //---------------------------------------------------------
    // Clock / Reset
    //---------------------------------------------------------
    input  logic                     aclk,
    input  logic                     areset_n,

    //---------------------------------------------------------
    // User control interface (1‑cycle pulse)
    //---------------------------------------------------------
    input  logic                     start_read,   // pulse -> issue AR* handshake
    input  logic                     start_write,  // pulse -> issue AW* & W* handshakes
    input  logic [ADDR_W-1:0]        addr,         // address for R/W (aligned)
    input  logic [DATA_W-1:0]        data,         // write data
//    input  logic [STRB_W-1:0]        wstrb,        // byte‑lane strobes
    output logic [DATA_W-1:0]        debug_rdata,  // last read data captured

    //---------------------------------------------------------
    // AXI‑Lite slave‑side signals
    //---------------------------------------------------------
    //  Read address
    output logic                     ARVALID,
    input  logic                     ARREADY,
    output logic [ADDR_W-1:0]        ARADDR,

    //  Read data
    input  logic                     RVALID,
    output logic                     RREADY,
    input  logic [DATA_W-1:0]        RDATA,

    //  Write address
    output logic                     AWVALID,
    input  logic                     AWREADY,
    output logic [ADDR_W-1:0]        AWADDR,

    //  Write data
    output logic                     WVALID,
    input  logic                     WREADY,
    output logic [DATA_W-1:0]        WDATA,
//    output logic [STRB_W-1:0]        WSTRB,

    //  Write response
    input  logic                     BVALID,
    output logic                     BREADY
);

    //-----------------------------------------------------
    // Local copies of address & data (latched on start_*)
    //-----------------------------------------------------
    logic [ADDR_W-1:0]  rd_addr_q, wr_addr_q;
    logic [DATA_W-1:0]  wr_data_q;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            rd_addr_q  <= '0;
            wr_addr_q  <= '0;
            wr_data_q  <= '0;
        end else begin
            if (start_read)  rd_addr_q <= addr;
            if (start_write) begin
                wr_addr_q  <= addr;
                wr_data_q  <= data;
            end
        end
    end

    //-----------------------------------------------------
    // Write‑channel FSM
    //-----------------------------------------------------
    typedef enum logic [1:0] {W_IDLE, W_ADDRDATA, W_RESP} wr_state_t;
    wr_state_t wr_state, wr_next;

    // default outputs
    always_comb begin
        AWVALID  = 1'b0;
        WVALID   = 1'b0;
        BREADY   = 1'b0;
        AWADDR   = wr_addr_q;
        WDATA    = wr_data_q;
        wr_next  = wr_state;

        case (wr_state)
            //-------------------------------------------------
            W_IDLE: begin
                if (start_write) begin
                    AWVALID = 1'b1;
                    WVALID  = 1'b1;
						  BREADY = 1'b1;             // always ready for respons
                    wr_next = W_ADDRDATA;
                end
            end
            //-------------------------------------------------
            W_ADDRDATA: begin
                AWVALID = 1'b1;           // hold until AW handshake
                WVALID  = 1'b1;           // hold until W  handshake
					 BREADY = 1'b1;             // always ready for response
                // Wait until both addresses and data accepted
                if (AWREADY && WREADY) begin
                    wr_next = W_RESP;
                end
            end
            //-------------------------------------------------
            W_RESP: begin
                BREADY = 1'b1;             // always ready for response
                if (BVALID) begin
                    wr_next = W_IDLE;
                end
            end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n)
            wr_state <= W_IDLE;
        else
            wr_state <= wr_next;
    end

    //-----------------------------------------------------
    // Read‑channel FSM
    //-----------------------------------------------------
    typedef enum logic [1:0] {R_IDLE, R_ADDR, R_DATA} rd_state_t;
    rd_state_t rd_state, rd_next;

    always_comb begin
        ARVALID  = 1'b0;
        RREADY   = 1'b0;
        ARADDR   = rd_addr_q;
        rd_next  = rd_state;

        case (rd_state)
            //-------------------------------------------------
            R_IDLE: begin
                if (start_read) begin
					     RREADY = 1'b1; 
                    ARVALID = 1'b1;
                    rd_next = R_ADDR;
                end
            end
            //-------------------------------------------------
            R_ADDR: begin
				    RREADY = 1'b1; 
                ARVALID = 1'b1;            // hold until handshake
                if (ARREADY) begin
                    rd_next = R_DATA;
                end
            end
            //-------------------------------------------------
            R_DATA: begin
					 ARVALID = 1'b1;  
                RREADY = 1'b1;             // keep ready high
                if (RVALID) begin
                    rd_next = R_IDLE;
                end
            end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n)
            rd_state <= R_IDLE;
        else
            rd_state <= rd_next;
    end

    //-----------------------------------------------------
    // Capture read data (debug / user access)
    //-----------------------------------------------------
    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n)
            debug_rdata <= '0;
        else if (RVALID && RREADY)
            debug_rdata <= RDATA;
    end

endmodule