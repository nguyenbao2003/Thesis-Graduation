//module axi_lite_master(
//    input  logic 			aclk,
//    input  logic 			areset_n,
//    input  logic 			start_read,
//    input  logic 			start_write,
//    output logic [31:0] debug_rdata, // New port to expose rdata
//	 output logic 			arvalid_int, awvalid_int, wvalid_int, rready_int, bready_int,
//	 input  logic [31:0] addr, data,
//	 input  logic [ 3:0] wstrb,
//	 
//	 input  logic 			AWREADY, WREADY, ARREADY, RVALID, BVALID,
//	 output logic [31:0] ARADDR, AWADDR, s_WDATA,
//	 input  logic [31:0] s_rdata,
//	 output logic [ 2:0] state
//);
//
//    typedef enum logic [2:0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
//    state_type next_state;
//
//    logic [31:0] rdata;
//    logic start_read_delay, start_write_delay;
//	 
//	 assign ARADDR = addr;
//	 assign AWADDR = addr;
//	 assign s_WDATA = data;
//
//	 assign rdata = (state == RDATA)? s_rdata : 32'b0;
//    assign debug_rdata = rdata;
//
//    // Register delays for start_read and start_write
//    always_ff @(posedge aclk) begin
//        if (~areset_n) begin
//            start_read_delay <= 0;
//            start_write_delay <= 0;
//        end else begin
//            start_read_delay <= start_read;
//            start_write_delay <= start_write;
//        end
//    end
//
//    // State transition logic
//    always_comb begin
//        next_state = IDLE;
//        arvalid_int = 0;
//        awvalid_int = 0;
//        wvalid_int = 0;
//        rready_int = 0;
//        bready_int = 0;
//
//        case (state)
//            IDLE: begin
//                if (start_read_delay) begin
//                    next_state = RADDR;
//                    arvalid_int = 1;
//                end else if (start_write_delay) begin
//                    next_state = WADDR;
//                    awvalid_int = 1;
//                end
//            end
//
//            RADDR: begin
//                arvalid_int = 1;
//					 if (ARREADY) begin
//                    next_state = RDATA;
//                end
//            end
//
//            RDATA: begin
//                rready_int = 1;
//					 if (RVALID) begin
//                    next_state = IDLE;
//                end else begin
//					    next_state = RDATA;
//					 end
//            end
//
//            WADDR: begin
//                awvalid_int = 1;
//					 if (AWREADY) begin
//                    next_state = WDATA;
//						  wvalid_int = 1;
//                end
//            end
//
//            WDATA: begin
//                wvalid_int = 1;
//					 if (WREADY) begin
//                    next_state = WRESP;
//                end
//            end
//
//            WRESP: begin
//                bready_int = 1'b1;
//					 if (BVALID) begin
//                    next_state = IDLE;
//                end else begin
//					   next_state = WRESP;
//					 end
//            end
//
//            default: next_state = IDLE;
//        endcase
//    end
//
//    // State register
//    always_ff @(posedge aclk) begin
//        if (~areset_n) begin
//            state <= IDLE;
//        end else begin
//            state <= next_state;
//        end
//    end
//
//endmodule

