`timescale 1ns / 1ps

module mux3#(parameter WIDTH=32)(
    input [WIDTH-1:0] sel_0,sel_1,sel_2,
    input [1:0] sel_signal,
    output [WIDTH-1:0] sel_result
    );
    assign sel_result = (sel_signal == 2'b00) ? sel_0 :
						(sel_signal == 2'b01) ? sel_1 :
						(sel_signal == 2'b10) ? sel_2 :
						sel_0;
endmodule