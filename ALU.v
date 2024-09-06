`timescale 1ns / 1ps

module ALU (
    input [15:0] data1,
    input [15:0] data2,
    input [2:0] control,
    output reg [15:0] result,
    output zero
);

  always @(*) begin
    case (control)
      3'd0: result = data1 + data2;
      3'd1: result = data1 - data2;
      3'd2: result = ~data1;
      3'd3: result = data1 << data2;
      3'd4: result = data1 >> data2;
      3'd5: result = data1 & data2;
      3'd6: result = data1 | data2;
      3'd7: result = (data1 < data2) ? 16'd1 : 16'd0;
      default: result = data1 + data2;
    endcase
  end

  assign zero = (result == 16'd0) ? 1'd1 : 1'd0;
endmodule
