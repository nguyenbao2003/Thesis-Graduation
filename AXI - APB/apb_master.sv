module apb_master(
    input logic SWRITE ,
    input logic [31:0] SADDR , SWDATA , 
    input logic [3:0] SSTRB ,
    input logic [2:0] SPROT  ,
    input logic transfer ,   //to indicate the begenning of the transfer

    //the followin signals are Mater signals
    output logic PSEL , PENABLE , PWRITE ,
    output logic [31:0] PADDR , PWDATA ,
    output logic [3:0] PSTRB ,
    output logic [2:0] PPROT ,
    input logic PCLK , PRESETn ,
    input logic PREADY ,
    input logic PSLVERR
);
//defining our states
localparam  IDLE = 2'b00,
            SETUP = 2'b01,
            ACCESS = 2'b10;
(* fsm_encoding = "one_hot" *)
reg [1:0] ns , cs ; //next state , current state

//state memory 
always_ff @(posedge PCLK , negedge PRESETn)
begin
    if(~PRESETn) begin 
        cs <= IDLE;
//		  PSEL <= 0;
//        PENABLE <= 0;
//        PWRITE <= 0;
//        PADDR <= 0;
//        PWDATA <= 0;
//        PSTRB <= 0;
//        PPROT <= 0;
    end else 
        cs <= ns ;
end

//next state logic
always_comb begin
    case(cs)
        IDLE : begin
            if(transfer)
                ns = SETUP;
            else
                ns = IDLE;
        end
        SETUP : ns = ACCESS ; //The bus only remains in the SETUP state for one clock cycle and always moves to the ACCESS state on the next rising edge of the clock
        ACCESS : begin
            if(PREADY && !transfer)
                ns = IDLE ;
            else if(PREADY && transfer)
                ns = SETUP ;
            else
                ns = ACCESS ;
        end
        default : ns = IDLE;
    endcase
end

//output logic
always_comb begin
//    if(~PRESETn)
//        begin
            PSEL = 0;
            PENABLE = 0;
            PWRITE = 0;
            PADDR = 0;
            PWDATA = 0;
            PSTRB = 0;
            PPROT = 0;
        case(cs)
            IDLE : begin
                PSEL = 0;
                PENABLE = 0;
            end
            SETUP : begin
                PSEL = 1;
                PENABLE = 0;   //signals are sent to slave in setup state
                PWRITE = SWRITE ;
                PADDR = SADDR ;
                PWDATA = SWDATA ;
                PSTRB = SSTRB ;
                PPROT = SPROT ;
            end
            ACCESS : begin
                PSEL = 1;
                PENABLE = 1;
            end
        endcase
//	end
end
endmodule