//module axi_lite_master (
//    // Clock / reset
//    input  logic        aclk,
//    input  logic        areset_n,
//
//    // Control from your testbench / FSM
//    input  logic        start_read,
//    input  logic        start_write,
//
//    // Debug & state
//    output logic [31:0] debug_rdata,
//    output logic [2:0]  state,
//
//    // Expose the internal valid/ready for AW/AR/W/R/B
//    output logic        arvalid_int,
//    output logic        awvalid_int,
//    output logic        wvalid_int,
//    output logic        rready_int,
//    output logic        bready_int,
//
//    // Master → slave signals
//    input  logic [31:0] addr,
//    input  logic [31:0] data,
//    input  logic [ 3:0] wstrb,
//
//    // From the slave
//    input  logic        AWREADY,
//    input  logic        WREADY,
//    input  logic        ARREADY,
//    input  logic        RVALID,
//    input  logic        BVALID,
//
//    // To the slave
//    output logic [31:0] AWADDR,
//    output logic [31:0] ARADDR,
//    output logic [31:0] s_WDATA,
//
//    // From slave read‐data
//    input  logic [31:0] s_rdata,
//
//    // Master-side handshakes
//    output logic        arvalid,
//    output logic        awvalid,
//    output logic        wvalid,
//    output logic        rready,
//    output logic        bready
//);
//
//  //==========================================================================
//  // 1) Internal AXI “valid” signals drive FIFO pushes:
//  //==========================================================================
//  // Write Address
//  assign awvalid_int = start_write;
//  assign aw_push     = awvalid_int && AWREADY;
//  assign AWADDR      = addr;
//
//  // Write Data
//  assign wvalid_int = start_write;
//  assign w_push     = wvalid_int && WREADY;
//  assign s_WDATA    = data;
//
//  // Write Response
//  assign bready_int = start_write;  // or driven by your FSM
//  assign b_pop      = bready_int && BVALID;
//
//  // Read Address
//  assign arvalid_int = start_read;
//  assign ar_push     = arvalid_int && ARREADY;
//  assign ARADDR      = addr;
//
//  // Read Data
//  assign rready_int = start_read;
//  assign r_pop      = rready_int && RVALID;
//  assign debug_rdata = s_rdata;     // capture for debug
//
//  //==========================================================================
//  // 2) Five FIFO_32 instances (you said you already have these):
//  //    – AW FIFO: stores 32‐bit addresses
//  //    – W  FIFO: stores 32‐bit data
//  //    – B  FIFO: stores 2‐bit response (packed into 32 bits)
//  //    – AR FIFO: stores 32‐bit addresses
//  //    – R  FIFO: stores 32‐bit read data (resp packed)
//  //==========================================================================
//
//  // Write Address FIFO
//  logic aw_full,  aw_empty;
//  logic aw_writeEn, aw_readEn;
//  logic [31:0] aw_dataOut;
//  FIFO_32 aw_fifo (
//    .reset   (~areset_n),
//    .clk     (aclk),
//    .writeEn (aw_push),
//    .readEn  (aw_pop),
//    .dataIn  (AWADDR),
//    .dataOut (aw_dataOut),
//    .EMPTY   (aw_empty),
//    .FULL    (aw_full)
//  );
//  assign AWREADY = !aw_full;
//
//  // Write Data FIFO
//  logic w_full, w_empty;
//  logic w_writeEn, w_readEn;
//  logic [31:0] w_dataOut;
//  FIFO_32 w_fifo (
//    .reset   (~areset_n),
//    .clk     (aclk),
//    .writeEn (w_push),
//    .readEn  (w_pop),
//    .dataIn  (s_WDATA),
//    .wptr(), .rptr(),
//    .dataOut (w_dataOut),
//    .EMPTY   (w_empty),
//    .FULL    (w_full)
//  );
//  assign WREADY = !w_full;
//
//  // Write Response FIFO (we pack BRESP into lower bits)
//  logic b_full, b_empty;
//  logic b_writeEn, b_readEn;
//  logic [31:0] b_dataOut;
//  FIFO_32 b_fifo (
//    .reset   (~areset_n),
//    .clk     (aclk),
//    .writeEn (b_push),
//    .readEn  (b_pop),
//    .dataIn  ({30'd0, 2'b00}), // always OKAY
//    .wptr(), .rptr(),
//    .dataOut (b_dataOut),
//    .EMPTY   (b_empty),
//    .FULL    (b_full)
//  );
//  assign BVALID = !b_empty;
//  assign BRESP  = b_dataOut[1:0];
//
//  // Read Address FIFO
//  logic ar_full, ar_empty;
//  logic ar_writeEn, ar_readEn;
//  logic [31:0] ar_dataOut;
//  FIFO_32 ar_fifo (
//    .reset   (~areset_n),
//    .clk     (aclk),
//    .writeEn (ar_push),
//    .readEn  (ar_pop),
//    .dataIn  (ARADDR),
//    .wptr(), .rptr(),
//    .dataOut (ar_dataOut),
//    .EMPTY   (ar_empty),
//    .FULL    (ar_full)
//  );
//  assign ARREADY = !ar_full;
//
//  // Read Data FIFO
//  logic r_full, r_empty;
//  logic r_writeEn, r_readEn;
//  logic [31:0] r_dataOut;
//  FIFO_32 r_fifo (
//    .reset   (~areset_n),
//    .clk     (aclk),
//    .writeEn (r_push),
//    .readEn  (r_pop),
//    .dataIn  (s_rdata),
//    .wptr(), .rptr(),
//    .dataOut (r_dataOut),
//    .EMPTY   (r_empty),
//    .FULL    (r_full)
//  );
//  assign RVALID = !r_empty;
//  assign RDATA  = r_dataOut;
//
//  //==========================================================================
//  // 3) Simple FSMs to pop & push through each FIFO
//  //    (Exactly as before—just wired to these new names)
//  //==========================================================================
//
//  // Write FSM
//  typedef enum logic { WIDLE, WRESP } wstate_e;
//  wstate_e wstate;
//  always_ff @(posedge aclk or negedge areset_n) begin
//    if (!areset_n) begin
//      wstate  <= WIDLE;
//      aw_readEn <= 0;  w_readEn <= 0;  b_writeEn <= 0;
//    end else begin
//      aw_readEn <= 0;  w_readEn <= 0;  b_writeEn <= 0;
//      case (wstate)
//        WIDLE: if (!aw_empty && !w_empty) begin
//                  aw_readEn <= 1;
//                  w_readEn  <= 1;
//                  // ... perform your regfile write using aw_dataOut & w_dataOut ...
//                  b_writeEn <= 1;  // push OKAY
//                  wstate    <= WRESP;
//                end
//        WRESP: if (BVALID && bready_int) begin
//                  b_readEn <= 1;
//                  wstate   <= WIDLE;
//                end
//      endcase
//    end
//  end
//  assign aw_pop = aw_readEn;
//  assign w_pop  = w_readEn;
//  assign b_push = b_writeEn;
//
//  // Read FSM
//  typedef enum logic { RIDLE, RDATA } rstate_e;
//  rstate_e rstate;
//  always_ff @(posedge aclk or negedge areset_n) begin
//    if (!areset_n) begin
//      rstate   <= RIDLE;
//      ar_readEn <= 0;  r_writeEn <= 0;
//    end else begin
//      ar_readEn <= 0;  r_writeEn <= 0;
//      case (rstate)
//        RIDLE: if (!ar_empty) begin
//                  ar_readEn <= 1;
//                  // ... perform your regfile read using ar_dataOut ...
//                  r_writeEn <= 1;  // push read data
//                  rstate    <= RDATA;
//                end
//        RDATA: if (RVALID && rready_int) begin
//                  r_readEn <= 1;
//                  rstate   <= RIDLE;
//                end
//      endcase
//    end
//  end
//  assign ar_pop = ar_readEn;
//  assign r_push = r_writeEn;
//
//endmodule

