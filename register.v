`timescale 1ns / 1ps

module register (
    input clk,
    input write_en,
    input [2:0] write_dest,
    input [15:0] write_data,
    input [2:0] read_dest_1,
    input [2:0] read_dest_2,
    output [15:0] read_data_1,
    output [15:0] read_data_2
);
  reg [15:0] register_array[7:0];
  integer i;

  initial begin
    for (i = 0; i < 8; i = i + 1) register_array[i] = 16'd0+i;
  end

  always @(posedge clk) begin
    if (write_en) register_array[write_dest] <= write_data;
  end

  assign read_data_1 = register_array[read_dest_1];
  assign read_data_2 = register_array[read_dest_2];
endmodule
