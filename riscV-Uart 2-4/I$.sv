module I$ (
  input  logic [31:0]  pc   ,
  output logic [31:0]  instr,
  output logic [31:0]  instr_debug
);
  logic [31:0] instructions_Value [255:0];  // maximum 2048 instruction

  initial begin
    //prefer absolute paths in simulators
    $readmemh("C://Users//NCB//Documents//Capstone2//Quartus//APB-UART done//instruction.txt", instructions_Value);
  end

  always_comb begin
    instr = instructions_Value[pc[31:2]];  //instead, we can ignore the least 2 LSBs
  end
  
  assign instr_debug = instr;
    
endmodule

