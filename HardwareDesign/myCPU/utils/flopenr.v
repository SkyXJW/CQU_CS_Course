`timescale 1ns / 1ps


module flopenr #(parameter WIDTH = 32)(
	input clk,rst,en,
	input [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q
    );
	always @(posedge clk) begin
		if(rst) 
			q <= 0;
		else if(en) 
			q <= d;
	end
endmodule
