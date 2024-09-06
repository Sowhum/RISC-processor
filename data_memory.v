`timescale 1ns / 1ps

module data_memory (
    input    clk,
    input    write_en,
    input    read_en,
    input    [15:0] addr,
    input    [15:0] write_data,
    output    [15:0] read_data
);

  reg [15:0] memory[7:0];
  initial begin
    $readmemb("data.mem", memory);
  end

  always @(posedge clk) begin
    if (write_en) begin
      memory[addr[2:0]] <= write_data;
    end
  end

  assign read_data = (read_en == 1'b1) ? memory[addr[2:0]] : 16'd0;

endmodule
