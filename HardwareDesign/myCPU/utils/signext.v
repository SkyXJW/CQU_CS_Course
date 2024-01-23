`include "./defines2.vh"
`timescale 1ns / 1ps

module signext(
    input [5:0] op,
    input [15:0] a,
    output reg [31:0] a_ext
    );
    // 数据扩展
    always @(*) begin
        case(op)
            `LUI: a_ext = {a, {16{1'b0}}};
            `ORI, `ANDI, `XORI: a_ext = {{16{1'b0}}, a};
            default: a_ext = { {16{a[15]}} ,a};
        endcase
    end
endmodule