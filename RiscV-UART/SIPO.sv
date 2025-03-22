//module SIPO(
//    input  logic        reset_n,        //  Active low reset.
//    input  logic        data_tx,        //  Serial Data received from the transmitter.
//    input  logic        baud_clk,       //  The clocking input comes from the sampling unit.
//
//    output logic        active_flag,    //  Outputs logic 1 when data is in progress.
//    output logic        recieved_flag,  //  Outputs a signal enabling the deframe unit. 
//    output logic [10:0] data_parll, data_parll_temp       //  Outputs the 11-bit parallel frame.
//);
//
//    // Internal declarations
//    logic [10:0] temp;
//    logic [3:0]  frame_counter, stop_count;
//    logic [1:0]  next_state;
//
//    // Encoding the states of the receiver
// 
//localparam IDLE   = 2'b00,
//           CENTER = 2'b01,
//           FRAME  = 2'b11,
//           GET    = 2'b10;
//
//
//    // Receiving logic FSM
//    always_ff @(posedge baud_clk or negedge reset_n) begin
//        if (!reset_n) begin
//            next_state    <= IDLE;
//            stop_count    <= 4'd0;
//            frame_counter <= 4'd0;
//            temp          <= {11{1'b1}};
//        end else begin
//            case (next_state)
//                IDLE: begin
//                    temp          <= {11{1'b1}};
//                    stop_count    <= 4'd0;
//                    frame_counter <= 4'd0;
//                    if (!data_tx) begin
//                        next_state <= CENTER;
//                    end else begin
//                        next_state <= IDLE;
//                    end
//                end
//
//                CENTER: begin
//                    if (stop_count == 4'd6) begin
//                        stop_count  <= 4'd0;
//                        next_state  <= GET;
//                    end else begin
//                        stop_count  <= stop_count + 4'd1;
//                        next_state  <= CENTER;
//                    end
//                end
//
//                FRAME: begin
//                    temp <= data_parll_temp;
//                    if (frame_counter == 4'd10) begin
//                        frame_counter <= 4'd0;
//                        next_state    <= IDLE;
//                    end else begin
//                        if (stop_count == 4'd14) begin
//                            frame_counter <= frame_counter + 4'd1;
//                            stop_count    <= 4'd0; 
//                            next_state    <= GET;
//                        end else begin
//                            stop_count    <= stop_count + 4'd1;
//                            next_state    <= FRAME;
//                        end
//                    end
//                end
//
//                GET: begin 
//                    next_state <= FRAME;
//                    temp       <= data_parll_temp;
//                end
//            endcase
//        end
//    end
//
//    always_comb begin
//        case (next_state)
//            IDLE, CENTER, FRAME: data_parll_temp = temp;
//
//            GET: begin
//                data_parll_temp     = temp >> 1;
//                data_parll_temp[10] = data_tx;
//            end
//        endcase
//    end
//
//    assign data_parll    = recieved_flag ? data_parll_temp : {11{1'b1}};
//    assign recieved_flag = (frame_counter == 4'd10);
//    assign active_flag   = !recieved_flag;
//
//endmodule
//

//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  FILE NAME: SIPO.v
//  TYPE: module.
//  DATE: 31/8/2022
//  KEYWORDS: SIPO, Shift register, Reciever.
//  PURPOSE: An RTL modelling for a Serial-In-Parallel-Out shift register,
//  controlled by an FSM to satisfy the UART-Rx protocol.
//  Stores the data recieved at the positive-clock-edges [BaudRate], then
//  pass the data frame to the DeFrame unit. 

module SIPO(
    input  wire         reset_n,        //  Active low reset.
    input  wire         data_tx,        //  Serial Data recieved from the transmitter.
    input  wire         baud_clk,       //  The clocking input comes from the sampling unit.

    output reg          active_flag,    //  outputs logic 1 when data is in progress.
    output reg          recieved_flag,  //  outputs a signal enables the deframe unit. 
    output reg  [10:0]  data_parll      //  outputs the 11-bit parallel frame.
);
//  Internal
reg [3:0]  frame_counter;
reg [3:0]  stop_count;
reg [1:0]  next_state;

//  Encoding the states of the reciever
//  Every State captures the corresponding bit from the frame
localparam IDLE   = 2'b00,
           CENTER = 2'b01,
           FRAME  = 2'b10,
           HOLD   = 2'b11;

//  FSM with Asynchronous Reset logic
always @(posedge baud_clk, negedge reset_n) 
begin
  if (~reset_n) 
  begin
    next_state        <= IDLE;
  end
  else
  begin
    case (next_state)
      //  Idle case waits untill start bit
      IDLE : 
      begin
        data_parll    <= {11{1'b1}};
        stop_count    <= 4'd0;
        frame_counter <= 4'd0;
        recieved_flag <= 1'b0;
        active_flag   <= 1'b0;
        //  waits till sensing the start bit which is low
        if(~data_tx)
        begin
          next_state  <= CENTER;
          active_flag <= 1'b1;
        end
        else
        begin
          next_state  <= IDLE;
          active_flag <= 1'b0;
        end
      end

      //  shifts the sampling to the Center of the recieved bit
      //  due to the protocol, thus the bit is stable.
      CENTER : 
      begin
        if(&stop_count[2:0])
        //  This is an equivalent condition to (stop_count == 7)
        //  in order to avoid comparators/xors
        begin
          //  Captures the start bit
          data_parll[0]  <= data_tx;
          stop_count     <= 4'd0;
          next_state     <= FRAME;
        end
        else
        begin
          stop_count  <= stop_count + 4'b1;
          next_state  <= CENTER;
        end
      end

      //  shifts the remaining 10-bits of the frame,
      //  then returns to the idle case.
      FRAME :
      begin
        if(frame_counter[1] && frame_counter[3])
        //  This is an equivalent condition to (frame_counter == 4'd10)
        //  in order to avoid comparators/xors
        begin
          frame_counter <= 4'd0;
          recieved_flag <= 1'b1;
          next_state    <= HOLD;
          active_flag   <= 1'b0;
        end
        else
        begin
          if(&stop_count[3:0])
          //  This is an equivalent condition to (stop_count == 4'd15)
          //  in order to avoid comparators/xors
          begin
            data_parll[frame_counter + 4'd1]    <= data_tx;
            frame_counter                       <= frame_counter + 4'b1;
            stop_count                          <= 4'd0; 
            next_state                          <= FRAME;
          end
          else 
          begin
            stop_count <= stop_count + 4'b1;
            next_state <= FRAME;
          end
        end
      end

      //  Holds the data recieved for a 16 baud cycles
      HOLD :
      begin
        if(&stop_count[3:0])
          //  This is an equivalent condition to (stop_count == 4'd15)
          //  in order to avoid comparators/xors
          begin
            data_parll    <= data_parll;
            frame_counter <= 4'd0;
            stop_count    <= 4'd0; 
            recieved_flag <= 1'b0;
            next_state    <= IDLE;
          end
          else 
          begin
            stop_count <= stop_count + 4'b1;
            next_state <= HOLD;
          end
      end

      //  Automatically directs to the IDLE state
      default : 
      begin
        next_state <= IDLE;
      end
    endcase
  end
end

endmodule