///////////////////////////////////////////////////////////////
//  AXI‑Lite single‑master controller
//  -----------------------------------------------------------
//  ‑ Supports one outstanding read and one outstanding write
//  ‑ Independent FSMs for read and write paths (full duplex)
//  ‑ Compatible with simple AXI‑Lite slaves or AXI‑to‑APB bridges
//  -----------------------------------------------------------
//  © 2025 – feel free to adapt / extend
///////////////////////////////////////////////////////////////

module axi_lite_master #(
    parameter ADDR_W = 32,
    parameter DATA_W = 32,
    parameter STRB_W = DATA_W/8
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
    input  logic [STRB_W-1:0]        wstrb,        // byte‑lane strobes
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
    output logic [STRB_W-1:0]        WSTRB,

    //  Write response
    input  logic                     BVALID,
    output logic                     BREADY
);

    //-----------------------------------------------------
    // Local copies of address & data (latched on start_*)
    //-----------------------------------------------------
    logic [ADDR_W-1:0]  rd_addr_q, wr_addr_q;
    logic [DATA_W-1:0]  wr_data_q;
    logic [STRB_W-1:0]  wr_strb_q;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            rd_addr_q  <= '0;
            wr_addr_q  <= '0;
            wr_data_q  <= '0;
            wr_strb_q  <= '0;
        end else begin
            if (start_read)  rd_addr_q <= addr;
            if (start_write) begin
                wr_addr_q  <= addr;
                wr_data_q  <= data;
                wr_strb_q  <= wstrb;
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
        WSTRB    = wr_strb_q;
        wr_next  = wr_state;

        unique case (wr_state)
            //-------------------------------------------------
            W_IDLE: begin
                if (start_write) begin
                    AWVALID = 1'b1;
                    WVALID  = 1'b1;
                    wr_next = W_ADDRDATA;
                end
            end
            //-------------------------------------------------
            W_ADDRDATA: begin
                AWVALID = 1'b1;           // hold until AW handshake
                WVALID  = 1'b1;           // hold until W  handshake
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

        unique case (rd_state)
            //-------------------------------------------------
            R_IDLE: begin
                if (start_read) begin
                    ARVALID = 1'b1;
                    rd_next = R_ADDR;
                end
            end
            //-------------------------------------------------
            R_ADDR: begin
                ARVALID = 1'b1;            // hold until handshake
                if (ARREADY) begin
                    rd_next = R_DATA;
                end
            end
            //-------------------------------------------------
            R_DATA: begin
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