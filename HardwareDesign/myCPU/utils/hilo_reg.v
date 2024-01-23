`timescale 1ns / 1ps

module hilo_reg(
    input wire clk,rst,we3,
    input [31:0] hi_i,lo_i,
    output wire [31:0] hi_o,lo_o
);
   reg [31:0] HI,LO;
   always @(negedge clk) begin
    if(rst) begin
        HI <= 0;
        LO <= 0;
    end else if(we3) begin
        HI <= hi_i;
        LO <= lo_i;
    end
   end
   assign hi_o = HI;
   assign lo_o = LO;
endmodule