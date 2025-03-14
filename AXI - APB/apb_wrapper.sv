module apb_wrapper (
    input logic PCLK , PRESETn ,
    input logic SWRITE ,
    input logic [31:0] SADDR , SWDATA , 
    input logic [3:0] SSTRB ,
    input logic [2:0] SPROT  ,
    input logic transfer ,
    output logic [31:0] PRDATA,
	 output logic PSEL , PENABLE , PWRITE, PREADY, PSLVERR
);
//logic PSEL , PENABLE , PWRITE ;
logic [31:0] PADDR , PWDATA ;
logic [3:0] PSTRB ;
logic [2:0] PPROT ;
// logic PREADY , PSLVERR ;

//instantiating our master
apb_master Master (
    .PCLK (PCLK),
    .PRESETn(PRESETn),
    .SWRITE(SWRITE),
    .SADDR(SADDR),
    .SWDATA(SWDATA),
    .SSTRB(SSTRB),
    .SPROT(SPROT),
    .transfer(transfer),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSTRB(PSTRB),
    .PPROT(PPROT),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
);

//instantiating our slave
apb_slave Slave (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSTRB(PSTRB),
    .PPROT(PPROT),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .PRDATA(PRDATA)
);
endmodule