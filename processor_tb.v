`timescale 1ns / 1ps
module processor_tb ();
  reg clk;
  reg reset;

  processor u_processor (.clk(clk),.reset(reset));

  initial begin
    clk <= 0;
    reset<=0;
    #2 reset =1;
    #2 reset =0;
    #200;
    $finish;
  end

  always begin
    #5 clk = ~clk;
  end
endmodule
