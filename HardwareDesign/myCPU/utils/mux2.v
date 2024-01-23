`timescale 1ns / 1ps

// 决定writeRegister时，mux的输入并不是32位

module mux2#(parameter WIDTH=32)(
    input [WIDTH-1:0] sel_0,
    input [WIDTH-1:0] sel_1,
    input sel_signal,
    output [WIDTH-1:0] sel_result
    );
    assign sel_result = sel_signal ? sel_1 : sel_0;
endmodule