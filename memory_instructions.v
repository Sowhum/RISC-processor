`timescale 1ns / 1ps

module memory_instructions (
    input  [15:0] pc,
    output [15:0] instruction
);

  reg [15:0] memory[15:0];
  wire [3:0] address = pc[4:1];

  initial begin
    $readmemb("instructions.mem", memory, 0, 14);
  end

  assign instruction = memory[address];
endmodule
