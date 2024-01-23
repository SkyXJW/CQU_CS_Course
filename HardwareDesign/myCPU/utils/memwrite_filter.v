`include "./control_signal_define.vh"
`timescale 1ns / 1ps

module memwrite_filter #(parameter WIDTH = 32)(
    input [WIDTH-1:0] addr,
    input [3:0] memwriteEN,
    output reg [3:0] memwriteEN_filterd
    );

    // 根据addr的偏移来确定SH是低半字还是高半字
    //                  SB是哪个字节
    // 例如，如果addr是10，那么SH就是高半字（也可以看作将原本的0011左移两位，变成1100）
    // 再例如，如果addr是11，那么SB就是最高的那个字节（也可以看作将原本的0001左移三位，变成1000）

    always@ (*) begin
        case(memwriteEN)
            `memWrite_WORD: memwriteEN_filterd = `memWrite_WORD;
            `memWrite_HALF: begin
                case(addr[1:0])
                    2'b00:   memwriteEN_filterd = `memWrite_HALF;
                    2'b10:   memwriteEN_filterd = `memWrite_HALF << 2;
                    default: memwriteEN_filterd = 4'b0000; // 按理说不应该发生，需要例外
                endcase
            end
            `memWrite_BYTE: begin
                case(addr[1:0])
                    2'b00:   memwriteEN_filterd = `memWrite_BYTE;
                    2'b01:   memwriteEN_filterd = `memWrite_BYTE << 1;
                    2'b10:   memwriteEN_filterd = `memWrite_BYTE << 2;
                    2'b11:   memwriteEN_filterd = `memWrite_BYTE << 3;
                    default: memwriteEN_filterd = 4'b0000; // 按理说不应该发生，需要例外
                endcase
            end
            default:        memwriteEN_filterd = `memWrite_OFF;
        endcase
    end
endmodule
