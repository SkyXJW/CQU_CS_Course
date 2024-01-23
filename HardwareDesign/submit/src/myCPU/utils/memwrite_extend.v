`include "./control_signal_define.vh"
`timescale 1ns / 1ps

module memwrite_extend #(parameter WIDTH = 32)(
    input [WIDTH-1:0] writedata,
    input [3:0] memwriteEN,
    output reg [WIDTH-1:0] extended
    );

    always@ (*) begin
        case(memwriteEN)
            `memWrite_HALF: extended = {writedata[15:0], writedata[15:0]};
            `memWrite_BYTE: extended = {writedata[7:0], writedata[7:0], writedata[7:0], writedata[7:0]};
            default:        extended = writedata;
        endcase
    end
endmodule
