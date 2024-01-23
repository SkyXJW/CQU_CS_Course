`timescale 1ns / 1ps

module mux6#(parameter WIDTH=32)(
    input [WIDTH-1:0] sel_0,sel_1,sel_2,sel_3,sel_4,sel_5,
    input [4:0] sel_signal,
    output [WIDTH-1:0] sel_result
    );
    assign sel_result = (sel_signal == 5'b00000) ? sel_0 :
						(sel_signal == 5'b10000) ? sel_1 :
						(sel_signal == 5'b01000) ? sel_2 :
                        (sel_signal == 5'b00100) ? sel_3 :
                        (sel_signal == 5'b00010) ? sel_4 :
                        (sel_signal == 5'b00001) ? sel_5 :
						sel_0;
endmodule