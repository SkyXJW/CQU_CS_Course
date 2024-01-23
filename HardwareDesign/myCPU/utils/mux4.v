`timescale 1ns / 1ps

module mux4#(parameter WIDTH=32)(
    input [WIDTH-1:0] sel_0,sel_1,sel_2,sel_3,
    input [2:0] sel_signal,
    output [WIDTH-1:0] sel_result
    );
    assign sel_result = (sel_signal == 3'b000) ? sel_0 :
						(sel_signal == 3'b001) ? sel_1 :
						(sel_signal == 3'b010) ? sel_2 :
                        (sel_signal == 3'b100) ? sel_3 :
						sel_0;
endmodule